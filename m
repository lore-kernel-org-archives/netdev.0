From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 2/3] rhashtable: Add a function for in order insertion and lookup in buckets
Date: Tue, 14 Jul 2015 16:45:48 -0700
Message-ID: <1436917549-3666965-3-git-send-email-tom@herbertland.com>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>,
	<herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59356 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752558AbbGNXqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 19:46:12 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6ENiWCw022532
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:46:12 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vnc1e81j4-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:46:12 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 8136e40c2a8211e5b45c24be0595f910-e67d4270 for <netdev@vger.kernel.org>;	Tue,
 14 Jul 2015 16:46:10 -0700
In-Reply-To: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The obj_orderfn function may be specified in the parameters for a
rhashtable. When inserting an element this function is used to order
objects in a bucket list (greatest to least ordering value).This
allows entries to have wild card fields, where entries with
more specific information match are placed first in the bucket.
When a lookup is done, the first match found will contain
the most specific match.

In order to maintain ordering guarantees during rehash, the
rhashtable_lookup_ordered_cmpfn was added. This function will check
future tables for matches that would have a greater insertion order
than a match found in an older table.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 108 +++++++++++++++++++++++++++++++++++++++++++--
 lib/rhashtable.c           |  20 ++++-----
 2 files changed, 115 insertions(+), 13 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 78a4e9b..651b5226 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -92,6 +92,7 @@ typedef u32 (*rht_hashfn_t)(const void *data, u32 len, u32 seed);
 typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 len, u32 seed);
 typedef int (*rht_obj_cmpfn_t)(struct rhashtable_compare_arg *arg,
 			       const void *obj);
+typedef int (*rht_obj_orderfn_t)(const void *obj);
 
 struct rhashtable;
 
@@ -111,6 +112,7 @@ struct rhashtable;
  * @hashfn: Hash function (default: jhash2 if !(key_len % 4), or jhash)
  * @obj_hashfn: Function to hash object
  * @obj_cmpfn: Function to compare key with object
+ * @obj_orderfn: Function to order an object for in-order insertion
  */
 struct rhashtable_params {
 	size_t			nelem_hint;
@@ -127,6 +129,7 @@ struct rhashtable_params {
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
 	rht_obj_cmpfn_t		obj_cmpfn;
+	rht_obj_orderfn_t	obj_orderfn;
 };
 
 /**
@@ -570,6 +573,104 @@ static inline void *rhashtable_lookup_fast(
 					    params.obj_cmpfn);
 }
 
+/**
+ * rhashtable_lookup_ordered_cmpfn - search table that uses ordered insertion
+ * @ht:		hash table
+ * @key:	the pointer to the key
+ * @params:	hash table parameters
+ * @obj_cmpfn:	compare function
+ *
+ * Computes the hash value for the key and traverses the bucket chain looking
+ * for a entry that matches the key. The bucket chains are assumed to be
+ * ordered. When a match is found this is recorded as a candidate. The
+ * search proceeds to future tables (rehash is in progress) to check is there
+ * is match which which have greater ordering precedence.
+ *
+ * Returns the first entry on which the compare function returned true adhering
+ * to ordering guarantee.
+ */
+static inline void *rhashtable_lookup_ordered_cmpfn(
+	struct rhashtable *ht, const void *key,
+	const struct rhashtable_params params,
+	rht_obj_cmpfn_t obj_cmpfn)
+{
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = key,
+	};
+	const struct bucket_table *tbl;
+	struct rhash_head *he, *result = NULL;
+	unsigned int hash;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+restart:
+	hash = rht_key_hashfn(ht, tbl, key, params);
+	rht_for_each_rcu(he, tbl, hash) {
+		if (obj_cmpfn ?
+		    obj_cmpfn(&arg, rht_obj(ht, he)) :
+		    rhashtable_compare(&arg, rht_obj(ht, he)))
+			continue;
+		if (unlikely(result)) {
+			if (params.obj_orderfn(he) > params.obj_orderfn(result))
+				result = he;
+		} else {
+			result = he;
+		}
+		break;
+	}
+
+	/* Ensure we see any new tables. */
+	smp_rmb();
+
+	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (unlikely(tbl))
+		goto restart;
+	rcu_read_unlock();
+
+	return result ? rht_obj(ht, result) : NULL;
+}
+
+static inline void *rhashtable_lookup_ordered(
+	struct rhashtable *ht, const void *key,
+	const struct rhashtable_params params)
+{
+	return rhashtable_lookup_ordered_cmpfn(ht, key, params,
+					      params.obj_cmpfn);
+}
+
+struct rht_insert_pos {
+	struct rhash_head __rcu *head;
+	struct rhash_head __rcu **pos;
+};
+
+static inline void rht_insert_pos(struct rhashtable *ht,
+				  struct rhash_head *obj,
+				  struct bucket_table *tbl,
+				  unsigned int hash,
+				  struct rht_insert_pos *ipos)
+{
+	struct rhash_head __rcu *head, **pos;
+
+	pos = &tbl->buckets[hash];
+
+	if (ht->p.obj_orderfn) {
+		int obj_order = ht->p.obj_orderfn(rht_obj(ht, obj));
+
+		rht_for_each_rcu(head, tbl, hash) {
+			if (ht->p.obj_orderfn(rht_obj(ht, head)) <= obj_order)
+				break;
+			pos = &head->next;
+		}
+	} else {
+		head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+	}
+
+	ipos->head = head;
+	ipos->pos = pos;
+}
+
 /* Internal function, please use rhashtable_insert_fast() instead */
 static inline int __rhashtable_insert_fast(
 	struct rhashtable *ht, const void *key, struct rhash_head *obj,
@@ -581,6 +682,7 @@ static inline int __rhashtable_insert_fast(
 	};
 	struct bucket_table *tbl, *new_tbl;
 	struct rhash_head *head;
+	struct rht_insert_pos ipos;
 	spinlock_t *lock;
 	unsigned int elasticity;
 	unsigned int hash;
@@ -643,11 +745,11 @@ slow_path:
 
 	err = 0;
 
-	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+	rht_insert_pos(ht, obj, tbl, hash, &ipos);
 
-	RCU_INIT_POINTER(obj->next, head);
+	RCU_INIT_POINTER(obj->next, ipos.head);
 
-	rcu_assign_pointer(tbl->buckets[hash], obj);
+	rcu_assign_pointer(*ipos.pos, obj);
 
 	atomic_inc(&ht->nelems);
 	if (rht_grow_above_75(ht, tbl))
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index cc0c697..0e09524 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -162,9 +162,10 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
 		rht_dereference_rcu(old_tbl->future_tbl, ht));
 	struct rhash_head __rcu **pprev = &old_tbl->buckets[old_hash];
 	int err = -ENOENT;
-	struct rhash_head *head, *next, *entry;
+	struct rhash_head *next, *entry;
 	spinlock_t *new_bucket_lock;
 	unsigned int new_hash;
+	struct rht_insert_pos ipos;
 
 	rht_for_each(entry, old_tbl, old_hash) {
 		err = 0;
@@ -184,15 +185,14 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
 	new_bucket_lock = rht_bucket_lock(new_tbl, new_hash);
 
 	spin_lock_nested(new_bucket_lock, SINGLE_DEPTH_NESTING);
-	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
-				      new_tbl, new_hash);
+	rht_insert_pos(ht, entry, new_tbl, new_hash, &ipos);
 
-	if (rht_is_a_nulls(head))
+	if (rht_is_a_nulls(ipos.head))
 		INIT_RHT_NULLS_HEAD(entry->next, ht, new_hash);
 	else
-		RCU_INIT_POINTER(entry->next, head);
+		RCU_INIT_POINTER(entry->next, ipos.head);
 
-	rcu_assign_pointer(new_tbl->buckets[new_hash], entry);
+	rcu_assign_pointer(*ipos.pos, entry);
 	spin_unlock(new_bucket_lock);
 
 	rcu_assign_pointer(*pprev, next);
@@ -436,7 +436,7 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 			   struct rhash_head *obj,
 			   struct bucket_table *tbl)
 {
-	struct rhash_head *head;
+	struct rht_insert_pos ipos;
 	unsigned int hash;
 	int err;
 
@@ -459,11 +459,11 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 
 	err = 0;
 
-	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+	rht_insert_pos(ht, obj, tbl, hash, &ipos);
 
-	RCU_INIT_POINTER(obj->next, head);
+	RCU_INIT_POINTER(obj->next, ipos.head);
 
-	rcu_assign_pointer(tbl->buckets[hash], obj);
+	rcu_assign_pointer(*ipos.pos, obj);
 
 	atomic_inc(&ht->nelems);
 
-- 
1.8.1
