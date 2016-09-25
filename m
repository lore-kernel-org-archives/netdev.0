From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 51/53] netfilter: nf_tables: add range expression
Date: Mon, 26 Sep 2016 01:07:01 +0200
Message-ID: <1474844823-2026-52-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54686 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034912AbcIYXIN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:08:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BAF33E3A0A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A8ABBDA7F7
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7445CDA7E9
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:08 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inverse ranges != [a,b] are not currently possible because rules are
composites of && operations, and we need to express this:

	data < a || data > b

This patch adds a new range expression. Positive ranges can be already
through two cmp expressions:

	cmp(sreg, data, >=)
	cmp(sreg, data, <=)

This new range expression provides an alternative way to express this.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h   |   3 +
 include/uapi/linux/netfilter/nf_tables.h |  29 +++++++
 net/netfilter/Makefile                   |   3 +-
 net/netfilter/nf_tables_core.c           |   7 +-
 net/netfilter/nft_range.c                | 138 +++++++++++++++++++++++++++++++
 5 files changed, 178 insertions(+), 2 deletions(-)
 create mode 100644 net/netfilter/nft_range.c

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index a9060dd99db7..00f4f6b1b1ba 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -28,6 +28,9 @@ extern const struct nft_expr_ops nft_cmp_fast_ops;
 int nft_cmp_module_init(void);
 void nft_cmp_module_exit(void);
 
+int nft_range_module_init(void);
+void nft_range_module_exit(void);
+
 int nft_lookup_module_init(void);
 void nft_lookup_module_exit(void);
 
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 1cf41dd838b2..c6c4477c136b 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -546,6 +546,35 @@ enum nft_cmp_attributes {
 };
 #define NFTA_CMP_MAX		(__NFTA_CMP_MAX - 1)
 
+/**
+ * enum nft_range_ops - nf_tables range operator
+ *
+ * @NFT_RANGE_EQ: equal
+ * @NFT_RANGE_NEQ: not equal
+ */
+enum nft_range_ops {
+	NFT_RANGE_EQ,
+	NFT_RANGE_NEQ,
+};
+
+/**
+ * enum nft_range_attributes - nf_tables range expression netlink attributes
+ *
+ * @NFTA_RANGE_SREG: source register of data to compare (NLA_U32: nft_registers)
+ * @NFTA_RANGE_OP: cmp operation (NLA_U32: nft_cmp_ops)
+ * @NFTA_RANGE_FROM_DATA: data range from (NLA_NESTED: nft_data_attributes)
+ * @NFTA_RANGE_TO_DATA: data range to (NLA_NESTED: nft_data_attributes)
+ */
+enum nft_range_attributes {
+	NFTA_RANGE_UNSPEC,
+	NFTA_RANGE_SREG,
+	NFTA_RANGE_OP,
+	NFTA_RANGE_FROM_DATA,
+	NFTA_RANGE_TO_DATA,
+	__NFTA_RANGE_MAX
+};
+#define NFTA_RANGE_MAX		(__NFTA_RANGE_MAX - 1)
+
 enum nft_lookup_flags {
 	NFT_LOOKUP_F_INV = (1 << 0),
 };
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 0c8581100ac6..c23c3c84416f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -71,8 +71,9 @@ obj-$(CONFIG_NF_DUP_NETDEV)	+= nf_dup_netdev.o
 
 # nf_tables
 nf_tables-objs += nf_tables_core.o nf_tables_api.o nf_tables_trace.o
-nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o nft_dynset.o
+nf_tables-objs += nft_immediate.o nft_cmp.o nft_range.o
 nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
+nf_tables-objs += nft_lookup.o nft_dynset.o
 
 obj-$(CONFIG_NF_TABLES)		+= nf_tables.o
 obj-$(CONFIG_NF_TABLES_INET)	+= nf_tables_inet.o
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 67259cefef06..7c94ce0080d5 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -263,8 +263,13 @@ int __init nf_tables_core_module_init(void)
 	if (err < 0)
 		goto err7;
 
-	return 0;
+	err = nft_range_module_init();
+	if (err < 0)
+		goto err8;
 
+	return 0;
+err8:
+	nft_dynset_module_exit();
 err7:
 	nft_payload_module_exit();
 err6:
diff --git a/net/netfilter/nft_range.c b/net/netfilter/nft_range.c
new file mode 100644
index 000000000000..c6d5358482d1
--- /dev/null
+++ b/net/netfilter/nft_range.c
@@ -0,0 +1,138 @@
+/*
+ * Copyright (c) 2016 Pablo Neira Ayuso <pablo@netfilter.org>
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
+#include <net/netfilter/nf_tables_core.h>
+#include <net/netfilter/nf_tables.h>
+
+struct nft_range_expr {
+	struct nft_data		data_from;
+	struct nft_data		data_to;
+	enum nft_registers	sreg:8;
+	u8			len;
+	enum nft_range_ops	op:8;
+};
+
+static void nft_range_eval(const struct nft_expr *expr,
+			 struct nft_regs *regs,
+			 const struct nft_pktinfo *pkt)
+{
+	const struct nft_range_expr *priv = nft_expr_priv(expr);
+	bool mismatch;
+	int d1, d2;
+
+	d1 = memcmp(&regs->data[priv->sreg], &priv->data_from, priv->len);
+	d2 = memcmp(&regs->data[priv->sreg], &priv->data_to, priv->len);
+	switch (priv->op) {
+	case NFT_RANGE_EQ:
+		mismatch = (d1 < 0 || d2 > 0);
+		break;
+	case NFT_RANGE_NEQ:
+		mismatch = (d1 >= 0 && d2 <= 0);
+		break;
+	}
+
+	if (mismatch)
+		regs->verdict.code = NFT_BREAK;
+}
+
+static const struct nla_policy nft_range_policy[NFTA_RANGE_MAX + 1] = {
+	[NFTA_RANGE_SREG]		= { .type = NLA_U32 },
+	[NFTA_RANGE_OP]			= { .type = NLA_U32 },
+	[NFTA_RANGE_FROM_DATA]		= { .type = NLA_NESTED },
+	[NFTA_RANGE_TO_DATA]		= { .type = NLA_NESTED },
+};
+
+static int nft_range_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+			const struct nlattr * const tb[])
+{
+	struct nft_range_expr *priv = nft_expr_priv(expr);
+	struct nft_data_desc desc_from, desc_to;
+	int err;
+
+	err = nft_data_init(NULL, &priv->data_from, sizeof(priv->data_from),
+			    &desc_from, tb[NFTA_RANGE_FROM_DATA]);
+	if (err < 0)
+		return err;
+
+	err = nft_data_init(NULL, &priv->data_to, sizeof(priv->data_to),
+			    &desc_to, tb[NFTA_RANGE_TO_DATA]);
+	if (err < 0)
+		goto err1;
+
+	if (desc_from.len != desc_to.len) {
+		err = -EINVAL;
+		goto err2;
+	}
+
+	priv->sreg = nft_parse_register(tb[NFTA_RANGE_SREG]);
+	err = nft_validate_register_load(priv->sreg, desc_from.len);
+	if (err < 0)
+		goto err2;
+
+	priv->op  = ntohl(nla_get_be32(tb[NFTA_RANGE_OP]));
+	priv->len = desc_from.len;
+	return 0;
+err2:
+	nft_data_uninit(&priv->data_to, desc_to.type);
+err1:
+	nft_data_uninit(&priv->data_from, desc_from.type);
+	return err;
+}
+
+static int nft_range_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_range_expr *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_RANGE_SREG, priv->sreg))
+		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_RANGE_OP, htonl(priv->op)))
+		goto nla_put_failure;
+
+	if (nft_data_dump(skb, NFTA_RANGE_FROM_DATA, &priv->data_from,
+			  NFT_DATA_VALUE, priv->len) < 0 ||
+	    nft_data_dump(skb, NFTA_RANGE_TO_DATA, &priv->data_to,
+			  NFT_DATA_VALUE, priv->len) < 0)
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_range_type;
+static const struct nft_expr_ops nft_range_ops = {
+	.type		= &nft_range_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_range_expr)),
+	.eval		= nft_range_eval,
+	.init		= nft_range_init,
+	.dump		= nft_range_dump,
+};
+
+static struct nft_expr_type nft_range_type __read_mostly = {
+	.name		= "range",
+	.ops		= &nft_range_ops,
+	.policy		= nft_range_policy,
+	.maxattr	= NFTA_RANGE_MAX,
+	.owner		= THIS_MODULE,
+};
+
+int __init nft_range_module_init(void)
+{
+	return nft_register_expr(&nft_range_type);
+}
+
+void nft_range_module_exit(void)
+{
+	nft_unregister_expr(&nft_range_type);
+}
-- 
2.1.4
