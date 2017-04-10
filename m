From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 3/4] chcr:Fix txq ids.
Date: Mon, 10 Apr 2017 18:24:00 +0530
Message-ID: <e1723a019a25946be4ade90ef185ffaaa3ec6f74.1491807106.git.harsh@chelsio.com>
References: <cover.1491807106.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, atul.gupta@chelsio.com,
        ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:20849 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752939AbdDJMxo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:53:44 -0400
In-Reply-To: <cover.1491807106.git.harsh@chelsio.com>
In-Reply-To: <cover.1491807106.git.harsh@chelsio.com>
References: <cover.1491807106.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes a critical issue to map txqid with flows on the hardware appropriately,
if tx queues created are more than flows configured then  txqid shall map within
the range of hardware flows configured. This ensure that un-mapped txqid does not remain un-handled.
The patch also segregated the rxqid and txqid for clarity.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Reviewed-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c              |   47 +++++++++++++---------
 drivers/crypto/chelsio/chcr_core.h              |    2 +
 drivers/crypto/chelsio/chcr_crypto.h            |    3 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    9 ++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    3 +-
 6 files changed, 44 insertions(+), 21 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 2d61043..5470e4e 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -522,7 +522,7 @@ static inline void create_wreq(struct chcr_context *ctx,
 {
 	struct uld_ctx *u_ctx = ULD_CTX(ctx);
 	int iv_loc = IV_DSGL;
-	int qid = u_ctx->lldi.rxq_ids[ctx->tx_channel_id];
+	int qid = u_ctx->lldi.rxq_ids[ctx->rx_qidx];
 	unsigned int immdatalen = 0, nr_frags = 0;
 
 	if (is_ofld_imm(skb)) {
@@ -543,7 +543,7 @@ static inline void create_wreq(struct chcr_context *ctx,
 	chcr_req->wreq.cookie = cpu_to_be64((uintptr_t)req);
 	chcr_req->wreq.rx_chid_to_rx_q_id =
 		FILL_WR_RX_Q_ID(ctx->dev->rx_channel_id, qid,
-				is_iv ? iv_loc : IV_NOP, ctx->tx_channel_id);
+				is_iv ? iv_loc : IV_NOP, ctx->tx_qidx);
 
 	chcr_req->ulptx.cmd_dest = FILL_ULPTX_CMD_DEST(ctx->dev->tx_channel_id,
 						       qid);
@@ -721,19 +721,19 @@ static int chcr_aes_encrypt(struct ablkcipher_request *req)
 	struct sk_buff *skb;
 
 	if (unlikely(cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0],
-					    ctx->tx_channel_id))) {
+					    ctx->tx_qidx))) {
 		if (!(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
 			return -EBUSY;
 	}
 
-	skb = create_cipher_wr(req, u_ctx->lldi.rxq_ids[ctx->tx_channel_id],
+	skb = create_cipher_wr(req, u_ctx->lldi.rxq_ids[ctx->rx_qidx],
 			       CHCR_ENCRYPT_OP);
 	if (IS_ERR(skb)) {
 		pr_err("chcr : %s : Failed to form WR. No memory\n", __func__);
 		return  PTR_ERR(skb);
 	}
 	skb->dev = u_ctx->lldi.ports[0];
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
 	chcr_send_wr(skb);
 	return -EINPROGRESS;
 }
@@ -746,19 +746,19 @@ static int chcr_aes_decrypt(struct ablkcipher_request *req)
 	struct sk_buff *skb;
 
 	if (unlikely(cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0],
-					    ctx->tx_channel_id))) {
+					    ctx->tx_qidx))) {
 		if (!(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
 			return -EBUSY;
 	}
 
-	skb = create_cipher_wr(req, u_ctx->lldi.rxq_ids[0],
+	skb = create_cipher_wr(req, u_ctx->lldi.rxq_ids[ctx->rx_qidx],
 			       CHCR_DECRYPT_OP);
 	if (IS_ERR(skb)) {
 		pr_err("chcr : %s : Failed to form WR. No memory\n", __func__);
 		return PTR_ERR(skb);
 	}
 	skb->dev = u_ctx->lldi.ports[0];
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
 	chcr_send_wr(skb);
 	return -EINPROGRESS;
 }
@@ -766,7 +766,9 @@ static int chcr_aes_decrypt(struct ablkcipher_request *req)
 static int chcr_device_init(struct chcr_context *ctx)
 {
 	struct uld_ctx *u_ctx;
+	struct adapter *adap;
 	unsigned int id;
+	int txq_perchan, txq_idx, ntxq;
 	int err = 0, rxq_perchan, rxq_idx;
 
 	id = smp_processor_id();
@@ -777,11 +779,18 @@ static int chcr_device_init(struct chcr_context *ctx)
 			goto out;
 		}
 		u_ctx = ULD_CTX(ctx);
+		adap = padap(ctx->dev);
+		ntxq = min_not_zero((unsigned int)u_ctx->lldi.nrxq,
+				    adap->vres.ncrypto_fc);
 		rxq_perchan = u_ctx->lldi.nrxq / u_ctx->lldi.nchan;
+		txq_perchan = ntxq / u_ctx->lldi.nchan;
 		rxq_idx = ctx->dev->tx_channel_id * rxq_perchan;
 		rxq_idx += id % rxq_perchan;
+		txq_idx = ctx->dev->tx_channel_id * txq_perchan;
+		txq_idx += id % txq_perchan;
 		spin_lock(&ctx->dev->lock_chcr_dev);
-		ctx->tx_channel_id = rxq_idx;
+		ctx->rx_qidx = rxq_idx;
+		ctx->tx_qidx = txq_idx;
 		ctx->dev->tx_channel_id = !ctx->dev->tx_channel_id;
 		ctx->dev->rx_channel_id = 0;
 		spin_unlock(&ctx->dev->lock_chcr_dev);
@@ -935,7 +944,7 @@ static int chcr_ahash_update(struct ahash_request *req)
 
 	u_ctx = ULD_CTX(ctx);
 	if (unlikely(cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0],
-					    ctx->tx_channel_id))) {
+					    ctx->tx_qidx))) {
 		if (!(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
 			return -EBUSY;
 	}
@@ -975,7 +984,7 @@ static int chcr_ahash_update(struct ahash_request *req)
 	}
 	req_ctx->reqlen = remainder;
 	skb->dev = u_ctx->lldi.ports[0];
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
 	chcr_send_wr(skb);
 
 	return -EINPROGRESS;
@@ -1028,7 +1037,7 @@ static int chcr_ahash_final(struct ahash_request *req)
 		return -ENOMEM;
 
 	skb->dev = u_ctx->lldi.ports[0];
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
 	chcr_send_wr(skb);
 	return -EINPROGRESS;
 }
@@ -1047,7 +1056,7 @@ static int chcr_ahash_finup(struct ahash_request *req)
 	u_ctx = ULD_CTX(ctx);
 
 	if (unlikely(cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0],
-					    ctx->tx_channel_id))) {
+					    ctx->tx_qidx))) {
 		if (!(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
 			return -EBUSY;
 	}
@@ -1079,7 +1088,7 @@ static int chcr_ahash_finup(struct ahash_request *req)
 		return -ENOMEM;
 
 	skb->dev = u_ctx->lldi.ports[0];
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
 	chcr_send_wr(skb);
 
 	return -EINPROGRESS;
@@ -1100,7 +1109,7 @@ static int chcr_ahash_digest(struct ahash_request *req)
 
 	u_ctx = ULD_CTX(ctx);
 	if (unlikely(cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0],
-					    ctx->tx_channel_id))) {
+					    ctx->tx_qidx))) {
 		if (!(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
 			return -EBUSY;
 	}
@@ -1130,7 +1139,7 @@ static int chcr_ahash_digest(struct ahash_request *req)
 		return -ENOMEM;
 
 	skb->dev = u_ctx->lldi.ports[0];
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
 	chcr_send_wr(skb);
 	return -EINPROGRESS;
 }
@@ -2451,13 +2460,13 @@ static int chcr_aead_op(struct aead_request *req,
 	}
 	u_ctx = ULD_CTX(ctx);
 	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0],
-				   ctx->tx_channel_id)) {
+				   ctx->tx_qidx)) {
 		if (!(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
 			return -EBUSY;
 	}
 
 	/* Form a WR from req */
-	skb = create_wr_fn(req, u_ctx->lldi.rxq_ids[ctx->tx_channel_id], size,
+	skb = create_wr_fn(req, u_ctx->lldi.rxq_ids[ctx->rx_qidx], size,
 			   op_type);
 
 	if (IS_ERR(skb) || skb == NULL) {
@@ -2466,7 +2475,7 @@ static int chcr_aead_op(struct aead_request *req,
 	}
 
 	skb->dev = u_ctx->lldi.ports[0];
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
 	chcr_send_wr(skb);
 	return -EINPROGRESS;
 }
diff --git a/drivers/crypto/chelsio/chcr_core.h b/drivers/crypto/chelsio/chcr_core.h
index 79da22b..cd0c35a 100644
--- a/drivers/crypto/chelsio/chcr_core.h
+++ b/drivers/crypto/chelsio/chcr_core.h
@@ -54,6 +54,8 @@
 #define CHK_MAC_ERR_BIT(x)	(((x) >> MAC_ERROR_BIT) & 1)
 #define MAX_SALT                4
 
+#define padap(dev) pci_get_drvdata(dev->u_ctx->lldi.pdev)
+
 struct uld_ctx;
 
 struct _key_ctx {
diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
index 4469fea..c5673f0 100644
--- a/drivers/crypto/chelsio/chcr_crypto.h
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -211,7 +211,8 @@ struct __crypto_ctx {
 
 struct chcr_context {
 	struct chcr_dev *dev;
-	unsigned char tx_channel_id;
+	unsigned char tx_qidx;
+	unsigned char rx_qidx;
 	struct __crypto_ctx crypto_ctx[0];
 };
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index afb0967..6faaca1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3809,6 +3809,15 @@ static int adap_init0(struct adapter *adap)
 	}
 	if (caps_cmd.cryptocaps) {
 		/* Should query params here...TODO */
+		params[0] = FW_PARAM_PFVF(NCRYPTO_LOOKASIDE);
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 2,
+				      params, val);
+		if (ret < 0) {
+			if (ret != -EINVAL)
+				goto bye;
+		} else {
+			adap->vres.ncrypto_fc = val[0];
+		}
 		adap->params.crypto |= ULP_CRYPTO_LOOKASIDE;
 		adap->num_uld += 1;
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 4c85660..6e74040 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -272,6 +272,7 @@ struct cxgb4_virt_res {                      /* virtualized HW resources */
 	struct cxgb4_range qp;
 	struct cxgb4_range cq;
 	struct cxgb4_range ocq;
+	unsigned int ncrypto_fc;
 };
 
 #define OCQ_WIN_OFFSET(pdev, vres) \
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index ccc05f8..8f8c079 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1167,7 +1167,8 @@ enum fw_params_param_pfvf {
 	FW_PARAMS_PARAM_PFVF_ACTIVE_FILTER_START = 0x2D,
 	FW_PARAMS_PARAM_PFVF_ACTIVE_FILTER_END = 0x2E,
 	FW_PARAMS_PARAM_PFVF_ETHOFLD_END = 0x30,
-	FW_PARAMS_PARAM_PFVF_CPLFW4MSG_ENCAP = 0x31
+	FW_PARAMS_PARAM_PFVF_CPLFW4MSG_ENCAP = 0x31,
+	FW_PARAMS_PARAM_PFVF_NCRYPTO_LOOKASIDE = 0x32
 };
 
 /*
-- 
1.7.1
