From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 24 Mar 2015 13:45:08 +1100
Message-ID: <20150324134508.77b039a9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/O7yrgSJSJ3WK5M7d.OOJKnA"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Tadeusz Struk <tadeusz.struk@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/O7yrgSJSJ3WK5M7d.OOJKnA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

crypto/algif_skcipher.c: In function 'skcipher_async_cb':
crypto/algif_skcipher.c:109:2: error: implicit declaration of function 'aio=
_complete' [-Werror=3Dimplicit-function-declaration]
  aio_complete(iocb, err, err);
  ^

Caused by commit a596999b7ddf ("crypto: algif - change algif_skcipher
to be asynchronous") interacting with commit 04b2fa9f8f36 ("fs: split
generic and aio kiocb") from the vfs tree.

I applied the following merge fix patch (which gets it building, but I
am not sure if more is needed).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 24 Mar 2015 13:40:45 +1100
Subject: [PATCH] crypto: algif - cope with aio_complete() going away

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 crypto/algif_skcipher.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 8276f21ea7be..506eb5f62b03 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -106,7 +106,7 @@ static void skcipher_async_cb(struct crypto_async_reque=
st *req, int err)
 	atomic_dec(&ctx->inflight);
 	skcipher_free_async_sgls(sreq);
 	kfree(req);
-	aio_complete(iocb, err, err);
+	iocb->ki_complete(iocb, err, err);
 }
=20
 static inline int skcipher_sndbuf(struct sock *sk)
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/O7yrgSJSJ3WK5M7d.OOJKnA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVEM+5AAoJEMDTa8Ir7ZwV+sgP/2JnjiBeOz2gS4R13NnjW4jp
ijTKoXgGFwb+6+DXWHktBbosJNRi3iLORdeYtYg6+l9urSOsZzhYQbLajeYHUIld
Q5P68tpB2JNLyz+pIYKdsjhPa3YzwfRheYCG6PSxpwuFH7ixIlMSf16e00fovAeC
Z4bBglqYHfiQbQDWZWX0YC0wleDpNw3j4bwv+NN/tF41EmLOC0pcWumGUPE+7KJO
P8IMUqJ3znLIbUzHKvfLb5sdj0HXlQBtia1SZjqpHOLB+Y84HdLy9mFuKj6FUw7J
0u6J/uQnZSk1os35aZz3cVHcK0CiKX3ibrSihEMwSmNbQRcNVMbAzZTrtbBMAKxO
fRccnG45ot0+QZQDrZGbaJCrAvz+rTKnoQQtOXMCxHeLClwzNMDN2VNpNep9C7Pl
IH/uCQDK0zQKpnPZ4AL/qqwitqNGe228RNyA0Eq6AiUZ6sHI9ugRo+NTxNQ2BlfJ
/doRR5bOrlLRMOXDqbI4RF8FPFESf5kh/jh/B0QVvUsp5IFtBMUEKfJj1TH2TGa/
5md5RPR/O4D+6/paOxSYof2rAs4+9fsq0j5uWVUe0l690vuM4sFf34BFttuWzAco
2K8alQc3YaybbtELf3PJWzuz8u8ddLrVJ2qf/C2CzMT7OyctczqnKuEZIUe/4Ji0
+USeZr3WedbQJuYOgSTl
=HZPt
-----END PGP SIGNATURE-----

--Sig_/O7yrgSJSJ3WK5M7d.OOJKnA--
