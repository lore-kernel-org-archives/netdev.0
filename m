From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 4/4] chcr: Add fallback for AEAD algos
Date: Mon, 10 Apr 2017 18:24:01 +0530
Message-ID: <7ea1be6326f57dbd462f6e4ef8fe68aa17341ba6.1491807106.git.harsh@chelsio.com>
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

Fallback to sw when
    I AAD length greater than 511
    II Zero length payload
    II No of sg entries exceeds Request size.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c   |  219 ++++++++++++++++++++++------------
 drivers/crypto/chelsio/chcr_algo.h   |    4 +
 drivers/crypto/chelsio/chcr_crypto.h |    3 +-
 3 files changed, 151 insertions(+), 75 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 5470e4e..53d9ce4 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -1343,7 +1343,36 @@ static int chcr_copy_assoc(struct aead_request *req,
 
 	return crypto_skcipher_encrypt(skreq);
 }
+static int chcr_aead_need_fallback(struct aead_request *req, int src_nent,
+				   int aadmax, int wrlen,
+				   unsigned short op_type)
+{
+	unsigned int authsize = crypto_aead_authsize(crypto_aead_reqtfm(req));
+
+	if (((req->cryptlen - (op_type ? authsize : 0)) == 0) ||
+	    (req->assoclen > aadmax) ||
+	    (src_nent > MAX_SKB_FRAGS) ||
+	    (wrlen > MAX_WR_SIZE))
+		return 1;
+	return 0;
+}
 
+static int chcr_aead_fallback(struct aead_request *req, unsigned short op_type)
+{
+	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
+	struct chcr_context *ctx = crypto_aead_ctx(tfm);
+	struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
+	struct aead_request *subreq = aead_request_ctx(req);
+
+	aead_request_set_tfm(subreq, aeadctx->sw_cipher);
+	aead_request_set_callback(subreq, req->base.flags,
+				  req->base.complete, req->base.data);
+	 aead_request_set_crypt(subreq, req->src, req->dst, req->cryptlen,
+				 req->iv);
+	 aead_request_set_ad(subreq, req->assoclen);
+	return op_type ? crypto_aead_decrypt(subreq) :
+		crypto_aead_encrypt(subreq);
+}
 
 static struct sk_buff *create_authenc_wr(struct aead_request *req,
 					 unsigned short qid,
@@ -1367,7 +1396,7 @@ static int chcr_copy_assoc(struct aead_request *req,
 	unsigned short stop_offset = 0;
 	unsigned int  assoclen = req->assoclen;
 	unsigned int  authsize = crypto_aead_authsize(tfm);
-	int err = 0;
+	int err = -EINVAL, src_nent;
 	int null = 0;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
 		GFP_ATOMIC;
@@ -1377,8 +1406,8 @@ static int chcr_copy_assoc(struct aead_request *req,
 
 	if (op_type && req->cryptlen < crypto_aead_authsize(tfm))
 		goto err;
-
-	if (sg_nents_for_len(req->src, req->assoclen + req->cryptlen) < 0)
+	src_nent = sg_nents_for_len(req->src, req->assoclen + req->cryptlen);
+	if (src_nent < 0)
 		goto err;
 	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
 	reqctx->dst = src;
@@ -1396,7 +1425,7 @@ static int chcr_copy_assoc(struct aead_request *req,
 	}
 	reqctx->dst_nents = sg_nents_for_len(reqctx->dst, req->cryptlen +
 					     (op_type ? -authsize : authsize));
-	if (reqctx->dst_nents <= 0) {
+	if (reqctx->dst_nents < 0) {
 		pr_err("AUTHENC:Invalid Destination sg entries\n");
 		goto err;
 	}
@@ -1404,6 +1433,12 @@ static int chcr_copy_assoc(struct aead_request *req,
 	kctx_len = (ntohl(KEY_CONTEXT_CTX_LEN_V(aeadctx->key_ctx_hdr)) << 4)
 		- sizeof(chcr_req->key_ctx);
 	transhdr_len = CIPHER_TRANSHDR_SIZE(kctx_len, dst_size);
+	if (chcr_aead_need_fallback(req, src_nent + MIN_AUTH_SG,
+			T6_MAX_AAD_SIZE,
+			transhdr_len + (sgl_len(src_nent + MIN_AUTH_SG) * 8),
+				op_type)) {
+		return ERR_PTR(chcr_aead_fallback(req, op_type));
+	}
 	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)), flags);
 	if (!skb)
 		goto err;
@@ -1485,24 +1520,6 @@ static int chcr_copy_assoc(struct aead_request *req,
 	return ERR_PTR(-EINVAL);
 }
 
-static void aes_gcm_empty_pld_pad(struct scatterlist *sg,
-				  unsigned short offset)
-{
-	struct page *spage;
-	unsigned char *addr;
-
-	spage = sg_page(sg);
-	get_page(spage); /* so that it is not freed by NIC */
-#ifdef KMAP_ATOMIC_ARGS
-	addr = kmap_atomic(spage, KM_SOFTIRQ0);
-#else
-	addr = kmap_atomic(spage);
-#endif
-	memset(addr + sg->offset, 0, offset + 1);
-
-	kunmap_atomic(addr);
-}
-
 static int set_msg_len(u8 *block, unsigned int msglen, int csize)
 {
 	__be32 data;
@@ -1566,11 +1583,6 @@ static int ccm_format_packet(struct aead_request *req,
 	struct chcr_aead_reqctx *reqctx = aead_request_ctx(req);
 	int rc = 0;
 
-	if (req->assoclen > T5_MAX_AAD_SIZE) {
-		pr_err("CCM: Unsupported AAD data. It should be < %d\n",
-		       T5_MAX_AAD_SIZE);
-		return -EINVAL;
-	}
 	if (sub_type == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4309) {
 		reqctx->iv[0] = 3;
 		memcpy(reqctx->iv + 1, &aeadctx->salt[0], 3);
@@ -1715,16 +1727,17 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	unsigned int dst_size = 0, kctx_len;
 	unsigned int sub_type;
 	unsigned int authsize = crypto_aead_authsize(tfm);
-	int err = 0;
+	int err = -EINVAL, src_nent;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
 		GFP_ATOMIC;
 
 
 	if (op_type && req->cryptlen < crypto_aead_authsize(tfm))
 		goto err;
-
-	if (sg_nents_for_len(req->src, req->assoclen + req->cryptlen) < 0)
+	src_nent = sg_nents_for_len(req->src, req->assoclen + req->cryptlen);
+	if (src_nent < 0)
 		goto err;
+
 	sub_type = get_aead_subtype(tfm);
 	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
 	reqctx->dst = src;
@@ -1740,7 +1753,7 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	}
 	reqctx->dst_nents = sg_nents_for_len(reqctx->dst, req->cryptlen +
 					     (op_type ? -authsize : authsize));
-	if (reqctx->dst_nents <= 0) {
+	if (reqctx->dst_nents < 0) {
 		pr_err("CCM:Invalid Destination sg entries\n");
 		goto err;
 	}
@@ -1752,6 +1765,13 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	dst_size = get_space_for_phys_dsgl(reqctx->dst_nents);
 	kctx_len = ((DIV_ROUND_UP(aeadctx->enckey_len, 16)) << 4) * 2;
 	transhdr_len = CIPHER_TRANSHDR_SIZE(kctx_len, dst_size);
+	if (chcr_aead_need_fallback(req, src_nent + MIN_CCM_SG,
+			    T6_MAX_AAD_SIZE - 18,
+			    transhdr_len + (sgl_len(src_nent + MIN_CCM_SG) * 8),
+			    op_type)) {
+		return ERR_PTR(chcr_aead_fallback(req, op_type));
+	}
+
 	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)),  flags);
 
 	if (!skb)
@@ -1816,7 +1836,7 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	unsigned char tag_offset = 0;
 	unsigned int crypt_len = 0;
 	unsigned int authsize = crypto_aead_authsize(tfm);
-	int err = 0;
+	int err = -EINVAL, src_nent;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL :
 		GFP_ATOMIC;
 
@@ -1826,8 +1846,8 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 
 	if (op_type && req->cryptlen < crypto_aead_authsize(tfm))
 		goto err;
-
-	if (sg_nents_for_len(req->src, req->assoclen + req->cryptlen) < 0)
+	src_nent = sg_nents_for_len(req->src, req->assoclen + req->cryptlen);
+	if (src_nent < 0)
 		goto err;
 
 	src = scatterwalk_ffwd(reqctx->srcffwd, req->src, req->assoclen);
@@ -1849,7 +1869,7 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 		crypt_len = req->cryptlen;
 	reqctx->dst_nents = sg_nents_for_len(reqctx->dst, req->cryptlen +
 					     (op_type ? -authsize : authsize));
-	if (reqctx->dst_nents <= 0) {
+	if (reqctx->dst_nents < 0) {
 		pr_err("GCM:Invalid Destination sg entries\n");
 		goto err;
 	}
@@ -1859,6 +1879,12 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	kctx_len = ((DIV_ROUND_UP(aeadctx->enckey_len, 16)) << 4) +
 		AEAD_H_SIZE;
 	transhdr_len = CIPHER_TRANSHDR_SIZE(kctx_len, dst_size);
+	if (chcr_aead_need_fallback(req, src_nent + MIN_GCM_SG,
+			    T6_MAX_AAD_SIZE,
+			    transhdr_len + (sgl_len(src_nent + MIN_GCM_SG) * 8),
+			    op_type)) {
+		return ERR_PTR(chcr_aead_fallback(req, op_type));
+	}
 	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)), flags);
 	if (!skb)
 		goto err;
@@ -1876,11 +1902,11 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	chcr_req->sec_cpl.op_ivinsrtofst = FILL_SEC_CPL_OP_IVINSR(
 					ctx->dev->rx_channel_id, 2, (ivsize ?
 					(req->assoclen + 1) : 0));
-	chcr_req->sec_cpl.pldlen = htonl(req->assoclen + ivsize + crypt_len);
+	chcr_req->sec_cpl.pldlen =
+		htonl(req->assoclen + ivsize + req->cryptlen);
 	chcr_req->sec_cpl.aadstart_cipherstop_hi = FILL_SEC_CPL_CIPHERSTOP_HI(
 					req->assoclen ? 1 : 0, req->assoclen,
 					req->assoclen + ivsize + 1, 0);
-	if (req->cryptlen) {
 		chcr_req->sec_cpl.cipherstop_lo_authinsert =
 			FILL_SEC_CPL_AUTHINSERT(0, req->assoclen + ivsize + 1,
 						tag_offset, tag_offset);
@@ -1890,15 +1916,6 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 					CHCR_SCMD_CIPHER_MODE_AES_GCM,
 					CHCR_SCMD_AUTH_MODE_GHASH,
 					aeadctx->hmac_ctrl, ivsize >> 1);
-	} else {
-		chcr_req->sec_cpl.cipherstop_lo_authinsert =
-			FILL_SEC_CPL_AUTHINSERT(0, 0, 0, 0);
-		chcr_req->sec_cpl.seqno_numivs =
-			FILL_SEC_CPL_SCMD0_SEQNO(op_type,
-					(op_type ==  CHCR_ENCRYPT_OP) ?
-					1 : 0, CHCR_SCMD_CIPHER_MODE_AES_CBC,
-					0, 0, ivsize >> 1);
-	}
 	chcr_req->sec_cpl.ivgen_hdrlen =  FILL_SEC_CPL_IVGEN_HDRLEN(0, 0, 1,
 					0, 1, dst_size);
 	chcr_req->key_ctx.ctx_hdr = aeadctx->key_ctx_hdr;
@@ -1931,15 +1948,7 @@ unsigned int fill_aead_req_fields(struct sk_buff *skb,
 	write_sg_to_skb(skb, &frags, req->src, req->assoclen);
 
 	write_buffer_to_skb(skb, &frags, reqctx->iv, ivsize);
-
-	if (req->cryptlen) {
-		write_sg_to_skb(skb, &frags, src, req->cryptlen);
-	} else {
-		aes_gcm_empty_pld_pad(req->dst, authsize - 1);
-		write_sg_to_skb(skb, &frags, reqctx->dst, crypt_len);
-
-	}
-
+	write_sg_to_skb(skb, &frags, src, req->cryptlen);
 	create_wreq(ctx, chcr_req, req, skb, kctx_len, size, 1,
 			sizeof(struct cpl_rx_phys_dsgl) + dst_size);
 	reqctx->skb = skb;
@@ -1960,8 +1969,15 @@ static int chcr_aead_cra_init(struct crypto_aead *tfm)
 {
 	struct chcr_context *ctx = crypto_aead_ctx(tfm);
 	struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
-
-	crypto_aead_set_reqsize(tfm, sizeof(struct chcr_aead_reqctx));
+	struct aead_alg *alg = crypto_aead_alg(tfm);
+
+	aeadctx->sw_cipher = crypto_alloc_aead(alg->base.cra_name, 0,
+					       CRYPTO_ALG_NEED_FALLBACK);
+	if  (IS_ERR(aeadctx->sw_cipher))
+		return PTR_ERR(aeadctx->sw_cipher);
+	crypto_aead_set_reqsize(tfm, max(sizeof(struct chcr_aead_reqctx),
+				 sizeof(struct aead_request) +
+				 crypto_aead_reqsize(aeadctx->sw_cipher)));
 	aeadctx->null = crypto_get_default_null_skcipher();
 	if (IS_ERR(aeadctx->null))
 		return PTR_ERR(aeadctx->null);
@@ -1970,7 +1986,11 @@ static int chcr_aead_cra_init(struct crypto_aead *tfm)
 
 static void chcr_aead_cra_exit(struct crypto_aead *tfm)
 {
+	struct chcr_context *ctx = crypto_aead_ctx(tfm);
+	struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
+
 	crypto_put_default_null_skcipher();
+	crypto_free_aead(aeadctx->sw_cipher);
 }
 
 static int chcr_authenc_null_setauthsize(struct crypto_aead *tfm,
@@ -1980,7 +2000,7 @@ static int chcr_authenc_null_setauthsize(struct crypto_aead *tfm,
 
 	aeadctx->hmac_ctrl = CHCR_SCMD_HMAC_CTRL_NOP;
 	aeadctx->mayverify = VERIFY_HW;
-	return 0;
+	return crypto_aead_setauthsize(aeadctx->sw_cipher, authsize);
 }
 static int chcr_authenc_setauthsize(struct crypto_aead *tfm,
 				    unsigned int authsize)
@@ -2017,7 +2037,7 @@ static int chcr_authenc_setauthsize(struct crypto_aead *tfm,
 		aeadctx->hmac_ctrl = CHCR_SCMD_HMAC_CTRL_NO_TRUNC;
 		aeadctx->mayverify = VERIFY_SW;
 	}
-	return 0;
+	return crypto_aead_setauthsize(aeadctx->sw_cipher, authsize);
 }
 
 
@@ -2057,7 +2077,7 @@ static int chcr_gcm_setauthsize(struct crypto_aead *tfm, unsigned int authsize)
 			CRYPTO_TFM_RES_BAD_KEY_LEN);
 		return -EINVAL;
 	}
-	return 0;
+	return crypto_aead_setauthsize(aeadctx->sw_cipher, authsize);
 }
 
 static int chcr_4106_4309_setauthsize(struct crypto_aead *tfm,
@@ -2083,7 +2103,7 @@ static int chcr_4106_4309_setauthsize(struct crypto_aead *tfm,
 				     CRYPTO_TFM_RES_BAD_KEY_LEN);
 		return -EINVAL;
 	}
-	return 0;
+	return crypto_aead_setauthsize(aeadctx->sw_cipher, authsize);
 }
 
 static int chcr_ccm_setauthsize(struct crypto_aead *tfm,
@@ -2125,10 +2145,10 @@ static int chcr_ccm_setauthsize(struct crypto_aead *tfm,
 				     CRYPTO_TFM_RES_BAD_KEY_LEN);
 		return -EINVAL;
 	}
-	return 0;
+	return crypto_aead_setauthsize(aeadctx->sw_cipher, authsize);
 }
 
-static int chcr_aead_ccm_setkey(struct crypto_aead *aead,
+static int chcr_ccm_common_setkey(struct crypto_aead *aead,
 				const u8 *key,
 				unsigned int keylen)
 {
@@ -2137,8 +2157,6 @@ static int chcr_aead_ccm_setkey(struct crypto_aead *aead,
 	unsigned char ck_size, mk_size;
 	int key_ctx_size = 0;
 
-	memcpy(aeadctx->key, key, keylen);
-	aeadctx->enckey_len = keylen;
 	key_ctx_size = sizeof(struct _key_ctx) +
 		((DIV_ROUND_UP(keylen, 16)) << 4)  * 2;
 	if (keylen == AES_KEYSIZE_128) {
@@ -2158,9 +2176,32 @@ static int chcr_aead_ccm_setkey(struct crypto_aead *aead,
 	}
 	aeadctx->key_ctx_hdr = FILL_KEY_CTX_HDR(ck_size, mk_size, 0, 0,
 						key_ctx_size >> 4);
+	memcpy(aeadctx->key, key, keylen);
+	aeadctx->enckey_len = keylen;
+
 	return 0;
 }
 
+static int chcr_aead_ccm_setkey(struct crypto_aead *aead,
+				const u8 *key,
+				unsigned int keylen)
+{
+	struct chcr_context *ctx = crypto_aead_ctx(aead);
+	struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
+	int error;
+
+	crypto_aead_clear_flags(aeadctx->sw_cipher, CRYPTO_TFM_REQ_MASK);
+	crypto_aead_set_flags(aeadctx->sw_cipher, crypto_aead_get_flags(aead) &
+			      CRYPTO_TFM_REQ_MASK);
+	error = crypto_aead_setkey(aeadctx->sw_cipher, key, keylen);
+	crypto_aead_clear_flags(aead, CRYPTO_TFM_RES_MASK);
+	crypto_aead_set_flags(aead, crypto_aead_get_flags(aeadctx->sw_cipher) &
+			      CRYPTO_TFM_RES_MASK);
+	if (error)
+		return error;
+	return chcr_ccm_common_setkey(aead, key, keylen);
+}
+
 static int chcr_aead_rfc4309_setkey(struct crypto_aead *aead, const u8 *key,
 				    unsigned int keylen)
 {
@@ -2175,7 +2216,7 @@ static int chcr_aead_rfc4309_setkey(struct crypto_aead *aead, const u8 *key,
 	}
 	keylen -= 3;
 	memcpy(aeadctx->salt, key + keylen, 3);
-	return chcr_aead_ccm_setkey(aead, key, keylen);
+	return chcr_ccm_common_setkey(aead, key, keylen);
 }
 
 static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
@@ -2188,6 +2229,17 @@ static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 	unsigned int ck_size;
 	int ret = 0, key_ctx_size = 0;
 
+	aeadctx->enckey_len = 0;
+	crypto_aead_clear_flags(aeadctx->sw_cipher, CRYPTO_TFM_REQ_MASK);
+	crypto_aead_set_flags(aeadctx->sw_cipher, crypto_aead_get_flags(aead)
+			      & CRYPTO_TFM_REQ_MASK);
+	ret = crypto_aead_setkey(aeadctx->sw_cipher, key, keylen);
+	crypto_aead_clear_flags(aead, CRYPTO_TFM_RES_MASK);
+	crypto_aead_set_flags(aead, crypto_aead_get_flags(aeadctx->sw_cipher) &
+			      CRYPTO_TFM_RES_MASK);
+	if (ret)
+		goto out;
+
 	if (get_aead_subtype(aead) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106 &&
 	    keylen > 3) {
 		keylen -= 4;  /* nonce/salt is present in the last 4 bytes */
@@ -2202,8 +2254,7 @@ static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 	} else {
 		crypto_tfm_set_flags((struct crypto_tfm *)aead,
 				     CRYPTO_TFM_RES_BAD_KEY_LEN);
-		aeadctx->enckey_len = 0;
-		pr_err("GCM: Invalid key length %d", keylen);
+		pr_err("GCM: Invalid key length %d\n", keylen);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -2259,6 +2310,16 @@ static int chcr_authenc_setkey(struct crypto_aead *authenc, const u8 *key,
 	int align;
 	u8 *o_ptr = NULL;
 
+	crypto_aead_clear_flags(aeadctx->sw_cipher, CRYPTO_TFM_REQ_MASK);
+	crypto_aead_set_flags(aeadctx->sw_cipher, crypto_aead_get_flags(authenc)
+			      & CRYPTO_TFM_REQ_MASK);
+	err = crypto_aead_setkey(aeadctx->sw_cipher, key, keylen);
+	crypto_aead_clear_flags(authenc, CRYPTO_TFM_RES_MASK);
+	crypto_aead_set_flags(authenc, crypto_aead_get_flags(aeadctx->sw_cipher)
+			      & CRYPTO_TFM_RES_MASK);
+	if (err)
+		goto out;
+
 	if (crypto_authenc_extractkeys(&keys, key, keylen) != 0) {
 		crypto_aead_set_flags(authenc, CRYPTO_TFM_RES_BAD_KEY_LEN);
 		goto out;
@@ -2291,7 +2352,8 @@ static int chcr_authenc_setkey(struct crypto_aead *authenc, const u8 *key,
 	base_hash  = chcr_alloc_shash(max_authsize);
 	if (IS_ERR(base_hash)) {
 		pr_err("chcr : Base driver cannot be loaded\n");
-		goto out;
+		aeadctx->enckey_len = 0;
+		return -EINVAL;
 	}
 	{
 		SHASH_DESC_ON_STACK(shash, base_hash);
@@ -2358,11 +2420,21 @@ static int chcr_aead_digest_null_setkey(struct crypto_aead *authenc,
 	struct chcr_aead_ctx *aeadctx = AEAD_CTX(ctx);
 	struct chcr_authenc_ctx *actx = AUTHENC_CTX(aeadctx);
 	struct crypto_authenc_keys keys;
-
+	int err;
 	/* it contains auth and cipher key both*/
 	int key_ctx_len = 0;
 	unsigned char ck_size = 0;
 
+	crypto_aead_clear_flags(aeadctx->sw_cipher, CRYPTO_TFM_REQ_MASK);
+	crypto_aead_set_flags(aeadctx->sw_cipher, crypto_aead_get_flags(authenc)
+			      & CRYPTO_TFM_REQ_MASK);
+	err = crypto_aead_setkey(aeadctx->sw_cipher, key, keylen);
+	crypto_aead_clear_flags(authenc, CRYPTO_TFM_RES_MASK);
+	crypto_aead_set_flags(authenc, crypto_aead_get_flags(aeadctx->sw_cipher)
+			      & CRYPTO_TFM_RES_MASK);
+	if (err)
+		goto out;
+
 	if (crypto_authenc_extractkeys(&keys, key, keylen) != 0) {
 		crypto_aead_set_flags(authenc, CRYPTO_TFM_RES_BAD_KEY_LEN);
 		goto out;
@@ -2469,10 +2541,8 @@ static int chcr_aead_op(struct aead_request *req,
 	skb = create_wr_fn(req, u_ctx->lldi.rxq_ids[ctx->rx_qidx], size,
 			   op_type);
 
-	if (IS_ERR(skb) || skb == NULL) {
-		pr_err("chcr : %s : failed to form WR. No memory\n", __func__);
+	if (IS_ERR(skb) || !skb)
 		return PTR_ERR(skb);
-	}
 
 	skb->dev = u_ctx->lldi.ports[0];
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
@@ -2921,7 +2991,8 @@ static int chcr_register_alg(void)
 			break;
 		case CRYPTO_ALG_TYPE_AEAD:
 			driver_algs[i].alg.aead.base.cra_flags =
-				CRYPTO_ALG_TYPE_AEAD | CRYPTO_ALG_ASYNC;
+				CRYPTO_ALG_TYPE_AEAD | CRYPTO_ALG_ASYNC |
+				CRYPTO_ALG_NEED_FALLBACK;
 			driver_algs[i].alg.aead.encrypt = chcr_aead_encrypt;
 			driver_algs[i].alg.aead.decrypt = chcr_aead_decrypt;
 			driver_algs[i].alg.aead.init = chcr_aead_cra_init;
diff --git a/drivers/crypto/chelsio/chcr_algo.h b/drivers/crypto/chelsio/chcr_algo.h
index ba38bae..751d06a 100644
--- a/drivers/crypto/chelsio/chcr_algo.h
+++ b/drivers/crypto/chelsio/chcr_algo.h
@@ -218,6 +218,10 @@
 
 #define MAX_NK 8
 #define CRYPTO_MAX_IMM_TX_PKT_LEN 256
+#define MAX_WR_SIZE			512
+#define MIN_AUTH_SG			2 /*IV + AAD*/
+#define MIN_GCM_SG			2 /* IV + AAD*/
+#define MIN_CCM_SG			3 /*IV+AAD+B0*/
 
 struct algo_param {
 	unsigned int auth_mode;
diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
index c5673f0..5b2fabb 100644
--- a/drivers/crypto/chelsio/chcr_crypto.h
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -41,7 +41,7 @@
 
 #define CCM_B0_SIZE             16
 #define CCM_AAD_FIELD_SIZE      2
-#define T5_MAX_AAD_SIZE 512
+#define T6_MAX_AAD_SIZE 511
 
 
 /* Define following if h/w is not dropping the AAD and IV data before
@@ -188,6 +188,7 @@ struct chcr_aead_ctx {
 	__be32 key_ctx_hdr;
 	unsigned int enckey_len;
 	struct crypto_skcipher *null;
+	struct crypto_aead *sw_cipher;
 	u8 salt[MAX_SALT];
 	u8 key[CHCR_AES_MAX_KEY_LEN];
 	u16 hmac_ctrl;
-- 
1.7.1
