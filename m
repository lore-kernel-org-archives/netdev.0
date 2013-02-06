From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the crypto tree with the net-next tree
Date: Wed, 6 Feb 2013 13:20:11 +1100
Message-ID: <20130206132011.9084f982f783cd9d298f187d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__6_Feb_2013_13_20_11_+1100_hG_/3vx8/=7B5y+1"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Julia Lawall <Julia.Lawall@lip6.fr>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__6_Feb_2013_13_20_11_+1100_hG_/3vx8/=7B5y+1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Herbert,

Today's linux-next merge of the crypto tree got a conflict in
crypto/ctr.c between commit 69d3150cfc20 ("crypto: ctr - make rfc3686
asynchronous block cipher") from the net-next tree and commit
3e8afe35c36f ("crypto: use ERR_CAST") from the crypto tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc crypto/ctr.c
index 1f2997c,095dcb6..0000000
--- a/crypto/ctr.c
+++ b/crypto/ctr.c
@@@ -335,40 -324,18 +335,38 @@@ static void crypto_rfc3686_exit_tfm(str
 =20
  static struct crypto_instance *crypto_rfc3686_alloc(struct rtattr **tb)
  {
 +	struct crypto_attr_type *algt;
  	struct crypto_instance *inst;
  	struct crypto_alg *alg;
 +	struct crypto_skcipher_spawn *spawn;
 +	const char *cipher_name;
  	int err;
 =20
 -	err =3D crypto_check_attr_type(tb, CRYPTO_ALG_TYPE_BLKCIPHER);
 +	algt =3D crypto_get_attr_type(tb);
- 	err =3D PTR_ERR(algt);
 +	if (IS_ERR(algt))
- 		return ERR_PTR(err);
++		return ERR_CAST(algt);
 +
 +	if ((algt->type ^ CRYPTO_ALG_TYPE_BLKCIPHER) & algt->mask)
 +		return ERR_PTR(-EINVAL);
 +
 +	cipher_name =3D crypto_attr_alg_name(tb[1]);
- 	err =3D PTR_ERR(cipher_name);
 +	if (IS_ERR(cipher_name))
- 		return ERR_PTR(err);
++		return ERR_CAST(cipher_name);
 +
 +	inst =3D kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
 +	if (!inst)
 +		return ERR_PTR(-ENOMEM);
 +
 +	spawn =3D crypto_instance_ctx(inst);
 +
 +	crypto_set_skcipher_spawn(spawn, inst);
 +	err =3D crypto_grab_skcipher(spawn, cipher_name, 0,
 +				   crypto_requires_sync(algt->type,
 +							algt->mask));
  	if (err)
 -		return ERR_PTR(err);
 +		goto err_free_inst;
 =20
 -	alg =3D crypto_attr_alg(tb[1], CRYPTO_ALG_TYPE_BLKCIPHER,
 -				  CRYPTO_ALG_TYPE_MASK);
 -	if (IS_ERR(alg))
 -		return ERR_CAST(alg);
 +	alg =3D crypto_skcipher_spawn_alg(spawn);
 =20
  	/* We only support 16-byte blocks. */
  	err =3D -EINVAL;

--Signature=_Wed__6_Feb_2013_13_20_11_+1100_hG_/3vx8/=7B5y+1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJREb3bAAoJEECxmPOUX5FExwAP/1+AsMQON4aljhGUNCwC/HEZ
gg90Bl9WRM6x7rMlVEdUZvFUHFDv/9cEyufR/ZaawdXaH6bg1gbuIHbkc+vigHev
g5J8rjJSCSMX6N4CtTlPZQI4Uo6rlis4xw5vBnmlz7d+VOFb5sPENykRCy52//wc
sfAZ9FWv9bcyPOJO5kk0WhRC7gnlJLjuPzMIrhibqwd01wtwjRNFxx2e9pk9paUp
2r9nB27c66lU9X8FH5Q/8uUGJ4I8MdGHus/Uf/SeT8JOdfEi2tePmeV+UCYIM7MK
EveqGAzl6HGri0D2BJrU4TiqB7ATUPnHNfc+bcFsYzrO4N/SLwat3+koowVYVk01
1og8V1FzLZYYV3cOkQNiA3VMUnsT3Z8JPAn9mKwWm1kY8Jz4exeLOwoeUrz3K+v5
qzoCDE/qZStYeJpeh1aHp8M3AH4iaoJWbmubsrnIGYtEIOi+0dOduoJsFcY1Dhjz
Mw7P8bYwermzkqg98BjwCDnMC1Kx47rRJtSMKUguReWVuTfRzA0kaY5PxMu5DuvQ
+GebmDrlXD5911Qgsu3Jb9OmGkfkzNI+CUInwCpNKyHtN5UJ/EhorcVkqGQuRSIJ
a+4ZijOZegdk0w2iT+d7clPjKs3u0cFvNRp2m0nSvtFJiBCgSEv95SeVUiLluKBl
Y+A5MWLK0xWQELGVBVr4
=WK/T
-----END PGP SIGNATURE-----

--Signature=_Wed__6_Feb_2013_13_20_11_+1100_hG_/3vx8/=7B5y+1--
