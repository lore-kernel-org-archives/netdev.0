From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/6] crypto: rmd128 - Switch to shash
Date: Mon, 01 Dec 2008 21:47:16 +0800
Message-ID: <E1L797M-0005jk-SE@gondolin.me.apana.org.au>
References: <20081201134448.GA21939@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59354 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751555AbYLANrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 08:47:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

crypto: rmd128 - Switch to shash

This patch changes rmd128 to the new shash interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/rmd128.c |   61 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 29 deletions(-)

diff --git a/crypto/rmd128.c b/crypto/rmd128.c
index 5de6fa2..1ceb673 100644
--- a/crypto/rmd128.c
+++ b/crypto/rmd128.c
@@ -13,11 +13,10 @@
  * any later version.
  *
  */
+#include <crypto/internal/hash.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/mm.h>
-#include <linux/crypto.h>
-#include <linux/cryptohash.h>
 #include <linux/types.h>
 #include <asm/byteorder.h>
 
@@ -218,9 +217,9 @@ static void rmd128_transform(u32 *state, const __le32 *in)
 	return;
 }
 
-static void rmd128_init(struct crypto_tfm *tfm)
+static int rmd128_init(struct shash_desc *desc)
 {
-	struct rmd128_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd128_ctx *rctx = shash_desc_ctx(desc);
 
 	rctx->byte_count = 0;
 
@@ -230,12 +229,14 @@ static void rmd128_init(struct crypto_tfm *tfm)
 	rctx->state[3] = RMD_H3;
 
 	memset(rctx->buffer, 0, sizeof(rctx->buffer));
+
+	return 0;
 }
 
-static void rmd128_update(struct crypto_tfm *tfm, const u8 *data,
-			  unsigned int len)
+static int rmd128_update(struct shash_desc *desc, const u8 *data,
+			 unsigned int len)
 {
-	struct rmd128_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd128_ctx *rctx = shash_desc_ctx(desc);
 	const u32 avail = sizeof(rctx->buffer) - (rctx->byte_count & 0x3f);
 
 	rctx->byte_count += len;
@@ -244,7 +245,7 @@ static void rmd128_update(struct crypto_tfm *tfm, const u8 *data,
 	if (avail > len) {
 		memcpy((char *)rctx->buffer + (sizeof(rctx->buffer) - avail),
 		       data, len);
-		return;
+		goto out;
 	}
 
 	memcpy((char *)rctx->buffer + (sizeof(rctx->buffer) - avail),
@@ -262,12 +263,15 @@ static void rmd128_update(struct crypto_tfm *tfm, const u8 *data,
 	}
 
 	memcpy(rctx->buffer, data, len);
+
+out:
+	return 0;
 }
 
 /* Add padding and return the message digest. */
-static void rmd128_final(struct crypto_tfm *tfm, u8 *out)
+static int rmd128_final(struct shash_desc *desc, u8 *out)
 {
-	struct rmd128_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd128_ctx *rctx = shash_desc_ctx(desc);
 	u32 i, index, padlen;
 	__le64 bits;
 	__le32 *dst = (__le32 *)out;
@@ -278,10 +282,10 @@ static void rmd128_final(struct crypto_tfm *tfm, u8 *out)
 	/* Pad out to 56 mod 64 */
 	index = rctx->byte_count & 0x3f;
 	padlen = (index < 56) ? (56 - index) : ((64+56) - index);
-	rmd128_update(tfm, padding, padlen);
+	rmd128_update(desc, padding, padlen);
 
 	/* Append length */
-	rmd128_update(tfm, (const u8 *)&bits, sizeof(bits));
+	rmd128_update(desc, (const u8 *)&bits, sizeof(bits));
 
 	/* Store state in digest */
 	for (i = 0; i < 4; i++)
@@ -289,31 +293,32 @@ static void rmd128_final(struct crypto_tfm *tfm, u8 *out)
 
 	/* Wipe context */
 	memset(rctx, 0, sizeof(*rctx));
+
+	return 0;
 }
 
-static struct crypto_alg alg = {
-	.cra_name	 =	"rmd128",
-	.cra_driver_name =	"rmd128",
-	.cra_flags	 =	CRYPTO_ALG_TYPE_DIGEST,
-	.cra_blocksize	 =	RMD128_BLOCK_SIZE,
-	.cra_ctxsize	 =	sizeof(struct rmd128_ctx),
-	.cra_module	 =	THIS_MODULE,
-	.cra_list	 =	LIST_HEAD_INIT(alg.cra_list),
-	.cra_u		 =	{ .digest = {
-	.dia_digestsize	 =	RMD128_DIGEST_SIZE,
-	.dia_init	 =	rmd128_init,
-	.dia_update	 =	rmd128_update,
-	.dia_final	 =	rmd128_final } }
+static struct shash_alg alg = {
+	.digestsize	=	RMD128_DIGEST_SIZE,
+	.init		=	rmd128_init,
+	.update		=	rmd128_update,
+	.final		=	rmd128_final,
+	.descsize	=	sizeof(struct rmd128_ctx),
+	.base		=	{
+		.cra_name	 =	"rmd128",
+		.cra_flags	 =	CRYPTO_ALG_TYPE_SHASH,
+		.cra_blocksize	 =	RMD128_BLOCK_SIZE,
+		.cra_module	 =	THIS_MODULE,
+	}
 };
 
 static int __init rmd128_mod_init(void)
 {
-	return crypto_register_alg(&alg);
+	return crypto_register_shash(&alg);
 }
 
 static void __exit rmd128_mod_fini(void)
 {
-	crypto_unregister_alg(&alg);
+	crypto_unregister_shash(&alg);
 }
 
 module_init(rmd128_mod_init);
@@ -321,5 +326,3 @@ module_exit(rmd128_mod_fini);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("RIPEMD-128 Message Digest");
-
-MODULE_ALIAS("rmd128");
