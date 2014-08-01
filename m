From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 3/3] nftables: Convert nft_hash to use generic rhashtable
Date: Fri,  1 Aug 2014 13:58:18 +0200
Message-ID: <bd4d9fa542072358cb0bd77e493ec5785a1d9666.1406891028.git.tgraf@suug.ch>
References: <cover.1406891028.git.tgraf@suug.ch>
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	challa@noironetworks.com, walpole@cs.pdx.edu, dev@openvswitch.org,
	tklauser@distanz.ch, netfilter-devel@vger.kernel.org,
	nikolay@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52157 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbaHAL6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 07:58:23 -0400
In-Reply-To: <cover.1406891028.git.tgraf@suug.ch>
In-Reply-To: <cover.1406891028.git.tgraf@suug.ch>
References: <cover.1406891028.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sizing of the hash table and the practice of requiring a lookup
to retrieve the pprev to be stored in the element cookie before the
deletion of an entry is left intact.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nft_hash.c | 292 +++++++++--------------------------------------
 1 file changed, 54 insertions(+), 238 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 4080ed6..35059d2 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -15,209 +15,40 @@
 #include <linux/log2.h>
 #include <linux/jhash.h>
 #include <linux/netlink.h>
-#include <linux/vmalloc.h>
+#include <linux/rhashtable.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 
-#define NFT_HASH_MIN_SIZE	4UL
-
-struct nft_hash {
-	struct nft_hash_table __rcu	*tbl;
-};
-
-struct nft_hash_table {
-	unsigned int			size;
-	struct nft_hash_elem __rcu	*buckets[];
-};
+/* We target a hash table size of 4, element hint is 75% of final size */
+#define NFT_HASH_ELEMENT_HINT 3
 
 struct nft_hash_elem {
-	struct nft_hash_elem __rcu	*next;
+	struct rhash_head		node;
 	struct nft_data			key;
 	struct nft_data			data[];
 };
 
-#define nft_hash_for_each_entry(i, head) \
-	for (i = nft_dereference(head); i != NULL; i = nft_dereference(i->next))
-#define nft_hash_for_each_entry_rcu(i, head) \
-	for (i = rcu_dereference(head); i != NULL; i = rcu_dereference(i->next))
-
-static u32 nft_hash_rnd __read_mostly;
-static bool nft_hash_rnd_initted __read_mostly;
-
-static unsigned int nft_hash_data(const struct nft_data *data,
-				  unsigned int hsize, unsigned int len)
-{
-	unsigned int h;
-
-	h = jhash(data->data, len, nft_hash_rnd);
-	return h & (hsize - 1);
-}
-
 static bool nft_hash_lookup(const struct nft_set *set,
 			    const struct nft_data *key,
 			    struct nft_data *data)
 {
-	const struct nft_hash *priv = nft_set_priv(set);
-	const struct nft_hash_table *tbl = rcu_dereference(priv->tbl);
+	const struct rhashtable *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
-	unsigned int h;
-
-	h = nft_hash_data(key, tbl->size, set->klen);
-	nft_hash_for_each_entry_rcu(he, tbl->buckets[h]) {
-		if (nft_data_cmp(&he->key, key, set->klen))
-			continue;
-		if (set->flags & NFT_SET_MAP)
-			nft_data_copy(data, he->data);
-		return true;
-	}
-	return false;
-}
-
-static void nft_hash_tbl_free(const struct nft_hash_table *tbl)
-{
-	kvfree(tbl);
-}
-
-static unsigned int nft_hash_tbl_size(unsigned int nelem)
-{
-	return max(roundup_pow_of_two(nelem * 4 / 3), NFT_HASH_MIN_SIZE);
-}
-
-static struct nft_hash_table *nft_hash_tbl_alloc(unsigned int nbuckets)
-{
-	struct nft_hash_table *tbl;
-	size_t size;
-
-	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
-	tbl = kzalloc(size, GFP_KERNEL | __GFP_REPEAT | __GFP_NOWARN);
-	if (tbl == NULL)
-		tbl = vzalloc(size);
-	if (tbl == NULL)
-		return NULL;
-	tbl->size = nbuckets;
-
-	return tbl;
-}
-
-static void nft_hash_chain_unzip(const struct nft_set *set,
-				 const struct nft_hash_table *ntbl,
-				 struct nft_hash_table *tbl, unsigned int n)
-{
-	struct nft_hash_elem *he, *last, *next;
-	unsigned int h;
-
-	he = nft_dereference(tbl->buckets[n]);
-	if (he == NULL)
-		return;
-	h = nft_hash_data(&he->key, ntbl->size, set->klen);
-
-	/* Find last element of first chain hashing to bucket h */
-	last = he;
-	nft_hash_for_each_entry(he, he->next) {
-		if (nft_hash_data(&he->key, ntbl->size, set->klen) != h)
-			break;
-		last = he;
-	}
-
-	/* Unlink first chain from the old table */
-	RCU_INIT_POINTER(tbl->buckets[n], last->next);
-
-	/* If end of chain reached, done */
-	if (he == NULL)
-		return;
-
-	/* Find first element of second chain hashing to bucket h */
-	next = NULL;
-	nft_hash_for_each_entry(he, he->next) {
-		if (nft_hash_data(&he->key, ntbl->size, set->klen) != h)
-			continue;
-		next = he;
-		break;
-	}
-
-	/* Link the two chains */
-	RCU_INIT_POINTER(last->next, next);
-}
-
-static int nft_hash_tbl_expand(const struct nft_set *set, struct nft_hash *priv)
-{
-	struct nft_hash_table *tbl = nft_dereference(priv->tbl), *ntbl;
-	struct nft_hash_elem *he;
-	unsigned int i, h;
-	bool complete;
-
-	ntbl = nft_hash_tbl_alloc(tbl->size * 2);
-	if (ntbl == NULL)
-		return -ENOMEM;
-
-	/* Link new table's buckets to first element in the old table
-	 * hashing to the new bucket.
-	 */
-	for (i = 0; i < ntbl->size; i++) {
-		h = i < tbl->size ? i : i - tbl->size;
-		nft_hash_for_each_entry(he, tbl->buckets[h]) {
-			if (nft_hash_data(&he->key, ntbl->size, set->klen) != i)
-				continue;
-			RCU_INIT_POINTER(ntbl->buckets[i], he);
-			break;
-		}
-	}
-
-	/* Publish new table */
-	rcu_assign_pointer(priv->tbl, ntbl);
 
-	/* Unzip interleaved hash chains */
-	do {
-		/* Wait for readers to use new table/unzipped chains */
-		synchronize_rcu();
+	he = rhashtable_lookup(priv, key);
+	if (he && set->flags & NFT_SET_MAP)
+		nft_data_copy(data, he->data);
 
-		complete = true;
-		for (i = 0; i < tbl->size; i++) {
-			nft_hash_chain_unzip(set, ntbl, tbl, i);
-			if (tbl->buckets[i] != NULL)
-				complete = false;
-		}
-	} while (!complete);
-
-	nft_hash_tbl_free(tbl);
-	return 0;
-}
-
-static int nft_hash_tbl_shrink(const struct nft_set *set, struct nft_hash *priv)
-{
-	struct nft_hash_table *tbl = nft_dereference(priv->tbl), *ntbl;
-	struct nft_hash_elem __rcu **pprev;
-	unsigned int i;
-
-	ntbl = nft_hash_tbl_alloc(tbl->size / 2);
-	if (ntbl == NULL)
-		return -ENOMEM;
-
-	for (i = 0; i < ntbl->size; i++) {
-		ntbl->buckets[i] = tbl->buckets[i];
-
-		for (pprev = &ntbl->buckets[i]; *pprev != NULL;
-		     pprev = &nft_dereference(*pprev)->next)
-			;
-		RCU_INIT_POINTER(*pprev, tbl->buckets[i + ntbl->size]);
-	}
-
-	/* Publish new table */
-	rcu_assign_pointer(priv->tbl, ntbl);
-	synchronize_rcu();
-
-	nft_hash_tbl_free(tbl);
-	return 0;
+	return !!he;
 }
 
 static int nft_hash_insert(const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_table *tbl = nft_dereference(priv->tbl);
+	struct rhashtable *priv = nft_set_priv(set);
 	struct nft_hash_elem *he;
-	unsigned int size, h;
+	unsigned int size;
 
 	if (elem->flags != 0)
 		return -EINVAL;
@@ -234,13 +65,7 @@ static int nft_hash_insert(const struct nft_set *set,
 	if (set->flags & NFT_SET_MAP)
 		nft_data_copy(he->data, &elem->data);
 
-	h = nft_hash_data(&he->key, tbl->size, set->klen);
-	RCU_INIT_POINTER(he->next, tbl->buckets[h]);
-	rcu_assign_pointer(tbl->buckets[h], he);
-
-	/* Expand table when exceeding 75% load */
-	if (set->nelems + 1 > tbl->size / 4 * 3)
-		nft_hash_tbl_expand(set, priv);
+	rhashtable_insert(priv, &he->node, GFP_KERNEL);
 
 	return 0;
 }
@@ -257,36 +82,28 @@ static void nft_hash_elem_destroy(const struct nft_set *set,
 static void nft_hash_remove(const struct nft_set *set,
 			    const struct nft_set_elem *elem)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_table *tbl = nft_dereference(priv->tbl);
-	struct nft_hash_elem *he, __rcu **pprev;
+	struct rhashtable *priv = nft_set_priv(set);
+	struct rhash_head *he, __rcu **pprev;
 
 	pprev = elem->cookie;
-	he = nft_dereference((*pprev));
-
-	RCU_INIT_POINTER(*pprev, he->next);
-	synchronize_rcu();
-	kfree(he);
+	he = rht_dereference((*pprev), priv);
 
-	/* Shrink table beneath 30% load */
-	if (set->nelems - 1 < tbl->size * 3 / 10 &&
-	    tbl->size > NFT_HASH_MIN_SIZE)
-		nft_hash_tbl_shrink(set, priv);
+	rhashtable_remove_pprev(priv, he, pprev, GFP_KERNEL);
 }
 
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 {
-	const struct nft_hash *priv = nft_set_priv(set);
-	const struct nft_hash_table *tbl = nft_dereference(priv->tbl);
-	struct nft_hash_elem __rcu * const *pprev;
+	const struct rhashtable *priv = nft_set_priv(set);
+	const struct bucket_table *tbl = rht_dereference_rcu(priv->tbl, priv);
+	struct rhash_head __rcu * const *pprev;
 	struct nft_hash_elem *he;
-	unsigned int h;
+	u32 h;
 
-	h = nft_hash_data(&elem->key, tbl->size, set->klen);
+	h = rhashtable_hashfn(priv, &elem->key, set->klen);
 	pprev = &tbl->buckets[h];
-	nft_hash_for_each_entry(he, tbl->buckets[h]) {
+	rht_for_each_entry_rcu(he, tbl->buckets[h], node) {
 		if (nft_data_cmp(&he->key, &elem->key, set->klen)) {
-			pprev = &he->next;
+			pprev = &he->node.next;
 			continue;
 		}
 
@@ -302,14 +119,15 @@ static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			  struct nft_set_iter *iter)
 {
-	const struct nft_hash *priv = nft_set_priv(set);
-	const struct nft_hash_table *tbl = nft_dereference(priv->tbl);
+	const struct rhashtable *priv = nft_set_priv(set);
+	const struct bucket_table *tbl;
 	const struct nft_hash_elem *he;
 	struct nft_set_elem elem;
 	unsigned int i;
 
+	tbl = rht_dereference_rcu(priv->tbl, priv);
 	for (i = 0; i < tbl->size; i++) {
-		nft_hash_for_each_entry(he, tbl->buckets[i]) {
+		rht_for_each_entry_rcu(he, tbl->buckets[i], node) {
 			if (iter->count < iter->skip)
 				goto cont;
 
@@ -329,48 +147,46 @@ cont:
 
 static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 {
-	return sizeof(struct nft_hash);
+	return sizeof(struct rhashtable);
+}
+
+static int lockdep_nfnl_lock_is_held(void)
+{
+	return lockdep_nfnl_is_held(NFNL_SUBSYS_NFTABLES);
 }
 
 static int nft_hash_init(const struct nft_set *set,
 			 const struct nft_set_desc *desc,
 			 const struct nlattr * const tb[])
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_table *tbl;
-	unsigned int size;
+	struct rhashtable *priv = nft_set_priv(set);
+	struct rhashtable_params params = {
+		.nelem_hint = desc->size ? : NFT_HASH_ELEMENT_HINT,
+		.head_offset = offsetof(struct nft_hash_elem, node),
+		.key_offset = offsetof(struct nft_hash_elem, key),
+		.key_len = set->klen,
+		.hashfn = jhash,
+		.grow_decision = rht_grow_above_75,
+		.shrink_decision = rht_shrink_below_30,
+		.mutex_is_held = lockdep_nfnl_lock_is_held,
+	};
 
-	if (unlikely(!nft_hash_rnd_initted)) {
-		get_random_bytes(&nft_hash_rnd, 4);
-		nft_hash_rnd_initted = true;
-	}
-
-	size = NFT_HASH_MIN_SIZE;
-	if (desc->size)
-		size = nft_hash_tbl_size(desc->size);
-
-	tbl = nft_hash_tbl_alloc(size);
-	if (tbl == NULL)
-		return -ENOMEM;
-	RCU_INIT_POINTER(priv->tbl, tbl);
-	return 0;
+	return rhashtable_init(priv, &params);
 }
 
 static void nft_hash_destroy(const struct nft_set *set)
 {
-	const struct nft_hash *priv = nft_set_priv(set);
-	const struct nft_hash_table *tbl = nft_dereference(priv->tbl);
+	const struct rhashtable *priv = nft_set_priv(set);
+	const struct bucket_table *tbl;
 	struct nft_hash_elem *he, *next;
 	unsigned int i;
 
-	for (i = 0; i < tbl->size; i++) {
-		for (he = nft_dereference(tbl->buckets[i]); he != NULL;
-		     he = next) {
-			next = nft_dereference(he->next);
+	tbl = rht_dereference(priv->tbl, priv);
+	for (i = 0; i < tbl->size; i++)
+		rht_for_each_entry_safe(he, next, tbl->buckets[i], priv, node)
 			nft_hash_elem_destroy(set, he);
-		}
-	}
-	kfree(tbl);
+
+	rhashtable_destroy(priv);
 }
 
 static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
@@ -383,8 +199,8 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 		esize += FIELD_SIZEOF(struct nft_hash_elem, data[0]);
 
 	if (desc->size) {
-		est->size = sizeof(struct nft_hash) +
-			    nft_hash_tbl_size(desc->size) *
+		est->size = sizeof(struct rhashtable) +
+			    roundup_pow_of_two(desc->size * 4 / 3) *
 			    sizeof(struct nft_hash_elem *) +
 			    desc->size * esize;
 	} else {
-- 
1.9.3
