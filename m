From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] netfilter: nf_tables: add fib expression
Date: Tue,  1 Nov 2016 22:26:28 +0100
Message-ID: <1478035593-1362-8-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52590 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932275AbcKAV1H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 17:27:07 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 64FA3168386
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 41891BAC27
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EF99FBAC28
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:01 +0100 (CET)
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Add FIB expression, supported for ipv4, ipv6 and inet family (the latter
just dispatches to ipv4 or ipv6 one based on nfproto).

Currently supports fetching output interface index/name and the
rtm_type associated with an address.

This can be used for adding path filtering. rtm_type is useful
to e.g. enforce a strong-end host model where packets
are only accepted if daddr is configured on the interface the
packet arrived on.

The fib expression is a native nftables alternative to the
xtables addrtype and rp_filter matches.

FIB result order for oif/oifname retrieval is as follows:
 - if packet is local (skb has rtable, RTF_LOCAL set, this
   will also catch looped-back multicast packets), set oif to
   the loopback interface.
 - if fib lookup returns an error, or result points to local,
   store zero result.  This means '--local' option of -m rpfilter
   is not supported. It is possible to use 'fib type local' or add
   explicit saddr/daddr matching rules to create exceptions if this
   is really needed.
 - store result in the destination register.
   In case of multiple routes, search set for desired oif in case
   strict matching is requested.

ipv4 and ipv6 behave fib expressions are supposed to behave the same.

[ I have collapsed Arnd Bergmann's ("netfilter: nf_tables: fib warnings")

	http://patchwork.ozlabs.org/patch/688615/

  to address fallout from this patch after rebasing nf-next, that was
  posted to address compilation warnings. --pablo ]

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nft_fib.h          |  31 ++++
 include/uapi/linux/netfilter/nf_tables.h |  36 ++++
 net/ipv4/netfilter/Kconfig               |   8 +
 net/ipv4/netfilter/Makefile              |   1 +
 net/ipv4/netfilter/nft_fib_ipv4.c        | 238 ++++++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig               |   8 +
 net/ipv6/netfilter/Makefile              |   1 +
 net/ipv6/netfilter/nft_fib_ipv6.c        | 275 +++++++++++++++++++++++++++++++
 net/netfilter/Kconfig                    |  13 ++
 net/netfilter/Makefile                   |   2 +
 net/netfilter/nft_fib.c                  | 159 ++++++++++++++++++
 net/netfilter/nft_fib_inet.c             |  82 +++++++++
 12 files changed, 854 insertions(+)
 create mode 100644 include/net/netfilter/nft_fib.h
 create mode 100644 net/ipv4/netfilter/nft_fib_ipv4.c
 create mode 100644 net/ipv6/netfilter/nft_fib_ipv6.c
 create mode 100644 net/netfilter/nft_fib.c
 create mode 100644 net/netfilter/nft_fib_inet.c

diff --git a/include/net/netfilter/nft_fib.h b/include/net/netfilter/nft_fib.h
new file mode 100644
index 000000000000..cbedda077db2
--- /dev/null
+++ b/include/net/netfilter/nft_fib.h
@@ -0,0 +1,31 @@
+#ifndef _NFT_FIB_H_
+#define _NFT_FIB_H_
+
+struct nft_fib {
+	enum nft_registers	dreg:8;
+	u8			result;
+	u32			flags;
+};
+
+extern const struct nla_policy nft_fib_policy[];
+
+int nft_fib_dump(struct sk_buff *skb, const struct nft_expr *expr);
+int nft_fib_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		 const struct nlattr * const tb[]);
+int nft_fib_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		     const struct nft_data **data);
+
+
+void nft_fib4_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
+			const struct nft_pktinfo *pkt);
+void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
+		   const struct nft_pktinfo *pkt);
+
+void nft_fib6_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
+			const struct nft_pktinfo *pkt);
+void nft_fib6_eval(const struct nft_expr *expr, struct nft_regs *regs,
+		   const struct nft_pktinfo *pkt);
+
+void nft_fib_store_result(void *reg, enum nft_fib_result r,
+			  const struct nft_pktinfo *pkt, int index);
+#endif
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index c6c4477c136b..a054ad2c8853 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1109,6 +1109,42 @@ enum nft_gen_attributes {
 };
 #define NFTA_GEN_MAX		(__NFTA_GEN_MAX - 1)
 
+/*
+ * enum nft_fib_attributes - nf_tables fib expression netlink attributes
+ *
+ * @NFTA_FIB_DREG: destination register (NLA_U32)
+ * @NFTA_FIB_RESULT: desired result (NLA_U32)
+ * @NFTA_FIB_FLAGS: flowi fields to initialize when querying the FIB (NLA_U32)
+ *
+ * The FIB expression performs a route lookup according
+ * to the packet data.
+ */
+enum nft_fib_attributes {
+	NFTA_FIB_UNSPEC,
+	NFTA_FIB_DREG,
+	NFTA_FIB_RESULT,
+	NFTA_FIB_FLAGS,
+	__NFTA_FIB_MAX
+};
+#define NFTA_FIB_MAX (__NFTA_FIB_MAX - 1)
+
+enum nft_fib_result {
+	NFT_FIB_RESULT_UNSPEC,
+	NFT_FIB_RESULT_OIF,
+	NFT_FIB_RESULT_OIFNAME,
+	NFT_FIB_RESULT_ADDRTYPE,
+	__NFT_FIB_RESULT_MAX
+};
+#define NFT_FIB_RESULT_MAX	(__NFT_FIB_RESULT_MAX - 1)
+
+enum nft_fib_flags {
+	NFTA_FIB_F_SADDR	= 1 << 0,	/* look up src */
+	NFTA_FIB_F_DADDR	= 1 << 1,	/* look up dst */
+	NFTA_FIB_F_MARK		= 1 << 2,	/* use skb->mark */
+	NFTA_FIB_F_IIF		= 1 << 3,	/* restrict to iif */
+	NFTA_FIB_F_OIF		= 1 << 4,	/* restrict to oif */
+};
+
 /**
  * enum nft_trace_attributes - nf_tables trace netlink attributes
  *
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index d613309e3e5d..f80bb8f457c8 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -54,6 +54,14 @@ config NFT_DUP_IPV4
 	help
 	  This module enables IPv4 packet duplication support for nf_tables.
 
+config NFT_FIB_IPV4
+	select NFT_FIB
+	tristate "nf_tables fib / ip route lookup support"
+	help
+	  This module enables IPv4 FIB lookups, e.g. for reverse path filtering.
+	  It also allows query of the FIB for the route type, e.g. local, unicast,
+	  multicast or blackhole.
+
 endif # NF_TABLES_IPV4
 
 config NF_TABLES_ARP
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 853328f8fd05..59d7786ddce1 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_NF_TABLES_IPV4) += nf_tables_ipv4.o
 obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV4) += nft_chain_route_ipv4.o
 obj-$(CONFIG_NFT_CHAIN_NAT_IPV4) += nft_chain_nat_ipv4.o
 obj-$(CONFIG_NFT_REJECT_IPV4) += nft_reject_ipv4.o
+obj-$(CONFIG_NFT_FIB_IPV4) += nft_fib_ipv4.o
 obj-$(CONFIG_NFT_MASQ_IPV4) += nft_masq_ipv4.o
 obj-$(CONFIG_NFT_REDIR_IPV4) += nft_redir_ipv4.o
 obj-$(CONFIG_NFT_DUP_IPV4) += nft_dup_ipv4.o
diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
new file mode 100644
index 000000000000..db91fd42db67
--- /dev/null
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -0,0 +1,238 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nft_fib.h>
+
+#include <net/ip_fib.h>
+#include <net/route.h>
+
+/* don't try to find route from mcast/bcast/zeronet */
+static __be32 get_saddr(__be32 addr)
+{
+	if (ipv4_is_multicast(addr) || ipv4_is_lbcast(addr) ||
+	    ipv4_is_zeronet(addr))
+		return 0;
+	return addr;
+}
+
+static bool fib4_is_local(const struct sk_buff *skb)
+{
+	const struct rtable *rt = skb_rtable(skb);
+
+	return rt && (rt->rt_flags & RTCF_LOCAL);
+}
+
+#define DSCP_BITS     0xfc
+
+void nft_fib4_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
+			const struct nft_pktinfo *pkt)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+	u32 *dst = &regs->data[priv->dreg];
+	const struct net_device *dev = NULL;
+	const struct iphdr *iph;
+	__be32 addr;
+
+	if (priv->flags & NFTA_FIB_F_IIF)
+		dev = pkt->in;
+	else if (priv->flags & NFTA_FIB_F_OIF)
+		dev = pkt->out;
+
+	iph = ip_hdr(pkt->skb);
+	if (priv->flags & NFTA_FIB_F_DADDR)
+		addr = iph->daddr;
+	else
+		addr = iph->saddr;
+
+	*dst = inet_dev_addr_type(pkt->net, dev, addr);
+}
+EXPORT_SYMBOL_GPL(nft_fib4_eval_type);
+
+static int get_ifindex(const struct net_device *dev)
+{
+	return dev ? dev->ifindex : 0;
+}
+
+void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
+		   const struct nft_pktinfo *pkt)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+	u32 *dest = &regs->data[priv->dreg];
+	const struct iphdr *iph;
+	struct fib_result res;
+	struct flowi4 fl4 = {
+		.flowi4_scope = RT_SCOPE_UNIVERSE,
+		.flowi4_iif = LOOPBACK_IFINDEX,
+	};
+	const struct net_device *oif;
+	struct net_device *found;
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	int i;
+#endif
+
+	/*
+	 * Do not set flowi4_oif, it restricts results (for example, asking
+	 * for oif 3 will get RTN_UNICAST result even if the daddr exits
+	 * on another interface.
+	 *
+	 * Search results for the desired outinterface instead.
+	 */
+	if (priv->flags & NFTA_FIB_F_OIF)
+		oif = pkt->out;
+	else if (priv->flags & NFTA_FIB_F_IIF)
+		oif = pkt->in;
+	else
+		oif = NULL;
+
+	if (pkt->hook == NF_INET_PRE_ROUTING && fib4_is_local(pkt->skb)) {
+		nft_fib_store_result(dest, priv->result, pkt, LOOPBACK_IFINDEX);
+		return;
+	}
+
+	iph = ip_hdr(pkt->skb);
+	if (ipv4_is_multicast(iph->daddr) &&
+	    ipv4_is_zeronet(iph->saddr) &&
+	    ipv4_is_local_multicast(iph->daddr)) {
+		nft_fib_store_result(dest, priv->result, pkt,
+				     get_ifindex(pkt->skb->dev));
+		return;
+	}
+
+	if (priv->flags & NFTA_FIB_F_MARK)
+		fl4.flowi4_mark = pkt->skb->mark;
+
+	fl4.flowi4_tos = iph->tos & DSCP_BITS;
+
+	if (priv->flags & NFTA_FIB_F_DADDR) {
+		fl4.daddr = iph->daddr;
+		fl4.saddr = get_saddr(iph->saddr);
+	} else {
+		fl4.daddr = iph->saddr;
+		fl4.saddr = get_saddr(iph->daddr);
+	}
+
+	if (fib_lookup(pkt->net, &fl4, &res, FIB_LOOKUP_IGNORE_LINKSTATE))
+		return;
+
+	switch (res.type) {
+	case RTN_UNICAST:
+		break;
+	case RTN_LOCAL:	/* should not appear here, see fib4_is_local() above */
+		return;
+	default:
+		break;
+	}
+
+       if (!oif) {
+               found = FIB_RES_DEV(res);
+               goto ok;
+       }
+
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	for (i = 0; i < res.fi->fib_nhs; i++) {
+		struct fib_nh *nh = &res.fi->fib_nh[i];
+
+		if (nh->nh_dev == oif) {
+			found = nh->nh_dev;
+			goto ok;
+		}
+	}
+	return;
+#else
+	found = FIB_RES_DEV(res);
+	if (found != oif)
+		return;
+#endif
+ok:
+	switch (priv->result) {
+	case NFT_FIB_RESULT_OIF:
+		*dest = found->ifindex;
+		break;
+	case NFT_FIB_RESULT_OIFNAME:
+		strncpy((char *)dest, found->name, IFNAMSIZ);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(nft_fib4_eval);
+
+static struct nft_expr_type nft_fib4_type;
+
+static const struct nft_expr_ops nft_fib4_type_ops = {
+	.type		= &nft_fib4_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_fib)),
+	.eval		= nft_fib4_eval_type,
+	.init		= nft_fib_init,
+	.dump		= nft_fib_dump,
+	.validate	= nft_fib_validate,
+};
+
+static const struct nft_expr_ops nft_fib4_ops = {
+	.type		= &nft_fib4_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_fib)),
+	.eval		= nft_fib4_eval,
+	.init		= nft_fib_init,
+	.dump		= nft_fib_dump,
+	.validate	= nft_fib_validate,
+};
+
+static const struct nft_expr_ops *
+nft_fib4_select_ops(const struct nft_ctx *ctx,
+		    const struct nlattr * const tb[])
+{
+	enum nft_fib_result result;
+
+	if (!tb[NFTA_FIB_RESULT])
+		return ERR_PTR(-EINVAL);
+
+	result = htonl(nla_get_be32(tb[NFTA_FIB_RESULT]));
+
+	switch (result) {
+	case NFT_FIB_RESULT_OIF:
+		return &nft_fib4_ops;
+	case NFT_FIB_RESULT_OIFNAME:
+		return &nft_fib4_ops;
+	case NFT_FIB_RESULT_ADDRTYPE:
+		return &nft_fib4_type_ops;
+	default:
+		return ERR_PTR(-EOPNOTSUPP);
+	}
+}
+
+static struct nft_expr_type nft_fib4_type __read_mostly = {
+	.name		= "fib",
+	.select_ops	= &nft_fib4_select_ops,
+	.policy		= nft_fib_policy,
+	.maxattr	= NFTA_FIB_MAX,
+	.family		= NFPROTO_IPV4,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_fib4_module_init(void)
+{
+	return nft_register_expr(&nft_fib4_type);
+}
+
+static void __exit nft_fib4_module_exit(void)
+{
+	nft_unregister_expr(&nft_fib4_type);
+}
+
+module_init(nft_fib4_module_init);
+module_exit(nft_fib4_module_exit);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_ALIAS_NFT_AF_EXPR(2, "fib");
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index e10a04c9cdc7..144f1de33836 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -54,6 +54,14 @@ config NFT_DUP_IPV6
 	help
 	  This module enables IPv6 packet duplication support for nf_tables.
 
+config NFT_FIB_IPV6
+	tristate "nf_tables fib / ipv6 route lookup support"
+	select NFT_FIB
+	help
+	  This module enables IPv6 FIB lookups, e.g. for reverse path filtering.
+	  It also allows query of the FIB for the route type, e.g. local, unicast,
+	  multicast or blackhole.
+
 endif # NF_TABLES_IPV6
 endif # NF_TABLES
 
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index b4f7d0b4e2af..7984f3071f05 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -40,6 +40,7 @@ obj-$(CONFIG_NFT_REJECT_IPV6) += nft_reject_ipv6.o
 obj-$(CONFIG_NFT_MASQ_IPV6) += nft_masq_ipv6.o
 obj-$(CONFIG_NFT_REDIR_IPV6) += nft_redir_ipv6.o
 obj-$(CONFIG_NFT_DUP_IPV6) += nft_dup_ipv6.o
+obj-$(CONFIG_NFT_FIB_IPV6) += nft_fib_ipv6.o
 
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
diff --git a/net/ipv6/netfilter/nft_fib_ipv6.c b/net/ipv6/netfilter/nft_fib_ipv6.c
new file mode 100644
index 000000000000..ff1f1b6b4a4a
--- /dev/null
+++ b/net/ipv6/netfilter/nft_fib_ipv6.c
@@ -0,0 +1,275 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <linux/netfilter_ipv6.h>
+#include <net/netfilter/nf_tables_core.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nft_fib.h>
+
+#include <net/ip6_fib.h>
+#include <net/ip6_route.h>
+
+static bool fib6_is_local(const struct sk_buff *skb)
+{
+	const struct rt6_info *rt = (const void *)skb_dst(skb);
+
+	return rt && (rt->rt6i_flags & RTF_LOCAL);
+}
+
+static int get_ifindex(const struct net_device *dev)
+{
+	return dev ? dev->ifindex : 0;
+}
+
+static int nft_fib6_flowi_init(struct flowi6 *fl6, const struct nft_fib *priv,
+			       const struct nft_pktinfo *pkt,
+			       const struct net_device *dev)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(pkt->skb);
+	int lookup_flags = 0;
+
+	if (priv->flags & NFTA_FIB_F_DADDR) {
+		fl6->daddr = iph->daddr;
+		fl6->saddr = iph->saddr;
+	} else {
+		fl6->daddr = iph->saddr;
+		fl6->saddr = iph->daddr;
+	}
+
+	if (ipv6_addr_type(&fl6->daddr) & IPV6_ADDR_LINKLOCAL) {
+		lookup_flags |= RT6_LOOKUP_F_IFACE;
+		fl6->flowi6_oif = get_ifindex(dev ? dev : pkt->skb->dev);
+	}
+
+	if (ipv6_addr_type(&fl6->saddr) & IPV6_ADDR_UNICAST)
+		lookup_flags |= RT6_LOOKUP_F_HAS_SADDR;
+
+	if (priv->flags & NFTA_FIB_F_MARK)
+		fl6->flowi6_mark = pkt->skb->mark;
+
+	fl6->flowlabel = (*(__be32 *)iph) & IPV6_FLOWINFO_MASK;
+
+	return lookup_flags;
+}
+
+static u32 __nft_fib6_eval_type(const struct nft_fib *priv,
+				const struct nft_pktinfo *pkt)
+{
+	const struct net_device *dev = NULL;
+	const struct nf_ipv6_ops *v6ops;
+	const struct nf_afinfo *afinfo;
+	int route_err, addrtype;
+	struct rt6_info *rt;
+	struct flowi6 fl6 = {
+		.flowi6_iif = LOOPBACK_IFINDEX,
+		.flowi6_proto = pkt->tprot,
+	};
+	u32 ret = 0;
+
+	afinfo = nf_get_afinfo(NFPROTO_IPV6);
+	if (!afinfo)
+		return RTN_UNREACHABLE;
+
+	if (priv->flags & NFTA_FIB_F_IIF)
+		dev = pkt->in;
+	else if (priv->flags & NFTA_FIB_F_OIF)
+		dev = pkt->out;
+
+	nft_fib6_flowi_init(&fl6, priv, pkt, dev);
+
+	v6ops = nf_get_ipv6_ops();
+	if (dev && v6ops && v6ops->chk_addr(pkt->net, &fl6.daddr, dev, true))
+		ret = RTN_LOCAL;
+
+	route_err = afinfo->route(pkt->net, (struct dst_entry **)&rt,
+				  flowi6_to_flowi(&fl6), false);
+	if (route_err)
+		goto err;
+
+	if (rt->rt6i_flags & RTF_REJECT) {
+		route_err = rt->dst.error;
+		dst_release(&rt->dst);
+		goto err;
+	}
+
+	if (ipv6_anycast_destination((struct dst_entry *)rt, &fl6.daddr))
+		ret = RTN_ANYCAST;
+	else if (!dev && rt->rt6i_flags & RTF_LOCAL)
+		ret = RTN_LOCAL;
+
+	dst_release(&rt->dst);
+
+	if (ret)
+		return ret;
+
+	addrtype = ipv6_addr_type(&fl6.daddr);
+
+	if (addrtype & IPV6_ADDR_MULTICAST)
+		return RTN_MULTICAST;
+	if (addrtype & IPV6_ADDR_UNICAST)
+		return RTN_UNICAST;
+
+	return RTN_UNSPEC;
+ err:
+	switch (route_err) {
+	case -EINVAL:
+		return RTN_BLACKHOLE;
+	case -EACCES:
+		return RTN_PROHIBIT;
+	case -EAGAIN:
+		return RTN_THROW;
+	default:
+		break;
+	}
+
+	return RTN_UNREACHABLE;
+}
+
+void nft_fib6_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
+			const struct nft_pktinfo *pkt)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+	u32 *dest = &regs->data[priv->dreg];
+
+	*dest = __nft_fib6_eval_type(priv, pkt);
+}
+EXPORT_SYMBOL_GPL(nft_fib6_eval_type);
+
+void nft_fib6_eval(const struct nft_expr *expr, struct nft_regs *regs,
+		   const struct nft_pktinfo *pkt)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+	const struct net_device *oif = NULL;
+	u32 *dest = &regs->data[priv->dreg];
+	struct flowi6 fl6 = {
+		.flowi6_iif = LOOPBACK_IFINDEX,
+		.flowi6_proto = pkt->tprot,
+	};
+	struct rt6_info *rt;
+	int lookup_flags;
+
+	if (priv->flags & NFTA_FIB_F_IIF)
+		oif = pkt->in;
+	else if (priv->flags & NFTA_FIB_F_OIF)
+		oif = pkt->out;
+
+	lookup_flags = nft_fib6_flowi_init(&fl6, priv, pkt, oif);
+
+	if (pkt->hook == NF_INET_PRE_ROUTING && fib6_is_local(pkt->skb)) {
+		nft_fib_store_result(dest, priv->result, pkt, LOOPBACK_IFINDEX);
+		return;
+	}
+
+	*dest = 0;
+ again:
+	rt = (void *)ip6_route_lookup(pkt->net, &fl6, lookup_flags);
+	if (rt->dst.error)
+		goto put_rt_err;
+
+	/* Should not see RTF_LOCAL here */
+	if (rt->rt6i_flags & (RTF_REJECT | RTF_ANYCAST | RTF_LOCAL))
+		goto put_rt_err;
+
+	if (oif && oif != rt->rt6i_idev->dev) {
+		/* multipath route? Try again with F_IFACE */
+		if ((lookup_flags & RT6_LOOKUP_F_IFACE) == 0) {
+			lookup_flags |= RT6_LOOKUP_F_IFACE;
+			fl6.flowi6_oif = oif->ifindex;
+			ip6_rt_put(rt);
+			goto again;
+		}
+	}
+
+	switch (priv->result) {
+	case NFT_FIB_RESULT_OIF:
+		*dest = rt->rt6i_idev->dev->ifindex;
+		break;
+	case NFT_FIB_RESULT_OIFNAME:
+		strncpy((char *)dest, rt->rt6i_idev->dev->name, IFNAMSIZ);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+
+ put_rt_err:
+	ip6_rt_put(rt);
+}
+EXPORT_SYMBOL_GPL(nft_fib6_eval);
+
+static struct nft_expr_type nft_fib6_type;
+
+static const struct nft_expr_ops nft_fib6_type_ops = {
+	.type		= &nft_fib6_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_fib)),
+	.eval		= nft_fib6_eval_type,
+	.init		= nft_fib_init,
+	.dump		= nft_fib_dump,
+	.validate	= nft_fib_validate,
+};
+
+static const struct nft_expr_ops nft_fib6_ops = {
+	.type		= &nft_fib6_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_fib)),
+	.eval		= nft_fib6_eval,
+	.init		= nft_fib_init,
+	.dump		= nft_fib_dump,
+	.validate	= nft_fib_validate,
+};
+
+static const struct nft_expr_ops *
+nft_fib6_select_ops(const struct nft_ctx *ctx,
+		    const struct nlattr * const tb[])
+{
+	enum nft_fib_result result;
+
+	if (!tb[NFTA_FIB_RESULT])
+		return ERR_PTR(-EINVAL);
+
+	result = htonl(nla_get_be32(tb[NFTA_FIB_RESULT]));
+
+	switch (result) {
+	case NFT_FIB_RESULT_OIF:
+		return &nft_fib6_ops;
+	case NFT_FIB_RESULT_OIFNAME:
+		return &nft_fib6_ops;
+	case NFT_FIB_RESULT_ADDRTYPE:
+		return &nft_fib6_type_ops;
+	default:
+		return ERR_PTR(-EOPNOTSUPP);
+	}
+}
+
+static struct nft_expr_type nft_fib6_type __read_mostly = {
+	.name		= "fib",
+	.select_ops	= &nft_fib6_select_ops,
+	.policy		= nft_fib_policy,
+	.maxattr	= NFTA_FIB_MAX,
+	.family		= NFPROTO_IPV6,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_fib6_module_init(void)
+{
+	return nft_register_expr(&nft_fib6_type);
+}
+
+static void __exit nft_fib6_module_exit(void)
+{
+	nft_unregister_expr(&nft_fib6_type);
+}
+module_init(nft_fib6_module_init);
+module_exit(nft_fib6_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_ALIAS_NFT_AF_EXPR(10, "fib");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e8d56d9a4df2..9bcf899ce16e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -581,6 +581,19 @@ config NFT_HASH
 	  This option adds the "hash" expression that you can use to perform
 	  a hash operation on registers.
 
+config NFT_FIB
+	tristate
+
+config NFT_FIB_INET
+	depends on NF_TABLES_INET
+	depends on NFT_FIB_IPV4
+	depends on NFT_FIB_IPV6
+	tristate "Netfilter nf_tables fib inet support"
+	help
+	  This option allows using the FIB expression from the inet table.
+	  The lookup will be delegated to the IPv4 or IPv6 FIB depending
+	  on the protocol of the packet.
+
 if NF_TABLES_NETDEV
 
 config NF_DUP_NETDEV
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index c23c3c84416f..8faa36c0686d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -96,6 +96,8 @@ obj-$(CONFIG_NFT_LOG)		+= nft_log.o
 obj-$(CONFIG_NFT_MASQ)		+= nft_masq.o
 obj-$(CONFIG_NFT_REDIR)		+= nft_redir.o
 obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
+obj-$(CONFIG_NFT_FIB)		+= nft_fib.o
+obj-$(CONFIG_NFT_FIB_INET)	+= nft_fib_inet.o
 
 # nf_tables netdev
 obj-$(CONFIG_NFT_DUP_NETDEV)	+= nft_dup_netdev.o
diff --git a/net/netfilter/nft_fib.c b/net/netfilter/nft_fib.c
new file mode 100644
index 000000000000..4944a8b7f7a7
--- /dev/null
+++ b/net/netfilter/nft_fib.c
@@ -0,0 +1,159 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Generic part shared by ipv4 and ipv6 backends.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nft_fib.h>
+
+const struct nla_policy nft_fib_policy[NFTA_FIB_MAX + 1] = {
+	[NFTA_FIB_DREG]		= { .type = NLA_U32 },
+	[NFTA_FIB_RESULT]	= { .type = NLA_U32 },
+	[NFTA_FIB_FLAGS]	= { .type = NLA_U32 },
+};
+EXPORT_SYMBOL(nft_fib_policy);
+
+#define NFTA_FIB_F_ALL (NFTA_FIB_F_SADDR | NFTA_FIB_F_DADDR | \
+			NFTA_FIB_F_MARK | NFTA_FIB_F_IIF | NFTA_FIB_F_OIF)
+
+int nft_fib_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		     const struct nft_data **data)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+	unsigned int hooks;
+
+	switch (priv->result) {
+	case NFT_FIB_RESULT_OIF: /* fallthrough */
+	case NFT_FIB_RESULT_OIFNAME:
+		hooks = (1 << NF_INET_PRE_ROUTING);
+		break;
+	case NFT_FIB_RESULT_ADDRTYPE:
+		if (priv->flags & NFTA_FIB_F_IIF)
+			hooks = (1 << NF_INET_PRE_ROUTING) |
+				(1 << NF_INET_LOCAL_IN) |
+				(1 << NF_INET_FORWARD);
+		else if (priv->flags & NFTA_FIB_F_OIF)
+			hooks = (1 << NF_INET_LOCAL_OUT) |
+				(1 << NF_INET_POST_ROUTING) |
+				(1 << NF_INET_FORWARD);
+		else
+			hooks = (1 << NF_INET_LOCAL_IN) |
+				(1 << NF_INET_LOCAL_OUT) |
+				(1 << NF_INET_FORWARD) |
+				(1 << NF_INET_PRE_ROUTING) |
+				(1 << NF_INET_POST_ROUTING);
+
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return nft_chain_validate_hooks(ctx->chain, hooks);
+}
+EXPORT_SYMBOL_GPL(nft_fib_validate);
+
+int nft_fib_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		 const struct nlattr * const tb[])
+{
+	struct nft_fib *priv = nft_expr_priv(expr);
+	unsigned int len;
+	int err;
+
+	if (!tb[NFTA_FIB_DREG] || !tb[NFTA_FIB_RESULT] || !tb[NFTA_FIB_FLAGS])
+		return -EINVAL;
+
+	priv->flags = ntohl(nla_get_be32(tb[NFTA_FIB_FLAGS]));
+
+	if (priv->flags == 0 || (priv->flags & ~NFTA_FIB_F_ALL))
+		return -EINVAL;
+
+	if ((priv->flags & (NFTA_FIB_F_SADDR | NFTA_FIB_F_DADDR)) ==
+			   (NFTA_FIB_F_SADDR | NFTA_FIB_F_DADDR))
+		return -EINVAL;
+	if ((priv->flags & (NFTA_FIB_F_IIF | NFTA_FIB_F_OIF)) ==
+			   (NFTA_FIB_F_IIF | NFTA_FIB_F_OIF))
+		return -EINVAL;
+	if ((priv->flags & (NFTA_FIB_F_SADDR | NFTA_FIB_F_DADDR)) == 0)
+		return -EINVAL;
+
+	priv->result = htonl(nla_get_be32(tb[NFTA_FIB_RESULT]));
+	priv->dreg = nft_parse_register(tb[NFTA_FIB_DREG]);
+
+	switch (priv->result) {
+	case NFT_FIB_RESULT_OIF:
+		if (priv->flags & NFTA_FIB_F_OIF)
+			return -EINVAL;
+		len = sizeof(int);
+		break;
+	case NFT_FIB_RESULT_OIFNAME:
+		if (priv->flags & NFTA_FIB_F_OIF)
+			return -EINVAL;
+		len = IFNAMSIZ;
+		break;
+	case NFT_FIB_RESULT_ADDRTYPE:
+		len = sizeof(u32);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	err = nft_validate_register_store(ctx, priv->dreg, NULL,
+					  NFT_DATA_VALUE, len);
+	if (err < 0)
+		return err;
+
+	return nft_fib_validate(ctx, expr, NULL);
+}
+EXPORT_SYMBOL_GPL(nft_fib_init);
+
+int nft_fib_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_FIB_DREG, priv->dreg))
+		return -1;
+
+	if (nla_put_be32(skb, NFTA_FIB_RESULT, htonl(priv->result)))
+		return -1;
+
+	if (nla_put_be32(skb, NFTA_FIB_FLAGS, htonl(priv->flags)))
+		return -1;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_fib_dump);
+
+void nft_fib_store_result(void *reg, enum nft_fib_result r,
+			  const struct nft_pktinfo *pkt, int index)
+{
+	struct net_device *dev;
+	u32 *dreg = reg;
+
+	switch (r) {
+	case NFT_FIB_RESULT_OIF:
+		*dreg = index;
+		break;
+	case NFT_FIB_RESULT_OIFNAME:
+		dev = dev_get_by_index_rcu(pkt->net, index);
+		strncpy(reg, dev ? dev->name : "", IFNAMSIZ);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		*dreg = 0;
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(nft_fib_store_result);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
diff --git a/net/netfilter/nft_fib_inet.c b/net/netfilter/nft_fib_inet.c
new file mode 100644
index 000000000000..fe8943b572b7
--- /dev/null
+++ b/net/netfilter/nft_fib_inet.c
@@ -0,0 +1,82 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+#include <net/netfilter/nf_tables.h>
+
+#include <net/netfilter/nft_fib.h>
+
+static void nft_fib_inet_eval(const struct nft_expr *expr,
+			      struct nft_regs *regs,
+			      const struct nft_pktinfo *pkt)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+
+	switch (pkt->pf) {
+	case NFPROTO_IPV4:
+		switch (priv->result) {
+		case NFT_FIB_RESULT_OIF:
+		case NFT_FIB_RESULT_OIFNAME:
+			return nft_fib4_eval(expr, regs, pkt);
+		case NFT_FIB_RESULT_ADDRTYPE:
+			return nft_fib4_eval_type(expr, regs, pkt);
+		}
+		break;
+	case NFPROTO_IPV6:
+		switch (priv->result) {
+		case NFT_FIB_RESULT_OIF:
+		case NFT_FIB_RESULT_OIFNAME:
+			return nft_fib6_eval(expr, regs, pkt);
+		case NFT_FIB_RESULT_ADDRTYPE:
+			return nft_fib6_eval_type(expr, regs, pkt);
+		}
+		break;
+	}
+
+	regs->verdict.code = NF_DROP;
+}
+
+static struct nft_expr_type nft_fib_inet_type;
+static const struct nft_expr_ops nft_fib_inet_ops = {
+	.type		= &nft_fib_inet_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_fib)),
+	.eval		= nft_fib_inet_eval,
+	.init		= nft_fib_init,
+	.dump		= nft_fib_dump,
+	.validate	= nft_fib_validate,
+};
+
+static struct nft_expr_type nft_fib_inet_type __read_mostly = {
+	.family		= NFPROTO_INET,
+	.name		= "fib",
+	.ops		= &nft_fib_inet_ops,
+	.policy		= nft_fib_policy,
+	.maxattr	= NFTA_FIB_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_fib_inet_module_init(void)
+{
+	return nft_register_expr(&nft_fib_inet_type);
+}
+
+static void __exit nft_fib_inet_module_exit(void)
+{
+	nft_unregister_expr(&nft_fib_inet_type);
+}
+
+module_init(nft_fib_inet_module_init);
+module_exit(nft_fib_inet_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_ALIAS_NFT_AF_EXPR(1, "fib");
-- 
2.1.4
