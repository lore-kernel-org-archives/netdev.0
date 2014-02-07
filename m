From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/18] netfilter: nft_reject: split up reject module into IPv4 and IPv6 specifc parts
Date: Fri,  7 Feb 2014 18:41:37 +0100
Message-ID: <1391794904-4017-12-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Currently the nft_reject module depends on symbols from ipv6. This is
wrong since no generic module should force IPv6 support to be loaded.
Split up the module into AF-specific and a generic part.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nft_reject.h   |   17 +++++++
 net/ipv4/netfilter/Kconfig           |    5 ++
 net/ipv4/netfilter/Makefile          |    1 +
 net/ipv4/netfilter/nft_reject_ipv4.c |   74 ++++++++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig           |    5 ++
 net/ipv6/netfilter/Makefile          |    1 +
 net/ipv6/netfilter/nft_reject_ipv6.c |   75 ++++++++++++++++++++++++++++
 net/netfilter/Kconfig                |    1 -
 net/netfilter/nft_reject.c           |   89 ++++------------------------------
 9 files changed, 187 insertions(+), 81 deletions(-)
 create mode 100644 include/net/netfilter/nft_reject.h
 create mode 100644 net/ipv4/netfilter/nft_reject_ipv4.c
 create mode 100644 net/ipv6/netfilter/nft_reject_ipv6.c

diff --git a/include/net/netfilter/nft_reject.h b/include/net/netfilter/nft_reject.h
new file mode 100644
index 0000000..ecda759
--- /dev/null
+++ b/include/net/netfilter/nft_reject.h
@@ -0,0 +1,17 @@
+#ifndef _NFT_REJECT_H_
+#define _NFT_REJECT_H_
+
+struct nft_reject {
+	enum nft_reject_types	type:8;
+	u8			icmp_code;
+};
+
+extern const struct nla_policy nft_reject_policy[];
+
+int nft_reject_init(const struct nft_ctx *ctx,
+		    const struct nft_expr *expr,
+		    const struct nlattr * const tb[]);
+
+int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr);
+
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 81c6910..a26ce03 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -61,6 +61,11 @@ config NFT_CHAIN_NAT_IPV4
 	  packet transformations such as the source, destination address and
 	  source and destination ports.
 
+config NFT_REJECT_IPV4
+	depends on NF_TABLES_IPV4
+	default NFT_REJECT
+	tristate
+
 config NF_TABLES_ARP
 	depends on NF_TABLES
 	tristate "ARP nf_tables support"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index c16be9d..90b8240 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
 obj-$(CONFIG_NF_TABLES_IPV4) += nf_tables_ipv4.o
 obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV4) += nft_chain_route_ipv4.o
 obj-$(CONFIG_NFT_CHAIN_NAT_IPV4) += nft_chain_nat_ipv4.o
+obj-$(CONFIG_NFT_REJECT_IPV4) += nft_reject_ipv4.o
 obj-$(CONFIG_NF_TABLES_ARP) += nf_tables_arp.o
 
 # generic IP tables 
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
new file mode 100644
index 0000000..e935d8d
--- /dev/null
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -0,0 +1,74 @@
+/*
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2013 Eric Leblond <eric@regit.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/icmp.h>
+#include <net/netfilter/ipv4/nf_reject.h>
+#include <net/netfilter/nft_reject.h>
+
+static void nft_reject_ipv4_eval(const struct nft_expr *expr,
+				 struct nft_data data[NFT_REG_MAX + 1],
+				 const struct nft_pktinfo *pkt)
+{
+	struct nft_reject *priv = nft_expr_priv(expr);
+
+	switch (priv->type) {
+	case NFT_REJECT_ICMP_UNREACH:
+		nf_send_unreach(pkt->skb, priv->icmp_code);
+		break;
+	case NFT_REJECT_TCP_RST:
+		nf_send_reset(pkt->skb, pkt->ops->hooknum);
+		break;
+	}
+
+	data[NFT_REG_VERDICT].verdict = NF_DROP;
+}
+
+static struct nft_expr_type nft_reject_ipv4_type;
+static const struct nft_expr_ops nft_reject_ipv4_ops = {
+	.type		= &nft_reject_ipv4_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_reject)),
+	.eval		= nft_reject_ipv4_eval,
+	.init		= nft_reject_init,
+	.dump		= nft_reject_dump,
+};
+
+static struct nft_expr_type nft_reject_ipv4_type __read_mostly = {
+	.family		= NFPROTO_IPV4,
+	.name		= "reject",
+	.ops		= &nft_reject_ipv4_ops,
+	.policy		= nft_reject_policy,
+	.maxattr	= NFTA_REJECT_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_reject_ipv4_module_init(void)
+{
+	return nft_register_expr(&nft_reject_ipv4_type);
+}
+
+static void __exit nft_reject_ipv4_module_exit(void)
+{
+	nft_unregister_expr(&nft_reject_ipv4_type);
+}
+
+module_init(nft_reject_ipv4_module_init);
+module_exit(nft_reject_ipv4_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS_NFT_AF_EXPR(AF_INET, "reject");
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 35750df..4bff1f2 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -50,6 +50,11 @@ config NFT_CHAIN_NAT_IPV6
 	  packet transformations such as the source, destination address and
 	  source and destination ports.
 
+config NFT_REJECT_IPV6
+	depends on NF_TABLES_IPV6
+	default NFT_REJECT
+	tristate
+
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering)"
 	depends on INET && IPV6
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index d1b4928..70d3dd6 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_NF_DEFRAG_IPV6) += nf_defrag_ipv6.o
 obj-$(CONFIG_NF_TABLES_IPV6) += nf_tables_ipv6.o
 obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV6) += nft_chain_route_ipv6.o
 obj-$(CONFIG_NFT_CHAIN_NAT_IPV6) += nft_chain_nat_ipv6.o
+obj-$(CONFIG_NFT_REJECT_IPV6) += nft_reject_ipv6.o
 
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
new file mode 100644
index 0000000..f732859
--- /dev/null
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -0,0 +1,75 @@
+/*
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2013 Eric Leblond <eric@regit.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nft_reject.h>
+#include <net/netfilter/ipv6/nf_reject.h>
+
+static void nft_reject_ipv6_eval(const struct nft_expr *expr,
+				 struct nft_data data[NFT_REG_MAX + 1],
+				 const struct nft_pktinfo *pkt)
+{
+	struct nft_reject *priv = nft_expr_priv(expr);
+	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
+
+	switch (priv->type) {
+	case NFT_REJECT_ICMP_UNREACH:
+		nf_send_unreach6(net, pkt->skb, priv->icmp_code,
+				 pkt->ops->hooknum);
+		break;
+	case NFT_REJECT_TCP_RST:
+		nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
+		break;
+	}
+
+	data[NFT_REG_VERDICT].verdict = NF_DROP;
+}
+
+static struct nft_expr_type nft_reject_ipv6_type;
+static const struct nft_expr_ops nft_reject_ipv6_ops = {
+	.type		= &nft_reject_ipv6_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_reject)),
+	.eval		= nft_reject_ipv6_eval,
+	.init		= nft_reject_init,
+	.dump		= nft_reject_dump,
+};
+
+static struct nft_expr_type nft_reject_ipv6_type __read_mostly = {
+	.family		= NFPROTO_IPV6,
+	.name		= "reject",
+	.ops		= &nft_reject_ipv6_ops,
+	.policy		= nft_reject_policy,
+	.maxattr	= NFTA_REJECT_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_reject_ipv6_module_init(void)
+{
+	return nft_register_expr(&nft_reject_ipv6_type);
+}
+
+static void __exit nft_reject_ipv6_module_exit(void)
+{
+	nft_unregister_expr(&nft_reject_ipv6_type);
+}
+
+module_init(nft_reject_ipv6_module_init);
+module_exit(nft_reject_ipv6_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS_NFT_AF_EXPR(AF_INET6, "reject");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c374675..ed8b50e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -513,7 +513,6 @@ config NFT_QUEUE
 
 config NFT_REJECT
 	depends on NF_TABLES
-	depends on NF_TABLES_IPV6 || !NF_TABLES_IPV6
 	default m if NETFILTER_ADVANCED=n
 	tristate "Netfilter nf_tables reject support"
 	help
diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
index 5e204711..f3448c2 100644
--- a/net/netfilter/nft_reject.c
+++ b/net/netfilter/nft_reject.c
@@ -16,65 +16,23 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
-#include <net/icmp.h>
-#include <net/netfilter/ipv4/nf_reject.h>
+#include <net/netfilter/nft_reject.h>
 
-#if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
-#include <net/netfilter/ipv6/nf_reject.h>
-#endif
-
-struct nft_reject {
-	enum nft_reject_types	type:8;
-	u8			icmp_code;
-	u8			family;
-};
-
-static void nft_reject_eval(const struct nft_expr *expr,
-			      struct nft_data data[NFT_REG_MAX + 1],
-			      const struct nft_pktinfo *pkt)
-{
-	struct nft_reject *priv = nft_expr_priv(expr);
-#if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
-	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
-#endif
-	switch (priv->type) {
-	case NFT_REJECT_ICMP_UNREACH:
-		if (priv->family == NFPROTO_IPV4)
-			nf_send_unreach(pkt->skb, priv->icmp_code);
-#if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
-		else if (priv->family == NFPROTO_IPV6)
-			nf_send_unreach6(net, pkt->skb, priv->icmp_code,
-				      pkt->ops->hooknum);
-#endif
-		break;
-	case NFT_REJECT_TCP_RST:
-		if (priv->family == NFPROTO_IPV4)
-			nf_send_reset(pkt->skb, pkt->ops->hooknum);
-#if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
-		else if (priv->family == NFPROTO_IPV6)
-			nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
-#endif
-		break;
-	}
-
-	data[NFT_REG_VERDICT].verdict = NF_DROP;
-}
-
-static const struct nla_policy nft_reject_policy[NFTA_REJECT_MAX + 1] = {
+const struct nla_policy nft_reject_policy[NFTA_REJECT_MAX + 1] = {
 	[NFTA_REJECT_TYPE]		= { .type = NLA_U32 },
 	[NFTA_REJECT_ICMP_CODE]		= { .type = NLA_U8 },
 };
+EXPORT_SYMBOL_GPL(nft_reject_policy);
 
-static int nft_reject_init(const struct nft_ctx *ctx,
-			   const struct nft_expr *expr,
-			   const struct nlattr * const tb[])
+int nft_reject_init(const struct nft_ctx *ctx,
+		    const struct nft_expr *expr,
+		    const struct nlattr * const tb[])
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 
 	if (tb[NFTA_REJECT_TYPE] == NULL)
 		return -EINVAL;
 
-	priv->family = ctx->afi->family;
 	priv->type = ntohl(nla_get_be32(tb[NFTA_REJECT_TYPE]));
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
@@ -89,8 +47,9 @@ static int nft_reject_init(const struct nft_ctx *ctx,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nft_reject_init);
 
-static int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr)
+int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_reject *priv = nft_expr_priv(expr);
 
@@ -109,37 +68,7 @@ static int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr)
 nla_put_failure:
 	return -1;
 }
-
-static struct nft_expr_type nft_reject_type;
-static const struct nft_expr_ops nft_reject_ops = {
-	.type		= &nft_reject_type,
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_reject)),
-	.eval		= nft_reject_eval,
-	.init		= nft_reject_init,
-	.dump		= nft_reject_dump,
-};
-
-static struct nft_expr_type nft_reject_type __read_mostly = {
-	.name		= "reject",
-	.ops		= &nft_reject_ops,
-	.policy		= nft_reject_policy,
-	.maxattr	= NFTA_REJECT_MAX,
-	.owner		= THIS_MODULE,
-};
-
-static int __init nft_reject_module_init(void)
-{
-	return nft_register_expr(&nft_reject_type);
-}
-
-static void __exit nft_reject_module_exit(void)
-{
-	nft_unregister_expr(&nft_reject_type);
-}
-
-module_init(nft_reject_module_init);
-module_exit(nft_reject_module_exit);
+EXPORT_SYMBOL_GPL(nft_reject_dump);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_ALIAS_NFT_EXPR("reject");
-- 
1.7.10.4

