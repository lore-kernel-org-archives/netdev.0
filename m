From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 16/24] [IPSEC]: Separate inner/outer mode processing on input
Date: Wed, 07 Nov 2007 22:08:32 +0800
Message-ID: <E1Ipla4-0001I0-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3788 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758193AbXKGO1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:27:02 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Separate inner/outer mode processing on input

With inter-family transforms the inner mode differs from the outer mode.
Attempting to handle both sides from the same function means that it
needs to handle both IPv4 and IPv6 which creates duplication and confusion.

This patch separates the two parts on the input path so that each function
deals with one family only.

In particular, the functions xfrm4_extract_inut/xfrm6_extract_inut
moves the pertinent fields from the IPv4/IPv6 IP headers into a neutral
format stored in skb->cb.  This is then used by the inner mode input
functions to modify the inner IP header.  In this way the input function
no longer has to know about the outer address family.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h           |   27 +++++++++++++++++
 net/ipv4/xfrm4_input.c       |    7 +++-
 net/ipv4/xfrm4_mode_beet.c   |   67 +++++++++++++++++++++++++------------------
 net/ipv4/xfrm4_mode_tunnel.c |   44 ++++++----------------------
 net/ipv4/xfrm4_state.c       |    2 +
 net/ipv6/xfrm6_input.c       |    7 +++-
 net/ipv6/xfrm6_mode_beet.c   |   36 +++++++++++++++--------
 net/ipv6/xfrm6_mode_tunnel.c |   31 +++++--------------
 net/ipv6/xfrm6_output.c      |    1 
 net/ipv6/xfrm6_state.c       |    5 ++-
 net/xfrm/xfrm_input.c        |   13 ++++++++
 11 files changed, 141 insertions(+), 99 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9115baa..448a57f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -258,6 +258,7 @@ extern int __xfrm_state_delete(struct xfrm_state *x);
 struct xfrm_state_afinfo {
 	unsigned int		family;
 	unsigned int		proto;
+	unsigned int		eth_proto;
 	struct module		*owner;
 	struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
@@ -268,6 +269,8 @@ struct xfrm_state_afinfo {
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
 	int			(*output)(struct sk_buff *skb);
+	int			(*extract_input)(struct xfrm_state *x,
+						 struct sk_buff *skb);
 	int			(*extract_output)(struct xfrm_state *x,
 						  struct sk_buff *skb);
 };
@@ -302,6 +305,27 @@ extern int xfrm_register_type(struct xfrm_type *type, unsigned short family);
 extern int xfrm_unregister_type(struct xfrm_type *type, unsigned short family);
 
 struct xfrm_mode {
+	/*
+	 * Remove encapsulation header.
+	 *
+	 * The IP header will be moved over the top of the encapsulation
+	 * header.
+	 *
+	 * On entry, the transport header shall point to where the IP header
+	 * should be and the network header shall be set to where the IP
+	 * header currently is.  skb->data shall point to the start of the
+	 * payload.
+	 */
+	int (*input2)(struct xfrm_state *x, struct sk_buff *skb);
+
+	/*
+	 * This is the actual input entry point.
+	 *
+	 * For transport mode and equivalent this would be identical to
+	 * input2 (which does not need to be set).  While tunnel mode
+	 * and equivalent would set this to the tunnel encapsulation function
+	 * xfrm4_prepare_input that would in turn call input2.
+	 */
 	int (*input)(struct xfrm_state *x, struct sk_buff *skb);
 
 	/*
@@ -1093,8 +1117,10 @@ extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
+extern int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm_output(struct sk_buff *skb);
 extern int xfrm4_extract_header(struct sk_buff *skb);
+extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 			   int encap_type);
 extern int xfrm4_rcv(struct sk_buff *skb);
@@ -1110,6 +1136,7 @@ extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm6_extract_header(struct sk_buff *skb);
+extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
 extern int xfrm6_rcv(struct sk_buff *skb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 5e95c8a..c0323d0 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -16,6 +16,11 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 
+int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	return xfrm4_extract_header(skb);
+}
+
 #ifdef CONFIG_NETFILTER
 static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 {
@@ -91,7 +96,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 
 		xfrm_vec[xfrm_nr++] = x;
 
-		if (x->outer_mode->input(x, skb))
+		if (x->inner_mode->input(x, skb))
 			goto drop;
 
 		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 94842ad..e093a7b 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -17,6 +17,21 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 
+static void xfrm4_beet_make_header(struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	iph->ihl = 5;
+	iph->version = 4;
+
+	iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
+	iph->tos = XFRM_MODE_SKB_CB(skb)->tos;
+
+	iph->id = XFRM_MODE_SKB_CB(skb)->id;
+	iph->frag_off = XFRM_MODE_SKB_CB(skb)->frag_off;
+	iph->ttl = XFRM_MODE_SKB_CB(skb)->ttl;
+}
+
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per draft-nikander-esp-beet-mode-06.txt.
@@ -40,20 +55,12 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 			  offsetof(struct iphdr, protocol);
 	skb->transport_header = skb->network_header + sizeof(*iph);
 
+	xfrm4_beet_make_header(skb);
+
 	ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iph) - hdrlen);
 
 	top_iph = ip_hdr(skb);
 
-	top_iph->ihl = 5;
-	top_iph->version = 4;
-
-	top_iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
-	top_iph->tos = XFRM_MODE_SKB_CB(skb)->tos;
-
-	top_iph->id = XFRM_MODE_SKB_CB(skb)->id;
-	top_iph->frag_off = XFRM_MODE_SKB_CB(skb)->frag_off;
-	top_iph->ttl = XFRM_MODE_SKB_CB(skb)->ttl;
-
 	if (unlikely(optlen)) {
 		BUG_ON(optlen < 0);
 
@@ -75,43 +82,46 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(skb);
-	int phlen = 0;
+	struct iphdr *iph;
 	int optlen = 0;
-	u8 ph_nexthdr = 0;
 	int err = -EINVAL;
 
-	if (unlikely(iph->protocol == IPPROTO_BEETPH)) {
+	if (unlikely(XFRM_MODE_SKB_CB(skb)->protocol == IPPROTO_BEETPH)) {
 		struct ip_beet_phdr *ph;
+		int phlen;
 
 		if (!pskb_may_pull(skb, sizeof(*ph)))
 			goto out;
-		ph = (struct ip_beet_phdr *)(ipip_hdr(skb) + 1);
+
+		ph = (struct ip_beet_phdr *)skb->data;
 
 		phlen = sizeof(*ph) + ph->padlen;
 		optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
 		if (optlen < 0 || optlen & 3 || optlen > 250)
 			goto out;
 
-		if (!pskb_may_pull(skb, phlen + optlen))
-			goto out;
-		skb->len -= phlen + optlen;
+		XFRM_MODE_SKB_CB(skb)->protocol = ph->nexthdr;
 
-		ph_nexthdr = ph->nexthdr;
+		if (!pskb_may_pull(skb, phlen));
+			goto out;
+		__skb_pull(skb, phlen);
 	}
 
-	skb_set_network_header(skb, phlen - sizeof(*iph));
-	memmove(skb_network_header(skb), iph, sizeof(*iph));
-	skb_set_transport_header(skb, phlen + optlen);
-	skb->data = skb_transport_header(skb);
+	skb_push(skb, sizeof(*iph));
+	skb_reset_network_header(skb);
+
+	memmove(skb->data - skb->mac_len, skb_mac_header(skb),
+		skb->mac_len);
+	skb_set_mac_header(skb, -skb->mac_len);
+
+	xfrm4_beet_make_header(skb);
 
 	iph = ip_hdr(skb);
-	iph->ihl = (sizeof(*iph) + optlen) / 4;
-	iph->tot_len = htons(skb->len + iph->ihl * 4);
+
+	iph->ihl += optlen / 4;
+	iph->tot_len = htons(skb->len);
 	iph->daddr = x->sel.daddr.a4;
 	iph->saddr = x->sel.saddr.a4;
-	if (ph_nexthdr)
-		iph->protocol = ph_nexthdr;
 	iph->check = 0;
 	iph->check = ip_fast_csum(skb_network_header(skb), iph->ihl);
 	err = 0;
@@ -120,7 +130,8 @@ out:
 }
 
 static struct xfrm_mode xfrm4_beet_mode = {
-	.input = xfrm4_beet_input,
+	.input2 = xfrm4_beet_input,
+	.input = xfrm_prepare_input,
 	.output2 = xfrm4_beet_output,
 	.output = xfrm4_prepare_output,
 	.owner = THIS_MODULE,
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index cc8bbb2..aa335db 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -16,19 +16,12 @@
 
 static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
 {
-	struct iphdr *outer_iph = ip_hdr(skb);
 	struct iphdr *inner_iph = ipip_hdr(skb);
 
-	if (INET_ECN_is_ce(outer_iph->tos))
+	if (INET_ECN_is_ce(XFRM_MODE_SKB_CB(skb)->tos))
 		IP_ECN_set_ce(inner_iph);
 }
 
-static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
-{
-	if (INET_ECN_is_ce(iph->tos))
-		IP6_ECN_set_ce(ipv6_hdr(skb));
-}
-
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per RFC 2401.
@@ -72,20 +65,11 @@ static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm4_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(skb);
 	const unsigned char *old_mac;
 	int err = -EINVAL;
 
-	switch (iph->protocol){
-		case IPPROTO_IPIP:
-			break;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-		case IPPROTO_IPV6:
-			break;
-#endif
-		default:
-			goto out;
-	}
+	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPIP)
+		goto out;
 
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto out;
@@ -94,20 +78,11 @@ static int xfrm4_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 		goto out;
 
-	iph = ip_hdr(skb);
-	if (iph->protocol == IPPROTO_IPIP) {
-		if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-			ipv4_copy_dscp(ipv4_get_dsfield(iph), ipip_hdr(skb));
-		if (!(x->props.flags & XFRM_STATE_NOECN))
-			ipip_ecn_decapsulate(skb);
-	}
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-	else {
-		if (!(x->props.flags & XFRM_STATE_NOECN))
-			ipip6_ecn_decapsulate(iph, skb);
-		skb->protocol = htons(ETH_P_IPV6);
-	}
-#endif
+	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+		ipv4_copy_dscp(XFRM_MODE_SKB_CB(skb)->tos, ipip_hdr(skb));
+	if (!(x->props.flags & XFRM_STATE_NOECN))
+		ipip_ecn_decapsulate(skb);
+
 	old_mac = skb_mac_header(skb);
 	skb_set_mac_header(skb, -skb->mac_len);
 	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
@@ -119,7 +94,8 @@ out:
 }
 
 static struct xfrm_mode xfrm4_tunnel_mode = {
-	.input = xfrm4_tunnel_input,
+	.input2 = xfrm4_tunnel_input,
+	.input = xfrm_prepare_input,
 	.output2 = xfrm4_tunnel_output,
 	.output = xfrm4_prepare_output,
 	.owner = THIS_MODULE,
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index e6030e7..85f04b7 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -65,10 +65,12 @@ int xfrm4_extract_header(struct sk_buff *skb)
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
 	.proto			= IPPROTO_IPIP,
+	.eth_proto		= htons(ETH_P_IP),
 	.owner			= THIS_MODULE,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.output			= xfrm4_output,
+	.extract_input		= xfrm4_extract_input,
 	.extract_output		= xfrm4_extract_output,
 };
 
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 5157837..c458d0a 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -16,6 +16,11 @@
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
+int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	return xfrm6_extract_header(skb);
+}
+
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
 	int err;
@@ -68,7 +73,7 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 
 		xfrm_vec[xfrm_nr++] = x;
 
-		if (x->outer_mode->input(x, skb))
+		if (x->inner_mode->input(x, skb))
 			goto drop;
 
 		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 4988ed9..0527d11 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -19,6 +19,20 @@
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
+static void xfrm6_beet_make_header(struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
+	iph->version = 6;
+
+	memcpy(iph->flow_lbl, XFRM_MODE_SKB_CB(skb)->flow_lbl,
+	       sizeof(iph->flow_lbl));
+	iph->nexthdr = XFRM_MODE_SKB_CB(skb)->protocol;
+
+	ipv6_change_dsfield(iph, 0, XFRM_MODE_SKB_CB(skb)->tos);
+	iph->hop_limit = XFRM_MODE_SKB_CB(skb)->ttl;
+}
+
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per draft-nikander-esp-beet-mode-06.txt.
@@ -31,16 +45,11 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	skb->mac_header = skb->network_header +
 			  offsetof(struct ipv6hdr, nexthdr);
 	skb->transport_header = skb->network_header + sizeof(*top_iph);
-	top_iph = ipv6_hdr(skb);
 
-	top_iph->version = 6;
+	xfrm6_beet_make_header(skb);
 
-	memcpy(top_iph->flow_lbl, XFRM_MODE_SKB_CB(skb)->flow_lbl,
-	       sizeof(top_iph->flow_lbl));
-	top_iph->nexthdr = XFRM_MODE_SKB_CB(skb)->protocol;
+	top_iph = ipv6_hdr(skb);
 
-	ipv6_change_dsfield(top_iph, 0, XFRM_MODE_SKB_CB(skb)->tos);
-	top_iph->hop_limit = XFRM_MODE_SKB_CB(skb)->ttl;
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
 	return 0;
@@ -51,19 +60,21 @@ static int xfrm6_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 	struct ipv6hdr *ip6h;
 	const unsigned char *old_mac;
 	int size = sizeof(struct ipv6hdr);
-	int err = -EINVAL;
+	int err;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+	err = skb_cow_head(skb, size + skb->mac_len);
+	if (err)
 		goto out;
 
-	skb_push(skb, size);
-	memmove(skb->data, skb_network_header(skb), size);
+	__skb_push(skb, size);
 	skb_reset_network_header(skb);
 
 	old_mac = skb_mac_header(skb);
 	skb_set_mac_header(skb, -skb->mac_len);
 	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
 
+	xfrm6_beet_make_header(skb);
+
 	ip6h = ipv6_hdr(skb);
 	ip6h->payload_len = htons(skb->len - size);
 	ipv6_addr_copy(&ip6h->daddr, (struct in6_addr *) &x->sel.daddr.a6);
@@ -74,7 +85,8 @@ out:
 }
 
 static struct xfrm_mode xfrm6_beet_mode = {
-	.input = xfrm6_beet_input,
+	.input2 = xfrm6_beet_input,
+	.input = xfrm_prepare_input,
 	.output2 = xfrm6_beet_output,
 	.output = xfrm6_prepare_output,
 	.owner = THIS_MODULE,
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index d45ce5d..f7d0d66 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -25,12 +25,6 @@ static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
 		IP6_ECN_set_ce(inner_iph);
 }
 
-static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
-{
-	if (INET_ECN_is_ce(ipv6_get_dsfield(ipv6_hdr(skb))))
-			IP_ECN_set_ce(ipip_hdr(skb));
-}
-
 /* Add encapsulation header.
  *
  * The top IP header will be constructed per RFC 2401.
@@ -68,10 +62,8 @@ static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = -EINVAL;
 	const unsigned char *old_mac;
-	const unsigned char *nh = skb_network_header(skb);
 
-	if (nh[IP6CB(skb)->nhoff] != IPPROTO_IPV6 &&
-	    nh[IP6CB(skb)->nhoff] != IPPROTO_IPIP)
+	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPV6)
 		goto out;
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
@@ -80,18 +72,12 @@ static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 		goto out;
 
-	nh = skb_network_header(skb);
-	if (nh[IP6CB(skb)->nhoff] == IPPROTO_IPV6) {
-		if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-			ipv6_copy_dscp(ipv6_get_dsfield(ipv6_hdr(skb)),
-				       ipipv6_hdr(skb));
-		if (!(x->props.flags & XFRM_STATE_NOECN))
-			ipip6_ecn_decapsulate(skb);
-	} else {
-		if (!(x->props.flags & XFRM_STATE_NOECN))
-			ip6ip_ecn_decapsulate(skb);
-		skb->protocol = htons(ETH_P_IP);
-	}
+	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+		ipv6_copy_dscp(ipv6_get_dsfield(ipv6_hdr(skb)),
+			       ipipv6_hdr(skb));
+	if (!(x->props.flags & XFRM_STATE_NOECN))
+		ipip6_ecn_decapsulate(skb);
+
 	old_mac = skb_mac_header(skb);
 	skb_set_mac_header(skb, -skb->mac_len);
 	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
@@ -103,7 +89,8 @@ out:
 }
 
 static struct xfrm_mode xfrm6_tunnel_mode = {
-	.input = xfrm6_tunnel_input,
+	.input2 = xfrm6_tunnel_input,
+	.input = xfrm_prepare_input,
 	.output2 = xfrm6_tunnel_output,
 	.output = xfrm6_prepare_output,
 	.owner = THIS_MODULE,
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index bc2e80e..c45050c 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -53,6 +53,7 @@ int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (err)
 		return err;
 
+	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 	return xfrm6_extract_header(skb);
 }
 
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 98b05f4..90fef0a 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -177,7 +177,8 @@ int xfrm6_extract_header(struct sk_buff *skb)
 	XFRM_MODE_SKB_CB(skb)->frag_off = htons(IP_DF);
 	XFRM_MODE_SKB_CB(skb)->tos = ipv6_get_dsfield(iph);
 	XFRM_MODE_SKB_CB(skb)->ttl = iph->hop_limit;
-	XFRM_MODE_SKB_CB(skb)->protocol = iph->nexthdr;
+	XFRM_MODE_SKB_CB(skb)->protocol =
+		skb_network_header(skb)[IP6CB(skb)->nhoff];
 	memcpy(XFRM_MODE_SKB_CB(skb)->flow_lbl, iph->flow_lbl,
 	       sizeof(XFRM_MODE_SKB_CB(skb)->flow_lbl));
 
@@ -187,11 +188,13 @@ int xfrm6_extract_header(struct sk_buff *skb)
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.proto			= IPPROTO_IPV6,
+	.eth_proto		= htons(ETH_P_IPV6),
 	.owner			= THIS_MODULE,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.tmpl_sort		= __xfrm6_tmpl_sort,
 	.state_sort		= __xfrm6_state_sort,
 	.output			= xfrm6_output,
+	.extract_input		= xfrm6_extract_input,
 	.extract_output		= xfrm6_extract_output,
 };
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index cb97fda..4c803f7 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -81,6 +81,19 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 }
 EXPORT_SYMBOL(xfrm_parse_spi);
 
+int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err;
+
+	err = x->outer_mode->afinfo->extract_input(x, skb);
+	if (err)
+		return err;
+
+	skb->protocol = x->inner_mode->afinfo->eth_proto;
+	return x->inner_mode->input2(x, skb);
+}
+EXPORT_SYMBOL(xfrm_prepare_input);
+
 void __init xfrm_input_init(void)
 {
 	secpath_cachep = kmem_cache_create("secpath_cache",
