From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 6/9] bpf: arraymap: introduce BPF_MAP_TYPE_ARRAY_PERCPU
Date: Mon, 11 Jan 2016 23:56:58 +0800
Message-ID: <1452527821-12276-7-git-send-email-tom.leiming@gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces percpu array map so that expensive
atomic operations can be avoided in eBPF prog in case of
ARRAY map.

PERCPU MAP uses the percpu version of update/lookup element
helpers and callbacks to access element in the map, and
the previous update/lookup element helpers and callbacks
don't work at the same time.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 include/linux/bpf.h      |   2 +
 include/uapi/linux/bpf.h |   1 +
 kernel/bpf/arraymap.c    | 136 ++++++++++++++++++++++++++++++++++++++++++-----
 kernel/bpf/bpf_map.h     |   2 +
 kernel/bpf/map.c         |   6 +++
 5 files changed, 135 insertions(+), 12 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 75d75d8..909dc1e 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -153,9 +153,11 @@ struct bpf_array {
 	 */
 	enum bpf_prog_type owner_prog_type;
 	bool owner_jited;
+	bool percpu;
 	union {
 		char value[0] __aligned(8);
 		void *ptrs[0] __aligned(8);
+		void __percpu *pptrs[0] __aligned(8);
 	};
 };
 #define MAX_TAIL_CALL_CNT 32
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 63b04c6..70968fd 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -83,6 +83,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_ARRAY,
 	BPF_MAP_TYPE_PROG_ARRAY,
 	BPF_MAP_TYPE_PERF_EVENT_ARRAY,
+	BPF_MAP_TYPE_ARRAY_PERCPU,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 20b9f2c..dbafa6a 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -19,11 +19,36 @@
 
 #include "bpf_map.h"
 
-/* Called from syscall */
-static struct bpf_map *array_map_alloc(union bpf_attr *attr)
+static void free_percpu_array(struct bpf_array *array)
+{
+	int i;
+
+	for (i = 0; i < array->map.max_entries; i++)
+		free_percpu(array->pptrs[i]);
+}
+
+static int alloc_percpu_array(struct bpf_array *array, int cnt, int elem_size)
+{
+	int i;
+
+	for (i = 0; i < cnt; i++) {
+		void __percpu *ptr = __alloc_percpu(elem_size, 8);
+
+		if (!ptr) {
+			free_percpu_array(array);
+			return -ENOMEM;
+		}
+		array->pptrs[i] = ptr;
+	}
+
+	array->percpu = true;
+	return 0;
+}
+
+static struct bpf_map *__array_map_alloc(union bpf_attr *attr, bool percpu)
 {
 	struct bpf_array *array;
-	u32 elem_size, array_size;
+	u32 elem_size, array_size, elem_alloc_size;
 
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
@@ -38,12 +63,22 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 
 	elem_size = round_up(attr->value_size, 8);
 
+	/*
+	 * In case of percpu-array, each element in the allocated array
+	 * points to one percpu element.
+	 */
+	if (percpu)
+		elem_alloc_size = sizeof(void *);
+	else
+		elem_alloc_size = elem_size;
+
 	/* check round_up into zero and u32 overflow */
-	if (elem_size == 0 ||
-	    attr->max_entries > (U32_MAX - PAGE_SIZE - sizeof(*array)) / elem_size)
+	if (elem_alloc_size == 0 ||
+	    attr->max_entries > (U32_MAX - PAGE_SIZE - sizeof(*array)) /
+	    elem_alloc_size)
 		return ERR_PTR(-ENOMEM);
 
-	array_size = sizeof(*array) + attr->max_entries * elem_size;
+	array_size = sizeof(*array) + attr->max_entries * elem_alloc_size;
 
 	/* allocate all map elements and zero-initialize them */
 	array = kzalloc(array_size, GFP_USER | __GFP_NOWARN);
@@ -53,16 +88,39 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 			return ERR_PTR(-ENOMEM);
 	}
 
+	if (percpu) {
+		if (alloc_percpu_array(array, attr->max_entries,
+				       attr->value_size)) {
+			kvfree(array);
+			return ERR_PTR(-ENOMEM);
+		}
+		array->map.pages = round_up(attr->max_entries *
+				attr->value_size * num_possible_cpus(),
+				PAGE_SIZE) >> PAGE_SHIFT;
+	}
+
 	/* copy mandatory map attributes */
 	array->map.key_size = attr->key_size;
 	array->map.value_size = attr->value_size;
 	array->map.max_entries = attr->max_entries;
-	array->map.pages = round_up(array_size, PAGE_SIZE) >> PAGE_SHIFT;
+	array->map.pages += round_up(array_size, PAGE_SIZE) >> PAGE_SHIFT;
 	array->elem_size = elem_size;
 
 	return &array->map;
 }
 
+/* Called from syscall */
+static struct bpf_map *array_map_alloc(union bpf_attr *attr)
+{
+	return __array_map_alloc(attr, false);
+}
+
+/* Called from syscall */
+static struct bpf_map *percpu_array_map_alloc(union bpf_attr *attr)
+{
+	return __array_map_alloc(attr, true);
+}
+
 /* Called from syscall or from eBPF program */
 static void *array_map_lookup_elem(struct bpf_map *map, void *key)
 {
@@ -75,6 +133,19 @@ static void *array_map_lookup_elem(struct bpf_map *map, void *key)
 	return array->value + array->elem_size * index;
 }
 
+/* Called from syscall or from eBPF program */
+static void *array_map_lookup_elem_percpu(struct bpf_map *map,
+		void *key, u32 cpu)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+
+	if (index >= array->map.max_entries)
+		return NULL;
+
+	return per_cpu_ptr(array->pptrs[index], cpu);
+}
+
 /* Called from syscall */
 static int array_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 {
@@ -95,11 +166,10 @@ static int array_map_get_next_key(struct bpf_map *map, void *key, void *next_key
 }
 
 /* Called from syscall or from eBPF program */
-static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
-				 u64 map_flags)
+static inline int __array_map_update_elem(struct bpf_array *array,
+					  u32 index, void *value,
+					  u64 map_flags, void *ptr)
 {
-	struct bpf_array *array = container_of(map, struct bpf_array, map);
-	u32 index = *(u32 *)key;
 
 	if (map_flags > BPF_EXIST)
 		/* unknown flags */
@@ -113,10 +183,32 @@ static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
 		/* all elements already exist */
 		return -EEXIST;
 
-	memcpy(array->value + array->elem_size * index, value, map->value_size);
+	memcpy(ptr, value, array->map.value_size);
 	return 0;
 }
 
+/* Called from syscall or from eBPF program */
+static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
+				 u64 map_flags)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+	void *ptr = array->value + array->elem_size * index;
+
+	return __array_map_update_elem(array, index, value, map_flags, ptr);
+}
+
+/* Called from syscall or from eBPF program */
+static int array_map_update_elem_percpu(struct bpf_map *map, void *key,
+					void *value, u64 map_flags, u32 cpu)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+	void *ptr = per_cpu_ptr(array->pptrs[index], cpu);
+
+	return __array_map_update_elem(array, index, value, map_flags, ptr);
+}
+
 /* Called when map->refcnt goes to zero, either from workqueue or from syscall */
 static void array_map_free(struct bpf_map *map)
 {
@@ -129,6 +221,9 @@ static void array_map_free(struct bpf_map *map)
 	 */
 	synchronize_rcu();
 
+	if (array->percpu)
+		free_percpu_array(array);
+
 	kvfree(array);
 }
 
@@ -148,9 +243,26 @@ static struct bpf_map_type_list array_type __read_mostly = {
 	.type = BPF_MAP_TYPE_ARRAY,
 };
 
+static const struct bpf_map_ops percpu_array_ops = {
+	.map_alloc = percpu_array_map_alloc,
+	.map_free = array_map_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = map_lookup_elem_nop,
+	.map_update_elem = map_update_elem_nop,
+	.map_delete_elem = map_delete_elem_nop,
+	.map_lookup_elem_percpu = array_map_lookup_elem_percpu,
+	.map_update_elem_percpu = array_map_update_elem_percpu,
+};
+
+static struct bpf_map_type_list percpu_array_type __read_mostly = {
+	.ops = &percpu_array_ops,
+	.type = BPF_MAP_TYPE_ARRAY_PERCPU,
+};
+
 static int __init register_array_map(void)
 {
 	bpf_register_map_type(&array_type);
+	bpf_register_map_type(&percpu_array_type);
 	return 0;
 }
 late_initcall(register_array_map);
diff --git a/kernel/bpf/bpf_map.h b/kernel/bpf/bpf_map.h
index adab4e6..8957a60 100644
--- a/kernel/bpf/bpf_map.h
+++ b/kernel/bpf/bpf_map.h
@@ -5,6 +5,8 @@
 
 extern void *map_lookup_elem_nop(struct bpf_map *map, void *key);
 extern int map_delete_elem_nop(struct bpf_map *map, void *key);
+extern int map_update_elem_nop(struct bpf_map *map, void *key,
+		void *value, u64 flags);
 extern void *map_lookup_elem_percpu_nop(struct bpf_map *map, void *key,
 		u32 cpu);
 extern int map_update_elem_percpu_nop(struct bpf_map *map, void *key,
diff --git a/kernel/bpf/map.c b/kernel/bpf/map.c
index b94458a..48252a6 100644
--- a/kernel/bpf/map.c
+++ b/kernel/bpf/map.c
@@ -24,6 +24,12 @@ int map_delete_elem_nop(struct bpf_map *map, void *key)
 	return -EINVAL;
 }
 
+int map_update_elem_nop(struct bpf_map *map, void *key, void *value, u64 flags)
+{
+	return -EINVAL;
+}
+
+
 void *map_lookup_elem_percpu_nop(struct bpf_map *map, void *key, u32 cpu)
 {
 	return NULL;
-- 
1.9.1
