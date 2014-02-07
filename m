From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/18] netfilter: nf_tables: add reject module for NFPROTO_INET
Date: Fri,  7 Feb 2014 18:41:38 +0100
Message-ID: <1391794904-4017-13-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41432 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086AbaBGRmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:11 -0500
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add a reject module for NFPROTO_INET. It does nothing but dispatch
to the AF-specific modules based on the hook family.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nft_reject.h   |    8 +++++
 net/ipv4/netfilter/nft_reject_ipv4.c |    7 ++--
 net/ipv6/netfilter/nft_reject_ipv6.c |    7 ++--
 net/netfilter/Kconfig                |    5 +++
 net/netfilter/Makefile               |    1 +
 net/netfilter/nft_reject_inet.c      |   63 ++++++++++++++++++++++++++++++++++
 6 files changed, 85 insertions(+), 6 deletions(-)
 create mode 100644 net/netfilter/nft_reject_inet.c

diff --git a/include/net/netfilter/nft_reject.h b/include/net/netfilter/nft_reject.h
index ecda759..36b0da2 100644
--- a/include/net/netfilter/nft_reject.h
+++ b/include/net/netfilter/nft_reject.h
@@ -14,4 +14,12 @@ int nft_reject_init(const struct nft_ctx *ctx,
 
 int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr);
 
+void nft_reject_ipv4_eval(const struct nft_expr *expr,
+			  struct nft_data data[NFT_REG_MAX + 1],
+			  const struct nft_pktinfo *pkt);
+
+void nft_reject_ipv6_eval(const struct nft_expr *expr,
+			  struct nft_data data[NFT_REG_MAX + 1],
+			  const struct nft_pktinfo *pkt);
+
 #endif
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index e935d8d..e79718a 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -20,9 +20,9 @@
 #include <net/netfilter/ipv4/nf_reject.h>
 #include <net/netfilter/nft_reject.h>
 
-static void nft_reject_ipv4_eval(const struct nft_expr *expr,
-				 struct nft_data data[NFT_REG_MAX + 1],
-				 const struct nft_pktinfo *pkt)
+void nft_reject_ipv4_eval(const struct nft_expr *expr,
+			  struct nft_data data[NFT_REG_MAX + 1],
+			  const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 
@@ -37,6 +37,7 @@ static void nft_reject_ipv4_eval(const struct nft_expr *expr,
 
 	data[NFT_REG_VERDICT].verdict = NF_DROP;
 }
+EXPORT_SYMBOL_GPL(nft_reject_ipv4_eval);
 
 static struct nft_expr_type nft_reject_ipv4_type;
 static const struct nft_expr_ops nft_reject_ipv4_ops = {
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index f732859..0bc19fa 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -19,9 +19,9 @@
 #include <net/netfilter/nft_reject.h>
 #include <net/netfilter/ipv6/nf_reject.h>
 
-static void nft_reject_ipv6_eval(const struct nft_expr *expr,
-				 struct nft_data data[NFT_REG_MAX + 1],
-				 const struct nft_pktinfo *pkt)
+void nft_reject_ipv6_eval(const struct nft_expr *expr,
+			  struct nft_data data[NFT_REG_MAX + 1],
+			  const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
@@ -38,6 +38,7 @@ static void nft_reject_ipv6_eval(const struct nft_expr *expr,
 
 	data[NFT_REG_VERDICT].verdict = NF_DROP;
 }
+EXPORT_SYMBOL_GPL(nft_reject_ipv6_eval);
 
 static struct nft_expr_type nft_reject_ipv6_type;
 static const struct nft_expr_ops nft_reject_ipv6_ops = {
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ed8b50e..e9410d1 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -520,6 +520,11 @@ config NFT_REJECT
 	  explicitly deny and notify via TCP reset/ICMP informational errors
 	  unallowed traffic.
 
+config NFT_REJECT_INET
+	depends on NF_TABLES_INET
+	default NFT_REJECT
+	tristate
+
 config NFT_COMPAT
 	depends on NF_TABLES
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index ee9c4de..bffdad7 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -79,6 +79,7 @@ obj-$(CONFIG_NFT_LIMIT)		+= nft_limit.o
 obj-$(CONFIG_NFT_NAT)		+= nft_nat.o
 obj-$(CONFIG_NFT_QUEUE)		+= nft_queue.o
 obj-$(CONFIG_NFT_REJECT) 	+= nft_reject.o
+obj-$(CONFIG_NFT_REJECT_INET)	+= nft_reject_inet.o
 obj-$(CONFIG_NFT_RBTREE)	+= nft_rbtree.o
 obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
 obj-$(CONFIG_NFT_COUNTER)	+= nft_counter.o
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
new file mode 100644
index 0000000..8a310f2
--- /dev/null
+++ b/net/netfilter/nft_reject_inet.c
@@ -0,0 +1,63 @@
+/*
+ * Copyright (c) 2014 Patrick McHardy <kaber@trash.net>
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
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nft_reject.h>
+
+static void nft_reject_inet_eval(const struct nft_expr *expr,
+				 struct nft_data data[NFT_REG_MAX + 1],
+				 const struct nft_pktinfo *pkt)
+{
+	switch (pkt->ops->pf) {
+	case NFPROTO_IPV4:
+		nft_reject_ipv4_eval(expr, data, pkt);
+	case NFPROTO_IPV6:
+		nft_reject_ipv6_eval(expr, data, pkt);
+	}
+}
+
+static struct nft_expr_type nft_reject_inet_type;
+static const struct nft_expr_ops nft_reject_inet_ops = {
+	.type		= &nft_reject_inet_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_reject)),
+	.eval		= nft_reject_inet_eval,
+	.init		= nft_reject_init,
+	.dump		= nft_reject_dump,
+};
+
+static struct nft_expr_type nft_reject_inet_type __read_mostly = {
+	.family		= NFPROTO_INET,
+	.name		= "reject",
+	.ops		= &nft_reject_inet_ops,
+	.policy		= nft_reject_policy,
+	.maxattr	= NFTA_REJECT_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_reject_inet_module_init(void)
+{
+	return nft_register_expr(&nft_reject_inet_type);
+}
+
+static void __exit nft_reject_inet_module_exit(void)
+{
+	nft_unregister_expr(&nft_reject_inet_type);
+}
+
+module_init(nft_reject_inet_module_init);
+module_exit(nft_reject_inet_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS_NFT_AF_EXPR(1, "reject");
-- 
1.7.10.4
