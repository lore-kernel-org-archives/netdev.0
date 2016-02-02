From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/6] bpf: introduce BPF_MAP_TYPE_PERCPU_HASH map
Date: Mon, 1 Feb 2016 22:39:53 -0800
Message-ID: <1454395198-1796236-2-git-send-email-ast@fb.com>
References: <1454395198-1796236-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Martin KaFai Lau <kafai@fb.com>, Ming Lei <tom.leiming@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:21902 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052AbcBBGkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 01:40:02 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u126b0O1006950
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2016 22:40:01 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 20rsvbkker-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 22:40:00 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 c7a16c20c97711e5ae4a0002c99293a0-ac6e82b0 for <netdev@vger.kernel.org>;	Mon,
 01 Feb 2016 22:39:59 -0800
In-Reply-To: <1454395198-1796236-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce BPF_MAP_TYPE_PERCPU_HASH map type which is used to do
accurate counters without need to use BPF_XADD instruction which turned
out to be too costly for high-performance network monitoring.
In the typical use case the 'key' is the flow tuple or other long
living object that sees a lot of events per second.

bpf_map_lookup_elem() returns per-cpu area.
Example:
struct {
  u32 packets;
  u32 bytes;
} * ptr = bpf_map_lookup_elem(&map, &key);
/* ptr points to this_cpu area of the value, so the following
 * increments will not collide with other cpus
 */
ptr->packets ++;
ptr->bytes += skb->len;

bpf_update_elem() atomically creates a new element where all per-cpu
values are zero initialized and this_cpu value is populated with
given 'value'.
Note that non-per-cpu hash map always allocates new element
and then deletes old after rcu grace period to maintain atomicity
of update. Per-cpu hash map updates element values in-place.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |   1 +
 kernel/bpf/hashtab.c     | 275 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 229 insertions(+), 47 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index aa6f8571de13..43ae40c8763e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -81,6 +81,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_ARRAY,
 	BPF_MAP_TYPE_PROG_ARRAY,
 	BPF_MAP_TYPE_PERF_EVENT_ARRAY,
+	BPF_MAP_TYPE_PERCPU_HASH,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index c5b30fd8a315..2be5f6e8bb04 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -31,21 +31,27 @@ struct bpf_htab {
 struct htab_elem {
 	struct hlist_node hash_node;
 	struct rcu_head rcu;
-	u32 hash;
+	union {
+		u32 hash;
+		u32 key_size;
+	};
 	char key[0] __aligned(8);
 };
 
 /* Called from syscall */
 static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 {
+	bool percpu = attr->map_type == BPF_MAP_TYPE_PERCPU_HASH;
 	struct bpf_htab *htab;
 	int err, i;
+	u64 cost;
 
 	htab = kzalloc(sizeof(*htab), GFP_USER);
 	if (!htab)
 		return ERR_PTR(-ENOMEM);
 
 	/* mandatory map attributes */
+	htab->map.map_type = attr->map_type;
 	htab->map.key_size = attr->key_size;
 	htab->map.value_size = attr->value_size;
 	htab->map.max_entries = attr->max_entries;
@@ -77,24 +83,34 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		 */
 		goto free_htab;
 
+	if (percpu && round_up(htab->map.value_size, 8) > PCPU_MIN_UNIT_SIZE)
+		/* make sure the size for pcpu_alloc() is reasonable */
+		goto free_htab;
+
 	htab->elem_size = sizeof(struct htab_elem) +
-			  round_up(htab->map.key_size, 8) +
-			  htab->map.value_size;
+			  round_up(htab->map.key_size, 8);
+	if (percpu)
+		htab->elem_size += sizeof(void *);
+	else
+		htab->elem_size += htab->map.value_size;
 
 	/* prevent zero size kmalloc and check for u32 overflow */
 	if (htab->n_buckets == 0 ||
 	    htab->n_buckets > U32_MAX / sizeof(struct bucket))
 		goto free_htab;
 
-	if ((u64) htab->n_buckets * sizeof(struct bucket) +
-	    (u64) htab->elem_size * htab->map.max_entries >=
-	    U32_MAX - PAGE_SIZE)
+	cost = (u64) htab->n_buckets * sizeof(struct bucket) +
+	       (u64) htab->elem_size * htab->map.max_entries;
+
+	if (percpu)
+		cost += (u64) round_up(htab->map.value_size, 8) *
+			num_possible_cpus() * htab->map.max_entries;
+
+	if (cost >= U32_MAX - PAGE_SIZE)
 		/* make sure page count doesn't overflow */
 		goto free_htab;
 
-	htab->map.pages = round_up(htab->n_buckets * sizeof(struct bucket) +
-				   htab->elem_size * htab->map.max_entries,
-				   PAGE_SIZE) >> PAGE_SHIFT;
+	htab->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
 
 	err = -ENOMEM;
 	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct bucket),
@@ -148,7 +164,7 @@ static struct htab_elem *lookup_elem_raw(struct hlist_head *head, u32 hash,
 }
 
 /* Called from syscall or from eBPF program */
-static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
+static void *__htab_map_lookup_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_head *head;
@@ -166,6 +182,13 @@ static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
 
 	l = lookup_elem_raw(head, hash, key, key_size);
 
+	return l;
+}
+
+static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct htab_elem *l = __htab_map_lookup_elem(map, key);
+
 	if (l)
 		return l->key + round_up(map->key_size, 8);
 
@@ -230,65 +253,139 @@ find_first_elem:
 	return -ENOENT;
 }
 
+
+static inline void htab_elem_set_ptr(struct htab_elem *l, u32 key_size,
+				     void __percpu *pptr)
+{
+	*(void __percpu **)(l->key + key_size) = pptr;
+}
+
+static inline void __percpu *htab_elem_get_ptr(struct htab_elem *l, u32 key_size)
+{
+	return *(void __percpu **)(l->key + key_size);
+}
+
+static void htab_percpu_elem_free(struct htab_elem *l)
+{
+	free_percpu(htab_elem_get_ptr(l, l->key_size));
+	kfree(l);
+}
+
+static void htab_percpu_elem_free_rcu(struct rcu_head *head)
+{
+	struct htab_elem *l = container_of(head, struct htab_elem, rcu);
+
+	htab_percpu_elem_free(l);
+}
+
+static void free_htab_elem(struct htab_elem *l, bool percpu, u32 key_size)
+{
+	if (percpu) {
+		l->key_size = key_size;
+		call_rcu(&l->rcu, htab_percpu_elem_free_rcu);
+	} else {
+		kfree_rcu(l, rcu);
+	}
+}
+
+static struct htab_elem *alloc_htab_elem(struct bpf_htab *htab, void *key,
+					 void *value, u32 key_size, u32 hash,
+					 bool percpu)
+{
+	u32 size = htab->map.value_size;
+	struct htab_elem *l_new;
+	void __percpu *pptr;
+
+	l_new = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
+	if (!l_new)
+		return NULL;
+
+	memcpy(l_new->key, key, key_size);
+	if (percpu) {
+		/* round up value_size to 8 bytes */
+		size = round_up(size, 8);
+
+		/* alloc_percpu zero-fills */
+		pptr = __alloc_percpu_gfp(size, 8, GFP_ATOMIC | __GFP_NOWARN);
+		if (!pptr) {
+			kfree(l_new);
+			return NULL;
+		}
+
+		/* copy true value_size bytes */
+		memcpy(this_cpu_ptr(pptr), value, htab->map.value_size);
+		htab_elem_set_ptr(l_new, key_size, pptr);
+	} else {
+		memcpy(l_new->key + round_up(key_size, 8), value, size);
+	}
+
+	l_new->hash = hash;
+	return l_new;
+}
+
+static int check_flags(struct bpf_htab *htab, struct htab_elem *l_old,
+		       u64 map_flags)
+{
+	if (!l_old && unlikely(atomic_read(&htab->count) >= htab->map.max_entries))
+		/* if elem with this 'key' doesn't exist and we've reached
+		 * max_entries limit, fail insertion of new elem
+		 */
+		return -E2BIG;
+
+	if (l_old && map_flags == BPF_NOEXIST)
+		/* elem already exists */
+		return -EEXIST;
+
+	if (!l_old && map_flags == BPF_EXIST)
+		/* elem doesn't exist, cannot update it */
+		return -ENOENT;
+
+	return 0;
+}
+
 /* Called from syscall or from eBPF program */
 static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 				u64 map_flags)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
-	struct htab_elem *l_new, *l_old;
+	struct htab_elem *l_new = NULL, *l_old;
 	struct hlist_head *head;
-	struct bucket *b;
 	unsigned long flags;
-	u32 key_size;
+	struct bucket *b;
+	u32 key_size, hash;
 	int ret;
 
-	if (map_flags > BPF_EXIST)
+	if (unlikely(map_flags > BPF_EXIST))
 		/* unknown flags */
 		return -EINVAL;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	/* allocate new element outside of lock */
-	l_new = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
-	if (!l_new)
-		return -ENOMEM;
-
 	key_size = map->key_size;
 
-	memcpy(l_new->key, key, key_size);
-	memcpy(l_new->key + round_up(key_size, 8), value, map->value_size);
+	hash = htab_map_hash(key, key_size);
+
+	/* allocate new element outside of the lock, since
+	 * we're most likley going to insert it
+	 */
+	l_new = alloc_htab_elem(htab, key, value, key_size, hash, false);
+	if (!l_new)
+		return -ENOMEM;
 
-	l_new->hash = htab_map_hash(l_new->key, key_size);
-	b = __select_bucket(htab, l_new->hash);
+	b = __select_bucket(htab, hash);
 	head = &b->head;
 
 	/* bpf_map_update_elem() can be called in_irq() */
 	raw_spin_lock_irqsave(&b->lock, flags);
 
-	l_old = lookup_elem_raw(head, l_new->hash, key, key_size);
+	l_old = lookup_elem_raw(head, hash, key, key_size);
 
-	if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
-		/* if elem with this 'key' doesn't exist and we've reached
-		 * max_entries limit, fail insertion of new elem
-		 */
-		ret = -E2BIG;
+	ret = check_flags(htab, l_old, map_flags);
+	if (ret)
 		goto err;
-	}
 
-	if (l_old && map_flags == BPF_NOEXIST) {
-		/* elem already exists */
-		ret = -EEXIST;
-		goto err;
-	}
-
-	if (!l_old && map_flags == BPF_EXIST) {
-		/* elem doesn't exist, cannot update it */
-		ret = -ENOENT;
-		goto err;
-	}
-
-	/* add new element to the head of the list, so that concurrent
-	 * search will find it before old elem
+	/* add new element to the head of the list, so that
+	 * concurrent search will find it before old elem
 	 */
 	hlist_add_head_rcu(&l_new->hash_node, head);
 	if (l_old) {
@@ -298,7 +395,6 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 		atomic_inc(&htab->count);
 	}
 	raw_spin_unlock_irqrestore(&b->lock, flags);
-
 	return 0;
 err:
 	raw_spin_unlock_irqrestore(&b->lock, flags);
@@ -306,10 +402,64 @@ err:
 	return ret;
 }
 
+static int htab_percpu_map_update_elem(struct bpf_map *map, void *key,
+				       void *value, u64 map_flags)
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
+		/* per-cpu hash map can update value in-place */
+		memcpy(this_cpu_ptr(htab_elem_get_ptr(l_old, key_size)),
+		       value, htab->map.value_size);
+	} else {
+		l_new = alloc_htab_elem(htab, key, value, key_size,
+					hash, true);
+		if (!l_new) {
+			ret = -ENOMEM;
+			goto err;
+		}
+		hlist_add_head_rcu(&l_new->hash_node, head);
+		atomic_inc(&htab->count);
+	}
+	ret = 0;
+err:
+	raw_spin_unlock_irqrestore(&b->lock, flags);
+	return ret;
+}
+
 /* Called from syscall or from eBPF program */
 static int htab_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	bool percpu = map->map_type == BPF_MAP_TYPE_PERCPU_HASH;
 	struct hlist_head *head;
 	struct bucket *b;
 	struct htab_elem *l;
@@ -332,7 +482,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	if (l) {
 		hlist_del_rcu(&l->hash_node);
 		atomic_dec(&htab->count);
-		kfree_rcu(l, rcu);
+		free_htab_elem(l, percpu, key_size);
 		ret = 0;
 	}
 
@@ -352,7 +502,12 @@ static void delete_all_elements(struct bpf_htab *htab)
 		hlist_for_each_entry_safe(l, n, head, hash_node) {
 			hlist_del_rcu(&l->hash_node);
 			atomic_dec(&htab->count);
-			kfree(l);
+			if (htab->map.map_type == BPF_MAP_TYPE_PERCPU_HASH) {
+				l->key_size = htab->map.key_size;
+				htab_percpu_elem_free(l);
+			} else {
+				kfree(l);
+			}
 		}
 	}
 }
@@ -391,9 +546,35 @@ static struct bpf_map_type_list htab_type __read_mostly = {
 	.type = BPF_MAP_TYPE_HASH,
 };
 
+/* Called from eBPF program */
+static void *htab_percpu_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct htab_elem *l = __htab_map_lookup_elem(map, key);
+
+	if (l)
+		return this_cpu_ptr(htab_elem_get_ptr(l, map->key_size));
+	else
+		return NULL;
+}
+
+static const struct bpf_map_ops htab_percpu_ops = {
+	.map_alloc = htab_map_alloc,
+	.map_free = htab_map_free,
+	.map_get_next_key = htab_map_get_next_key,
+	.map_lookup_elem = htab_percpu_map_lookup_elem,
+	.map_update_elem = htab_percpu_map_update_elem,
+	.map_delete_elem = htab_map_delete_elem,
+};
+
+static struct bpf_map_type_list htab_percpu_type __read_mostly = {
+	.ops = &htab_percpu_ops,
+	.type = BPF_MAP_TYPE_PERCPU_HASH,
+};
+
 static int __init register_htab_map(void)
 {
 	bpf_register_map_type(&htab_type);
+	bpf_register_map_type(&htab_percpu_type);
 	return 0;
 }
 late_initcall(register_htab_map);
-- 
2.4.6
