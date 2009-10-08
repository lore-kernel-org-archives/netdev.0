From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/5] ah4: convert to ahash
Date: Thu, 8 Oct 2009 10:48:17 +0200
Message-ID: <20091008084817.GL15653@secunet.com>
References: <20091008084631.GJ15653@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:43212 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117AbZJHIs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 04:48:56 -0400
Content-Disposition: inline
In-Reply-To: <20091008084631.GJ15653@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts ah4 to the new ahash interface.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ah4.c |  295 ++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 236 insertions(+), 59 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 5c66270..d07b0c1 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -1,3 +1,4 @@
+#include <crypto/hash.h>
 #include <linux/err.h>
 #include <linux/module.h>
 #include <net/ip.h>
@@ -5,10 +6,67 @@
 #include <net/ah.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
-#include <linux/spinlock.h>
+#include <linux/scatterlist.h>
 #include <net/icmp.h>
 #include <net/protocol.h>
 
+struct ah_skb_cb {
+	struct xfrm_skb_cb xfrm;
+	void *tmp;
+};
+
+#define AH_SKB_CB(__skb) ((struct ah_skb_cb *)&((__skb)->cb[0]))
+
+static void *ah_alloc_tmp(struct crypto_ahash *ahash, int nfrags,
+			  unsigned int size)
+{
+	unsigned int len;
+
+	len = size + crypto_ahash_digestsize(ahash) +
+	      (crypto_ahash_alignmask(ahash) &
+	       ~(crypto_tfm_ctx_alignment() - 1));
+
+	len = ALIGN(len, crypto_tfm_ctx_alignment());
+
+	len += sizeof(struct ahash_request) + crypto_ahash_reqsize(ahash);
+	len = ALIGN(len, __alignof__(struct scatterlist));
+
+	len += sizeof(struct scatterlist) * nfrags;
+
+	return kmalloc(len, GFP_ATOMIC);
+}
+
+static inline u8 *ah_tmp_auth(void *tmp, unsigned int offset)
+{
+	return tmp + offset;
+}
+
+static inline u8 *ah_tmp_icv(struct crypto_ahash *ahash, void *tmp,
+			     unsigned int offset)
+{
+	return PTR_ALIGN((u8 *)tmp + offset, crypto_ahash_alignmask(ahash) + 1);
+}
+
+static inline struct ahash_request *ah_tmp_req(struct crypto_ahash *ahash,
+					       u8 *icv)
+{
+	struct ahash_request *req;
+
+	req = (void *)PTR_ALIGN(icv + crypto_ahash_digestsize(ahash),
+				crypto_tfm_ctx_alignment());
+
+	ahash_request_set_tfm(req, ahash);
+
+	return req;
+}
+
+static inline struct scatterlist *ah_req_sg(struct crypto_ahash *ahash,
+					     struct ahash_request *req)
+{
+	return (void *)ALIGN((unsigned long)(req + 1) +
+			     crypto_ahash_reqsize(ahash),
+			     __alignof__(struct scatterlist));
+}
 
 /* Clear mutable options and find final destination to substitute
  * into IP header for icv calculation. Options are already checked
@@ -54,20 +112,72 @@ static int ip_clear_mutable_options(struct iphdr *iph, __be32 *daddr)
 	return 0;
 }
 
+static void ah_output_done(struct crypto_async_request *base, int err)
+{
+	u8 *icv;
+	struct iphdr *iph;
+	struct sk_buff *skb = base->data;
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
+	struct ah_data *ahp = x->data;
+	struct iphdr *top_iph = ip_hdr(skb);
+	struct ip_auth_hdr *ah = ip_auth_hdr(skb);
+	int ihl = ip_hdrlen(skb);
+
+	iph = AH_SKB_CB(skb)->tmp;
+	icv = ah_tmp_icv(ahp->ahash, iph, ihl);
+	memcpy(ah->auth_data, icv, ahp->icv_trunc_len);
+
+	top_iph->tos = iph->tos;
+	top_iph->ttl = iph->ttl;
+	top_iph->frag_off = iph->frag_off;
+	if (top_iph->ihl != 5) {
+		top_iph->daddr = iph->daddr;
+		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
+	}
+
+	err = ah->nexthdr;
+
+	kfree(AH_SKB_CB(skb)->tmp);
+	xfrm_output_resume(skb, err);
+}
+
 static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
+	int nfrags;
+	int ihl;
+	u8 *icv;
+	struct sk_buff *trailer;
+	struct crypto_ahash *ahash;
+	struct ahash_request *req;
+	struct scatterlist *sg;
 	struct iphdr *iph, *top_iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
-	union {
-		struct iphdr	iph;
-		char 		buf[60];
-	} tmp_iph;
+
+	ahp = x->data;
+	ahash = ahp->ahash;
+
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+		goto out;
+	nfrags = err;
 
 	skb_push(skb, -skb_network_offset(skb));
+	ah = ip_auth_hdr(skb);
+	ihl = ip_hdrlen(skb);
+
+	err = -ENOMEM;
+	iph = ah_alloc_tmp(ahash, nfrags, ihl);
+	if (!iph)
+		goto out;
+
+	icv = ah_tmp_icv(ahash, iph, ihl);
+	req = ah_tmp_req(ahash, icv);
+	sg = ah_req_sg(ahash, req);
+
+	memset(ah->auth_data, 0, ahp->icv_trunc_len);
+
 	top_iph = ip_hdr(skb);
-	iph = &tmp_iph.iph;
 
 	iph->tos = top_iph->tos;
 	iph->ttl = top_iph->ttl;
@@ -78,10 +188,9 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 		memcpy(iph+1, top_iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
 		err = ip_clear_mutable_options(top_iph, &top_iph->daddr);
 		if (err)
-			goto error;
+			goto out_free;
 	}
 
-	ah = ip_auth_hdr(skb);
 	ah->nexthdr = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_AH;
 
@@ -91,20 +200,31 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->ttl = 0;
 	top_iph->check = 0;
 
-	ahp = x->data;
 	ah->hdrlen  = (XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
 
-	spin_lock_bh(&x->lock);
-	err = ah_mac_digest(ahp, skb, ah->auth_data);
-	memcpy(ah->auth_data, ahp->work_icv, ahp->icv_trunc_len);
-	spin_unlock_bh(&x->lock);
+	sg_init_table(sg, nfrags);
+	skb_to_sgvec(skb, sg, 0, skb->len);
 
-	if (err)
-		goto error;
+	ahash_request_set_crypt(req, sg, icv, skb->len);
+	ahash_request_set_callback(req, 0, ah_output_done, skb);
+
+	AH_SKB_CB(skb)->tmp = iph;
+
+	err = crypto_ahash_digest(req);
+	if (err) {
+		if (err == -EINPROGRESS)
+			goto out;
+
+		if (err == -EBUSY)
+			err = NET_XMIT_DROP;
+		goto out_free;
+	}
+
+	memcpy(ah->auth_data, icv, ahp->icv_trunc_len);
 
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
@@ -114,28 +234,67 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
 	}
 
-	err = 0;
-
-error:
+out_free:
+	kfree(iph);
+out:
 	return err;
 }
 
+static void ah_input_done(struct crypto_async_request *base, int err)
+{
+	u8 *auth_data;
+	u8 *icv;
+	struct iphdr *work_iph;
+	struct sk_buff *skb = base->data;
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct ah_data *ahp = x->data;
+	struct ip_auth_hdr *ah = ip_auth_hdr(skb);
+	int ihl = ip_hdrlen(skb);
+	int ah_hlen = (ah->hdrlen + 2) << 2;
+
+	work_iph = AH_SKB_CB(skb)->tmp;
+	auth_data = ah_tmp_auth(work_iph, ihl);
+	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
+
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	if (err)
+		goto out;
+
+	skb->network_header += ah_hlen;
+	memcpy(skb_network_header(skb), work_iph, ihl);
+	__skb_pull(skb, ah_hlen + ihl);
+	skb_set_transport_header(skb, -ihl);
+
+	err = ah->nexthdr;
+out:
+	kfree(AH_SKB_CB(skb)->tmp);
+	xfrm_input_resume(skb, err);
+}
+
 static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int ah_hlen;
 	int ihl;
 	int nexthdr;
-	int err = -EINVAL;
-	struct iphdr *iph;
+	int nfrags;
+	u8 *auth_data;
+	u8 *icv;
+	struct sk_buff *trailer;
+	struct crypto_ahash *ahash;
+	struct ahash_request *req;
+	struct scatterlist *sg;
+	struct iphdr *iph, *work_iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
-	char work_buf[60];
+	int err = -ENOMEM;
 
 	if (!pskb_may_pull(skb, sizeof(*ah)))
 		goto out;
 
 	ah = (struct ip_auth_hdr *)skb->data;
 	ahp = x->data;
+	ahash = ahp->ahash;
+
 	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 
@@ -156,9 +315,24 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah = (struct ip_auth_hdr *)skb->data;
 	iph = ip_hdr(skb);
+	ihl = ip_hdrlen(skb);
+
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+		goto out;
+	nfrags = err;
+
+	work_iph = ah_alloc_tmp(ahash, nfrags, ihl + ahp->icv_trunc_len);
+	if (!work_iph)
+		goto out;
+
+	auth_data = ah_tmp_auth(work_iph, ihl);
+	icv = ah_tmp_icv(ahash, auth_data, ahp->icv_trunc_len);
+	req = ah_tmp_req(ahash, icv);
+	sg = ah_req_sg(ahash, req);
 
-	ihl = skb->data - skb_network_header(skb);
-	memcpy(work_buf, iph, ihl);
+	memcpy(work_iph, iph, ihl);
+	memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
+	memset(ah->auth_data, 0, ahp->icv_trunc_len);
 
 	iph->ttl = 0;
 	iph->tos = 0;
@@ -166,35 +340,44 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 	iph->check = 0;
 	if (ihl > sizeof(*iph)) {
 		__be32 dummy;
-		if (ip_clear_mutable_options(iph, &dummy))
-			goto out;
+		err = ip_clear_mutable_options(iph, &dummy);
+		if (err)
+			goto out_free;
 	}
 
-	spin_lock(&x->lock);
-	{
-		u8 auth_data[MAX_AH_AUTH_LEN];
+	skb_push(skb, ihl);
 
-		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
-		skb_push(skb, ihl);
-		err = ah_mac_digest(ahp, skb, ah->auth_data);
-		if (err)
-			goto unlock;
-		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len))
-			err = -EBADMSG;
+	sg_init_table(sg, nfrags);
+	skb_to_sgvec(skb, sg, 0, skb->len);
+
+	ahash_request_set_crypt(req, sg, icv, skb->len);
+	ahash_request_set_callback(req, 0, ah_input_done, skb);
+
+	AH_SKB_CB(skb)->tmp = work_iph;
+
+	err = crypto_ahash_digest(req);
+	if (err) {
+		if (err == -EINPROGRESS)
+			goto out;
+
+		if (err == -EBUSY)
+			err = NET_XMIT_DROP;
+		goto out_free;
 	}
-unlock:
-	spin_unlock(&x->lock);
 
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
 	if (err)
-		goto out;
+		goto out_free;
 
 	skb->network_header += ah_hlen;
-	memcpy(skb_network_header(skb), work_buf, ihl);
-	skb->transport_header = skb->network_header;
+	memcpy(skb_network_header(skb), work_iph, ihl);
 	__skb_pull(skb, ah_hlen + ihl);
+	skb_set_transport_header(skb, -ihl);
 
-	return nexthdr;
+	err = nexthdr;
 
+out_free:
+	kfree (work_iph);
 out:
 	return err;
 }
@@ -222,7 +405,7 @@ static int ah_init_state(struct xfrm_state *x)
 {
 	struct ah_data *ahp = NULL;
 	struct xfrm_algo_desc *aalg_desc;
-	struct crypto_hash *tfm;
+	struct crypto_ahash *ahash;
 
 	if (!x->aalg)
 		goto error;
@@ -231,31 +414,31 @@ static int ah_init_state(struct xfrm_state *x)
 		goto error;
 
 	ahp = kzalloc(sizeof(*ahp), GFP_KERNEL);
-	if (ahp == NULL)
+	if (!ahp)
 		return -ENOMEM;
 
-	tfm = crypto_alloc_hash(x->aalg->alg_name, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(tfm))
+	ahash = crypto_alloc_ahash(x->aalg->alg_name, 0, 0);
+	if (IS_ERR(ahash))
 		goto error;
 
-	ahp->tfm = tfm;
-	if (crypto_hash_setkey(tfm, x->aalg->alg_key,
-			       (x->aalg->alg_key_len + 7) / 8))
+	ahp->ahash = ahash;
+	if (crypto_ahash_setkey(ahash, x->aalg->alg_key,
+				(x->aalg->alg_key_len + 7) / 8))
 		goto error;
 
 	/*
 	 * Lookup the algorithm description maintained by xfrm_algo,
 	 * verify crypto transform properties, and store information
 	 * we need for AH processing.  This lookup cannot fail here
-	 * after a successful crypto_alloc_hash().
+	 * after a successful crypto_alloc_ahash().
 	 */
 	aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 	BUG_ON(!aalg_desc);
 
 	if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
-	    crypto_hash_digestsize(tfm)) {
+	    crypto_ahash_digestsize(ahash)) {
 		printk(KERN_INFO "AH: %s digestsize %u != %hu\n",
-		       x->aalg->alg_name, crypto_hash_digestsize(tfm),
+		       x->aalg->alg_name, crypto_ahash_digestsize(ahash),
 		       aalg_desc->uinfo.auth.icv_fullbits/8);
 		goto error;
 	}
@@ -265,10 +448,6 @@ static int ah_init_state(struct xfrm_state *x)
 
 	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
 
-	ahp->work_icv = kmalloc(ahp->icv_full_len, GFP_KERNEL);
-	if (!ahp->work_icv)
-		goto error;
-
 	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
 					  ahp->icv_trunc_len);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
@@ -279,8 +458,7 @@ static int ah_init_state(struct xfrm_state *x)
 
 error:
 	if (ahp) {
-		kfree(ahp->work_icv);
-		crypto_free_hash(ahp->tfm);
+		crypto_free_ahash(ahp->ahash);
 		kfree(ahp);
 	}
 	return -EINVAL;
@@ -293,8 +471,7 @@ static void ah_destroy(struct xfrm_state *x)
 	if (!ahp)
 		return;
 
-	kfree(ahp->work_icv);
-	crypto_free_hash(ahp->tfm);
+	crypto_free_ahash(ahp->ahash);
 	kfree(ahp);
 }
 
-- 
1.5.4.2

