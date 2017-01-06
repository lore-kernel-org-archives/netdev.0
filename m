From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 2/8] crypto:chcr- Fix panic on dma_unmap_sg
Date: Fri,  6 Jan 2017 14:01:33 +0530
Message-ID: <6691e22c89aff784f6c6a6e362cc8cfccb83d236.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>, Atul Gupta <atul.gupta@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:39184 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939660AbdAFIc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:32:27 -0500
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save DMA mapped sg list addresses to request context buffer.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c   | 49 +++++++++++++++++++-----------------
 drivers/crypto/chelsio/chcr_crypto.h |  3 +++
 2 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 1d7dfcf..deec7c0 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -158,7 +158,7 @@ int chcr_handle_resp(struct crypto_async_request *req, unsigned char *input,
 	case CRYPTO_ALG_TYPE_AEAD:
 		ctx_req.req.aead_req = (struct aead_request *)req;
 		ctx_req.ctx.reqctx = aead_request_ctx(ctx_req.req.aead_req);
-		dma_unmap_sg(&u_ctx->lldi.pdev->dev, ctx_req.req.aead_req->dst,
+		dma_unmap_sg(&u_ctx->lldi.pdev->dev, ctx_req.ctx.reqctx->dst,
 			     ctx_req.ctx.reqctx->dst_nents, DMA_FROM_DEVICE);
 		if (ctx_req.ctx.reqctx->skb) {
 			kfree_skb(ctx_req.ctx.reqctx->skb);
@@ -1364,8 +1364,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	struct chcr_wr *chcr_req;
 	struct cpl_rx_phys_dsgl *phys_cpl;
 	struct phys_sge_parm sg_param;
-	struct scatterlist *src, *dst;
-	struct scatterlist src_sg[2], dst_sg[2];
+	struct scatterlist *src;
 	unsigned int frags = 0, transhdr_len;
 	unsigned int ivsize = crypto_aead_ivsize(tfm), dst_size = 0;
 	unsigned int   kctx_len = 0;
@@ -1385,19 +1384,21 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 
 	if (sg_nents_for_len(req->src, req->assoclen + req->cryptlen) < 0)
 		goto err;
-	src = scatterwalk_ffwd(src_sg, req->src, req->assoclen);
-	dst = src;
+	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
+	reqctx->dst = src;
+
 	if (req->src != req->dst) {
 		err = chcr_copy_assoc(req, aeadctx);
 		if (err)
 			return ERR_PTR(err);
-		dst = scatterwalk_ffwd(dst_sg, req->dst, req->assoclen);
+		reqctx->dst = scatterwalk_ffwd(reqctx->dstffwd, req->dst,
+					       req->assoclen);
 	}
 	if (get_aead_subtype(tfm) == CRYPTO_ALG_SUB_TYPE_AEAD_NULL) {
 		null = 1;
 		assoclen = 0;
 	}
-	reqctx->dst_nents = sg_nents_for_len(dst, req->cryptlen +
+	reqctx->dst_nents = sg_nents_for_len(reqctx->dst, req->cryptlen +
 					     (op_type ? -authsize : authsize));
 	if (reqctx->dst_nents <= 0) {
 		pr_err("AUTHENC:Invalid Destination sg entries\n");
@@ -1462,7 +1463,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	sg_param.obsize = req->cryptlen + (op_type ? -authsize : authsize);
 	sg_param.qid = qid;
 	sg_param.align = 0;
-	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, dst,
+	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, reqctx->dst,
 				  &sg_param))
 		goto dstmap_fail;
 
@@ -1713,8 +1714,7 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 	struct chcr_wr *chcr_req;
 	struct cpl_rx_phys_dsgl *phys_cpl;
 	struct phys_sge_parm sg_param;
-	struct scatterlist *src, *dst;
-	struct scatterlist src_sg[2], dst_sg[2];
+	struct scatterlist *src;
 	unsigned int frags = 0, transhdr_len, ivsize = AES_BLOCK_SIZE;
 	unsigned int dst_size = 0, kctx_len;
 	unsigned int sub_type;
@@ -1730,17 +1730,19 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 	if (sg_nents_for_len(req->src, req->assoclen + req->cryptlen) < 0)
 		goto err;
 	sub_type = get_aead_subtype(tfm);
-	src = scatterwalk_ffwd(src_sg, req->src, req->assoclen);
-	dst = src;
+	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
+	reqctx->dst = src;
+
 	if (req->src != req->dst) {
 		err = chcr_copy_assoc(req, aeadctx);
 		if (err) {
 			pr_err("AAD copy to destination buffer fails\n");
 			return ERR_PTR(err);
 		}
-		dst = scatterwalk_ffwd(dst_sg, req->dst, req->assoclen);
+		reqctx->dst = scatterwalk_ffwd(reqctx->dstffwd, req->dst,
+					       req->assoclen);
 	}
-	reqctx->dst_nents = sg_nents_for_len(dst, req->cryptlen +
+	reqctx->dst_nents = sg_nents_for_len(reqctx->dst, req->cryptlen +
 					     (op_type ? -authsize : authsize));
 	if (reqctx->dst_nents <= 0) {
 		pr_err("CCM:Invalid Destination sg entries\n");
@@ -1779,7 +1781,7 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 	sg_param.obsize = req->cryptlen + (op_type ? -authsize : authsize);
 	sg_param.qid = qid;
 	sg_param.align = 0;
-	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, dst,
+	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, reqctx->dst,
 				  &sg_param))
 		goto dstmap_fail;
 
@@ -1811,8 +1813,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	struct chcr_wr *chcr_req;
 	struct cpl_rx_phys_dsgl *phys_cpl;
 	struct phys_sge_parm sg_param;
-	struct scatterlist *src, *dst;
-	struct scatterlist src_sg[2], dst_sg[2];
+	struct scatterlist *src;
 	unsigned int frags = 0, transhdr_len;
 	unsigned int ivsize = AES_BLOCK_SIZE;
 	unsigned int dst_size = 0, kctx_len;
@@ -1834,13 +1835,14 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	if (sg_nents_for_len(req->src, req->assoclen + req->cryptlen) < 0)
 		goto err;
 
-	src = scatterwalk_ffwd(src_sg, req->src, req->assoclen);
-	dst = src;
+	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
+	reqctx->dst = src;
 	if (req->src != req->dst) {
 		err = chcr_copy_assoc(req, aeadctx);
 		if (err)
 			return	ERR_PTR(err);
-		dst = scatterwalk_ffwd(dst_sg, req->dst, req->assoclen);
+		reqctx->dst = scatterwalk_ffwd(reqctx->dstffwd, req->dst,
+					       req->assoclen);
 	}
 
 	if (!req->cryptlen)
@@ -1850,7 +1852,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 		crypt_len = AES_BLOCK_SIZE;
 	else
 		crypt_len = req->cryptlen;
-	reqctx->dst_nents = sg_nents_for_len(dst, req->cryptlen +
+	reqctx->dst_nents = sg_nents_for_len(reqctx->dst, req->cryptlen +
 					     (op_type ? -authsize : authsize));
 	if (reqctx->dst_nents <= 0) {
 		pr_err("GCM:Invalid Destination sg entries\n");
@@ -1925,7 +1927,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	sg_param.obsize = req->cryptlen + (op_type ? -authsize : authsize);
 	sg_param.qid = qid;
 	sg_param.align = 0;
-	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, dst,
+	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, reqctx->dst,
 				  &sg_param))
 		goto dstmap_fail;
 
@@ -1939,7 +1941,8 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 		write_sg_to_skb(skb, &frags, src, req->cryptlen);
 	} else {
 		aes_gcm_empty_pld_pad(req->dst, authsize - 1);
-		write_sg_to_skb(skb, &frags, dst, crypt_len);
+		write_sg_to_skb(skb, &frags, reqctx->dst, crypt_len);
+
 	}
 
 	create_wreq(ctx, chcr_req, req, skb, kctx_len, size, 1,
diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
index d5af7d6..7ec0a8f 100644
--- a/drivers/crypto/chelsio/chcr_crypto.h
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -158,6 +158,9 @@ struct ablk_ctx {
 };
 struct chcr_aead_reqctx {
 	struct	sk_buff	*skb;
+	struct scatterlist *dst;
+	struct scatterlist srcffwd[2];
+	struct scatterlist dstffwd[2];
 	short int dst_nents;
 	u16 verify;
 	u8 iv[CHCR_MAX_CRYPTO_IV_LEN];
-- 
1.8.2.3
