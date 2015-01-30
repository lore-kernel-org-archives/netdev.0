From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 9/9] netfilter: nf_tables: add support for dynamic set updates
Date: Fri, 30 Jan 2015 07:46:34 +0000
Message-ID: <1422603994-5836-10-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34149 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759398AbbA3HrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 02:47:00 -0500
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tables.h        |   4 +-
 include/uapi/linux/netfilter/nf_tables.h |  21 ++++
 net/netfilter/Kconfig                    |   7 ++
 net/netfilter/Makefile                   |   1 +
 net/netfilter/nf_tables_api.c            |   2 +
 net/netfilter/nft_hash.c                 |  20 +++-
 net/netfilter/nft_set.c                  | 176 +++++++++++++++++++++++++++++++
 7 files changed, 228 insertions(+), 3 deletions(-)
 create mode 100644 net/netfilter/nft_set.c

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 735a59d..5bbde43 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -319,6 +319,8 @@ struct nft_set_ops {
 	bool				(*lookup)(const struct nft_set *set,
 						  const struct nft_data *key,
 						  const struct nft_set_ext **ext);
+	bool				(*update)(const struct nft_set *set,
+						  void *elem);
 	int				(*get)(const struct nft_set *set,
 					       struct nft_set_elem *elem);
 	int				(*insert)(const struct nft_set *set,
@@ -373,13 +375,13 @@ struct nft_set {
 	u32				dtype;
 	u32				size;
 	u32				nelems;
-	u32				timeout;
 	u16				policy;
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
 	u16				flags;
 	u8				klen;
 	u8				dlen;
+	u32				timeout;
 	unsigned char			data[]
 		__attribute__((aligned(__alignof__(u64))));
 };
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 144d8fe..d8bad34 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -510,6 +510,27 @@ enum nft_lookup_attributes {
 };
 #define NFTA_LOOKUP_MAX		(__NFTA_LOOKUP_MAX - 1)
 
+enum nft_set_ops_ {
+	NFT_SET_OP_ADD,
+	NFT_SET_OP_UPDATE,
+	NFT_SET_OP_DELETE,
+};
+
+/**
+ * enum nft_set_attributes - set expression attributes
+ *
+ */
+enum nft_set_attributes_ {
+	NFTA_SET_UNSPEC_,
+	NFTA_SET_SET_NAME,
+	NFTA_SET_SET_ID,
+	NFTA_SET_OP,
+	NFTA_SET_SREG_KEY,
+	NFTA_SET_SREG_DATA,
+	__NFTA_SET_MAX_,
+};
+#define NFTA_SET_MAX_		(__NFTA_SET_MAX_ - 1)
+
 /**
  * enum nft_payload_bases - nf_tables payload expression offset bases
  *
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index b02660f..a6c5942 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -482,6 +482,13 @@ config NFT_HASH
 	  This option adds the "hash" set type that is used to build one-way
 	  mappings between matchings and actions.
 
+config NFT_SET
+	depends on NF_TABLES
+	tristate "Netfilter nf_tables set module"
+	help
+	  This options adds support for dynamic set updates during the packet
+	  classification process.
+
 config NFT_COUNTER
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables counter module"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 89f73a9..0ff329f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -86,6 +86,7 @@ obj-$(CONFIG_NFT_REJECT) 	+= nft_reject.o
 obj-$(CONFIG_NFT_REJECT_INET)	+= nft_reject_inet.o
 obj-$(CONFIG_NFT_RBTREE)	+= nft_rbtree.o
 obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
+obj-$(CONFIG_NFT_SET)		+= nft_set.o
 obj-$(CONFIG_NFT_COUNTER)	+= nft_counter.o
 obj-$(CONFIG_NFT_LOG)		+= nft_log.o
 obj-$(CONFIG_NFT_MASQ)		+= nft_masq.o
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 95234a3..7bdc626 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2246,6 +2246,7 @@ struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
 	}
 	return ERR_PTR(-ENOENT);
 }
+EXPORT_SYMBOL_GPL(nf_tables_set_lookup);
 
 struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
 					  const struct nlattr *nla)
@@ -2260,6 +2261,7 @@ struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
 	}
 	return ERR_PTR(-ENOENT);
 }
+EXPORT_SYMBOL(nf_tables_set_lookup_byid);
 
 static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 				    const char *name)
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index e7cf886..cc6750e 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -71,6 +71,19 @@ static bool nft_hash_lookup(const struct nft_set *set,
 	return !!he;
 }
 
+static bool nft_hash_update(const struct nft_set *set, void *elem)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he = elem;
+	struct nft_hash_compare_arg arg = {
+		.key	= nft_set_ext_key(&he->ext),
+		.len	= set->klen,
+	};
+
+	return rhashtable_lookup_compare_insert(&priv->ht, &he->node,
+						nft_hash_compare, &arg);
+}
+
 static int nft_hash_insert(const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
@@ -96,7 +109,8 @@ static void nft_hash_remove(const struct nft_set *set,
 	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he = elem->cookie;
 
-	rhashtable_remove(&priv->ht, &he->node);
+	if (!rhashtable_remove(&priv->ht, &he->node))
+		return;
 	synchronize_rcu();
 	kfree(elem->cookie);
 }
@@ -171,7 +185,8 @@ static void nft_hash_gc(struct work_struct *work)
 			if (time_before(jiffies, timeout))
 				continue;
 
-			rhashtable_remove(&priv->ht, &he->node);
+			if (!rhashtable_remove(&priv->ht, &he->node))
+				continue;
 			nft_hash_elem_destroy(set, he);
 		}
 	}
@@ -277,6 +292,7 @@ static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.insert		= nft_hash_insert,
 	.remove		= nft_hash_remove,
 	.lookup		= nft_hash_lookup,
+	.update		= nft_hash_update,
 	.walk		= nft_hash_walk,
 	.features	= NFT_SET_MAP | NFT_SET_TIMEOUT,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_set.c b/net/netfilter/nft_set.c
new file mode 100644
index 0000000..e94048e
--- /dev/null
+++ b/net/netfilter/nft_set.c
@@ -0,0 +1,176 @@
+/*
+ * Copyright (c) 2015 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+
+struct nft_set_expr {
+	struct nft_set			*set;
+	enum nft_registers		sreg_key:8;
+	enum nft_registers		sreg_data:8;
+	unsigned long			timeout;
+};
+
+static void nft_set_eval(const struct nft_expr *expr,
+			 struct nft_data data[NFT_REG_MAX + 1],
+			 const struct nft_pktinfo *pkt)
+{
+	const struct nft_set_expr *priv = nft_expr_priv(expr);
+	const struct nft_set *set = priv->set;
+	struct nft_set_ext_tmpl tmpl;
+	struct nft_set_ext *ext;
+	unsigned long timeout;
+	void *elem;
+
+	nft_set_ext_prepare(&tmpl);
+	nft_set_ext_add(&tmpl, NFT_SET_EXT_KEY);
+
+	timeout = 0;
+	if (set->flags & NFT_SET_TIMEOUT) {
+		timeout = priv->timeout ? : set->timeout;
+		if (timeout > 0)
+			nft_set_ext_add(&tmpl, NFT_SET_EXT_TIMEOUT);
+	}
+	if (set->flags & NFT_SET_MAP)
+		nft_set_ext_add(&tmpl, NFT_SET_EXT_DATA);
+
+	elem = kzalloc(set->ops->elemsize + tmpl.len, GFP_ATOMIC);
+	if (elem == NULL)
+		return;
+	ext = elem + set->ops->elemsize;
+	nft_set_ext_init(ext, &tmpl);
+
+	nft_data_copy(nft_set_ext_key(ext), &data[priv->sreg_key]);
+	if (set->flags & NFT_SET_MAP)
+		nft_data_copy(nft_set_ext_data(ext), &data[priv->sreg_data]);
+	if (timeout > 0)
+		*nft_set_ext_timeout(ext) = jiffies + timeout;
+
+	if (!set->ops->update(set, elem))
+		kfree(elem);
+}
+
+static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
+	[NFTA_SET_SET_NAME]	= { .type = NLA_STRING },
+	[NFTA_SET_SET_ID]	= { .type = NLA_U32 },
+	[NFTA_SET_OP]		= { .type = NLA_U32 },
+	[NFTA_SET_SREG_KEY]	= { .type = NLA_U32 },
+	[NFTA_SET_SREG_DATA]	= { .type = NLA_U32 },
+	[NFTA_SET_TIMEOUT]	= { .type = NLA_U32 },
+};
+
+static int nft_set_init(const struct nft_ctx *ctx,
+			const struct nft_expr *expr,
+			const struct nlattr * const tb[])
+{
+	struct nft_set_expr *priv = nft_expr_priv(expr);
+	struct nft_set *set;
+	enum nft_set_ops_ op;
+	int err;
+
+	if (tb[NFTA_SET_SET_NAME] == NULL ||
+	    tb[NFTA_SET_OP] == NULL ||
+	    tb[NFTA_SET_SREG_KEY] == NULL)
+		return -EINVAL;
+
+	op = ntohl(nla_get_be32(tb[NFTA_SET_OP]));
+	switch (op) {
+	case NFT_SET_ADD:
+	case NFT_SET_UPDATE:
+	case NFT_SET_DELETE:
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	set = nf_tables_set_lookup(ctx->table, tb[NFTA_SET_SET_NAME]);
+	if (IS_ERR(set)) {
+		if (tb[NFTA_SET_SET_ID])
+			set = nf_tables_set_lookup_byid(ctx->net,
+							tb[NFTA_SET_SET_ID]);
+		if (IS_ERR(set))
+			return PTR_ERR(set);
+	}
+
+	priv->sreg_key = ntohl(nla_get_be32(tb[NFTA_SET_SREG_KEY]));
+	err = nft_validate_input_register(priv->sreg_key);
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_SET_SREG_DATA] != NULL) {
+		if (!(set->flags & NFT_SET_MAP))
+			return -EINVAL;
+
+		priv->sreg_data = ntohl(nla_get_be32(tb[NFTA_SET_SREG_DATA]));
+		err = nft_validate_input_register(priv->sreg_data);
+		if (err < 0)
+			return err;
+	} else if (set->flags & NFT_SET_MAP)
+		return -EINVAL;
+
+	// FIXME: bind
+	priv->set = set;
+	return 0;
+}
+
+static int nft_set_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_set_expr *priv = nft_expr_priv(expr);
+
+	if (nla_put_be32(skb, NFTA_SET_SREG_KEY, htonl(priv->sreg_key)))
+		goto nla_put_failure;
+	if (priv->set->flags & NFT_SET_MAP &&
+	    nla_put_be32(skb, NFTA_SET_SREG_DATA, htonl(priv->sreg_data)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_SET_OP, htonl(priv->op)))
+		goto nla_put_failure;
+	if (nla_put_string(skb, NFTA_SET_SET_NAME, priv->set->name))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_set_type;
+static const struct nft_expr_ops nft_set_ops = {
+	.type		= &nft_set_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_set_expr)),
+	.eval		= nft_set_eval,
+	.init		= nft_set_init,
+	.dump		= nft_set_dump,
+};
+
+static struct nft_expr_type nft_set_type __read_mostly = {
+	.name		= "set",
+	.ops		= &nft_set_ops,
+	.policy		= nft_set_policy,
+	.maxattr	= NFTA_SET_MAX,
+	.owner		= THIS_MODULE,
+};
+
+int __init nft_set_module_init(void)
+{
+	return nft_register_expr(&nft_set_type);
+}
+
+void nft_set_module_exit(void)
+{
+	nft_unregister_expr(&nft_set_type);
+}
+
+module_init(nft_set_module_init);
+module_exit(nft_set_module_exit);
+MODULE_LICENSE("GPL");
-- 
2.1.0
