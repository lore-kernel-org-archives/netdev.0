From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 10/10] rhashtable: Add immediate rehash during insertion
Date: Sun, 22 Mar 2015 19:04:09 +1100
Message-ID: <E1YZarh-0000x3-Fl@gondolin.me.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38030 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbCVIEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 04:04:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reintroduces immediate rehash during insertion.  If
we find during insertion that the table is full or the chain
length exceeds a set limit (currently 16 but may be disabled
with insecure_elasticity) then we will force an immediate rehash.
The rehash will contain an expansion if the table utilisation
exceeds 75%.

If this rehash fails then the insertion will fail.  Otherwise the
insertion will be reattempted in the new hash table.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   32 +++++++++++++++-----
 lib/rhashtable.c           |   71 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 95 insertions(+), 8 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index cba22d8..c19cf89 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -103,6 +103,7 @@ struct rhashtable;
  * @max_size: Maximum size while expanding
  * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
+ * @insecure_elasticity: Set to true to disable chain length checks
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Hash function (default: jhash2 if !(key_len % 4), or jhash)
  * @obj_hashfn: Function to hash object
@@ -116,6 +117,7 @@ struct rhashtable_params {
 	unsigned int		max_size;
 	unsigned int		min_size;
 	u32			nulls_base;
+	bool			insecure_elasticity;
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
@@ -127,6 +129,7 @@ struct rhashtable_params {
  * @tbl: Bucket table
  * @nelems: Number of elements in table
  * @key_len: Key length for hashfn
+ * @elasticity: Maximum chain length before rehash
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
@@ -137,6 +140,7 @@ struct rhashtable {
 	atomic_t			nelems;
 	bool                            being_destroyed;
 	unsigned int			key_len;
+	unsigned int			elasticity;
 	struct rhashtable_params	p;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
@@ -252,6 +256,17 @@ static inline bool rht_grow_above_75(const struct rhashtable *ht,
 	       (!ht->p.max_size || tbl->size < ht->p.max_size);
 }
 
+/**
+ * rht_grow_above_100 - returns true if nelems > table-size
+ * @ht:		hash table
+ * @tbl:	current table
+ */
+static inline bool rht_grow_above_100(const struct rhashtable *ht,
+				      const struct bucket_table *tbl)
+{
+	return atomic_read(&ht->nelems) > tbl->size;
+}
+
 /* The bucket lock is selected based on the hash and protects mutations
  * on a group of hash buckets.
  *
@@ -517,11 +532,12 @@ static inline int __rhashtable_insert_fast(
 		.ht = ht,
 		.key = key,
 	};
-	int err = -EEXIST;
 	struct bucket_table *tbl, *new_tbl;
 	struct rhash_head *head;
 	spinlock_t *lock;
+	unsigned elasticity;
 	unsigned hash;
+	int err;
 
 	rcu_read_lock();
 
@@ -543,22 +559,24 @@ static inline int __rhashtable_insert_fast(
 	}
 
 	new_tbl = rht_dereference_rcu(tbl->future_tbl, ht);
-	if (unlikely(new_tbl)) {
+	if (unlikely(new_tbl || rht_grow_above_100(ht, tbl))) {
+slow_path:
 		err = rhashtable_insert_slow(ht, key, obj, new_tbl);
 		goto out;
 	}
 
-	if (!key)
-		goto skip_lookup;
-
+	err = -EEXIST;
+	elasticity = ht->elasticity;
 	rht_for_each(head, tbl, hash) {
-		if (unlikely(!(params.obj_cmpfn ?
+		if (key &&
+		    unlikely(!(params.obj_cmpfn ?
 			       params.obj_cmpfn(&arg, rht_obj(ht, head)) :
 			       rhashtable_compare(&arg, rht_obj(ht, head)))))
 			goto out;
+		if (!--elasticity)
+			goto slow_path;
 	}
 
-skip_lookup:
 	err = 0;
 
 	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 2ed3cc1..adfe94c 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -364,21 +364,80 @@ unlock:
 		schedule_work(&ht->run_work);
 }
 
+static bool rhashtable_check_elasticity(struct rhashtable *ht,
+					struct bucket_table *tbl,
+					unsigned hash)
+{
+	unsigned elasticity = ht->elasticity;
+	struct rhash_head *head;
+
+	rht_for_each(head, tbl, hash)
+		if (!--elasticity)
+			return true;
+
+	return false;
+}
+
+int rhashtable_expand_or_rehash(struct rhashtable *ht,
+				struct bucket_table *tbl)
+{
+	struct bucket_table *old_tbl;
+	struct bucket_table *new_tbl;
+	unsigned int size;
+	int err;
+
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	if (!tbl)
+		tbl = rhashtable_last_table(ht, old_tbl);
+
+	size = tbl->size;
+
+	if (rht_grow_above_75(ht, tbl))
+		size *= 2;
+	/* More than two rehashes (not resizes) detected. */
+	else if (WARN_ON(old_tbl != tbl && old_tbl->size == size))
+		return -EBUSY;
+
+	new_tbl = bucket_table_alloc(ht, size, GFP_ATOMIC);
+	if (new_tbl == NULL)
+		return -ENOMEM;
+
+	err = rhashtable_rehash_attach(ht, tbl, new_tbl);
+	if (err) {
+		bucket_table_free(new_tbl);
+		if (err == -EEXIST)
+			err = 0;
+	} else
+		schedule_work(&ht->run_work);
+
+	return err;
+}
+
 int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 			   struct rhash_head *obj,
 			   struct bucket_table *tbl)
 {
 	struct rhash_head *head;
 	unsigned hash;
-	int err = -EEXIST;
+	int err;
+
+	if (!tbl)
+		goto rehash;
 
+restart:
 	tbl = rhashtable_last_table(ht, tbl);
 	hash = head_hashfn(ht, tbl, obj);
 	spin_lock_nested(rht_bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
 
+	err = -EEXIST;
 	if (key && rhashtable_lookup_fast(ht, key, ht->p))
 		goto exit;
 
+	err = -EAGAIN;
+	if (rhashtable_check_elasticity(ht, tbl, hash) ||
+	    rht_grow_above_100(ht, tbl))
+		goto exit;
+
 	err = 0;
 
 	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
@@ -391,6 +450,13 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 
 exit:
 	spin_unlock(rht_bucket_lock(tbl, hash));
+ 
+	if (err == -EAGAIN) {
+rehash:
+		err = rhashtable_expand_or_rehash(ht, tbl);
+		if (!err)
+			goto restart;
+	}
 
 	return err;
 }
@@ -667,6 +733,9 @@ int rhashtable_init(struct rhashtable *ht,
 
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
+	if (!params->insecure_elasticity)
+		ht->elasticity = 16;
+
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
 	else
