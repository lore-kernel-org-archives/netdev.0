From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 5/6] bpf: hash: avoid to call kmalloc() in eBPF prog
Date: Tue, 15 Dec 2015 19:21:03 +0800
Message-ID: <1450178464-27721-6-git-send-email-tom.leiming@gmail.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kmalloc() is often a bit time-consuming, also
one atomic counter has to be used to track the total
allocated elements, which is also not good.

This patch pre-allocates element pool in htab_map_alloc(),
then use percpu_ida to allocate one slot from the pool,
then the runtime allocation/freeing cost can be decreased.

>From my test, at least 10% fio throughput is improved in block
I/O test when tools/biolatency of bcc(iovisor) is running.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/hashtab.c | 204 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 167 insertions(+), 37 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 8543fea..c1600c3 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -13,23 +13,165 @@
 #include <linux/jhash.h>
 #include <linux/filter.h>
 #include <linux/vmalloc.h>
+#include <linux/percpu_ida.h>
+
+/* each htab element is struct htab_elem + key + value */
+struct htab_elem {
+	union {
+		struct hlist_node hash_node;
+
+		/* used after deleted from hash */
+		struct bpf_htab *htab;
+	};
+	struct rcu_head rcu;
+	u32 hash;
+	u32 tag;
+	char key[0] __aligned(8);
+};
 
 struct bpf_htab {
 	struct bpf_map map;
 	struct hlist_head *buckets;
-	atomic_t count;	/* number of elements in this hashtable */
 	u32 n_buckets;	/* number of hash buckets */
 	u32 elem_size;	/* size of each element in bytes */
-};
 
-/* each htab element is struct htab_elem + key + value */
-struct htab_elem {
-	struct hlist_node hash_node;
-	struct rcu_head rcu;
-	u32 hash;
-	char key[0] __aligned(8);
+	struct list_head page_list;
+	struct htab_elem **elems;
+	struct percpu_ida elems_pool;
 };
 
+static size_t order_to_size(unsigned int order)
+{
+	return (size_t)PAGE_SIZE << order;
+}
+
+/* Called from syscall, and the code is borrowed from blk_mq */
+static int htab_pre_alloc_elems(struct bpf_htab *htab)
+{
+	const unsigned max_order = 4;
+	unsigned elem_size = htab->elem_size, i;
+	unsigned nr_entries = htab->map.max_entries;
+	size_t left = nr_entries * elem_size;
+
+	htab->elems = kzalloc(nr_entries * sizeof(struct htab_elem *),
+			      GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
+	if (!htab->elems)
+		goto fail;
+
+	INIT_LIST_HEAD(&htab->page_list);
+
+	for (i = 0; i < nr_entries; ) {
+		int this_order = max_order;
+		struct page *page;
+		int j, to_do;
+		void *p;
+
+		while (left < order_to_size(this_order - 1) && this_order)
+			this_order--;
+
+		do {
+			page = alloc_pages(GFP_KERNEL | __GFP_NOWARN |
+					   __GFP_NORETRY | __GFP_ZERO,
+					   this_order);
+			if (page)
+				break;
+			if (!this_order--)
+				break;
+			if (order_to_size(this_order) < elem_size)
+				break;
+		} while (1);
+
+		if (!page)
+			goto fail;
+
+		page->private = this_order;
+		list_add_tail(&page->lru, &htab->page_list);
+
+		p = page_address(page);
+
+		to_do = min_t(unsigned,
+			      order_to_size(this_order) / elem_size,
+			      nr_entries - i);
+		left -= to_do * elem_size;
+
+		for (j = 0; j < to_do; j++) {
+			htab->elems[i] = p;
+			p += elem_size;
+			i++;
+		}
+	}
+	return 0;
+
+fail:
+	kfree(htab->elems);
+	return -ENOMEM;
+}
+
+static void htab_destroy_elems(struct bpf_htab *htab)
+{
+	struct page *page;
+
+	while (!list_empty(&htab->page_list)) {
+		page = list_first_entry(&htab->page_list, struct page, lru);
+		list_del_init(&page->lru);
+		__free_pages(page, page->private);
+	}
+
+	kfree(htab->elems);
+}
+
+static int htab_init_elems_allocator(struct bpf_htab *htab)
+{
+	int ret = htab_pre_alloc_elems(htab);
+
+	if (ret)
+		return ret;
+
+	ret = percpu_ida_init(&htab->elems_pool, htab->map.max_entries);
+	if (ret)
+		htab_destroy_elems(htab);
+	return ret;
+}
+
+static void htab_deinit_elems_allocator(struct bpf_htab *htab)
+{
+	htab_destroy_elems(htab);
+	percpu_ida_destroy(&htab->elems_pool);
+}
+
+static struct htab_elem *htab_alloc_elem(struct bpf_htab *htab)
+{
+	int tag = percpu_ida_alloc(&htab->elems_pool, TASK_RUNNING);
+	struct htab_elem *elem;
+
+	if (tag < 0)
+		return NULL;
+
+	elem = htab->elems[tag];
+	elem->tag = tag;
+	return elem;
+}
+
+static void htab_free_elem(struct bpf_htab *htab, struct htab_elem *elem)
+{
+	percpu_ida_free(&htab->elems_pool, elem->tag);
+}
+
+static void htab_free_elem_cb(struct rcu_head *head)
+{
+	struct htab_elem *elem = container_of(head, struct htab_elem, rcu);
+
+	htab_free_elem(elem->htab, elem);
+}
+
+static void htab_free_elem_rcu(struct bpf_htab *htab,
+			       struct htab_elem *elem)
+{
+	hlist_del_rcu_lock(&elem->hash_node);
+	elem->htab = htab;
+	call_rcu(&elem->rcu, htab_free_elem_cb);
+}
+
 /* Called from syscall */
 static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 {
@@ -72,9 +214,10 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		 */
 		goto free_htab;
 
-	htab->elem_size = sizeof(struct htab_elem) +
-			  round_up(htab->map.key_size, 8) +
-			  htab->map.value_size;
+	htab->elem_size = round_up(sizeof(struct htab_elem) +
+				   round_up(htab->map.key_size, 8) +
+				   htab->map.value_size,
+				   cache_line_size());
 
 	/* prevent zero size kmalloc and check for u32 overflow */
 	if (htab->n_buckets == 0 ||
@@ -104,10 +247,14 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	for (i = 0; i < htab->n_buckets; i++)
 		INIT_HLIST_HEAD(&htab->buckets[i]);
 
-	atomic_set(&htab->count, 0);
+	err = htab_init_elems_allocator(htab);
+	if (err)
+		goto free_buckets;
 
 	return &htab->map;
 
+free_buckets:
+	kvfree(htab->buckets);
 free_htab:
 	kfree(htab);
 	return ERR_PTR(err);
@@ -242,9 +389,9 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
 	/* allocate new element outside of lock */
-	l_new = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
+	l_new = htab_alloc_elem(htab);
 	if (!l_new)
-		return -ENOMEM;
+		return -E2BIG;
 
 	key_size = map->key_size;
 
@@ -261,14 +408,6 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	l_old = lookup_elem_raw(hlist_get_head_lock(head, &h), l_new->hash,
 			key, key_size);
 
-	if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
-		/* if elem with this 'key' doesn't exist and we've reached
-		 * max_entries limit, fail insertion of new elem
-		 */
-		ret = -E2BIG;
-		goto err;
-	}
-
 	if (l_old && map_flags == BPF_NOEXIST) {
 		/* elem already exists */
 		ret = -EEXIST;
@@ -285,12 +424,8 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	 * search will find it before old elem
 	 */
 	hlist_add_head_rcu_lock(&l_new->hash_node, head);
-	if (l_old) {
-		hlist_del_rcu_lock(&l_old->hash_node);
-		kfree_rcu(l_old, rcu);
-	} else {
-		atomic_inc(&htab->count);
-	}
+	if (l_old)
+		htab_free_elem_rcu(htab, l_old);
 	bit_spin_unlock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
 	raw_local_irq_restore(flags);
 
@@ -298,7 +433,7 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 err:
 	bit_spin_unlock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
 	raw_local_irq_restore(flags);
-	kfree(l_new);
+	htab_free_elem(htab, l_new);
 	return ret;
 }
 
@@ -324,11 +459,8 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	bit_spin_lock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
 
 	l = lookup_elem_raw(hlist_get_head_lock(head, &h), hash, key, key_size);
-
 	if (l) {
-		hlist_del_rcu_lock(&l->hash_node);
-		atomic_dec(&htab->count);
-		kfree_rcu(l, rcu);
+		htab_free_elem_rcu(htab, l);
 		ret = 0;
 	}
 
@@ -349,11 +481,8 @@ static void delete_all_elements(struct bpf_htab *htab)
 
 		head = hlist_get_head_lock(head, &h);
 
-		hlist_for_each_entry_safe(l, n, head, hash_node) {
+		hlist_for_each_entry_safe(l, n, head, hash_node)
 			hlist_del_rcu(&l->hash_node);
-			atomic_dec(&htab->count);
-			kfree(l);
-		}
 	}
 }
 
@@ -373,6 +502,7 @@ static void htab_map_free(struct bpf_map *map)
 	 * executed. It's ok. Proceed to free residual elements and map itself
 	 */
 	delete_all_elements(htab);
+	htab_deinit_elems_allocator(htab);
 	kvfree(htab->buckets);
 	kfree(htab);
 }
-- 
1.9.1
