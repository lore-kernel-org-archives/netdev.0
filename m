From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/6] crypto: rmd160 - Switch to shash
Date: Mon, 01 Dec 2008 21:47:17 +0800
Message-ID: <E1L797N-0005ju-Vc@gondolin.me.apana.org.au>
References: <20081201134448.GA21939@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

crypto: rmd160 - Switch to shash

This patch changes rmd160 to the new shash interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/rmd160.c |   61 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 29 deletions(-)

diff --git a/crypto/rmd160.c b/crypto/rmd160.c
index f001ec7..472261f 100644
--- a/crypto/rmd160.c
+++ b/crypto/rmd160.c
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
 
@@ -261,9 +260,9 @@ static void rmd160_transform(u32 *state, const __le32 *in)
 	return;
 }
 
-static void rmd160_init(struct crypto_tfm *tfm)
+static int rmd160_init(struct shash_desc *desc)
 {
-	struct rmd160_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd160_ctx *rctx = shash_desc_ctx(desc);
 
 	rctx->byte_count = 0;
 
@@ -274,12 +273,14 @@ static void rmd160_init(struct crypto_tfm *tfm)
 	rctx->state[4] = RMD_H4;
 
 	memset(rctx->buffer, 0, sizeof(rctx->buffer));
+
+	return 0;
 }
 
-static void rmd160_update(struct crypto_tfm *tfm, const u8 *data,
-			  unsigned int len)
+static int rmd160_update(struct shash_desc *desc, const u8 *data,
+			 unsigned int len)
 {
-	struct rmd160_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd160_ctx *rctx = shash_desc_ctx(desc);
 	const u32 avail = sizeof(rctx->buffer) - (rctx->byte_count & 0x3f);
 
 	rctx->byte_count += len;
@@ -288,7 +289,7 @@ static void rmd160_update(struct crypto_tfm *tfm, const u8 *data,
 	if (avail > len) {
 		memcpy((char *)rctx->buffer + (sizeof(rctx->buffer) - avail),
 		       data, len);
-		return;
+		goto out;
 	}
 
 	memcpy((char *)rctx->buffer + (sizeof(rctx->buffer) - avail),
@@ -306,12 +307,15 @@ static void rmd160_update(struct crypto_tfm *tfm, const u8 *data,
 	}
 
 	memcpy(rctx->buffer, data, len);
+
+out:
+	return 0;
 }
 
 /* Add padding and return the message digest. */
-static void rmd160_final(struct crypto_tfm *tfm, u8 *out)
+static int rmd160_final(struct shash_desc *desc, u8 *out)
 {
-	struct rmd160_ctx *rctx = crypto_tfm_ctx(tfm);
+	struct rmd160_ctx *rctx = shash_desc_ctx(desc);
 	u32 i, index, padlen;
 	__le64 bits;
 	__le32 *dst = (__le32 *)out;
@@ -322,10 +326,10 @@ static void rmd160_final(struct crypto_tfm *tfm, u8 *out)
 	/* Pad out to 56 mod 64 */
 	index = rctx->byte_count & 0x3f;
 	padlen = (index < 56) ? (56 - index) : ((64+56) - index);
-	rmd160_update(tfm, padding, padlen);
+	rmd160_update(desc, padding, padlen);
 
 	/* Append length */
-	rmd160_update(tfm, (const u8 *)&bits, sizeof(bits));
+	rmd160_update(desc, (const u8 *)&bits, sizeof(bits));
 
 	/* Store state in digest */
 	for (i = 0; i < 5; i++)
@@ -333,31 +337,32 @@ static void rmd160_final(struct crypto_tfm *tfm, u8 *out)
 
 	/* Wipe context */
 	memset(rctx, 0, sizeof(*rctx));
+
+	return 0;
 }
 
-static struct crypto_alg alg = {
-	.cra_name	 =	"rmd160",
-	.cra_driver_name =	"rmd160",
-	.cra_flags	 =	CRYPTO_ALG_TYPE_DIGEST,
-	.cra_blocksize	 =	RMD160_BLOCK_SIZE,
-	.cra_ctxsize	 =	sizeof(struct rmd160_ctx),
-	.cra_module	 =	THIS_MODULE,
-	.cra_list	 =	LIST_HEAD_INIT(alg.cra_list),
-	.cra_u		 =	{ .digest = {
-	.dia_digestsize	 =	RMD160_DIGEST_SIZE,
-	.dia_init	 =	rmd160_init,
-	.dia_update	 =	rmd160_update,
-	.dia_final	 =	rmd160_final } }
+static struct shash_alg alg = {
+	.digestsize	=	RMD160_DIGEST_SIZE,
+	.init		=	rmd160_init,
+	.update		=	rmd160_update,
+	.final		=	rmd160_final,
+	.descsize	=	sizeof(struct rmd160_ctx),
+	.base		=	{
+		.cra_name	 =	"rmd160",
+		.cra_flags	 =	CRYPTO_ALG_TYPE_SHASH,
+		.cra_blocksize	 =	RMD160_BLOCK_SIZE,
+		.cra_module	 =	THIS_MODULE,
+	}
 };
 
 static int __init rmd160_mod_init(void)
 {
-	return crypto_register_alg(&alg);
+	return crypto_register_shash(&alg);
 }
 
 static void __exit rmd160_mod_fini(void)
 {
-	crypto_unregister_alg(&alg);
+	crypto_unregister_shash(&alg);
 }
 
 module_init(rmd160_mod_init);
@@ -365,5 +370,3 @@ module_exit(rmd160_mod_fini);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("RIPEMD-160 Message Digest");
