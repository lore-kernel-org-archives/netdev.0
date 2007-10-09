From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/7] [IPSEC]: Store IPv6 nh pointer in mac_header on output
Date: Tue, 09 Oct 2007 22:36:32 +0800
Message-ID: <E1IfGCG-0005Lp-00@gondolin.me.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4985 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752933AbXJIOgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Store IPv6 nh pointer in mac_header on output

Current the x->mode->output functions store the IPv6 nh pointer in the
skb network header.  This is inconvenient because the network header then
has to be fixed up before the packet can leave the IPsec stack.  The mac
header field is unused on output so we can use that to store this instead.

This patch does that and removes the network header fix-up in xfrm_output.

It also uses ipv6_hdr where appropriate in the x->type->output functions.

There is also a minor clean-up in esp4 to make it use the same code as
esp6 to help any subsequent effort to merge the two.

Lastly it kills two redundant skb_set_* statements in BEET that were
simply copied over from transport mode.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/esp4.c                 |    2 +-
 net/ipv6/ah6.c                  |    6 +++---
 net/ipv6/esp6.c                 |    7 ++++---
 net/ipv6/ipcomp6.c              |    6 +++---
 net/ipv6/mip6.c                 |   12 ++++++------
 net/ipv6/xfrm6_mode_beet.c      |   16 +++++++---------
 net/ipv6/xfrm6_mode_ro.c        |   13 +++++++------
 net/ipv6/xfrm6_mode_transport.c |   13 +++++++------
 net/ipv6/xfrm6_mode_tunnel.c    |   13 +++++++------
 net/ipv6/xfrm6_tunnel.c         |    2 +-
 net/xfrm/xfrm_output.c          |    2 --
 11 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 0f62af9..ffd5653 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -59,7 +59,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	tail[clen - skb->len - 2] = (clen - skb->len) - 2;
 	pskb_put(skb, trailer, clen - skb->len);
 
-	__skb_push(skb, skb->data - skb_network_header(skb));
+	__skb_push(skb, -skb_network_offset(skb));
 	top_iph = ip_hdr(skb);
 	esph = (struct ip_esp_hdr *)(skb_network_header(skb) +
 				     top_iph->ihl * 4);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ae68a90..ff904a7 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -235,11 +235,11 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 		char hdrs[0];
 	} *tmp_ext;
 
-	top_iph = (struct ipv6hdr *)skb->data;
+	top_iph = ipv6_hdr(skb);
 	top_iph->payload_len = htons(skb->len - sizeof(*top_iph));
 
-	nexthdr = *skb_network_header(skb);
-	*skb_network_header(skb) = IPPROTO_AH;
+	nexthdr = *skb_mac_header(skb);
+	*skb_mac_header(skb) = IPPROTO_AH;
 
 	/* When there are no extension headers, we only need to save the first
 	 * 8 bytes of the base IP header.
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 0c5fb81..9fc1940 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -88,11 +88,12 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	tail[clen-skb->len - 2] = (clen - skb->len) - 2;
 	pskb_put(skb, trailer, clen - skb->len);
 
-	top_iph = (struct ipv6hdr *)__skb_push(skb, hdr_len);
+	__skb_push(skb, -skb_network_offset(skb));
+	top_iph = ipv6_hdr(skb);
 	esph = (struct ipv6_esp_hdr *)skb_transport_header(skb);
 	top_iph->payload_len = htons(skb->len + alen - sizeof(*top_iph));
-	*(skb_tail_pointer(trailer) - 1) = *skb_network_header(skb);
-	*skb_network_header(skb) = IPPROTO_ESP;
+	*(skb_tail_pointer(trailer) - 1) = *skb_mac_header(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 91b2a75..71a14c0 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -157,15 +157,15 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	pskb_trim(skb, hdr_len + dlen + sizeof(struct ip_comp_hdr));
 
 	/* insert ipcomp header and replace datagram */
-	top_iph = (struct ipv6hdr *)skb->data;
+	top_iph = ipv6_hdr(skb);
 
 	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 
 	ipch = (struct ipv6_comp_hdr *)start;
-	ipch->nexthdr = *skb_network_header(skb);
+	ipch->nexthdr = *skb_mac_header(skb);
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
-	*skb_network_header(skb) = IPPROTO_COMP;
+	*skb_mac_header(skb) = IPPROTO_COMP;
 
 out_ok:
 	return 0;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 8a1399c..7261c29 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -153,11 +153,11 @@ static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 nexthdr;
 	int len;
 
-	iph = (struct ipv6hdr *)skb->data;
+	iph = ipv6_hdr(skb);
 	iph->payload_len = htons(skb->len - sizeof(*iph));
 
-	nexthdr = *skb_network_header(skb);
-	*skb_network_header(skb) = IPPROTO_DSTOPTS;
+	nexthdr = *skb_mac_header(skb);
+	*skb_mac_header(skb) = IPPROTO_DSTOPTS;
 
 	dstopt = (struct ipv6_destopt_hdr *)skb_transport_header(skb);
 	dstopt->nexthdr = nexthdr;
@@ -365,11 +365,11 @@ static int mip6_rthdr_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct rt2_hdr *rt2;
 	u8 nexthdr;
 
-	iph = (struct ipv6hdr *)skb->data;
+	iph = ipv6_hdr(skb);
 	iph->payload_len = htons(skb->len - sizeof(*iph));
 
-	nexthdr = *skb_network_header(skb);
-	*skb_network_header(skb) = IPPROTO_ROUTING;
+	nexthdr = *skb_mac_header(skb);
+	*skb_mac_header(skb) = IPPROTO_ROUTING;
 
 	rt2 = (struct rt2_hdr *)skb_transport_header(skb);
 	rt2->rt_hdr.nexthdr = nexthdr;
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 2e61d6d..65e6b2a 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -26,10 +26,11 @@
  *	payload_len
  *
  * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and skb->nh will be set to the nextheader field
- * of the extension header directly preceding the encapsulation header, or in
- * its absence, that of the top IP header.  The value of skb->data will always
- * point to the top IP header.
+ * filled in by x->type->output and the mac header will be set to the
+ * nextheader field of the extension header directly preceding the
+ * encapsulation header, or in its absence, that of the top IP header.
+ * The value of skb->data and the network header will always point to the
+ * top IP header.
  */
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -41,15 +42,12 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	iph = ipv6_hdr(skb);
 
 	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
-	skb_set_network_header(skb,
-			       (prevhdr - x->props.header_len) - skb->data);
-	skb_set_transport_header(skb, hdr_len);
 	memmove(skb->data, iph, hdr_len);
 
+	skb_set_mac_header(skb, offsetof(struct ipv6hdr, nexthdr));
 	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
 	top_iph = ipv6_hdr(skb);
-	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
-	skb->network_header += offsetof(struct ipv6hdr, nexthdr);
 
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index a156373..2575804 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -39,10 +39,11 @@
  * space for the route optimization header.
  *
  * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and skb->nh will be set to the nextheader field
- * of the extension header directly preceding the encapsulation header, or in
- * its absence, that of the top IP header.  The value of skb->data will always
- * point to the top IP header.
+ * filled in by x->type->output and the mac header will be set to the
+ * nextheader field of the extension header directly preceding the
+ * encapsulation header, or in its absence, that of the top IP header.
+ * The value of skb->data and the network header will always point to the
+ * top IP header.
  */
 static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -54,8 +55,8 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	iph = ipv6_hdr(skb);
 
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
-	skb_set_network_header(skb,
-			       (prevhdr - x->props.header_len) - skb->data);
+	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
+	skb_reset_network_header(skb);
 	skb_set_transport_header(skb, hdr_len);
 	memmove(skb->data, iph, hdr_len);
 
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index c026bfe..65c166b 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -20,10 +20,11 @@
  * space for the encapsulation header.
  *
  * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and skb->nh will be set to the nextheader field
- * of the extension header directly preceding the encapsulation header, or in
- * its absence, that of the top IP header.  The value of skb->data will always
- * point to the top IP header.
+ * filled in by x->type->output and the mac header will be set to the
+ * nextheader field of the extension header directly preceding the
+ * encapsulation header, or in its absence, that of the top IP header.
+ * The value of skb->data and the network header will always point to the
+ * top IP header.
  */
 static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -35,8 +36,8 @@ static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	iph = ipv6_hdr(skb);
 
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
-	skb_set_network_header(skb,
-			       (prevhdr - x->props.header_len) - skb->data);
+	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
+	skb_reset_network_header(skb);
 	skb_set_transport_header(skb, hdr_len);
 	memmove(skb->data, iph, hdr_len);
 	return 0;
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 9fc95bc..3dd40af 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -38,10 +38,11 @@ static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
  *	payload_len
  *
  * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and skb->nh will be set to the nextheader field
- * of the extension header directly preceding the encapsulation header, or in
- * its absence, that of the top IP header.  The value of skb->data will always
- * point to the top IP header.
+ * filled in by x->type->output and the mac header will be set to the
+ * nextheader field of the extension header directly preceding the
+ * encapsulation header, or in its absence, that of the top IP header.
+ * The value of skb->data and the network header will always point to the
+ * top IP header.
  */
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -53,10 +54,10 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	skb_push(skb, x->props.header_len);
 	iph = ipv6_hdr(skb);
 
+	skb_set_mac_header(skb, offsetof(struct ipv6hdr, nexthdr));
 	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
 	top_iph = ipv6_hdr(skb);
-	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
-	skb->network_header   += offsetof(struct ipv6hdr, nexthdr);
 
 	top_iph->version = 6;
 	if (xdst->route->ops->family == AF_INET6) {
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 30f3236..aeb0607 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -244,7 +244,7 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
 
-	top_iph = (struct ipv6hdr *)skb->data;
+	top_iph = ipv6_hdr(skb);
 	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 
 	return 0;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 8c85211..9847bae 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -76,8 +76,6 @@ int xfrm_output(struct sk_buff *skb)
 
 		spin_unlock_bh(&x->lock);
 
-		skb_reset_network_header(skb);
-
 		if (!(skb->dst = dst_pop(dst))) {
 			err = -EHOSTUNREACH;
 			goto error_nolock;
