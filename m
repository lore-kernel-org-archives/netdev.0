From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 15/24] [IPSEC]: Separate inner/outer mode processing on output
Date: Wed, 07 Nov 2007 22:08:31 +0800
Message-ID: <E1Ipla3-0001Hs-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3771 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758133AbXKGO0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:26:40 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Separate inner/outer mode processing on output

With inter-family transforms the inner mode differs from the outer mode.
Attempting to handle both sides from the same function means that it
needs to handle both IPv4 and IPv6 which creates duplication and confusion.

This patch separates the two parts on the output path so that each function
deals with one family only.

In particular, the functions xfrm4_extract_output/xfrm6_extract_output
moves the pertinent fields from the IPv4/IPv6 IP headers into a neutral
format stored in skb->cb.  This is then used by the outer mode output
functions to write the outer IP header.  In this way the output function
no longer has to know about the inner address family.

Since the extract functions are only called by tunnel modes (the only
modes that can support inter-family transforms), I've also moved the
xfrm*_tunnel_check_size calls into them.  This allows the correct ICMP
message to be sent as opposed to now where you might call icmp_send with
an IPv6 packet and vice versa.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h           |   51 ++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/xfrm4_mode_beet.c   |   15 ++++++++++--
 net/ipv4/xfrm4_mode_tunnel.c |   37 +++++++++----------------------
 net/ipv4/xfrm4_output.c      |   41 +++++++++++++++++++++++++---------
 net/ipv4/xfrm4_state.c       |   17 ++++++++++++++
 net/ipv6/xfrm6_mode_beet.c   |   28 +++++++++++------------
 net/ipv6/xfrm6_mode_tunnel.c |   31 ++++++++------------------
 net/ipv6/xfrm6_output.c      |   39 +++++++++++++++++++++++++-------
 net/ipv6/xfrm6_state.c       |   18 +++++++++++++++
 9 files changed, 193 insertions(+), 84 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4178c2b..9115baa 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -257,6 +257,7 @@ extern int __xfrm_state_delete(struct xfrm_state *x);
 
 struct xfrm_state_afinfo {
 	unsigned int		family;
+	unsigned int		proto;
 	struct module		*owner;
 	struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
@@ -267,6 +268,8 @@ struct xfrm_state_afinfo {
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
 	int			(*output)(struct sk_buff *skb);
+	int			(*extract_output)(struct xfrm_state *x,
+						  struct sk_buff *skb);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -312,7 +315,18 @@ struct xfrm_mode {
 	 * header.  The value of the network header will always point
 	 * to the top IP header while skb->data will point to the payload.
 	 */
-	int (*output)(struct xfrm_state *x,struct sk_buff *skb);
+	int (*output2)(struct xfrm_state *x,struct sk_buff *skb);
+
+	/*
+	 * This is the actual output entry point.
+	 *
+	 * For transport mode and equivalent this would be identical to
+	 * output2 (which does not need to be set).  While tunnel mode
+	 * and equivalent would set this to a tunnel encapsulation function
+	 * (xfrm4_prepare_output or xfrm6_prepare_output) that would in turn
+	 * call output2.
+	 */
+	int (*output)(struct xfrm_state *x, struct sk_buff *skb);
 
 	struct xfrm_state_afinfo *afinfo;
 	struct module *owner;
@@ -454,6 +468,35 @@ struct xfrm_skb_cb {
 
 #define XFRM_SKB_CB(__skb) ((struct xfrm_skb_cb *)&((__skb)->cb[0]))
 
+/*
+ * This structure is used by the afinfo prepare_input/prepare_output functions
+ * to transmit header information to the mode input/output functions.
+ */
+struct xfrm_mode_skb_cb {
+	union {
+		struct inet_skb_parm h4;
+		struct inet6_skb_parm h6;
+	} header;
+
+	/* Copied from header for IPv4, always set to zero and DF for IPv6. */
+	__be16 id;
+	__be16 frag_off;
+
+	/* TOS for IPv4, class for IPv6. */
+	u8 tos;
+
+	/* TTL for IPv4, hop limitfor IPv6. */
+	u8 ttl;
+
+	/* Protocol for IPv4, NH for IPv6. */
+	u8 protocol;
+
+	/* Used by IPv6 only, zero for IPv4. */
+	u8 flow_lbl[3];
+};
+
+#define XFRM_MODE_SKB_CB(__skb) ((struct xfrm_mode_skb_cb *)&((__skb)->cb[0]))
+
 /* Audit Information */
 struct xfrm_audit
 {
@@ -1051,6 +1094,7 @@ extern void xfrm_replay_notify(struct xfrm_state *x, int event);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_output(struct sk_buff *skb);
+extern int xfrm4_extract_header(struct sk_buff *skb);
 extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 			   int encap_type);
 extern int xfrm4_rcv(struct sk_buff *skb);
@@ -1060,9 +1104,12 @@ static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 	return xfrm4_rcv_encap(skb, nexthdr, spi, 0);
 }
 
+extern int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
+extern int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
+extern int xfrm6_extract_header(struct sk_buff *skb);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
 extern int xfrm6_rcv(struct sk_buff *skb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
@@ -1072,6 +1119,8 @@ extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short
 extern __be32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
 extern void xfrm6_tunnel_free_spi(xfrm_address_t *saddr);
 extern __be32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr);
+extern int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
+extern int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_output(struct sk_buff *skb);
 extern int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 				 u8 **prevhdr);
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index e42e122..94842ad 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -43,7 +43,17 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iph) - hdrlen);
 
 	top_iph = ip_hdr(skb);
-	memmove(top_iph, iph, sizeof(*iph));
+
+	top_iph->ihl = 5;
+	top_iph->version = 4;
+
+	top_iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
+	top_iph->tos = XFRM_MODE_SKB_CB(skb)->tos;
+
+	top_iph->id = XFRM_MODE_SKB_CB(skb)->id;
+	top_iph->frag_off = XFRM_MODE_SKB_CB(skb)->frag_off;
+	top_iph->ttl = XFRM_MODE_SKB_CB(skb)->ttl;
+
 	if (unlikely(optlen)) {
 		BUG_ON(optlen < 0);
 
@@ -111,7 +121,8 @@ out:
 
 static struct xfrm_mode xfrm4_beet_mode = {
 	.input = xfrm4_beet_input,
-	.output = xfrm4_beet_output,
+	.output2 = xfrm4_beet_output,
+	.output = xfrm4_prepare_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_BEET,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 68a9f56..cc8bbb2 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -36,53 +36,37 @@ static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
 static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
-	struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
-	struct iphdr *iph, *top_iph;
+	struct iphdr *top_iph;
 	int flags;
 
-	iph = ip_hdr(skb);
-
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
-	skb->transport_header = skb->network_header + sizeof(*iph);
+	skb->transport_header = skb->network_header + sizeof(*top_iph);
 	top_iph = ip_hdr(skb);
 
 	top_iph->ihl = 5;
 	top_iph->version = 4;
 
-	flags = x->props.flags;
+	top_iph->protocol = x->inner_mode->afinfo->proto;
 
 	/* DS disclosed */
-	if (xdst->route->ops->family == AF_INET) {
-		top_iph->protocol = IPPROTO_IPIP;
-		top_iph->tos = INET_ECN_encapsulate(iph->tos, iph->tos);
-		top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
-			0 : (iph->frag_off & htons(IP_DF));
-	}
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-	else {
-		struct ipv6hdr *ipv6h = (struct ipv6hdr*)iph;
-		top_iph->protocol = IPPROTO_IPV6;
-		top_iph->tos = INET_ECN_encapsulate(iph->tos, ipv6_get_dsfield(ipv6h));
-		top_iph->frag_off = 0;
-	}
-#endif
+	top_iph->tos = INET_ECN_encapsulate(XFRM_MODE_SKB_CB(skb)->tos,
+					    XFRM_MODE_SKB_CB(skb)->tos);
 
+	flags = x->props.flags;
 	if (flags & XFRM_STATE_NOECN)
 		IP_ECN_clear(top_iph);
 
-	if (!top_iph->frag_off)
-		__ip_select_ident(top_iph, dst->child, 0);
+	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
+			    0 : XFRM_MODE_SKB_CB(skb)->frag_off;
+	ip_select_ident(top_iph, dst->child, NULL);
 
 	top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
 
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
 
-	skb->protocol = htons(ETH_P_IP);
-
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	return 0;
 }
 
@@ -136,7 +120,8 @@ out:
 
 static struct xfrm_mode xfrm4_tunnel_mode = {
 	.input = xfrm4_tunnel_input,
-	.output = xfrm4_tunnel_output,
+	.output2 = xfrm4_tunnel_output,
+	.output = xfrm4_prepare_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index c4a7156..13fd113 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -8,11 +8,12 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#include <linux/compiler.h>
 #include <linux/if_ether.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter_ipv4.h>
+#include <net/dst.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/icmp.h>
@@ -25,8 +26,6 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	if (IPCB(skb)->flags & IPSKB_XFRM_TUNNEL_SIZE)
 		goto out;
 
-	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
-
 	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->local_df)
 		goto out;
 
@@ -40,19 +39,39 @@ out:
 	return ret;
 }
 
+int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err;
+
+	err = xfrm4_tunnel_check_size(skb);
+	if (err)
+		return err;
+
+	return xfrm4_extract_header(skb);
+}
+
+int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err;
+
+	err = x->inner_mode->afinfo->extract_output(x, skb);
+	if (err)
+		return err;
+
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
+
+	skb->protocol = htons(ETH_P_IP);
+
+	return x->outer_mode->output2(x, skb);
+}
+EXPORT_SYMBOL(xfrm4_prepare_output);
+
 static inline int xfrm4_output_one(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct iphdr *iph;
 	int err;
 
-	if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
-		err = xfrm4_tunnel_check_size(skb);
-		if (err)
-			goto error_nolock;
-	}
-
 	err = xfrm_output(skb);
 	if (err)
 		goto error_nolock;
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 13d54a1..e6030e7 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -47,12 +47,29 @@ __xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 	x->props.family = AF_INET;
 }
 
+int xfrm4_extract_header(struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	XFRM_MODE_SKB_CB(skb)->id = iph->id;
+	XFRM_MODE_SKB_CB(skb)->frag_off = iph->frag_off;
+	XFRM_MODE_SKB_CB(skb)->tos = iph->tos;
+	XFRM_MODE_SKB_CB(skb)->ttl = iph->ttl;
+	XFRM_MODE_SKB_CB(skb)->protocol = iph->protocol;
+	memset(XFRM_MODE_SKB_CB(skb)->flow_lbl, 0,
+	       sizeof(XFRM_MODE_SKB_CB(skb)->flow_lbl));
+
+	return 0;
+}
+
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
+	.proto			= IPPROTO_IPIP,
 	.owner			= THIS_MODULE,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.output			= xfrm4_output,
+	.extract_output		= xfrm4_extract_output,
 };
 
 void __init xfrm4_state_init(void)
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 2bfb4f0..4988ed9 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -25,25 +25,24 @@
  */
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ipv6hdr *iph, *top_iph;
-	u8 *prevhdr;
-	int hdr_len;
+	struct ipv6hdr *top_iph;
 
-	iph = ipv6_hdr(skb);
-
-	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
-
-	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_set_network_header(skb, -x->props.header_len);
-	skb->transport_header = skb->network_header + hdr_len;
-	__skb_pull(skb, hdr_len);
-
+	skb->mac_header = skb->network_header +
+			  offsetof(struct ipv6hdr, nexthdr);
+	skb->transport_header = skb->network_header + sizeof(*top_iph);
 	top_iph = ipv6_hdr(skb);
-	memmove(top_iph, iph, hdr_len);
 
+	top_iph->version = 6;
+
+	memcpy(top_iph->flow_lbl, XFRM_MODE_SKB_CB(skb)->flow_lbl,
+	       sizeof(top_iph->flow_lbl));
+	top_iph->nexthdr = XFRM_MODE_SKB_CB(skb)->protocol;
+
+	ipv6_change_dsfield(top_iph, 0, XFRM_MODE_SKB_CB(skb)->tos);
+	top_iph->hop_limit = XFRM_MODE_SKB_CB(skb)->ttl;
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
-
 	return 0;
 }
 
@@ -76,7 +75,8 @@ out:
 
 static struct xfrm_mode xfrm6_beet_mode = {
 	.input = xfrm6_beet_input,
-	.output = xfrm6_beet_output,
+	.output2 = xfrm6_beet_output,
+	.output = xfrm6_prepare_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_BEET,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 9a43ea7..d45ce5d 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -38,33 +38,22 @@ static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
-	struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
-	struct ipv6hdr *iph, *top_iph;
+	struct ipv6hdr *top_iph;
 	int dsfield;
 
-	iph = ipv6_hdr(skb);
-
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct ipv6hdr, nexthdr);
-	skb->transport_header = skb->network_header + sizeof(*iph);
+	skb->transport_header = skb->network_header + sizeof(*top_iph);
 	top_iph = ipv6_hdr(skb);
 
 	top_iph->version = 6;
-	if (xdst->route->ops->family == AF_INET6) {
-		top_iph->priority = iph->priority;
-		top_iph->flow_lbl[0] = iph->flow_lbl[0];
-		top_iph->flow_lbl[1] = iph->flow_lbl[1];
-		top_iph->flow_lbl[2] = iph->flow_lbl[2];
-		top_iph->nexthdr = IPPROTO_IPV6;
-	} else {
-		top_iph->priority = 0;
-		top_iph->flow_lbl[0] = 0;
-		top_iph->flow_lbl[1] = 0;
-		top_iph->flow_lbl[2] = 0;
-		top_iph->nexthdr = IPPROTO_IPIP;
-	}
-	dsfield = ipv6_get_dsfield(top_iph);
+
+	memcpy(top_iph->flow_lbl, XFRM_MODE_SKB_CB(skb)->flow_lbl,
+	       sizeof(top_iph->flow_lbl));
+	top_iph->nexthdr = x->inner_mode->afinfo->proto;
+
+	dsfield = XFRM_MODE_SKB_CB(skb)->tos;
 	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
 	if (x->props.flags & XFRM_STATE_NOECN)
 		dsfield &= ~INET_ECN_MASK;
@@ -72,7 +61,6 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
-	skb->protocol = htons(ETH_P_IPV6);
 	return 0;
 }
 
@@ -116,7 +104,8 @@ out:
 
 static struct xfrm_mode xfrm6_tunnel_mode = {
 	.input = xfrm6_tunnel_input,
-	.output = xfrm6_tunnel_output,
+	.output2 = xfrm6_tunnel_output,
+	.output = xfrm6_prepare_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6569767..bc2e80e 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -10,10 +10,12 @@
  */
 
 #include <linux/if_ether.h>
-#include <linux/compiler.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter_ipv6.h>
+#include <net/dst.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
@@ -43,19 +45,38 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 	return ret;
 }
 
+int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err;
+
+	err = xfrm6_tunnel_check_size(skb);
+	if (err)
+		return err;
+
+	return xfrm6_extract_header(skb);
+}
+
+int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err;
+
+	err = x->inner_mode->afinfo->extract_output(x, skb);
+	if (err)
+		return err;
+
+	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
+
+	skb->protocol = htons(ETH_P_IPV6);
+
+	return x->outer_mode->output2(x, skb);
+}
+EXPORT_SYMBOL(xfrm6_prepare_output);
+
 static inline int xfrm6_output_one(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct ipv6hdr *iph;
 	int err;
 
-	if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
-		err = xfrm6_tunnel_check_size(skb);
-		if (err)
-			goto error_nolock;
-	}
-
 	err = xfrm_output(skb);
 	if (err)
 		goto error_nolock;
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index b392bee..98b05f4 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -14,6 +14,7 @@
 #include <net/xfrm.h>
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
+#include <net/dsfield.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 
@@ -168,13 +169,30 @@ __xfrm6_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n)
 	return 0;
 }
 
+int xfrm6_extract_header(struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
+	XFRM_MODE_SKB_CB(skb)->id = 0;
+	XFRM_MODE_SKB_CB(skb)->frag_off = htons(IP_DF);
+	XFRM_MODE_SKB_CB(skb)->tos = ipv6_get_dsfield(iph);
+	XFRM_MODE_SKB_CB(skb)->ttl = iph->hop_limit;
+	XFRM_MODE_SKB_CB(skb)->protocol = iph->nexthdr;
+	memcpy(XFRM_MODE_SKB_CB(skb)->flow_lbl, iph->flow_lbl,
+	       sizeof(XFRM_MODE_SKB_CB(skb)->flow_lbl));
+
+	return 0;
+}
+
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
+	.proto			= IPPROTO_IPV6,
 	.owner			= THIS_MODULE,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.tmpl_sort		= __xfrm6_tmpl_sort,
 	.state_sort		= __xfrm6_state_sort,
 	.output			= xfrm6_output,
+	.extract_output		= xfrm6_extract_output,
 };
 
 void __init xfrm6_state_init(void)
