From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 1/7] esp: Add an additional scatterlist entry for the
	assoc data
Date: Thu, 16 Jul 2009 13:16:29 +0200
Message-ID: <20090716111629.GQ20288@secunet.com>
References: <20090716111548.GP20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090716111548.GP20288@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be able to chain all the scatterlists we add an additional
scatterlist entry to the scatterlist of the associated data.
To keep compatibility we set the termination bit at the first
entry. This can be reverted as soon as we can use sg_chain().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c |   23 +++++++++++++++++------
 net/ipv6/esp6.c |   25 +++++++++++++++++++------
 2 files changed, 36 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 18bb383..dbb1a33 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -139,14 +139,14 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto error;
 	nfrags = err;
 
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto error;
 
 	iv = esp_tmp_iv(aead, tmp);
 	req = esp_tmp_givreq(aead, iv);
 	asg = esp_givreq_sg(aead, req);
-	sg = asg + 1;
+	sg = asg + 2;
 
 	/* Fill padding... */
 	tail = skb_tail_pointer(trailer);
@@ -205,7 +205,16 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	skb_to_sgvec(skb, sg,
 		     esph->enc_data + crypto_aead_ivsize(aead) - skb->data,
 		     clen + alen);
-	sg_init_one(asg, esph, sizeof(*esph));
+
+	/*
+	 * We add an additional scatterlist entry to be able to chain up
+	 * the scatterlists in the crypto layer. To keep compatibility we
+	 * set the termination bit at the first entry. This can be removed
+	 * as soon as as architectures support scatterlist chaining.
+	 */
+	sg_init_table(asg, 2);
+	sg_mark_end(asg);
+	sg_set_buf(asg, esph, sizeof(*esph));
 
 	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
@@ -347,7 +356,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	nfrags = err;
 
 	err = -ENOMEM;
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto out;
 
@@ -355,7 +364,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	iv = esp_tmp_iv(aead, tmp);
 	req = esp_tmp_req(aead, iv);
 	asg = esp_req_sg(aead, req);
-	sg = asg + 1;
+	sg = asg + 2;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -366,7 +375,9 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
-	sg_init_one(asg, esph, sizeof(*esph));
+	sg_init_table(asg, 2);
+	sg_mark_end(asg);
+	sg_set_buf(asg, esph, sizeof(*esph));
 
 	aead_request_set_callback(req, 0, esp_input_done, skb);
 	aead_request_set_crypt(req, sg, sg, elen, iv);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 678bb95..6ba707a 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -163,14 +163,14 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto error;
 	nfrags = err;
 
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto error;
 
 	iv = esp_tmp_iv(aead, tmp);
 	req = esp_tmp_givreq(aead, iv);
 	asg = esp_givreq_sg(aead, req);
-	sg = asg + 1;
+	sg = asg + 2;
 
 	/* Fill padding... */
 	tail = skb_tail_pointer(trailer);
@@ -194,7 +194,17 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	skb_to_sgvec(skb, sg,
 		     esph->enc_data + crypto_aead_ivsize(aead) - skb->data,
 		     clen + alen);
-	sg_init_one(asg, esph, sizeof(*esph));
+
+
+	/*
+	 * We add an additional scatterlist entry to be able to chain up
+	 * the scatterlists in the crypto layer. To keep compatibility we
+	 * set the termination bit at the first entry. This can be removed
+	 * as soon as as architectures support scatterlist chaining.
+	 */
+	sg_init_table(asg, 2);
+	sg_mark_end(asg);
+	sg_set_buf(asg, esph, sizeof(*esph));
 
 	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
@@ -298,7 +308,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 	ret = -ENOMEM;
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto out;
 
@@ -306,7 +316,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	iv = esp_tmp_iv(aead, tmp);
 	req = esp_tmp_req(aead, iv);
 	asg = esp_req_sg(aead, req);
-	sg = asg + 1;
+	sg = asg + 2;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -317,7 +327,10 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
-	sg_init_one(asg, esph, sizeof(*esph));
+
+	sg_init_table(asg, 2);
+	sg_mark_end(asg);
+	sg_set_buf(asg, esph, sizeof(*esph));
 
 	aead_request_set_callback(req, 0, esp_input_done, skb);
 	aead_request_set_crypt(req, sg, sg, elen, iv);
-- 
1.5.4.2

