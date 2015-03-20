From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 7/7] rhashtable: Rip out obsolete out-of-line interface
Date: Fri, 20 Mar 2015 21:57:06 +1100
Message-ID: <E1YYuby-0004mT-AN@gondolin.me.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43454 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbbCTK5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that all rhashtable users have been converted over to the
inline interface, this patch removes the unused out-of-line
interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   19 ---
 lib/rhashtable.c           |  284 ---------------------------------------------
 2 files changed, 3 insertions(+), 300 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 2e221a1..e5b76cf 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -1,14 +1,13 @@
 /*
  * Resizable, Scalable, Concurrent Hash Table
  *
+ * Copyright (c) 2015 Herbert Xu <herbert@gondor.apana.org.au>
  * Copyright (c) 2014 Thomas Graf <tgraf@suug.ch>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
  *
- * Based on the following paper by Josh Triplett, Paul E. McKenney
- * and Jonathan Walpole:
- * https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
- *
  * Code partially derived from nft_hash
+ * Rewritten with rehash code from br_multicast plus single list
+ * pointer as suggested by Josh Triplett
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -282,22 +281,10 @@ int rhashtable_init(struct rhashtable *ht,
 int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 			   struct rhash_head *obj,
 			   struct bucket_table *old_tbl);
-void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
-bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
 
 int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
 
-void *rhashtable_lookup(struct rhashtable *ht, const void *key);
-void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
-				bool (*compare)(void *, void *), void *arg);
-
-bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj);
-bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
-				      struct rhash_head *obj,
-				      bool (*compare)(void *, void *),
-				      void *arg);
-
 int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter);
 void rhashtable_walk_exit(struct rhashtable_iter *iter);
 int rhashtable_walk_start(struct rhashtable_iter *iter) __acquires(RCU);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index d1d23fb..83cfedd 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -339,290 +339,6 @@ exit:
 }
 EXPORT_SYMBOL_GPL(rhashtable_insert_slow);
 
-static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
-				bool (*compare)(void *, void *), void *arg)
-{
-	struct bucket_table *tbl, *old_tbl;
-	struct rhash_head *head;
-	bool no_resize_running;
-	unsigned hash;
-	spinlock_t *old_lock;
-	bool success = true;
-
-	rcu_read_lock();
-
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = head_hashfn(ht, old_tbl, obj);
-	old_lock = rht_bucket_lock(old_tbl, hash);
-
-	spin_lock_bh(old_lock);
-
-	/* Because we have already taken the bucket lock in old_tbl,
-	 * if we find that future_tbl is not yet visible then that
-	 * guarantees all other insertions of the same entry will
-	 * also grab the bucket lock in old_tbl because until the
-	 * rehash completes ht->tbl won't be changed.
-	 */
-	tbl = rht_dereference_rcu(old_tbl->future_tbl, ht) ?: old_tbl;
-	if (tbl != old_tbl) {
-		hash = head_hashfn(ht, tbl, obj);
-		spin_lock_nested(rht_bucket_lock(tbl, hash),
-				 SINGLE_DEPTH_NESTING);
-	}
-
-	if (compare &&
-	    rhashtable_lookup_compare(ht, rht_obj(ht, obj) + ht->p.key_offset,
-				      compare, arg)) {
-		success = false;
-		goto exit;
-	}
-
-	no_resize_running = tbl == old_tbl;
-
-	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
-
-	if (rht_is_a_nulls(head))
-		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
-	else
-		RCU_INIT_POINTER(obj->next, head);
-
-	rcu_assign_pointer(tbl->buckets[hash], obj);
-
-	atomic_inc(&ht->nelems);
-	if (no_resize_running && rht_grow_above_75(ht, tbl))
-		schedule_work(&ht->run_work);
-
-exit:
-	if (tbl != old_tbl)
-		spin_unlock(rht_bucket_lock(tbl, hash));
-
-	spin_unlock_bh(old_lock);
-
-	rcu_read_unlock();
-
-	return success;
-}
-
-/**
- * rhashtable_insert - insert object into hash table
- * @ht:		hash table
- * @obj:	pointer to hash head inside object
- *
- * Will take a per bucket spinlock to protect against mutual mutations
- * on the same bucket. Multiple insertions may occur in parallel unless
- * they map to the same bucket lock.
- *
- * It is safe to call this function from atomic context.
- *
- * Will trigger an automatic deferred table resizing if the size grows
- * beyond the watermark indicated by grow_decision() which can be passed
- * to rhashtable_init().
- */
-void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
-{
-	__rhashtable_insert(ht, obj, NULL, NULL);
-}
-EXPORT_SYMBOL_GPL(rhashtable_insert);
-
-static bool __rhashtable_remove(struct rhashtable *ht,
-				struct bucket_table *tbl,
-				struct rhash_head *obj)
-{
-	struct rhash_head __rcu **pprev;
-	struct rhash_head *he;
-	spinlock_t * lock;
-	unsigned hash;
-	bool ret = false;
-
-	hash = head_hashfn(ht, tbl, obj);
-	lock = rht_bucket_lock(tbl, hash);
-
-	spin_lock_bh(lock);
-
-	pprev = &tbl->buckets[hash];
-	rht_for_each(he, tbl, hash) {
-		if (he != obj) {
-			pprev = &he->next;
-			continue;
-		}
-
-		rcu_assign_pointer(*pprev, obj->next);
-		ret = true;
-		break;
-	}
-
-	spin_unlock_bh(lock);
-
-	return ret;
-}
-
-/**
- * rhashtable_remove - remove object from hash table
- * @ht:		hash table
- * @obj:	pointer to hash head inside object
- *
- * Since the hash chain is single linked, the removal operation needs to
- * walk the bucket chain upon removal. The removal operation is thus
- * considerable slow if the hash table is not correctly sized.
- *
- * Will automatically shrink the table via rhashtable_expand() if the
- * shrink_decision function specified at rhashtable_init() returns true.
- *
- * The caller must ensure that no concurrent table mutations occur. It is
- * however valid to have concurrent lookups if they are RCU protected.
- */
-bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
-{
-	struct bucket_table *tbl;
-	bool ret;
-
-	rcu_read_lock();
-
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-
-	/* Because we have already taken (and released) the bucket
-	 * lock in old_tbl, if we find that future_tbl is not yet
-	 * visible then that guarantees the entry to still be in
-	 * the old tbl if it exists.
-	 */
-	while (!(ret = __rhashtable_remove(ht, tbl, obj)) &&
-	       (tbl = rht_dereference_rcu(tbl->future_tbl, ht)))
-		;
-
-	if (ret) {
-		atomic_dec(&ht->nelems);
-		if (rht_shrink_below_30(ht, tbl))
-			schedule_work(&ht->run_work);
-	}
-
-	rcu_read_unlock();
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(rhashtable_remove);
-
-/**
- * rhashtable_lookup - lookup key in hash table
- * @ht:		hash table
- * @key:	pointer to key
- *
- * Computes the hash value for the key and traverses the bucket chain looking
- * for a entry with an identical key. The first matching entry is returned.
- *
- * This lookup function may only be used for fixed key hash table (key_len
- * parameter set). It will BUG() if used inappropriately.
- *
- * Lookups may occur in parallel with hashtable mutations and resizing.
- */
-void *rhashtable_lookup(struct rhashtable *ht, const void *key)
-{
-	return rhashtable_lookup_fast(ht, key, ht->p);
-}
-EXPORT_SYMBOL_GPL(rhashtable_lookup);
-
-/**
- * rhashtable_lookup_compare - search hash table with compare function
- * @ht:		hash table
- * @key:	the pointer to the key
- * @compare:	compare function, must return true on match
- * @arg:	argument passed on to compare function
- *
- * Traverses the bucket chain behind the provided hash value and calls the
- * specified compare function for each entry.
- *
- * Lookups may occur in parallel with hashtable mutations and resizing.
- *
- * Returns the first entry on which the compare function returned true.
- */
-void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
-				bool (*compare)(void *, void *),
-				void *arg)
-{
-	const struct bucket_table *tbl;
-	struct rhash_head *he;
-	u32 hash;
-
-	rcu_read_lock();
-
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-restart:
-	hash = rht_key_hashfn(ht, tbl, key, ht->p);
-	rht_for_each_rcu(he, tbl, hash) {
-		if (!compare(rht_obj(ht, he), arg))
-			continue;
-		rcu_read_unlock();
-		return rht_obj(ht, he);
-	}
-
-	/* Ensure we see any new tables. */
-	smp_rmb();
-
-	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
-	if (unlikely(tbl))
-		goto restart;
-	rcu_read_unlock();
-
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
-
-/**
- * rhashtable_lookup_insert - lookup and insert object into hash table
- * @ht:		hash table
- * @obj:	pointer to hash head inside object
- *
- * Locks down the bucket chain in both the old and new table if a resize
- * is in progress to ensure that writers can't remove from the old table
- * and can't insert to the new table during the atomic operation of search
- * and insertion. Searches for duplicates in both the old and new table if
- * a resize is in progress.
- *
- * This lookup function may only be used for fixed key hash table (key_len
- * parameter set). It will BUG() if used inappropriately.
- *
- * It is safe to call this function from atomic context.
- *
- * Will trigger an automatic deferred table resizing if the size grows
- * beyond the watermark indicated by grow_decision() which can be passed
- * to rhashtable_init().
- */
-bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
-{
-	return rhashtable_lookup_insert_fast(ht, obj, ht->p);
-}
-EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
-
-/**
- * rhashtable_lookup_compare_insert - search and insert object to hash table
- *                                    with compare function
- * @ht:		hash table
- * @obj:	pointer to hash head inside object
- * @compare:	compare function, must return true on match
- * @arg:	argument passed on to compare function
- *
- * Locks down the bucket chain in both the old and new table if a resize
- * is in progress to ensure that writers can't remove from the old table
- * and can't insert to the new table during the atomic operation of search
- * and insertion. Searches for duplicates in both the old and new table if
- * a resize is in progress.
- *
- * Lookups may occur in parallel with hashtable mutations and resizing.
- *
- * Will trigger an automatic deferred table resizing if the size grows
- * beyond the watermark indicated by grow_decision() which can be passed
- * to rhashtable_init().
- */
-bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
-				      struct rhash_head *obj,
-				      bool (*compare)(void *, void *),
-				      void *arg)
-{
-	BUG_ON(!ht->p.key_len);
-
-	return __rhashtable_insert(ht, obj, compare, arg);
-}
-EXPORT_SYMBOL_GPL(rhashtable_lookup_compare_insert);
-
 /**
  * rhashtable_walk_init - Initialise an iterator
  * @ht:		Table to walk over
