From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/20] netfilter: nf_tables: add support for dynamic set updates
Date: Thu,  9 Apr 2015 13:35:03 +0200
Message-ID: <1428579304-5520-20-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add a new "dynset" expression for dynamic set updates.

A new set op ->update() is added which, for non existant elements,
invokes an initialization callback and inserts the new element.
For both new or existing elements the extenstion pointer is returned
to the caller to optionally perform timer updates or other actions.

Element removal is not supported so far, however that seems to be a
rather exotic need and can be added later on.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |   17 +++
 include/net/netfilter/nf_tables_core.h   |    3 +
 include/uapi/linux/netfilter/nf_tables.h |   27 ++++
 net/netfilter/Makefile                   |    2 +-
 net/netfilter/nf_tables_api.c            |   10 +-
 net/netfilter/nf_tables_core.c           |    7 +
 net/netfilter/nft_dynset.c               |  218 ++++++++++++++++++++++++++++++
 net/netfilter/nft_hash.c                 |   37 +++++
 8 files changed, 315 insertions(+), 6 deletions(-)
 create mode 100644 net/netfilter/nft_dynset.c

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index e7e6365..38c3496 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -196,6 +196,7 @@ struct nft_set_estimate {
 };
 
 struct nft_set_ext;
+struct nft_expr;
 
 /**
  *	struct nft_set_ops - nf_tables set operations
@@ -218,6 +219,15 @@ struct nft_set_ops {
 	bool				(*lookup)(const struct nft_set *set,
 						  const struct nft_data *key,
 						  const struct nft_set_ext **ext);
+	bool				(*update)(struct nft_set *set,
+						  const struct nft_data *key,
+						  void *(*new)(struct nft_set *,
+							       const struct nft_expr *,
+							       struct nft_data []),
+						  const struct nft_expr *expr,
+						  struct nft_data data[],
+						  const struct nft_set_ext **ext);
+
 	int				(*insert)(const struct nft_set *set,
 						  const struct nft_set_elem *elem);
 	void				(*activate)(const struct nft_set *set,
@@ -466,6 +476,11 @@ static inline struct nft_set_ext *nft_set_elem_ext(const struct nft_set *set,
 	return elem + set->ops->elemsize;
 }
 
+void *nft_set_elem_init(const struct nft_set *set,
+			const struct nft_set_ext_tmpl *tmpl,
+			const struct nft_data *key,
+			const struct nft_data *data,
+			u64 timeout, gfp_t gfp);
 void nft_set_elem_destroy(const struct nft_set *set, void *elem);
 
 /**
@@ -845,6 +860,8 @@ static inline u8 nft_genmask_cur(const struct net *net)
 	return 1 << ACCESS_ONCE(net->nft.gencursor);
 }
 
+#define NFT_GENMASK_ANY		((1 << 0) | (1 << 1))
+
 /*
  * Set element transaction helpers
  */
diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index a75fc8e..c6f400c 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -31,6 +31,9 @@ void nft_cmp_module_exit(void);
 int nft_lookup_module_init(void);
 void nft_lookup_module_exit(void);
 
+int nft_dynset_module_init(void);
+void nft_dynset_module_exit(void);
+
 int nft_bitwise_module_init(void);
 void nft_bitwise_module_exit(void);
 
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 83441cc..0b87b2f 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -515,6 +515,33 @@ enum nft_lookup_attributes {
 };
 #define NFTA_LOOKUP_MAX		(__NFTA_LOOKUP_MAX - 1)
 
+enum nft_dynset_ops {
+	NFT_DYNSET_OP_ADD,
+	NFT_DYNSET_OP_UPDATE,
+};
+
+/**
+ * enum nft_dynset_attributes - dynset expression attributes
+ *
+ * @NFTA_DYNSET_SET_NAME: name of set the to add data to (NLA_STRING)
+ * @NFTA_DYNSET_SET_ID: uniquely identifier of the set in the transaction (NLA_U32)
+ * @NFTA_DYNSET_OP: operation (NLA_U32)
+ * @NFTA_DYNSET_SREG_KEY: source register of the key (NLA_U32)
+ * @NFTA_DYNSET_SREG_DATA: source register of the data (NLA_U32)
+ * @NFTA_DYNSET_TIMEOUT: timeout value for the new element (NLA_U64)
+ */
+enum nft_dynset_attributes {
+	NFTA_DYNSET_UNSPEC,
+	NFTA_DYNSET_SET_NAME,
+	NFTA_DYNSET_SET_ID,
+	NFTA_DYNSET_OP,
+	NFTA_DYNSET_SREG_KEY,
+	NFTA_DYNSET_SREG_DATA,
+	NFTA_DYNSET_TIMEOUT,
+	__NFTA_DYNSET_MAX,
+};
+#define NFTA_DYNSET_MAX		(__NFTA_DYNSET_MAX - 1)
+
 /**
  * enum nft_payload_bases - nf_tables payload expression offset bases
  *
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 89f73a9..a87d8b8 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -70,7 +70,7 @@ obj-$(CONFIG_NETFILTER_SYNPROXY) += nf_synproxy_core.o
 
 # nf_tables
 nf_tables-objs += nf_tables_core.o nf_tables_api.o
-nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o
+nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o nft_dynset.o
 nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
 
 obj-$(CONFIG_NF_TABLES)		+= nf_tables.o
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 90b8984..598e53e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3183,11 +3183,11 @@ static struct nft_trans *nft_trans_elem_alloc(struct nft_ctx *ctx,
 	return trans;
 }
 
-static void *nft_set_elem_init(const struct nft_set *set,
-			       const struct nft_set_ext_tmpl *tmpl,
-			       const struct nft_data *key,
-			       const struct nft_data *data,
-			       u64 timeout, gfp_t gfp)
+void *nft_set_elem_init(const struct nft_set *set,
+			const struct nft_set_ext_tmpl *tmpl,
+			const struct nft_data *key,
+			const struct nft_data *data,
+			u64 timeout, gfp_t gfp)
 {
 	struct nft_set_ext *ext;
 	void *elem;
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index ef4dfcb..7caf08a 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -239,8 +239,14 @@ int __init nf_tables_core_module_init(void)
 	if (err < 0)
 		goto err6;
 
+	err = nft_dynset_module_init();
+	if (err < 0)
+		goto err7;
+
 	return 0;
 
+err7:
+	nft_payload_module_exit();
 err6:
 	nft_byteorder_module_exit();
 err5:
@@ -257,6 +263,7 @@ err1:
 
 void nf_tables_core_module_exit(void)
 {
+	nft_dynset_module_exit();
 	nft_payload_module_exit();
 	nft_byteorder_module_exit();
 	nft_bitwise_module_exit();
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
new file mode 100644
index 0000000..eeb72de
--- /dev/null
+++ b/net/netfilter/nft_dynset.c
@@ -0,0 +1,218 @@
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
+struct nft_dynset {
+	struct nft_set			*set;
+	struct nft_set_ext_tmpl		tmpl;
+	enum nft_dynset_ops		op:8;
+	enum nft_registers		sreg_key:8;
+	enum nft_registers		sreg_data:8;
+	u64				timeout;
+	struct nft_set_binding		binding;
+};
+
+static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
+			    struct nft_data data[NFT_REG_MAX + 1])
+{
+	const struct nft_dynset *priv = nft_expr_priv(expr);
+	u64 timeout;
+	void *elem;
+
+	if (set->size && !atomic_add_unless(&set->nelems, 1, set->size))
+		return NULL;
+
+	timeout = priv->timeout ? : set->timeout;
+	elem = nft_set_elem_init(set, &priv->tmpl,
+				 &data[priv->sreg_key], &data[priv->sreg_data],
+				 timeout, GFP_ATOMIC);
+	if (elem == NULL) {
+		if (set->size)
+			atomic_dec(&set->nelems);
+	}
+	return elem;
+}
+
+static void nft_dynset_eval(const struct nft_expr *expr,
+			    struct nft_data data[NFT_REG_MAX + 1],
+			    const struct nft_pktinfo *pkt)
+{
+	const struct nft_dynset *priv = nft_expr_priv(expr);
+	struct nft_set *set = priv->set;
+	const struct nft_set_ext *ext;
+	u64 timeout;
+
+	if (set->ops->update(set, &data[priv->sreg_key], nft_dynset_new,
+			     expr, data, &ext)) {
+		if (priv->op == NFT_DYNSET_OP_UPDATE &&
+		    nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION)) {
+			timeout = priv->timeout ? : set->timeout;
+			*nft_set_ext_expiration(ext) = jiffies + timeout;
+			return;
+		}
+	}
+
+	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+}
+
+static const struct nla_policy nft_dynset_policy[NFTA_DYNSET_MAX + 1] = {
+	[NFTA_DYNSET_SET_NAME]	= { .type = NLA_STRING },
+	[NFTA_DYNSET_SET_ID]	= { .type = NLA_U32 },
+	[NFTA_DYNSET_OP]	= { .type = NLA_U32 },
+	[NFTA_DYNSET_SREG_KEY]	= { .type = NLA_U32 },
+	[NFTA_DYNSET_SREG_DATA]	= { .type = NLA_U32 },
+	[NFTA_DYNSET_TIMEOUT]	= { .type = NLA_U64 },
+};
+
+static int nft_dynset_init(const struct nft_ctx *ctx,
+			   const struct nft_expr *expr,
+			   const struct nlattr * const tb[])
+{
+	struct nft_dynset *priv = nft_expr_priv(expr);
+	struct nft_set *set;
+	u64 timeout;
+	int err;
+
+	if (tb[NFTA_DYNSET_SET_NAME] == NULL ||
+	    tb[NFTA_DYNSET_OP] == NULL ||
+	    tb[NFTA_DYNSET_SREG_KEY] == NULL)
+		return -EINVAL;
+
+	set = nf_tables_set_lookup(ctx->table, tb[NFTA_DYNSET_SET_NAME]);
+	if (IS_ERR(set)) {
+		if (tb[NFTA_DYNSET_SET_ID])
+			set = nf_tables_set_lookup_byid(ctx->net,
+							tb[NFTA_DYNSET_SET_ID]);
+		if (IS_ERR(set))
+			return PTR_ERR(set);
+	}
+
+	if (set->flags & NFT_SET_CONSTANT)
+		return -EBUSY;
+
+	priv->op = ntohl(nla_get_be32(tb[NFTA_DYNSET_OP]));
+	switch (priv->op) {
+	case NFT_DYNSET_OP_ADD:
+		break;
+	case NFT_DYNSET_OP_UPDATE:
+		if (!(set->flags & NFT_SET_TIMEOUT))
+			return -EOPNOTSUPP;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	timeout = 0;
+	if (tb[NFTA_DYNSET_TIMEOUT] != NULL) {
+		if (!(set->flags & NFT_SET_TIMEOUT))
+			return -EINVAL;
+		timeout = be64_to_cpu(nla_get_be64(tb[NFTA_DYNSET_TIMEOUT]));
+	}
+
+	priv->sreg_key = ntohl(nla_get_be32(tb[NFTA_DYNSET_SREG_KEY]));
+	err = nft_validate_input_register(priv->sreg_key);
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_DYNSET_SREG_DATA] != NULL) {
+		if (!(set->flags & NFT_SET_MAP))
+			return -EINVAL;
+		if (set->dtype == NFT_DATA_VERDICT)
+			return -EOPNOTSUPP;
+
+		priv->sreg_data = ntohl(nla_get_be32(tb[NFTA_DYNSET_SREG_DATA]));
+		err = nft_validate_input_register(priv->sreg_data);
+		if (err < 0)
+			return err;
+	} else if (set->flags & NFT_SET_MAP)
+		return -EINVAL;
+
+	nft_set_ext_prepare(&priv->tmpl);
+	nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_KEY, set->klen);
+	if (set->flags & NFT_SET_MAP)
+		nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_DATA, set->dlen);
+	if (set->flags & NFT_SET_TIMEOUT) {
+		if (timeout || set->timeout)
+			nft_set_ext_add(&priv->tmpl, NFT_SET_EXT_EXPIRATION);
+	}
+
+	priv->timeout = timeout;
+
+	err = nf_tables_bind_set(ctx, set, &priv->binding);
+	if (err < 0)
+		return err;
+
+	priv->set = set;
+	return 0;
+}
+
+static void nft_dynset_destroy(const struct nft_ctx *ctx,
+			       const struct nft_expr *expr)
+{
+	struct nft_dynset *priv = nft_expr_priv(expr);
+
+	nf_tables_unbind_set(ctx, priv->set, &priv->binding);
+}
+
+static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_dynset *priv = nft_expr_priv(expr);
+
+	if (nla_put_be32(skb, NFTA_DYNSET_SREG_KEY, htonl(priv->sreg_key)))
+		goto nla_put_failure;
+	if (priv->set->flags & NFT_SET_MAP &&
+	    nla_put_be32(skb, NFTA_DYNSET_SREG_DATA, htonl(priv->sreg_data)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_DYNSET_OP, htonl(priv->op)))
+		goto nla_put_failure;
+	if (nla_put_string(skb, NFTA_DYNSET_SET_NAME, priv->set->name))
+		goto nla_put_failure;
+	if (nla_put_be64(skb, NFTA_DYNSET_TIMEOUT, cpu_to_be64(priv->timeout)))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_dynset_type;
+static const struct nft_expr_ops nft_dynset_ops = {
+	.type		= &nft_dynset_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_dynset)),
+	.eval		= nft_dynset_eval,
+	.init		= nft_dynset_init,
+	.destroy	= nft_dynset_destroy,
+	.dump		= nft_dynset_dump,
+};
+
+static struct nft_expr_type nft_dynset_type __read_mostly = {
+	.name		= "dynset",
+	.ops		= &nft_dynset_ops,
+	.policy		= nft_dynset_policy,
+	.maxattr	= NFTA_DYNSET_MAX,
+	.owner		= THIS_MODULE,
+};
+
+int __init nft_dynset_module_init(void)
+{
+	return nft_register_expr(&nft_dynset_type);
+}
+
+void nft_dynset_module_exit(void)
+{
+	nft_unregister_expr(&nft_dynset_type);
+}
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index c74e2bf..bc23806 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -90,6 +90,42 @@ static bool nft_hash_lookup(const struct nft_set *set,
 	return !!he;
 }
 
+static bool nft_hash_update(struct nft_set *set, const struct nft_data *key,
+			    void *(*new)(struct nft_set *,
+					 const struct nft_expr *,
+					 struct nft_data []),
+			    const struct nft_expr *expr,
+			    struct nft_data data[],
+			    const struct nft_set_ext **ext)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he;
+	struct nft_hash_cmp_arg arg = {
+		.genmask = NFT_GENMASK_ANY,
+		.set	 = set,
+		.key	 = key,
+	};
+
+	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
+	if (he != NULL)
+		goto out;
+
+	he = new(set, expr, data);
+	if (he == NULL)
+		goto err1;
+	if (rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
+					 nft_hash_params))
+		goto err2;
+out:
+	*ext = &he->ext;
+	return true;
+
+err2:
+	nft_set_elem_destroy(set, he);
+err1:
+	return false;
+}
+
 static int nft_hash_insert(const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
@@ -335,6 +371,7 @@ static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.deactivate	= nft_hash_deactivate,
 	.remove		= nft_hash_remove,
 	.lookup		= nft_hash_lookup,
+	.update		= nft_hash_update,
 	.walk		= nft_hash_walk,
 	.features	= NFT_SET_MAP | NFT_SET_TIMEOUT,
 	.owner		= THIS_MODULE,
-- 
1.7.10.4

