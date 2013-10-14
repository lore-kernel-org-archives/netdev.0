From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/17] netfilter: nf_tables: Add support for IPv6 NAT
Date: Mon, 14 Oct 2013 18:38:53 +0200
Message-ID: <1381768738-17739-13-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>

This patch generalizes the NAT expression to support both IPv4 and IPv6
using the existing IPv4/IPv6 NAT infrastructure. This also adds the
NAT chain type for IPv6.

This patch collapses the following patches that were posted to the
netfilter-devel mailing list, from Tomasz:

* nf_tables: Change NFTA_NAT_ attributes to better semantic significance
* nf_tables: Split IPv4 NAT into NAT expression and IPv4 NAT chain
* nf_tables: Add support for IPv6 NAT expression
* nf_tables: Add support for IPv6 NAT chain
* nf_tables: Fix up build issue on IPv6 NAT support

And, from Pablo Neira Ayuso:

* fix missing dependencies in nft_chain_nat

Signed-off-by: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |   18 +--
 net/ipv4/netfilter/Kconfig               |    1 +
 net/ipv4/netfilter/nft_chain_nat_ipv4.c  |  156 +--------------------
 net/ipv6/netfilter/Kconfig               |    5 +
 net/ipv6/netfilter/Makefile              |    1 +
 net/ipv6/netfilter/nft_chain_nat_ipv6.c  |  211 ++++++++++++++++++++++++++++
 net/netfilter/Kconfig                    |    6 +
 net/netfilter/Makefile                   |    1 +
 net/netfilter/nft_nat.c                  |  220 ++++++++++++++++++++++++++++++
 9 files changed, 457 insertions(+), 162 deletions(-)
 create mode 100644 net/ipv6/netfilter/nft_chain_nat_ipv6.c
 create mode 100644 net/netfilter/nft_nat.c

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index a9c4bce..7d4a199 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -695,18 +695,20 @@ enum nft_nat_types {
  * enum nft_nat_attributes - nf_tables nat expression netlink attributes
  *
  * @NFTA_NAT_TYPE: NAT type (NLA_U32: nft_nat_types)
- * @NFTA_NAT_ADDR_MIN: source register of address range start (NLA_U32: nft_registers)
- * @NFTA_NAT_ADDR_MAX: source register of address range end (NLA_U32: nft_registers)
- * @NFTA_NAT_PROTO_MIN: source register of proto range start (NLA_U32: nft_registers)
- * @NFTA_NAT_PROTO_MAX: source register of proto range end (NLA_U32: nft_registers)
+ * @NFTA_NAT_FAMILY: NAT family (NLA_U32)
+ * @NFTA_NAT_REG_ADDR_MIN: source register of address range start (NLA_U32: nft_registers)
+ * @NFTA_NAT_REG_ADDR_MAX: source register of address range end (NLA_U32: nft_registers)
+ * @NFTA_NAT_REG_PROTO_MIN: source register of proto range start (NLA_U32: nft_registers)
+ * @NFTA_NAT_REG_PROTO_MAX: source register of proto range end (NLA_U32: nft_registers)
  */
 enum nft_nat_attributes {
 	NFTA_NAT_UNSPEC,
 	NFTA_NAT_TYPE,
-	NFTA_NAT_ADDR_MIN,
-	NFTA_NAT_ADDR_MAX,
-	NFTA_NAT_PROTO_MIN,
-	NFTA_NAT_PROTO_MAX,
+	NFTA_NAT_FAMILY,
+	NFTA_NAT_REG_ADDR_MIN,
+	NFTA_NAT_REG_ADDR_MAX,
+	NFTA_NAT_REG_PROTO_MIN,
+	NFTA_NAT_REG_PROTO_MAX,
 	__NFTA_NAT_MAX
 };
 #define NFTA_NAT_MAX		(__NFTA_NAT_MAX - 1)
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index ae65fe9..1f37ef6 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -50,6 +50,7 @@ config NFT_CHAIN_ROUTE_IPV4
 
 config NFT_CHAIN_NAT_IPV4
 	depends on NF_TABLES_IPV4
+	depends on NF_NAT_IPV4 && NFT_NAT
 	tristate "IPv4 nf_tables nat chain support"
 
 config IP_NF_IPTABLES
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index e09c201..cf2c792 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -1,6 +1,7 @@
 /*
  * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  * Copyright (c) 2012 Pablo Neira Ayuso <pablo@netfilter.org>
+ * Copyright (c) 2012 Intel Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -14,10 +15,8 @@
 #include <linux/list.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
-#include <linux/netlink.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
-#include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_nat.h>
@@ -27,147 +26,6 @@
 #include <net/netfilter/nf_nat_l3proto.h>
 #include <net/ip.h>
 
-struct nft_nat {
-	enum nft_registers	sreg_addr_min:8;
-	enum nft_registers	sreg_addr_max:8;
-	enum nft_registers	sreg_proto_min:8;
-	enum nft_registers	sreg_proto_max:8;
-	enum nf_nat_manip_type	type;
-};
-
-static void nft_nat_eval(const struct nft_expr *expr,
-			 struct nft_data data[NFT_REG_MAX + 1],
-			 const struct nft_pktinfo *pkt)
-{
-	const struct nft_nat *priv = nft_expr_priv(expr);
-	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct = nf_ct_get(pkt->skb, &ctinfo);
-	struct nf_nat_range range;
-
-	memset(&range, 0, sizeof(range));
-	if (priv->sreg_addr_min) {
-		range.min_addr.ip = data[priv->sreg_addr_min].data[0];
-		range.max_addr.ip = data[priv->sreg_addr_max].data[0];
-		range.flags |= NF_NAT_RANGE_MAP_IPS;
-	}
-
-	if (priv->sreg_proto_min) {
-		range.min_proto.all = data[priv->sreg_proto_min].data[0];
-		range.max_proto.all = data[priv->sreg_proto_max].data[0];
-		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
-	}
-
-	data[NFT_REG_VERDICT].verdict =
-		nf_nat_setup_info(ct, &range, priv->type);
-}
-
-static const struct nla_policy nft_nat_policy[NFTA_NAT_MAX + 1] = {
-	[NFTA_NAT_ADDR_MIN]	= { .type = NLA_U32 },
-	[NFTA_NAT_ADDR_MAX]	= { .type = NLA_U32 },
-	[NFTA_NAT_PROTO_MIN]	= { .type = NLA_U32 },
-	[NFTA_NAT_PROTO_MAX]	= { .type = NLA_U32 },
-	[NFTA_NAT_TYPE]		= { .type = NLA_U32 },
-};
-
-static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
-			const struct nlattr * const tb[])
-{
-	struct nft_nat *priv = nft_expr_priv(expr);
-	int err;
-
-	if (tb[NFTA_NAT_TYPE] == NULL)
-		return -EINVAL;
-
-	switch (ntohl(nla_get_be32(tb[NFTA_NAT_TYPE]))) {
-	case NFT_NAT_SNAT:
-		priv->type = NF_NAT_MANIP_SRC;
-		break;
-	case NFT_NAT_DNAT:
-		priv->type = NF_NAT_MANIP_DST;
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	if (tb[NFTA_NAT_ADDR_MIN]) {
-		priv->sreg_addr_min = ntohl(nla_get_be32(tb[NFTA_NAT_ADDR_MIN]));
-		err = nft_validate_input_register(priv->sreg_addr_min);
-		if (err < 0)
-			return err;
-	}
-
-	if (tb[NFTA_NAT_ADDR_MAX]) {
-		priv->sreg_addr_max = ntohl(nla_get_be32(tb[NFTA_NAT_ADDR_MAX]));
-		err = nft_validate_input_register(priv->sreg_addr_max);
-		if (err < 0)
-			return err;
-	} else
-		priv->sreg_addr_max = priv->sreg_addr_min;
-
-	if (tb[NFTA_NAT_PROTO_MIN]) {
-		priv->sreg_proto_min = ntohl(nla_get_be32(tb[NFTA_NAT_PROTO_MIN]));
-		err = nft_validate_input_register(priv->sreg_proto_min);
-		if (err < 0)
-			return err;
-	}
-
-	if (tb[NFTA_NAT_PROTO_MAX]) {
-		priv->sreg_proto_max = ntohl(nla_get_be32(tb[NFTA_NAT_PROTO_MAX]));
-		err = nft_validate_input_register(priv->sreg_proto_max);
-		if (err < 0)
-			return err;
-	} else
-		priv->sreg_proto_max = priv->sreg_proto_min;
-
-	return 0;
-}
-
-static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr)
-{
-	const struct nft_nat *priv = nft_expr_priv(expr);
-
-	switch (priv->type) {
-	case NF_NAT_MANIP_SRC:
-		if (nla_put_be32(skb, NFTA_NAT_TYPE, htonl(NFT_NAT_SNAT)))
-			goto nla_put_failure;
-		break;
-	case NF_NAT_MANIP_DST:
-		if (nla_put_be32(skb, NFTA_NAT_TYPE, htonl(NFT_NAT_DNAT)))
-			goto nla_put_failure;
-		break;
-	}
-
-	if (nla_put_be32(skb, NFTA_NAT_ADDR_MIN, htonl(priv->sreg_addr_min)))
-		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_NAT_ADDR_MAX, htonl(priv->sreg_addr_max)))
-		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_NAT_PROTO_MIN, htonl(priv->sreg_proto_min)))
-		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_NAT_PROTO_MAX, htonl(priv->sreg_proto_max)))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return -1;
-}
-
-static struct nft_expr_type nft_nat_type;
-static const struct nft_expr_ops nft_nat_ops = {
-	.type		= &nft_nat_type,
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_nat)),
-	.eval		= nft_nat_eval,
-	.init		= nft_nat_init,
-	.dump		= nft_nat_dump,
-};
-
-static struct nft_expr_type nft_nat_type __read_mostly = {
-	.name		= "nat",
-	.ops		= &nft_nat_ops,
-	.policy		= nft_nat_policy,
-	.maxattr	= NFTA_NAT_MAX,
-	.owner		= THIS_MODULE,
-};
-
 /*
  * NAT chains
  */
@@ -306,7 +164,7 @@ static unsigned int nf_nat_output(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-struct nf_chain_type nft_chain_nat_ipv4 = {
+static struct nf_chain_type nft_chain_nat_ipv4 = {
 	.family		= NFPROTO_IPV4,
 	.name		= "nat",
 	.type		= NFT_CHAIN_T_NAT,
@@ -331,20 +189,11 @@ static int __init nft_chain_nat_init(void)
 	if (err < 0)
 		return err;
 
-	err = nft_register_expr(&nft_nat_type);
-	if (err < 0)
-		goto err;
-
 	return 0;
-
-err:
-	nft_unregister_chain_type(&nft_chain_nat_ipv4);
-	return err;
 }
 
 static void __exit nft_chain_nat_exit(void)
 {
-	nft_unregister_expr(&nft_nat_type);
 	nft_unregister_chain_type(&nft_chain_nat_ipv4);
 }
 
@@ -354,4 +203,3 @@ module_exit(nft_chain_nat_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_ALIAS_NFT_CHAIN(AF_INET, "nat");
-MODULE_ALIAS_NFT_EXPR("nat");
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 2383306..7702f9e 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -33,6 +33,11 @@ config NFT_CHAIN_ROUTE_IPV6
 	depends on NF_TABLES_IPV6
 	tristate "IPv6 nf_tables route chain support"
 
+config NFT_CHAIN_NAT_IPV6
+	depends on NF_TABLES_IPV6
+	depends on NF_NAT_IPV6 && NFT_NAT
+	tristate "IPv6 nf_tables nat chain support"
+
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering)"
 	depends on INET && IPV6
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index be4913a..d1b4928 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_NF_DEFRAG_IPV6) += nf_defrag_ipv6.o
 # nf_tables
 obj-$(CONFIG_NF_TABLES_IPV6) += nf_tables_ipv6.o
 obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV6) += nft_chain_route_ipv6.o
+obj-$(CONFIG_NFT_CHAIN_NAT_IPV6) += nft_chain_nat_ipv6.o
 
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
new file mode 100644
index 0000000..e86dcd7
--- /dev/null
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -0,0 +1,211 @@
+/*
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012 Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_ipv6.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/ipv6.h>
+
+/*
+ * IPv6 NAT chains
+ */
+
+static unsigned int nf_nat_ipv6_fn(const struct nf_hook_ops *ops,
+			      struct sk_buff *skb,
+			      const struct net_device *in,
+			      const struct net_device *out,
+			      int (*okfn)(struct sk_buff *))
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conn_nat *nat;
+	enum nf_nat_manip_type maniptype = HOOK2MANIP(ops->hooknum);
+	__be16 frag_off;
+	int hdrlen;
+	u8 nexthdr;
+	struct nft_pktinfo pkt;
+	unsigned int ret;
+
+	if (ct == NULL || nf_ct_is_untracked(ct))
+		return NF_ACCEPT;
+
+	nat = nfct_nat(ct);
+	if (nat == NULL) {
+		/* Conntrack module was loaded late, can't add extension. */
+		if (nf_ct_is_confirmed(ct))
+			return NF_ACCEPT;
+		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
+		if (nat == NULL)
+			return NF_ACCEPT;
+	}
+
+	switch (ctinfo) {
+	case IP_CT_RELATED:
+	case IP_CT_RELATED + IP_CT_IS_REPLY:
+		nexthdr = ipv6_hdr(skb)->nexthdr;
+		hdrlen = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr),
+					  &nexthdr, &frag_off);
+
+		if (hdrlen >= 0 && nexthdr == IPPROTO_ICMPV6) {
+			if (!nf_nat_icmpv6_reply_translation(skb, ct, ctinfo,
+							   ops->hooknum,
+							   hdrlen))
+				return NF_DROP;
+			else
+				return NF_ACCEPT;
+		}
+		/* Fall through */
+	case IP_CT_NEW:
+		if (nf_nat_initialized(ct, maniptype))
+			break;
+
+		nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out);
+
+		ret = nft_do_chain_pktinfo(&pkt, ops);
+		if (ret != NF_ACCEPT)
+			return ret;
+		if (!nf_nat_initialized(ct, maniptype)) {
+			ret = nf_nat_alloc_null_binding(ct, ops->hooknum);
+			if (ret != NF_ACCEPT)
+				return ret;
+		}
+	default:
+		break;
+	}
+
+	return nf_nat_packet(ct, ctinfo, ops->hooknum, skb);
+}
+
+static unsigned int nf_nat_ipv6_prerouting(const struct nf_hook_ops *ops,
+				      struct sk_buff *skb,
+				      const struct net_device *in,
+				      const struct net_device *out,
+				      int (*okfn)(struct sk_buff *))
+{
+	struct in6_addr daddr = ipv6_hdr(skb)->daddr;
+	unsigned int ret;
+
+	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    ipv6_addr_cmp(&daddr, &ipv6_hdr(skb)->daddr))
+		skb_dst_drop(skb);
+
+	return ret;
+}
+
+static unsigned int nf_nat_ipv6_postrouting(const struct nf_hook_ops *ops,
+				       struct sk_buff *skb,
+				       const struct net_device *in,
+				       const struct net_device *out,
+				       int (*okfn)(struct sk_buff *))
+{
+	enum ip_conntrack_info ctinfo __maybe_unused;
+	const struct nf_conn *ct __maybe_unused;
+	unsigned int ret;
+
+	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+#ifdef CONFIG_XFRM
+	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    !(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
+	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
+		if (!nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.src.u3,
+				      &ct->tuplehash[!dir].tuple.dst.u3) ||
+		    (ct->tuplehash[dir].tuple.src.u.all !=
+		     ct->tuplehash[!dir].tuple.dst.u.all))
+			if (nf_xfrm_me_harder(skb, AF_INET6) < 0)
+				ret = NF_DROP;
+	}
+#endif
+	return ret;
+}
+
+static unsigned int nf_nat_ipv6_output(const struct nf_hook_ops *ops,
+				  struct sk_buff *skb,
+				  const struct net_device *in,
+				  const struct net_device *out,
+				  int (*okfn)(struct sk_buff *))
+{
+	enum ip_conntrack_info ctinfo;
+	const struct nf_conn *ct;
+	unsigned int ret;
+
+	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
+		if (!nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.dst.u3,
+				      &ct->tuplehash[!dir].tuple.src.u3)) {
+			if (ip6_route_me_harder(skb))
+				ret = NF_DROP;
+		}
+#ifdef CONFIG_XFRM
+		else if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
+			 ct->tuplehash[dir].tuple.dst.u.all !=
+			 ct->tuplehash[!dir].tuple.src.u.all)
+			if (nf_xfrm_me_harder(skb, AF_INET6))
+				ret = NF_DROP;
+#endif
+	}
+	return ret;
+}
+
+static struct nf_chain_type nft_chain_nat_ipv6 = {
+	.family		= NFPROTO_IPV6,
+	.name		= "nat",
+	.type		= NFT_CHAIN_T_NAT,
+	.hook_mask	= (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_LOCAL_IN),
+	.fn		= {
+		[NF_INET_PRE_ROUTING]	= nf_nat_ipv6_prerouting,
+		[NF_INET_POST_ROUTING]	= nf_nat_ipv6_postrouting,
+		[NF_INET_LOCAL_OUT]	= nf_nat_ipv6_output,
+		[NF_INET_LOCAL_IN]	= nf_nat_ipv6_fn,
+	},
+	.me		= THIS_MODULE,
+};
+
+static int __init nft_chain_nat_ipv6_init(void)
+{
+	int err;
+
+	err = nft_register_chain_type(&nft_chain_nat_ipv6);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static void __exit nft_chain_nat_ipv6_exit(void)
+{
+	nft_unregister_chain_type(&nft_chain_nat_ipv6);
+}
+
+module_init(nft_chain_nat_ipv6_init);
+module_exit(nft_chain_nat_ipv6_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>");
+MODULE_ALIAS_NFT_CHAIN(AF_INET6, "nat");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 49e3627..48acec1 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -450,6 +450,12 @@ config NFT_LIMIT
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables limit module"
 
+config NFT_NAT
+	depends on NF_TABLES
+	depends on NF_CONNTRACK
+	depends on NF_NAT
+	tristate "Netfilter nf_tables nat module"
+
 config NFT_COMPAT
 	depends on NF_TABLES
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index a678145..394483b 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -75,6 +75,7 @@ obj-$(CONFIG_NFT_EXTHDR)	+= nft_exthdr.o
 obj-$(CONFIG_NFT_META)		+= nft_meta.o
 obj-$(CONFIG_NFT_CT)		+= nft_ct.o
 obj-$(CONFIG_NFT_LIMIT)		+= nft_limit.o
+obj-$(CONFIG_NFT_NAT)		+= nft_nat.o
 #nf_tables-objs			+= nft_meta_target.o
 obj-$(CONFIG_NFT_RBTREE)	+= nft_rbtree.o
 obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
new file mode 100644
index 0000000..b0b87b2
--- /dev/null
+++ b/net/netfilter/nft_nat.c
@@ -0,0 +1,220 @@
+/*
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012 Pablo Neira Ayuso <pablo@netfilter.org>
+ * Copyright (c) 2012 Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/string.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/ip.h>
+
+struct nft_nat {
+	enum nft_registers      sreg_addr_min:8;
+	enum nft_registers      sreg_addr_max:8;
+	enum nft_registers      sreg_proto_min:8;
+	enum nft_registers      sreg_proto_max:8;
+	int                     family;
+	enum nf_nat_manip_type  type;
+};
+
+static void nft_nat_eval(const struct nft_expr *expr,
+			 struct nft_data data[NFT_REG_MAX + 1],
+			 const struct nft_pktinfo *pkt)
+{
+	const struct nft_nat *priv = nft_expr_priv(expr);
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = nf_ct_get(pkt->skb, &ctinfo);
+	struct nf_nat_range range;
+
+	memset(&range, 0, sizeof(range));
+	if (priv->sreg_addr_min) {
+		if (priv->family == AF_INET) {
+			range.min_addr.ip = data[priv->sreg_addr_min].data[0];
+			range.max_addr.ip = data[priv->sreg_addr_max].data[0];
+
+		} else {
+			memcpy(range.min_addr.ip6,
+			       data[priv->sreg_addr_min].data,
+			       sizeof(struct nft_data));
+			memcpy(range.max_addr.ip6,
+			       data[priv->sreg_addr_max].data,
+			       sizeof(struct nft_data));
+		}
+		range.flags |= NF_NAT_RANGE_MAP_IPS;
+	}
+
+	if (priv->sreg_proto_min) {
+		range.min_proto.all = data[priv->sreg_proto_min].data[0];
+		range.max_proto.all = data[priv->sreg_proto_max].data[0];
+		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
+	}
+
+	data[NFT_REG_VERDICT].verdict =
+		nf_nat_setup_info(ct, &range, priv->type);
+}
+
+static const struct nla_policy nft_nat_policy[NFTA_NAT_MAX + 1] = {
+	[NFTA_NAT_TYPE]		 = { .type = NLA_U32 },
+	[NFTA_NAT_FAMILY]	 = { .type = NLA_U32 },
+	[NFTA_NAT_REG_ADDR_MIN]	 = { .type = NLA_U32 },
+	[NFTA_NAT_REG_ADDR_MAX]	 = { .type = NLA_U32 },
+	[NFTA_NAT_REG_PROTO_MIN] = { .type = NLA_U32 },
+	[NFTA_NAT_REG_PROTO_MAX] = { .type = NLA_U32 },
+};
+
+static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+			const struct nlattr * const tb[])
+{
+	struct nft_nat *priv = nft_expr_priv(expr);
+	int err;
+
+	if (tb[NFTA_NAT_TYPE] == NULL)
+		return -EINVAL;
+
+	switch (ntohl(nla_get_be32(tb[NFTA_NAT_TYPE]))) {
+	case NFT_NAT_SNAT:
+		priv->type = NF_NAT_MANIP_SRC;
+		break;
+	case NFT_NAT_DNAT:
+		priv->type = NF_NAT_MANIP_DST;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (tb[NFTA_NAT_FAMILY] == NULL)
+		return -EINVAL;
+
+	priv->family = ntohl(nla_get_be32(tb[NFTA_NAT_FAMILY]));
+	if (priv->family != AF_INET && priv->family != AF_INET6)
+		return -EINVAL;
+
+	if (tb[NFTA_NAT_REG_ADDR_MIN]) {
+		priv->sreg_addr_min = ntohl(nla_get_be32(
+						tb[NFTA_NAT_REG_ADDR_MIN]));
+		err = nft_validate_input_register(priv->sreg_addr_min);
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[NFTA_NAT_REG_ADDR_MAX]) {
+		priv->sreg_addr_max = ntohl(nla_get_be32(
+						tb[NFTA_NAT_REG_ADDR_MAX]));
+		err = nft_validate_input_register(priv->sreg_addr_max);
+		if (err < 0)
+			return err;
+	} else
+		priv->sreg_addr_max = priv->sreg_addr_min;
+
+	if (tb[NFTA_NAT_REG_PROTO_MIN]) {
+		priv->sreg_proto_min = ntohl(nla_get_be32(
+						tb[NFTA_NAT_REG_PROTO_MIN]));
+		err = nft_validate_input_register(priv->sreg_proto_min);
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[NFTA_NAT_REG_PROTO_MAX]) {
+		priv->sreg_proto_max = ntohl(nla_get_be32(
+						tb[NFTA_NAT_REG_PROTO_MAX]));
+		err = nft_validate_input_register(priv->sreg_proto_max);
+		if (err < 0)
+			return err;
+	} else
+		priv->sreg_proto_max = priv->sreg_proto_min;
+
+	return 0;
+}
+
+static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_nat *priv = nft_expr_priv(expr);
+
+	switch (priv->type) {
+	case NF_NAT_MANIP_SRC:
+		if (nla_put_be32(skb, NFTA_NAT_TYPE, htonl(NFT_NAT_SNAT)))
+			goto nla_put_failure;
+		break;
+	case NF_NAT_MANIP_DST:
+		if (nla_put_be32(skb, NFTA_NAT_TYPE, htonl(NFT_NAT_DNAT)))
+			goto nla_put_failure;
+		break;
+	}
+
+	if (nla_put_be32(skb, NFTA_NAT_FAMILY, htonl(priv->family)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb,
+			 NFTA_NAT_REG_ADDR_MIN, htonl(priv->sreg_addr_min)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb,
+			 NFTA_NAT_REG_ADDR_MAX, htonl(priv->sreg_addr_max)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb,
+			 NFTA_NAT_REG_PROTO_MIN, htonl(priv->sreg_proto_min)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb,
+			 NFTA_NAT_REG_PROTO_MAX, htonl(priv->sreg_proto_max)))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_nat_type;
+static const struct nft_expr_ops nft_nat_ops = {
+	.type           = &nft_nat_type,
+	.size           = NFT_EXPR_SIZE(sizeof(struct nft_nat)),
+	.eval           = nft_nat_eval,
+	.init           = nft_nat_init,
+	.dump           = nft_nat_dump,
+};
+
+static struct nft_expr_type nft_nat_type __read_mostly = {
+	.name           = "nat",
+	.ops            = &nft_nat_ops,
+	.policy         = nft_nat_policy,
+	.maxattr        = NFTA_NAT_MAX,
+	.owner          = THIS_MODULE,
+};
+
+static int __init nft_nat_module_init(void)
+{
+	int err;
+
+	err = nft_register_expr(&nft_nat_type);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static void __exit nft_nat_module_exit(void)
+{
+	nft_unregister_expr(&nft_nat_type);
+}
+
+module_init(nft_nat_module_init);
+module_exit(nft_nat_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>");
+MODULE_ALIAS_NFT_EXPR("nat");
-- 
1.7.10.4

