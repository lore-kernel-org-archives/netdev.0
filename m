From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/7] [IPSEC]: Move IP length/checksum setting out of transforms
Date: Wed, 10 Oct 2007 22:40:15 +0800
Message-ID: <E1IfcjP-00024c-00@gondolin.me.apana.org.au>
References: <20071010143915.GA7650@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3592 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754443AbXJJOkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:40:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move IP length/checksum setting out of transforms

This patch moves the setting of the IP length and checksum fields out of
the transforms and into the xfrmX_output functions.  This would help future
efforts in merging the transforms themselves.

It also adds an optimisation to ipcomp due to the fact that the transport
offset is guaranteed to be zero.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ah4.c               |    2 --
 net/ipv4/esp4.c              |    7 +------
 net/ipv4/ipcomp.c            |   22 +++++-----------------
 net/ipv4/xfrm4_mode_beet.c   |    3 ---
 net/ipv4/xfrm4_mode_tunnel.c |    5 +----
 net/ipv4/xfrm4_output.c      |    5 +++++
 net/ipv4/xfrm4_tunnel.c      |    5 -----
 net/ipv6/esp6.c              |    3 ---
 net/ipv6/ipcomp6.c           |   19 ++++++-------------
 net/ipv6/mip6.c              |    2 --
 net/ipv6/xfrm6_mode_beet.c   |    2 --
 net/ipv6/xfrm6_mode_tunnel.c |    4 +---
 net/ipv6/xfrm6_output.c      |    4 ++++
 net/ipv6/xfrm6_tunnel.c      |    5 -----
 14 files changed, 23 insertions(+), 65 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index d697064..60925fe 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -115,8 +115,6 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
 	}
 
-	ip_send_check(top_iph);
-
 	err = 0;
 
 error:
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 66eb496..8377bed 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -16,7 +16,6 @@
 static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
-	struct iphdr *top_iph;
 	struct ip_esp_hdr *esph;
 	struct crypto_blkcipher *tfm;
 	struct blkcipher_desc desc;
@@ -59,9 +58,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	pskb_put(skb, trailer, clen - skb->len);
 
 	skb_push(skb, -skb_network_offset(skb));
-	top_iph = ip_hdr(skb);
 	esph = ip_esp_hdr(skb);
-	top_iph->tot_len = htons(skb->len + alen);
 	*(skb_tail_pointer(trailer) - 1) = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_ESP;
 
@@ -76,7 +73,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		uh = (struct udphdr *)esph;
 		uh->source = encap->encap_sport;
 		uh->dest = encap->encap_dport;
-		uh->len = htons(skb->len + alen - top_iph->ihl*4);
+		uh->len = htons(skb->len + alen - skb_transport_offset(skb));
 		uh->check = 0;
 
 		switch (encap->encap_type) {
@@ -136,8 +133,6 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 unlock:
 	spin_unlock_bh(&x->lock);
 
-	ip_send_check(top_iph);
-
 error:
 	return err;
 }
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 78d6ddb..32b02de 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -98,10 +98,9 @@ out:
 static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipcomp_data *ipcd = x->data;
-	const int ihlen = skb_transport_offset(skb);
-	const int plen = skb->len - ihlen;
+	const int plen = skb->len;
 	int dlen = IPCOMP_SCRATCH_SIZE;
-	u8 *start = skb_transport_header(skb);
+	u8 *start = skb->data;
 	const int cpu = get_cpu();
 	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
 	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
@@ -118,7 +117,7 @@ static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
 	put_cpu();
 
-	pskb_trim(skb, ihlen + dlen + sizeof(struct ip_comp_hdr));
+	pskb_trim(skb, dlen + sizeof(struct ip_comp_hdr));
 	return 0;
 
 out:
@@ -131,13 +130,8 @@ static int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int err;
 	struct ip_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
-	int hdr_len = 0;
-	struct iphdr *iph = ip_hdr(skb);
 
-	skb_push(skb, -skb_network_offset(skb));
-	iph->tot_len = htons(skb->len);
-	hdr_len = iph->ihl * 4;
-	if ((skb->len - hdr_len) < ipcd->threshold) {
+	if (skb->len < ipcd->threshold) {
 		/* Don't bother compressing */
 		goto out_ok;
 	}
@@ -146,25 +140,19 @@ static int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto out_ok;
 
 	err = ipcomp_compress(x, skb);
-	iph = ip_hdr(skb);
 
 	if (err) {
 		goto out_ok;
 	}
 
 	/* Install ipcomp header, convert into ipcomp datagram. */
-	iph->tot_len = htons(skb->len);
 	ipch = ip_comp_hdr(skb);
 	ipch->nexthdr = *skb_mac_header(skb);
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
 	*skb_mac_header(skb) = IPPROTO_COMP;
-	ip_send_check(iph);
-	return 0;
-
 out_ok:
-	if (x->props.mode == XFRM_MODE_TUNNEL)
-		ip_send_check(iph);
+	skb_push(skb, -skb_network_offset(skb));
 	return 0;
 }
 
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 7226c64..73d2338 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -20,9 +20,6 @@
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per draft-nikander-esp-beet-mode-06.txt.
- * The following fields in it shall be filled in by x->type->output:
- *      tot_len
- *      check
  */
 static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index f1d41ea..1ae9d32 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -31,10 +31,7 @@ static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
 
 /* Add encapsulation header.
  *
- * The top IP header will be constructed per RFC 2401.  The following fields
- * in it shall be filled in by x->type->output:
- *      tot_len
- *      check
+ * The top IP header will be constructed per RFC 2401.
  */
 static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 04805c7..434ef30 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -44,6 +44,7 @@ static inline int xfrm4_output_one(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
+	struct iphdr *iph;
 	int err;
 
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
@@ -56,6 +57,10 @@ static inline int xfrm4_output_one(struct sk_buff *skb)
 	if (err)
 		goto error_nolock;
 
+	iph = ip_hdr(skb);
+	iph->tot_len = htons(skb->len);
+	ip_send_check(iph);
+
 	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	err = 0;
 
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index be572f9..e1fafc1 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -12,12 +12,7 @@
 
 static int ipip_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(skb);
-
 	skb_push(skb, -skb_network_offset(skb));
-	iph->tot_len = htons(skb->len);
-	ip_send_check(iph);
-
 	return 0;
 }
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index a64295d..9eb9285 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -43,7 +43,6 @@
 static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
-	struct ipv6hdr *top_iph;
 	struct ip_esp_hdr *esph;
 	struct crypto_blkcipher *tfm;
 	struct blkcipher_desc desc;
@@ -85,9 +84,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	pskb_put(skb, trailer, clen - skb->len);
 
 	skb_push(skb, -skb_network_offset(skb));
-	top_iph = ipv6_hdr(skb);
 	esph = ip_esp_hdr(skb);
-	top_iph->payload_len = htons(skb->len + alen - sizeof(*top_iph));
 	*(skb_tail_pointer(trailer) - 1) = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_ESP;
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 8f3f32f..28fc8ed 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -119,20 +119,15 @@ out:
 static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
-	struct ipv6hdr *top_iph;
 	struct ip_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
 	int plen, dlen;
 	u8 *start, *scratch;
 	struct crypto_comp *tfm;
 	int cpu;
-	int hdr_len;
-
-	skb_push(skb, -skb_network_offset(skb));
-	hdr_len = skb_transport_offset(skb);
 
 	/* check whether datagram len is larger than threshold */
-	if ((skb->len - hdr_len) < ipcd->threshold) {
+	if (skb->len < ipcd->threshold) {
 		goto out_ok;
 	}
 
@@ -140,9 +135,9 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto out_ok;
 
 	/* compression */
-	plen = skb->len - hdr_len;
+	plen = skb->len;
 	dlen = IPCOMP_SCRATCH_SIZE;
-	start = skb_transport_header(skb);
+	start = skb->data;
 
 	cpu = get_cpu();
 	scratch = *per_cpu_ptr(ipcomp6_scratches, cpu);
@@ -155,13 +150,9 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
 	put_cpu();
-	pskb_trim(skb, hdr_len + dlen + sizeof(struct ip_comp_hdr));
+	pskb_trim(skb, dlen + sizeof(struct ip_comp_hdr));
 
 	/* insert ipcomp header and replace datagram */
-	top_iph = ipv6_hdr(skb);
-
-	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
-
 	ipch = ip_comp_hdr(skb);
 	ipch->nexthdr = *skb_mac_header(skb);
 	ipch->flags = 0;
@@ -169,6 +160,8 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	*skb_mac_header(skb) = IPPROTO_COMP;
 
 out_ok:
+	skb_push(skb, -skb_network_offset(skb));
+
 	return 0;
 }
 
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 0e7a60f..7fd841d 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -155,7 +155,6 @@ static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_push(skb, -skb_network_offset(skb));
 	iph = ipv6_hdr(skb);
-	iph->payload_len = htons(skb->len - sizeof(*iph));
 
 	nexthdr = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_DSTOPTS;
@@ -370,7 +369,6 @@ static int mip6_rthdr_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_push(skb, -skb_network_offset(skb));
 	iph = ipv6_hdr(skb);
-	iph->payload_len = htons(skb->len - sizeof(*iph));
 
 	nexthdr = *skb_mac_header(skb);
 	*skb_mac_header(skb) = IPPROTO_ROUTING;
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 42c6ef8..13bb1e8 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -22,8 +22,6 @@
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per draft-nikander-esp-beet-mode-06.txt.
- * The following fields in it shall be filled in by x->type->output:
- *	payload_len
  */
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index e79c6bd..ea22838 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -33,9 +33,7 @@ static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
 
 /* Add encapsulation header.
  *
- * The top IP header will be constructed per RFC 2401.  The following fields
- * in it shall be filled in by x->type->output:
- *	payload_len
+ * The top IP header will be constructed per RFC 2401.
  */
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index f21596f..4618c18 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -47,6 +47,7 @@ static inline int xfrm6_output_one(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
+	struct ipv6hdr *iph;
 	int err;
 
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
@@ -59,6 +60,9 @@ static inline int xfrm6_output_one(struct sk_buff *skb)
 	if (err)
 		goto error_nolock;
 
+	iph = ipv6_hdr(skb);
+	iph->payload_len = htons(skb->len - sizeof(*iph));
+
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 	err = 0;
 
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 00a1a3e..3f8a3ab 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -242,12 +242,7 @@ EXPORT_SYMBOL(xfrm6_tunnel_free_spi);
 
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ipv6hdr *top_iph;
-
 	skb_push(skb, -skb_network_offset(skb));
-	top_iph = ipv6_hdr(skb);
-	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
-
 	return 0;
 }
 
