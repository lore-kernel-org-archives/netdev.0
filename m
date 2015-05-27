From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 5/8] esp6: Switch to new AEAD interface
Date: Wed, 27 May 2015 16:03:47 +0800
Message-ID: <E1YxWJX-0006zY-T2@gondolin.me.apana.org.au>
References: <20150527080105.GA26751@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes use of the new AEAD interface which uses a single
SG list instead of separate lists for the AD and plain text.  The
IV generation is also now carried out through normal AEAD methods.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/esp6.c |  200 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 122 insertions(+), 78 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 31f1b5d..060a60b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -76,7 +76,7 @@ static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags, int seqihlen)
 		len = ALIGN(len, crypto_tfm_ctx_alignment());
 	}
 
-	len += sizeof(struct aead_givcrypt_request) + crypto_aead_reqsize(aead);
+	len += sizeof(struct aead_request) + crypto_aead_reqsize(aead);
 	len = ALIGN(len, __alignof__(struct scatterlist));
 
 	len += sizeof(struct scatterlist) * nfrags;
@@ -96,17 +96,6 @@ static inline u8 *esp_tmp_iv(struct crypto_aead *aead, void *tmp, int seqhilen)
 			 crypto_aead_alignmask(aead) + 1) : tmp + seqhilen;
 }
 
-static inline struct aead_givcrypt_request *esp_tmp_givreq(
-	struct crypto_aead *aead, u8 *iv)
-{
-	struct aead_givcrypt_request *req;
-
-	req = (void *)PTR_ALIGN(iv + crypto_aead_ivsize(aead),
-				crypto_tfm_ctx_alignment());
-	aead_givcrypt_set_tfm(req, aead);
-	return req;
-}
-
 static inline struct aead_request *esp_tmp_req(struct crypto_aead *aead, u8 *iv)
 {
 	struct aead_request *req;
@@ -125,14 +114,6 @@ static inline struct scatterlist *esp_req_sg(struct crypto_aead *aead,
 			     __alignof__(struct scatterlist));
 }
 
-static inline struct scatterlist *esp_givreq_sg(
-	struct crypto_aead *aead, struct aead_givcrypt_request *req)
-{
-	return (void *)ALIGN((unsigned long)(req + 1) +
-			     crypto_aead_reqsize(aead),
-			     __alignof__(struct scatterlist));
-}
-
 static void esp_output_done(struct crypto_async_request *base, int err)
 {
 	struct sk_buff *skb = base->data;
@@ -141,32 +122,57 @@ static void esp_output_done(struct crypto_async_request *base, int err)
 	xfrm_output_resume(skb, err);
 }
 
+/* Move ESP header back into place. */
+static void esp_restore_header(struct sk_buff *skb, unsigned int offset)
+{
+	struct ip_esp_hdr *esph = (void *)(skb->data + offset);
+	void *tmp = ESP_SKB_CB(skb)->tmp;
+	__be32 *seqhi = esp_tmp_seqhi(tmp);
+
+	esph->seq_no = esph->spi;
+	esph->spi = *seqhi;
+}
+
+static void esp_output_restore_header(struct sk_buff *skb)
+{
+	esp_restore_header(skb, skb_transport_offset(skb) - sizeof(__be32));
+}
+
+static void esp_output_done_esn(struct crypto_async_request *base, int err)
+{
+	struct sk_buff *skb = base->data;
+
+	esp_output_restore_header(skb);
+	esp_output_done(base, err);
+}
+
 static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
 	struct ip_esp_hdr *esph;
 	struct crypto_aead *aead;
-	struct aead_givcrypt_request *req;
+	struct aead_request *req;
 	struct scatterlist *sg;
-	struct scatterlist *asg;
 	struct sk_buff *trailer;
 	void *tmp;
 	int blksize;
 	int clen;
 	int alen;
 	int plen;
+	int ivlen;
 	int tfclen;
 	int nfrags;
 	int assoclen;
-	int sglists;
 	int seqhilen;
 	u8 *iv;
 	u8 *tail;
 	__be32 *seqhi;
+	__be64 seqno;
 
 	/* skb is pure payload to encrypt */
 	aead = x->data;
 	alen = crypto_aead_authsize(aead);
+	ivlen = crypto_aead_ivsize(aead);
 
 	tfclen = 0;
 	if (x->tfcpad) {
@@ -187,16 +193,14 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	nfrags = err;
 
 	assoclen = sizeof(*esph);
-	sglists = 1;
 	seqhilen = 0;
 
 	if (x->props.flags & XFRM_STATE_ESN) {
-		sglists += 2;
 		seqhilen += sizeof(__be32);
 		assoclen += seqhilen;
 	}
 
-	tmp = esp_alloc_tmp(aead, nfrags + sglists, seqhilen);
+	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
 	if (!tmp) {
 		err = -ENOMEM;
 		goto error;
@@ -204,9 +208,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	seqhi = esp_tmp_seqhi(tmp);
 	iv = esp_tmp_iv(aead, tmp, seqhilen);
-	req = esp_tmp_givreq(aead, iv);
-	asg = esp_givreq_sg(aead, req);
-	sg = asg + sglists;
+	req = esp_tmp_req(aead, iv);
+	sg = esp_req_sg(aead, req);
 
 	/* Fill padding... */
 	tail = skb_tail_pointer(trailer);
@@ -227,36 +230,53 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph = ip_esp_hdr(skb);
 	*skb_mac_header(skb) = IPPROTO_ESP;
 
-	esph->spi = x->id.spi;
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
+	aead_request_set_callback(req, 0, esp_output_done, skb);
+
+	/* For ESN we move the header forward by 4 bytes to
+	 * accomodate the high bits.  We will move it back after
+	 * encryption.
+	 */
+	if ((x->props.flags & XFRM_STATE_ESN)) {
+		esph = (void *)(skb_transport_header(skb) - sizeof(__be32));
+		*seqhi = esph->spi;
+		esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+		aead_request_set_callback(req, 0, esp_output_done_esn, skb);
+	}
+
+	esph->spi = x->id.spi;
+
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg,
-		     esph->enc_data + crypto_aead_ivsize(aead) - skb->data,
-		     clen + alen);
+		     (unsigned char *)esph - skb->data,
+		     assoclen + ivlen + clen + alen);
 
-	if ((x->props.flags & XFRM_STATE_ESN)) {
-		sg_init_table(asg, 3);
-		sg_set_buf(asg, &esph->spi, sizeof(__be32));
-		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
-		sg_set_buf(asg + 1, seqhi, seqhilen);
-		sg_set_buf(asg + 2, &esph->seq_no, sizeof(__be32));
-	} else
-		sg_init_one(asg, esph, sizeof(*esph));
-
-	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
-	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
-	aead_givcrypt_set_assoc(req, asg, assoclen);
-	aead_givcrypt_set_giv(req, esph->enc_data,
-			      XFRM_SKB_CB(skb)->seq.output.low);
+	aead_request_set_crypt(req, sg, sg, ivlen + clen, iv);
+	aead_request_set_ad(req, assoclen);
+
+	seqno = cpu_to_be64(XFRM_SKB_CB(skb)->seq.output.low +
+			    ((u64)XFRM_SKB_CB(skb)->seq.output.hi << 32));
+
+	memset(iv, 0, ivlen);
+	memcpy(iv + ivlen - min(ivlen, 8), (u8 *)&seqno + 8 - min(ivlen, 8),
+	       min(ivlen, 8));
 
 	ESP_SKB_CB(skb)->tmp = tmp;
-	err = crypto_aead_givencrypt(req);
-	if (err == -EINPROGRESS)
+	err = crypto_aead_encrypt(req);
+
+	switch (err) {
+	case -EINPROGRESS:
 		goto error;
 
-	if (err == -EBUSY)
+	case -EBUSY:
 		err = NET_XMIT_DROP;
+		break;
+
+	case 0:
+		if ((x->props.flags & XFRM_STATE_ESN))
+			esp_output_restore_header(skb);
+	}
 
 	kfree(tmp);
 
@@ -317,25 +337,38 @@ static void esp_input_done(struct crypto_async_request *base, int err)
 	xfrm_input_resume(skb, esp_input_done2(skb, err));
 }
 
+static void esp_input_restore_header(struct sk_buff *skb)
+{
+	esp_restore_header(skb, 0);
+	__skb_pull(skb, 4);
+}
+
+static void esp_input_done_esn(struct crypto_async_request *base, int err)
+{
+	struct sk_buff *skb = base->data;
+
+	esp_input_restore_header(skb);
+	esp_input_done(base, err);
+}
+
 static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ip_esp_hdr *esph;
 	struct crypto_aead *aead = x->data;
 	struct aead_request *req;
 	struct sk_buff *trailer;
-	int elen = skb->len - sizeof(*esph) - crypto_aead_ivsize(aead);
+	int ivlen = crypto_aead_ivsize(aead);
+	int elen = skb->len - sizeof(*esph) - ivlen;
 	int nfrags;
 	int assoclen;
-	int sglists;
 	int seqhilen;
 	int ret = 0;
 	void *tmp;
 	__be32 *seqhi;
 	u8 *iv;
 	struct scatterlist *sg;
-	struct scatterlist *asg;
 
-	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead))) {
+	if (!pskb_may_pull(skb, sizeof(*esph) + ivlen)) {
 		ret = -EINVAL;
 		goto out;
 	}
@@ -354,16 +387,14 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	ret = -ENOMEM;
 
 	assoclen = sizeof(*esph);
-	sglists = 1;
 	seqhilen = 0;
 
 	if (x->props.flags & XFRM_STATE_ESN) {
-		sglists += 2;
 		seqhilen += sizeof(__be32);
 		assoclen += seqhilen;
 	}
 
-	tmp = esp_alloc_tmp(aead, nfrags + sglists, seqhilen);
+	tmp = esp_alloc_tmp(aead, nfrags, seqhilen);
 	if (!tmp)
 		goto out;
 
@@ -371,36 +402,39 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	seqhi = esp_tmp_seqhi(tmp);
 	iv = esp_tmp_iv(aead, tmp, seqhilen);
 	req = esp_tmp_req(aead, iv);
-	asg = esp_req_sg(aead, req);
-	sg = asg + sglists;
+	sg = esp_req_sg(aead, req);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
 	esph = (struct ip_esp_hdr *)skb->data;
 
-	/* Get ivec. This can be wrong, check against another impls. */
-	iv = esph->enc_data;
-
-	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
+	aead_request_set_callback(req, 0, esp_input_done, skb);
 
+	/* For ESN we move the header forward by 4 bytes to
+	 * accomodate the high bits.  We will move it back after
+	 * decryption.
+	 */
 	if ((x->props.flags & XFRM_STATE_ESN)) {
-		sg_init_table(asg, 3);
-		sg_set_buf(asg, &esph->spi, sizeof(__be32));
-		*seqhi = XFRM_SKB_CB(skb)->seq.input.hi;
-		sg_set_buf(asg + 1, seqhi, seqhilen);
-		sg_set_buf(asg + 2, &esph->seq_no, sizeof(__be32));
-	} else
-		sg_init_one(asg, esph, sizeof(*esph));
+		esph = (void *)skb_push(skb, 4);
+		*seqhi = esph->spi;
+		esph->spi = esph->seq_no;
+		esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.input.hi);
+		aead_request_set_callback(req, 0, esp_input_done_esn, skb);
+	}
 
-	aead_request_set_callback(req, 0, esp_input_done, skb);
-	aead_request_set_crypt(req, sg, sg, elen, iv);
-	aead_request_set_assoc(req, asg, assoclen);
+	sg_init_table(sg, nfrags);
+	skb_to_sgvec(skb, sg, 0, skb->len);
+
+	aead_request_set_crypt(req, sg, sg, elen + ivlen, iv);
+	aead_request_set_ad(req, assoclen);
 
 	ret = crypto_aead_decrypt(req);
 	if (ret == -EINPROGRESS)
 		goto out;
 
+	if ((x->props.flags & XFRM_STATE_ESN))
+		esp_input_restore_header(skb);
+
 	ret = esp_input_done2(skb, ret);
 
 out:
@@ -460,10 +494,16 @@ static void esp6_destroy(struct xfrm_state *x)
 
 static int esp_init_aead(struct xfrm_state *x)
 {
+	char aead_name[CRYPTO_MAX_ALG_NAME];
 	struct crypto_aead *aead;
 	int err;
 
-	aead = crypto_alloc_aead(x->aead->alg_name, 0, 0);
+	err = -ENAMETOOLONG;
+	if (snprintf(aead_name, CRYPTO_MAX_ALG_NAME, "%s(%s)",
+		     x->geniv, x->aead->alg_name) >= CRYPTO_MAX_ALG_NAME)
+		goto error;
+
+	aead = crypto_alloc_aead(aead_name, 0, 0);
 	err = PTR_ERR(aead);
 	if (IS_ERR(aead))
 		goto error;
@@ -502,15 +542,19 @@ static int esp_init_authenc(struct xfrm_state *x)
 
 	if ((x->props.flags & XFRM_STATE_ESN)) {
 		if (snprintf(authenc_name, CRYPTO_MAX_ALG_NAME,
-			     "authencesn(%s,%s)",
+			     "%s%sauthencesn(%s,%s)%s",
+			     x->geniv ?: "", x->geniv ? "(" : "",
 			     x->aalg ? x->aalg->alg_name : "digest_null",
-			     x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
+			     x->ealg->alg_name,
+			     x->geniv ? ")" : "") >= CRYPTO_MAX_ALG_NAME)
 			goto error;
 	} else {
 		if (snprintf(authenc_name, CRYPTO_MAX_ALG_NAME,
-			     "authenc(%s,%s)",
+			     "%s%sauthenc(%s,%s)%s",
+			     x->geniv ?: "", x->geniv ? "(" : "",
 			     x->aalg ? x->aalg->alg_name : "digest_null",
-			     x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
+			     x->ealg->alg_name,
+			     x->geniv ? ")" : "") >= CRYPTO_MAX_ALG_NAME)
 			goto error;
 	}
 
