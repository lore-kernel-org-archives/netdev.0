From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink decision functions
Date: Wed, 25 Feb 2015 16:31:54 +0100
Message-ID: <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50445 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbbBYPcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:32:04 -0500
In-Reply-To: <cover.1424877322.git.daniel@iogearbox.net>
In-Reply-To: <cover.1424877322.git.daniel@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, all real users of rhashtable default their grow and shrink
decision functions to rht_grow_above_75() and rht_shrink_below_30(),
so that there's currently no need to have this explicitly selectable.

It can/should be generic and private inside rhashtable until a real
use case pops up. Since we can make this private, we'll save us this
additional indirection layer and can improve insertion/deletion time
as well.

Reference: http://patchwork.ozlabs.org/patch/443040/
Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/rhashtable.h | 13 -----------
 lib/rhashtable.c           | 56 ++++++++++++++--------------------------------
 lib/test_rhashtable.c      |  1 +
 net/netfilter/nft_hash.c   |  2 --
 net/netlink/af_netlink.c   |  2 --
 net/tipc/socket.c          |  2 --
 6 files changed, 18 insertions(+), 58 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index cb2104b..d438eeb 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -79,12 +79,6 @@ struct rhashtable;
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
- * @grow_decision: If defined, may return true if table should expand
- * @shrink_decision: If defined, may return true if table should shrink
- *
- * Note: when implementing the grow and shrink decision function, min/max
- * shift must be enforced, otherwise, resizing watermarks they set may be
- * useless.
  */
 struct rhashtable_params {
 	size_t			nelem_hint;
@@ -98,10 +92,6 @@ struct rhashtable_params {
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
-	bool			(*grow_decision)(const struct rhashtable *ht,
-						 size_t new_size);
-	bool			(*shrink_decision)(const struct rhashtable *ht,
-						   size_t new_size);
 };
 
 /**
@@ -193,9 +183,6 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params);
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
 
-bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size);
-bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size);
-
 int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
 
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index bcf119b..090641d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -247,26 +247,24 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
  * @ht:		hash table
  * @new_size:	new table size
  */
-bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size)
+static bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size)
 {
 	/* Expand table when exceeding 75% load */
 	return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
 	       (!ht->p.max_shift || atomic_read(&ht->shift) < ht->p.max_shift);
 }
-EXPORT_SYMBOL_GPL(rht_grow_above_75);
 
 /**
  * rht_shrink_below_30 - returns true if nelems < 0.3 * table-size
  * @ht:		hash table
  * @new_size:	new table size
  */
-bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)
+static bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)
 {
 	/* Shrink table beneath 30% load */
 	return atomic_read(&ht->nelems) < (new_size * 3 / 10) &&
 	       (atomic_read(&ht->shift) > ht->p.min_shift);
 }
-EXPORT_SYMBOL_GPL(rht_shrink_below_30);
 
 static void lock_buckets(struct bucket_table *new_tbl,
 			 struct bucket_table *old_tbl, unsigned int hash)
@@ -528,40 +526,19 @@ static void rht_deferred_worker(struct work_struct *work)
 	list_for_each_entry(walker, &ht->walkers, list)
 		walker->resize = true;
 
-	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+	if (rht_grow_above_75(ht, tbl->size))
 		rhashtable_expand(ht);
-	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
+	else if (rht_shrink_below_30(ht, tbl->size))
 		rhashtable_shrink(ht);
-
 unlock:
 	mutex_unlock(&ht->mutex);
 }
 
-static void rhashtable_probe_expand(struct rhashtable *ht)
-{
-	const struct bucket_table *new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
-
-	/* Only adjust the table if no resizing is currently in progress. */
-	if (tbl == new_tbl && ht->p.grow_decision &&
-	    ht->p.grow_decision(ht, tbl->size))
-		schedule_work(&ht->run_work);
-}
-
-static void rhashtable_probe_shrink(struct rhashtable *ht)
-{
-	const struct bucket_table *new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
-
-	/* Only adjust the table if no resizing is currently in progress. */
-	if (tbl == new_tbl && ht->p.shrink_decision &&
-	    ht->p.shrink_decision(ht, tbl->size))
-		schedule_work(&ht->run_work);
-}
-
 static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
-				struct bucket_table *tbl, u32 hash)
+				struct bucket_table *tbl,
+				const struct bucket_table *old_tbl, u32 hash)
 {
+	bool no_resize_running = tbl == old_tbl;
 	struct rhash_head *head;
 
 	hash = rht_bucket_index(tbl, hash);
@@ -577,8 +554,8 @@ static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	rcu_assign_pointer(tbl->buckets[hash], obj);
 
 	atomic_inc(&ht->nelems);
-
-	rhashtable_probe_expand(ht);
+	if (no_resize_running && rht_grow_above_75(ht, tbl->size))
+		schedule_work(&ht->run_work);
 }
 
 /**
@@ -608,7 +585,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 	hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
 
 	lock_buckets(tbl, old_tbl, hash);
-	__rhashtable_insert(ht, obj, tbl, hash);
+	__rhashtable_insert(ht, obj, tbl, old_tbl, hash);
 	unlock_buckets(tbl, old_tbl, hash);
 
 	rcu_read_unlock();
@@ -690,8 +667,11 @@ found:
 	unlock_buckets(new_tbl, old_tbl, new_hash);
 
 	if (ret) {
+		bool no_resize_running = new_tbl == old_tbl;
+
 		atomic_dec(&ht->nelems);
-		rhashtable_probe_shrink(ht);
+		if (no_resize_running && rht_shrink_below_30(ht, new_tbl->size))
+			schedule_work(&ht->run_work);
 	}
 
 	rcu_read_unlock();
@@ -861,7 +841,7 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 		goto exit;
 	}
 
-	__rhashtable_insert(ht, obj, new_tbl, new_hash);
+	__rhashtable_insert(ht, obj, new_tbl, old_tbl, new_hash);
 
 exit:
 	unlock_buckets(new_tbl, old_tbl, new_hash);
@@ -1123,8 +1103,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (!ht->p.hash_rnd)
 		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
 
-	if (ht->p.grow_decision || ht->p.shrink_decision)
-		INIT_WORK(&ht->run_work, rht_deferred_worker);
+	INIT_WORK(&ht->run_work, rht_deferred_worker);
 
 	return 0;
 }
@@ -1142,8 +1121,7 @@ void rhashtable_destroy(struct rhashtable *ht)
 {
 	ht->being_destroyed = true;
 
-	if (ht->p.grow_decision || ht->p.shrink_decision)
-		cancel_work_sync(&ht->run_work);
+	cancel_work_sync(&ht->run_work);
 
 	mutex_lock(&ht->mutex);
 	bucket_table_free(rht_dereference(ht->tbl, ht));
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index f9e9d73..67c7593 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -201,6 +201,7 @@ static int __init test_rht_init(void)
 		.key_offset = offsetof(struct test_obj, value),
 		.key_len = sizeof(int),
 		.hashfn = jhash,
+		.max_shift = 1, /* we expand/shrink manually here */
 		.nulls_base = (3U << RHT_BASE_SHIFT),
 	};
 	int err;
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 61e6c40..c82df0a 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -192,8 +192,6 @@ static int nft_hash_init(const struct nft_set *set,
 		.key_offset = offsetof(struct nft_hash_elem, key),
 		.key_len = set->klen,
 		.hashfn = jhash,
-		.grow_decision = rht_grow_above_75,
-		.shrink_decision = rht_shrink_below_30,
 	};
 
 	return rhashtable_init(priv, &params);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2702673..05919bf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3126,8 +3126,6 @@ static int __init netlink_proto_init(void)
 		.key_len = sizeof(u32), /* portid */
 		.hashfn = jhash,
 		.max_shift = 16, /* 64K */
-		.grow_decision = rht_grow_above_75,
-		.shrink_decision = rht_shrink_below_30,
 	};
 
 	if (err != 0)
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f73e975..b4d4467 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2364,8 +2364,6 @@ int tipc_sk_rht_init(struct net *net)
 		.hashfn = jhash,
 		.max_shift = 20, /* 1M */
 		.min_shift = 8,  /* 256 */
-		.grow_decision = rht_grow_above_75,
-		.shrink_decision = rht_shrink_below_30,
 	};
 
 	return rhashtable_init(&tn->sk_rht, &rht_params);
-- 
1.9.3
