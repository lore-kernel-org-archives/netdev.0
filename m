From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 3/9] crypto: chcr - Return correct error code
Date: Thu, 15 Jun 2017 12:43:41 +0530
Message-ID: <feb9a5727e148df1c23c05b8cefbf1e8cdb979fe.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:28042 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751620AbdFOHOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:14:01 -0400
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return correct error instead of EINVAL.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 76 +++++++++++++++++++++-----------------
 1 file changed, 42 insertions(+), 34 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 14641c6..156065d 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -1399,7 +1399,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	unsigned short stop_offset = 0;
 	unsigned int  assoclen = req->assoclen;
 	unsigned int  authsize = crypto_aead_authsize(tfm);
-	int err = -EINVAL, src_nent;
+	int error = -EINVAL, src_nent;
 	int null = 0;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
 		GFP_ATOMIC;
@@ -1416,9 +1416,9 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	reqctx->dst = src;
 
 	if (req->src != req->dst) {
-		err = chcr_copy_assoc(req, aeadctx);
-		if (err)
-			return ERR_PTR(err);
+		error = chcr_copy_assoc(req, aeadctx);
+		if (error)
+			return ERR_PTR(error);
 		reqctx->dst = scatterwalk_ffwd(reqctx->dstffwd, req->dst,
 					       req->assoclen);
 	}
@@ -1430,6 +1430,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 					     (op_type ? -authsize : authsize));
 	if (reqctx->dst_nents < 0) {
 		pr_err("AUTHENC:Invalid Destination sg entries\n");
+		error = -EINVAL;
 		goto err;
 	}
 	dst_size = get_space_for_phys_dsgl(reqctx->dst_nents);
@@ -1443,8 +1444,10 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 		return ERR_PTR(chcr_aead_fallback(req, op_type));
 	}
 	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)), flags);
-	if (!skb)
+	if (!skb) {
+		error = -ENOMEM;
 		goto err;
+	}
 
 	/* LLD is going to write the sge hdr. */
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
@@ -1496,9 +1499,9 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	sg_param.nents = reqctx->dst_nents;
 	sg_param.obsize = req->cryptlen + (op_type ? -authsize : authsize);
 	sg_param.qid = qid;
-	sg_param.align = 0;
-	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, reqctx->dst,
-				  &sg_param))
+	error = map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl,
+					reqctx->dst, &sg_param);
+	if (error)
 		goto dstmap_fail;
 
 	skb_set_transport_header(skb, transhdr_len);
@@ -1520,7 +1523,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	/* ivmap_fail: */
 	kfree_skb(skb);
 err:
-	return ERR_PTR(-EINVAL);
+	return ERR_PTR(error);
 }
 
 static int set_msg_len(u8 *block, unsigned int msglen, int csize)
@@ -1730,7 +1733,7 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 	unsigned int dst_size = 0, kctx_len;
 	unsigned int sub_type;
 	unsigned int authsize = crypto_aead_authsize(tfm);
-	int err = -EINVAL, src_nent;
+	int error = -EINVAL, src_nent;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
 		GFP_ATOMIC;
 
@@ -1746,10 +1749,10 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 	reqctx->dst = src;
 
 	if (req->src != req->dst) {
-		err = chcr_copy_assoc(req, aeadctx);
-		if (err) {
+		error = chcr_copy_assoc(req, aeadctx);
+		if (error) {
 			pr_err("AAD copy to destination buffer fails\n");
-			return ERR_PTR(err);
+			return ERR_PTR(error);
 		}
 		reqctx->dst = scatterwalk_ffwd(reqctx->dstffwd, req->dst,
 					       req->assoclen);
@@ -1758,11 +1761,11 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 					     (op_type ? -authsize : authsize));
 	if (reqctx->dst_nents < 0) {
 		pr_err("CCM:Invalid Destination sg entries\n");
+		error = -EINVAL;
 		goto err;
 	}
-
-
-	if (aead_ccm_validate_input(op_type, req, aeadctx, sub_type))
+	error = aead_ccm_validate_input(op_type, req, aeadctx, sub_type);
+	if (error)
 		goto err;
 
 	dst_size = get_space_for_phys_dsgl(reqctx->dst_nents);
@@ -1777,8 +1780,10 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 
 	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)),  flags);
 
-	if (!skb)
+	if (!skb) {
+		error = -ENOMEM;
 		goto err;
+	}
 
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
 
@@ -1793,15 +1798,16 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 					16), aeadctx->key, aeadctx->enckey_len);
 
 	phys_cpl = (struct cpl_rx_phys_dsgl *)((u8 *)(chcr_req + 1) + kctx_len);
-	if (ccm_format_packet(req, aeadctx, sub_type, op_type))
+	error = ccm_format_packet(req, aeadctx, sub_type, op_type);
+	if (error)
 		goto dstmap_fail;
 
 	sg_param.nents = reqctx->dst_nents;
 	sg_param.obsize = req->cryptlen + (op_type ? -authsize : authsize);
 	sg_param.qid = qid;
-	sg_param.align = 0;
-	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, reqctx->dst,
-				  &sg_param))
+	error = map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl,
+				 reqctx->dst, &sg_param);
+	if (error)
 		goto dstmap_fail;
 
 	skb_set_transport_header(skb, transhdr_len);
@@ -1813,9 +1819,8 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 	return skb;
 dstmap_fail:
 	kfree_skb(skb);
-	skb = NULL;
 err:
-	return ERR_PTR(-EINVAL);
+	return ERR_PTR(error);
 }
 
 static struct sk_buff *create_gcm_wr(struct aead_request *req,
@@ -1839,7 +1844,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	unsigned char tag_offset = 0;
 	unsigned int crypt_len = 0;
 	unsigned int authsize = crypto_aead_authsize(tfm);
-	int err = -EINVAL, src_nent;
+	int error = -EINVAL, src_nent;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
 		GFP_ATOMIC;
 
@@ -1856,9 +1861,9 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
 	reqctx->dst = src;
 	if (req->src != req->dst) {
-		err = chcr_copy_assoc(req, aeadctx);
-		if (err)
-			return	ERR_PTR(err);
+		error = chcr_copy_assoc(req, aeadctx);
+		if (error)
+			return	ERR_PTR(error);
 		reqctx->dst = scatterwalk_ffwd(reqctx->dstffwd, req->dst,
 					       req->assoclen);
 	}
@@ -1874,6 +1879,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 					     (op_type ? -authsize : authsize));
 	if (reqctx->dst_nents < 0) {
 		pr_err("GCM:Invalid Destination sg entries\n");
+		error = -EINVAL;
 		goto err;
 	}
 
@@ -1889,8 +1895,10 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 		return ERR_PTR(chcr_aead_fallback(req, op_type));
 	}
 	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)), flags);
-	if (!skb)
+	if (!skb) {
+		error = -ENOMEM;
 		goto err;
+	}
 
 	/* NIC driver is going to write the sge hdr. */
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
@@ -1941,9 +1949,9 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	sg_param.nents = reqctx->dst_nents;
 	sg_param.obsize = req->cryptlen + (op_type ? -authsize : authsize);
 	sg_param.qid = qid;
-	sg_param.align = 0;
-	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, reqctx->dst,
-				  &sg_param))
+	error = map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl,
+					  reqctx->dst, &sg_param);
+	if (error)
 		goto dstmap_fail;
 
 	skb_set_transport_header(skb, transhdr_len);
@@ -1962,9 +1970,8 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 dstmap_fail:
 	/* ivmap_fail: */
 	kfree_skb(skb);
-	skb = NULL;
 err:
-	return skb;
+	return ERR_PTR(error);
 }
 
 
@@ -1976,7 +1983,8 @@ static int chcr_aead_cra_init(struct crypto_aead *tfm)
 	struct aead_alg *alg = crypto_aead_alg(tfm);
 
 	aeadctx->sw_cipher = crypto_alloc_aead(alg->base.cra_name, 0,
-					       CRYPTO_ALG_NEED_FALLBACK);
+					       CRYPTO_ALG_NEED_FALLBACK |
+					       CRYPTO_ALG_ASYNC);
 	if  (IS_ERR(aeadctx->sw_cipher))
 		return PTR_ERR(aeadctx->sw_cipher);
 	crypto_aead_set_reqsize(tfm, max(sizeof(struct chcr_aead_reqctx),
-- 
1.8.3.1
