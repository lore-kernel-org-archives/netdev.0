From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/2] bpf: remove struct bpf_map_type_list
Date: Tue,  4 Apr 2017 19:27:11 +0200
Message-ID: <20170404172711.4088-2-johannes@sipsolutions.net>
References: <20170404172711.4088-1-johannes@sipsolutions.net>
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37818 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754549AbdDDR1V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 13:27:21 -0400
In-Reply-To: <20170404172711.4088-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There's no need to have struct bpf_map_type_list since
it just contains a list_head, the type, and the ops
pointer. Since the types are densely packed and not
actually dynamically registered, it's much easier and
smaller to have an array of type->ops pointer.

This doesn't really change the image size much, but in
the running image it saves a few hundred bytes because
the structs are removed and traded against __init code.

While at it, also mark bpf_register_map_type() __init
since it's only called from code already marked so.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/bpf.h      |  9 ++-------
 include/uapi/linux/bpf.h |  2 ++
 kernel/bpf/arraymap.c    | 36 ++++++------------------------------
 kernel/bpf/hashtab.c     | 29 +++++------------------------
 kernel/bpf/lpm_trie.c    |  7 +------
 kernel/bpf/stackmap.c    |  7 +------
 kernel/bpf/syscall.c     | 33 ++++++++++++++++++---------------
 7 files changed, 35 insertions(+), 88 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 891a76aaccaa..9e0a2dec789a 100644
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
@@ -230,7 +224,8 @@ DECLARE_PER_CPU(int, bpf_prog_active);
 
 void bpf_register_prog_type(enum bpf_prog_type type,
 			    const struct bpf_verifier_ops *ops);
-void bpf_register_map_type(struct bpf_map_type_list *tl);
+void bpf_register_map_type(enum bpf_map_type type,
+			   const struct bpf_map_ops *ops);
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index cc68f5bbf458..53adc7e93062 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -96,6 +96,8 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_LRU_HASH,
 	BPF_MAP_TYPE_LRU_PERCPU_HASH,
 	BPF_MAP_TYPE_LPM_TRIE,
+
+	NUM_BPF_MAP_TYPES,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 6b6f41f0b211..6a3f3aa681de 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -269,11 +269,6 @@ static const struct bpf_map_ops array_ops = {
 	.map_delete_elem = array_map_delete_elem,
 };
 
-static struct bpf_map_type_list array_type __ro_after_init = {
-	.ops = &array_ops,
-	.type = BPF_MAP_TYPE_ARRAY,
-};
-
 static const struct bpf_map_ops percpu_array_ops = {
 	.map_alloc = array_map_alloc,
 	.map_free = array_map_free,
@@ -283,15 +278,10 @@ static const struct bpf_map_ops percpu_array_ops = {
 	.map_delete_elem = array_map_delete_elem,
 };
 
-static struct bpf_map_type_list percpu_array_type __ro_after_init = {
-	.ops = &percpu_array_ops,
-	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
-};
-
 static int __init register_array_map(void)
 {
-	bpf_register_map_type(&array_type);
-	bpf_register_map_type(&percpu_array_type);
+	bpf_register_map_type(BPF_MAP_TYPE_ARRAY, &array_ops);
+	bpf_register_map_type(BPF_MAP_TYPE_PERCPU_ARRAY, &percpu_array_ops);
 	return 0;
 }
 late_initcall(register_array_map);
@@ -409,14 +399,9 @@ static const struct bpf_map_ops prog_array_ops = {
 	.map_fd_put_ptr = prog_fd_array_put_ptr,
 };
 
-static struct bpf_map_type_list prog_array_type __ro_after_init = {
-	.ops = &prog_array_ops,
-	.type = BPF_MAP_TYPE_PROG_ARRAY,
-};
-
 static int __init register_prog_array_map(void)
 {
-	bpf_register_map_type(&prog_array_type);
+	bpf_register_map_type(BPF_MAP_TYPE_PROG_ARRAY, &prog_array_ops);
 	return 0;
 }
 late_initcall(register_prog_array_map);
@@ -522,14 +507,10 @@ static const struct bpf_map_ops perf_event_array_ops = {
 	.map_release = perf_event_fd_array_release,
 };
 
-static struct bpf_map_type_list perf_event_array_type __ro_after_init = {
-	.ops = &perf_event_array_ops,
-	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
-};
-
 static int __init register_perf_event_array_map(void)
 {
-	bpf_register_map_type(&perf_event_array_type);
+	bpf_register_map_type(BPF_MAP_TYPE_PERF_EVENT_ARRAY,
+			      &perf_event_array_ops);
 	return 0;
 }
 late_initcall(register_perf_event_array_map);
@@ -564,14 +545,9 @@ static const struct bpf_map_ops cgroup_array_ops = {
 	.map_fd_put_ptr = cgroup_fd_array_put_ptr,
 };
 
-static struct bpf_map_type_list cgroup_array_type __ro_after_init = {
-	.ops = &cgroup_array_ops,
-	.type = BPF_MAP_TYPE_CGROUP_ARRAY,
-};
-
 static int __init register_cgroup_array_map(void)
 {
-	bpf_register_map_type(&cgroup_array_type);
+	bpf_register_map_type(BPF_MAP_TYPE_CGROUP_ARRAY, &cgroup_array_ops);
 	return 0;
 }
 late_initcall(register_cgroup_array_map);
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 3ea87fb19a94..1101f0983795 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -1023,11 +1023,6 @@ static const struct bpf_map_ops htab_ops = {
 	.map_delete_elem = htab_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_type __ro_after_init = {
-	.ops = &htab_ops,
-	.type = BPF_MAP_TYPE_HASH,
-};
-
 static const struct bpf_map_ops htab_lru_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
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
@@ -1124,11 +1114,6 @@ static const struct bpf_map_ops htab_percpu_ops = {
 	.map_delete_elem = htab_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_percpu_type __ro_after_init = {
-	.ops = &htab_percpu_ops,
-	.type = BPF_MAP_TYPE_PERCPU_HASH,
-};
-
 static const struct bpf_map_ops htab_lru_percpu_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
@@ -1138,17 +1123,13 @@ static const struct bpf_map_ops htab_lru_percpu_ops = {
 	.map_delete_elem = htab_lru_map_delete_elem,
 };
 
-static struct bpf_map_type_list htab_lru_percpu_type __ro_after_init = {
-	.ops = &htab_lru_percpu_ops,
-	.type = BPF_MAP_TYPE_LRU_PERCPU_HASH,
-};
-
 static int __init register_htab_map(void)
 {
-	bpf_register_map_type(&htab_type);
-	bpf_register_map_type(&htab_percpu_type);
-	bpf_register_map_type(&htab_lru_type);
-	bpf_register_map_type(&htab_lru_percpu_type);
+	bpf_register_map_type(BPF_MAP_TYPE_HASH, &htab_ops);
+	bpf_register_map_type(BPF_MAP_TYPE_PERCPU_HASH, &htab_percpu_ops);
+	bpf_register_map_type(BPF_MAP_TYPE_LRU_HASH, &htab_lru_ops);
+	bpf_register_map_type(BPF_MAP_TYPE_LRU_PERCPU_HASH,
+			      &htab_lru_percpu_ops);
 	return 0;
 }
 late_initcall(register_htab_map);
diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 8bfe0afaee10..e5599c0a7737 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -508,14 +508,9 @@ static const struct bpf_map_ops trie_ops = {
 	.map_delete_elem = trie_delete_elem,
 };
 
-static struct bpf_map_type_list trie_type __ro_after_init = {
-	.ops = &trie_ops,
-	.type = BPF_MAP_TYPE_LPM_TRIE,
-};
-
 static int __init register_trie_map(void)
 {
-	bpf_register_map_type(&trie_type);
+	bpf_register_map_type(BPF_MAP_TYPE_LPM_TRIE, &trie_ops);
 	return 0;
 }
 late_initcall(register_trie_map);
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 22aa45cd0324..a99130148d92 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -273,14 +273,9 @@ static const struct bpf_map_ops stack_map_ops = {
 	.map_delete_elem = stack_map_delete_elem,
 };
 
-static struct bpf_map_type_list stack_map_type __ro_after_init = {
-	.ops = &stack_map_ops,
-	.type = BPF_MAP_TYPE_STACK_TRACE,
-};
-
 static int __init register_stack_map(void)
 {
-	bpf_register_map_type(&stack_map_type);
+	bpf_register_map_type(BPF_MAP_TYPE_STACK_TRACE, &stack_map_ops);
 	return 0;
 }
 late_initcall(register_stack_map);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 1156eccf36a5..ea52db73b952 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -27,30 +27,33 @@ DEFINE_PER_CPU(int, bpf_prog_active);
 
 int sysctl_unprivileged_bpf_disabled __read_mostly;
 
-static LIST_HEAD(bpf_map_types);
+static const struct bpf_map_ops *
+bpf_map_types[NUM_BPF_MAP_TYPES] __ro_after_init;
 
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
+	if (attr->map_type >= NUM_BPF_MAP_TYPES ||
+	    !bpf_map_types[attr->map_type])
+		return ERR_PTR(-EINVAL);
+
+	map = bpf_map_types[attr->map_type]->map_alloc(attr);
+	if (IS_ERR(map))
+		return map;
+	map->ops = bpf_map_types[attr->map_type];
+	map->map_type = attr->map_type;
+	return map;
 }
 
 /* boot time registration of different map implementations */
-void bpf_register_map_type(struct bpf_map_type_list *tl)
+void __init bpf_register_map_type(enum bpf_map_type type,
+				  const struct bpf_map_ops *ops)
 {
-	list_add(&tl->list_node, &bpf_map_types);
+	if (WARN_ON(bpf_map_types[type]))
+		return;
+
+	bpf_map_types[type] = ops;
 }
 
 void *bpf_map_area_alloc(size_t size)
-- 
2.11.0
