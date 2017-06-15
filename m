From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 4/9] crypto: chcr - Avoid changing request structure
Date: Thu, 15 Jun 2017 12:43:42 +0530
Message-ID: <7de19938370a686d0e6159037bc321728bb6d03c.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:25794 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752097AbdFOHOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:14:04 -0400
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not update assoclen received in aead_request.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 37 ++++++++++++++-----------------------
 1 file changed, 14 insertions(+), 23 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 156065d..9c839c6 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -126,13 +126,13 @@ static void chcr_verify_tag(struct aead_request *req, u8 *input, int *err)
 	fw6_pld = (struct cpl_fw6_pld *)input;
 	if ((get_aead_subtype(tfm) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106) ||
 	    (get_aead_subtype(tfm) == CRYPTO_ALG_SUB_TYPE_AEAD_GCM)) {
-		cmp = memcmp(&fw6_pld->data[2], (fw6_pld + 1), authsize);
+		cmp = crypto_memneq(&fw6_pld->data[2], (fw6_pld + 1), authsize);
 	} else {
 
 		sg_pcopy_to_buffer(req->src, sg_nents(req->src), temp,
 				authsize, req->assoclen +
 				req->cryptlen - authsize);
-		cmp = memcmp(temp, (fw6_pld + 1), authsize);
+		cmp = crypto_memneq(temp, (fw6_pld + 1), authsize);
 	}
 	if (cmp)
 		*err = -EBADMSG;
@@ -1840,9 +1840,8 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	struct scatterlist *src;
 	unsigned int frags = 0, transhdr_len;
 	unsigned int ivsize = AES_BLOCK_SIZE;
-	unsigned int dst_size = 0, kctx_len;
+	unsigned int dst_size = 0, kctx_len, assoclen = req->assoclen;
 	unsigned char tag_offset = 0;
-	unsigned int crypt_len = 0;
 	unsigned int authsize = crypto_aead_authsize(tfm);
 	int error = -EINVAL, src_nent;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
@@ -1854,27 +1853,21 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 
 	if (op_type && req->cryptlen < crypto_aead_authsize(tfm))
 		goto err;
-	src_nent = sg_nents_for_len(req->src, req->assoclen + req->cryptlen);
+	src_nent = sg_nents_for_len(req->src, assoclen + req->cryptlen);
 	if (src_nent < 0)
 		goto err;
 
-	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
+	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, assoclen);
 	reqctx->dst = src;
 	if (req->src != req->dst) {
 		error = chcr_copy_assoc(req, aeadctx);
 		if (error)
 			return	ERR_PTR(error);
 		reqctx->dst = scatterwalk_ffwd(reqctx->dstffwd, req->dst,
-					       req->assoclen);
+					       assoclen);
 	}
 
-	if (!req->cryptlen)
-		/* null-payload is not supported in the hardware.
-		 * software is sending block size
-		 */
-		crypt_len = AES_BLOCK_SIZE;
-	else
-		crypt_len = req->cryptlen;
+
 	reqctx->dst_nents = sg_nents_for_len(reqctx->dst, req->cryptlen +
 					     (op_type ? -authsize : authsize));
 	if (reqctx->dst_nents < 0) {
@@ -1907,19 +1900,19 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	memset(chcr_req, 0, transhdr_len);
 
 	if (get_aead_subtype(tfm) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106)
-		req->assoclen -= 8;
+		assoclen = req->assoclen - 8;
 
 	tag_offset = (op_type == CHCR_ENCRYPT_OP) ? 0 : authsize;
 	chcr_req->sec_cpl.op_ivinsrtofst = FILL_SEC_CPL_OP_IVINSR(
 					ctx->dev->rx_channel_id, 2, (ivsize ?
-					(req->assoclen + 1) : 0));
+					(assoclen + 1) : 0));
 	chcr_req->sec_cpl.pldlen =
-		htonl(req->assoclen + ivsize + req->cryptlen);
+		htonl(assoclen + ivsize + req->cryptlen);
 	chcr_req->sec_cpl.aadstart_cipherstop_hi = FILL_SEC_CPL_CIPHERSTOP_HI(
-					req->assoclen ? 1 : 0, req->assoclen,
-					req->assoclen + ivsize + 1, 0);
+					assoclen ? 1 : 0, assoclen,
+					assoclen + ivsize + 1, 0);
 		chcr_req->sec_cpl.cipherstop_lo_authinsert =
-			FILL_SEC_CPL_AUTHINSERT(0, req->assoclen + ivsize + 1,
+			FILL_SEC_CPL_AUTHINSERT(0, assoclen + ivsize + 1,
 						tag_offset, tag_offset);
 		chcr_req->sec_cpl.seqno_numivs =
 			FILL_SEC_CPL_SCMD0_SEQNO(op_type, (op_type ==
@@ -1955,9 +1948,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 		goto dstmap_fail;
 
 	skb_set_transport_header(skb, transhdr_len);
-
-	write_sg_to_skb(skb, &frags, req->src, req->assoclen);
-
+	write_sg_to_skb(skb, &frags, req->src, assoclen);
 	write_buffer_to_skb(skb, &frags, reqctx->iv, ivsize);
 	write_sg_to_skb(skb, &frags, src, req->cryptlen);
 	create_wreq(ctx, chcr_req, req, skb, kctx_len, size, 1,
-- 
1.8.3.1
