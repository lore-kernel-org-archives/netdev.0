From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 3/3] bpf: hash: use per-bucket spinlock
Date: Sat, 26 Dec 2015 17:31:34 +0800
Message-ID: <1451122294-16524-4-git-send-email-tom.leiming@gmail.com>
References: <1451122294-16524-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451122294-16524-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei@canonical.com>

Both htab_map_update_elem() and htab_map_delete_elem() can be
called from eBPF program, and they may be in kernel hot path,
so it isn't efficient to use a per-hashtable lock in this two
helpers.

The per-hashtable spinlock is used just for protecting bucket's
hlist, and per-bucket lock should be enough. This patch converts
the per-hashtable lock into per-bucket spinlock, so that contention
can be decreased a lot.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 kernel/bpf/hashtab.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index d857fcb..66bad7a 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -14,9 +14,14 @@
 #include <linux/filter.h>
 #include <linux/vmalloc.h>
 
+struct bucket {
+	struct hlist_head head;
+	raw_spinlock_t lock;
+};
+
 struct bpf_htab {
 	struct bpf_map map;
-	struct hlist_head *buckets;
+	struct bucket *buckets;
 	raw_spinlock_t lock;
 	atomic_t count;	/* number of elements in this hashtable */
 	u32 n_buckets;	/* number of hash buckets */
@@ -88,24 +93,25 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		/* make sure page count doesn't overflow */
 		goto free_htab;
 
-	htab->map.pages = round_up(htab->n_buckets * sizeof(struct hlist_head) +
+	htab->map.pages = round_up(htab->n_buckets * sizeof(struct bucket) +
 				   htab->elem_size * htab->map.max_entries,
 				   PAGE_SIZE) >> PAGE_SHIFT;
 
 	err = -ENOMEM;
-	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct hlist_head),
+	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct bucket),
 				      GFP_USER | __GFP_NOWARN);
 
 	if (!htab->buckets) {
-		htab->buckets = vmalloc(htab->n_buckets * sizeof(struct hlist_head));
+		htab->buckets = vmalloc(htab->n_buckets * sizeof(struct bucket));
 		if (!htab->buckets)
 			goto free_htab;
 	}
 
-	for (i = 0; i < htab->n_buckets; i++)
-		INIT_HLIST_HEAD(&htab->buckets[i]);
+	for (i = 0; i < htab->n_buckets; i++) {
+		INIT_HLIST_HEAD(&htab->buckets[i].head);
+		raw_spin_lock_init(&htab->buckets[i].lock);
+	}
 
-	raw_spin_lock_init(&htab->lock);
 	atomic_set(&htab->count, 0);
 
 	return &htab->map;
@@ -120,11 +126,16 @@ static inline u32 htab_map_hash(const void *key, u32 key_len)
 	return jhash(key, key_len, 0);
 }
 
-static inline struct hlist_head *select_bucket(struct bpf_htab *htab, u32 hash)
+static inline struct bucket *__select_bucket(struct bpf_htab *htab, u32 hash)
 {
 	return &htab->buckets[hash & (htab->n_buckets - 1)];
 }
 
+static inline struct hlist_head *select_bucket(struct bpf_htab *htab, u32 hash)
+{
+	return &__select_bucket(htab, hash)->head;
+}
+
 static struct htab_elem *lookup_elem_raw(struct hlist_head *head, u32 hash,
 					 void *key, u32 key_size)
 {
@@ -227,6 +238,7 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct htab_elem *l_new, *l_old;
 	struct hlist_head *head;
+	struct bucket *b;
 	unsigned long flags;
 	u32 key_size;
 	int ret;
@@ -248,7 +260,8 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	memcpy(l_new->key + round_up(key_size, 8), value, map->value_size);
 
 	l_new->hash = htab_map_hash(l_new->key, key_size);
-	head = select_bucket(htab, l_new->hash);
+	b = __select_bucket(htab, l_new->hash);
+	head = &b->head;
 
 	/* bpf_map_update_elem() can be called in_irq() */
 	raw_spin_lock_irqsave(&htab->lock, flags);
@@ -299,6 +312,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_head *head;
+	struct bucket *b;
 	struct htab_elem *l;
 	unsigned long flags;
 	u32 hash, key_size;
@@ -309,7 +323,8 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	key_size = map->key_size;
 
 	hash = htab_map_hash(key, key_size);
-	head = select_bucket(htab, hash);
+	b = __select_bucket(htab, hash);
+	head = &b->head;
 
 	raw_spin_lock_irqsave(&htab->lock, flags);
 
-- 
1.9.1
