From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/9] bpf: pre-allocate hash map elements
Date: Sun, 6 Mar 2016 17:58:31 -0800
Message-ID: <1457315917-1970307-4-git-send-email-ast@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457315917-1970307-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If kprobe is placed on spin_unlock then calling kmalloc/kfree from
bpf programs is not safe, since the following dead lock is possible:
kfree->spin_lock(kmem_cache_node->lock)...spin_unlock->kprobe->
bpf_prog->map_update->kmalloc->spin_lock(of the same kmem_cache_node->lock)
and deadlocks.

The following solutions were considered and some implemented, but
eventually discarded
- kmem_cache_create for every map
- add recursion check to slow-path of slub
- use reserved memory in bpf_map_update for in_irq or in preempt_disabled
- kmalloc via irq_work

At the end pre-allocation of all map elements turned out to be the simplest
solution and since the user is charged upfront for all the memory, such
pre-allocation doesn't affect the user space visible behavior.

Since it's impossible to tell whether kprobe is triggered in a safe
location from kmalloc point of view, use pre-allocation by default
and introduce new BPF_F_NO_PREALLOC flag.

While testing of per-cpu hash maps it was discovered
that alloc_percpu(GFP_ATOMIC) has odd corner cases and often
fails to allocate memory even when 90% of it is free.
The pre-allocation of per-cpu hash elements solves this problem as well.

Turned out that bpf_map_update() quickly followed by
bpf_map_lookup()+bpf_map_delete() is very common pattern used
in many of iovisor/bcc/tools, so there is additional benefit of
pre-allocation, since such use cases are must faster.

Since all hash map elements are now pre-allocated we can remove
atomic increment of htab->count and save few more cycles.

Also add precharge_memlock() to check rlimit_memlock early to avoid
large malloc/free done by by users who don't have sufficient limits.

Pre-allocation is done with vmalloc and alloc/free is done
via percpu_freelist. Here are performance numbers for different
pre-allocation algorithms that were implemented, but discarded
in favor of percpu_freelist:

1 cpu:
pcpu_ida	2.1M
pcpu_ida nolock	2.3M
bt		2.4M
kmalloc		1.8M
hlist+spinlock	2.3M
pcpu_freelist	2.6M

4 cpu:
pcpu_ida	1.5M
pcpu_ida nolock	1.8M
bt w/smp_align	1.7M
bt no/smp_align	1.1M
kmalloc		0.7M
hlist+spinlock	0.2M
pcpu_freelist	2.0M

8 cpu:
pcpu_ida	0.7M
bt w/smp_align	0.8M
kmalloc		0.4M
pcpu_freelist	1.5M

32 cpu:
kmalloc		0.13M
pcpu_freelist	0.49M

pcpu_ida nolock is a modified percpu_ida algorithm without
percpu_ida_cpu locks and without cross-cpu tag stealing.
It's faster than existing percpu_ida, but not as fast as pcpu_freelist.

bt is a variant of block/blk-mq-tag.c simlified and customized
for bpf use case. bt w/smp_align is using cache line for every 'long'
(similar to blk-mq-tag). bt no/smp_align allocates 'long'
bitmasks continuously to save memory. It's comparable to percpu_ida
and in some cases faster, but slower than percpu_freelist

hlist+spinlock is the simplest free list with single spinlock.
As expeceted it has very bad scaling in SMP.

kmalloc is existing implementation which is still available via
BPF_F_NO_PREALLOC flag. It's significantly slower in single cpu and
in 8 cpu setup it's 3 times slower than pre-allocation with pcpu_freelist,
but saves memory, so in cases where map->max_entries can be large
and number of map update/delete per second is low, it may make
sense to use it.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |   1 +
 include/uapi/linux/bpf.h |   3 +
 kernel/bpf/hashtab.c     | 264 ++++++++++++++++++++++++++++++++++-------------
 kernel/bpf/syscall.c     |   2 +-
 4 files changed, 196 insertions(+), 74 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 4b070827200d..c81efb10bbb5 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -37,6 +37,7 @@ struct bpf_map {
 	u32 key_size;
 	u32 value_size;
 	u32 max_entries;
+	u32 map_flags;
 	u32 pages;
 	struct user_struct *user;
 	const struct bpf_map_ops *ops;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6496f98d3d68..5eeb2ca9441e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -101,12 +101,15 @@ enum bpf_prog_type {
 #define BPF_NOEXIST	1 /* create new element if it didn't exist */
 #define BPF_EXIST	2 /* update existing element */
 
+#define BPF_F_NO_PREALLOC	(1ULL << 0)
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
 		__u32	key_size;	/* size of key in bytes */
 		__u32	value_size;	/* size of value in bytes */
 		__u32	max_entries;	/* max number of entries in a map */
+		__u32	map_flags;	/* prealloc or not */
 	};
 
 	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index a68e95133fcd..7d5f539d196b 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -1,4 +1,5 @@
 /* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2016 Facebook
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -13,6 +14,7 @@
 #include <linux/jhash.h>
 #include <linux/filter.h>
 #include <linux/vmalloc.h>
+#include "percpu_freelist.h"
 
 struct bucket {
 	struct hlist_head head;
@@ -22,6 +24,8 @@ struct bucket {
 struct bpf_htab {
 	struct bpf_map map;
 	struct bucket *buckets;
+	void *elems;
+	struct pcpu_freelist freelist;
 	atomic_t count;	/* number of elements in this hashtable */
 	u32 n_buckets;	/* number of hash buckets */
 	u32 elem_size;	/* size of each element in bytes */
@@ -29,15 +33,111 @@ struct bpf_htab {
 
 /* each htab element is struct htab_elem + key + value */
 struct htab_elem {
-	struct hlist_node hash_node;
-	struct rcu_head rcu;
 	union {
-		u32 hash;
-		u32 key_size;
+		struct hlist_node hash_node;
+		struct bpf_htab *htab;
+		struct pcpu_freelist_node fnode;
 	};
+	struct rcu_head rcu;
+	u32 hash;
 	char key[0] __aligned(8);
 };
 
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
+static struct htab_elem *get_htab_elem(struct bpf_htab *htab, int i)
+{
+	return (struct htab_elem *) (htab->elems + i * htab->elem_size);
+}
+
+static void htab_free_elems(struct bpf_htab *htab)
+{
+	int i;
+
+	if (htab->map.map_type != BPF_MAP_TYPE_PERCPU_HASH)
+		goto free_elems;
+
+	for (i = 0; i < htab->map.max_entries; i++) {
+		void __percpu *pptr;
+
+		pptr = htab_elem_get_ptr(get_htab_elem(htab, i),
+					 htab->map.key_size);
+		free_percpu(pptr);
+	}
+free_elems:
+	vfree(htab->elems);
+}
+
+/* if requested map size is larger than memlock limit, reject it early */
+static int precharge_memlock(u32 pages)
+{
+	struct user_struct *user = get_current_user();
+	unsigned long memlock_limit, cur;
+
+	memlock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	cur = atomic_long_read(&user->locked_vm);
+	free_uid(user);
+	if (cur + pages > memlock_limit)
+		return -EPERM;
+	return 0;
+}
+
+static int prealloc_elems_and_freelist(struct bpf_htab *htab)
+{
+	int err = -ENOMEM, i, cpu, pcpu_entries;
+
+	htab->elems = vzalloc(htab->elem_size * htab->map.max_entries);
+	if (!htab->elems)
+		return -ENOMEM;
+
+	if (htab->map.map_type != BPF_MAP_TYPE_PERCPU_HASH)
+		goto skip_percpu_elems;
+
+	for (i = 0; i < htab->map.max_entries; i++) {
+		u32 size = round_up(htab->map.value_size, 8);
+		void __percpu *pptr;
+
+		pptr = __alloc_percpu_gfp(size, 8, GFP_USER | __GFP_NOWARN);
+		if (!pptr)
+			goto free_elems;
+		htab_elem_set_ptr(get_htab_elem(htab, i), htab->map.key_size,
+				  pptr);
+	}
+
+skip_percpu_elems:
+	err = pcpu_freelist_init(&htab->freelist);
+	if (err)
+		goto free_elems;
+
+	pcpu_entries = htab->map.max_entries / num_possible_cpus() + 1;
+	i = 0;
+	for_each_possible_cpu(cpu) {
+		struct htab_elem *elem;
+again:
+		elem = get_htab_elem(htab, i);
+		pcpu_freelist_push_cpu(&htab->freelist, &elem->fnode, cpu);
+		i++;
+		if (i == htab->map.max_entries)
+			break;
+		if (i % pcpu_entries)
+			goto again;
+	}
+	return 0;
+
+free_elems:
+	htab_free_elems(htab);
+	return err;
+}
+
 /* Called from syscall */
 static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 {
@@ -46,6 +146,10 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	int err, i;
 	u64 cost;
 
+	if (attr->map_flags & ~BPF_F_NO_PREALLOC)
+		/* reserved bits should not be used */
+		return ERR_PTR(-EINVAL);
+
 	htab = kzalloc(sizeof(*htab), GFP_USER);
 	if (!htab)
 		return ERR_PTR(-ENOMEM);
@@ -55,6 +159,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	htab->map.key_size = attr->key_size;
 	htab->map.value_size = attr->value_size;
 	htab->map.max_entries = attr->max_entries;
+	htab->map.map_flags = attr->map_flags;
 
 	/* check sanity of attributes.
 	 * value_size == 0 may be allowed in the future to use map as a set
@@ -92,7 +197,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	if (percpu)
 		htab->elem_size += sizeof(void *);
 	else
-		htab->elem_size += htab->map.value_size;
+		htab->elem_size += round_up(htab->map.value_size, 8);
 
 	/* prevent zero size kmalloc and check for u32 overflow */
 	if (htab->n_buckets == 0 ||
@@ -112,6 +217,10 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 
 	htab->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
 
+	err = precharge_memlock(htab->map.pages);
+	if (err)
+		goto free_htab;
+
 	err = -ENOMEM;
 	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct bucket),
 				      GFP_USER | __GFP_NOWARN);
@@ -127,10 +236,16 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		raw_spin_lock_init(&htab->buckets[i].lock);
 	}
 
-	atomic_set(&htab->count, 0);
+	if (!(attr->map_flags & BPF_F_NO_PREALLOC)) {
+		err = prealloc_elems_and_freelist(htab);
+		if (err)
+			goto free_buckets;
+	}
 
 	return &htab->map;
 
+free_buckets:
+	kvfree(htab->buckets);
 free_htab:
 	kfree(htab);
 	return ERR_PTR(err);
@@ -249,42 +364,42 @@ find_first_elem:
 		}
 	}
 
-	/* itereated over all buckets and all elements */
+	/* iterated over all buckets and all elements */
 	return -ENOENT;
 }
 
-
-static inline void htab_elem_set_ptr(struct htab_elem *l, u32 key_size,
-				     void __percpu *pptr)
-{
-	*(void __percpu **)(l->key + key_size) = pptr;
-}
-
-static inline void __percpu *htab_elem_get_ptr(struct htab_elem *l, u32 key_size)
+static void htab_elem_free(struct bpf_htab *htab, struct htab_elem *l)
 {
-	return *(void __percpu **)(l->key + key_size);
-}
-
-static void htab_percpu_elem_free(struct htab_elem *l)
-{
-	free_percpu(htab_elem_get_ptr(l, l->key_size));
+	if (htab->map.map_type == BPF_MAP_TYPE_PERCPU_HASH)
+		free_percpu(htab_elem_get_ptr(l, htab->map.key_size));
 	kfree(l);
+
 }
 
-static void htab_percpu_elem_free_rcu(struct rcu_head *head)
+static void htab_elem_free_rcu(struct rcu_head *head)
 {
 	struct htab_elem *l = container_of(head, struct htab_elem, rcu);
+	struct bpf_htab *htab = l->htab;
 
-	htab_percpu_elem_free(l);
+	/* must increment bpf_prog_active to avoid kprobe+bpf triggering while
+	 * we're calling kfree, otherwise deadlock is possible if kprobes
+	 * are placed somewhere inside of slub
+	 */
+	preempt_disable();
+	__this_cpu_inc(bpf_prog_active);
+	htab_elem_free(htab, l);
+	__this_cpu_dec(bpf_prog_active);
+	preempt_enable();
 }
 
-static void free_htab_elem(struct htab_elem *l, bool percpu, u32 key_size)
+static void free_htab_elem(struct bpf_htab *htab, struct htab_elem *l)
 {
-	if (percpu) {
-		l->key_size = key_size;
-		call_rcu(&l->rcu, htab_percpu_elem_free_rcu);
+	if (!(htab->map.map_flags & BPF_F_NO_PREALLOC)) {
+		pcpu_freelist_push(&htab->freelist, &l->fnode);
 	} else {
-		kfree_rcu(l, rcu);
+		atomic_dec(&htab->count);
+		l->htab = htab;
+		call_rcu(&l->rcu, htab_elem_free_rcu);
 	}
 }
 
@@ -293,23 +408,39 @@ static struct htab_elem *alloc_htab_elem(struct bpf_htab *htab, void *key,
 					 bool percpu, bool onallcpus)
 {
 	u32 size = htab->map.value_size;
+	bool prealloc = !(htab->map.map_flags & BPF_F_NO_PREALLOC);
 	struct htab_elem *l_new;
 	void __percpu *pptr;
 
-	l_new = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
-	if (!l_new)
-		return NULL;
+	if (prealloc) {
+		l_new = (struct htab_elem *)pcpu_freelist_pop(&htab->freelist);
+		if (!l_new)
+			return ERR_PTR(-E2BIG);
+	} else {
+		if (atomic_inc_return(&htab->count) > htab->map.max_entries) {
+			atomic_dec(&htab->count);
+			return ERR_PTR(-E2BIG);
+		}
+		l_new = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
+		if (!l_new)
+			return ERR_PTR(-ENOMEM);
+	}
 
 	memcpy(l_new->key, key, key_size);
 	if (percpu) {
 		/* round up value_size to 8 bytes */
 		size = round_up(size, 8);
 
-		/* alloc_percpu zero-fills */
-		pptr = __alloc_percpu_gfp(size, 8, GFP_ATOMIC | __GFP_NOWARN);
-		if (!pptr) {
-			kfree(l_new);
-			return NULL;
+		if (prealloc) {
+			pptr = htab_elem_get_ptr(l_new, key_size);
+		} else {
+			/* alloc_percpu zero-fills */
+			pptr = __alloc_percpu_gfp(size, 8,
+						  GFP_ATOMIC | __GFP_NOWARN);
+			if (!pptr) {
+				kfree(l_new);
+				return ERR_PTR(-ENOMEM);
+			}
 		}
 
 		if (!onallcpus) {
@@ -324,7 +455,8 @@ static struct htab_elem *alloc_htab_elem(struct bpf_htab *htab, void *key,
 				off += size;
 			}
 		}
-		htab_elem_set_ptr(l_new, key_size, pptr);
+		if (!prealloc)
+			htab_elem_set_ptr(l_new, key_size, pptr);
 	} else {
 		memcpy(l_new->key + round_up(key_size, 8), value, size);
 	}
@@ -336,12 +468,6 @@ static struct htab_elem *alloc_htab_elem(struct bpf_htab *htab, void *key,
 static int check_flags(struct bpf_htab *htab, struct htab_elem *l_old,
 		       u64 map_flags)
 {
-	if (!l_old && unlikely(atomic_read(&htab->count) >= htab->map.max_entries))
-		/* if elem with this 'key' doesn't exist and we've reached
-		 * max_entries limit, fail insertion of new elem
-		 */
-		return -E2BIG;
-
 	if (l_old && map_flags == BPF_NOEXIST)
 		/* elem already exists */
 		return -EEXIST;
@@ -375,13 +501,6 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 
 	hash = htab_map_hash(key, key_size);
 
-	/* allocate new element outside of the lock, since
-	 * we're most likley going to insert it
-	 */
-	l_new = alloc_htab_elem(htab, key, value, key_size, hash, false, false);
-	if (!l_new)
-		return -ENOMEM;
-
 	b = __select_bucket(htab, hash);
 	head = &b->head;
 
@@ -394,21 +513,24 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	if (ret)
 		goto err;
 
+	l_new = alloc_htab_elem(htab, key, value, key_size, hash, false, false);
+	if (IS_ERR(l_new)) {
+		/* all pre-allocated elements are in use or memory exhausted */
+		ret = PTR_ERR(l_new);
+		goto err;
+	}
+
 	/* add new element to the head of the list, so that
 	 * concurrent search will find it before old elem
 	 */
 	hlist_add_head_rcu(&l_new->hash_node, head);
 	if (l_old) {
 		hlist_del_rcu(&l_old->hash_node);
-		kfree_rcu(l_old, rcu);
-	} else {
-		atomic_inc(&htab->count);
+		free_htab_elem(htab, l_old);
 	}
-	raw_spin_unlock_irqrestore(&b->lock, flags);
-	return 0;
+	ret = 0;
 err:
 	raw_spin_unlock_irqrestore(&b->lock, flags);
-	kfree(l_new);
 	return ret;
 }
 
@@ -466,12 +588,11 @@ static int __htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 	} else {
 		l_new = alloc_htab_elem(htab, key, value, key_size,
 					hash, true, onallcpus);
-		if (!l_new) {
-			ret = -ENOMEM;
+		if (IS_ERR(l_new)) {
+			ret = PTR_ERR(l_new);
 			goto err;
 		}
 		hlist_add_head_rcu(&l_new->hash_node, head);
-		atomic_inc(&htab->count);
 	}
 	ret = 0;
 err:
@@ -489,7 +610,6 @@ static int htab_percpu_map_update_elem(struct bpf_map *map, void *key,
 static int htab_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
-	bool percpu = map->map_type == BPF_MAP_TYPE_PERCPU_HASH;
 	struct hlist_head *head;
 	struct bucket *b;
 	struct htab_elem *l;
@@ -511,8 +631,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 
 	if (l) {
 		hlist_del_rcu(&l->hash_node);
-		atomic_dec(&htab->count);
-		free_htab_elem(l, percpu, key_size);
+		free_htab_elem(htab, l);
 		ret = 0;
 	}
 
@@ -531,17 +650,10 @@ static void delete_all_elements(struct bpf_htab *htab)
 
 		hlist_for_each_entry_safe(l, n, head, hash_node) {
 			hlist_del_rcu(&l->hash_node);
-			atomic_dec(&htab->count);
-			if (htab->map.map_type == BPF_MAP_TYPE_PERCPU_HASH) {
-				l->key_size = htab->map.key_size;
-				htab_percpu_elem_free(l);
-			} else {
-				kfree(l);
-			}
+			htab_elem_free(htab, l);
 		}
 	}
 }
-
 /* Called when map->refcnt goes to zero, either from workqueue or from syscall */
 static void htab_map_free(struct bpf_map *map)
 {
@@ -554,10 +666,16 @@ static void htab_map_free(struct bpf_map *map)
 	 */
 	synchronize_rcu();
 
-	/* some of kfree_rcu() callbacks for elements of this map may not have
-	 * executed. It's ok. Proceed to free residual elements and map itself
+	/* some of free_htab_elem() callbacks for elements of this map may
+	 * not have executed. Wait for them.
 	 */
-	delete_all_elements(htab);
+	rcu_barrier();
+	if (htab->map.map_flags & BPF_F_NO_PREALLOC) {
+		delete_all_elements(htab);
+	} else {
+		htab_free_elems(htab);
+		pcpu_freelist_destroy(&htab->freelist);
+	}
 	kvfree(htab->buckets);
 	kfree(htab);
 }
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index dc99f6a000f5..1e7dfae0de8c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -153,7 +153,7 @@ int bpf_map_new_fd(struct bpf_map *map)
 		   offsetof(union bpf_attr, CMD##_LAST_FIELD) - \
 		   sizeof(attr->CMD##_LAST_FIELD)) != NULL
 
-#define BPF_MAP_CREATE_LAST_FIELD max_entries
+#define BPF_MAP_CREATE_LAST_FIELD map_flags
 /* called via syscall */
 static int map_create(union bpf_attr *attr)
 {
-- 
2.6.5
