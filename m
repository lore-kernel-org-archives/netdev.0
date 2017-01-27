From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 4/8] crypto:chcr- Use cipher instead of Block Cipher in gcm setkey
Date: Fri, 27 Jan 2017 16:09:08 +0530
Message-ID: <7e30d6dd45bb5605b077127acd2f5fb0487697e3.1485501429.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hariprasad@chelsio.com, netdev@vger.kernel.org, arjun@chelsio.com,
        atul.gupta@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:39800 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932520AbdA0KlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 05:41:19 -0500
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1 Block of encrption can be done with aes-generic. no need of
cbc(aes). This patch replaces cbc(aes-generic) with aes-generic.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 6c2dea3..d335943 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -2189,8 +2189,7 @@ static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 	struct chcr_context *ctx = crypto_aead_ctx(aead);
 	struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
 	struct chcr_gcm_ctx *gctx = GCM_CTX(aeadctx);
-	struct blkcipher_desc h_desc;
-	struct scatterlist src[1];
+	struct crypto_cipher *cipher;
 	unsigned int ck_size;
 	int ret = 0, key_ctx_size = 0;
 
@@ -2223,27 +2222,26 @@ static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 						CHCR_KEYCTX_MAC_KEY_SIZE_128,
 						0, 0,
 						key_ctx_size >> 4);
-	/* Calculate the H = CIPH(K, 0 repeated 16 times) using sync aes
-	 * blkcipher It will go on key context
+	/* Calculate the H = CIPH(K, 0 repeated 16 times).
+	 * It will go in key context
 	 */
-	h_desc.tfm = crypto_alloc_blkcipher("cbc(aes-generic)", 0, 0);
-	if (IS_ERR(h_desc.tfm)) {
+	cipher = crypto_alloc_cipher("aes-generic", 0, 0);
+	if (IS_ERR(cipher)) {
 		aeadctx->enckey_len = 0;
 		ret = -ENOMEM;
 		goto out;
 	}
-	h_desc.flags = 0;
-	ret = crypto_blkcipher_setkey(h_desc.tfm, key, keylen);
+
+	ret = crypto_cipher_setkey(cipher, key, keylen);
 	if (ret) {
 		aeadctx->enckey_len = 0;
 		goto out1;
 	}
 	memset(gctx->ghash_h, 0, AEAD_H_SIZE);
-	sg_init_one(&src[0], gctx->ghash_h, AEAD_H_SIZE);
-	ret = crypto_blkcipher_encrypt(&h_desc, &src[0], &src[0], AEAD_H_SIZE);
+	crypto_cipher_encrypt_one(cipher, gctx->ghash_h, gctx->ghash_h);
 
 out1:
-	crypto_free_blkcipher(h_desc.tfm);
+	crypto_free_cipher(cipher);
 out:
 	return ret;
 }
-- 
1.8.2.3
