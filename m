From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/29] netfilter: nf_tables: select set backend flavour depending on description
Date: Fri, 30 Jun 2017 00:53:11 +0200
Message-ID: <1498776807-11124-14-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the infrastructure to support several implementations of
the same set type. This selection will be based on the set description
and the features available for this set. This allow us to select set
backend implementation that will result in better performance numbers.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 26 +++++++++++++----
 net/netfilter/nf_tables_api.c     | 59 ++++++++++++++++++++++++---------------
 net/netfilter/nft_set_bitmap.c    | 10 +++++--
 net/netfilter/nft_set_hash.c      | 10 +++++--
 net/netfilter/nft_set_rbtree.c    | 10 +++++--
 5 files changed, 80 insertions(+), 35 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 8a8bab8d7b15..f27012098846 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -281,6 +281,23 @@ struct nft_set_estimate {
 	enum nft_set_class	space;
 };
 
+/**
+ *      struct nft_set_type - nf_tables set type
+ *
+ *      @select_ops: function to select nft_set_ops
+ *      @ops: default ops, used when no select_ops functions is present
+ *      @list: used internally
+ *      @owner: module reference
+ */
+struct nft_set_type {
+	const struct nft_set_ops	*(*select_ops)(const struct nft_ctx *,
+						       const struct nft_set_desc *desc,
+						       u32 flags);
+	const struct nft_set_ops	*ops;
+	struct list_head		list;
+	struct module			*owner;
+};
+
 struct nft_set_ext;
 struct nft_expr;
 
@@ -297,8 +314,6 @@ struct nft_expr;
  *	@privsize: function to return size of set private data
  *	@init: initialize private data of new set instance
  *	@destroy: destroy private data of set instance
- *	@list: nf_tables_set_ops list node
- *	@owner: module reference
  *	@elemsize: element private size
  *	@features: features supported by the implementation
  */
@@ -345,14 +360,13 @@ struct nft_set_ops {
 						const struct nlattr * const nla[]);
 	void				(*destroy)(const struct nft_set *set);
 
-	struct list_head		list;
-	struct module			*owner;
 	unsigned int			elemsize;
 	u32				features;
+	const struct nft_set_type	*type;
 };
 
-int nft_register_set(struct nft_set_ops *ops);
-void nft_unregister_set(struct nft_set_ops *ops);
+int nft_register_set(struct nft_set_type *type);
+void nft_unregister_set(struct nft_set_type *type);
 
 /**
  * 	struct nft_set - nf_tables set instance
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index da314be0c048..c0b2b19607e1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2377,64 +2377,77 @@ static int nf_tables_delrule(struct net *net, struct sock *nlsk,
  * Sets
  */
 
-static LIST_HEAD(nf_tables_set_ops);
+static LIST_HEAD(nf_tables_set_types);
 
-int nft_register_set(struct nft_set_ops *ops)
+int nft_register_set(struct nft_set_type *type)
 {
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_add_tail_rcu(&ops->list, &nf_tables_set_ops);
+	list_add_tail_rcu(&type->list, &nf_tables_set_types);
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nft_register_set);
 
-void nft_unregister_set(struct nft_set_ops *ops)
+void nft_unregister_set(struct nft_set_type *type)
 {
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_del_rcu(&ops->list);
+	list_del_rcu(&type->list);
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 }
 EXPORT_SYMBOL_GPL(nft_unregister_set);
 
+#define NFT_SET_FEATURES	(NFT_SET_INTERVAL | NFT_SET_MAP | \
+				 NFT_SET_TIMEOUT | NFT_SET_OBJECT)
+
+static bool nft_set_ops_candidate(const struct nft_set_ops *ops, u32 flags)
+{
+	return (flags & ops->features) == (flags & NFT_SET_FEATURES);
+}
+
 /*
  * Select a set implementation based on the data characteristics and the
  * given policy. The total memory use might not be known if no size is
  * given, in that case the amount of memory per element is used.
  */
 static const struct nft_set_ops *
-nft_select_set_ops(const struct nlattr * const nla[],
+nft_select_set_ops(const struct nft_ctx *ctx,
+		   const struct nlattr * const nla[],
 		   const struct nft_set_desc *desc,
 		   enum nft_set_policies policy)
 {
 	const struct nft_set_ops *ops, *bops;
 	struct nft_set_estimate est, best;
-	u32 features;
+	const struct nft_set_type *type;
+	u32 flags = 0;
 
 #ifdef CONFIG_MODULES
-	if (list_empty(&nf_tables_set_ops)) {
+	if (list_empty(&nf_tables_set_types)) {
 		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 		request_module("nft-set");
 		nfnl_lock(NFNL_SUBSYS_NFTABLES);
-		if (!list_empty(&nf_tables_set_ops))
+		if (!list_empty(&nf_tables_set_types))
 			return ERR_PTR(-EAGAIN);
 	}
 #endif
-	features = 0;
-	if (nla[NFTA_SET_FLAGS] != NULL) {
-		features = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
-		features &= NFT_SET_INTERVAL | NFT_SET_MAP | NFT_SET_TIMEOUT |
-			    NFT_SET_OBJECT;
-	}
+	if (nla[NFTA_SET_FLAGS] != NULL)
+		flags = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
 
 	bops	    = NULL;
 	best.size   = ~0;
 	best.lookup = ~0;
 	best.space  = ~0;
 
-	list_for_each_entry(ops, &nf_tables_set_ops, list) {
-		if ((ops->features & features) != features)
+	list_for_each_entry(type, &nf_tables_set_types, list) {
+		if (!type->select_ops)
+			ops = type->ops;
+		else
+			ops = type->select_ops(ctx, desc, flags);
+		if (!ops)
+			continue;
+
+		if (!nft_set_ops_candidate(ops, flags))
 			continue;
-		if (!ops->estimate(desc, features, &est))
+		if (!ops->estimate(desc, flags, &est))
 			continue;
 
 		switch (policy) {
@@ -2465,10 +2478,10 @@ nft_select_set_ops(const struct nlattr * const nla[],
 			break;
 		}
 
-		if (!try_module_get(ops->owner))
+		if (!try_module_get(type->owner))
 			continue;
 		if (bops != NULL)
-			module_put(bops->owner);
+			module_put(bops->type->owner);
 
 		bops = ops;
 		best = est;
@@ -3029,7 +3042,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	if (!(nlh->nlmsg_flags & NLM_F_CREATE))
 		return -ENOENT;
 
-	ops = nft_select_set_ops(nla, &desc, policy);
+	ops = nft_select_set_ops(&ctx, nla, &desc, policy);
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
 
@@ -3089,14 +3102,14 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 err2:
 	kfree(set);
 err1:
-	module_put(ops->owner);
+	module_put(ops->type->owner);
 	return err;
 }
 
 static void nft_set_destroy(struct nft_set *set)
 {
 	set->ops->destroy(set);
-	module_put(set->ops->owner);
+	module_put(set->ops->type->owner);
 	kfree(set);
 }
 
diff --git a/net/netfilter/nft_set_bitmap.c b/net/netfilter/nft_set_bitmap.c
index b988162b5b15..87d17691278f 100644
--- a/net/netfilter/nft_set_bitmap.c
+++ b/net/netfilter/nft_set_bitmap.c
@@ -278,7 +278,9 @@ static bool nft_bitmap_estimate(const struct nft_set_desc *desc, u32 features,
 	return true;
 }
 
+static struct nft_set_type nft_bitmap_type;
 static struct nft_set_ops nft_bitmap_ops __read_mostly = {
+	.type		= &nft_bitmap_type,
 	.privsize	= nft_bitmap_privsize,
 	.elemsize	= offsetof(struct nft_bitmap_elem, ext),
 	.estimate	= nft_bitmap_estimate,
@@ -291,17 +293,21 @@ static struct nft_set_ops nft_bitmap_ops __read_mostly = {
 	.activate	= nft_bitmap_activate,
 	.lookup		= nft_bitmap_lookup,
 	.walk		= nft_bitmap_walk,
+};
+
+static struct nft_set_type nft_bitmap_type __read_mostly = {
+	.ops		= &nft_bitmap_ops,
 	.owner		= THIS_MODULE,
 };
 
 static int __init nft_bitmap_module_init(void)
 {
-	return nft_register_set(&nft_bitmap_ops);
+	return nft_register_set(&nft_bitmap_type);
 }
 
 static void __exit nft_bitmap_module_exit(void)
 {
-	nft_unregister_set(&nft_bitmap_ops);
+	nft_unregister_set(&nft_bitmap_type);
 }
 
 module_init(nft_bitmap_module_init);
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 7c21e3da0d88..4ba0717408d9 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -379,7 +379,9 @@ static bool nft_rhash_estimate(const struct nft_set_desc *desc, u32 features,
 	return true;
 }
 
+static struct nft_set_type nft_hash_type;
 static struct nft_set_ops nft_rhash_ops __read_mostly = {
+	.type		= &nft_hash_type,
 	.privsize       = nft_rhash_privsize,
 	.elemsize	= offsetof(struct nft_rhash_elem, ext),
 	.estimate	= nft_rhash_estimate,
@@ -394,17 +396,21 @@ static struct nft_set_ops nft_rhash_ops __read_mostly = {
 	.update		= nft_rhash_update,
 	.walk		= nft_rhash_walk,
 	.features	= NFT_SET_MAP | NFT_SET_OBJECT | NFT_SET_TIMEOUT,
+};
+
+static struct nft_set_type nft_hash_type __read_mostly = {
+	.ops		= &nft_rhash_ops,
 	.owner		= THIS_MODULE,
 };
 
 static int __init nft_hash_module_init(void)
 {
-	return nft_register_set(&nft_rhash_ops);
+	return nft_register_set(&nft_hash_type);
 }
 
 static void __exit nft_hash_module_exit(void)
 {
-	nft_unregister_set(&nft_rhash_ops);
+	nft_unregister_set(&nft_hash_type);
 }
 
 module_init(nft_hash_module_init);
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index fbfb3cbb3916..29d41d378339 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -295,7 +295,9 @@ static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,
 	return true;
 }
 
+static struct nft_set_type nft_rbtree_type;
 static struct nft_set_ops nft_rbtree_ops __read_mostly = {
+	.type		= &nft_rbtree_type,
 	.privsize	= nft_rbtree_privsize,
 	.elemsize	= offsetof(struct nft_rbtree_elem, ext),
 	.estimate	= nft_rbtree_estimate,
@@ -309,17 +311,21 @@ static struct nft_set_ops nft_rbtree_ops __read_mostly = {
 	.lookup		= nft_rbtree_lookup,
 	.walk		= nft_rbtree_walk,
 	.features	= NFT_SET_INTERVAL | NFT_SET_MAP | NFT_SET_OBJECT,
+};
+
+static struct nft_set_type nft_rbtree_type __read_mostly = {
+	.ops		= &nft_rbtree_ops,
 	.owner		= THIS_MODULE,
 };
 
 static int __init nft_rbtree_module_init(void)
 {
-	return nft_register_set(&nft_rbtree_ops);
+	return nft_register_set(&nft_rbtree_type);
 }
 
 static void __exit nft_rbtree_module_exit(void)
 {
-	nft_unregister_set(&nft_rbtree_ops);
+	nft_unregister_set(&nft_rbtree_type);
 }
 
 module_init(nft_rbtree_module_init);
-- 
2.1.4

