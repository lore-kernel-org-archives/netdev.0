From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/17] netfilter: nf_tables: add forward expression to the netdev family
Date: Fri,  8 Jan 2016 15:02:08 +0100
Message-ID: <1452261737-7475-9-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You can use this to forward packets from ingress to the egress path of
the specified interface. This provides a fast path to bounce packets
from one interface to another specific destination interface.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h | 12 ++++
 net/netfilter/Kconfig                    |  6 ++
 net/netfilter/Makefile                   |  1 +
 net/netfilter/nft_fwd_netdev.c           | 98 ++++++++++++++++++++++++++++++++
 4 files changed, 117 insertions(+)
 create mode 100644 net/netfilter/nft_fwd_netdev.c

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 22043ce..731288a 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -984,6 +984,18 @@ enum nft_dup_attributes {
 #define NFTA_DUP_MAX		(__NFTA_DUP_MAX - 1)
 
 /**
+ * enum nft_fwd_attributes - nf_tables fwd expression netlink attributes
+ *
+ * @NFTA_FWD_SREG_DEV: source register of output interface (NLA_U32: nft_register)
+ */
+enum nft_fwd_attributes {
+	NFTA_FWD_UNSPEC,
+	NFTA_FWD_SREG_DEV,
+	__NFTA_FWD_MAX
+};
+#define NFTA_FWD_MAX	(__NFTA_FWD_MAX - 1)
+
+/**
  * enum nft_gen_attributes - nf_tables ruleset generation attributes
  *
  * @NFTA_GEN_ID: Ruleset generation ID (NLA_U32)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8514cc4..8c067e6 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -577,6 +577,12 @@ config NFT_DUP_NETDEV
 	help
 	  This option enables packet duplication for the "netdev" family.
 
+config NFT_FWD_NETDEV
+	tristate "Netfilter nf_tables netdev packet forwarding support"
+	select NF_DUP_NETDEV
+	help
+	  This option enables packet forwarding for the "netdev" family.
+
 endif # NF_TABLES_NETDEV
 
 endif # NF_TABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 5c99133..6913454 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -95,6 +95,7 @@ obj-$(CONFIG_NFT_REDIR)		+= nft_redir.o
 
 # nf_tables netdev
 obj-$(CONFIG_NFT_DUP_NETDEV)	+= nft_dup_netdev.o
+obj-$(CONFIG_NFT_FWD_NETDEV)	+= nft_fwd_netdev.o
 
 # generic X tables 
 obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
diff --git a/net/netfilter/nft_fwd_netdev.c b/net/netfilter/nft_fwd_netdev.c
new file mode 100644
index 0000000..763ebc3
--- /dev/null
+++ b/net/netfilter/nft_fwd_netdev.c
@@ -0,0 +1,98 @@
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
+struct nft_fwd_netdev {
+	enum nft_registers	sreg_dev:8;
+};
+
+static void nft_fwd_netdev_eval(const struct nft_expr *expr,
+				struct nft_regs *regs,
+				const struct nft_pktinfo *pkt)
+{
+	struct nft_fwd_netdev *priv = nft_expr_priv(expr);
+	int oif = regs->data[priv->sreg_dev];
+
+	nf_dup_netdev_egress(pkt, oif);
+	regs->verdict.code = NF_DROP;
+}
+
+static const struct nla_policy nft_fwd_netdev_policy[NFTA_FWD_MAX + 1] = {
+	[NFTA_FWD_SREG_DEV]	= { .type = NLA_U32 },
+};
+
+static int nft_fwd_netdev_init(const struct nft_ctx *ctx,
+			       const struct nft_expr *expr,
+			       const struct nlattr * const tb[])
+{
+	struct nft_fwd_netdev *priv = nft_expr_priv(expr);
+
+	if (tb[NFTA_FWD_SREG_DEV] == NULL)
+		return -EINVAL;
+
+	priv->sreg_dev = nft_parse_register(tb[NFTA_FWD_SREG_DEV]);
+	return nft_validate_register_load(priv->sreg_dev, sizeof(int));
+}
+
+static const struct nft_expr_ops nft_fwd_netdev_ingress_ops;
+
+static int nft_fwd_netdev_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	struct nft_fwd_netdev *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_FWD_SREG_DEV, priv->sreg_dev))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_fwd_netdev_type;
+static const struct nft_expr_ops nft_fwd_netdev_ops = {
+	.type		= &nft_fwd_netdev_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_fwd_netdev)),
+	.eval		= nft_fwd_netdev_eval,
+	.init		= nft_fwd_netdev_init,
+	.dump		= nft_fwd_netdev_dump,
+};
+
+static struct nft_expr_type nft_fwd_netdev_type __read_mostly = {
+	.family		= NFPROTO_NETDEV,
+	.name		= "fwd",
+	.ops		= &nft_fwd_netdev_ops,
+	.policy		= nft_fwd_netdev_policy,
+	.maxattr	= NFTA_FWD_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_fwd_netdev_module_init(void)
+{
+	return nft_register_expr(&nft_fwd_netdev_type);
+}
+
+static void __exit nft_fwd_netdev_module_exit(void)
+{
+	nft_unregister_expr(&nft_fwd_netdev_type);
+}
+
+module_init(nft_fwd_netdev_module_init);
+module_exit(nft_fwd_netdev_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_AF_EXPR(5, "fwd");
-- 
2.1.4

