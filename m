From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/9] netfilter: bridge: add reject support
Date: Thu, 31 Jul 2014 21:27:00 +0200
Message-ID: <1406834828-8500-2-git-send-email-pablo@netfilter.org>
References: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35645 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbaGaT1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 15:27:07 -0400
In-Reply-To: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So you can reject IPv4 and IPv6 packets from bridge tables. If the ether
proto is now known, default on dropping the packet instead.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/Kconfig             |    6 +++
 net/bridge/netfilter/Makefile            |    1 +
 net/bridge/netfilter/nft_reject_bridge.c |   67 ++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+)
 create mode 100644 net/bridge/netfilter/nft_reject_bridge.c

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index 4ce0b31..9cebf47 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -14,6 +14,12 @@ config NFT_BRIDGE_META
 	help
 	  Add support for bridge dedicated meta key.
 
+config NFT_BRIDGE_REJECT
+	tristate "Netfilter nf_tables bridge reject support"
+	depends on NFT_REJECT && NFT_REJECT_IPV4 && NFT_REJECT_IPV6
+	help
+	  Add support to reject packets.
+
 config NF_LOG_BRIDGE
 	tristate "Bridge packet logging"
 
diff --git a/net/bridge/netfilter/Makefile b/net/bridge/netfilter/Makefile
index 1f78ea0..061d121 100644
--- a/net/bridge/netfilter/Makefile
+++ b/net/bridge/netfilter/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_NF_TABLES_BRIDGE) += nf_tables_bridge.o
 obj-$(CONFIG_NFT_BRIDGE_META)  += nft_meta_bridge.o
+obj-$(CONFIG_NFT_BRIDGE_REJECT)  += nft_reject_bridge.o
 
 # packet logging
 obj-$(CONFIG_NF_LOG_BRIDGE) += nf_log_bridge.o
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
new file mode 100644
index 0000000..ee3ffe9
--- /dev/null
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -0,0 +1,67 @@
+/*
+ * Copyright (c) 2014 Pablo Neira Ayuso <pablo@netfilter.org>
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
+static void nft_reject_bridge_eval(const struct nft_expr *expr,
+				 struct nft_data data[NFT_REG_MAX + 1],
+				 const struct nft_pktinfo *pkt)
+{
+	switch (eth_hdr(pkt->skb)->h_proto) {
+	case htons(ETH_P_IP):
+		return nft_reject_ipv4_eval(expr, data, pkt);
+	case htons(ETH_P_IPV6):
+		return nft_reject_ipv6_eval(expr, data, pkt);
+	default:
+		/* No explicit way to reject this protocol, drop it. */
+		data[NFT_REG_VERDICT].verdict = NF_DROP;
+		break;
+	}
+}
+
+static struct nft_expr_type nft_reject_bridge_type;
+static const struct nft_expr_ops nft_reject_bridge_ops = {
+	.type		= &nft_reject_bridge_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_reject)),
+	.eval		= nft_reject_bridge_eval,
+	.init		= nft_reject_init,
+	.dump		= nft_reject_dump,
+};
+
+static struct nft_expr_type nft_reject_bridge_type __read_mostly = {
+	.family		= NFPROTO_BRIDGE,
+	.name		= "reject",
+	.ops		= &nft_reject_bridge_ops,
+	.policy		= nft_reject_policy,
+	.maxattr	= NFTA_REJECT_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_reject_bridge_module_init(void)
+{
+	return nft_register_expr(&nft_reject_bridge_type);
+}
+
+static void __exit nft_reject_bridge_module_exit(void)
+{
+	nft_unregister_expr(&nft_reject_bridge_type);
+}
+
+module_init(nft_reject_bridge_module_init);
+module_exit(nft_reject_bridge_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_AF_EXPR(AF_BRIDGE, "reject");
-- 
1.7.10.4
