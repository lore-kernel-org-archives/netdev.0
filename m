From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 3/7] bpf: add array type of eBPF maps
Date: Thu, 13 Nov 2014 17:36:46 -0800
Message-ID: <1415929010-9361-4-git-send-email-ast@plumgrid.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add new map type BPF_MAP_TYPE_ARRAY and its implementation

- optimized for fastest possible lookup()
  . in the future verifier/JIT may recognize lookup() with constant key
    and optimize it into constant pointer. Can optimize non-constant
    key into direct pointer arithmetic as well, since pointers and
    value_size are constant for the life of the eBPF program.
    In other words array_map_lookup_elem() may be 'inlined' by verifier/JIT
    while preserving concurrent access to this map from user space

- two main use cases for array type:
  . 'global' eBPF variables: array of 1 element with key=0 and value is a
    collection of 'global' variables which programs can use to keep the state
    between events
  . aggregation of tracing events into fixed set of buckets

- all array elements pre-allocated and zero initialized at init time

- key as an index in array and can only be 4 byte

- map_delete_elem() returns EINVAL, since elements cannot be deleted

- map_update_elem() replaces elements in an non-atomic way
  (for atomic updates hashtable type should be used instead)

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

Note, from eBPF program and from user space, all map types are accessed
through the same API.

Example of using array type for 'global' variables from eBPF program:
struct globals {
    u64 lat_ave;
    u64 lat_sum;
    u64 missed;
    u64 max_lat;
    int num_samples;
};

struct bpf_map_def SEC("maps") global_map = {
    .type = BPF_MAP_TYPE_ARRAY,
    .key_size = sizeof(int),
    .value_size = sizeof(struct globals),
    .max_entries = 1,
};

int bpf_prog(struct bpf_context *ctx)
{
    ...
    int ind = 0;
    struct globals *g = bpf_map_lookup_elem(&global_map, &ind);
    if (!g)
            return 0;
    if (g->lat_ave == 0) {
            g->num_samples++;
            g->lat_sum += delta;
            if (g->num_samples >= 100) {
                    g->lat_ave = g->lat_sum / g->num_samples;
    ...

The future verifier/JIT optimization will replace bpf_map_lookup_elem()
call inside eBPF program with const pointer to element value of key=0,
so that eBPF program will have no penalty whatsoever to access such
'global' variables.
At the same time user space can access this 'globals' via common map API.

Full example of both kernel and user side follows in later patches.

The array map is like C array of structures. Nothing protects concurrent access.
It's used in the cases where accuracy is not needed or when there is no
concurrent access. To compute a histogram of events in tracing the array
of integers is used. Every integer is a counter. Program increments it
(may be without using xadd) and user space periodically reads it back.
map_update_elem() is called by userspace once to initialize it if zero-init
is not enough. Programs do lookup() and modify the values.
For array type update() method is used rarely, delete() is never used and
get_next() is needed for completeness to browse maps through common map API.

 include/uapi/linux/bpf.h |    1 +
 kernel/bpf/Makefile      |    2 +-
 kernel/bpf/arraymap.c    |  151 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 153 insertions(+), 1 deletion(-)
 create mode 100644 kernel/bpf/arraymap.c

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 03a01fd609aa..0d662fe75df5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -112,6 +112,7 @@ enum bpf_cmd {
 enum bpf_map_type {
 	BPF_MAP_TYPE_UNSPEC,
 	BPF_MAP_TYPE_HASH,
+	BPF_MAP_TYPE_ARRAY,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 2c0ec7f9da78..72ec98ba2d42 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,5 +1,5 @@
 obj-y := core.o
-obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o hashtab.o
+obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o hashtab.o arraymap.o
 ifdef CONFIG_TEST_BPF
 obj-$(CONFIG_BPF_SYSCALL) += test_stub.o
 endif
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
new file mode 100644
index 000000000000..f4f6965f86cb
--- /dev/null
+++ b/kernel/bpf/arraymap.c
@@ -0,0 +1,151 @@
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
+#include <linux/err.h>
+#include <linux/vmalloc.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+
+struct bpf_array {
+	struct bpf_map map;
+	u32 elem_size;
+	char value[0] __aligned(8);
+};
+
+/* Called from syscall */
+static struct bpf_map *array_map_alloc(union bpf_attr *attr)
+{
+	struct bpf_array *array;
+	u32 elem_size;
+
+	/* check sanity of attributes */
+	if (attr->max_entries == 0 || attr->key_size != 4 ||
+	    attr->value_size == 0)
+		return ERR_PTR(-EINVAL);
+
+	elem_size = round_up(attr->value_size, 8);
+
+	/* allocate all map elements and zero-initialize them */
+	array = kzalloc(sizeof(*array) + attr->max_entries * elem_size,
+			GFP_USER | __GFP_NOWARN);
+	if (!array) {
+		array = vzalloc(array->map.max_entries * array->elem_size);
+		if (!array)
+			return ERR_PTR(-ENOMEM);
+	}
+
+	/* copy mandatory map attributes */
+	array->map.key_size = attr->key_size;
+	array->map.value_size = attr->value_size;
+	array->map.max_entries = attr->max_entries;
+
+	array->elem_size = elem_size;
+
+	return &array->map;
+
+}
+
+/* Called from syscall or from eBPF program */
+static void *array_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+
+	if (index >= array->map.max_entries)
+		return NULL;
+
+	return array->value + array->elem_size * index;
+}
+
+/* Called from syscall */
+static int array_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+	u32 *next = (u32 *)next_key;
+
+	if (index >= array->map.max_entries) {
+		*next = 0;
+		return 0;
+	}
+
+	if (index == array->map.max_entries - 1)
+		return -ENOENT;
+
+	*next = index + 1;
+	return 0;
+}
+
+/* Called from syscall or from eBPF program */
+static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
+				 u64 map_flags)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+
+	if (map_flags > BPF_EXIST)
+		/* unknown flags */
+		return -EINVAL;
+
+	if (index >= array->map.max_entries)
+		/* all elements were pre-allocated, cannot insert a new one */
+		return -E2BIG;
+	
+	if (map_flags == BPF_NOEXIST)
+		/* all elemenets already exist */
+		return -EEXIST;
+
+	memcpy(array->value + array->elem_size * index, value, array->elem_size);
+	return 0;
+}
+
+/* Called from syscall or from eBPF program */
+static int array_map_delete_elem(struct bpf_map *map, void *key)
+{
+	return -EINVAL;
+}
+
+/* Called when map->refcnt goes to zero, either from workqueue or from syscall */
+static void array_map_free(struct bpf_map *map)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+
+	/* at this point bpf_prog->aux->refcnt == 0 and this map->refcnt == 0,
+	 * so the programs (can be more than one that used this map) were
+	 * disconnected from events. Wait for outstanding programs to complete
+	 * and free the array
+	 */
+	synchronize_rcu();
+
+	kvfree(array);
+}
+
+static struct bpf_map_ops array_ops = {
+	.map_alloc = array_map_alloc,
+	.map_free = array_map_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = array_map_lookup_elem,
+	.map_update_elem = array_map_update_elem,
+	.map_delete_elem = array_map_delete_elem,
+};
+
+static struct bpf_map_type_list tl = {
+	.ops = &array_ops,
+	.type = BPF_MAP_TYPE_ARRAY,
+};
+
+static int __init register_array_map(void)
+{
+	bpf_register_map_type(&tl);
+	return 0;
+}
+late_initcall(register_array_map);
-- 
1.7.9.5
