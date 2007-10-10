From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/7] [IPSEC]: Get rid of ipv6_{auth,esp,comp}_hdr
Date: Wed, 10 Oct 2007 22:40:14 +0800
Message-ID: <E1IfcjO-00024U-00@gondolin.me.apana.org.au>
References: <20071010143915.GA7650@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3590 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754341AbXJJOkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:40:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Get rid of ipv6_{auth,esp,comp}_hdr

This patch removes the duplicate ipv6_{auth,esp,comp}_hdr structures since
they're identical to the IPv4 versions.  Duplicating them would only create
problems for ourselves later when we need to add things like extended
sequence numbers.

I've also added transport header type conversion headers for these types
which are now used by the transforms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/ipv6.h |   21 ---------------------
 include/net/ah.h     |    7 +++++++
 include/net/esp.h    |    7 +++++++
 include/net/ipcomp.h |   11 ++++++++++-
 net/ipv4/ah4.c       |   18 +++++++++---------
 net/ipv4/esp4.c      |   10 +++++-----
 net/ipv4/ipcomp.c    |    2 +-
 net/ipv6/ah6.c       |   16 ++++++++--------
 net/ipv6/esp6.c      |   18 +++++++++---------
 net/ipv6/ipcomp6.c   |   17 ++++++++---------
 10 files changed, 64 insertions(+), 63 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4ca60c3..5d35a4c 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -96,27 +96,6 @@ struct ipv6_destopt_hao {
 	struct in6_addr		addr;
 } __attribute__ ((__packed__));
 
-struct ipv6_auth_hdr {
-	__u8  nexthdr;
-	__u8  hdrlen;           /* This one is measured in 32 bit units! */
-	__be16 reserved;
-	__be32 spi;
-	__be32 seq_no;           /* Sequence number */
-	__u8  auth_data[0];     /* Length variable but >=4. Mind the 64 bit alignment! */
-};
-
-struct ipv6_esp_hdr {
-	__be32 spi;
-	__be32 seq_no;           /* Sequence number */
-	__u8  enc_data[0];      /* Length variable but >=8. Mind the 64 bit alignment! */
-};
-
-struct ipv6_comp_hdr {
-	__u8 nexthdr;
-	__u8 flags;
-	__be16 cpi;
-};
-
 /*
  *	IPv6 fixed header
  *
diff --git a/include/net/ah.h b/include/net/ah.h
index 5e758c2..ae1c322 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -38,4 +38,11 @@ out:
 	return err;
 }
 
+struct ip_auth_hdr;
+
+static inline struct ip_auth_hdr *ip_auth_hdr(const struct sk_buff *skb)
+{
+	return (struct ip_auth_hdr *)skb_transport_header(skb);
+}
+
 #endif
diff --git a/include/net/esp.h b/include/net/esp.h
index e793d76..c1bc529 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -53,4 +53,11 @@ static inline int esp_mac_digest(struct esp_data *esp, struct sk_buff *skb,
 	return crypto_hash_final(&desc, esp->auth.work_icv);
 }
 
+struct ip_esp_hdr;
+
+static inline struct ip_esp_hdr *ip_esp_hdr(const struct sk_buff *skb)
+{
+	return (struct ip_esp_hdr *)skb_transport_header(skb);
+}
+
 #endif
diff --git a/include/net/ipcomp.h b/include/net/ipcomp.h
index 87c1af3..330b74e 100644
--- a/include/net/ipcomp.h
+++ b/include/net/ipcomp.h
@@ -1,14 +1,23 @@
 #ifndef _NET_IPCOMP_H
 #define _NET_IPCOMP_H
 
-#include <linux/crypto.h>
 #include <linux/types.h>
 
 #define IPCOMP_SCRATCH_SIZE     65400
 
+struct crypto_comp;
+
 struct ipcomp_data {
 	u16 threshold;
 	struct crypto_comp **tfms;
 };
 
+struct ip_comp_hdr;
+struct sk_buff;
+
+static inline struct ip_comp_hdr *ip_comp_hdr(const struct sk_buff *skb)
+{
+	return (struct ip_comp_hdr *)skb_transport_header(skb);
+}
+
 #endif
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index e4f7aa3..d697064 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -82,7 +82,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 			goto error;
 	}
 
-	ah = (struct ip_auth_hdr *)skb_transport_header(skb);
+	ah = ip_auth_hdr(skb);
 	ah->nexthdr = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_AH;
 
@@ -93,8 +93,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->check = 0;
 
 	ahp = x->data;
-	ah->hdrlen  = (XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
-				   ahp->icv_trunc_len) >> 2) - 2;
+	ah->hdrlen  = (XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
@@ -134,15 +133,15 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 	struct ah_data *ahp;
 	char work_buf[60];
 
-	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
+	if (!pskb_may_pull(skb, sizeof(*ah)))
 		goto out;
 
-	ah = (struct ip_auth_hdr*)skb->data;
+	ah = (struct ip_auth_hdr *)skb->data;
 	ahp = x->data;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 
-	if (ah_hlen != XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + ahp->icv_full_len) &&
-	    ah_hlen != XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + ahp->icv_trunc_len))
+	if (ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_full_len) &&
+	    ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len))
 		goto out;
 
 	if (!pskb_may_pull(skb, ah_hlen))
@@ -156,7 +155,7 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	ah = (struct ip_auth_hdr*)skb->data;
+	ah = (struct ip_auth_hdr *)skb->data;
 	iph = ip_hdr(skb);
 
 	ihl = skb->data - skb_network_header(skb);
@@ -266,7 +265,8 @@ static int ah_init_state(struct xfrm_state *x)
 	if (!ahp->work_icv)
 		goto error;
 
-	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + ahp->icv_trunc_len);
+	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
+					  ahp->icv_trunc_len);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
 	x->data = ahp;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 93153d1..66eb496 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -60,7 +60,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ip_hdr(skb);
-	esph = (struct ip_esp_hdr *)skb_transport_header(skb);
+	esph = ip_esp_hdr(skb);
 	top_iph->tot_len = htons(skb->len + alen);
 	*(skb_tail_pointer(trailer) - 1) = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_ESP;
@@ -157,7 +157,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	struct sk_buff *trailer;
 	int blksize = ALIGN(crypto_blkcipher_blocksize(tfm), 4);
 	int alen = esp->auth.icv_trunc_len;
-	int elen = skb->len - sizeof(struct ip_esp_hdr) - esp->conf.ivlen - alen;
+	int elen = skb->len - sizeof(*esph) - esp->conf.ivlen - alen;
 	int nfrags;
 	int ihl;
 	u8 nexthdr[2];
@@ -165,7 +165,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	int padlen;
 	int err;
 
-	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
+	if (!pskb_may_pull(skb, sizeof(*esph)))
 		goto out;
 
 	if (elen <= 0 || (elen & (blksize-1)))
@@ -193,7 +193,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	esph = (struct ip_esp_hdr*)skb->data;
+	esph = (struct ip_esp_hdr *)skb->data;
 
 	/* Get ivec. This can be wrong, check against another impls. */
 	if (esp->conf.ivlen)
@@ -206,7 +206,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 		if (!sg)
 			goto out;
 	}
-	skb_to_sgvec(skb, sg, sizeof(struct ip_esp_hdr) + esp->conf.ivlen, elen);
+	skb_to_sgvec(skb, sg, sizeof(*esph) + esp->conf.ivlen, elen);
 	err = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 	if (unlikely(sg != &esp->sgbuf[0]))
 		kfree(sg);
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index bf74f64..78d6ddb 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -154,7 +154,7 @@ static int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* Install ipcomp header, convert into ipcomp datagram. */
 	iph->tot_len = htons(skb->len);
-	ipch = (struct ip_comp_hdr *)skb_transport_header(skb);
+	ipch = ip_comp_hdr(skb);
 	ipch->nexthdr = *skb_mac_header(skb);
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ac6bae1..f9f6891 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -270,7 +270,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 			goto error_free_iph;
 	}
 
-	ah = (struct ip_auth_hdr *)skb_transport_header(skb);
+	ah = ip_auth_hdr(skb);
 	ah->nexthdr = nexthdr;
 
 	top_iph->priority    = 0;
@@ -280,8 +280,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->hop_limit   = 0;
 
 	ahp = x->data;
-	ah->hdrlen  = (XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) +
-				   ahp->icv_trunc_len) >> 2) - 2;
+	ah->hdrlen  = (XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len) >> 2) - 2;
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
@@ -327,7 +326,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	 * There is offset of AH before IPv6 header after the process.
 	 */
 
-	struct ipv6_auth_hdr *ah;
+	struct ip_auth_hdr *ah;
 	struct ipv6hdr *ip6h;
 	struct ah_data *ahp;
 	unsigned char *tmp_hdr = NULL;
@@ -346,13 +345,13 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out;
 
 	hdr_len = skb->data - skb_network_header(skb);
-	ah = (struct ipv6_auth_hdr*)skb->data;
+	ah = (struct ip_auth_hdr *)skb->data;
 	ahp = x->data;
 	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 
-	if (ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_full_len) &&
-	    ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_trunc_len))
+	if (ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_full_len) &&
+	    ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_trunc_len))
 		goto out;
 
 	if (!pskb_may_pull(skb, ah_hlen))
@@ -474,7 +473,8 @@ static int ah6_init_state(struct xfrm_state *x)
 	if (!ahp->work_icv)
 		goto error;
 
-	x->props.header_len = XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_trunc_len);
+	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
+					  ahp->icv_trunc_len);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = ahp;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 21c93f0..a64295d 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -44,7 +44,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
 	struct ipv6hdr *top_iph;
-	struct ipv6_esp_hdr *esph;
+	struct ip_esp_hdr *esph;
 	struct crypto_blkcipher *tfm;
 	struct blkcipher_desc desc;
 	struct sk_buff *trailer;
@@ -86,7 +86,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ipv6_hdr(skb);
-	esph = (struct ipv6_esp_hdr *)skb_transport_header(skb);
+	esph = ip_esp_hdr(skb);
 	top_iph->payload_len = htons(skb->len + alen - sizeof(*top_iph));
 	*(skb_tail_pointer(trailer) - 1) = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_ESP;
@@ -142,19 +142,19 @@ error:
 static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *iph;
-	struct ipv6_esp_hdr *esph;
+	struct ip_esp_hdr *esph;
 	struct esp_data *esp = x->data;
 	struct crypto_blkcipher *tfm = esp->conf.tfm;
 	struct blkcipher_desc desc = { .tfm = tfm };
 	struct sk_buff *trailer;
 	int blksize = ALIGN(crypto_blkcipher_blocksize(tfm), 4);
 	int alen = esp->auth.icv_trunc_len;
-	int elen = skb->len - sizeof(struct ipv6_esp_hdr) - esp->conf.ivlen - alen;
+	int elen = skb->len - sizeof(*esph) - esp->conf.ivlen - alen;
 	int hdr_len = skb_network_header_len(skb);
 	int nfrags;
 	int ret = 0;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6_esp_hdr))) {
+	if (!pskb_may_pull(skb, sizeof(*esph))) {
 		ret = -EINVAL;
 		goto out;
 	}
@@ -189,7 +189,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	esph = (struct ipv6_esp_hdr*)skb->data;
+	esph = (struct ip_esp_hdr *)skb->data;
 	iph = ipv6_hdr(skb);
 
 	/* Get ivec. This can be wrong, check against another impls. */
@@ -208,7 +208,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 				goto out;
 			}
 		}
-		skb_to_sgvec(skb, sg, sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen, elen);
+		skb_to_sgvec(skb, sg, sizeof(*esph) + esp->conf.ivlen, elen);
 		ret = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
@@ -260,7 +260,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		     int type, int code, int offset, __be32 info)
 {
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
-	struct ipv6_esp_hdr *esph = (struct ipv6_esp_hdr*)(skb->data+offset);
+	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
 	if (type != ICMPV6_DEST_UNREACH &&
@@ -356,7 +356,7 @@ static int esp6_init_state(struct xfrm_state *x)
 	if (crypto_blkcipher_setkey(tfm, x->ealg->alg_key,
 				    (x->ealg->alg_key_len + 7) / 8))
 		goto error;
-	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
+	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = esp;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 87e6407..8f3f32f 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -65,7 +65,7 @@ static LIST_HEAD(ipcomp6_tfms_list);
 static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = -ENOMEM;
-	struct ipv6_comp_hdr *ipch;
+	struct ip_comp_hdr *ipch;
 	int plen, dlen;
 	struct ipcomp_data *ipcd = x->data;
 	u8 *start, *scratch;
@@ -92,12 +92,10 @@ static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
 
 	err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
-	if (err) {
-		err = -EINVAL;
+	if (err)
 		goto out_put_cpu;
-	}
 
-	if (dlen < (plen + sizeof(struct ipv6_comp_hdr))) {
+	if (dlen < (plen + sizeof(*ipch))) {
 		err = -EINVAL;
 		goto out_put_cpu;
 	}
@@ -122,7 +120,7 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
 	struct ipv6hdr *top_iph;
-	struct ipv6_comp_hdr *ipch;
+	struct ip_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
 	int plen, dlen;
 	u8 *start, *scratch;
@@ -151,7 +149,7 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
 
 	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
-	if (err || (dlen + sizeof(struct ipv6_comp_hdr)) >= plen) {
+	if (err || (dlen + sizeof(*ipch)) >= plen) {
 		put_cpu();
 		goto out_ok;
 	}
@@ -164,7 +162,7 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 
-	ipch = (struct ipv6_comp_hdr *)start;
+	ipch = ip_comp_hdr(skb);
 	ipch->nexthdr = *skb_mac_header(skb);
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
@@ -179,7 +177,8 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 {
 	__be32 spi;
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
-	struct ipv6_comp_hdr *ipcomph = (struct ipv6_comp_hdr*)(skb->data+offset);
+	struct ip_comp_hdr *ipcomph =
+		(struct ip_comp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
 	if (type != ICMPV6_DEST_UNREACH && type != ICMPV6_PKT_TOOBIG)
