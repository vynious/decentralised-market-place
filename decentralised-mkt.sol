// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DecentralizedArtMarketplace is ERC721 {
    struct Artwork {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 price;
        bool isAvailable;
    }

    mapping(uint256 => Artwork) public artworks;
    uint256 public artworkCount;

    event ArtworkCreated(uint256 id, address creator, string title, uint256 price);
    event ArtworkPurchased(uint256 id, address buyer, uint256 price);

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        artworkCount = 0;
    }

    function createArtwork(string memory _title, string memory _description, uint256 _price) external {
        require(bytes(_title).length > 0, "Title is required");
        require(_price > 0, "Price must be greater than 0");

        artworkCount++;
        uint256 tokenId = artworkCount;
        _safeMint(msg.sender, tokenId);

        artworks[tokenId] = Artwork({
            id: tokenId,
            creator: msg.sender,
            title: _title,
            description: _description,
            price: _price,
            isAvailable: true
        });

        emit ArtworkCreated(tokenId, msg.sender, _title, _price);
    }

    function purchaseArtwork(uint256 _artworkId) external payable {
        require(_artworkId > 0 && _artworkId <= artworkCount, "Invalid artwork ID");

        Artwork storage artwork = artworks[_artworkId];
        require(artwork.isAvailable, "Artwork is not available for purchase");
        require(msg.value == artwork.price, "Incorrect payment amount");

        artwork.isAvailable = false;
        _transfer(artwork.creator, msg.sender, _artworkId);

        emit ArtworkPurchased(_artworkId, msg.sender, msg.value);
    }
}
