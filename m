From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/6] crypto: rmd320 - Switch to shash
Date: Mon, 01 Dec 2008 21:47:20 +0800
Message-ID: <E1L797Q-0005kE-5Q@gondolin.me.apana.org.au>
References: <20081201134448.GA21939@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59365 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752238AbYLANrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 08:47:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

crypto: rmd320 - Switch to shash

This patch changes rmd320 to the new shash interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/rmd320.c |   61 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 29 deletions(-)

diff --git a/crypto/rmd320.c b/crypto/rmd320.c
index b143d66..86becab 100644
--- a/crypto/rmd320.c
+++ b/crypto/rmd320.c
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
 
@@ -280,9 +279,9 @@ static void rmd320_transform(u32 *state, const __le32 *in)
 	return;
 }
 
-static void rmd320_init(struct crypto_tfm *tfm)
+static int rmd320_init(struct shash_desc *desc)
 {
-	struct rmd320_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd320_ctx *rctx = shash_desc_ctx(desc);
 
 	rctx->byte_count = 0;
 
@@ -298,12 +297,14 @@ static void rmd320_init(struct crypto_tfm *tfm)
 	rctx->state[9] = RMD_H9;
 
 	memset(rctx->buffer, 0, sizeof(rctx->buffer));
+
+	return 0;
 }
 
-static void rmd320_update(struct crypto_tfm *tfm, const u8 *data,
-			  unsigned int len)
+static int rmd320_update(struct shash_desc *desc, const u8 *data,
+			 unsigned int len)
 {
-	struct rmd320_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd320_ctx *rctx = shash_desc_ctx(desc);
 	const u32 avail = sizeof(rctx->buffer) - (rctx->byte_count & 0x3f);
 
 	rctx->byte_count += len;
@@ -312,7 +313,7 @@ static void rmd320_update(struct crypto_tfm *tfm, const u8 *data,
 	if (avail > len) {
 		memcpy((char *)rctx->buffer + (sizeof(rctx->buffer) - avail),
 		       data, len);
-		return;
+		goto out;
 	}
 
 	memcpy((char *)rctx->buffer + (sizeof(rctx->buffer) - avail),
@@ -330,12 +331,15 @@ static void rmd320_update(struct crypto_tfm *tfm, const u8 *data,
 	}
 
 	memcpy(rctx->buffer, data, len);
+
+out:
+	return 0;
 }
 
 /* Add padding and return the message digest. */
-static void rmd320_final(struct crypto_tfm *tfm, u8 *out)
+static int rmd320_final(struct shash_desc *desc, u8 *out)
 {
-	struct rmd320_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd320_ctx *rctx = shash_desc_ctx(desc);
 	u32 i, index, padlen;
 	__le64 bits;
 	__le32 *dst = (__le32 *)out;
@@ -346,10 +350,10 @@ static void rmd320_final(struct crypto_tfm *tfm, u8 *out)
 	/* Pad out to 56 mod 64 */
 	index = rctx->byte_count & 0x3f;
 	padlen = (index < 56) ? (56 - index) : ((64+56) - index);
-	rmd320_update(tfm, padding, padlen);
+	rmd320_update(desc, padding, padlen);
 
 	/* Append length */
-	rmd320_update(tfm, (const u8 *)&bits, sizeof(bits));
+	rmd320_update(desc, (const u8 *)&bits, sizeof(bits));
 
 	/* Store state in digest */
 	for (i = 0; i < 10; i++)
@@ -357,31 +361,32 @@ static void rmd320_final(struct crypto_tfm *tfm, u8 *out)
 
 	/* Wipe context */
 	memset(rctx, 0, sizeof(*rctx));
+
+	return 0;
 }
 
-static struct crypto_alg alg = {
-	.cra_name	 =	"rmd320",
-	.cra_driver_name =	"rmd320",
-	.cra_flags	 =	CRYPTO_ALG_TYPE_DIGEST,
-	.cra_blocksize	 =	RMD320_BLOCK_SIZE,
-	.cra_ctxsize	 =	sizeof(struct rmd320_ctx),
-	.cra_module	 =	THIS_MODULE,
-	.cra_list	 =	LIST_HEAD_INIT(alg.cra_list),
-	.cra_u		 =	{ .digest = {
-	.dia_digestsize	 =	RMD320_DIGEST_SIZE,
-	.dia_init	 =	rmd320_init,
-	.dia_update	 =	rmd320_update,
-	.dia_final	 =	rmd320_final } }
+static struct shash_alg alg = {
+	.digestsize	=	RMD320_DIGEST_SIZE,
+	.init		=	rmd320_init,
+	.update		=	rmd320_update,
+	.final		=	rmd320_final,
+	.descsize	=	sizeof(struct rmd320_ctx),
+	.base		=	{
+		.cra_name	 =	"rmd320",
+		.cra_flags	 =	CRYPTO_ALG_TYPE_SHASH,
+		.cra_blocksize	 =	RMD320_BLOCK_SIZE,
+		.cra_module	 =	THIS_MODULE,
+	}
 };
 
 static int __init rmd320_mod_init(void)
 {
-	return crypto_register_alg(&alg);
+	return crypto_register_shash(&alg);
 }
 
 static void __exit rmd320_mod_fini(void)
 {
-	crypto_unregister_alg(&alg);
+	crypto_unregister_shash(&alg);
 }
 
 module_init(rmd320_mod_init);
@@ -389,5 +394,3 @@ module_exit(rmd320_mod_fini);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("RIPEMD-320 Message Digest");
-
-MODULE_ALIAS("rmd320");
