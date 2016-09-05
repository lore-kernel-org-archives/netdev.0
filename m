From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/29] netfilter: nf_tables: add number generator expression
Date: Mon,  5 Sep 2016 12:58:27 +0200
Message-ID: <1473073124-5015-13-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35204 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933502AbcIEK7F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:05 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6EE052EFECF
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5FAC81150AE
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D96441150B3
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:00 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Garcia Liebana <nevola@gmail.com>

This patch adds the numgen expression that allows us to generated
incremental and random numbers, this generator is bound to a upper limit
that is specified by userspace.

This expression is useful to distribute packets in a round-robin fashion
as well as randomly.

Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  24 ++++
 net/netfilter/Kconfig                    |   6 +
 net/netfilter/Makefile                   |   1 +
 net/netfilter/nft_numgen.c               | 192 +++++++++++++++++++++++++++++++
 4 files changed, 223 insertions(+)
 create mode 100644 net/netfilter/nft_numgen.c

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 784fbf1..8c9d6ff 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1121,4 +1121,28 @@ enum nft_trace_types {
 	__NFT_TRACETYPE_MAX
 };
 #define NFT_TRACETYPE_MAX (__NFT_TRACETYPE_MAX - 1)
+
+/**
+ * enum nft_ng_attributes - nf_tables number generator expression netlink attributes
+ *
+ * @NFTA_NG_DREG: destination register (NLA_U32)
+ * @NFTA_NG_UNTIL: source value to increment the counter until reset (NLA_U32)
+ * @NFTA_NG_TYPE: operation type (NLA_U32)
+ */
+enum nft_ng_attributes {
+	NFTA_NG_UNSPEC,
+	NFTA_NG_DREG,
+	NFTA_NG_UNTIL,
+	NFTA_NG_TYPE,
+	__NFTA_NG_MAX
+};
+#define NFTA_NG_MAX	(__NFTA_NG_MAX - 1)
+
+enum nft_ng_types {
+	NFT_NG_INCREMENTAL,
+	NFT_NG_RANDOM,
+	__NFT_NG_MAX
+};
+#define NFT_NG_MAX	(__NFT_NG_MAX - 1)
+
 #endif /* _LINUX_NF_TABLES_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 29a8078..e8d56d9 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -474,6 +474,12 @@ config NFT_META
 	  This option adds the "meta" expression that you can use to match and
 	  to set packet metainformation such as the packet mark.
 
+config NFT_NUMGEN
+	tristate "Netfilter nf_tables number generator module"
+	help
+	  This option adds the number generator expression used to perform
+	  incremental counting and random numbers bound to a upper limit.
+
 config NFT_CT
 	depends on NF_CONNTRACK
 	tristate "Netfilter nf_tables conntrack module"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 0fc42df..0c858110 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -80,6 +80,7 @@ obj-$(CONFIG_NF_TABLES_NETDEV)	+= nf_tables_netdev.o
 obj-$(CONFIG_NFT_COMPAT)	+= nft_compat.o
 obj-$(CONFIG_NFT_EXTHDR)	+= nft_exthdr.o
 obj-$(CONFIG_NFT_META)		+= nft_meta.o
+obj-$(CONFIG_NFT_NUMGEN)	+= nft_numgen.o
 obj-$(CONFIG_NFT_CT)		+= nft_ct.o
 obj-$(CONFIG_NFT_LIMIT)		+= nft_limit.o
 obj-$(CONFIG_NFT_NAT)		+= nft_nat.o
diff --git a/net/netfilter/nft_numgen.c b/net/netfilter/nft_numgen.c
new file mode 100644
index 0000000..176e26d
--- /dev/null
+++ b/net/netfilter/nft_numgen.c
@@ -0,0 +1,192 @@
+/*
+ * Copyright (c) 2016 Laura Garcia <nevola@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <linux/static_key.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+
+static DEFINE_PER_CPU(struct rnd_state, nft_numgen_prandom_state);
+
+struct nft_ng_inc {
+	enum nft_registers      dreg:8;
+	u32			until;
+	atomic_t		counter;
+};
+
+static void nft_ng_inc_eval(const struct nft_expr *expr,
+			    struct nft_regs *regs,
+			    const struct nft_pktinfo *pkt)
+{
+	struct nft_ng_inc *priv = nft_expr_priv(expr);
+	u32 nval, oval;
+
+	do {
+		oval = atomic_read(&priv->counter);
+		nval = (oval + 1 < priv->until) ? oval + 1 : 0;
+	} while (atomic_cmpxchg(&priv->counter, oval, nval) != oval);
+
+	memcpy(&regs->data[priv->dreg], &priv->counter, sizeof(u32));
+}
+
+static const struct nla_policy nft_ng_policy[NFTA_NG_MAX + 1] = {
+	[NFTA_NG_DREG]		= { .type = NLA_U32 },
+	[NFTA_NG_UNTIL]		= { .type = NLA_U32 },
+	[NFTA_NG_TYPE]		= { .type = NLA_U32 },
+};
+
+static int nft_ng_inc_init(const struct nft_ctx *ctx,
+			   const struct nft_expr *expr,
+			   const struct nlattr * const tb[])
+{
+	struct nft_ng_inc *priv = nft_expr_priv(expr);
+
+	priv->until = ntohl(nla_get_be32(tb[NFTA_NG_UNTIL]));
+	if (priv->until == 0)
+		return -ERANGE;
+
+	priv->dreg = nft_parse_register(tb[NFTA_NG_DREG]);
+	atomic_set(&priv->counter, 0);
+
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, sizeof(u32));
+}
+
+static int nft_ng_dump(struct sk_buff *skb, enum nft_registers dreg,
+		       u32 until, enum nft_ng_types type)
+{
+	if (nft_dump_register(skb, NFTA_NG_DREG, dreg))
+		goto nla_put_failure;
+	if (nft_dump_register(skb, NFTA_NG_UNTIL, until))
+		goto nla_put_failure;
+	if (nft_dump_register(skb, NFTA_NG_TYPE, type))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int nft_ng_inc_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_ng_inc *priv = nft_expr_priv(expr);
+
+	return nft_ng_dump(skb, priv->dreg, priv->until, NFT_NG_INCREMENTAL);
+}
+
+struct nft_ng_random {
+	enum nft_registers      dreg:8;
+	u32			until;
+};
+
+static void nft_ng_random_eval(const struct nft_expr *expr,
+			       struct nft_regs *regs,
+			       const struct nft_pktinfo *pkt)
+{
+	struct nft_ng_random *priv = nft_expr_priv(expr);
+	struct rnd_state *state = this_cpu_ptr(&nft_numgen_prandom_state);
+
+	regs->data[priv->dreg] = reciprocal_scale(prandom_u32_state(state),
+						  priv->until);
+}
+
+static int nft_ng_random_init(const struct nft_ctx *ctx,
+			      const struct nft_expr *expr,
+			      const struct nlattr * const tb[])
+{
+	struct nft_ng_random *priv = nft_expr_priv(expr);
+
+	priv->until = ntohl(nla_get_be32(tb[NFTA_NG_UNTIL]));
+	if (priv->until == 0)
+		return -ERANGE;
+
+	prandom_init_once(&nft_numgen_prandom_state);
+
+	priv->dreg = nft_parse_register(tb[NFTA_NG_DREG]);
+
+	return nft_validate_register_store(ctx, priv->dreg, NULL,
+					   NFT_DATA_VALUE, sizeof(u32));
+}
+
+static int nft_ng_random_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_ng_random *priv = nft_expr_priv(expr);
+
+	return nft_ng_dump(skb, priv->dreg, priv->until, NFT_NG_RANDOM);
+}
+
+static struct nft_expr_type nft_ng_type;
+static const struct nft_expr_ops nft_ng_inc_ops = {
+	.type		= &nft_ng_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_ng_inc)),
+	.eval		= nft_ng_inc_eval,
+	.init		= nft_ng_inc_init,
+	.dump		= nft_ng_inc_dump,
+};
+
+static const struct nft_expr_ops nft_ng_random_ops = {
+	.type		= &nft_ng_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_ng_random)),
+	.eval		= nft_ng_random_eval,
+	.init		= nft_ng_random_init,
+	.dump		= nft_ng_random_dump,
+};
+
+static const struct nft_expr_ops *
+nft_ng_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
+{
+	u32 type;
+
+	if (!tb[NFTA_NG_DREG]	||
+	    !tb[NFTA_NG_UNTIL]	||
+	    !tb[NFTA_NG_TYPE])
+		return ERR_PTR(-EINVAL);
+
+	type = ntohl(nla_get_be32(tb[NFTA_NG_TYPE]));
+
+	switch (type) {
+	case NFT_NG_INCREMENTAL:
+		return &nft_ng_inc_ops;
+	case NFT_NG_RANDOM:
+		return &nft_ng_random_ops;
+	}
+
+	return ERR_PTR(-EINVAL);
+}
+
+static struct nft_expr_type nft_ng_type __read_mostly = {
+	.name		= "numgen",
+	.select_ops	= &nft_ng_select_ops,
+	.policy		= nft_ng_policy,
+	.maxattr	= NFTA_NG_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_ng_module_init(void)
+{
+	return nft_register_expr(&nft_ng_type);
+}
+
+static void __exit nft_ng_module_exit(void)
+{
+	nft_unregister_expr(&nft_ng_type);
+}
+
+module_init(nft_ng_module_init);
+module_exit(nft_ng_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Laura Garcia <nevola@gmail.com>");
+MODULE_ALIAS_NFT_EXPR("numgen");
-- 
2.1.4
