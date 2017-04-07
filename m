From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 2/2] bpf: remove struct bpf_map_type_list
Date: Fri,  7 Apr 2017 21:00:08 +0200
Message-ID: <20170407190008.32632-2-johannes@sipsolutions.net>
References: <20170407190008.32632-1-johannes@sipsolutions.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51626 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933633AbdDGTAS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:00:18 -0400
In-Reply-To: <20170407190008.32632-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There's no need to have struct bpf_map_type_list since
it just contains a list_head, the type, and the ops
pointer. Since the types are densely packed and not
actually dynamically registered, it's much easier and
smaller to have an array of type->ops pointer. Also
initialize this array statically to remove code needed
to initialize it.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/bpf.h   | 18 +++++++++------
 kernel/bpf/arraymap.c | 64 ++++-----------------------------------------------
 kernel/bpf/hashtab.c  | 38 ++++--------------------------
 kernel/bpf/lpm_trie.c | 14 +----------
 kernel/bpf/stackmap.c | 14 +----------
 kernel/bpf/syscall.c  | 42 ++++++++++++++++++---------------
 6 files changed, 46 insertions(+), 144 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 75cea2890751..4a95a25186e5 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -51,12 +51,6 @@ struct bpf_map {
 	atomic_t usercnt;
 };
 
-struct bpf_map_type_list {
-	struct list_head list_node;
-	const struct bpf_map_ops *ops;
-	enum bpf_map_type type;
-};
-
 /* function argument constraints */
 enum bpf_arg_type {
 	ARG_DONTCARE = 0,	/* unused argument in helper function */
@@ -239,7 +233,17 @@ extern const struct bpf_verifier_ops kprobe_prog_ops;
 extern const struct bpf_verifier_ops tracepoint_prog_ops;
 extern const struct bpf_verifier_ops perf_event_prog_ops;
 
-void bpf_register_map_type(struct bpf_map_type_list *tl);
+extern const struct bpf_map_ops array_map_ops;
+extern const struct bpf_map_ops percpu_array_map_ops;
+extern const struct bpf_map_ops prog_array_map_ops;
+extern const struct bpf_map_ops perf_event_array_map_ops;
+extern const struct bpf_map_ops cgroup_array_map_ops;
+extern const struct bpf_map_ops htab_map_ops;
+extern const struct bpf_map_ops htab_lru_map_ops;
+extern const struct bpf_map_ops htab_percpu_map_ops;
+extern const struct bpf_map_ops htab_lru_percpu_map_ops;
+extern const struct bpf_map_ops trie_map_ops;
+extern const struct bpf_map_ops stack_map_ops;
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 6b6f41f0b211..376afd14cf32 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -260,7 +260,7 @@ static void array_map_free(struct bpf_map *map)
 	bpf_map_area_free(array);
 }
 
-static const struct bpf_map_ops array_ops = {
+const struct bpf_map_ops array_map_ops = {
 	.map_alloc = array_map_alloc,
 	.map_free = array_map_free,
 	.map_get_next_key = array_map_get_next_key,
@@ -269,12 +269,7 @@ static const struct bpf_map_ops array_ops = {
 	.map_delete_elem = array_map_delete_elem,
 };
 
-static struct bpf_map_type_list array_type __ro_after_init = {
-	.ops = &array_ops,
-	.type = BPF_MAP_TYPE_ARRAY,
-};
-
-static const struct bpf_map_ops percpu_array_ops = {
+const struct bpf_map_ops percpu_array_map_ops = {
 	.map_alloc = array_map_alloc,
 	.map_free = array_map_free,
 	.map_get_next_key = array_map_get_next_key,
@@ -283,19 +278,6 @@ static const struct bpf_map_ops percpu_array_ops = {
 	.map_delete_elem = array_map_delete_elem,
 };
 
-static struct bpf_map_type_list percpu_array_type __ro_after_init = {
-	.ops = &percpu_array_ops,
-	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
-};
-
-static int __init register_array_map(void)
-{
-	bpf_register_map_type(&array_type);
-	bpf_register_map_type(&percpu_array_type);
-	return 0;
-}
-late_initcall(register_array_map);
-
 static struct bpf_map *fd_array_map_alloc(union bpf_attr *attr)
 {
 	/* only file descriptors can be stored in this type of map */
@@ -399,7 +381,7 @@ void bpf_fd_array_map_clear(struct bpf_map *map)
 		fd_array_map_delete_elem(map, &i);
 }
 
-static const struct bpf_map_ops prog_array_ops = {
+const struct bpf_map_ops prog_array_map_ops = {
 	.map_alloc = fd_array_map_alloc,
 	.map_free = fd_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
@@ -409,18 +391,6 @@ static const struct bpf_map_ops prog_array_ops = {
 	.map_fd_put_ptr = prog_fd_array_put_ptr,
 };
 
-static struct bpf_map_type_list prog_array_type __ro_after_init = {
-	.ops = &prog_array_ops,
-	.type = BPF_MAP_TYPE_PROG_ARRAY,
-};
-
-static int __init register_prog_array_map(void)
-{
-	bpf_register_map_type(&prog_array_type);
-	return 0;
-}
-late_initcall(register_prog_array_map);
-
 static struct bpf_event_entry *bpf_event_entry_gen(struct file *perf_file,
 						   struct file *map_file)
 {
@@ -511,7 +481,7 @@ static void perf_event_fd_array_release(struct bpf_map *map,
 	rcu_read_unlock();
 }
 
-static const struct bpf_map_ops perf_event_array_ops = {
+const struct bpf_map_ops perf_event_array_map_ops = {
 	.map_alloc = fd_array_map_alloc,
 	.map_free = fd_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
@@ -522,18 +492,6 @@ static const struct bpf_map_ops perf_event_array_ops = {
 	.map_release = perf_event_fd_array_release,
 };
 
-static struct bpf_map_type_list perf_event_array_type __ro_after_init = {
-	.ops = &perf_event_array_ops,
-	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
-};
-
-static int __init register_perf_event_array_map(void)
-{
-	bpf_register_map_type(&perf_event_array_type);
-	return 0;
-}
-late_initcall(register_perf_event_array_map);
-
 #ifdef CONFIG_CGROUPS
 static void *cgroup_fd_array_get_ptr(struct bpf_map *map,
 				     struct file *map_file /* not used */,
@@ -554,7 +512,7 @@ static void cgroup_fd_array_free(struct bpf_map *map)
 	fd_array_map_free(map);
 }
 
-static const struct bpf_map_ops cgroup_array_ops = {
+const struct bpf_map_ops cgroup_array_map_ops = {
 	.map_alloc = fd_array_map_alloc,
 	.map_free = cgroup_fd_array_free,
 	.map_get_next_key = array_map_get_next_key,
@@ -563,16 +521,4 @@ static const struct bpf_map_ops cgroup_array_ops = {
 	.map_fd_get_ptr = cgroup_fd_array_get_ptr,
 	.map_fd_put_ptr = cgroup_fd_array_put_ptr,
 };
-
-static struct bpf_map_type_list cgroup_array_type __ro_after_init = {
-	.ops = &cgroup_array_ops,
-	.type = BPF_MAP_TYPE_CGROUP_ARRAY,
-};
-
-static int __init register_cgroup_array_map(void)
-{
-	bpf_register_map_type(&cgroup_array_type);
-	return 0;
-}
-late_initcall(register_cgroup_array_map);
 #endif
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 3ea87fb19a94..c7913d2aa8ba 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -1014,7 +1014,7 @@ static void htab_map_free(struct bpf_map *map)
 	kfree(htab);
 }
 
-static const struct bpf_map_ops htab_ops = {
+const struct bpf_map_ops htab_map_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
 	.map_get_next_key = htab_map_get_next_key,
@@ -1023,12 +1023,7 @@ static const struct bpf_map_ops htab_ops = {
 	.map_delete_elem = htab_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_type __ro_after_init = {
-	.ops = &htab_ops,
-	.type = BPF_MAP_TYPE_HASH,
-};
-
-static const struct bpf_map_ops htab_lru_ops = {
+const struct bpf_map_ops htab_lru_map_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
 	.map_get_next_key = htab_map_get_next_key,
@@ -1037,11 +1032,6 @@ static const struct bpf_map_ops htab_lru_ops = {
 	.map_delete_elem = htab_lru_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_lru_type __ro_after_init = {
-	.ops = &htab_lru_ops,
-	.type = BPF_MAP_TYPE_LRU_HASH,
-};
-
 /* Called from eBPF program */
 static void *htab_percpu_map_lookup_elem(struct bpf_map *map, void *key)
 {
@@ -1115,7 +1105,7 @@ int bpf_percpu_hash_update(struct bpf_map *map, void *key, void *value,
 	return ret;
 }
 
-static const struct bpf_map_ops htab_percpu_ops = {
+const struct bpf_map_ops htab_percpu_map_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
 	.map_get_next_key = htab_map_get_next_key,
@@ -1124,12 +1114,7 @@ static const struct bpf_map_ops htab_percpu_ops = {
 	.map_delete_elem = htab_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_percpu_type __ro_after_init = {
-	.ops = &htab_percpu_ops,
-	.type = BPF_MAP_TYPE_PERCPU_HASH,
-};
-
-static const struct bpf_map_ops htab_lru_percpu_ops = {
+const struct bpf_map_ops htab_lru_percpu_map_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
 	.map_get_next_key = htab_map_get_next_key,
@@ -1137,18 +1122,3 @@ static const struct bpf_map_ops htab_lru_percpu_ops = {
 	.map_update_elem = htab_lru_percpu_map_update_elem,
 	.map_delete_elem = htab_lru_map_delete_elem,
 };
-
-static struct bpf_map_type_list htab_lru_percpu_type __ro_after_init = {
-	.ops = &htab_lru_percpu_ops,
-	.type = BPF_MAP_TYPE_LRU_PERCPU_HASH,
-};
-
-static int __init register_htab_map(void)
-{
-	bpf_register_map_type(&htab_type);
-	bpf_register_map_type(&htab_percpu_type);
-	bpf_register_map_type(&htab_lru_type);
-	bpf_register_map_type(&htab_lru_percpu_type);
-	return 0;
-}
-late_initcall(register_htab_map);
diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 8bfe0afaee10..352ae2a2830a 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -500,22 +500,10 @@ static void trie_free(struct bpf_map *map)
 	raw_spin_unlock(&trie->lock);
 }
 
-static const struct bpf_map_ops trie_ops = {
+const struct bpf_map_ops trie_map_ops = {
 	.map_alloc = trie_alloc,
 	.map_free = trie_free,
 	.map_lookup_elem = trie_lookup_elem,
 	.map_update_elem = trie_update_elem,
 	.map_delete_elem = trie_delete_elem,
 };
-
-static struct bpf_map_type_list trie_type __ro_after_init = {
-	.ops = &trie_ops,
-	.type = BPF_MAP_TYPE_LPM_TRIE,
-};
-
-static int __init register_trie_map(void)
-{
-	bpf_register_map_type(&trie_type);
-	return 0;
-}
-late_initcall(register_trie_map);
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 22aa45cd0324..4dfd6f2ec2f9 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -264,7 +264,7 @@ static void stack_map_free(struct bpf_map *map)
 	put_callchain_buffers();
 }
 
-static const struct bpf_map_ops stack_map_ops = {
+const struct bpf_map_ops stack_map_ops = {
 	.map_alloc = stack_map_alloc,
 	.map_free = stack_map_free,
 	.map_get_next_key = stack_map_get_next_key,
@@ -272,15 +272,3 @@ static const struct bpf_map_ops stack_map_ops = {
 	.map_update_elem = stack_map_update_elem,
 	.map_delete_elem = stack_map_delete_elem,
 };
-
-static struct bpf_map_type_list stack_map_type __ro_after_init = {
-	.ops = &stack_map_ops,
-	.type = BPF_MAP_TYPE_STACK_TRACE,
-};
-
-static int __init register_stack_map(void)
-{
-	bpf_register_map_type(&stack_map_type);
-	return 0;
-}
-late_initcall(register_stack_map);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 421aa81ef5d4..c0c02667e641 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -27,30 +27,36 @@ DEFINE_PER_CPU(int, bpf_prog_active);
 
 int sysctl_unprivileged_bpf_disabled __read_mostly;
 
-static LIST_HEAD(bpf_map_types);
+static const struct bpf_map_ops * const bpf_map_types[] = {
+	[BPF_MAP_TYPE_ARRAY] = &array_map_ops,
+	[BPF_MAP_TYPE_PERCPU_ARRAY] = &percpu_array_map_ops,
+	[BPF_MAP_TYPE_PROG_ARRAY] = &prog_array_map_ops,
+	[BPF_MAP_TYPE_PERF_EVENT_ARRAY] = &perf_event_array_map_ops,
+#ifdef CONFIG_CGROUPS
+	[BPF_MAP_TYPE_CGROUP_ARRAY] = &cgroup_array_map_ops,
+#endif
+	[BPF_MAP_TYPE_HASH] = &htab_map_ops,
+	[BPF_MAP_TYPE_PERCPU_HASH] = &htab_percpu_map_ops,
+	[BPF_MAP_TYPE_LRU_HASH] = &htab_lru_map_ops,
+	[BPF_MAP_TYPE_LRU_PERCPU_HASH] = &htab_lru_percpu_map_ops,
+	[BPF_MAP_TYPE_LPM_TRIE] = &trie_map_ops,
+	[BPF_MAP_TYPE_STACK_TRACE] = &stack_map_ops,
+};
 
 static struct bpf_map *find_and_alloc_map(union bpf_attr *attr)
 {
-	struct bpf_map_type_list *tl;
 	struct bpf_map *map;
 
-	list_for_each_entry(tl, &bpf_map_types, list_node) {
-		if (tl->type == attr->map_type) {
-			map = tl->ops->map_alloc(attr);
-			if (IS_ERR(map))
-				return map;
-			map->ops = tl->ops;
-			map->map_type = attr->map_type;
-			return map;
-		}
-	}
-	return ERR_PTR(-EINVAL);
-}
+	if (attr->map_type >= ARRAY_SIZE(bpf_map_types) ||
+	    !bpf_map_types[attr->map_type])
+		return ERR_PTR(-EINVAL);
 
-/* boot time registration of different map implementations */
-void bpf_register_map_type(struct bpf_map_type_list *tl)
-{
-	list_add(&tl->list_node, &bpf_map_types);
+	map = bpf_map_types[attr->map_type]->map_alloc(attr);
+	if (IS_ERR(map))
+		return map;
+	map->ops = bpf_map_types[attr->map_type];
+	map->map_type = attr->map_type;
+	return map;
 }
 
 void *bpf_map_area_alloc(size_t size)
-- 
2.11.0
