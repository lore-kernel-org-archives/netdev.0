From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [CRYPTO] Fix stack overrun in crypt()
Date: Thu, 15 Jul 2004 21:48:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715114840.GA1325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Cc: James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

The stack allocation in crypt() is bogus as whether tmp_src/tmp_dst
is used is determined by factors unrelated to nbytes and
src->length/dst->length.

Since the condition for whether tmp_src/tmp_dst are used is very
complex, let's allocate them always instead of guessing.

This fixes a number of weird crashes including those AES crashes
that people have been seeing with the 2.4 backport + ipt_conntrack.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

PS I think someone should double-check the logic in the scatterwalk
stuff, especially the whichbuf bits.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== crypto/cipher.c 1.18 vs edited =====
--- 1.18/crypto/cipher.c	2004-05-27 06:25:36 +10:00
+++ edited/crypto/cipher.c	2004-07-15 21:40:53 +10:00
@@ -52,8 +52,8 @@
 {
 	struct scatter_walk walk_in, walk_out;
 	const unsigned int bsize = crypto_tfm_alg_blocksize(tfm);
-	u8 tmp_src[nbytes > src->length ? bsize : 0];
-	u8 tmp_dst[nbytes > dst->length ? bsize : 0];
+	u8 tmp_src[bsize];
+	u8 tmp_dst[bsize];
 
 	if (!nbytes)
 		return 0;

--BOKacYhQ+x31HxR3--
