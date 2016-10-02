From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 3/5] bpf: ADD BPF_MAP_TYPE_LRU_HASH
Date: Sat, 1 Oct 2016 20:58:31 -0700
Message-ID: <1475380713-4106095-3-git-send-email-kafai@fb.com>
References: <1475380713-4106095-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: FB Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36124 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751628AbcJBD6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 23:58:38 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u923vW3t008894
        for <netdev@vger.kernel.org>; Sat, 1 Oct 2016 20:58:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 25t8tb3ep3-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 20:58:37 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 7d731aa8885411e6832a0002c95209d8-ed83b6d0 for <netdev@vger.kernel.org>;        Sat,
 01 Oct 2016 20:58:34 -0700
In-Reply-To: <1475380713-4106095-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a LRU version of the existing BPF_MAP_TYPE_HASH.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/uapi/linux/bpf.h |   1 +
 kernel/bpf/hashtab.c     | 234 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 222 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f896dfa..c153ff8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -85,6 +85,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_PERCPU_ARRAY,
 	BPF_MAP_TYPE_STACK_TRACE,
 	BPF_MAP_TYPE_CGROUP_ARRAY,
+	BPF_MAP_TYPE_LRU_HASH,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index a5e3915..1493d98 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -15,6 +15,7 @@
 #include <linux/filter.h>
 #include <linux/vmalloc.h>
 #include "percpu_freelist.h"
+#include "bpf_lru_list.h"
 
 struct bucket {
 	struct hlist_head head;
@@ -25,7 +26,10 @@ struct bpf_htab {
 	struct bpf_map map;
 	struct bucket *buckets;
 	void *elems;
-	struct pcpu_freelist freelist;
+	union {
+		struct pcpu_freelist freelist;
+		struct bpf_lru lru;
+	};
 	void __percpu *extra_elems;
 	atomic_t count;	/* number of elements in this hashtable */
 	u32 n_buckets;	/* number of hash buckets */
@@ -48,11 +52,19 @@ struct htab_elem {
 	union {
 		struct rcu_head rcu;
 		enum extra_elem_state state;
+		struct bpf_lru_node lru_node;
 	};
 	u32 hash;
 	char key[0] __aligned(8);
 };
 
+static bool htab_lru_map_delete_node(void *arg, struct bpf_lru_node *node);
+
+static bool htab_is_lru(const struct bpf_htab *htab)
+{
+	return htab->map.map_type == BPF_MAP_TYPE_LRU_HASH;
+}
+
 static inline void htab_elem_set_ptr(struct htab_elem *l, u32 key_size,
 				     void __percpu *pptr)
 {
@@ -87,7 +99,22 @@ free_elems:
 	vfree(htab->elems);
 }
 
-static int prealloc_elems_and_freelist(struct bpf_htab *htab)
+static struct htab_elem *prealloc_lru_pop(struct bpf_htab *htab, void *key,
+					  u32 hash)
+{
+	struct bpf_lru_node *node = bpf_lru_pop_free(&htab->lru, hash);
+	struct htab_elem *l;
+
+	if (node) {
+		l = container_of(node, struct htab_elem, lru_node);
+		memcpy(l->key, key, htab->map.key_size);
+		return l;
+	}
+
+	return NULL;
+}
+
+static int prealloc_init(struct bpf_htab *htab)
 {
 	int err = -ENOMEM, i;
 
@@ -110,12 +137,26 @@ static int prealloc_elems_and_freelist(struct bpf_htab *htab)
 	}
 
 skip_percpu_elems:
-	err = pcpu_freelist_init(&htab->freelist);
+	if (htab_is_lru(htab))
+		err = bpf_lru_init(&htab->lru,
+				   offsetof(struct htab_elem, hash) -
+				   offsetof(struct htab_elem, lru_node),
+				   htab_lru_map_delete_node,
+				   htab);
+	else
+		err = pcpu_freelist_init(&htab->freelist);
+
 	if (err)
 		goto free_elems;
 
-	pcpu_freelist_populate(&htab->freelist, htab->elems, htab->elem_size,
-			       htab->map.max_entries);
+	if (htab_is_lru(htab))
+		bpf_lru_populate(&htab->lru, htab->elems,
+				 offsetof(struct htab_elem, lru_node),
+				 htab->elem_size, htab->map.max_entries);
+	else
+		pcpu_freelist_populate(&htab->freelist, htab->elems,
+				       htab->elem_size, htab->map.max_entries);
+
 	return 0;
 
 free_elems:
@@ -123,6 +164,16 @@ free_elems:
 	return err;
 }
 
+static void prealloc_destroy(struct bpf_htab *htab)
+{
+	htab_free_elems(htab);
+
+	if (htab_is_lru(htab))
+		bpf_lru_destroy(&htab->lru);
+	else
+		pcpu_freelist_destroy(&htab->freelist);
+}
+
 static int alloc_extra_elems(struct bpf_htab *htab)
 {
 	void __percpu *pptr;
@@ -144,6 +195,8 @@ static int alloc_extra_elems(struct bpf_htab *htab)
 static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 {
 	bool percpu = attr->map_type == BPF_MAP_TYPE_PERCPU_HASH;
+	bool lru = attr->map_type == BPF_MAP_TYPE_LRU_HASH;
+	bool prealloc = !(attr->map_flags & BPF_F_NO_PREALLOC);
 	struct bpf_htab *htab;
 	int err, i;
 	u64 cost;
@@ -152,6 +205,9 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		/* reserved bits should not be used */
 		return ERR_PTR(-EINVAL);
 
+	if (lru && !prealloc)
+		return ERR_PTR(-ENOTSUPP);
+
 	htab = kzalloc(sizeof(*htab), GFP_USER);
 	if (!htab)
 		return ERR_PTR(-ENOMEM);
@@ -241,14 +297,14 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		raw_spin_lock_init(&htab->buckets[i].lock);
 	}
 
-	if (!percpu) {
+	if (!percpu && !lru) {
 		err = alloc_extra_elems(htab);
 		if (err)
 			goto free_buckets;
 	}
 
-	if (!(attr->map_flags & BPF_F_NO_PREALLOC)) {
-		err = prealloc_elems_and_freelist(htab);
+	if (prealloc) {
+		err = prealloc_init(htab);
 		if (err)
 			goto free_extra_elems;
 	}
@@ -323,6 +379,47 @@ static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
 	return NULL;
 }
 
+static void *htab_lru_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct htab_elem *l = __htab_map_lookup_elem(map, key);
+
+	if (l) {
+		bpf_lru_node_set_ref(&l->lru_node);
+		return l->key + round_up(map->key_size, 8);
+	}
+
+	return NULL;
+}
+
+/* It is called from the bpf_lru_list when the LRU needs to delete
+ * older elements from the htab.
+ */
+static bool htab_lru_map_delete_node(void *arg, struct bpf_lru_node *node)
+{
+	struct bpf_htab *htab = (struct bpf_htab *)arg;
+	struct htab_elem *l, *tgt_l;
+	struct hlist_head *head;
+	unsigned long flags;
+	struct bucket *b;
+
+	tgt_l = container_of(node, struct htab_elem, lru_node);
+	b = __select_bucket(htab, tgt_l->hash);
+	head = &b->head;
+
+	raw_spin_lock_irqsave(&b->lock, flags);
+
+	hlist_for_each_entry_rcu(l, head, hash_node)
+		if (l == tgt_l) {
+			hlist_del_rcu(&l->hash_node);
+			break;
+		}
+
+
+	raw_spin_unlock_irqrestore(&b->lock, flags);
+
+	return l == tgt_l;
+}
+
 /* Called from syscall */
 static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 {
@@ -579,6 +676,70 @@ err:
 	return ret;
 }
 
+static int htab_lru_map_update_elem(struct bpf_map *map, void *key, void *value,
+				    u64 map_flags)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct htab_elem *l_new, *l_old = NULL;
+	struct hlist_head *head;
+	unsigned long flags;
+	struct bucket *b;
+	u32 key_size, hash;
+	int ret;
+
+	if (unlikely(map_flags > BPF_EXIST))
+		/* unknown flags */
+		return -EINVAL;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	key_size = map->key_size;
+
+	hash = htab_map_hash(key, key_size);
+
+	b = __select_bucket(htab, hash);
+	head = &b->head;
+
+	/* For LRU, we need to alloc before taking bucket's
+	 * spinlock because getting free nodes from LRU may need
+	 * to remove older elements from htab and this removal
+	 * operation will need a bucket lock.
+	 */
+	l_new = prealloc_lru_pop(htab, key, hash);
+	if (!l_new)
+		return -ENOMEM;
+	memcpy(l_new->key + round_up(map->key_size, 8), value, map->value_size);
+
+	/* bpf_map_update_elem() can be called in_irq() */
+	raw_spin_lock_irqsave(&b->lock, flags);
+
+	l_old = lookup_elem_raw(head, hash, key, key_size);
+
+	ret = check_flags(htab, l_old, map_flags);
+	if (ret)
+		goto err;
+
+	/* add new element to the head of the list, so that
+	 * concurrent search will find it before old elem
+	 */
+	hlist_add_head_rcu(&l_new->hash_node, head);
+	if (l_old) {
+		bpf_lru_node_set_ref(&l_new->lru_node);
+		hlist_del_rcu(&l_old->hash_node);
+	}
+	ret = 0;
+
+err:
+	raw_spin_unlock_irqrestore(&b->lock, flags);
+
+	if (ret)
+		bpf_lru_push_free(&htab->lru, &l_new->lru_node);
+	else if (l_old)
+		bpf_lru_push_free(&htab->lru, &l_old->lru_node);
+
+	return ret;
+}
+
 static int __htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 					 void *value, u64 map_flags,
 					 bool onallcpus)
@@ -671,6 +832,39 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	return ret;
 }
 
+static int htab_lru_map_delete_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct hlist_head *head;
+	struct bucket *b;
+	struct htab_elem *l;
+	unsigned long flags;
+	u32 hash, key_size;
+	int ret = -ENOENT;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	key_size = map->key_size;
+
+	hash = htab_map_hash(key, key_size);
+	b = __select_bucket(htab, hash);
+	head = &b->head;
+
+	raw_spin_lock_irqsave(&b->lock, flags);
+
+	l = lookup_elem_raw(head, hash, key, key_size);
+
+	if (l) {
+		hlist_del_rcu(&l->hash_node);
+		ret = 0;
+	}
+
+	raw_spin_unlock_irqrestore(&b->lock, flags);
+	if (l)
+		bpf_lru_push_free(&htab->lru, &l->lru_node);
+	return ret;
+}
+
 static void delete_all_elements(struct bpf_htab *htab)
 {
 	int i;
@@ -702,12 +896,11 @@ static void htab_map_free(struct bpf_map *map)
 	 * not have executed. Wait for them.
 	 */
 	rcu_barrier();
-	if (htab->map.map_flags & BPF_F_NO_PREALLOC) {
+	if (htab->map.map_flags & BPF_F_NO_PREALLOC)
 		delete_all_elements(htab);
-	} else {
-		htab_free_elems(htab);
-		pcpu_freelist_destroy(&htab->freelist);
-	}
+	else
+		prealloc_destroy(htab);
+
 	free_percpu(htab->extra_elems);
 	kvfree(htab->buckets);
 	kfree(htab);
@@ -727,6 +920,20 @@ static struct bpf_map_type_list htab_type __read_mostly = {
 	.type = BPF_MAP_TYPE_HASH,
 };
 
+static const struct bpf_map_ops htab_lru_ops = {
+	.map_alloc = htab_map_alloc,
+	.map_free = htab_map_free,
+	.map_get_next_key = htab_map_get_next_key,
+	.map_lookup_elem = htab_lru_map_lookup_elem,
+	.map_update_elem = htab_lru_map_update_elem,
+	.map_delete_elem = htab_lru_map_delete_elem,
+};
+
+static struct bpf_map_type_list htab_lru_type __read_mostly = {
+	.ops = &htab_lru_ops,
+	.type = BPF_MAP_TYPE_LRU_HASH,
+};
+
 /* Called from eBPF program */
 static void *htab_percpu_map_lookup_elem(struct bpf_map *map, void *key)
 {
@@ -797,6 +1004,7 @@ static int __init register_htab_map(void)
 {
 	bpf_register_map_type(&htab_type);
 	bpf_register_map_type(&htab_percpu_type);
+	bpf_register_map_type(&htab_lru_type);
 	return 0;
 }
 late_initcall(register_htab_map);
-- 
2.5.1
