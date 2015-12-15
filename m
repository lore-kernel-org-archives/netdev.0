From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 4/6] bpf: hash: convert per-hashtable lock into per-bucket bit spinlock
Date: Tue, 15 Dec 2015 19:21:02 +0800
Message-ID: <1450178464-27721-5-git-send-email-tom.leiming@gmail.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both htab_map_update_elem() and htab_map_delete_elem() can be
called from eBPF program, and they may be in kernel hot path,
so it isn't efficient to use a per-hashtable lock in this two
helpers.

The per-hashtable spinlock is used just for protecting bucket's
hlist, and per-bucket lock should be enough. This patch converts
the per-hashtable lock into per-bucket bit spinlock, so that
contention can be decreased a lot, and no extra memory can be
consumed for these locks.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/hashtab.c | 38 ++++++++++++++++++++++++++------------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index d857fcb..8543fea 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -17,7 +17,6 @@
 struct bpf_htab {
 	struct bpf_map map;
 	struct hlist_head *buckets;
-	raw_spinlock_t lock;
 	atomic_t count;	/* number of elements in this hashtable */
 	u32 n_buckets;	/* number of hash buckets */
 	u32 elem_size;	/* size of each element in bytes */
@@ -105,7 +104,6 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	for (i = 0; i < htab->n_buckets; i++)
 		INIT_HLIST_HEAD(&htab->buckets[i]);
 
-	raw_spin_lock_init(&htab->lock);
 	atomic_set(&htab->count, 0);
 
 	return &htab->map;
@@ -142,6 +140,7 @@ static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_head *head;
+	struct hlist_head h;
 	struct htab_elem *l;
 	u32 hash, key_size;
 
@@ -153,6 +152,7 @@ static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
 	hash = htab_map_hash(key, key_size);
 
 	head = select_bucket(htab, hash);
+	head = hlist_get_head_lock(head, &h);
 
 	l = lookup_elem_raw(head, hash, key, key_size);
 
@@ -167,6 +167,7 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_head *head;
+	struct hlist_head h;
 	struct htab_elem *l, *next_l;
 	u32 hash, key_size;
 	int i;
@@ -178,6 +179,7 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	hash = htab_map_hash(key, key_size);
 
 	head = select_bucket(htab, hash);
+	head = hlist_get_head_lock(head, &h);
 
 	/* lookup the key */
 	l = lookup_elem_raw(head, hash, key, key_size);
@@ -205,6 +207,7 @@ find_first_elem:
 	/* iterate over buckets */
 	for (; i < htab->n_buckets; i++) {
 		head = select_bucket(htab, i);
+		head = hlist_get_head_lock(head, &h);
 
 		/* pick first element in the bucket */
 		next_l = hlist_entry_safe(rcu_dereference_raw(hlist_first_rcu(head)),
@@ -227,6 +230,7 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct htab_elem *l_new, *l_old;
 	struct hlist_head *head;
+	struct hlist_head h;
 	unsigned long flags;
 	u32 key_size;
 	int ret;
@@ -251,9 +255,11 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	head = select_bucket(htab, l_new->hash);
 
 	/* bpf_map_update_elem() can be called in_irq() */
-	raw_spin_lock_irqsave(&htab->lock, flags);
+	raw_local_irq_save(flags);
+	bit_spin_lock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
 
-	l_old = lookup_elem_raw(head, l_new->hash, key, key_size);
+	l_old = lookup_elem_raw(hlist_get_head_lock(head, &h), l_new->hash,
+			key, key_size);
 
 	if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
 		/* if elem with this 'key' doesn't exist and we've reached
@@ -278,18 +284,20 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	/* add new element to the head of the list, so that concurrent
 	 * search will find it before old elem
 	 */
-	hlist_add_head_rcu(&l_new->hash_node, head);
+	hlist_add_head_rcu_lock(&l_new->hash_node, head);
 	if (l_old) {
-		hlist_del_rcu(&l_old->hash_node);
+		hlist_del_rcu_lock(&l_old->hash_node);
 		kfree_rcu(l_old, rcu);
 	} else {
 		atomic_inc(&htab->count);
 	}
-	raw_spin_unlock_irqrestore(&htab->lock, flags);
+	bit_spin_unlock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
+	raw_local_irq_restore(flags);
 
 	return 0;
 err:
-	raw_spin_unlock_irqrestore(&htab->lock, flags);
+	bit_spin_unlock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
+	raw_local_irq_restore(flags);
 	kfree(l_new);
 	return ret;
 }
@@ -299,6 +307,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_head *head;
+	struct hlist_head h;
 	struct htab_elem *l;
 	unsigned long flags;
 	u32 hash, key_size;
@@ -311,18 +320,20 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	hash = htab_map_hash(key, key_size);
 	head = select_bucket(htab, hash);
 
-	raw_spin_lock_irqsave(&htab->lock, flags);
+	raw_local_irq_save(flags);
+	bit_spin_lock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
 
-	l = lookup_elem_raw(head, hash, key, key_size);
+	l = lookup_elem_raw(hlist_get_head_lock(head, &h), hash, key, key_size);
 
 	if (l) {
-		hlist_del_rcu(&l->hash_node);
+		hlist_del_rcu_lock(&l->hash_node);
 		atomic_dec(&htab->count);
 		kfree_rcu(l, rcu);
 		ret = 0;
 	}
 
-	raw_spin_unlock_irqrestore(&htab->lock, flags);
+	bit_spin_unlock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
+	raw_local_irq_restore(flags);
 	return ret;
 }
 
@@ -332,9 +343,12 @@ static void delete_all_elements(struct bpf_htab *htab)
 
 	for (i = 0; i < htab->n_buckets; i++) {
 		struct hlist_head *head = select_bucket(htab, i);
+		struct hlist_head h;
 		struct hlist_node *n;
 		struct htab_elem *l;
 
+		head = hlist_get_head_lock(head, &h);
+
 		hlist_for_each_entry_safe(l, n, head, hash_node) {
 			hlist_del_rcu(&l->hash_node);
 			atomic_dec(&htab->count);
-- 
1.9.1
