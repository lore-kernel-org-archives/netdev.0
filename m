From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 06/11] esp4: Add support for IPsec extended sequence
 numbers
Date: Mon, 22 Nov 2010 11:30:14 +0100
Message-ID: <20101122103014.GI1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds IPsec extended sequence numbers support to esp4.
We use the authencesn crypto algorithm to handle esp with separate
encryption/authentication algorithms.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c |   98 ++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 80 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index f986aee..1a4ac47 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -31,11 +31,14 @@ struct esp_skb_cb {
  *
  * TODO: Use spare space in skb for this where possible.
  */
-static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags)
+static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags, int seqhilen)
 {
 	unsigned int len;
 
-	len = crypto_aead_ivsize(aead);
+	len = seqhilen;
+
+	len += crypto_aead_ivsize(aead);
+
 	if (len) {
 		len += crypto_aead_alignmask(aead) &
 		       ~(crypto_tfm_ctx_alignment() - 1);
@@ -50,10 +53,15 @@ static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags)
 	return kmalloc(len, GFP_ATOMIC);
 }
 
-static inline u8 *esp_tmp_iv(struct crypto_aead *aead, void *tmp)
+static inline __be32 *esp_tmp_seqhi(void *tmp)
+{
+	return PTR_ALIGN((__be32 *)tmp, __alignof__(__be32));
+}
+static inline u8 *esp_tmp_iv(struct crypto_aead *aead, void *tmp, int seqhilen)
 {
 	return crypto_aead_ivsize(aead) ?
-	       PTR_ALIGN((u8 *)tmp, crypto_aead_alignmask(aead) + 1) : tmp;
+	       PTR_ALIGN((u8 *)tmp + seqhilen,
+			 crypto_aead_alignmask(aead) + 1) : tmp + seqhilen;
 }
 
 static inline struct aead_givcrypt_request *esp_tmp_givreq(
@@ -118,6 +126,10 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int clen;
 	int alen;
 	int nfrags;
+	int assoclen;
+	int sglists;
+	int seqhilen;
+	__be32 *seqhi;
 
 	/* skb is pure payload to encrypt */
 
@@ -139,14 +151,25 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto error;
 	nfrags = err;
 
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	assoclen = sizeof(*esph);
+	sglists = 1;
+	seqhilen = 0;
+
+	if (x->props.flags & XFRM_STATE_ESN) {
+		sglists++;
+		seqhilen += sizeof(__be32);
+		assoclen += seqhilen;
+	}
+
+	tmp = esp_alloc_tmp(aead, nfrags + sglists, seqhilen);
 	if (!tmp)
 		goto error;
 
-	iv = esp_tmp_iv(aead, tmp);
+	seqhi = esp_tmp_seqhi(tmp);
+	iv = esp_tmp_iv(aead, tmp, seqhilen);
 	req = esp_tmp_givreq(aead, iv);
 	asg = esp_givreq_sg(aead, req);
-	sg = asg + 1;
+	sg = asg + sglists;
 
 	/* Fill padding... */
 	tail = skb_tail_pointer(trailer);
@@ -205,11 +228,18 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	skb_to_sgvec(skb, sg,
 		     esph->enc_data + crypto_aead_ivsize(aead) - skb->data,
 		     clen + alen);
-	sg_init_one(asg, esph, sizeof(*esph));
+
+	if ((x->props.flags & XFRM_STATE_ESN)) {
+		sg_init_table(asg, 2);
+		sg_set_buf(asg, esph, sizeof(*esph));
+		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+		sg_set_buf(asg + 1, seqhi, seqhilen);
+	} else
+		sg_init_one(asg, esph, sizeof(*esph));
 
 	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
-	aead_givcrypt_set_assoc(req, asg, sizeof(*esph));
+	aead_givcrypt_set_assoc(req, asg, assoclen);
 	aead_givcrypt_set_giv(req, esph->enc_data,
 			      XFRM_SKB_CB(skb)->seq.output.low);
 
@@ -330,6 +360,10 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	struct sk_buff *trailer;
 	int elen = skb->len - sizeof(*esph) - crypto_aead_ivsize(aead);
 	int nfrags;
+	int assoclen;
+	int sglists;
+	int seqhilen;
+	__be32 *seqhi;
 	void *tmp;
 	u8 *iv;
 	struct scatterlist *sg;
@@ -346,16 +380,27 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out;
 	nfrags = err;
 
+	assoclen = sizeof(*esph);
+	sglists = 1;
+	seqhilen = 0;
+
+	if (x->props.flags & XFRM_STATE_ESN) {
+		sglists++;
+		seqhilen += sizeof(__be32);
+		assoclen += seqhilen;
+	}
+
 	err = -ENOMEM;
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + sglists, seqhilen);
 	if (!tmp)
 		goto out;
 
 	ESP_SKB_CB(skb)->tmp = tmp;
-	iv = esp_tmp_iv(aead, tmp);
+	seqhi = esp_tmp_seqhi(tmp);
+	iv = esp_tmp_iv(aead, tmp, seqhilen);
 	req = esp_tmp_req(aead, iv);
 	asg = esp_req_sg(aead, req);
-	sg = asg + 1;
+	sg = asg + sglists;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -366,11 +411,18 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
-	sg_init_one(asg, esph, sizeof(*esph));
+
+	if ((x->props.flags & XFRM_STATE_ESN)) {
+		sg_init_table(asg, 2);
+		sg_set_buf(asg, esph, sizeof(*esph));
+		*seqhi = XFRM_SKB_CB(skb)->seq.input.hi;
+		sg_set_buf(asg + 1, seqhi, seqhilen);
+	} else
+		sg_init_one(asg, esph, sizeof(*esph));
 
 	aead_request_set_callback(req, 0, esp_input_done, skb);
 	aead_request_set_crypt(req, sg, sg, elen, iv);
-	aead_request_set_assoc(req, asg, sizeof(*esph));
+	aead_request_set_assoc(req, asg, assoclen);
 
 	err = crypto_aead_decrypt(req);
 	if (err == -EINPROGRESS)
@@ -484,10 +536,20 @@ static int esp_init_authenc(struct xfrm_state *x)
 		goto error;
 
 	err = -ENAMETOOLONG;
-	if (snprintf(authenc_name, CRYPTO_MAX_ALG_NAME, "authenc(%s,%s)",
-		     x->aalg ? x->aalg->alg_name : "digest_null",
-		     x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
-		goto error;
+
+	if ((x->props.flags & XFRM_STATE_ESN)) {
+		if (snprintf(authenc_name, CRYPTO_MAX_ALG_NAME,
+			     "authencesn(%s,%s)",
+			     x->aalg ? x->aalg->alg_name : "digest_null",
+			     x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
+			goto error;
+	} else {
+		if (snprintf(authenc_name, CRYPTO_MAX_ALG_NAME,
+			     "authenc(%s,%s)",
+			     x->aalg ? x->aalg->alg_name : "digest_null",
+			     x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
+			goto error;
+	}
 
 	aead = crypto_alloc_aead(authenc_name, 0, 0);
 	err = PTR_ERR(aead);
-- 
1.7.0.4
