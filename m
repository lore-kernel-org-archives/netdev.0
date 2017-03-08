From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 2/2] bpf: convert htab map to hlist_nulls
Date: Tue, 7 Mar 2017 20:00:13 -0800
Message-ID: <1488945613-1857856-3-git-send-email-ast@fb.com>
References: <1488945613-1857856-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41655 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756713AbdCHEAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 23:00:17 -0500
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v283wJcp013569
        for <netdev@vger.kernel.org>; Tue, 7 Mar 2017 20:00:15 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2925uwrtn1-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 20:00:15 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 bbbe6e3603b311e7b7330002c9dfb610-94cc79a0 for <netdev@vger.kernel.org>;        Tue,
 07 Mar 2017 20:00:14 -0800
In-Reply-To: <1488945613-1857856-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when all map elements are pre-allocated one cpu can delete and reuse htab_elem
while another cpu is still walking the hlist. In such case the lookup may
miss the element. Convert hlist to hlist_nulls to avoid such scenario.
When bucket lock is taken there is no need to take such precautions,
so only convert map_lookup and map_get_next to nulls.
The race window is extremely small and only reproducible with explicit
udelay() inside lookup_nulls_elem_raw()

Similar to hlist add hlist_nulls_for_each_entry_safe() and
hlist_nulls_entry_safe() helpers.

Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
Reported-by: Jonathan Perry <jonperry@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/list_nulls.h    |  5 +++
 include/linux/rculist_nulls.h | 14 +++++++
 kernel/bpf/hashtab.c          | 94 +++++++++++++++++++++++++++----------------
 3 files changed, 79 insertions(+), 34 deletions(-)

diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
index b01fe1009084..87ff4f58a2f0 100644
--- a/include/linux/list_nulls.h
+++ b/include/linux/list_nulls.h
@@ -29,6 +29,11 @@ struct hlist_nulls_node {
 	((ptr)->first = (struct hlist_nulls_node *) NULLS_MARKER(nulls))
 
 #define hlist_nulls_entry(ptr, type, member) container_of(ptr,type,member)
+
+#define hlist_nulls_entry_safe(ptr, type, member) \
+	({ typeof(ptr) ____ptr = (ptr); \
+	   !is_a_nulls(____ptr) ? hlist_nulls_entry(____ptr, type, member) : NULL; \
+	})
 /**
  * ptr_is_a_nulls - Test if a ptr is a nulls
  * @ptr: ptr to be tested
diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
index 4ae95f7e8597..a23a33153180 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -156,5 +156,19 @@ static inline void hlist_nulls_add_tail_rcu(struct hlist_nulls_node *n,
 		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
 		pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))
 
+/**
+ * hlist_nulls_for_each_entry_safe -
+ *   iterate over list of given type safe against removal of list entry
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_nulls_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_nulls_node within the struct.
+ */
+#define hlist_nulls_for_each_entry_safe(tpos, pos, head, member)		\
+	for (({barrier();}),							\
+	     pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));		\
+		(!is_a_nulls(pos)) &&						\
+		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member);	\
+		   pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)); 1; });)
 #endif
 #endif
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 63c86a7be2a1..afe5bab376c9 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -13,11 +13,12 @@
 #include <linux/bpf.h>
 #include <linux/jhash.h>
 #include <linux/filter.h>
+#include <linux/rculist_nulls.h>
 #include "percpu_freelist.h"
 #include "bpf_lru_list.h"
 
 struct bucket {
-	struct hlist_head head;
+	struct hlist_nulls_head head;
 	raw_spinlock_t lock;
 };
 
@@ -44,7 +45,7 @@ enum extra_elem_state {
 /* each htab element is struct htab_elem + key + value */
 struct htab_elem {
 	union {
-		struct hlist_node hash_node;
+		struct hlist_nulls_node hash_node;
 		struct {
 			void *padding;
 			union {
@@ -337,7 +338,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		goto free_htab;
 
 	for (i = 0; i < htab->n_buckets; i++) {
-		INIT_HLIST_HEAD(&htab->buckets[i].head);
+		INIT_HLIST_NULLS_HEAD(&htab->buckets[i].head, i);
 		raw_spin_lock_init(&htab->buckets[i].lock);
 	}
 
@@ -377,28 +378,52 @@ static inline struct bucket *__select_bucket(struct bpf_htab *htab, u32 hash)
 	return &htab->buckets[hash & (htab->n_buckets - 1)];
 }
 
-static inline struct hlist_head *select_bucket(struct bpf_htab *htab, u32 hash)
+static inline struct hlist_nulls_head *select_bucket(struct bpf_htab *htab, u32 hash)
 {
 	return &__select_bucket(htab, hash)->head;
 }
 
-static struct htab_elem *lookup_elem_raw(struct hlist_head *head, u32 hash,
+/* this lookup function can only be called with bucket lock taken */
+static struct htab_elem *lookup_elem_raw(struct hlist_nulls_head *head, u32 hash,
 					 void *key, u32 key_size)
 {
+	struct hlist_nulls_node *n;
 	struct htab_elem *l;
 
-	hlist_for_each_entry_rcu(l, head, hash_node)
+	hlist_nulls_for_each_entry_rcu(l, n, head, hash_node)
 		if (l->hash == hash && !memcmp(&l->key, key, key_size))
 			return l;
 
 	return NULL;
 }
 
+/* can be called without bucket lock. it will repeat the loop in
+ * the unlikely event when elements moved from one bucket into another
+ * while link list is being walked
+ */
+static struct htab_elem *lookup_nulls_elem_raw(struct hlist_nulls_head *head,
+					       u32 hash, void *key,
+					       u32 key_size, u32 n_buckets)
+{
+	struct hlist_nulls_node *n;
+	struct htab_elem *l;
+
+again:
+	hlist_nulls_for_each_entry_rcu(l, n, head, hash_node)
+		if (l->hash == hash && !memcmp(&l->key, key, key_size))
+			return l;
+
+	if (unlikely(get_nulls_value(n) != (hash & (n_buckets - 1))))
+		goto again;
+
+	return NULL;
+}
+
 /* Called from syscall or from eBPF program */
 static void *__htab_map_lookup_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	struct htab_elem *l;
 	u32 hash, key_size;
 
@@ -411,7 +436,7 @@ static void *__htab_map_lookup_elem(struct bpf_map *map, void *key)
 
 	head = select_bucket(htab, hash);
 
-	l = lookup_elem_raw(head, hash, key, key_size);
+	l = lookup_nulls_elem_raw(head, hash, key, key_size, htab->n_buckets);
 
 	return l;
 }
@@ -444,8 +469,9 @@ static void *htab_lru_map_lookup_elem(struct bpf_map *map, void *key)
 static bool htab_lru_map_delete_node(void *arg, struct bpf_lru_node *node)
 {
 	struct bpf_htab *htab = (struct bpf_htab *)arg;
-	struct htab_elem *l, *tgt_l;
-	struct hlist_head *head;
+	struct htab_elem *l = NULL, *tgt_l;
+	struct hlist_nulls_head *head;
+	struct hlist_nulls_node *n;
 	unsigned long flags;
 	struct bucket *b;
 
@@ -455,9 +481,9 @@ static bool htab_lru_map_delete_node(void *arg, struct bpf_lru_node *node)
 
 	raw_spin_lock_irqsave(&b->lock, flags);
 
-	hlist_for_each_entry_rcu(l, head, hash_node)
+	hlist_nulls_for_each_entry_rcu(l, n, head, hash_node)
 		if (l == tgt_l) {
-			hlist_del_rcu(&l->hash_node);
+			hlist_nulls_del_rcu(&l->hash_node);
 			break;
 		}
 
@@ -470,7 +496,7 @@ static bool htab_lru_map_delete_node(void *arg, struct bpf_lru_node *node)
 static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	struct htab_elem *l, *next_l;
 	u32 hash, key_size;
 	int i;
@@ -484,7 +510,7 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	head = select_bucket(htab, hash);
 
 	/* lookup the key */
-	l = lookup_elem_raw(head, hash, key, key_size);
+	l = lookup_nulls_elem_raw(head, hash, key, key_size, htab->n_buckets);
 
 	if (!l) {
 		i = 0;
@@ -492,7 +518,7 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	}
 
 	/* key was found, get next key in the same bucket */
-	next_l = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu(&l->hash_node)),
+	next_l = hlist_nulls_entry_safe(rcu_dereference_raw(hlist_nulls_next_rcu(&l->hash_node)),
 				  struct htab_elem, hash_node);
 
 	if (next_l) {
@@ -511,7 +537,7 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 		head = select_bucket(htab, i);
 
 		/* pick first element in the bucket */
-		next_l = hlist_entry_safe(rcu_dereference_raw(hlist_first_rcu(head)),
+		next_l = hlist_nulls_entry_safe(rcu_dereference_raw(hlist_nulls_first_rcu(head)),
 					  struct htab_elem, hash_node);
 		if (next_l) {
 			/* if it's not empty, just return it */
@@ -676,7 +702,7 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct htab_elem *l_new = NULL, *l_old;
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	unsigned long flags;
 	struct bucket *b;
 	u32 key_size, hash;
@@ -715,9 +741,9 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	/* add new element to the head of the list, so that
 	 * concurrent search will find it before old elem
 	 */
-	hlist_add_head_rcu(&l_new->hash_node, head);
+	hlist_nulls_add_head_rcu(&l_new->hash_node, head);
 	if (l_old) {
-		hlist_del_rcu(&l_old->hash_node);
+		hlist_nulls_del_rcu(&l_old->hash_node);
 		free_htab_elem(htab, l_old);
 	}
 	ret = 0;
@@ -731,7 +757,7 @@ static int htab_lru_map_update_elem(struct bpf_map *map, void *key, void *value,
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct htab_elem *l_new, *l_old = NULL;
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	unsigned long flags;
 	struct bucket *b;
 	u32 key_size, hash;
@@ -772,10 +798,10 @@ static int htab_lru_map_update_elem(struct bpf_map *map, void *key, void *value,
 	/* add new element to the head of the list, so that
 	 * concurrent search will find it before old elem
 	 */
-	hlist_add_head_rcu(&l_new->hash_node, head);
+	hlist_nulls_add_head_rcu(&l_new->hash_node, head);
 	if (l_old) {
 		bpf_lru_node_set_ref(&l_new->lru_node);
-		hlist_del_rcu(&l_old->hash_node);
+		hlist_nulls_del_rcu(&l_old->hash_node);
 	}
 	ret = 0;
 
@@ -796,7 +822,7 @@ static int __htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct htab_elem *l_new = NULL, *l_old;
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	unsigned long flags;
 	struct bucket *b;
 	u32 key_size, hash;
@@ -835,7 +861,7 @@ static int __htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 			ret = PTR_ERR(l_new);
 			goto err;
 		}
-		hlist_add_head_rcu(&l_new->hash_node, head);
+		hlist_nulls_add_head_rcu(&l_new->hash_node, head);
 	}
 	ret = 0;
 err:
@@ -849,7 +875,7 @@ static int __htab_lru_percpu_map_update_elem(struct bpf_map *map, void *key,
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct htab_elem *l_new = NULL, *l_old;
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	unsigned long flags;
 	struct bucket *b;
 	u32 key_size, hash;
@@ -897,7 +923,7 @@ static int __htab_lru_percpu_map_update_elem(struct bpf_map *map, void *key,
 	} else {
 		pcpu_copy_value(htab, htab_elem_get_ptr(l_new, key_size),
 				value, onallcpus);
-		hlist_add_head_rcu(&l_new->hash_node, head);
+		hlist_nulls_add_head_rcu(&l_new->hash_node, head);
 		l_new = NULL;
 	}
 	ret = 0;
@@ -925,7 +951,7 @@ static int htab_lru_percpu_map_update_elem(struct bpf_map *map, void *key,
 static int htab_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	struct bucket *b;
 	struct htab_elem *l;
 	unsigned long flags;
@@ -945,7 +971,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	l = lookup_elem_raw(head, hash, key, key_size);
 
 	if (l) {
-		hlist_del_rcu(&l->hash_node);
+		hlist_nulls_del_rcu(&l->hash_node);
 		free_htab_elem(htab, l);
 		ret = 0;
 	}
@@ -957,7 +983,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 static int htab_lru_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
-	struct hlist_head *head;
+	struct hlist_nulls_head *head;
 	struct bucket *b;
 	struct htab_elem *l;
 	unsigned long flags;
@@ -977,7 +1003,7 @@ static int htab_lru_map_delete_elem(struct bpf_map *map, void *key)
 	l = lookup_elem_raw(head, hash, key, key_size);
 
 	if (l) {
-		hlist_del_rcu(&l->hash_node);
+		hlist_nulls_del_rcu(&l->hash_node);
 		ret = 0;
 	}
 
@@ -992,12 +1018,12 @@ static void delete_all_elements(struct bpf_htab *htab)
 	int i;
 
 	for (i = 0; i < htab->n_buckets; i++) {
-		struct hlist_head *head = select_bucket(htab, i);
-		struct hlist_node *n;
+		struct hlist_nulls_head *head = select_bucket(htab, i);
+		struct hlist_nulls_node *n;
 		struct htab_elem *l;
 
-		hlist_for_each_entry_safe(l, n, head, hash_node) {
-			hlist_del_rcu(&l->hash_node);
+		hlist_nulls_for_each_entry_safe(l, n, head, hash_node) {
+			hlist_nulls_del_rcu(&l->hash_node);
 			if (l->state != HTAB_EXTRA_ELEM_USED)
 				htab_elem_free(htab, l);
 		}
-- 
2.8.0
