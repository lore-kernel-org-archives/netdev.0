From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/12] netfilter: nf_tables: introduce routing expression
Date: Tue,  1 Nov 2016 22:26:31 +0100
Message-ID: <1478035593-1362-11-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Anders K. Pedersen" <akp@cohaesio.com>

Introduces an nftables rt expression for routing related data with support
for nexthop (i.e. the directly connected IP address that an outgoing packet
is sent to), which can be used either for matching or accounting, eg.

 # nft add rule filter postrouting \
	ip daddr 192.168.1.0/24 rt nexthop != 192.168.0.1 drop

This will drop any traffic to 192.168.1.0/24 that is not routed via
192.168.0.1.

 # nft add rule filter postrouting \
	flow table acct { rt nexthop timeout 600s counter }
 # nft add rule ip6 filter postrouting \
	flow table acct { rt nexthop timeout 600s counter }

These rules count outgoing traffic per nexthop. Note that the timeout
releases an entry if no traffic is seen for this nexthop within 10 minutes.

 # nft add rule inet filter postrouting \
	ether type ip \
	flow table acct { rt nexthop timeout 600s counter }
 # nft add rule inet filter postrouting \
	ether type ip6 \
	flow table acct { rt nexthop timeout 600s counter }

Same as above, but via the inet family, where the ether type must be
specified explicitly.

"rt classid" is also implemented identical to "meta rtclassid", since it
is more logical to have this match in the routing expression going forward.

Signed-off-by: Anders K. Pedersen <akp@cohaesio.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  27 ++++++
 net/netfilter/Kconfig                    |   6 ++
 net/netfilter/Makefile                   |   1 +
 net/netfilter/nft_rt.c                   | 153 +++++++++++++++++++++++++++++++
 4 files changed, 187 insertions(+)
 create mode 100644 net/netfilter/nft_rt.c

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index a054ad2c8853..14e5f619167e 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -759,6 +759,19 @@ enum nft_meta_keys {
 };
 
 /**
+ * enum nft_rt_keys - nf_tables routing expression keys
+ *
+ * @NFT_RT_CLASSID: realm value of packet's route (skb->dst->tclassid)
+ * @NFT_RT_NEXTHOP4: routing nexthop for IPv4
+ * @NFT_RT_NEXTHOP6: routing nexthop for IPv6
+ */
+enum nft_rt_keys {
+	NFT_RT_CLASSID,
+	NFT_RT_NEXTHOP4,
+	NFT_RT_NEXTHOP6,
+};
+
+/**
  * enum nft_hash_attributes - nf_tables hash expression netlink attributes
  *
  * @NFTA_HASH_SREG: source register (NLA_U32)
@@ -797,6 +810,20 @@ enum nft_meta_attributes {
 #define NFTA_META_MAX		(__NFTA_META_MAX - 1)
 
 /**
+ * enum nft_rt_attributes - nf_tables routing expression netlink attributes
+ *
+ * @NFTA_RT_DREG: destination register (NLA_U32)
+ * @NFTA_RT_KEY: routing data item to load (NLA_U32: nft_rt_keys)
+ */
+enum nft_rt_attributes {
+	NFTA_RT_UNSPEC,
+	NFTA_RT_DREG,
+	NFTA_RT_KEY,
+	__NFTA_RT_MAX
+};
+#define NFTA_RT_MAX		(__NFTA_RT_MAX - 1)
+
+/**
  * enum nft_ct_keys - nf_tables ct expression keys
  *
  * @NFT_CT_STATE: conntrack state (bitmask of enum ip_conntrack_info)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ed00ec114ea2..44410d30d461 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -478,6 +478,12 @@ config NFT_META
 	  This option adds the "meta" expression that you can use to match and
 	  to set packet metainformation such as the packet mark.
 
+config NFT_RT
+	tristate "Netfilter nf_tables routing module"
+	help
+	  This option adds the "rt" expression that you can use to match
+	  packet routing information such as the packet nexthop.
+
 config NFT_NUMGEN
 	tristate "Netfilter nf_tables number generator module"
 	help
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 8edd791743fe..5bbf767672ec 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -84,6 +84,7 @@ obj-$(CONFIG_NF_TABLES_NETDEV)	+= nf_tables_netdev.o
 obj-$(CONFIG_NFT_COMPAT)	+= nft_compat.o
 obj-$(CONFIG_NFT_EXTHDR)	+= nft_exthdr.o
 obj-$(CONFIG_NFT_META)		+= nft_meta.o
+obj-$(CONFIG_NFT_RT)		+= nft_rt.o
 obj-$(CONFIG_NFT_NUMGEN)	+= nft_numgen.o
 obj-$(CONFIG_NFT_CT)		+= nft_ct.o
 obj-$(CONFIG_NFT_LIMIT)		+= nft_limit.o
diff --git a/net/netfilter/nft_rt.c b/net/netfilter/nft_rt.c
new file mode 100644
index 000000000000..9e5ec1f67020
--- /dev/null
+++ b/net/netfilter/nft_rt.c
@@ -0,0 +1,153 @@
+/*
+ * Copyright (c) 2016 Anders K. Pedersen <akp@cohaesio.com>
+ *
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
+#include <net/dst.h>
+#include <net/ip6_route.h>
+#include <net/route.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+
+struct nft_rt {
+	enum nft_rt_keys	key:8;
+	enum nft_registers	dreg:8;
+};
+
+void nft_rt_get_eval(const struct nft_expr *expr,
+		     struct nft_regs *regs,
+		     const struct nft_pktinfo *pkt)
+{
+	const struct nft_rt *priv = nft_expr_priv(expr);
+	const struct sk_buff *skb = pkt->skb;
+	u32 *dest = &regs->data[priv->dreg];
+	const struct dst_entry *dst;
+
+	dst = skb_dst(skb);
+	if (!dst)
+		goto err;
+
+	switch (priv->key) {
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	case NFT_RT_CLASSID:
+		*dest = dst->tclassid;
+		break;
+#endif
+	case NFT_RT_NEXTHOP4:
+		if (pkt->pf != NFPROTO_IPV4)
+			goto err;
+
+		*dest = rt_nexthop((const struct rtable *)dst,
+				   ip_hdr(skb)->daddr);
+		break;
+	case NFT_RT_NEXTHOP6:
+		if (pkt->pf != NFPROTO_IPV6)
+			goto err;
+
+		memcpy(dest, rt6_nexthop((struct rt6_info *)dst,
+					 &ipv6_hdr(skb)->daddr),
+		       sizeof(struct in6_addr));
+		break;
+	default:
+		WARN_ON(1);
+		goto err;
+	}
+	return;
+
+err:
+	regs->verdict.code = NFT_BREAK;
+}
+
+const struct nla_policy nft_rt_policy[NFTA_RT_MAX + 1] = {
+	[NFTA_RT_DREG]		= { .type = NLA_U32 },
+	[NFTA_RT_KEY]		= { .type = NLA_U32 },
+};
+
+int nft_rt_get_init(const struct nft_ctx *ctx,
+		    const struct nft_expr *expr,
+		    const struct nlattr * const tb[])
+{
+	struct nft_rt *priv = nft_expr_priv(expr);
+	unsigned int len;
+
+	if (tb[NFTA_RT_KEY] == NULL ||
+	    tb[NFTA_RT_DREG] == NULL)
+		return -EINVAL;
+
+	priv->key = ntohl(nla_get_be32(tb[NFTA_RT_KEY]));
+	switch (priv->key) {
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	case NFT_RT_CLASSID:
+#endif
+	case NFT_RT_NEXTHOP4:
+		len = sizeof(u32);
+		break;
+	case NFT_RT_NEXTHOP6:
+		len = sizeof(struct in6_addr);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	priv->dreg = nft_parse_register(tb[NFTA_RT_DREG]);
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, len);
+}
+
+int nft_rt_get_dump(struct sk_buff *skb,
+		    const struct nft_expr *expr)
+{
+	const struct nft_rt *priv = nft_expr_priv(expr);
+
+	if (nla_put_be32(skb, NFTA_RT_KEY, htonl(priv->key)))
+		goto nla_put_failure;
+	if (nft_dump_register(skb, NFTA_RT_DREG, priv->dreg))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_rt_type;
+static const struct nft_expr_ops nft_rt_get_ops = {
+	.type		= &nft_rt_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_rt)),
+	.eval		= nft_rt_get_eval,
+	.init		= nft_rt_get_init,
+	.dump		= nft_rt_get_dump,
+};
+
+static struct nft_expr_type nft_rt_type __read_mostly = {
+	.name		= "rt",
+	.ops		= &nft_rt_get_ops,
+	.policy		= nft_rt_policy,
+	.maxattr	= NFTA_RT_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_rt_module_init(void)
+{
+	return nft_register_expr(&nft_rt_type);
+}
+
+static void __exit nft_rt_module_exit(void)
+{
+	nft_unregister_expr(&nft_rt_type);
+}
+
+module_init(nft_rt_module_init);
+module_exit(nft_rt_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Anders K. Pedersen <akp@cohaesio.com>");
+MODULE_ALIAS_NFT_EXPR("rt");
-- 
2.1.4

