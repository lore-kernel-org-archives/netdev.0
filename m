From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC 4/9] ipv6: sr: add support for SRH encapsulation and injection with lwtunnels
Date: Fri, 26 Aug 2016 17:52:42 +0200
Message-ID: <1472226767-9904-5-git-send-email-david.lebrun@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34047 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751321AbcHZQOV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 12:14:21 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 2ADA367DE02
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:52:19 +0200 (CEST)
In-Reply-To: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a new type of interfaceless lightweight tunnel (SEG6),
enabling the encapsulation and injection of SRH within locally emitted
packets and forwarded packets.

>From a configuration viewpoint, a seg6 tunnel would be configured as follows:

  ip -6 ro ad fc00::1/128 via <gw> encap seg6 mode encap segs fc42::1,fc42::2,fc42::3

Any packet whose destination address is fc00::1 would thus be encapsulated
within an outer IPv6 header containing the SRH with three segments, and would
actually be routed to the first segment of the list. If `mode inline' was
specified instead of `mode encap', then the SRH would be directly inserted
after the IPv6 header without outer encapsulation.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/linux/seg6_iptunnel.h      |   6 +
 include/net/seg6.h                 |  11 ++
 include/uapi/linux/lwtunnel.h      |   1 +
 include/uapi/linux/seg6_iptunnel.h |  33 ++++
 net/core/lwtunnel.c                |   2 +
 net/ipv6/Kconfig                   |   9 ++
 net/ipv6/Makefile                  |   1 +
 net/ipv6/seg6_iptunnel.c           | 313 +++++++++++++++++++++++++++++++++++++
 8 files changed, 376 insertions(+)
 create mode 100644 include/linux/seg6_iptunnel.h
 create mode 100644 include/uapi/linux/seg6_iptunnel.h
 create mode 100644 net/ipv6/seg6_iptunnel.c

diff --git a/include/linux/seg6_iptunnel.h b/include/linux/seg6_iptunnel.h
new file mode 100644
index 0000000..5377cf6
--- /dev/null
+++ b/include/linux/seg6_iptunnel.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_SEG6_IPTUNNEL_H
+#define _LINUX_SEG6_IPTUNNEL_H
+
+#include <uapi/linux/seg6_iptunnel.h>
+
+#endif
diff --git a/include/net/seg6.h b/include/net/seg6.h
index d5177a9..af817f6 100644
--- a/include/net/seg6.h
+++ b/include/net/seg6.h
@@ -16,6 +16,9 @@
 
 #include <linux/net.h>
 #include <linux/ipv6.h>
+#if IS_ENABLED(CONFIG_IPV6_SEG6_IPTUNNEL)
+#include <net/lwtunnel.h>
+#endif
 
 #define SEG6_VERSION_MAJOR	0
 #define SEG6_VERSION_MINOR	30
@@ -40,4 +43,12 @@ static inline void seg6_pernet_unlock(struct net *net)
 	spin_unlock(&seg6_pernet(net)->lock);
 }
 
+#if IS_ENABLED(CONFIG_IPV6_SEG6_IPTUNNEL)
+static inline struct seg6_iptunnel_encap *
+seg6_lwtunnel_encap(struct lwtunnel_state *lwtstate)
+{
+	return (struct seg6_iptunnel_encap *)lwtstate->data;
+}
+#endif
+
 #endif
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index a478fe8..453cc62 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -9,6 +9,7 @@ enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_IP,
 	LWTUNNEL_ENCAP_ILA,
 	LWTUNNEL_ENCAP_IP6,
+	LWTUNNEL_ENCAP_SEG6,
 	__LWTUNNEL_ENCAP_MAX,
 };
 
diff --git a/include/uapi/linux/seg6_iptunnel.h b/include/uapi/linux/seg6_iptunnel.h
new file mode 100644
index 0000000..2794a5f
--- /dev/null
+++ b/include/uapi/linux/seg6_iptunnel.h
@@ -0,0 +1,33 @@
+/*
+ *  SR-IPv6 implementation
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_SEG6_IPTUNNEL_H
+#define _UAPI_LINUX_SEG6_IPTUNNEL_H
+
+enum {
+	SEG6_IPTUNNEL_UNSPEC,
+	SEG6_IPTUNNEL_SRH,
+	__SEG6_IPTUNNEL_MAX,
+};
+#define SEG6_IPTUNNEL_MAX (__SEG6_IPTUNNEL_MAX - 1)
+
+struct seg6_iptunnel_encap {
+	int flags;
+	struct ipv6_sr_hdr srh[0];
+};
+
+#define SEG6_IPTUN_ENCAP_SIZE(x) (sizeof(*(x)) + (((x)->srh->hdrlen + 1) << 3))
+
+#define SEG6_IPTUN_FLAG_ENCAP   0x1
+
+#endif
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 669ecc9..dfe82ff 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -39,6 +39,8 @@ static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
 		return "MPLS";
 	case LWTUNNEL_ENCAP_ILA:
 		return "ILA";
+	case LWTUNNEL_ENCAP_SEG6:
+		return "SEG6";
 	case LWTUNNEL_ENCAP_IP6:
 	case LWTUNNEL_ENCAP_IP:
 	case LWTUNNEL_ENCAP_NONE:
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 931111f..192c59f 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -310,4 +310,13 @@ config IPV6_SEG6_CORE
 
 	  If unsure, say N.
 
+config IPV6_SEG6_IPTUNNEL
+	tristate "IPv6: Segment Routing IP Tunnels encapsulation support"
+	depends on IPV6_SEG6_CORE
+	---help---
+	  Support encapsulation and injection of SRH in locally emitted and
+	  forwarded packets.
+
+	  If unsure, say N.
+
 endif # IPV6
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 4254716..a040f90 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 obj-$(CONFIG_IPV6_FOU) += fou6.o
 obj-$(CONFIG_IPV6_SEG6_CORE) += seg6.o
+obj-$(CONFIG_IPV6_SEG6_IPTUNNEL) += seg6_iptunnel.o
 
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
new file mode 100644
index 0000000..ce7218a
--- /dev/null
+++ b/net/ipv6/seg6_iptunnel.c
@@ -0,0 +1,313 @@
+/*
+ *  SR-IPv6 implementation
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *        modify it under the terms of the GNU General Public License
+ *        as published by the Free Software Foundation; either version
+ *        2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/net.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <net/lwtunnel.h>
+#include <net/netevent.h>
+#include <net/netns/generic.h>
+#include <net/ip6_fib.h>
+#include <net/route.h>
+#include <net/seg6.h>
+#include <linux/seg6.h>
+#include <linux/seg6_iptunnel.h>
+#include <net/addrconf.h>
+#include <net/ip6_route.h>
+
+static const struct nla_policy seg6_iptunnel_policy[SEG6_IPTUNNEL_MAX + 1] = {
+	[SEG6_IPTUNNEL_SRH]	= { .type = NLA_BINARY },
+};
+
+int nla_put_srh(struct sk_buff *skb, int attrtype,
+		struct seg6_iptunnel_encap *tuninfo)
+{
+	struct nlattr *nla;
+	struct seg6_iptunnel_encap *data;
+	int len;
+
+	len = SEG6_IPTUN_ENCAP_SIZE(tuninfo);
+
+	nla = nla_reserve(skb, attrtype, len);
+	if (!nla)
+		return -EMSGSIZE;
+
+	data = nla_data(nla);
+	memcpy(data, tuninfo, len);
+
+	return 0;
+}
+
+static void set_tun_src(struct net *net, struct net_device *dev,
+			struct in6_addr *daddr, struct in6_addr *saddr)
+{
+	struct in6_addr *tun_src;
+	struct seg6_pernet_data *sdata = seg6_pernet(net);
+
+	rcu_read_lock();
+
+	tun_src = rcu_dereference(sdata->tun_src);
+
+	if (!ipv6_addr_any(tun_src)) {
+		memcpy(saddr, tun_src, sizeof(struct in6_addr));
+	} else {
+		ipv6_dev_get_saddr(net, dev, daddr, IPV6_PREFER_SRC_PUBLIC,
+				   saddr);
+	}
+
+	rcu_read_unlock();
+}
+
+/* encapsulate an IPv6 packet within an outer IPv6 header with a given SRH */
+static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
+{
+	struct ipv6hdr *hdr, *inner_hdr;
+	struct ipv6_sr_hdr *isrh;
+	struct net *net = dev_net(skb_dst(skb)->dev);
+	int hdrlen, tot_len, err;
+
+	hdrlen = (osrh->hdrlen + 1) << 3;
+	tot_len = hdrlen + sizeof(*hdr);
+
+	err = pskb_expand_head(skb, tot_len, 0, GFP_ATOMIC);
+	if (unlikely(err))
+		return err;
+
+	inner_hdr = ipv6_hdr(skb);
+
+	skb_push(skb, tot_len);
+	skb_reset_network_header(skb);
+	skb_mac_header_rebuild(skb);
+	hdr = ipv6_hdr(skb);
+
+	/* inherit tc, flowlabel and hlim
+	 * hlim will be decremented in ip6_forward() afterwards and
+	 * decapsulation will overwrite inner hlim with outer hlim
+	 */
+	ip6_flow_hdr(hdr, ip6_tclass(ip6_flowinfo(inner_hdr)),
+		     ip6_flowlabel(inner_hdr));
+	hdr->hop_limit = inner_hdr->hop_limit;
+	hdr->nexthdr = NEXTHDR_ROUTING;
+
+	isrh = (void *)hdr + sizeof(*hdr);
+	memcpy(isrh, osrh, hdrlen);
+
+	isrh->nexthdr = NEXTHDR_IPV6;
+
+	hdr->daddr = isrh->segments[isrh->first_segment];
+	set_tun_src(net, skb->dev, &hdr->daddr, &hdr->saddr);
+
+	return 0;
+}
+
+/* insert an SRH within an IPv6 packet, just after the IPv6 header */
+static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
+{
+	struct ipv6hdr *hdr, *oldhdr;
+	struct ipv6_sr_hdr *isrh;
+	int hdrlen, err;
+
+	hdrlen = (osrh->hdrlen + 1) << 3;
+
+	err = pskb_expand_head(skb, hdrlen, 0, GFP_ATOMIC);
+	if (unlikely(err))
+		return err;
+
+	oldhdr = ipv6_hdr(skb);
+
+	skb_push(skb, hdrlen);
+	skb_reset_network_header(skb);
+	skb_mac_header_rebuild(skb);
+
+	hdr = ipv6_hdr(skb);
+
+	memmove(hdr, oldhdr, sizeof(*hdr));
+
+	isrh = (void *)hdr + sizeof(*hdr);
+	memcpy(isrh, osrh, hdrlen);
+
+	isrh->nexthdr = hdr->nexthdr;
+	hdr->nexthdr = NEXTHDR_ROUTING;
+
+	isrh->segments[0] = hdr->daddr;
+	hdr->daddr = isrh->segments[isrh->first_segment];
+
+	return 0;
+}
+
+static int seg6_do_srh(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct seg6_iptunnel_encap *tinfo = seg6_lwtunnel_encap(dst->lwtstate);
+	int err = 0;
+
+	if (likely(!skb->encapsulation)) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	if (tinfo->flags & SEG6_IPTUN_FLAG_ENCAP) {
+		err = seg6_do_srh_encap(skb, tinfo->srh);
+	} else {
+		err = seg6_do_srh_inline(skb, tinfo->srh);
+		skb_reset_inner_headers(skb);
+	}
+
+	if (err)
+		return err;
+
+	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+
+	skb_set_inner_protocol(skb, skb->protocol);
+
+	return 0;
+}
+
+int seg6_input(struct sk_buff *skb)
+{
+	int err;
+
+	err = seg6_do_srh(skb);
+	if (unlikely(err))
+		return err;
+
+	skb_dst_drop(skb);
+	ip6_route_input(skb);
+
+	return dst_input(skb);
+}
+
+int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	int err;
+	struct dst_entry *dst;
+	struct ipv6hdr *hdr;
+	struct flowi6 fl6;
+
+	err = seg6_do_srh(skb);
+	if (unlikely(err))
+		return err;
+
+	hdr = ipv6_hdr(skb);
+	fl6.daddr = hdr->daddr;
+	fl6.saddr = hdr->saddr;
+	fl6.flowlabel = ip6_flowinfo(hdr);
+	fl6.flowi6_mark = skb->mark;
+	fl6.flowi6_proto = hdr->nexthdr;
+
+	skb_dst_drop(skb);
+
+	err = ip6_dst_lookup(net, sk, &dst, &fl6);
+	if (unlikely(err))
+		return err;
+
+	skb_dst_set(skb, dst);
+
+	return dst_output(net, sk, skb);
+}
+
+static int seg6_build_state(struct net_device *dev, struct nlattr *nla,
+			    unsigned int family, const void *cfg,
+			    struct lwtunnel_state **ts)
+{
+	struct seg6_iptunnel_encap *tuninfo, *tuninfo_new;
+	struct nlattr *tb[SEG6_IPTUNNEL_MAX + 1];
+	struct lwtunnel_state *newts;
+	int tuninfo_len;
+	int err;
+
+	err = nla_parse_nested(tb, SEG6_IPTUNNEL_MAX, nla,
+			       seg6_iptunnel_policy);
+
+	if (err < 0)
+		return err;
+
+	if (!tb[SEG6_IPTUNNEL_SRH])
+		return -EINVAL;
+
+	tuninfo = nla_data(tb[SEG6_IPTUNNEL_SRH]);
+	tuninfo_len = SEG6_IPTUN_ENCAP_SIZE(tuninfo);
+
+	newts = lwtunnel_state_alloc(tuninfo_len);
+	if (!newts)
+		return -ENOMEM;
+
+	newts->len = tuninfo_len;
+	tuninfo_new = seg6_lwtunnel_encap(newts);
+	memcpy(tuninfo_new, tuninfo, tuninfo_len);
+
+	newts->type = LWTUNNEL_ENCAP_SEG6;
+	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
+			LWTUNNEL_STATE_INPUT_REDIRECT;
+
+	*ts = newts;
+
+	return 0;
+}
+
+static int seg6_fill_encap_info(struct sk_buff *skb,
+				struct lwtunnel_state *lwtstate)
+{
+	struct seg6_iptunnel_encap *tuninfo = seg6_lwtunnel_encap(lwtstate);
+
+	if (nla_put_srh(skb, SEG6_IPTUNNEL_SRH, tuninfo))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int seg6_encap_nlsize(struct lwtunnel_state *lwtstate)
+{
+	struct seg6_iptunnel_encap *tuninfo = seg6_lwtunnel_encap(lwtstate);
+
+	return nla_total_size(SEG6_IPTUN_ENCAP_SIZE(tuninfo));
+}
+
+static int seg6_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
+{
+	struct seg6_iptunnel_encap *a_hdr = seg6_lwtunnel_encap(a);
+	struct seg6_iptunnel_encap *b_hdr = seg6_lwtunnel_encap(b);
+	int len = SEG6_IPTUN_ENCAP_SIZE(a_hdr);
+
+	if (len != SEG6_IPTUN_ENCAP_SIZE(b_hdr))
+		return 1;
+
+	return memcmp(a_hdr, b_hdr, len);
+}
+
+static const struct lwtunnel_encap_ops seg6_iptun_ops = {
+	.build_state = seg6_build_state,
+	.output = seg6_output,
+	.input = seg6_input,
+	.fill_encap = seg6_fill_encap_info,
+	.get_encap_size = seg6_encap_nlsize,
+	.cmp_encap = seg6_encap_cmp,
+};
+
+static int __init seg6_iptunnel_init(void)
+{
+	return lwtunnel_encap_add_ops(&seg6_iptun_ops, LWTUNNEL_ENCAP_SEG6);
+}
+module_init(seg6_iptunnel_init);
+
+static void __exit seg6_iptunnel_exit(void)
+{
+	lwtunnel_encap_del_ops(&seg6_iptun_ops, LWTUNNEL_ENCAP_SEG6);
+}
+module_exit(seg6_iptunnel_exit);
+
+MODULE_DESCRIPTION("Segment Routing with IPv6 IP Tunnels");
+MODULE_LICENSE("GPL v2");
-- 
2.3.6
