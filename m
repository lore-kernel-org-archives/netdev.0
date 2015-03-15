From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 10/14] rhashtable: Rip out obsolete compare interface
Date: Sun, 15 Mar 2015 21:44:35 +1100
Message-ID: <E1YX627-0005oh-Le@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47106 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbbCOKok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the only user of rhashtable_lookup_compare_insert and
rhashtable_lookup_compare (i.e., netlink) has switched over to
the new obj_hashfn based interface, we can rip them out safely.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    6 -
 lib/rhashtable.c           |  143 +--------------------------------------------
 2 files changed, 4 insertions(+), 145 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index de7ac49..00fe294 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -193,14 +193,8 @@ int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
 
 void *rhashtable_lookup(struct rhashtable *ht, const void *key);
-void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
-				bool (*compare)(void *, void *), void *arg);
 
 bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj);
-bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
-				      struct rhash_head *obj,
-				      bool (*compare)(void *, void *),
-				      void *arg);
 int rhashtable_lookup_insert_key(struct rhashtable *ht,
 				 const void *key, struct rhash_head *obj);
 
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 8b3cae3..e33e7b9 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -1,13 +1,16 @@
 /*
  * Resizable, Scalable, Concurrent Hash Table
  *
+ * Copyright (c) 2015 Herbert Xu <herbert@gondor.apana.org.au>
  * Copyright (c) 2014-2015 Thomas Graf <tgraf@suug.ch>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
  *
  * Based on the following paper:
  * https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
  *
- * Code partially derived from nft_hash
+ * Code originally partially derived from nft_hash
+ * Rewritten with rehash code from br_multicast plus single list
+ * pointer as suggested by Josh Triplett
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -439,70 +442,6 @@ exit:
 	return err;
 }
 
-static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
-				bool (*compare)(void *, void *), void *arg)
-{
-	struct bucket_table *tbl, *old_tbl;
-	struct rhash_head *head;
-	bool no_resize_running;
-	unsigned hash;
-	bool success = true;
-
-	rcu_read_lock();
-
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = head_hashfn(ht, old_tbl, obj);
-
-	spin_lock_bh(bucket_lock(old_tbl, hash));
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
-		spin_lock_nested(bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
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
-	if (tbl != old_tbl) {
-		hash = head_hashfn(ht, tbl, obj);
-		spin_unlock(bucket_lock(tbl, hash));
-	}
-
-	hash = head_hashfn(ht, old_tbl, obj);
-	spin_unlock_bh(bucket_lock(old_tbl, hash));
-
-	rcu_read_unlock();
-
-	return success;
-}
-
 /**
  * rhashtable_insert - insert object into hash table
  * @ht:		hash table
@@ -671,51 +610,6 @@ restart:
 EXPORT_SYMBOL_GPL(rhashtable_lookup);
 
 /**
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
-				bool (*compare)(void *, void *), void *arg)
-{
-	const struct bucket_table *tbl;
-	struct rhash_head *he;
-	u32 hash;
-
-	rcu_read_lock();
-
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-restart:
-	hash = key_hashfn(ht, tbl, key);
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
  * rhashtable_lookup_insert - lookup and insert object into hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
@@ -747,35 +641,6 @@ bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
 EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
 
 /**
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
-	return __rhashtable_insert(ht, obj, compare, arg);
-}
-EXPORT_SYMBOL_GPL(rhashtable_lookup_compare_insert);
-
-/**
  * rhashtable_lookup_insert_key - search and insert object to hash table
  *                                with explicit key
  * @ht:		hash table
