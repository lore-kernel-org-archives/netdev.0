From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 7/9] netfilter: nft_hash: add support for timeouts
Date: Fri, 30 Jan 2015 07:46:32 +0000
Message-ID: <1422603994-5836-8-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nft_hash.c | 153 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 107 insertions(+), 46 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index cba0ad2..e7cf886 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -15,6 +15,7 @@
 #include <linux/log2.h>
 #include <linux/jhash.h>
 #include <linux/netlink.h>
+#include <linux/workqueue.h>
 #include <linux/rhashtable.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_tables.h>
@@ -23,19 +24,47 @@
 /* We target a hash table size of 4, element hint is 75% of final size */
 #define NFT_HASH_ELEMENT_HINT 3
 
+struct nft_hash {
+	struct rhashtable		ht;
+	struct delayed_work		gc_work;
+};
+
 struct nft_hash_elem {
 	struct rhash_head		node;
 	struct nft_set_ext		ext;
 };
 
+struct nft_hash_compare_arg {
+	const struct nft_data		*key;
+	unsigned int			len;
+};
+
+static bool nft_hash_compare(void *ptr, void *arg)
+{
+	const struct nft_hash_elem *he = ptr;
+	struct nft_hash_compare_arg *x = arg;
+
+	if (nft_data_cmp(nft_set_ext_key(&he->ext), x->key, x->len))
+		return false;
+	if (nft_set_ext_exists(&he->ext, NFT_SET_EXT_TIMEOUT) &&
+	    time_after_eq(jiffies, *nft_set_ext_timeout(&he->ext)))
+		return false;
+
+	return true;
+}
+
 static bool nft_hash_lookup(const struct nft_set *set,
 			    const struct nft_data *key,
 			    const struct nft_set_ext **ext)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
+	struct nft_hash_compare_arg arg = {
+		.key	= key,
+		.len	= set->klen,
+	};
 
-	he = rhashtable_lookup(priv, key);
+	he = rhashtable_lookup_compare(&priv->ht, key, nft_hash_compare, &arg);
 	if (he != NULL)
 		*ext = &he->ext;
 
@@ -45,10 +74,10 @@ static bool nft_hash_lookup(const struct nft_set *set,
 static int nft_hash_insert(const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he = elem->priv;
 
-	rhashtable_insert(priv, &he->node);
+	rhashtable_insert(&priv->ht, &he->node);
 	return 0;
 }
 
@@ -64,58 +93,43 @@ static void nft_hash_elem_destroy(const struct nft_set *set,
 static void nft_hash_remove(const struct nft_set *set,
 			    const struct nft_set_elem *elem)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he = elem->cookie;
 
-	rhashtable_remove(priv, elem->cookie);
+	rhashtable_remove(&priv->ht, &he->node);
 	synchronize_rcu();
 	kfree(elem->cookie);
 }
 
-struct nft_compare_arg {
-	const struct nft_set *set;
-	struct nft_set_elem *elem;
-};
-
-static bool nft_hash_compare(void *ptr, void *arg)
-{
-	struct nft_hash_elem *he = ptr;
-	struct nft_compare_arg *x = arg;
-
-	if (!nft_data_cmp(nft_set_ext_key(&he->ext), &x->elem->key,
-			  x->set->klen)) {
-		x->elem->cookie = he;
-		x->elem->priv  = he;
-		return true;
-	}
-
-	return false;
-}
-
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 {
-	struct rhashtable *priv = nft_set_priv(set);
-	struct nft_compare_arg arg = {
-		.set = set,
-		.elem = elem,
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he;
+	struct nft_hash_compare_arg arg = {
+		.key	= &elem->key,
+		.len	= set->klen,
 	};
 
-	if (rhashtable_lookup_compare(priv, &elem->key,
-				      &nft_hash_compare, &arg))
+	he = rhashtable_lookup_compare(&priv->ht, &elem->key,
+				       nft_hash_compare, &arg);
+	if (he != NULL) {
+		elem->cookie = he;
+		elem->priv   = he;
 		return 0;
-
+	}
 	return -ENOENT;
 }
 
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			  struct nft_set_iter *iter)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	const struct bucket_table *tbl;
 	struct nft_hash_elem *he;
 	struct nft_set_elem elem;
 	unsigned int i;
 
-	tbl = rht_dereference_rcu(priv->tbl, priv);
+	tbl = rht_dereference_rcu(priv->ht.tbl, &priv->ht);
 	for (i = 0; i < tbl->size; i++) {
 		struct rhash_head *pos;
 
@@ -134,16 +148,48 @@ cont:
 	}
 }
 
+static void nft_hash_gc(struct work_struct *work)
+{
+	const struct nft_set *set;
+	const struct bucket_table *tbl;
+	struct rhash_head *pos, *next;
+	struct nft_hash_elem *he;
+	struct nft_hash *priv;
+	unsigned long timeout;
+	unsigned int i;
+
+	priv = container_of(work, struct nft_hash, gc_work.work);
+	set  = (void *)priv - offsetof(struct nft_set, data);
+
+	mutex_lock(&priv->ht.mutex);
+	tbl = rht_dereference(priv->ht.tbl, &priv->ht);
+	for (i = 0; i < tbl->size; i++) {
+		rht_for_each_entry_safe(he, pos, next, tbl, i, node) {
+			if (!nft_set_ext_exists(&he->ext, NFT_SET_EXT_TIMEOUT))
+				continue;
+			timeout = *nft_set_ext_timeout(&he->ext);
+			if (time_before(jiffies, timeout))
+				continue;
+
+			rhashtable_remove(&priv->ht, &he->node);
+			nft_hash_elem_destroy(set, he);
+		}
+	}
+	mutex_unlock(&priv->ht.mutex);
+
+	queue_delayed_work(system_power_efficient_wq, &priv->gc_work, HZ);
+}
+
 static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 {
-	return sizeof(struct rhashtable);
+	return sizeof(struct nft_hash);
 }
 
 static int nft_hash_init(const struct nft_set *set,
 			 const struct nft_set_desc *desc,
 			 const struct nlattr * const tb[])
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	struct rhashtable_params params = {
 		.nelem_hint = desc->size ? : NFT_HASH_ELEMENT_HINT,
 		.head_offset = offsetof(struct nft_hash_elem, node),
@@ -153,30 +199,42 @@ static int nft_hash_init(const struct nft_set *set,
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
 	};
+	int err;
 
-	return rhashtable_init(priv, &params);
+	err = rhashtable_init(&priv->ht, &params);
+	if (err < 0)
+		return err;
+
+	INIT_DEFERRABLE_WORK(&priv->gc_work, nft_hash_gc);
+	if (set->flags & NFT_SET_TIMEOUT)
+		queue_delayed_work(system_power_efficient_wq,
+				   &priv->gc_work, HZ);
+
+	return 0;
 }
 
 static void nft_hash_destroy(const struct nft_set *set)
 {
-	struct rhashtable *priv = nft_set_priv(set);
+	struct nft_hash *priv = nft_set_priv(set);
 	const struct bucket_table *tbl;
 	struct nft_hash_elem *he;
 	struct rhash_head *pos, *next;
 	unsigned int i;
 
+	cancel_delayed_work_sync(&priv->gc_work);
+
 	/* Stop an eventual async resizing */
-	priv->being_destroyed = true;
-	mutex_lock(&priv->mutex);
+	priv->ht.being_destroyed = true;
+	mutex_lock(&priv->ht.mutex);
 
-	tbl = rht_dereference(priv->tbl, priv);
+	tbl = rht_dereference(priv->ht.tbl, &priv->ht);
 	for (i = 0; i < tbl->size; i++) {
 		rht_for_each_entry_safe(he, pos, next, tbl, i, node)
 			nft_hash_elem_destroy(set, he);
 	}
-	mutex_unlock(&priv->mutex);
+	mutex_unlock(&priv->ht.mutex);
 
-	rhashtable_destroy(priv);
+	rhashtable_destroy(&priv->ht);
 }
 
 static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
@@ -187,9 +245,11 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 	esize = sizeof(struct nft_hash_elem);
 	if (features & NFT_SET_MAP)
 		esize += sizeof(struct nft_data);
+	if (features & NFT_SET_TIMEOUT)
+		esize += sizeof(unsigned long);
 
 	if (desc->size) {
-		est->size = sizeof(struct rhashtable) +
+		est->size = sizeof(struct nft_hash) +
 			    roundup_pow_of_two(desc->size * 4 / 3) *
 			    sizeof(struct nft_hash_elem *) +
 			    desc->size * esize;
@@ -218,7 +278,7 @@ static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.remove		= nft_hash_remove,
 	.lookup		= nft_hash_lookup,
 	.walk		= nft_hash_walk,
-	.features	= NFT_SET_MAP,
+	.features	= NFT_SET_MAP | NFT_SET_TIMEOUT,
 	.owner		= THIS_MODULE,
 };
 
@@ -238,3 +298,4 @@ module_exit(nft_hash_module_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_ALIAS_NFT_SET();
+
-- 
2.1.0

