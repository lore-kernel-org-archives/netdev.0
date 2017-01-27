From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 1/8] crypto:chcr-Change flow IDs
Date: Fri, 27 Jan 2017 16:09:05 +0530
Message-ID: <4d01998875eeca00637ec6316b397b631d4b5407.1485501429.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hariprasad@chelsio.com, netdev@vger.kernel.org, arjun@chelsio.com,
        atul.gupta@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change assign flowc id to each outgoing request.Firmware use flowc id
to schedule each request onto HW. FW reply may miss without this change.

Reviewed-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c            | 18 ++++++++++--------
 drivers/crypto/chelsio/chcr_algo.h            |  9 +++++----
 drivers/crypto/chelsio/chcr_core.h            |  1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  8 ++++++++
 4 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index d29c2b4..deec7c0 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -542,10 +542,11 @@ static inline void create_wreq(struct chcr_context *ctx,
 				    (calc_tx_flits_ofld(skb) * 8), 16)));
 	chcr_req->wreq.cookie = cpu_to_be64((uintptr_t)req);
 	chcr_req->wreq.rx_chid_to_rx_q_id =
-		FILL_WR_RX_Q_ID(ctx->dev->tx_channel_id, qid,
-				is_iv ? iv_loc : IV_NOP);
+		FILL_WR_RX_Q_ID(ctx->dev->rx_channel_id, qid,
+				is_iv ? iv_loc : IV_NOP, ctx->tx_channel_id);
 
-	chcr_req->ulptx.cmd_dest = FILL_ULPTX_CMD_DEST(ctx->dev->tx_channel_id);
+	chcr_req->ulptx.cmd_dest = FILL_ULPTX_CMD_DEST(ctx->dev->tx_channel_id,
+						       qid);
 	chcr_req->ulptx.len = htonl((DIV_ROUND_UP((calc_tx_flits_ofld(skb) * 8),
 					16) - ((sizeof(chcr_req->wreq)) >> 4)));
 
@@ -606,7 +607,7 @@ static inline void create_wreq(struct chcr_context *ctx,
 	chcr_req = (struct chcr_wr *)__skb_put(skb, transhdr_len);
 	memset(chcr_req, 0, transhdr_len);
 	chcr_req->sec_cpl.op_ivinsrtofst =
-		FILL_SEC_CPL_OP_IVINSR(ctx->dev->tx_channel_id, 2, 1);
+		FILL_SEC_CPL_OP_IVINSR(ctx->dev->rx_channel_id, 2, 1);
 
 	chcr_req->sec_cpl.pldlen = htonl(ivsize + req->nbytes);
 	chcr_req->sec_cpl.aadstart_cipherstop_hi =
@@ -782,6 +783,7 @@ static int chcr_device_init(struct chcr_context *ctx)
 		spin_lock(&ctx->dev->lock_chcr_dev);
 		ctx->tx_channel_id = rxq_idx;
 		ctx->dev->tx_channel_id = !ctx->dev->tx_channel_id;
+		ctx->dev->rx_channel_id = 0;
 		spin_unlock(&ctx->dev->lock_chcr_dev);
 	}
 out:
@@ -874,7 +876,7 @@ static struct sk_buff *create_hash_wr(struct ahash_request *req,
 	memset(chcr_req, 0, transhdr_len);
 
 	chcr_req->sec_cpl.op_ivinsrtofst =
-		FILL_SEC_CPL_OP_IVINSR(ctx->dev->tx_channel_id, 2, 0);
+		FILL_SEC_CPL_OP_IVINSR(ctx->dev->rx_channel_id, 2, 0);
 	chcr_req->sec_cpl.pldlen = htonl(param->bfr_len + param->sg_len);
 
 	chcr_req->sec_cpl.aadstart_cipherstop_hi =
@@ -1425,7 +1427,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	 * to the hardware spec
 	 */
 	chcr_req->sec_cpl.op_ivinsrtofst =
-		FILL_SEC_CPL_OP_IVINSR(ctx->dev->tx_channel_id, 2,
+		FILL_SEC_CPL_OP_IVINSR(ctx->dev->rx_channel_id, 2,
 				       (ivsize ? (assoclen + 1) : 0));
 	chcr_req->sec_cpl.pldlen = htonl(assoclen + ivsize + req->cryptlen);
 	chcr_req->sec_cpl.aadstart_cipherstop_hi = FILL_SEC_CPL_CIPHERSTOP_HI(
@@ -1601,7 +1603,7 @@ static void fill_sec_cpl_for_aead(struct cpl_tx_sec_pdu *sec_cpl,
 	unsigned int ivsize = AES_BLOCK_SIZE;
 	unsigned int cipher_mode = CHCR_SCMD_CIPHER_MODE_AES_CCM;
 	unsigned int mac_mode = CHCR_SCMD_AUTH_MODE_CBCMAC;
-	unsigned int c_id = chcrctx->dev->tx_channel_id;
+	unsigned int c_id = chcrctx->dev->rx_channel_id;
 	unsigned int ccm_xtra;
 	unsigned char tag_offset = 0, auth_offset = 0;
 	unsigned char hmac_ctrl = get_hmac(crypto_aead_authsize(tfm));
@@ -1877,7 +1879,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 
 	tag_offset = (op_type == CHCR_ENCRYPT_OP) ? 0 : authsize;
 	chcr_req->sec_cpl.op_ivinsrtofst = FILL_SEC_CPL_OP_IVINSR(
-					ctx->dev->tx_channel_id, 2, (ivsize ?
+					ctx->dev->rx_channel_id, 2, (ivsize ?
 					(req->assoclen + 1) : 0));
 	chcr_req->sec_cpl.pldlen = htonl(req->assoclen + ivsize + crypt_len);
 	chcr_req->sec_cpl.aadstart_cipherstop_hi = FILL_SEC_CPL_CIPHERSTOP_HI(
diff --git a/drivers/crypto/chelsio/chcr_algo.h b/drivers/crypto/chelsio/chcr_algo.h
index 3c7c51f..ba38bae 100644
--- a/drivers/crypto/chelsio/chcr_algo.h
+++ b/drivers/crypto/chelsio/chcr_algo.h
@@ -185,20 +185,21 @@
 			FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC_V(1) | \
 			FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE_V((ctx_len)))
 
-#define FILL_WR_RX_Q_ID(cid, qid, wr_iv) \
+#define FILL_WR_RX_Q_ID(cid, qid, wr_iv, fid) \
 		htonl( \
 			FW_CRYPTO_LOOKASIDE_WR_RX_CHID_V((cid)) | \
 			FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID_V((qid)) | \
 			FW_CRYPTO_LOOKASIDE_WR_LCB_V(0) | \
-			FW_CRYPTO_LOOKASIDE_WR_IV_V((wr_iv)))
+			FW_CRYPTO_LOOKASIDE_WR_IV_V((wr_iv)) | \
+			FW_CRYPTO_LOOKASIDE_WR_FQIDX_V(fid))
 
-#define FILL_ULPTX_CMD_DEST(cid) \
+#define FILL_ULPTX_CMD_DEST(cid, qid) \
 	htonl(ULPTX_CMD_V(ULP_TX_PKT) | \
 	      ULP_TXPKT_DEST_V(0) | \
 	      ULP_TXPKT_DATAMODIFY_V(0) | \
 	      ULP_TXPKT_CHANNELID_V((cid)) | \
 	      ULP_TXPKT_RO_V(1) | \
-	      ULP_TXPKT_FID_V(0))
+	      ULP_TXPKT_FID_V(qid))
 
 #define KEYCTX_ALIGN_PAD(bs) ({unsigned int _bs = (bs);\
 			      _bs == SHA1_DIGEST_SIZE ? 12 : 0; })
diff --git a/drivers/crypto/chelsio/chcr_core.h b/drivers/crypto/chelsio/chcr_core.h
index c7088a4..79da22b 100644
--- a/drivers/crypto/chelsio/chcr_core.h
+++ b/drivers/crypto/chelsio/chcr_core.h
@@ -75,6 +75,7 @@ struct chcr_dev {
 	spinlock_t lock_chcr_dev;
 	struct uld_ctx *u_ctx;
 	unsigned char tx_channel_id;
+	unsigned char rx_channel_id;
 };
 
 struct uld_ctx {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 8d9e4b7..ccc05f8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -3385,6 +3385,14 @@ struct fw_crypto_lookaside_wr {
 #define FW_CRYPTO_LOOKASIDE_WR_IV_G(x) \
 	(((x) >> FW_CRYPTO_LOOKASIDE_WR_IV_S) & FW_CRYPTO_LOOKASIDE_WR_IV_M)
 
+#define FW_CRYPTO_LOOKASIDE_WR_FQIDX_S   15
+#define FW_CRYPTO_LOOKASIDE_WR_FQIDX_M   0xff
+#define FW_CRYPTO_LOOKASIDE_WR_FQIDX_V(x) \
+	((x) << FW_CRYPTO_LOOKASIDE_WR_FQIDX_S)
+#define FW_CRYPTO_LOOKASIDE_WR_FQIDX_G(x) \
+	(((x) >> FW_CRYPTO_LOOKASIDE_WR_FQIDX_S) & \
+	 FW_CRYPTO_LOOKASIDE_WR_FQIDX_M)
+
 #define FW_CRYPTO_LOOKASIDE_WR_TX_CH_S 10
 #define FW_CRYPTO_LOOKASIDE_WR_TX_CH_M 0x3
 #define FW_CRYPTO_LOOKASIDE_WR_TX_CH_V(x) \
-- 
1.8.2.3
