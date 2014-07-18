From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v2 net-next 08/16] bpf: add hashtable type of BPF maps
Date: Thu, 17 Jul 2014 21:19:58 -0700
Message-ID: <1405657206-12060-9-git-send-email-ast@plumgrid.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add new map type: BPF_MAP_TYPE_HASH
and its simple (not auto resizeable) hash table implementation

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/bpf/Makefile      |    2 +-
 kernel/bpf/hashtab.c     |  371 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 373 insertions(+), 1 deletion(-)
 create mode 100644 kernel/bpf/hashtab.c

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 5e1bfbc9cdc7..3ea11ba053a8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -347,6 +347,7 @@ enum bpf_map_attributes {
 
 enum bpf_map_type {
 	BPF_MAP_TYPE_UNSPEC,
+	BPF_MAP_TYPE_HASH,
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index e9f7334ed07a..558e12712ebc 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1 +1 @@
-obj-y := core.o syscall.o
+obj-y := core.o syscall.o hashtab.o
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
new file mode 100644
index 000000000000..6e481cacbba3
--- /dev/null
+++ b/kernel/bpf/hashtab.c
@@ -0,0 +1,371 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+#include <linux/bpf.h>
+#include <net/netlink.h>
+#include <linux/jhash.h>
+
+struct bpf_htab {
+	struct bpf_map map;
+	struct hlist_head *buckets;
+	struct kmem_cache *elem_cache;
+	char *slab_name;
+	spinlock_t lock;
+	u32 count; /* number of elements in this hashtable */
+	u32 n_buckets; /* number of hash buckets */
+	u32 elem_size; /* size of each element in bytes */
+};
+
+/* each htab element is struct htab_elem + key + value */
+struct htab_elem {
+	struct hlist_node hash_node;
+	struct rcu_head rcu;
+	struct bpf_htab *htab;
+	u32 hash;
+	u32 pad;
+	char key[0];
+};
+
+#define HASH_MAX_BUCKETS 1024
+#define BPF_MAP_MAX_KEY_SIZE 256
+static struct bpf_map *htab_map_alloc(struct nlattr *attr[BPF_MAP_ATTR_MAX + 1])
+{
+	struct bpf_htab *htab;
+	int err, i;
+
+	htab = kmalloc(sizeof(*htab), GFP_USER);
+	if (!htab)
+		return ERR_PTR(-ENOMEM);
+
+	/* look for mandatory map attributes */
+	err = -EINVAL;
+	if (!attr[BPF_MAP_KEY_SIZE])
+		goto free_htab;
+	htab->map.key_size = nla_get_u32(attr[BPF_MAP_KEY_SIZE]);
+
+	if (!attr[BPF_MAP_VALUE_SIZE])
+		goto free_htab;
+	htab->map.value_size = nla_get_u32(attr[BPF_MAP_VALUE_SIZE]);
+
+	if (!attr[BPF_MAP_MAX_ENTRIES])
+		goto free_htab;
+	htab->map.max_entries = nla_get_u32(attr[BPF_MAP_MAX_ENTRIES]);
+
+	htab->n_buckets = (htab->map.max_entries <= HASH_MAX_BUCKETS) ?
+			  htab->map.max_entries : HASH_MAX_BUCKETS;
+
+	/* hash table size must be power of 2 */
+	if ((htab->n_buckets & (htab->n_buckets - 1)) != 0)
+		goto free_htab;
+
+	err = -E2BIG;
+	if (htab->map.key_size > BPF_MAP_MAX_KEY_SIZE)
+		goto free_htab;
+
+	err = -ENOMEM;
+	htab->buckets = kmalloc(htab->n_buckets * sizeof(struct hlist_head),
+				GFP_USER);
+
+	if (!htab->buckets)
+		goto free_htab;
+
+	for (i = 0; i < htab->n_buckets; i++)
+		INIT_HLIST_HEAD(&htab->buckets[i]);
+
+	spin_lock_init(&htab->lock);
+	htab->count = 0;
+
+	htab->elem_size = sizeof(struct htab_elem) +
+			  round_up(htab->map.key_size, 8) +
+			  htab->map.value_size;
+
+	htab->slab_name = kasprintf(GFP_USER, "bpf_htab_%p", htab);
+	if (!htab->slab_name)
+		goto free_buckets;
+
+	htab->elem_cache = kmem_cache_create(htab->slab_name,
+					     htab->elem_size, 0, 0, NULL);
+	if (!htab->elem_cache)
+		goto free_slab_name;
+
+	return &htab->map;
+
+free_slab_name:
+	kfree(htab->slab_name);
+free_buckets:
+	kfree(htab->buckets);
+free_htab:
+	kfree(htab);
+	return ERR_PTR(err);
+}
+
+static inline u32 htab_map_hash(const void *key, u32 key_len)
+{
+	return jhash(key, key_len, 0);
+}
+
+static inline struct hlist_head *select_bucket(struct bpf_htab *htab, u32 hash)
+{
+	return &htab->buckets[hash & (htab->n_buckets - 1)];
+}
+
+static struct htab_elem *lookup_elem_raw(struct hlist_head *head, u32 hash,
+					 void *key, u32 key_size)
+{
+	struct htab_elem *l;
+
+	hlist_for_each_entry_rcu(l, head, hash_node) {
+		if (l->hash == hash && !memcmp(&l->key, key, key_size))
+			return l;
+	}
+	return NULL;
+}
+
+/* Must be called with rcu_read_lock. */
+static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct hlist_head *head;
+	struct htab_elem *l;
+	u32 hash, key_size;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	key_size = map->key_size;
+
+	hash = htab_map_hash(key, key_size);
+
+	head = select_bucket(htab, hash);
+
+	l = lookup_elem_raw(head, hash, key, key_size);
+
+	if (l)
+		return l->key + round_up(map->key_size, 8);
+	else
+		return NULL;
+}
+
+/* Must be called with rcu_read_lock. */
+static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct hlist_head *head;
+	struct htab_elem *l, *next_l;
+	u32 hash, key_size;
+	int i;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	key_size = map->key_size;
+
+	hash = htab_map_hash(key, key_size);
+
+	head = select_bucket(htab, hash);
+
+	/* lookup the key */
+	l = lookup_elem_raw(head, hash, key, key_size);
+
+	if (!l) {
+		i = 0;
+		goto find_first_elem;
+	}
+
+	/* key was found, get next key in the same bucket */
+	next_l = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu(&l->hash_node)),
+				  struct htab_elem, hash_node);
+
+	if (next_l) {
+		/* if next elem in this hash list is non-zero, just return it */
+		memcpy(next_key, next_l->key, key_size);
+		return 0;
+	} else {
+		/* no more elements in this hash list, go to the next bucket */
+		i = hash & (htab->n_buckets - 1);
+		i++;
+	}
+
+find_first_elem:
+	/* iterate over buckets */
+	for (; i < htab->n_buckets; i++) {
+		head = select_bucket(htab, i);
+
+		/* pick first element in the bucket */
+		next_l = hlist_entry_safe(rcu_dereference_raw(hlist_first_rcu(head)),
+					  struct htab_elem, hash_node);
+		if (next_l) {
+			/* if it's not empty, just return it */
+			memcpy(next_key, next_l->key, key_size);
+			return 0;
+		}
+	}
+
+	/* itereated over all buckets and all elements */
+	return -ENOENT;
+}
+
+static struct htab_elem *htab_alloc_elem(struct bpf_htab *htab)
+{
+	void *l;
+
+	l = kmem_cache_alloc(htab->elem_cache, GFP_ATOMIC);
+	if (!l)
+		return ERR_PTR(-ENOMEM);
+	return l;
+}
+
+static void free_htab_elem_rcu(struct rcu_head *rcu)
+{
+	struct htab_elem *l = container_of(rcu, struct htab_elem, rcu);
+
+	kmem_cache_free(l->htab->elem_cache, l);
+}
+
+static void release_htab_elem(struct bpf_htab *htab, struct htab_elem *l)
+{
+	l->htab = htab;
+	call_rcu(&l->rcu, free_htab_elem_rcu);
+}
+
+/* Must be called with rcu_read_lock. */
+static int htab_map_update_elem(struct bpf_map *map, void *key, void *value)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct htab_elem *l_new, *l_old;
+	struct hlist_head *head;
+	u32 key_size;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	l_new = htab_alloc_elem(htab);
+	if (IS_ERR(l_new))
+		return -ENOMEM;
+
+	key_size = map->key_size;
+
+	memcpy(l_new->key, key, key_size);
+	memcpy(l_new->key + round_up(key_size, 8), value, map->value_size);
+
+	l_new->hash = htab_map_hash(l_new->key, key_size);
+
+	head = select_bucket(htab, l_new->hash);
+
+	l_old = lookup_elem_raw(head, l_new->hash, key, key_size);
+
+	spin_lock_bh(&htab->lock);
+	if (!l_old && unlikely(htab->count >= map->max_entries)) {
+		/* if elem with this 'key' doesn't exist and we've reached
+		 * max_entries limit, fail insertion of new elem
+		 */
+		spin_unlock_bh(&htab->lock);
+		kmem_cache_free(htab->elem_cache, l_new);
+		return -EFBIG;
+	}
+
+	/* add new element to the head of the list, so that concurrent
+	 * search will find it before old elem
+	 */
+	hlist_add_head_rcu(&l_new->hash_node, head);
+	if (l_old) {
+		hlist_del_rcu(&l_old->hash_node);
+		release_htab_elem(htab, l_old);
+	} else {
+		htab->count++;
+	}
+	spin_unlock_bh(&htab->lock);
+
+	return 0;
+}
+
+/* Must be called with rcu_read_lock. */
+static int htab_map_delete_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct htab_elem *l;
+	struct hlist_head *head;
+	u32 hash, key_size;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	key_size = map->key_size;
+
+	hash = htab_map_hash(key, key_size);
+
+	head = select_bucket(htab, hash);
+
+	l = lookup_elem_raw(head, hash, key, key_size);
+
+	if (l) {
+		spin_lock_bh(&htab->lock);
+		hlist_del_rcu(&l->hash_node);
+		htab->count--;
+		release_htab_elem(htab, l);
+		spin_unlock_bh(&htab->lock);
+		return 0;
+	}
+	return -ESRCH;
+}
+
+static void delete_all_elements(struct bpf_htab *htab)
+{
+	int i;
+
+	for (i = 0; i < htab->n_buckets; i++) {
+		struct hlist_head *head = select_bucket(htab, i);
+		struct hlist_node *n;
+		struct htab_elem *l;
+
+		hlist_for_each_entry_safe(l, n, head, hash_node) {
+			hlist_del_rcu(&l->hash_node);
+			htab->count--;
+			kmem_cache_free(htab->elem_cache, l);
+		}
+	}
+}
+
+/* called when map->refcnt goes to zero */
+static void htab_map_free(struct bpf_map *map)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+
+	/* wait for all outstanding updates to complete */
+	synchronize_rcu();
+
+	/* kmem_cache_free all htab elements */
+	delete_all_elements(htab);
+
+	/* and destroy cache, which might sleep */
+	kmem_cache_destroy(htab->elem_cache);
+
+	kfree(htab->buckets);
+	kfree(htab->slab_name);
+	kfree(htab);
+}
+
+static struct bpf_map_ops htab_ops = {
+	.map_alloc = htab_map_alloc,
+	.map_free = htab_map_free,
+	.map_get_next_key = htab_map_get_next_key,
+	.map_lookup_elem = htab_map_lookup_elem,
+	.map_update_elem = htab_map_update_elem,
+	.map_delete_elem = htab_map_delete_elem,
+};
+
+static struct bpf_map_type_list tl = {
+	.ops = &htab_ops,
+	.type = BPF_MAP_TYPE_HASH,
+};
+
+static int __init register_htab_map(void)
+{
+	bpf_register_map_type(&tl);
+	return 0;
+}
+late_initcall(register_htab_map);
-- 
1.7.9.5
