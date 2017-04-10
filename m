From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 2/4] chcr:Set hmac_ctrl bit to use HW register HMAC_CFG[456]
Date: Mon, 10 Apr 2017 18:23:59 +0530
Message-ID: <b1838deb23b3f5e7a94515c14b67590523f8c010.1491807106.git.harsh@chelsio.com>
References: <cover.1491807106.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, atul.gupta@chelsio.com,
        ganeshgr@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1491807106.git.harsh@chelsio.com>
In-Reply-To: <cover.1491807106.git.harsh@chelsio.com>
References: <cover.1491807106.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use hmac_ctrl bit value saved in setauthsize callback.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c |   24 +++++-------------------
 1 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 7d59591..2d61043 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -1335,19 +1335,6 @@ static int chcr_copy_assoc(struct aead_request *req,
 	return crypto_skcipher_encrypt(skreq);
 }
 
-static unsigned char get_hmac(unsigned int authsize)
-{
-	switch (authsize) {
-	case ICV_8:
-		return CHCR_SCMD_HMAC_CTRL_PL1;
-	case ICV_10:
-		return CHCR_SCMD_HMAC_CTRL_TRUNC_RFC4366;
-	case ICV_12:
-		return CHCR_SCMD_HMAC_CTRL_IPSEC_96BIT;
-	}
-	return CHCR_SCMD_HMAC_CTRL_NO_TRUNC;
-}
-
 
 static struct sk_buff *create_authenc_wr(struct aead_request *req,
 					 unsigned short qid,
@@ -1600,13 +1587,13 @@ static void fill_sec_cpl_for_aead(struct cpl_tx_sec_pdu *sec_cpl,
 					  struct chcr_context *chcrctx)
 {
 	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct chcr_aead_ctx *aeadctx = AEAD_CTX(crypto_aead_ctx(tfm));
 	unsigned int ivsize = AES_BLOCK_SIZE;
 	unsigned int cipher_mode = CHCR_SCMD_CIPHER_MODE_AES_CCM;
 	unsigned int mac_mode = CHCR_SCMD_AUTH_MODE_CBCMAC;
 	unsigned int c_id = chcrctx->dev->rx_channel_id;
 	unsigned int ccm_xtra;
 	unsigned char tag_offset = 0, auth_offset = 0;
-	unsigned char hmac_ctrl = get_hmac(crypto_aead_authsize(tfm));
 	unsigned int assoclen;
 
 	if (get_aead_subtype(tfm) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4309)
@@ -1642,8 +1629,8 @@ static void fill_sec_cpl_for_aead(struct cpl_tx_sec_pdu *sec_cpl,
 					crypto_aead_authsize(tfm));
 	sec_cpl->seqno_numivs =  FILL_SEC_CPL_SCMD0_SEQNO(op_type,
 					(op_type == CHCR_ENCRYPT_OP) ? 0 : 1,
-					cipher_mode, mac_mode, hmac_ctrl,
-					ivsize >> 1);
+					cipher_mode, mac_mode,
+					aeadctx->hmac_ctrl, ivsize >> 1);
 
 	sec_cpl->ivgen_hdrlen = FILL_SEC_CPL_IVGEN_HDRLEN(0, 0, 1, 0,
 					1, dst_size);
@@ -1820,7 +1807,6 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	unsigned char tag_offset = 0;
 	unsigned int crypt_len = 0;
 	unsigned int authsize = crypto_aead_authsize(tfm);
-	unsigned char hmac_ctrl = get_hmac(authsize);
 	int err = 0;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
 		GFP_ATOMIC;
@@ -1893,8 +1879,8 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 			FILL_SEC_CPL_SCMD0_SEQNO(op_type, (op_type ==
 					CHCR_ENCRYPT_OP) ? 1 : 0,
 					CHCR_SCMD_CIPHER_MODE_AES_GCM,
-					CHCR_SCMD_AUTH_MODE_GHASH, hmac_ctrl,
-					ivsize >> 1);
+					CHCR_SCMD_AUTH_MODE_GHASH,
+					aeadctx->hmac_ctrl, ivsize >> 1);
 	} else {
 		chcr_req->sec_cpl.cipherstop_lo_authinsert =
 			FILL_SEC_CPL_AUTHINSERT(0, 0, 0, 0);
-- 
1.7.1
