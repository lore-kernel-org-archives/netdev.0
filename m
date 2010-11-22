From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 02/11] crypto: Use scatterwalk_crypto_chain
Date: Mon, 22 Nov 2010 11:26:54 +0100
Message-ID: <20101122102654.GE1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use scatterwalk_crypto_chain in favor of locally defined chaining functions.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 crypto/authenc.c |   22 ++++------------------
 crypto/eseqiv.c  |   18 ++----------------
 crypto/gcm.c     |   19 ++-----------------
 3 files changed, 8 insertions(+), 51 deletions(-)

diff --git a/crypto/authenc.c b/crypto/authenc.c
index a5a22cf..5ef7ba6 100644
--- a/crypto/authenc.c
+++ b/crypto/authenc.c
@@ -107,20 +107,6 @@ badkey:
 	goto out;
 }
 
-static void authenc_chain(struct scatterlist *head, struct scatterlist *sg,
-			  int chain)
-{
-	if (chain) {
-		head->length += sg->length;
-		sg = scatterwalk_sg_next(sg);
-	}
-
-	if (sg)
-		scatterwalk_sg_chain(head, 2, sg);
-	else
-		sg_mark_end(head);
-}
-
 static void authenc_geniv_ahash_update_done(struct crypto_async_request *areq,
 					    int err)
 {
@@ -345,7 +331,7 @@ static int crypto_authenc_genicv(struct aead_request *req, u8 *iv,
 	if (ivsize) {
 		sg_init_table(cipher, 2);
 		sg_set_buf(cipher, iv, ivsize);
-		authenc_chain(cipher, dst, vdst == iv + ivsize);
+		scatterwalk_crypto_chain(cipher, dst, vdst == iv + ivsize, 2);
 		dst = cipher;
 		cryptlen += ivsize;
 	}
@@ -354,7 +340,7 @@ static int crypto_authenc_genicv(struct aead_request *req, u8 *iv,
 		authenc_ahash_fn = crypto_authenc_ahash;
 		sg_init_table(asg, 2);
 		sg_set_page(asg, sg_page(assoc), assoc->length, assoc->offset);
-		authenc_chain(asg, dst, 0);
+		scatterwalk_crypto_chain(asg, dst, 0, 2);
 		dst = asg;
 		cryptlen += req->assoclen;
 	}
@@ -499,7 +485,7 @@ static int crypto_authenc_iverify(struct aead_request *req, u8 *iv,
 	if (ivsize) {
 		sg_init_table(cipher, 2);
 		sg_set_buf(cipher, iv, ivsize);
-		authenc_chain(cipher, src, vsrc == iv + ivsize);
+		scatterwalk_crypto_chain(cipher, src, vsrc == iv + ivsize, 2);
 		src = cipher;
 		cryptlen += ivsize;
 	}
@@ -508,7 +494,7 @@ static int crypto_authenc_iverify(struct aead_request *req, u8 *iv,
 		authenc_ahash_fn = crypto_authenc_ahash;
 		sg_init_table(asg, 2);
 		sg_set_page(asg, sg_page(assoc), assoc->length, assoc->offset);
-		authenc_chain(asg, src, 0);
+		scatterwalk_crypto_chain(asg, src, 0, 2);
 		src = asg;
 		cryptlen += req->assoclen;
 	}
diff --git a/crypto/eseqiv.c b/crypto/eseqiv.c
index 3ca3b66..42ce9f5 100644
--- a/crypto/eseqiv.c
+++ b/crypto/eseqiv.c
@@ -62,20 +62,6 @@ out:
 	skcipher_givcrypt_complete(req, err);
 }
 
-static void eseqiv_chain(struct scatterlist *head, struct scatterlist *sg,
-			 int chain)
-{
-	if (chain) {
-		head->length += sg->length;
-		sg = scatterwalk_sg_next(sg);
-	}
-
-	if (sg)
-		scatterwalk_sg_chain(head, 2, sg);
-	else
-		sg_mark_end(head);
-}
-
 static int eseqiv_givencrypt(struct skcipher_givcrypt_request *req)
 {
 	struct crypto_ablkcipher *geniv = skcipher_givcrypt_reqtfm(req);
@@ -124,13 +110,13 @@ static int eseqiv_givencrypt(struct skcipher_givcrypt_request *req)
 
 	sg_init_table(reqctx->src, 2);
 	sg_set_buf(reqctx->src, giv, ivsize);
-	eseqiv_chain(reqctx->src, osrc, vsrc == giv + ivsize);
+	scatterwalk_crypto_chain(reqctx->src, osrc, vsrc == giv + ivsize, 2);
 
 	dst = reqctx->src;
 	if (osrc != odst) {
 		sg_init_table(reqctx->dst, 2);
 		sg_set_buf(reqctx->dst, giv, ivsize);
-		eseqiv_chain(reqctx->dst, odst, vdst == giv + ivsize);
+		scatterwalk_crypto_chain(reqctx->dst, odst, vdst == giv + ivsize, 2);
 
 		dst = reqctx->dst;
 	}
diff --git a/crypto/gcm.c b/crypto/gcm.c
index 2f5fbba..1a25263 100644
--- a/crypto/gcm.c
+++ b/crypto/gcm.c
@@ -1102,21 +1102,6 @@ static int crypto_rfc4543_setauthsize(struct crypto_aead *parent,
 	return crypto_aead_setauthsize(ctx->child, authsize);
 }
 
-/* this is the same as crypto_authenc_chain */
-static void crypto_rfc4543_chain(struct scatterlist *head,
-				 struct scatterlist *sg, int chain)
-{
-	if (chain) {
-		head->length += sg->length;
-		sg = scatterwalk_sg_next(sg);
-	}
-
-	if (sg)
-		scatterwalk_sg_chain(head, 2, sg);
-	else
-		sg_mark_end(head);
-}
-
 static struct aead_request *crypto_rfc4543_crypt(struct aead_request *req,
 						 int enc)
 {
@@ -1154,13 +1139,13 @@ static struct aead_request *crypto_rfc4543_crypt(struct aead_request *req,
 
 	sg_init_table(payload, 2);
 	sg_set_buf(payload, req->iv, 8);
-	crypto_rfc4543_chain(payload, dst, vdst == req->iv + 8);
+	scatterwalk_crypto_chain(payload, dst, vdst == req->iv + 8, 2);
 	assoclen += 8 + req->cryptlen - (enc ? 0 : authsize);
 
 	sg_init_table(assoc, 2);
 	sg_set_page(assoc, sg_page(req->assoc), req->assoc->length,
 		    req->assoc->offset);
-	crypto_rfc4543_chain(assoc, payload, 0);
+	scatterwalk_crypto_chain(assoc, payload, 0, 2);
 
 	aead_request_set_tfm(subreq, ctx->child);
 	aead_request_set_callback(subreq, req->base.flags, req->base.complete,
-- 
1.7.0.4
