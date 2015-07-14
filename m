From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/3] rhashtable: Add a function for in order insertion in buckets
Date: Mon, 13 Jul 2015 17:39:11 -0700
Message-ID: <1436834353-1851565-2-git-send-email-tom@herbertland.com>
References: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:26693 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751931AbbGNAj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 20:39:29 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6E0cljg018088
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vmppx0aa9-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:28 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 c74b648a29c011e599e90002c991e86a-284d82b0 for <netdev@vger.kernel.org>;	Mon,
 13 Jul 2015 17:39:26 -0700
In-Reply-To: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The obj_orderfn function may be specified in the parameters for a
rhashtable. When inserting an element this function is used to order
objects in a bucket list (greatest to least ordering value).This
allows entries to have wild card fields, where entries with
more specific information match are placed first in the bucket.
When a lookup is done, the first match found will contain
the most specific match.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 41 ++++++++++++++++++++++++++++++++++++++---
 lib/rhashtable.c           | 20 ++++++++++----------
 2 files changed, 48 insertions(+), 13 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 843ceca..8e27159 100644
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
@@ -560,6 +563,37 @@ restart:
 	return NULL;
 }
 
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
@@ -571,6 +605,7 @@ static inline int __rhashtable_insert_fast(
 	};
 	struct bucket_table *tbl, *new_tbl;
 	struct rhash_head *head;
+	struct rht_insert_pos ipos;
 	spinlock_t *lock;
 	unsigned int elasticity;
 	unsigned int hash;
@@ -633,11 +668,11 @@ slow_path:
 
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
index a60a6d3..0de37e0 100644
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
