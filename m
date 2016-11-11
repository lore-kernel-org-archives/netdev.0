From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 5/6] bpf: Add BPF_MAP_TYPE_LRU_PERCPU_HASH
Date: Fri, 11 Nov 2016 10:55:10 -0800
Message-ID: <1478890511-1346984-6-git-send-email-kafai@fb.com>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40840 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934703AbcKKSzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 13:55:25 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uABIptlx031898
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:55:25 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 26nk23geka-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:55:25 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 6678503ca84011e6bd1e24be0593f280-275faa50 for <netdev@vger.kernel.org>;        Fri,
 11 Nov 2016 10:55:23 -0800
In-Reply-To: <1478890511-1346984-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a LRU version of the existing BPF_MAP_TYPE_PERCPU_HASH

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/uapi/linux/bpf.h |   3 +-
 kernel/bpf/hashtab.c     | 129 ++++++++++++++++++++++++++++++++++++++++++++---
 kernel/bpf/syscall.c     |   8 ++-
 3 files changed, 131 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ed8c679..7d9b283 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -86,6 +86,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_STACK_TRACE,
 	BPF_MAP_TYPE_CGROUP_ARRAY,
 	BPF_MAP_TYPE_LRU_HASH,
+	BPF_MAP_TYPE_LRU_PERCPU_HASH,
 };
 
 enum bpf_prog_type {
@@ -108,7 +109,7 @@ enum bpf_prog_type {
 
 #define BPF_F_NO_PREALLOC	(1U << 0)
 /* Instead of having one common LRU list in the
- * BPF_MAP_TYPE_LRU_HASH map, use a percpu LRU list
+ * BPF_MAP_TYPE_LRU_[PERCPU_]HASH map, use a percpu LRU list
  * which can scale and perform better.
  * Note, the LRU nodes (including free nodes) cannot be moved
  * across different LRU lists.
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 60e9e85..60e76fc 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -62,7 +62,14 @@ static bool htab_lru_map_delete_node(void *arg, struct bpf_lru_node *node);
 
 static bool htab_is_lru(const struct bpf_htab *htab)
 {
-	return htab->map.map_type == BPF_MAP_TYPE_LRU_HASH;
+	return htab->map.map_type == BPF_MAP_TYPE_LRU_HASH ||
+		htab->map.map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH;
+}
+
+static bool htab_is_percpu(const struct bpf_htab *htab)
+{
+	return htab->map.map_type == BPF_MAP_TYPE_PERCPU_HASH ||
+		htab->map.map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH;
 }
 
 static inline void htab_elem_set_ptr(struct htab_elem *l, u32 key_size,
@@ -85,7 +92,7 @@ static void htab_free_elems(struct bpf_htab *htab)
 {
 	int i;
 
-	if (htab->map.map_type != BPF_MAP_TYPE_PERCPU_HASH)
+	if (!htab_is_percpu(htab))
 		goto free_elems;
 
 	for (i = 0; i < htab->map.max_entries; i++) {
@@ -122,7 +129,7 @@ static int prealloc_init(struct bpf_htab *htab)
 	if (!htab->elems)
 		return -ENOMEM;
 
-	if (htab->map.map_type != BPF_MAP_TYPE_PERCPU_HASH)
+	if (!htab_is_percpu(htab))
 		goto skip_percpu_elems;
 
 	for (i = 0; i < htab->map.max_entries; i++) {
@@ -195,8 +202,10 @@ static int alloc_extra_elems(struct bpf_htab *htab)
 /* Called from syscall */
 static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 {
-	bool percpu = attr->map_type == BPF_MAP_TYPE_PERCPU_HASH;
-	bool lru = attr->map_type == BPF_MAP_TYPE_LRU_HASH;
+	bool percpu = (attr->map_type == BPF_MAP_TYPE_PERCPU_HASH ||
+		       attr->map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH);
+	bool lru = (attr->map_type == BPF_MAP_TYPE_LRU_HASH ||
+		    attr->map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH);
 	/* percpu_lru means each cpu has its own LRU list.
 	 * it is different from BPF_MAP_TYPE_PERCPU_HASH where
 	 * the map's value itself is percpu.  percpu_lru has
@@ -823,12 +832,84 @@ static int __htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 	return ret;
 }
 
+static int __htab_lru_percpu_map_update_elem(struct bpf_map *map, void *key,
+					     void *value, u64 map_flags,
+					     bool onallcpus)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct htab_elem *l_new = NULL, *l_old;
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
+	 * spinlock because LRU's elem alloc may need
+	 * to remove older elem from htab and this removal
+	 * operation will need a bucket lock.
+	 */
+	if (map_flags != BPF_EXIST) {
+		l_new = prealloc_lru_pop(htab, key, hash);
+		if (!l_new)
+			return -ENOMEM;
+	}
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
+	if (l_old) {
+		bpf_lru_node_set_ref(&l_old->lru_node);
+
+		/* per-cpu hash map can update value in-place */
+		pcpu_copy_value(htab, htab_elem_get_ptr(l_old, key_size),
+				value, onallcpus);
+	} else {
+		pcpu_copy_value(htab, htab_elem_get_ptr(l_new, key_size),
+				value, onallcpus);
+		hlist_add_head_rcu(&l_new->hash_node, head);
+		l_new = NULL;
+	}
+	ret = 0;
+err:
+	raw_spin_unlock_irqrestore(&b->lock, flags);
+	if (l_new)
+		bpf_lru_push_free(&htab->lru, &l_new->lru_node);
+	return ret;
+}
+
 static int htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 				       void *value, u64 map_flags)
 {
 	return __htab_percpu_map_update_elem(map, key, value, map_flags, false);
 }
 
+static int htab_lru_percpu_map_update_elem(struct bpf_map *map, void *key,
+					   void *value, u64 map_flags)
+{
+	return __htab_lru_percpu_map_update_elem(map, key, value, map_flags,
+						 false);
+}
+
 /* Called from syscall or from eBPF program */
 static int htab_map_delete_elem(struct bpf_map *map, void *key)
 {
@@ -975,8 +1056,21 @@ static void *htab_percpu_map_lookup_elem(struct bpf_map *map, void *key)
 		return NULL;
 }
 
+static void *htab_lru_percpu_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct htab_elem *l = __htab_map_lookup_elem(map, key);
+
+	if (l) {
+		bpf_lru_node_set_ref(&l->lru_node);
+		return this_cpu_ptr(htab_elem_get_ptr(l, map->key_size));
+	}
+
+	return NULL;
+}
+
 int bpf_percpu_hash_copy(struct bpf_map *map, void *key, void *value)
 {
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct htab_elem *l;
 	void __percpu *pptr;
 	int ret = -ENOENT;
@@ -992,6 +1086,8 @@ int bpf_percpu_hash_copy(struct bpf_map *map, void *key, void *value)
 	l = __htab_map_lookup_elem(map, key);
 	if (!l)
 		goto out;
+	if (htab_is_lru(htab))
+		bpf_lru_node_set_ref(&l->lru_node);
 	pptr = htab_elem_get_ptr(l, map->key_size);
 	for_each_possible_cpu(cpu) {
 		bpf_long_memcpy(value + off,
@@ -1007,10 +1103,16 @@ int bpf_percpu_hash_copy(struct bpf_map *map, void *key, void *value)
 int bpf_percpu_hash_update(struct bpf_map *map, void *key, void *value,
 			   u64 map_flags)
 {
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	int ret;
 
 	rcu_read_lock();
-	ret = __htab_percpu_map_update_elem(map, key, value, map_flags, true);
+	if (htab_is_lru(htab))
+		ret = __htab_lru_percpu_map_update_elem(map, key, value,
+							map_flags, true);
+	else
+		ret = __htab_percpu_map_update_elem(map, key, value, map_flags,
+						    true);
 	rcu_read_unlock();
 
 	return ret;
@@ -1030,11 +1132,26 @@ static struct bpf_map_type_list htab_percpu_type __read_mostly = {
 	.type = BPF_MAP_TYPE_PERCPU_HASH,
 };
 
+static const struct bpf_map_ops htab_lru_percpu_ops = {
+	.map_alloc = htab_map_alloc,
+	.map_free = htab_map_free,
+	.map_get_next_key = htab_map_get_next_key,
+	.map_lookup_elem = htab_lru_percpu_map_lookup_elem,
+	.map_update_elem = htab_lru_percpu_map_update_elem,
+	.map_delete_elem = htab_lru_map_delete_elem,
+};
+
+static struct bpf_map_type_list htab_lru_percpu_type __read_mostly = {
+	.ops = &htab_lru_percpu_ops,
+	.type = BPF_MAP_TYPE_LRU_PERCPU_HASH,
+};
+
 static int __init register_htab_map(void)
 {
 	bpf_register_map_type(&htab_type);
 	bpf_register_map_type(&htab_percpu_type);
 	bpf_register_map_type(&htab_lru_type);
+	bpf_register_map_type(&htab_lru_percpu_type);
 	return 0;
 }
 late_initcall(register_htab_map);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 228f962..bc69eb4 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -295,6 +295,7 @@ static int map_lookup_elem(union bpf_attr *attr)
 		goto free_key;
 
 	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH ||
+	    map->map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH ||
 	    map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
 		value_size = round_up(map->value_size, 8) * num_possible_cpus();
 	else
@@ -305,7 +306,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 	if (!value)
 		goto free_key;
 
-	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH) {
+	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH ||
+	    map->map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH) {
 		err = bpf_percpu_hash_copy(map, key, value);
 	} else if (map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY) {
 		err = bpf_percpu_array_copy(map, key, value);
@@ -369,6 +371,7 @@ static int map_update_elem(union bpf_attr *attr)
 		goto free_key;
 
 	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH ||
+	    map->map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH ||
 	    map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
 		value_size = round_up(map->value_size, 8) * num_possible_cpus();
 	else
@@ -388,7 +391,8 @@ static int map_update_elem(union bpf_attr *attr)
 	 */
 	preempt_disable();
 	__this_cpu_inc(bpf_prog_active);
-	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH) {
+	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH ||
+	    map->map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH) {
 		err = bpf_percpu_hash_update(map, key, value, attr->flags);
 	} else if (map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY) {
 		err = bpf_percpu_array_update(map, key, value, attr->flags);
-- 
2.5.1
