From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/47] netfilter: nf_tables: add fib expression to the netdev family
Date: Mon,  4 Sep 2017 00:25:48 +0200
Message-ID: <1504477589-12045-7-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50810 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753155AbdICW0n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:26:43 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 61E3E190F65
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4BBF2B5030
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:16 +0200 (CEST)
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Pablo M. Bermudo Garay" <pablombg@gmail.com>

Add fib expression support for netdev family. Like inet family, netdev
delegates the actual decision to the corresponding backend, either ipv4
or ipv6.

This allows to perform very early reverse path filtering, among other
things.

You can find more information about fib expression in the f6d0cbcf09c5
("<netfilter: nf_tables: add fib expression>") commit message.

Signed-off-by: Pablo M. Bermudo Garay <pablombg@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig          |  9 +++++
 net/netfilter/Makefile         |  1 +
 net/netfilter/nft_fib_netdev.c | 87 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 97 insertions(+)
 create mode 100644 net/netfilter/nft_fib_netdev.c

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 9b28864cc36a..e4a13cc8a2e7 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -636,6 +636,15 @@ config NFT_FWD_NETDEV
 	help
 	  This option enables packet forwarding for the "netdev" family.
 
+config NFT_FIB_NETDEV
+	depends on NFT_FIB_IPV4
+	depends on NFT_FIB_IPV6
+	tristate "Netfilter nf_tables netdev fib lookups support"
+	help
+	  This option allows using the FIB expression from the netdev table.
+	  The lookup will be delegated to the IPv4 or IPv6 FIB depending
+	  on the protocol of the packet.
+
 endif # NF_TABLES_NETDEV
 
 endif # NF_TABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 913380919301..d3891c93edd6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -100,6 +100,7 @@ obj-$(CONFIG_NFT_REDIR)		+= nft_redir.o
 obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
 obj-$(CONFIG_NFT_FIB)		+= nft_fib.o
 obj-$(CONFIG_NFT_FIB_INET)	+= nft_fib_inet.o
+obj-$(CONFIG_NFT_FIB_NETDEV)	+= nft_fib_netdev.o
 
 # nf_tables netdev
 obj-$(CONFIG_NFT_DUP_NETDEV)	+= nft_dup_netdev.o
diff --git a/net/netfilter/nft_fib_netdev.c b/net/netfilter/nft_fib_netdev.c
new file mode 100644
index 000000000000..3997ee36cfbd
--- /dev/null
+++ b/net/netfilter/nft_fib_netdev.c
@@ -0,0 +1,87 @@
+/*
+ * Copyright (c) 2017 Pablo M. Bermudo Garay <pablombg@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This code is based on net/netfilter/nft_fib_inet.c, written by
+ * Florian Westphal <fw@strlen.de>.
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
+static void nft_fib_netdev_eval(const struct nft_expr *expr,
+				struct nft_regs *regs,
+				const struct nft_pktinfo *pkt)
+{
+	const struct nft_fib *priv = nft_expr_priv(expr);
+
+	switch (ntohs(pkt->skb->protocol)) {
+	case ETH_P_IP:
+		switch (priv->result) {
+		case NFT_FIB_RESULT_OIF:
+		case NFT_FIB_RESULT_OIFNAME:
+			return nft_fib4_eval(expr, regs, pkt);
+		case NFT_FIB_RESULT_ADDRTYPE:
+			return nft_fib4_eval_type(expr, regs, pkt);
+		}
+		break;
+	case ETH_P_IPV6:
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
+	regs->verdict.code = NFT_BREAK;
+}
+
+static struct nft_expr_type nft_fib_netdev_type;
+static const struct nft_expr_ops nft_fib_netdev_ops = {
+	.type		= &nft_fib_netdev_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_fib)),
+	.eval		= nft_fib_netdev_eval,
+	.init		= nft_fib_init,
+	.dump		= nft_fib_dump,
+	.validate	= nft_fib_validate,
+};
+
+static struct nft_expr_type nft_fib_netdev_type __read_mostly = {
+	.family		= NFPROTO_NETDEV,
+	.name		= "fib",
+	.ops		= &nft_fib_netdev_ops,
+	.policy		= nft_fib_policy,
+	.maxattr	= NFTA_FIB_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_fib_netdev_module_init(void)
+{
+	return nft_register_expr(&nft_fib_netdev_type);
+}
+
+static void __exit nft_fib_netdev_module_exit(void)
+{
+	nft_unregister_expr(&nft_fib_netdev_type);
+}
+
+module_init(nft_fib_netdev_module_init);
+module_exit(nft_fib_netdev_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo M. Bermudo Garay <pablombg@gmail.com>");
+MODULE_ALIAS_NFT_AF_EXPR(5, "fib");
-- 
2.1.4
