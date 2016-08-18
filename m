From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] rhashtable: Remove GFP flag from rhashtable_walk_init
Date: Thu, 18 Aug 2016 16:50:56 +0800
Message-ID: <E1baJ2O-00030u-FE@gondolin.me.apana.org.au>
References: <20160818084854.GA11502@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41793 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbcHRIvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 04:51:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 8f6fd83c6c5ec66a4a70c728535ddcdfef4f3697 ("rhashtable:
accept GFP flags in rhashtable_walk_init") added a GFP flag argument
to rhashtable_walk_init because some users wish to use the walker
in an unsleepable context.

In fact we don't need to allocate memory in rhashtable_walk_init
at all.  The walker is always paired with an iterator so we could
just stash ourselves there.

This patch does that by introducing a new enter function to replace
the existing init function.  This way we don't have to churn all
the existing users again.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   14 ++++++++++---
 lib/rhashtable.c           |   46 +++++++++++++++++----------------------------
 2 files changed, 29 insertions(+), 31 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 3eef080..8b72ee7 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -173,7 +173,7 @@ struct rhashtable_walker {
 struct rhashtable_iter {
 	struct rhashtable *ht;
 	struct rhash_head *p;
-	struct rhashtable_walker *walker;
+	struct rhashtable_walker walker;
 	unsigned int slot;
 	unsigned int skip;
 };
@@ -346,8 +346,8 @@ struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
 					    struct bucket_table *old_tbl);
 int rhashtable_insert_rehash(struct rhashtable *ht, struct bucket_table *tbl);
 
-int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter,
-			 gfp_t gfp);
+void rhashtable_walk_enter(struct rhashtable *ht,
+			   struct rhashtable_iter *iter);
 void rhashtable_walk_exit(struct rhashtable_iter *iter);
 int rhashtable_walk_start(struct rhashtable_iter *iter) __acquires(RCU);
 void *rhashtable_walk_next(struct rhashtable_iter *iter);
@@ -906,4 +906,12 @@ static inline int rhashtable_replace_fast(
 	return err;
 }
 
+/* Obsolete function, do not use in new code. */
+static inline int rhashtable_walk_init(struct rhashtable *ht,
+				       struct rhashtable_iter *iter, gfp_t gfp)
+{
+	rhashtable_walk_enter(ht, iter);
+	return 0;
+}
+
 #endif /* _LINUX_RHASHTABLE_H */
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5d845ff..5b0a2b3 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -484,10 +484,9 @@ exit:
 EXPORT_SYMBOL_GPL(rhashtable_insert_slow);
 
 /**
- * rhashtable_walk_init - Initialise an iterator
+ * rhashtable_walk_enter - Initialise an iterator
  * @ht:		Table to walk over
  * @iter:	Hash table Iterator
- * @gfp:	GFP flags for allocations
  *
  * This function prepares a hash table walk.
  *
@@ -502,30 +501,22 @@ EXPORT_SYMBOL_GPL(rhashtable_insert_slow);
  * This function may sleep so you must not call it from interrupt
  * context or with spin locks held.
  *
- * You must call rhashtable_walk_exit if this function returns
- * successfully.
+ * You must call rhashtable_walk_exit after this function returns.
  */
-int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter,
-			 gfp_t gfp)
+void rhashtable_walk_enter(struct rhashtable *ht, struct rhashtable_iter *iter)
 {
 	iter->ht = ht;
 	iter->p = NULL;
 	iter->slot = 0;
 	iter->skip = 0;
 
-	iter->walker = kmalloc(sizeof(*iter->walker), gfp);
-	if (!iter->walker)
-		return -ENOMEM;
-
 	spin_lock(&ht->lock);
-	iter->walker->tbl =
+	iter->walker.tbl =
 		rcu_dereference_protected(ht->tbl, lockdep_is_held(&ht->lock));
-	list_add(&iter->walker->list, &iter->walker->tbl->walkers);
+	list_add(&iter->walker.list, &iter->walker.tbl->walkers);
 	spin_unlock(&ht->lock);
-
-	return 0;
 }
-EXPORT_SYMBOL_GPL(rhashtable_walk_init);
+EXPORT_SYMBOL_GPL(rhashtable_walk_enter);
 
 /**
  * rhashtable_walk_exit - Free an iterator
@@ -536,10 +527,9 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_init);
 void rhashtable_walk_exit(struct rhashtable_iter *iter)
 {
 	spin_lock(&iter->ht->lock);
-	if (iter->walker->tbl)
-		list_del(&iter->walker->list);
+	if (iter->walker.tbl)
+		list_del(&iter->walker.list);
 	spin_unlock(&iter->ht->lock);
-	kfree(iter->walker);
 }
 EXPORT_SYMBOL_GPL(rhashtable_walk_exit);
 
@@ -565,12 +555,12 @@ int rhashtable_walk_start(struct rhashtable_iter *iter)
 	rcu_read_lock();
 
 	spin_lock(&ht->lock);
-	if (iter->walker->tbl)
-		list_del(&iter->walker->list);
+	if (iter->walker.tbl)
+		list_del(&iter->walker.list);
 	spin_unlock(&ht->lock);
 
-	if (!iter->walker->tbl) {
-		iter->walker->tbl = rht_dereference_rcu(ht->tbl, ht);
+	if (!iter->walker.tbl) {
+		iter->walker.tbl = rht_dereference_rcu(ht->tbl, ht);
 		return -EAGAIN;
 	}
 
@@ -592,7 +582,7 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_start);
  */
 void *rhashtable_walk_next(struct rhashtable_iter *iter)
 {
-	struct bucket_table *tbl = iter->walker->tbl;
+	struct bucket_table *tbl = iter->walker.tbl;
 	struct rhashtable *ht = iter->ht;
 	struct rhash_head *p = iter->p;
 
@@ -625,8 +615,8 @@ next:
 	/* Ensure we see any new tables. */
 	smp_rmb();
 
-	iter->walker->tbl = rht_dereference_rcu(tbl->future_tbl, ht);
-	if (iter->walker->tbl) {
+	iter->walker.tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (iter->walker.tbl) {
 		iter->slot = 0;
 		iter->skip = 0;
 		return ERR_PTR(-EAGAIN);
@@ -646,7 +636,7 @@ void rhashtable_walk_stop(struct rhashtable_iter *iter)
 	__releases(RCU)
 {
 	struct rhashtable *ht;
-	struct bucket_table *tbl = iter->walker->tbl;
+	struct bucket_table *tbl = iter->walker.tbl;
 
 	if (!tbl)
 		goto out;
@@ -655,9 +645,9 @@ void rhashtable_walk_stop(struct rhashtable_iter *iter)
 
 	spin_lock(&ht->lock);
 	if (tbl->rehash < tbl->size)
-		list_add(&iter->walker->list, &tbl->walkers);
+		list_add(&iter->walker.list, &tbl->walkers);
 	else
-		iter->walker->tbl = NULL;
+		iter->walker.tbl = NULL;
 	spin_unlock(&ht->lock);
 
 	iter->p = NULL;
