From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/29] netfilter: nf_tables: add quota expression
Date: Mon,  5 Sep 2016 12:58:26 +0200
Message-ID: <1473073124-5015-12-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35196 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933499AbcIEK7F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:05 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C81612EFED3
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8DB651150C6
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F1A4A114D73
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:59 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the quota expression. This new stateful expression
integrate easily into the dynset expression to build 'hashquota' flow
tables.

Arguably, we could use instead "counter bytes > 1000" instead, but this
approach has several problems:

1) We only support for one single stateful expression in dynamic set
   definitions, and the expression above is a composite of two
   expressions: get counter + comparison.

2) We would need to restore the packed counter representation (that we
   used to have) based on seqlock to synchronize this, since per-cpu is
   not suitable for this.

So instead of bloating the counter expression back with the seqlock
representation and extending the existing set infrastructure to make it
more complex for the composite described above, let's follow the more
simple approach of adding a quota expression that we can plug into our
existing infrastructure.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  19 +++++
 net/netfilter/Kconfig                    |   6 ++
 net/netfilter/Makefile                   |   1 +
 net/netfilter/nft_quota.c                | 121 +++++++++++++++++++++++++++++++
 4 files changed, 147 insertions(+)
 create mode 100644 net/netfilter/nft_quota.c

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 6ce0a6d..784fbf1 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -900,6 +900,25 @@ enum nft_queue_attributes {
 #define NFT_QUEUE_FLAG_CPU_FANOUT	0x02 /* use current CPU (no hashing) */
 #define NFT_QUEUE_FLAG_MASK		0x03
 
+enum nft_quota_flags {
+	NFT_QUOTA_F_INV		= (1 << 0),
+};
+
+/**
+ * enum nft_quota_attributes - nf_tables quota expression netlink attributes
+ *
+ * @NFTA_QUOTA_BYTES: quota in bytes (NLA_U16)
+ * @NFTA_QUOTA_FLAGS: flags (NLA_U32)
+ */
+enum nft_quota_attributes {
+	NFTA_QUOTA_UNSPEC,
+	NFTA_QUOTA_BYTES,
+	NFTA_QUOTA_FLAGS,
+	NFTA_QUOTA_PAD,
+	__NFTA_QUOTA_MAX
+};
+#define NFTA_QUOTA_MAX		(__NFTA_QUOTA_MAX - 1)
+
 /**
  * enum nft_reject_types - nf_tables reject expression reject types
  *
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 9cfaa00..29a8078 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -542,6 +542,12 @@ config NFT_QUEUE
 	  This is required if you intend to use the userspace queueing
 	  infrastructure (also known as NFQUEUE) from nftables.
 
+config NFT_QUOTA
+	tristate "Netfilter nf_tables quota module"
+	help
+	  This option adds the "quota" expression that you can use to match
+	  enforce bytes quotas.
+
 config NFT_REJECT
 	default m if NETFILTER_ADVANCED=n
 	tristate "Netfilter nf_tables reject support"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 1106ccd..0fc42df 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -84,6 +84,7 @@ obj-$(CONFIG_NFT_CT)		+= nft_ct.o
 obj-$(CONFIG_NFT_LIMIT)		+= nft_limit.o
 obj-$(CONFIG_NFT_NAT)		+= nft_nat.o
 obj-$(CONFIG_NFT_QUEUE)		+= nft_queue.o
+obj-$(CONFIG_NFT_QUOTA)		+= nft_quota.o
 obj-$(CONFIG_NFT_REJECT) 	+= nft_reject.o
 obj-$(CONFIG_NFT_REJECT_INET)	+= nft_reject_inet.o
 obj-$(CONFIG_NFT_SET_RBTREE)	+= nft_set_rbtree.o
diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
new file mode 100644
index 0000000..6eafbf9
--- /dev/null
+++ b/net/netfilter/nft_quota.c
@@ -0,0 +1,121 @@
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
+#include <linux/atomic.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+
+struct nft_quota {
+	u64		quota;
+	bool		invert;
+	atomic64_t	remain;
+};
+
+static inline long nft_quota(struct nft_quota *priv,
+			     const struct nft_pktinfo *pkt)
+{
+	return atomic64_sub_return(pkt->skb->len, &priv->remain);
+}
+
+static void nft_quota_eval(const struct nft_expr *expr,
+			   struct nft_regs *regs,
+			   const struct nft_pktinfo *pkt)
+{
+	struct nft_quota *priv = nft_expr_priv(expr);
+
+	if (nft_quota(priv, pkt) < 0 && !priv->invert)
+		regs->verdict.code = NFT_BREAK;
+}
+
+static const struct nla_policy nft_quota_policy[NFTA_QUOTA_MAX + 1] = {
+	[NFTA_QUOTA_BYTES]	= { .type = NLA_U64 },
+	[NFTA_QUOTA_FLAGS]	= { .type = NLA_U32 },
+};
+
+static int nft_quota_init(const struct nft_ctx *ctx,
+			  const struct nft_expr *expr,
+			  const struct nlattr * const tb[])
+{
+	struct nft_quota *priv = nft_expr_priv(expr);
+	u32 flags = 0;
+	u64 quota;
+
+	if (!tb[NFTA_QUOTA_BYTES])
+		return -EINVAL;
+
+	quota = be64_to_cpu(nla_get_be64(tb[NFTA_QUOTA_BYTES]));
+	if (quota > S64_MAX)
+		return -EOVERFLOW;
+
+	if (tb[NFTA_QUOTA_FLAGS]) {
+		flags = ntohl(nla_get_be32(tb[NFTA_QUOTA_FLAGS]));
+		if (flags & ~NFT_QUOTA_F_INV)
+			return -EINVAL;
+	}
+
+	priv->quota = quota;
+	priv->invert = (flags & NFT_QUOTA_F_INV) ? true : false;
+	atomic64_set(&priv->remain, quota);
+
+	return 0;
+}
+
+static int nft_quota_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_quota *priv = nft_expr_priv(expr);
+	u32 flags = priv->invert ? NFT_QUOTA_F_INV : 0;
+
+	if (nla_put_be64(skb, NFTA_QUOTA_BYTES, cpu_to_be64(priv->quota),
+			 NFTA_QUOTA_PAD) ||
+	    nla_put_be32(skb, NFTA_QUOTA_FLAGS, htonl(flags)))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_quota_type;
+static const struct nft_expr_ops nft_quota_ops = {
+	.type		= &nft_quota_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_quota)),
+	.eval		= nft_quota_eval,
+	.init		= nft_quota_init,
+	.dump		= nft_quota_dump,
+};
+
+static struct nft_expr_type nft_quota_type __read_mostly = {
+	.name		= "quota",
+	.ops		= &nft_quota_ops,
+	.policy		= nft_quota_policy,
+	.maxattr	= NFTA_QUOTA_MAX,
+	.flags		= NFT_EXPR_STATEFUL,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_quota_module_init(void)
+{
+        return nft_register_expr(&nft_quota_type);
+}
+
+static void __exit nft_quota_module_exit(void)
+{
+        nft_unregister_expr(&nft_quota_type);
+}
+
+module_init(nft_quota_module_init);
+module_exit(nft_quota_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_EXPR("quota");
-- 
2.1.4
