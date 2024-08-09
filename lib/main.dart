import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Groovy 2.0')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.music_note,
              size: 100,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedSection = 'Songs';
  final List<Map<String, String>> _favourites = [];
  final List<Map<String, String>> _songs = [
    {'title': 'Lemon', 'artist': 'Kenshi Yonezu', 'album': 'Lemon', 'duration': '4:16'},
    {'title': 'orion', 'artist': 'Kenshi Yonezu', 'album': 'BOOTLEG', 'duration': '4:41'},
    {'title': 'End of Beginning', 'artist': 'Djo', 'album': 'DECIDE', 'duration': '2:39'},
    {'title': 'Mockingbird', 'artist': 'Eminem', 'album': 'Encore', 'duration': '4:10'},
    {'title': 'Line Without a Hook', 'artist': 'Ricky Montgomery', 'album': 'Montgomery Ricky', 'duration': '4:09'},
    {'title': 'Glimpse of Us', 'artist': 'Joji', 'album': 'Glimpse of Us', 'duration': '3:53'},
  ];
  final List<Map<String, dynamic>> _playlists = [];
  String _searchQuery = ''; // Add this for search query

  void _navigateTo(String section) {
    setState(() {
      _selectedSection = section;
    });
    print('Navigate to $section');
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String playlistName = '';
        return AlertDialog(
          title: const Text('Create New Playlist'),
          content: TextField(
            onChanged: (value) {
              playlistName = value;
            },
            decoration: const InputDecoration(
              labelText: 'Playlist Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (playlistName.isNotEmpty) {
                  setState(() {
                    _playlists.add({
                      'name': playlistName,
                      'songs': [],
                    });
                    print('New playlist created: $playlistName');
                  });
                }
              },
              child: const Text('Create'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddToPlaylistDialog(String songTitle) {
    showDialog(
      context: context, //find position in widget tree
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _playlists.isEmpty
                ? [const Text('No playlists available')]
                : _playlists.map((playlist) {
              return ListTile(
                title: Text(playlist['name']),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    playlist['songs'].add(songTitle);
                    print('Added $songTitle to playlist ${playlist['name']}');
                  });
                },
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); //to close dialog box
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFavourite(String title) {
    final song = _songs.firstWhere((song) => song['title'] == title);
    setState(() {
      if (_favourites.contains(song)) {
        _favourites.remove(song);
        print('Removed $title from Favourites');
      } else {
        _favourites.add(song);
        print('Added $title to Favourites');
      }
    });
  }

  bool _isFavourite(String title) {
    return _favourites.any((song) => song['title'] == title);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SongSearchDelegate(_songs, (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  }),
                ).then((_) {
                  setState(() {
                    _searchQuery = ''; // Reset query after search is done
                  });
                });
              },
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildStyledButton('Songs', () => _navigateTo('Songs')),
                  _buildStyledButton('Playlists', () => _navigateTo('Playlists')),
                  _buildStyledButton('Favourites', () => _navigateTo('Favourites')),
                ],
              ),
            ),
          ),
          Expanded(
            child: _selectedSection == 'Songs'
                ? _buildSongList()
                : _selectedSection == 'Playlists'
                ? _buildPlaylistList()
                : _buildFavouritesList(),
          ),
        ],
      ),
    );
  }


  Widget _buildStyledButton(String label, VoidCallback onPressed) {
    bool isSelected = _selectedSection == label;
    return GestureDetector( //taps, drags
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    final filteredSongs = _searchQuery.isEmpty
        ? _songs
        : _songs.where((song) {
      final title = song['title']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();

    return ListView(
      children: filteredSongs.map((song) {
        return _buildSongCard(
          song['title']!,
          song['artist']!,
          song['album']!,
          song['duration']!,
        );
      }).toList(),
    );
  }

  Widget _buildSongCard(String title, String artist, String album, String duration) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.music_note, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text('$artist - $album • $duration'),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.deepPurple),
          onSelected: (value) {
            if (value == 'Add to Favourites' || value == 'Remove from Favourites') {
              _toggleFavourite(title);
            } else if (value == 'Add to Playlist') {
              _showAddToPlaylistDialog(title);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: _isFavourite(title) ? 'Remove from Favourites' : 'Add to Favourites', //which item selected
                child: Text(_isFavourite(title) ? 'Remove from Favourites' : 'Add to Favourites'),
              ),
              PopupMenuItem<String>(
                value: 'Add to Playlist',
                child: Text('Add to Playlist'),
              ),
            ];
          },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SongPage(
                title: title,
                artist: artist,
                album: album,
                duration: duration,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                color: Colors.deepPurple,
                onPressed: _showCreatePlaylistDialog,
              ),
              Text(
                'Create Playlist',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              final playlist = _playlists[index];
              return _buildPlaylistCard(playlist['name'], '${playlist['songs'].length} songs');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistCard(String name, String songCount) {
    final playlist = _playlists.firstWhere((playlist) => playlist['name'] == name);
    final songTitles = List<String>.from(playlist['songs']);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(name),
        subtitle: Text(songCount),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.deepPurple),
          onSelected: (value) {
            if (value == 'Remove Playlist') {
              _showRemovePlaylistDialog(name);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'Remove Playlist',
                child: Text('Remove Playlist'),
              ),
            ];
          },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlaylistDetailPage(
                playlistName: name,
                songTitles: songTitles,
                allSongs: _songs,
                onRemoveFromPlaylist: (songTitle) {
                  setState(() {
                    playlist['songs'].remove(songTitle);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavouritesList() {
    return ListView(
      children: _favourites.map((song) {
        return _buildSongCard(
          song['title']!,
          song['artist']!,
          song['album']!,
          song['duration']!,
        );
      }).toList(),
    );
  }

  void _showRemovePlaylistDialog(String playlistName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Playlist'),
          content: Text('Are you sure you want to remove the playlist "$playlistName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _playlists.removeWhere((playlist) => playlist['name'] == playlistName);
                  print('Removed playlist $playlistName');
                });
              },
              child: Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

}

class SongSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, String>> songs;
  final Function(String) onSearch;

  SongSearchDelegate(this.songs, this.onSearch);

  @override
  @override
  Widget buildSuggestions(BuildContext context) {
    var query = this.query.toLowerCase();
    final suggestions = songs.where((song) {
      final title = song['title']!.toLowerCase(); //!asserting value is non null
      return title.contains(query);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final song = suggestions[index];
        return ListTile(
          title: Text(song['title']!),
          subtitle: Text('${song['artist']} - ${song['album']}'),
          onTap: () {
            query = song['title']!;
            onSearch(query);
            showResults(context);
          },
        );
      },
    );
  }


  @override
  Widget buildResults(BuildContext context) {
    var query = this.query.toLowerCase();
    final results = songs.where((song) {
      final title = song['title']!.toLowerCase();
      return title.contains(query);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text('No results found', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return ListTile(
          title: Text(song['title']!),
          subtitle: Text('${song['artist']} - ${song['album']}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SongPage(
                  title: song['title']!,
                  artist: song['artist']!,
                  album: song['album']!,
                  duration: song['duration']!,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query); // Clear search query on action
        },
      ),
    ];
  }
}

int parseDuration(String duration) {
  final parts = duration.split(':');
  if (parts.length == 2) {
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    return (minutes * 60) + seconds;
  }
  return 0;
}

class SongPage extends StatefulWidget {
  final String title;
  final String artist;
  final String album;
  final String duration;

  const SongPage({
    super.key,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
  });

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  double _currentPosition = 0.0;
  late double _totalDuration;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isLoop = false;
  Timer? _timer;
  List<Map<String, String>> _songs = [];
  int _currentIndex = 0; // Index of the current song

  String? _currentTitle;
  String? _currentArtist;
  String? _currentAlbum;
  String? _currentDuration;

  @override
  void initState() {
    super.initState();
    _totalDuration = parseDuration(widget.duration).toDouble();
    _songs = [
      {'title': 'Lemon', 'artist': 'Kenshi Yonezu', 'album': 'Lemon', 'duration': '4:16'},
      {'title': 'orion', 'artist': 'Kenshi Yonezu', 'album': 'BOOTLEG', 'duration': '4:41'},
      {'title': 'End of Beginning', 'artist': 'Djo', 'album': 'DECIDE', 'duration': '2:39'},
      {'title': 'Mockingbird', 'artist': 'Eminem', 'album': 'Encore', 'duration': '4:10'},
      {'title': 'Line Without a Hook', 'artist': 'Ricky Montgomery', 'album': 'Montgomery Ricky', 'duration': '4:09'},
      {'title': 'Glimpse of Us', 'artist': 'Joji', 'album': 'Glimpse of Us', 'duration': '3:53'},
    ];
    _currentIndex = _songs.indexWhere((song) => song['title'] == widget.title);
    _currentTitle = _songs[_currentIndex]['title'];
    _currentArtist = _songs[_currentIndex]['artist'];
    _currentAlbum = _songs[_currentIndex]['album'];
    _currentDuration = _songs[_currentIndex]['duration'];
    _totalDuration = parseDuration(_currentDuration!).toDouble();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isPlaying) {
        setState(() {
          _currentPosition += 0.5;
          if (_currentPosition >= _totalDuration) {
            if (_isLoop) {
              _currentPosition = 0; // Restart song if looping
            } else {
              //_isPlaying = false; // Pause when song ends
              _playNextSong(); // Automatically play next song
            }
          }
        });
      }
    });
  }

  void _playPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _playNextSong() {
    setState(() {
      if (_isShuffle) {
        _currentIndex = Random().nextInt(_songs.length); // Play a random song
      } else {
        _currentIndex = (_currentIndex + 1) % _songs.length; // Play next song
      }
      _currentPosition = 0.0;
      _currentTitle = _songs[_currentIndex]['title'];
      _currentArtist = _songs[_currentIndex]['artist'];
      _currentAlbum = _songs[_currentIndex]['album'];
      _currentDuration = _songs[_currentIndex]['duration'];
      _totalDuration = parseDuration(_currentDuration!).toDouble();
    });
  }

  void _playPreviousSong() {
    setState(() {
      if (_isShuffle) {
        _currentIndex = Random().nextInt(_songs.length); // Play a random song
      } else {
        _currentIndex = (_currentIndex - 1 + _songs.length) % _songs.length; // Play previous song
      }
      _currentPosition = 0.0;
      _currentTitle = _songs[_currentIndex]['title'];
      _currentArtist = _songs[_currentIndex]['artist'];
      _currentAlbum = _songs[_currentIndex]['album'];
      _currentDuration = _songs[_currentIndex]['duration'];
      _totalDuration = parseDuration(_currentDuration!).toDouble();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle ?? '', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 80),
          Icon(
            Icons.music_note,
            size: 150,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: <Widget>[
                Text(
                  _currentTitle ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${_currentArtist ?? ''} • ${_currentAlbum ?? ''}',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _currentDuration ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 160),
          Slider(
            value: _currentPosition,
            max: _totalDuration,
            onChanged: (value) {
              setState(() {
                _currentPosition = value;
              });
            },
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  _isShuffle ? Icons.shuffle : Icons.shuffle_outlined,
                  color: _isShuffle ? Colors.purpleAccent : Colors.deepPurple,
                  size: _isShuffle ? 30 : 24, // Increase size when active
                ),
                onPressed: () {
                  setState(() {
                    _isShuffle = !_isShuffle;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.deepPurple),
                onPressed: _playPreviousSong,
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.deepPurple,
                ),
                onPressed: _playPause,
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.deepPurple),
                onPressed: _playNextSong,
              ),
              IconButton(
                icon: Icon(
                  _isLoop ? Icons.repeat : Icons.repeat_outlined,
                  color: _isLoop ? Colors.purpleAccent : Colors.deepPurple,
                  size: _isLoop ? 30 : 24, // Increase size when active
                ),
                onPressed: () {
                  setState(() {
                    _isLoop = !_isLoop;
                  });
                },
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

}

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;
  final List<String> songTitles;
  final List<Map<String, String>> allSongs;
  final Function(String) onRemoveFromPlaylist;

  const PlaylistDetailPage({
    Key? key,
    required this.playlistName,
    required this.songTitles,
    required this.allSongs,
    required this.onRemoveFromPlaylist,
  }) : super(key: key);

  @override
  _PlaylistDetailPageState createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late List<String> _songTitles; //late:variable will be initialized later

  @override
  void initState() {
    super.initState();
    _songTitles = widget.songTitles;
  }

  void _removeFromPlaylist(String songTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Song'),
          content: Text('Are you sure you want to remove "$songTitle" from the playlist?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _songTitles.remove(songTitle); // Update local state
                  widget.onRemoveFromPlaylist(songTitle); // Notify parent
                });
                print('Removed $songTitle from Playlist');
              },
              child: Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: _songTitles.map((songTitle) {
          final song = _getSongDetails(songTitle);
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.music_note, color: Colors.deepPurple),
              title: Text(song['title']!),
              subtitle: Text('${song['artist']} - ${song['album']} • ${_formatDuration(song['duration']!)}'),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.deepPurple),
                onSelected: (value) {
                  if (value == 'Remove from Playlist') {
                    _removeFromPlaylist(songTitle);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'Remove from Playlist',
                      child: Text('Remove from Playlist'),
                    ),
                  ];
                },
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SongPage(
                      title: song['title']!,
                      artist: song['artist']!,
                      album: song['album']!,
                      duration: song['duration']!,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, String> _getSongDetails(String title) {
    return widget.allSongs.firstWhere(
          (song) => song['title'] == title,
      orElse: () => {'title': '', 'artist': '', 'album': '', 'duration': ''},
    );
  }

  String _formatDuration(String duration) {
    return duration;
  }
}