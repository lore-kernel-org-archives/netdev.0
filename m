From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/6] crypto: null - Switch to shash
Date: Mon, 01 Dec 2008 21:47:15 +0800
Message-ID: <E1L797L-0005ja-PA@gondolin.me.apana.org.au>
References: <20081201134448.GA21939@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59352 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751543AbYLANrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 08:47:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

crypto: null - Switch to shash

This patch changes digest_null to the new shash interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/crypto_null.c |   64 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 41 insertions(+), 23 deletions(-)

diff --git a/crypto/crypto_null.c b/crypto/crypto_null.c
index 1f7d530..cb71c91 100644
--- a/crypto/crypto_null.c
+++ b/crypto/crypto_null.c
@@ -17,6 +17,7 @@
  *
  */
 
+#include <crypto/internal/hash.h>
 #include <crypto/internal/skcipher.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -38,15 +39,31 @@ static int null_compress(struct crypto_tfm *tfm, const u8 *src,
 	return 0;
 }
 
-static void null_init(struct crypto_tfm *tfm)
-{ }
+static int null_init(struct shash_desc *desc)
+{
+	return 0;
+}
 
-static void null_update(struct crypto_tfm *tfm, const u8 *data,
-			unsigned int len)
-{ }
+static int null_update(struct shash_desc *desc, const u8 *data,
+		       unsigned int len)
+{
+	return 0;
+}
 
-static void null_final(struct crypto_tfm *tfm, u8 *out)
-{ }
+static int null_final(struct shash_desc *desc, u8 *out)
+{
+	return 0;
+}
+
+static int null_digest(struct shash_desc *desc, const u8 *data,
+		       unsigned int len, u8 *out)
+{
+	return 0;
+}
+
+static int null_hash_setkey(struct crypto_shash *tfm, const u8 *key,
+			    unsigned int keylen)
+{ return 0; }
 
 static int null_setkey(struct crypto_tfm *tfm, const u8 *key,
 		       unsigned int keylen)
@@ -89,19 +106,20 @@ static struct crypto_alg compress_null = {
 	.coa_decompress		=	null_compress } }
 };
 
-static struct crypto_alg digest_null = {
-	.cra_name		=	"digest_null",
-	.cra_flags		=	CRYPTO_ALG_TYPE_DIGEST,
-	.cra_blocksize		=	NULL_BLOCK_SIZE,
-	.cra_ctxsize		=	0,
-	.cra_module		=	THIS_MODULE,
-	.cra_list		=       LIST_HEAD_INIT(digest_null.cra_list),	
-	.cra_u			=	{ .digest = {
-	.dia_digestsize		=	NULL_DIGEST_SIZE,
-	.dia_setkey   		=	null_setkey,
-	.dia_init   		=	null_init,
-	.dia_update 		=	null_update,
-	.dia_final  		=	null_final } }
+static struct shash_alg digest_null = {
+	.digestsize		=	NULL_DIGEST_SIZE,
+	.setkey   		=	null_hash_setkey,
+	.init   		=	null_init,
+	.update 		=	null_update,
+	.finup 			=	null_digest,
+	.digest 		=	null_digest,
+	.final  		=	null_final,
+	.base			=	{
+		.cra_name		=	"digest_null",
+		.cra_flags		=	CRYPTO_ALG_TYPE_SHASH,
+		.cra_blocksize		=	NULL_BLOCK_SIZE,
+		.cra_module		=	THIS_MODULE,
+	}
 };
 
 static struct crypto_alg cipher_null = {
@@ -154,7 +172,7 @@ static int __init crypto_null_mod_init(void)
 	if (ret < 0)
 		goto out_unregister_cipher;
 
-	ret = crypto_register_alg(&digest_null);
+	ret = crypto_register_shash(&digest_null);
 	if (ret < 0)
 		goto out_unregister_skcipher;
 
@@ -166,7 +184,7 @@ out:
 	return ret;
 
 out_unregister_digest:
-	crypto_unregister_alg(&digest_null);
+	crypto_unregister_shash(&digest_null);
 out_unregister_skcipher:
 	crypto_unregister_alg(&skcipher_null);
 out_unregister_cipher:
@@ -177,7 +195,7 @@ out_unregister_cipher:
 static void __exit crypto_null_mod_fini(void)
 {
 	crypto_unregister_alg(&compress_null);
-	crypto_unregister_alg(&digest_null);
+	crypto_unregister_shash(&digest_null);
 	crypto_unregister_alg(&skcipher_null);
 	crypto_unregister_alg(&cipher_null);
 }
