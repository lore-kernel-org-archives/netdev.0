From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5 net-next] rhashtable: Add rhashtable_free_and_destroy()
Date: Tue, 24 Mar 2015 14:18:20 +0100
Message-ID: <1758cf3ce7934f268bc9ba9d3404a225781144ab.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34737 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbCXNSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:18:32 -0400
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rhashtable_destroy() variant which stops rehashes, iterates over
the table and calls a callback to release resources.

Avoids need for nft_hash to embed rhashtable internals and allows to
get rid of the being_destroyed flag. It also saves a 2nd mutex
lock upon destruction.

Also fixes an RCU lockdep splash on nft set destruction due to
calling rht_for_each_entry_safe() without holding bucket locks.
Open code this loop as we need know that no mutations may occur in
parallel.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |  5 +++--
 lib/rhashtable.c           | 49 ++++++++++++++++++++++++++++++++++++----------
 net/netfilter/nft_hash.c   | 25 +++++++----------------
 3 files changed, 49 insertions(+), 30 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index d0ca452..1995db3 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -134,12 +134,10 @@ struct rhashtable_params {
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
  * @lock: Spin lock to protect walker list
- * @being_destroyed: True if table is set up for destruction
  */
 struct rhashtable {
 	struct bucket_table __rcu	*tbl;
 	atomic_t			nelems;
-	bool                            being_destroyed;
 	unsigned int			key_len;
 	unsigned int			elasticity;
 	struct rhashtable_params	p;
@@ -332,6 +330,9 @@ int rhashtable_walk_start(struct rhashtable_iter *iter) __acquires(RCU);
 void *rhashtable_walk_next(struct rhashtable_iter *iter);
 void rhashtable_walk_stop(struct rhashtable_iter *iter) __releases(RCU);
 
+void rhashtable_free_and_destroy(struct rhashtable *ht,
+				 void (*free_fn)(void *ptr, void *arg),
+				 void *arg);
 void rhashtable_destroy(struct rhashtable *ht);
 
 #define rht_dereference(p, ht) \
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 93374d7..bb3a792 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -359,8 +359,6 @@ static void rht_deferred_worker(struct work_struct *work)
 
 	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
-	if (ht->being_destroyed)
-		goto unlock;
 
 	tbl = rht_dereference(ht->tbl, ht);
 	tbl = rhashtable_last_table(ht, tbl);
@@ -372,7 +370,6 @@ static void rht_deferred_worker(struct work_struct *work)
 
 	err = rhashtable_rehash_table(ht);
 
-unlock:
 	mutex_unlock(&ht->mutex);
 
 	if (err)
@@ -771,21 +768,53 @@ int rhashtable_init(struct rhashtable *ht,
 EXPORT_SYMBOL_GPL(rhashtable_init);
 
 /**
- * rhashtable_destroy - destroy hash table
+ * rhashtable_free_and_destroy - free elements and destroy hash table
  * @ht:		the hash table to destroy
+ * @free_fn:	callback to release resources of element
+ * @arg:	pointer passed to free_fn
  *
- * Frees the bucket array. This function is not rcu safe, therefore the caller
- * has to make sure that no resizing may happen by unpublishing the hashtable
- * and waiting for the quiescent cycle before releasing the bucket array.
+ * Stops an eventual async resize. If defined, invokes free_fn for each
+ * element to releasal resources. Please note that RCU protected
+ * readers may still be accessing the elements. Releasing of resources
+ * must occur in a compatible manner. Then frees the bucket array.
+ *
+ * This function will eventually sleep to wait for an async resize
+ * to complete. The caller is responsible that no further write operations
+ * occurs in parallel.
  */
-void rhashtable_destroy(struct rhashtable *ht)
+void rhashtable_free_and_destroy(struct rhashtable *ht,
+				 void (*free_fn)(void *ptr, void *arg),
+				 void *arg)
 {
-	ht->being_destroyed = true;
+	const struct bucket_table *tbl;
+	unsigned int i;
 
 	cancel_work_sync(&ht->run_work);
 
 	mutex_lock(&ht->mutex);
-	bucket_table_free(rht_dereference(ht->tbl, ht));
+	tbl = rht_dereference(ht->tbl, ht);
+	if (free_fn) {
+		for (i = 0; i < tbl->size; i++) {
+			struct rhash_head *pos, *next;
+
+			for (pos = rht_dereference(tbl->buckets[i], ht),
+			     next = !rht_is_a_nulls(pos) ?
+					rht_dereference(pos->next, ht) : NULL;
+			     !rht_is_a_nulls(pos);
+			     pos = next,
+			     next = !rht_is_a_nulls(pos) ?
+					rht_dereference(pos->next, ht) : NULL)
+				free_fn(rht_obj(ht, pos), arg);
+		}
+	}
+
+	bucket_table_free(tbl);
 	mutex_unlock(&ht->mutex);
 }
+EXPORT_SYMBOL_GPL(rhashtable_free_and_destroy);
+
+void rhashtable_destroy(struct rhashtable *ht)
+{
+	return rhashtable_free_and_destroy(ht, NULL, NULL);
+}
 EXPORT_SYMBOL_GPL(rhashtable_destroy);
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 2986f1d..ad29965 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -187,26 +187,15 @@ static int nft_hash_init(const struct nft_set *set,
 	return rhashtable_init(priv, &params);
 }
 
-static void nft_hash_destroy(const struct nft_set *set)
+static void nft_free_element(void *ptr, void *arg)
 {
-	struct rhashtable *priv = nft_set_priv(set);
-	const struct bucket_table *tbl;
-	struct nft_hash_elem *he;
-	struct rhash_head *pos, *next;
-	unsigned int i;
-
-	/* Stop an eventual async resizing */
-	priv->being_destroyed = true;
-	mutex_lock(&priv->mutex);
-
-	tbl = rht_dereference(priv->tbl, priv);
-	for (i = 0; i < tbl->size; i++) {
-		rht_for_each_entry_safe(he, pos, next, tbl, i, node)
-			nft_hash_elem_destroy(set, he);
-	}
-	mutex_unlock(&priv->mutex);
+	nft_hash_elem_destroy((const struct nft_set *)arg, ptr);
+}
 
-	rhashtable_destroy(priv);
+static void nft_hash_destroy(const struct nft_set *set)
+{
+	rhashtable_free_and_destroy(nft_set_priv(set), nft_free_element,
+				    (void *)set);
 }
 
 static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
-- 
1.9.3
