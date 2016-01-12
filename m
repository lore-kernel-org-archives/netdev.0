From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 1/4] bpf: bpf_htab: Refactor some htab_elem logic
Date: Tue, 12 Jan 2016 00:20:49 -0800
Message-ID: <1452586852-1575604-2-git-send-email-kafai@fb.com>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Ming Lei <tom.leiming@gmail.com>,
	FB Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:63402 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761881AbcALIVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 03:21:06 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u0C8KKiK008001
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 00:21:06 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 20cnqm9hat-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 00:21:06 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 6b56124ab90511e5a56524be05956610-44ffa1f0 for <netdev@vger.kernel.org>;	Tue,
 12 Jan 2016 00:21:03 -0800
In-Reply-To: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work for htab_percpu_map.

A similar fio test against /dev/nullb0 is done
while bcc/tools/biolatency is running.  It is to
make sure this change does not have regression
after the commit 688ecfe60220 ("bpf: hash: use per-bucket spinlock")
by "Ming Lei <tom.leiming@gmail.com>".

With biolatency running, the iops before and after this patch
is similar.  However, I cannot get as high iops as Ming did when
biolatency is not running.

With biolatency running, I get ~280k iops before
and after this patch.  Hence, no regression noticed.

Without biolatency running, I get ~330k iops.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/hashtab.c | 217 ++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 153 insertions(+), 64 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index c5b30fd..24a6a47 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -19,24 +19,45 @@ struct bucket {
 	raw_spinlock_t lock;
 };
 
+struct htab_elem_common;
+typedef void (*elem_free_fn)(struct htab_elem_common *);
+
 struct bpf_htab {
 	struct bpf_map map;
 	struct bucket *buckets;
 	atomic_t count;	/* number of elements in this hashtable */
 	u32 n_buckets;	/* number of hash buckets */
 	u32 elem_size;	/* size of each element in bytes */
+	u32 elem_key_offset; /* offset to the key */
 };
 
-/* each htab element is struct htab_elem + key + value */
-struct htab_elem {
+struct htab_elem_common {
 	struct hlist_node hash_node;
 	struct rcu_head rcu;
 	u32 hash;
+};
+
+/* each htab element is struct htab_elem + key + value */
+struct htab_elem {
+	struct htab_elem_common common;
 	char key[0] __aligned(8);
 };
 
-/* Called from syscall */
-static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
+static void *htab_elem_common_get_key(const struct bpf_htab *htab,
+				      struct htab_elem_common *l)
+{
+	return (void *)l + htab->elem_key_offset;
+}
+
+static struct htab_elem *htab_elem(struct htab_elem_common *l)
+{
+	return (struct htab_elem *)l;
+}
+
+static struct bpf_map *__htab_map_alloc(union bpf_attr *attr,
+					u32 elem_size,
+					u32 elem_value_size,
+					u32 elem_key_offset)
 {
 	struct bpf_htab *htab;
 	int err, i;
@@ -77,9 +98,8 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		 */
 		goto free_htab;
 
-	htab->elem_size = sizeof(struct htab_elem) +
-			  round_up(htab->map.key_size, 8) +
-			  htab->map.value_size;
+	htab->elem_size = elem_size;
+	htab->elem_key_offset = elem_key_offset;
 
 	/* prevent zero size kmalloc and check for u32 overflow */
 	if (htab->n_buckets == 0 ||
@@ -87,13 +107,13 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		goto free_htab;
 
 	if ((u64) htab->n_buckets * sizeof(struct bucket) +
-	    (u64) htab->elem_size * htab->map.max_entries >=
+	    (u64) elem_value_size * htab->map.max_entries >=
 	    U32_MAX - PAGE_SIZE)
 		/* make sure page count doesn't overflow */
 		goto free_htab;
 
 	htab->map.pages = round_up(htab->n_buckets * sizeof(struct bucket) +
-				   htab->elem_size * htab->map.max_entries,
+				   elem_value_size * htab->map.max_entries,
 				   PAGE_SIZE) >> PAGE_SHIFT;
 
 	err = -ENOMEM;
@@ -120,6 +140,16 @@ free_htab:
 	return ERR_PTR(err);
 }
 
+/* Called from syscall */
+static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
+{
+	u32 elem_size = sizeof(struct htab_elem) + round_up(attr->key_size, 8) +
+		attr->value_size;
+
+	return __htab_map_alloc(attr, elem_size, elem_size,
+				offsetof(struct htab_elem, key));
+}
+
 static inline u32 htab_map_hash(const void *key, u32 key_len)
 {
 	return jhash(key, key_len, 0);
@@ -135,39 +165,48 @@ static inline struct hlist_head *select_bucket(struct bpf_htab *htab, u32 hash)
 	return &__select_bucket(htab, hash)->head;
 }
 
-static struct htab_elem *lookup_elem_raw(struct hlist_head *head, u32 hash,
-					 void *key, u32 key_size)
+static struct htab_elem_common *lookup_elem_raw(struct bpf_htab *htab,
+						struct hlist_head *head,
+						u32 hash, void *key)
 {
-	struct htab_elem *l;
+	struct htab_elem_common *l;
 
 	hlist_for_each_entry_rcu(l, head, hash_node)
-		if (l->hash == hash && !memcmp(&l->key, key, key_size))
+		if (l->hash == hash &&
+		    !memcmp(htab_elem_common_get_key(htab, l),
+			    key, htab->map.key_size))
 			return l;
 
 	return NULL;
 }
 
 /* Called from syscall or from eBPF program */
-static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
+static struct htab_elem_common *__htab_map_lookup_elem(struct bpf_htab *htab,
+						       void *key)
 {
-	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_head *head;
-	struct htab_elem *l;
 	u32 hash, key_size;
 
 	/* Must be called with rcu_read_lock. */
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	key_size = map->key_size;
+	key_size = htab->map.key_size;
 
 	hash = htab_map_hash(key, key_size);
 
 	head = select_bucket(htab, hash);
 
-	l = lookup_elem_raw(head, hash, key, key_size);
+	return lookup_elem_raw(htab, head, hash, key);
+}
 
+static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct htab_elem_common *l;
+
+	l = __htab_map_lookup_elem(htab, key);
 	if (l)
-		return l->key + round_up(map->key_size, 8);
+		return htab_elem(l)->key + round_up(map->key_size, 8);
 
 	return NULL;
 }
@@ -177,7 +216,7 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_head *head;
-	struct htab_elem *l, *next_l;
+	struct htab_elem_common *l, *next_l;
 	u32 hash, key_size;
 	int i;
 
@@ -190,7 +229,7 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	head = select_bucket(htab, hash);
 
 	/* lookup the key */
-	l = lookup_elem_raw(head, hash, key, key_size);
+	l = lookup_elem_raw(htab, head, hash, key);
 
 	if (!l) {
 		i = 0;
@@ -199,11 +238,12 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 
 	/* key was found, get next key in the same bucket */
 	next_l = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu(&l->hash_node)),
-				  struct htab_elem, hash_node);
+				  struct htab_elem_common, hash_node);
 
 	if (next_l) {
 		/* if next elem in this hash list is non-zero, just return it */
-		memcpy(next_key, next_l->key, key_size);
+		memcpy(next_key, htab_elem_common_get_key(htab, next_l),
+		       key_size);
 		return 0;
 	}
 
@@ -218,10 +258,11 @@ find_first_elem:
 
 		/* pick first element in the bucket */
 		next_l = hlist_entry_safe(rcu_dereference_raw(hlist_first_rcu(head)),
-					  struct htab_elem, hash_node);
+					  struct htab_elem_common, hash_node);
 		if (next_l) {
 			/* if it's not empty, just return it */
-			memcpy(next_key, next_l->key, key_size);
+			memcpy(next_key, htab_elem_common_get_key(htab, next_l),
+			       key_size);
 			return 0;
 		}
 	}
@@ -230,6 +271,67 @@ find_first_elem:
 	return -ENOENT;
 }
 
+static struct htab_elem_common *htab_elem_common_alloc(
+	const struct bpf_htab *htab, void *key)
+{
+	struct htab_elem_common *l;
+
+	l = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
+	if (!l)
+		return NULL;
+
+	memcpy(htab_elem_common_get_key(htab, l), key, htab->map.key_size);
+	l->hash = htab_map_hash(key, htab->map.key_size);
+
+	return l;
+}
+
+static struct htab_elem *htab_elem_alloc(const struct bpf_htab *htab,
+					 void *key,
+					 void *value)
+{
+	struct htab_elem *l;
+
+	l = htab_elem(htab_elem_common_alloc(htab, key));
+	if (!l)
+		return NULL;
+
+	memcpy(l->key + round_up(htab->map.key_size, 8), value,
+	       htab->map.value_size);
+
+	return l;
+}
+
+static struct htab_elem_common *htab_map_check_update(
+	struct bpf_htab *htab,
+	struct hlist_head *head,
+	u32 hash,
+	void *key,
+	u64 map_flags)
+{
+	struct htab_elem_common *l_old;
+
+	l_old = lookup_elem_raw(htab, head, hash, key);
+
+	if (!l_old &&
+	    unlikely(atomic_read(&htab->count) >= htab->map.max_entries)) {
+		/* if elem with this 'key' doesn't exist and we've reached
+		 * max_entries limit, fail insertion of new elem
+		 */
+		return ERR_PTR(-E2BIG);
+	}
+
+	if (l_old && map_flags == BPF_NOEXIST)
+		/* elem already exists */
+		return ERR_PTR(-EEXIST);
+
+	if (!l_old && map_flags == BPF_EXIST)
+		/* elem doesn't exist, cannot update it */
+		return ERR_PTR(-ENOENT);
+
+	return l_old;
+}
+
 /* Called from syscall or from eBPF program */
 static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 				u64 map_flags)
@@ -239,7 +341,6 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	struct hlist_head *head;
 	struct bucket *b;
 	unsigned long flags;
-	u32 key_size;
 	int ret;
 
 	if (map_flags > BPF_EXIST)
@@ -249,51 +350,32 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
 	/* allocate new element outside of lock */
-	l_new = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
+	l_new = htab_elem_alloc(htab, key, value);
 	if (!l_new)
 		return -ENOMEM;
 
-	key_size = map->key_size;
-
-	memcpy(l_new->key, key, key_size);
-	memcpy(l_new->key + round_up(key_size, 8), value, map->value_size);
-
-	l_new->hash = htab_map_hash(l_new->key, key_size);
-	b = __select_bucket(htab, l_new->hash);
+	b = __select_bucket(htab, l_new->common.hash);
 	head = &b->head;
 
 	/* bpf_map_update_elem() can be called in_irq() */
 	raw_spin_lock_irqsave(&b->lock, flags);
 
-	l_old = lookup_elem_raw(head, l_new->hash, key, key_size);
+	l_old = htab_elem(htab_map_check_update(
+				  htab, head, l_new->common.hash, key,
+				  map_flags));
 
-	if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
-		/* if elem with this 'key' doesn't exist and we've reached
-		 * max_entries limit, fail insertion of new elem
-		 */
-		ret = -E2BIG;
-		goto err;
-	}
-
-	if (l_old && map_flags == BPF_NOEXIST) {
-		/* elem already exists */
-		ret = -EEXIST;
-		goto err;
-	}
-
-	if (!l_old && map_flags == BPF_EXIST) {
-		/* elem doesn't exist, cannot update it */
-		ret = -ENOENT;
+	if (IS_ERR(l_old)) {
+		ret = PTR_ERR(l_old);
 		goto err;
 	}
 
 	/* add new element to the head of the list, so that concurrent
 	 * search will find it before old elem
 	 */
-	hlist_add_head_rcu(&l_new->hash_node, head);
+	hlist_add_head_rcu(&l_new->common.hash_node, head);
 	if (l_old) {
-		hlist_del_rcu(&l_old->hash_node);
-		kfree_rcu(l_old, rcu);
+		hlist_del_rcu(&l_old->common.hash_node);
+		kfree_rcu(&l_old->common, rcu);
 	} else {
 		atomic_inc(&htab->count);
 	}
@@ -310,9 +392,9 @@ err:
 static int htab_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct htab_elem_common *l;
 	struct hlist_head *head;
 	struct bucket *b;
-	struct htab_elem *l;
 	unsigned long flags;
 	u32 hash, key_size;
 	int ret = -ENOENT;
@@ -327,7 +409,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 
 	raw_spin_lock_irqsave(&b->lock, flags);
 
-	l = lookup_elem_raw(head, hash, key, key_size);
+	l = lookup_elem_raw(htab, head, hash, key);
 
 	if (l) {
 		hlist_del_rcu(&l->hash_node);
@@ -340,28 +422,28 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	return ret;
 }
 
-static void delete_all_elements(struct bpf_htab *htab)
+static void delete_all_elements(struct bpf_htab *htab, elem_free_fn elem_free)
+
 {
 	int i;
 
 	for (i = 0; i < htab->n_buckets; i++) {
 		struct hlist_head *head = select_bucket(htab, i);
 		struct hlist_node *n;
-		struct htab_elem *l;
+		struct htab_elem_common *l;
 
 		hlist_for_each_entry_safe(l, n, head, hash_node) {
 			hlist_del_rcu(&l->hash_node);
 			atomic_dec(&htab->count);
-			kfree(l);
+			elem_free(l);
 		}
 	}
 }
 
 /* Called when map->refcnt goes to zero, either from workqueue or from syscall */
-static void htab_map_free(struct bpf_map *map)
+static void __htab_map_free(struct bpf_htab *htab,
+			    elem_free_fn elem_free)
 {
-	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
-
 	/* at this point bpf_prog->aux->refcnt == 0 and this map->refcnt == 0,
 	 * so the programs (can be more than one that used this map) were
 	 * disconnected from events. Wait for outstanding critical sections in
@@ -372,11 +454,18 @@ static void htab_map_free(struct bpf_map *map)
 	/* some of kfree_rcu() callbacks for elements of this map may not have
 	 * executed. It's ok. Proceed to free residual elements and map itself
 	 */
-	delete_all_elements(htab);
+	delete_all_elements(htab, elem_free);
 	kvfree(htab->buckets);
 	kfree(htab);
 }
 
+static void htab_map_free(struct bpf_map *map)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+
+	__htab_map_free(htab, (elem_free_fn)kfree);
+}
+
 static const struct bpf_map_ops htab_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
-- 
2.5.1
