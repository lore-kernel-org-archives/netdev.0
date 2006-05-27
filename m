From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/4] [IPSEC] xfrm: Abstract out encapsulation modes
Date: Sat, 27 May 2006 21:34:25 +1000
Message-ID: <20060527113425.GB4737@gondor.apana.org.au>
References: <20060527113236.GA4203@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SkvwRMAIpAhPCcCJ"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:17164 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751476AbWE0Le2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 07:34:28 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060527113236.GA4203@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[IPSEC] xfrm: Abstract out encapsulation modes

This patch adds the structure xfrm_mode.  It is meant to represent
the operations carried out by transport/tunnel modes.

By doing this we allow additional encapsulation modes to be added
without clogging up the xfrm_input/xfrm_output paths.

Candidate modes include 4-to-6 tunnel mode, 6-to-4 tunnel mode, and
BEET modes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p2.patch"

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -118,6 +118,10 @@ enum
 	XFRM_SHARE_UNIQUE	/* Use once */
 };
 
+#define XFRM_MODE_TRANSPORT 0
+#define XFRM_MODE_TUNNEL 1
+#define XFRM_MODE_MAX 2
+
 /* Netlink configuration messages.  */
 enum {
 	XFRM_MSG_BASE = 0x10,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -20,6 +20,8 @@
 #include <net/ip6_fib.h>
 
 #define XFRM_ALIGN8(len)	(((len) + 7) & ~7)
+#define MODULE_ALIAS_XFRM_MODE(family, encap) \
+	MODULE_ALIAS("xfrm-mode-" __stringify(family) "-" __stringify(encap))
 
 extern struct sock *xfrm_nl;
 extern u32 sysctl_xfrm_aevent_etime;
@@ -164,6 +166,7 @@ struct xfrm_state
 	/* Reference to data common to all the instances of this
 	 * transformer. */
 	struct xfrm_type	*type;
+	struct xfrm_mode	*mode;
 
 	/* Security context */
 	struct xfrm_sec_ctx	*security;
@@ -205,6 +208,7 @@ struct xfrm_dst;
 struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct xfrm_type	*type_map[256];
+	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(void);
 	int			(*dst_lookup)(struct xfrm_dst **dst, struct flowi *fl);
@@ -267,6 +271,19 @@ extern int xfrm_unregister_type(struct x
 extern struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family);
 extern void xfrm_put_type(struct xfrm_type *type);
 
+struct xfrm_mode {
+	int (*input)(struct xfrm_state *x, struct sk_buff *skb);
+	int (*output)(struct sk_buff *skb);
+
+	struct module *owner;
+	unsigned int encap;
+};
+
+extern int xfrm_register_mode(struct xfrm_mode *mode, int family);
+extern int xfrm_unregister_mode(struct xfrm_mode *mode, int family);
+extern struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family);
+extern void xfrm_put_mode(struct xfrm_mode *mode);
+
 struct xfrm_tmpl
 {
 /* id in template is interpreted as:
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -414,6 +414,24 @@ config INET_TUNNEL
 	tristate
 	default n
 
+config INET_XFRM_MODE_TRANSPORT
+	tristate "IP: IPsec transport mode"
+	default y
+	select XFRM
+	---help---
+	  Support for IPsec transport mode.
+
+	  If unsure, say Y.
+
+config INET_XFRM_MODE_TUNNEL
+	tristate "IP: IPsec tunnel mode"
+	default y
+	select XFRM
+	---help---
+	  Support for IPsec tunnel mode.
+
+	  If unsure, say Y.
+
 config INET_DIAG
 	tristate "INET: socket monitoring interface"
 	default y
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -24,6 +24,8 @@ obj-$(CONFIG_INET_ESP) += esp4.o
 obj-$(CONFIG_INET_IPCOMP) += ipcomp.o
 obj-$(CONFIG_INET_XFRM_TUNNEL) += xfrm4_tunnel.o
 obj-$(CONFIG_INET_TUNNEL) += tunnel4.o
+obj-$(CONFIG_INET_XFRM_MODE_TRANSPORT) += xfrm4_mode_transport.o
+obj-$(CONFIG_INET_XFRM_MODE_TUNNEL) += xfrm4_mode_tunnel.o
 obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_IP_ROUTE_MULTIPATH_RR) += multipath_rr.o
 obj-$(CONFIG_IP_ROUTE_MULTIPATH_RANDOM) += multipath_random.o
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -13,7 +13,6 @@
 #include <linux/string.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 
@@ -24,15 +23,6 @@ int xfrm4_rcv(struct sk_buff *skb)
 
 EXPORT_SYMBOL(xfrm4_rcv);
 
-static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
-{
-	struct iphdr *outer_iph = skb->nh.iph;
-	struct iphdr *inner_iph = skb->h.ipiph;
-
-	if (INET_ECN_is_ce(outer_iph->tos))
-		IP_ECN_set_ce(inner_iph);
-}
-
 static int xfrm4_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 *seq)
 {
 	switch (nexthdr) {
@@ -113,24 +103,10 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 
 		xfrm_vec[xfrm_nr++] = x;
 
-		iph = skb->nh.iph;
+		if (x->mode->input(x, skb))
+			goto drop;
 
 		if (x->props.mode) {
-			if (iph->protocol != IPPROTO_IPIP)
-				goto drop;
-			if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-				goto drop;
-			if (skb_cloned(skb) &&
-			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-				goto drop;
-			if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-				ipv4_copy_dscp(iph, skb->h.ipiph);
-			if (!(x->props.flags & XFRM_STATE_NOECN))
-				ipip_ecn_decapsulate(skb);
-			skb->mac.raw = memmove(skb->data - skb->mac_len,
-					       skb->mac.raw, skb->mac_len);
-			skb->nh.raw = skb->data;
-			memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -0,0 +1,69 @@
+/*
+ * xfrm4_mode_transport.c - Transport mode encapsulation for IPv4.
+ *
+ * Copyright (c) 2004-2006 Herbert Xu <herbert@gondor.apana.org.au>
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/stringify.h>
+#include <net/dst.h>
+#include <net/ip.h>
+#include <net/xfrm.h>
+
+/* Add encapsulation header.
+ *
+ * The IP header will be moved forward to make space for the encapsulation
+ * header.
+ *
+ * On exit, skb->h will be set to the start of the payload to be processed
+ * by x->type->output and skb->nh will be set to the top IP header.
+ */
+static int xfrm4_transport_output(struct sk_buff *skb)
+{
+	struct xfrm_state *x;
+	struct iphdr *iph;
+	int ihl;
+
+	iph = skb->nh.iph;
+	skb->h.ipiph = iph;
+
+	ihl = iph->ihl * 4;
+	skb->h.raw += ihl;
+
+	x = skb->dst->xfrm;
+	skb->nh.raw = memmove(skb_push(skb, x->props.header_len), iph, ihl);
+	return 0;
+}
+
+static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	return 0;
+}
+
+static struct xfrm_mode xfrm4_transport_mode = {
+	.input = xfrm4_transport_input,
+	.output = xfrm4_transport_output,
+	.owner = THIS_MODULE,
+	.encap = XFRM_MODE_TRANSPORT,
+};
+
+static int __init xfrm4_transport_init(void)
+{
+	return xfrm_register_mode(&xfrm4_transport_mode, AF_INET);
+}
+
+static void __exit xfrm4_transport_exit(void)
+{
+	int err;
+
+	err = xfrm_unregister_mode(&xfrm4_transport_mode, AF_INET);
+	BUG_ON(err);
+}
+
+module_init(xfrm4_transport_init);
+module_exit(xfrm4_transport_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_MODE(AF_INET, XFRM_MODE_TRANSPORT);
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -0,0 +1,125 @@
+/*
+ * xfrm4_mode_tunnel.c - Tunnel mode encapsulation for IPv4.
+ *
+ * Copyright (c) 2004-2006 Herbert Xu <herbert@gondor.apana.org.au>
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/stringify.h>
+#include <net/dst.h>
+#include <net/inet_ecn.h>
+#include <net/ip.h>
+#include <net/xfrm.h>
+
+static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
+{
+	struct iphdr *outer_iph = skb->nh.iph;
+	struct iphdr *inner_iph = skb->h.ipiph;
+
+	if (INET_ECN_is_ce(outer_iph->tos))
+		IP_ECN_set_ce(inner_iph);
+}
+
+/* Add encapsulation header.
+ *
+ * The top IP header will be constructed per RFC 2401.  The following fields
+ * in it shall be filled in by x->type->output:
+ *      tot_len
+ *      check
+ *
+ * On exit, skb->h will be set to the start of the payload to be processed
+ * by x->type->output and skb->nh will be set to the top IP header.
+ */
+static int xfrm4_tunnel_output(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb->dst;
+	struct xfrm_state *x = dst->xfrm;
+	struct iphdr *iph, *top_iph;
+	int flags;
+
+	iph = skb->nh.iph;
+	skb->h.ipiph = iph;
+
+	skb->nh.raw = skb_push(skb, x->props.header_len);
+	top_iph = skb->nh.iph;
+
+	top_iph->ihl = 5;
+	top_iph->version = 4;
+
+	/* DS disclosed */
+	top_iph->tos = INET_ECN_encapsulate(iph->tos, iph->tos);
+
+	flags = x->props.flags;
+	if (flags & XFRM_STATE_NOECN)
+		IP_ECN_clear(top_iph);
+
+	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
+		0 : (iph->frag_off & htons(IP_DF));
+	if (!top_iph->frag_off)
+		__ip_select_ident(top_iph, dst->child, 0);
+
+	top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
+
+	top_iph->saddr = x->props.saddr.a4;
+	top_iph->daddr = x->id.daddr.a4;
+	top_iph->protocol = IPPROTO_IPIP;
+
+	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+	return 0;
+}
+
+static int xfrm4_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct iphdr *iph = skb->nh.iph;
+	int err = -EINVAL;
+
+	if (iph->protocol != IPPROTO_IPIP)
+		goto out;
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto out;
+
+	if (skb_cloned(skb) &&
+	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto out;
+
+	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+		ipv4_copy_dscp(iph, skb->h.ipiph);
+	if (!(x->props.flags & XFRM_STATE_NOECN))
+		ipip_ecn_decapsulate(skb);
+	skb->mac.raw = memmove(skb->data - skb->mac_len,
+			       skb->mac.raw, skb->mac_len);
+	skb->nh.raw = skb->data;
+	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+	err = 0;
+
+out:
+	return err;
+}
+
+static struct xfrm_mode xfrm4_tunnel_mode = {
+	.input = xfrm4_tunnel_input,
+	.output = xfrm4_tunnel_output,
+	.owner = THIS_MODULE,
+	.encap = XFRM_MODE_TUNNEL,
+};
+
+static int __init xfrm4_tunnel_init(void)
+{
+	return xfrm_register_mode(&xfrm4_tunnel_mode, AF_INET);
+}
+
+static void __exit xfrm4_tunnel_exit(void)
+{
+	int err;
+
+	err = xfrm_unregister_mode(&xfrm4_tunnel_mode, AF_INET);
+	BUG_ON(err);
+}
+
+module_init(xfrm4_tunnel_init);
+module_exit(xfrm4_tunnel_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_MODE(AF_INET, XFRM_MODE_TUNNEL);
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -12,67 +12,10 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/netfilter_ipv4.h>
-#include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/icmp.h>
 
-/* Add encapsulation header.
- *
- * In transport mode, the IP header will be moved forward to make space
- * for the encapsulation header.
- *
- * In tunnel mode, the top IP header will be constructed per RFC 2401.
- * The following fields in it shall be filled in by x->type->output:
- *	tot_len
- *	check
- *
- * On exit, skb->h will be set to the start of the payload to be processed
- * by x->type->output and skb->nh will be set to the top IP header.
- */
-static void xfrm4_encap(struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
-	struct iphdr *iph, *top_iph;
-	int flags;
-
-	iph = skb->nh.iph;
-	skb->h.ipiph = iph;
-
-	skb->nh.raw = skb_push(skb, x->props.header_len);
-	top_iph = skb->nh.iph;
-
-	if (!x->props.mode) {
-		skb->h.raw += iph->ihl*4;
-		memmove(top_iph, iph, iph->ihl*4);
-		return;
-	}
-
-	top_iph->ihl = 5;
-	top_iph->version = 4;
-
-	/* DS disclosed */
-	top_iph->tos = INET_ECN_encapsulate(iph->tos, iph->tos);
-
-	flags = x->props.flags;
-	if (flags & XFRM_STATE_NOECN)
-		IP_ECN_clear(top_iph);
-
-	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
-		0 : (iph->frag_off & htons(IP_DF));
-	if (!top_iph->frag_off)
-		__ip_select_ident(top_iph, dst->child, 0);
-
-	top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
-
-	top_iph->saddr = x->props.saddr.a4;
-	top_iph->daddr = x->id.daddr.a4;
-	top_iph->protocol = IPPROTO_IPIP;
-
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
-}
-
 static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
@@ -121,7 +64,9 @@ static int xfrm4_output_one(struct sk_bu
 		if (err)
 			goto error;
 
-		xfrm4_encap(skb);
+		err = x->mode->output(skb);
+		if (err)
+			goto error;
 
 		err = x->type->output(x, skb);
 		if (err)
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -106,6 +106,26 @@ config INET6_TUNNEL
 	tristate
 	default n
 
+config INET6_XFRM_MODE_TRANSPORT
+	tristate "IPv6: IPsec transport mode"
+	depends on IPV6
+	default IPV6
+	select XFRM
+	---help---
+	  Support for IPsec transport mode.
+
+	  If unsure, say Y.
+
+config INET6_XFRM_MODE_TUNNEL
+	tristate "IPv6: IPsec tunnel mode"
+	depends on IPV6
+	default IPV6
+	select XFRM
+	---help---
+	  Support for IPsec tunnel mode.
+
+	  If unsure, say Y.
+
 config IPV6_TUNNEL
 	tristate "IPv6: IPv6-in-IPv6 tunnel"
 	select INET6_TUNNEL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -20,6 +20,8 @@ obj-$(CONFIG_INET6_ESP) += esp6.o
 obj-$(CONFIG_INET6_IPCOMP) += ipcomp6.o
 obj-$(CONFIG_INET6_XFRM_TUNNEL) += xfrm6_tunnel.o
 obj-$(CONFIG_INET6_TUNNEL) += tunnel6.o
+obj-$(CONFIG_INET6_XFRM_MODE_TRANSPORT) += xfrm6_mode_transport.o
+obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -39,6 +39,7 @@
 #include <linux/in6.h>
 #include <linux/tcp.h>
 #include <linux/route.h>
+#include <linux/module.h>
 
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
@@ -488,6 +489,7 @@ int ip6_find_1stfragopt(struct sk_buff *
 
 	return offset;
 }
+EXPORT_SYMBOL_GPL(ip6_find_1stfragopt);
 
 static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -13,21 +13,9 @@
 #include <linux/string.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
-#include <net/dsfield.h>
-#include <net/inet_ecn.h>
-#include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
-static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
-{
-	struct ipv6hdr *outer_iph = skb->nh.ipv6h;
-	struct ipv6hdr *inner_iph = skb->h.ipv6h;
-
-	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
-		IP6_ECN_set_ce(inner_iph);
-}
-
 int xfrm6_rcv_spi(struct sk_buff *skb, u32 spi)
 {
 	int err;
@@ -81,21 +69,10 @@ int xfrm6_rcv_spi(struct sk_buff *skb, u
 
 		xfrm_vec[xfrm_nr++] = x;
 
+		if (x->mode->input(x, skb))
+			goto drop;
+
 		if (x->props.mode) { /* XXX */
-			if (nexthdr != IPPROTO_IPV6)
-				goto drop;
-			if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-				goto drop;
-			if (skb_cloned(skb) &&
-			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-				goto drop;
-			if (x->props.flags & XFRM_STATE_DECAP_DSCP)
-				ipv6_copy_dscp(skb->nh.ipv6h, skb->h.ipv6h);
-			if (!(x->props.flags & XFRM_STATE_NOECN))
-				ipip6_ecn_decapsulate(skb);
-			skb->mac.raw = memmove(skb->data - skb->mac_len,
-					       skb->mac.raw, skb->mac_len);
-			skb->nh.raw = skb->data;
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
new file mode 100644
--- /dev/null
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -0,0 +1,73 @@
+/*
+ * xfrm6_mode_transport.c - Transport mode encapsulation for IPv6.
+ *
+ * Copyright (C) 2002 USAGI/WIDE Project
+ * Copyright (c) 2004-2006 Herbert Xu <herbert@gondor.apana.org.au>
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/stringify.h>
+#include <net/dst.h>
+#include <net/ipv6.h>
+#include <net/xfrm.h>
+
+/* Add encapsulation header.
+ *
+ * The IP header and mutable extension headers will be moved forward to make
+ * space for the encapsulation header.
+ *
+ * On exit, skb->h will be set to the start of the encapsulation header to be
+ * filled in by x->type->output and skb->nh will be set to the nextheader field
+ * of the extension header directly preceding the encapsulation header, or in
+ * its absence, that of the top IP header.  The value of skb->data will always
+ * point to the top IP header.
+ */
+static int xfrm6_transport_output(struct sk_buff *skb)
+{
+	struct xfrm_state *x = skb->dst->xfrm;
+	struct ipv6hdr *iph;
+	u8 *prevhdr;
+	int hdr_len;
+
+	skb_push(skb, x->props.header_len);
+	iph = skb->nh.ipv6h;
+
+	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
+	skb->nh.raw = prevhdr - x->props.header_len;
+	skb->h.raw = skb->data + hdr_len;
+	memmove(skb->data, iph, hdr_len);
+	return 0;
+}
+
+static int xfrm6_transport_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	return 0;
+}
+
+static struct xfrm_mode xfrm6_transport_mode = {
+	.input = xfrm6_transport_input,
+	.output = xfrm6_transport_output,
+	.owner = THIS_MODULE,
+	.encap = XFRM_MODE_TRANSPORT,
+};
+
+static int __init xfrm6_transport_init(void)
+{
+	return xfrm_register_mode(&xfrm6_transport_mode, AF_INET6);
+}
+
+static void __exit xfrm6_transport_exit(void)
+{
+	int err;
+
+	err = xfrm_unregister_mode(&xfrm6_transport_mode, AF_INET6);
+	BUG_ON(err);
+}
+
+module_init(xfrm6_transport_init);
+module_exit(xfrm6_transport_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_MODE(AF_INET6, XFRM_MODE_TRANSPORT);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
new file mode 100644
--- /dev/null
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -0,0 +1,121 @@
+/*
+ * xfrm6_mode_tunnel.c - Tunnel mode encapsulation for IPv6.
+ *
+ * Copyright (C) 2002 USAGI/WIDE Project
+ * Copyright (c) 2004-2006 Herbert Xu <herbert@gondor.apana.org.au>
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/stringify.h>
+#include <net/dsfield.h>
+#include <net/dst.h>
+#include <net/inet_ecn.h>
+#include <net/ipv6.h>
+#include <net/xfrm.h>
+
+static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
+{
+	struct ipv6hdr *outer_iph = skb->nh.ipv6h;
+	struct ipv6hdr *inner_iph = skb->h.ipv6h;
+
+	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
+		IP6_ECN_set_ce(inner_iph);
+}
+
+/* Add encapsulation header.
+ *
+ * The top IP header will be constructed per RFC 2401.  The following fields
+ * in it shall be filled in by x->type->output:
+ *	payload_len
+ *
+ * On exit, skb->h will be set to the start of the encapsulation header to be
+ * filled in by x->type->output and skb->nh will be set to the nextheader field
+ * of the extension header directly preceding the encapsulation header, or in
+ * its absence, that of the top IP header.  The value of skb->data will always
+ * point to the top IP header.
+ */
+static int xfrm6_tunnel_output(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb->dst;
+	struct xfrm_state *x = dst->xfrm;
+	struct ipv6hdr *iph, *top_iph;
+	int dsfield;
+
+	skb_push(skb, x->props.header_len);
+	iph = skb->nh.ipv6h;
+
+	skb->nh.raw = skb->data;
+	top_iph = skb->nh.ipv6h;
+	skb->nh.raw = &top_iph->nexthdr;
+	skb->h.ipv6h = top_iph + 1;
+
+	top_iph->version = 6;
+	top_iph->priority = iph->priority;
+	top_iph->flow_lbl[0] = iph->flow_lbl[0];
+	top_iph->flow_lbl[1] = iph->flow_lbl[1];
+	top_iph->flow_lbl[2] = iph->flow_lbl[2];
+	dsfield = ipv6_get_dsfield(top_iph);
+	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
+	if (x->props.flags & XFRM_STATE_NOECN)
+		dsfield &= ~INET_ECN_MASK;
+	ipv6_change_dsfield(top_iph, 0, dsfield);
+	top_iph->nexthdr = IPPROTO_IPV6; 
+	top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
+	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
+	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	return 0;
+}
+
+static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = -EINVAL;
+
+	if (skb->nh.raw[IP6CB(skb)->nhoff] != IPPROTO_IPV6)
+		goto out;
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+		goto out;
+
+	if (skb_cloned(skb) &&
+	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto out;
+
+	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+		ipv6_copy_dscp(skb->nh.ipv6h, skb->h.ipv6h);
+	if (!(x->props.flags & XFRM_STATE_NOECN))
+		ipip6_ecn_decapsulate(skb);
+	skb->mac.raw = memmove(skb->data - skb->mac_len,
+			       skb->mac.raw, skb->mac_len);
+	skb->nh.raw = skb->data;
+	err = 0;
+
+out:
+	return err;
+}
+
+static struct xfrm_mode xfrm6_tunnel_mode = {
+	.input = xfrm6_tunnel_input,
+	.output = xfrm6_tunnel_output,
+	.owner = THIS_MODULE,
+	.encap = XFRM_MODE_TUNNEL,
+};
+
+static int __init xfrm6_tunnel_init(void)
+{
+	return xfrm_register_mode(&xfrm6_tunnel_mode, AF_INET6);
+}
+
+static void __exit xfrm6_tunnel_exit(void)
+{
+	int err;
+
+	err = xfrm_unregister_mode(&xfrm6_tunnel_mode, AF_INET6);
+	BUG_ON(err);
+}
+
+module_init(xfrm6_tunnel_init);
+module_exit(xfrm6_tunnel_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_MODE(AF_INET6, XFRM_MODE_TUNNEL);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -14,68 +14,9 @@
 #include <linux/spinlock.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter_ipv6.h>
-#include <net/dsfield.h>
-#include <net/inet_ecn.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
-/* Add encapsulation header.
- *
- * In transport mode, the IP header and mutable extension headers will be moved
- * forward to make space for the encapsulation header.
- *
- * In tunnel mode, the top IP header will be constructed per RFC 2401.
- * The following fields in it shall be filled in by x->type->output:
- *	payload_len
- *
- * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and skb->nh will be set to the nextheader field
- * of the extension header directly preceding the encapsulation header, or in
- * its absence, that of the top IP header.  The value of skb->data will always
- * point to the top IP header.
- */
-static void xfrm6_encap(struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
-	struct ipv6hdr *iph, *top_iph;
-	int dsfield;
-
-	skb_push(skb, x->props.header_len);
-	iph = skb->nh.ipv6h;
-
-	if (!x->props.mode) {
-		u8 *prevhdr;
-		int hdr_len;
-
-		hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
-		skb->nh.raw = prevhdr - x->props.header_len;
-		skb->h.raw = skb->data + hdr_len;
-		memmove(skb->data, iph, hdr_len);
-		return;
-	}
-
-	skb->nh.raw = skb->data;
-	top_iph = skb->nh.ipv6h;
-	skb->nh.raw = &top_iph->nexthdr;
-	skb->h.ipv6h = top_iph + 1;
-
-	top_iph->version = 6;
-	top_iph->priority = iph->priority;
-	top_iph->flow_lbl[0] = iph->flow_lbl[0];
-	top_iph->flow_lbl[1] = iph->flow_lbl[1];
-	top_iph->flow_lbl[2] = iph->flow_lbl[2];
-	dsfield = ipv6_get_dsfield(top_iph);
-	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
-	if (x->props.flags & XFRM_STATE_NOECN)
-		dsfield &= ~INET_ECN_MASK;
-	ipv6_change_dsfield(top_iph, 0, dsfield);
-	top_iph->nexthdr = IPPROTO_IPV6; 
-	top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
-	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
-}
-
 static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
@@ -118,7 +59,9 @@ static int xfrm6_output_one(struct sk_bu
 		if (err)
 			goto error;
 
-		xfrm6_encap(skb);
+		err = x->mode->output(skb);
+		if (err)
+			goto error;
 
 		err = x->type->output(x, skb);
 		if (err)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -138,6 +138,89 @@ void xfrm_put_type(struct xfrm_type *typ
 	module_put(type->owner);
 }
 
+int xfrm_register_mode(struct xfrm_mode *mode, int family)
+{
+	struct xfrm_policy_afinfo *afinfo;
+	struct xfrm_mode **modemap;
+	int err;
+
+	if (unlikely(mode->encap >= XFRM_MODE_MAX))
+		return -EINVAL;
+
+	afinfo = xfrm_policy_lock_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+
+	err = -EEXIST;
+	modemap = afinfo->mode_map;
+	if (likely(modemap[mode->encap] == NULL)) {
+		modemap[mode->encap] = mode;
+		err = 0;
+	}
+
+	xfrm_policy_unlock_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_register_mode);
+
+int xfrm_unregister_mode(struct xfrm_mode *mode, int family)
+{
+	struct xfrm_policy_afinfo *afinfo;
+	struct xfrm_mode **modemap;
+	int err;
+
+	if (unlikely(mode->encap >= XFRM_MODE_MAX))
+		return -EINVAL;
+
+	afinfo = xfrm_policy_lock_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return -EAFNOSUPPORT;
+
+	err = -ENOENT;
+	modemap = afinfo->mode_map;
+	if (likely(modemap[mode->encap] == mode)) {
+		modemap[mode->encap] = NULL;
+		err = 0;
+	}
+
+	xfrm_policy_unlock_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_unregister_mode);
+
+struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
+{
+	struct xfrm_policy_afinfo *afinfo;
+	struct xfrm_mode *mode;
+	int modload_attempted = 0;
+
+	if (unlikely(encap >= XFRM_MODE_MAX))
+		return NULL;
+
+retry:
+	afinfo = xfrm_policy_get_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return NULL;
+
+	mode = afinfo->mode_map[encap];
+	if (unlikely(mode && !try_module_get(mode->owner)))
+		mode = NULL;
+	if (!mode && !modload_attempted) {
+		xfrm_policy_put_afinfo(afinfo);
+		request_module("xfrm-mode-%d-%d", family, encap);
+		modload_attempted = 1;
+		goto retry;
+	}
+
+	xfrm_policy_put_afinfo(afinfo);
+	return mode;
+}
+
+void xfrm_put_mode(struct xfrm_mode *mode)
+{
+	module_put(mode->owner);
+}
+
 static inline unsigned long make_jiffies(long secs)
 {
 	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -77,6 +77,8 @@ static void xfrm_state_gc_destroy(struct
 	kfree(x->ealg);
 	kfree(x->calg);
 	kfree(x->encap);
+	if (x->mode)
+		xfrm_put_mode(x->mode);
 	if (x->type) {
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
@@ -1193,6 +1195,10 @@ int xfrm_init_state(struct xfrm_state *x
 	if (err)
 		goto error;
 
+	x->mode = xfrm_get_mode(x->props.mode, family);
+	if (x->mode == NULL)
+		goto error;
+
 	x->km.state = XFRM_STATE_VALID;
 
 error:

--SkvwRMAIpAhPCcCJ--
