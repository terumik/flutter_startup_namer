import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

// shortcut: stl to create stateless widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.pink,
      ),
      title: 'Flutter Demo',
      home: RandomWords(),
    );
  }
}

// note: stf to create stateful widgeSt
// this SF widget will be thrown away/regenerate over the time, but the State will be held
class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() {
    print('createState() called');
    return _RandomWordsState();
  }
}

class _RandomWordsState extends State<RandomWords> {
  // setStateが呼ばれてもここにある変数は変更されないんだと思う（setStateでコールされるのは下のbuild()なので）
  final _suggestions = <WordPair>[];
  final _savedWords = <WordPair>{}; // Set{} does not allow dupulicate entries
  final _fontSize18 = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    print('_RandomWordsState.build()');
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Up Namer'),
        actions: [
          IconButton(
            onPressed: _pushFavoritesScreen,
            icon: Icon(Icons.list),
            tooltip: 'Show Favorites',
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  // List Builder
  Widget _buildSuggestions() {
    print('_buildSuggestions()');
    return ListView.builder(
        padding: EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int itemIndex) {
          // itemBuilderの挙動としてはfor...eachっぽい動きをする。
          // (generate itemIndex 0, check if odd or even, return row if even. generate itemIndex 1...)
          print({'Build ItemIndex', itemIndex});
          if (itemIndex.isOdd) {
            return Divider();
          }

          final int wordIndex =
              itemIndex ~/ 2; // (割り算の整数部を返す。つまり、現在表示されているWordPairの数までのIndex)
          print({'WordIndex', wordIndex});

          // 表示されているWordPairがSuggestionsリストに保存されているWordPairの数を超えた場合、新たに10個WordPairを作成
          if (wordIndex >= _suggestions.length) {
            print('Generate 10 word pairs');
            _suggestions.addAll(generateWordPairs().take(10));
          }

          // print({'Suggestions List after', _suggestions});
          return _buildRow(_suggestions[wordIndex]);
        });
  }

  // Row Builder
  Widget _buildRow(WordPair _wordPair) {
    final _hasSaved = _savedWords.contains(_wordPair);

    return ListTile(
      title: Text(
        _wordPair.asPascalCase,
        style: _fontSize18,
      ),
      trailing: Icon(
        _hasSaved ? Icons.favorite : Icons.favorite_border,
        color: _hasSaved ? Colors.pink : null,
        semanticLabel:
            _hasSaved ? 'Remove from favorites' : 'Save the word pair',
      ),
      onTap: () {
        // setState() notifies the framework that the state has been changed
        // In Flutter's reactive style framework,
        // calling setState() triggers a call to the build() method for the State object (_RandomWordsState),
        // resulting in an update to the UI.

        // setStateがコールされると、_RandomWordState.buildが再度コールされる（StatefulW内の"createState() called"はPrintされない。Build()のみ）
        setState(() {
          print('setState() called');
          if (_hasSaved) {
            _savedWords.remove(_wordPair);
          } else {
            _savedWords.add(_wordPair);
          }
        });
      },
    );
  }

  void _pushFavoritesScreen() {
    Navigator.of(context).push(
      // Push Route
      // 新しいページのコンテンツは、MaterialPageRoute の builder プロパティに作成されます
      MaterialPageRoute(
        builder: (context) {
          final tiles = _savedWords.map(
            (word) {
              // unlike ListView.builder(), ListTile is simply create a single tile
              return ListTile(
                title: Text(
                  word.asPascalCase,
                  style: _fontSize18,
                ),
              );
            },
          );

          final favoritesTiles = tiles.isNotEmpty
              ? ListTile.divideTiles(tiles: tiles, context: context).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: Text('My Favorites'),
            ),
            body: ListView(
              children: favoritesTiles,
            ),
          );
        },
      ),
    );
  }
}
