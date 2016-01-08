From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/17] netfilter: nf_tables: add packet duplication to the netdev family
Date: Fri,  8 Jan 2016 15:02:07 +0100
Message-ID: <1452261737-7475-8-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You can use this to duplicate packets and inject them at the egress path
of the specified interface. This duplication allows you to inspect
traffic from the dummy or any other interface dedicated to this purpose.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_dup_netdev.h |  6 +++
 net/netfilter/Kconfig                 | 16 ++++++
 net/netfilter/Makefile                |  6 +++
 net/netfilter/nf_dup_netdev.c         | 40 +++++++++++++++
 net/netfilter/nft_dup_netdev.c        | 97 +++++++++++++++++++++++++++++++++++
 5 files changed, 165 insertions(+)
 create mode 100644 include/net/netfilter/nf_dup_netdev.h
 create mode 100644 net/netfilter/nf_dup_netdev.c
 create mode 100644 net/netfilter/nft_dup_netdev.c

diff --git a/include/net/netfilter/nf_dup_netdev.h b/include/net/netfilter/nf_dup_netdev.h
new file mode 100644
index 0000000..397dcae
--- /dev/null
+++ b/include/net/netfilter/nf_dup_netdev.h
@@ -0,0 +1,6 @@
+#ifndef _NF_DUP_NETDEV_H_
+#define _NF_DUP_NETDEV_H_
+
+void nf_dup_netdev_egress(const struct nft_pktinfo *pkt, int oif);
+
+#endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 4692782..8514cc4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -563,6 +563,22 @@ config NFT_COMPAT
 	  x_tables match/target extensions over the nf_tables
 	  framework.
 
+if NF_TABLES_NETDEV
+
+config NF_DUP_NETDEV
+	tristate "Netfilter packet duplication support"
+	help
+	  This option enables the generic packet duplication infrastructure
+	  for Netfilter.
+
+config NFT_DUP_NETDEV
+	tristate "Netfilter nf_tables netdev packet duplication support"
+	select NF_DUP_NETDEV
+	help
+	  This option enables packet duplication for the "netdev" family.
+
+endif # NF_TABLES_NETDEV
+
 endif # NF_TABLES
 
 config NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 2293484..5c99133 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -66,6 +66,9 @@ obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 # SYNPROXY
 obj-$(CONFIG_NETFILTER_SYNPROXY) += nf_synproxy_core.o
 
+# generic packet duplication from netdev family
+obj-$(CONFIG_NF_DUP_NETDEV)	+= nf_dup_netdev.o
+
 # nf_tables
 nf_tables-objs += nf_tables_core.o nf_tables_api.o nf_tables_trace.o
 nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o nft_dynset.o
@@ -90,6 +93,9 @@ obj-$(CONFIG_NFT_LOG)		+= nft_log.o
 obj-$(CONFIG_NFT_MASQ)		+= nft_masq.o
 obj-$(CONFIG_NFT_REDIR)		+= nft_redir.o
 
+# nf_tables netdev
+obj-$(CONFIG_NFT_DUP_NETDEV)	+= nft_dup_netdev.o
+
 # generic X tables 
 obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 
diff --git a/net/netfilter/nf_dup_netdev.c b/net/netfilter/nf_dup_netdev.c
new file mode 100644
index 0000000..8414ee1
--- /dev/null
+++ b/net/netfilter/nf_dup_netdev.c
@@ -0,0 +1,40 @@
+/*
+ * Copyright (c) 2015 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+
+void nf_dup_netdev_egress(const struct nft_pktinfo *pkt, int oif)
+{
+	struct net_device *dev;
+	struct sk_buff *skb;
+
+	dev = dev_get_by_index_rcu(pkt->net, oif);
+	if (dev == NULL)
+		return;
+
+	skb = skb_clone(pkt->skb, GFP_ATOMIC);
+	if (skb == NULL)
+		return;
+
+	if (skb_mac_header_was_set(skb))
+		skb_push(skb, skb->mac_len);
+
+	skb->dev = dev;
+	skb_sender_cpu_clear(skb);
+	dev_queue_xmit(skb);
+}
+EXPORT_SYMBOL_GPL(nf_dup_netdev_egress);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
diff --git a/net/netfilter/nft_dup_netdev.c b/net/netfilter/nft_dup_netdev.c
new file mode 100644
index 0000000..2cc1e0e
--- /dev/null
+++ b/net/netfilter/nft_dup_netdev.c
@@ -0,0 +1,97 @@
+/*
+ * Copyright (c) 2015 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_dup_netdev.h>
+
+struct nft_dup_netdev {
+	enum nft_registers	sreg_dev:8;
+};
+
+static void nft_dup_netdev_eval(const struct nft_expr *expr,
+				struct nft_regs *regs,
+				const struct nft_pktinfo *pkt)
+{
+	struct nft_dup_netdev *priv = nft_expr_priv(expr);
+	int oif = regs->data[priv->sreg_dev];
+
+	nf_dup_netdev_egress(pkt, oif);
+}
+
+static const struct nla_policy nft_dup_netdev_policy[NFTA_DUP_MAX + 1] = {
+	[NFTA_DUP_SREG_DEV]	= { .type = NLA_U32 },
+};
+
+static int nft_dup_netdev_init(const struct nft_ctx *ctx,
+			       const struct nft_expr *expr,
+			       const struct nlattr * const tb[])
+{
+	struct nft_dup_netdev *priv = nft_expr_priv(expr);
+
+	if (tb[NFTA_DUP_SREG_DEV] == NULL)
+		return -EINVAL;
+
+	priv->sreg_dev = nft_parse_register(tb[NFTA_DUP_SREG_DEV]);
+	return nft_validate_register_load(priv->sreg_dev, sizeof(int));
+}
+
+static const struct nft_expr_ops nft_dup_netdev_ingress_ops;
+
+static int nft_dup_netdev_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	struct nft_dup_netdev *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_DUP_SREG_DEV, priv->sreg_dev))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_dup_netdev_type;
+static const struct nft_expr_ops nft_dup_netdev_ops = {
+	.type		= &nft_dup_netdev_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_dup_netdev)),
+	.eval		= nft_dup_netdev_eval,
+	.init		= nft_dup_netdev_init,
+	.dump		= nft_dup_netdev_dump,
+};
+
+static struct nft_expr_type nft_dup_netdev_type __read_mostly = {
+	.family		= NFPROTO_NETDEV,
+	.name		= "dup",
+	.ops		= &nft_dup_netdev_ops,
+	.policy		= nft_dup_netdev_policy,
+	.maxattr	= NFTA_DUP_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_dup_netdev_module_init(void)
+{
+	return nft_register_expr(&nft_dup_netdev_type);
+}
+
+static void __exit nft_dup_netdev_module_exit(void)
+{
+	nft_unregister_expr(&nft_dup_netdev_type);
+}
+
+module_init(nft_dup_netdev_module_init);
+module_exit(nft_dup_netdev_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_AF_EXPR(5, "dup");
-- 
2.1.4

