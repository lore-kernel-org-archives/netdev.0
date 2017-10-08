From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v2 4/7] crypto:chelsio:Use x8_ble gf multiplication to calculate IV.
Date: Sun,  8 Oct 2017 13:37:21 +0530
Message-ID: <a91c26d676ee674131f8b9d90d39327680a783f9.1507449374.git.harsh@chelsio.com>
References: <cover.1507010612.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:22471 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdJHIHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 04:07:49 -0400
In-Reply-To: <cover.1507010612.git.harsh@chelsio.com>
In-Reply-To: <cover.1507449374.git.harsh@chelsio.com>
References: <cover.1507449374.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gf128mul_x8_ble() will reduce gf Multiplication iteration by 8.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c   | 11 +++++++++--
 drivers/crypto/chelsio/chcr_crypto.h |  1 +
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index e4bf32d..e0ab34a 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -888,9 +888,11 @@ static int chcr_update_tweak(struct ablkcipher_request *req, u8 *iv)
 	int ret, i;
 	u8 *key;
 	unsigned int keylen;
+	int round = reqctx->last_req_len / AES_BLOCK_SIZE;
+	int round8 = round / 8;
 
 	cipher = ablkctx->aes_generic;
-	memcpy(iv, req->info, AES_BLOCK_SIZE);
+	memcpy(iv, reqctx->iv, AES_BLOCK_SIZE);
 
 	keylen = ablkctx->enckey_len / 2;
 	key = ablkctx->key + keylen;
@@ -899,7 +901,10 @@ static int chcr_update_tweak(struct ablkcipher_request *req, u8 *iv)
 		goto out;
 
 	crypto_cipher_encrypt_one(cipher, iv, iv);
-	for (i = 0; i < (reqctx->processed / AES_BLOCK_SIZE); i++)
+	for (i = 0; i < round8; i++)
+		gf128mul_x8_ble((le128 *)iv, (le128 *)iv);
+
+	for (i = 0; i < (round % 8); i++)
 		gf128mul_x_ble((le128 *)iv, (le128 *)iv);
 
 	crypto_cipher_decrypt_one(cipher, iv, iv);
@@ -1040,6 +1045,7 @@ static int chcr_handle_cipher_resp(struct ablkcipher_request *req,
 	    CRYPTO_ALG_SUB_TYPE_CTR)
 		bytes = adjust_ctr_overflow(reqctx->iv, bytes);
 	reqctx->processed += bytes;
+	reqctx->last_req_len = bytes;
 	wrparam.qid = u_ctx->lldi.rxq_ids[ctx->rx_qidx];
 	wrparam.req = req;
 	wrparam.bytes = bytes;
@@ -1132,6 +1138,7 @@ static int process_cipher(struct ablkcipher_request *req,
 		goto error;
 	}
 	reqctx->processed = bytes;
+	reqctx->last_req_len = bytes;
 	reqctx->dst = reqctx->dstsg;
 	reqctx->op = op_type;
 	wrparam.qid = qid;
diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
index 30af1ee..b3722b3 100644
--- a/drivers/crypto/chelsio/chcr_crypto.h
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -247,6 +247,7 @@ struct chcr_blkcipher_req_ctx {
 	struct scatterlist *dst;
 	struct scatterlist *newdstsg;
 	unsigned int processed;
+	unsigned int last_req_len;
 	unsigned int op;
 	short int dst_nents;
 	u8 iv[CHCR_MAX_CRYPTO_IV_LEN];
-- 
2.1.4
