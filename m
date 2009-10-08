From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/5] ah6: convert to ahash
Date: Thu, 8 Oct 2009 10:49:01 +0200
Message-ID: <20091008084900.GM15653@secunet.com>
References: <20091008084631.GJ15653@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:43222 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbZJHItn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 04:49:43 -0400
Content-Disposition: inline
In-Reply-To: <20091008084631.GJ15653@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts ah6 to the new ahash interface.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ah6.c |  352 +++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 272 insertions(+), 80 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index c1589e2..0f526f8 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -24,18 +24,92 @@
  * 	This file is derived from net/ipv4/ah.c.
  */
 
+#include <crypto/hash.h>
 #include <linux/module.h>
 #include <net/ip.h>
 #include <net/ah.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
-#include <linux/spinlock.h>
 #include <linux/string.h>
+#include <linux/scatterlist.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
 #include <net/xfrm.h>
 
+#define IPV6HDR_BASELEN 8
+
+struct tmp_ext {
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+		struct in6_addr saddr;
+#endif
+		struct in6_addr daddr;
+		char hdrs[0];
+};
+
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
+static inline struct tmp_ext *ah_tmp_ext(void *base)
+{
+	return base + IPV6HDR_BASELEN;
+}
+
+static inline u8 *ah_tmp_auth(u8 *tmp, unsigned int offset)
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
+
 static int zero_out_mutable_opts(struct ipv6_opt_hdr *opthdr)
 {
 	u8 *opt = (u8 *)opthdr;
@@ -218,24 +292,85 @@ static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
 	return 0;
 }
 
+static void ah6_output_done(struct crypto_async_request *base, int err)
+{
+	int extlen;
+	u8 *iph_base;
+	u8 *icv;
+	struct sk_buff *skb = base->data;
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
+	struct ah_data *ahp = x->data;
+	struct ipv6hdr *top_iph = ipv6_hdr(skb);
+	struct ip_auth_hdr *ah = ip_auth_hdr(skb);
+	struct tmp_ext *iph_ext;
+
+	extlen = skb_network_header_len(skb) - sizeof(struct ipv6hdr);
+	if (extlen)
+		extlen += sizeof(*iph_ext);
+
+	iph_base = AH_SKB_CB(skb)->tmp;
+	iph_ext = ah_tmp_ext(iph_base);
+	icv = ah_tmp_icv(ahp->ahash, iph_ext, extlen);
+
+	memcpy(ah->auth_data, icv, ahp->icv_trunc_len);
+	memcpy(top_iph, iph_base, IPV6HDR_BASELEN);
+
+	if (extlen) {
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+		memcpy(&top_iph->saddr, iph_ext, extlen);
+#else
+		memcpy(&top_iph->daddr, iph_ext, extlen);
+#endif
+	}
+
+	err = ah->nexthdr;
+
+	kfree(AH_SKB_CB(skb)->tmp);
+	xfrm_output_resume(skb, err);
+}
+
 static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
+	int nfrags;
 	int extlen;
+	u8 *iph_base;
+	u8 *icv;
+	u8 nexthdr;
+	struct sk_buff *trailer;
+	struct crypto_ahash *ahash;
+	struct ahash_request *req;
+	struct scatterlist *sg;
 	struct ipv6hdr *top_iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
-	u8 nexthdr;
-	char tmp_base[8];
-	struct {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-		struct in6_addr saddr;
-#endif
-		struct in6_addr daddr;
-		char hdrs[0];
-	} *tmp_ext;
+	struct tmp_ext *iph_ext;
+
+	ahp = x->data;
+	ahash = ahp->ahash;
+
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+		goto out;
+	nfrags = err;
 
 	skb_push(skb, -skb_network_offset(skb));
+	extlen = skb_network_header_len(skb) - sizeof(struct ipv6hdr);
+	if (extlen)
+		extlen += sizeof(*iph_ext);
+
+	err = -ENOMEM;
+	iph_base = ah_alloc_tmp(ahash, nfrags, IPV6HDR_BASELEN + extlen);
+	if (!iph_base)
+		goto out;
+
+	iph_ext = ah_tmp_ext(iph_base);
+	icv = ah_tmp_icv(ahash, iph_ext, extlen);
+	req = ah_tmp_req(ahash, icv);
+	sg = ah_req_sg(ahash, req);
+
+	ah = ip_auth_hdr(skb);
+	memset(ah->auth_data, 0, ahp->icv_trunc_len);
+
 	top_iph = ipv6_hdr(skb);
 	top_iph->payload_len = htons(skb->len - sizeof(*top_iph));
 
@@ -245,31 +380,22 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	/* When there are no extension headers, we only need to save the first
 	 * 8 bytes of the base IP header.
 	 */
-	memcpy(tmp_base, top_iph, sizeof(tmp_base));
+	memcpy(iph_base, top_iph, IPV6HDR_BASELEN);
 
-	tmp_ext = NULL;
-	extlen = skb_transport_offset(skb) - sizeof(struct ipv6hdr);
 	if (extlen) {
-		extlen += sizeof(*tmp_ext);
-		tmp_ext = kmalloc(extlen, GFP_ATOMIC);
-		if (!tmp_ext) {
-			err = -ENOMEM;
-			goto error;
-		}
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-		memcpy(tmp_ext, &top_iph->saddr, extlen);
+		memcpy(iph_ext, &top_iph->saddr, extlen);
 #else
-		memcpy(tmp_ext, &top_iph->daddr, extlen);
+		memcpy(iph_ext, &top_iph->daddr, extlen);
 #endif
 		err = ipv6_clear_mutable_options(top_iph,
-						 extlen - sizeof(*tmp_ext) +
+						 extlen - sizeof(*iph_ext) +
 						 sizeof(*top_iph),
 						 XFRM_POLICY_OUT);
 		if (err)
-			goto error_free_iph;
+			goto out_free;
 	}
 
-	ah = ip_auth_hdr(skb);
 	ah->nexthdr = nexthdr;
 
 	top_iph->priority    = 0;
@@ -278,36 +404,80 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->flow_lbl[2] = 0;
 	top_iph->hop_limit   = 0;
 
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
-		goto error_free_iph;
+	ahash_request_set_crypt(req, sg, icv, skb->len);
+	ahash_request_set_callback(req, 0, ah6_output_done, skb);
+
+	AH_SKB_CB(skb)->tmp = iph_base;
 
-	memcpy(top_iph, tmp_base, sizeof(tmp_base));
-	if (tmp_ext) {
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
+	memcpy(top_iph, iph_base, IPV6HDR_BASELEN);
+
+	if (extlen) {
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-		memcpy(&top_iph->saddr, tmp_ext, extlen);
+		memcpy(&top_iph->saddr, iph_ext, extlen);
 #else
-		memcpy(&top_iph->daddr, tmp_ext, extlen);
+		memcpy(&top_iph->daddr, iph_ext, extlen);
 #endif
-error_free_iph:
-		kfree(tmp_ext);
 	}
 
-error:
+out_free:
+	kfree(iph_base);
+out:
 	return err;
 }
 
+static void ah6_input_done(struct crypto_async_request *base, int err)
+{
+	u8 *auth_data;
+	u8 *icv;
+	u8 *work_iph;
+	struct sk_buff *skb = base->data;
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct ah_data *ahp = x->data;
+	struct ip_auth_hdr *ah = ip_auth_hdr(skb);
+	int hdr_len = skb_network_header_len(skb);
+	int ah_hlen = (ah->hdrlen + 2) << 2;
+
+	work_iph = AH_SKB_CB(skb)->tmp;
+	auth_data = ah_tmp_auth(work_iph, hdr_len);
+	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
+
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	if (err)
+		goto out;
+
+	skb->network_header += ah_hlen;
+	memcpy(skb_network_header(skb), work_iph, hdr_len);
+	__skb_pull(skb, ah_hlen + hdr_len);
+	skb_set_transport_header(skb, -hdr_len);
+
+	err = ah->nexthdr;
+out:
+	kfree(AH_SKB_CB(skb)->tmp);
+	xfrm_input_resume(skb, err);
+}
+
+
+
 static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	/*
@@ -325,14 +495,21 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	 * There is offset of AH before IPv6 header after the process.
 	 */
 
+	u8 *auth_data;
+	u8 *icv;
+	u8 *work_iph;
+	struct sk_buff *trailer;
+	struct crypto_ahash *ahash;
+	struct ahash_request *req;
+	struct scatterlist *sg;
 	struct ip_auth_hdr *ah;
 	struct ipv6hdr *ip6h;
 	struct ah_data *ahp;
-	unsigned char *tmp_hdr = NULL;
 	u16 hdr_len;
 	u16 ah_hlen;
 	int nexthdr;
-	int err = -EINVAL;
+	int nfrags;
+	int err = -ENOMEM;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
 		goto out;
@@ -345,9 +522,11 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	hdr_len = skb->data - skb_network_header(skb);
+	hdr_len = skb_network_header_len(skb);
 	ah = (struct ip_auth_hdr *)skb->data;
 	ahp = x->data;
+	ahash = ahp->ahash;
+
 	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 
@@ -358,48 +537,67 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, ah_hlen))
 		goto out;
 
-	tmp_hdr = kmemdup(skb_network_header(skb), hdr_len, GFP_ATOMIC);
-	if (!tmp_hdr)
-		goto out;
 	ip6h = ipv6_hdr(skb);
+
+	skb_push(skb, hdr_len);
+
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+		goto out;
+	nfrags = err;
+
+	work_iph = ah_alloc_tmp(ahash, nfrags, hdr_len + ahp->icv_trunc_len);
+	if (!work_iph)
+		goto out;
+
+	auth_data = ah_tmp_auth(work_iph, hdr_len);
+	icv = ah_tmp_icv(ahash, auth_data, ahp->icv_trunc_len);
+	req = ah_tmp_req(ahash, icv);
+	sg = ah_req_sg(ahash, req);
+
+	memcpy(work_iph, ip6h, hdr_len);
+	memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
+	memset(ah->auth_data, 0, ahp->icv_trunc_len);
+
 	if (ipv6_clear_mutable_options(ip6h, hdr_len, XFRM_POLICY_IN))
-		goto free_out;
+		goto out_free;
+
 	ip6h->priority    = 0;
 	ip6h->flow_lbl[0] = 0;
 	ip6h->flow_lbl[1] = 0;
 	ip6h->flow_lbl[2] = 0;
 	ip6h->hop_limit   = 0;
 
-	spin_lock(&x->lock);
-	{
-		u8 auth_data[MAX_AH_AUTH_LEN];
+	sg_init_table(sg, nfrags);
+	skb_to_sgvec(skb, sg, 0, skb->len);
 
-		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
-		memset(ah->auth_data, 0, ahp->icv_trunc_len);
-		skb_push(skb, hdr_len);
-		err = ah_mac_digest(ahp, skb, ah->auth_data);
-		if (err)
-			goto unlock;
-		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len))
-			err = -EBADMSG;
+	ahash_request_set_crypt(req, sg, icv, skb->len);
+	ahash_request_set_callback(req, 0, ah6_input_done, skb);
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
-		goto free_out;
+		goto out_free;
 
 	skb->network_header += ah_hlen;
-	memcpy(skb_network_header(skb), tmp_hdr, hdr_len);
+	memcpy(skb_network_header(skb), work_iph, hdr_len);
 	skb->transport_header = skb->network_header;
 	__skb_pull(skb, ah_hlen + hdr_len);
 
-	kfree(tmp_hdr);
+	err = nexthdr;
 
-	return nexthdr;
-
-free_out:
-	kfree(tmp_hdr);
+out_free:
+	kfree(work_iph);
 out:
 	return err;
 }
@@ -430,7 +628,7 @@ static int ah6_init_state(struct xfrm_state *x)
 {
 	struct ah_data *ahp = NULL;
 	struct xfrm_algo_desc *aalg_desc;
-	struct crypto_hash *tfm;
+	struct crypto_ahash *ahash;
 
 	if (!x->aalg)
 		goto error;
@@ -442,12 +640,12 @@ static int ah6_init_state(struct xfrm_state *x)
 	if (ahp == NULL)
 		return -ENOMEM;
 
-	tfm = crypto_alloc_hash(x->aalg->alg_name, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(tfm))
+	ahash = crypto_alloc_ahash(x->aalg->alg_name, 0, 0);
+	if (IS_ERR(ahash))
 		goto error;
 
-	ahp->tfm = tfm;
-	if (crypto_hash_setkey(tfm, x->aalg->alg_key,
+	ahp->ahash = ahash;
+	if (crypto_ahash_setkey(ahash, x->aalg->alg_key,
 			       (x->aalg->alg_key_len + 7) / 8))
 		goto error;
 
@@ -461,9 +659,9 @@ static int ah6_init_state(struct xfrm_state *x)
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
@@ -473,10 +671,6 @@ static int ah6_init_state(struct xfrm_state *x)
 
 	BUG_ON(ahp->icv_trunc_len > MAX_AH_AUTH_LEN);
 
-	ahp->work_icv = kmalloc(ahp->icv_full_len, GFP_KERNEL);
-	if (!ahp->work_icv)
-		goto error;
-
 	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
 					  ahp->icv_trunc_len);
 	switch (x->props.mode) {
@@ -495,8 +689,7 @@ static int ah6_init_state(struct xfrm_state *x)
 
 error:
 	if (ahp) {
-		kfree(ahp->work_icv);
-		crypto_free_hash(ahp->tfm);
+		crypto_free_ahash(ahp->ahash);
 		kfree(ahp);
 	}
 	return -EINVAL;
@@ -509,8 +702,7 @@ static void ah6_destroy(struct xfrm_state *x)
 	if (!ahp)
 		return;
 
-	kfree(ahp->work_icv);
-	crypto_free_hash(ahp->tfm);
+	crypto_free_ahash(ahp->ahash);
 	kfree(ahp);
 }
 
-- 
1.5.4.2

