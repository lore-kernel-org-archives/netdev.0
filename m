From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/4] bpf: Add array of maps support
Date: Wed, 22 Mar 2017 10:00:33 -0700
Message-ID: <20170322170035.923581-3-kafai@fb.com>
References: <20170322170035.923581-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        FB Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60265 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1760146AbdCVRAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:00:53 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v2MGx5fb014950
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 29bp46a4xf-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:37 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 112655f00f2111e7a8930002c99293a0-bfdf59a0 for <netdev@vger.kernel.org>;        Wed,
 22 Mar 2017 10:00:35 -0700
In-Reply-To: <20170322170035.923581-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a few helper funcs to enable map-in-map
support (i.e. outer_map->inner_map).  The first outer_map type
BPF_MAP_TYPE_ARRAY_OF_MAPS is also added in this patch.
The next patch will introduce a hash of maps type.

Any bpf map type can be acted as an inner_map.  The exception
is BPF_MAP_TYPE_PROG_ARRAY because the extra level of
indirection makes it harder to verify the owner_prog_type
and owner_jited.

Multi-level map-in-map is not supported (i.e. map->map is ok
but not map->map->map).

When adding an inner_map to an outer_map, it currently checks the
map_type, key_size, value_size, map_flags, max_entries and ops.
The verifier also uses those map's properties to do static analysis.
map_flags is needed because we need to ensure BPF_PROG_TYPE_PERF_EVENT
is using a preallocated hashtab for the inner_hash also.  ops and
max_entries are needed to generate inlined map-lookup instructions.
For simplicity reason, a simple '==' test is used for both map_flags
and max_entries.  The equality of ops is implied by the equality of
map_type.

During outer_map creation time, an inner_map_fd is needed to create an
outer_map.  However, the inner_map_fd's life time does not depend on the
outer_map.  The inner_map_fd is merely used to initialize
the inner_map_meta of the outer_map.

Also, for the outer_map:

* It allows element update and delete from syscall
* It allows element lookup from bpf_prog

The above is similar to the current fd_array pattern.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      |  1 +
 include/uapi/linux/bpf.h |  2 +
 kernel/bpf/Makefile      |  2 +-
 kernel/bpf/arraymap.c    | 63 +++++++++++++++++++++++++++++++
 kernel/bpf/map_in_map.c  | 97 ++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/map_in_map.h  | 23 ++++++++++++
 kernel/bpf/syscall.c     |  7 +++-
 kernel/bpf/verifier.c    | 42 ++++++++++++++++-----
 8 files changed, 225 insertions(+), 12 deletions(-)
 create mode 100644 kernel/bpf/map_in_map.c
 create mode 100644 kernel/bpf/map_in_map.h

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index da8c64ca8dc9..3f3cdf9b15e8 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -50,6 +50,7 @@ struct bpf_map {
 	const struct bpf_map_ops *ops;
 	struct work_struct work;
 	atomic_t usercnt;
+	struct bpf_map *inner_map_meta;
 };
 
 struct bpf_map_type_list {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0539a0ceef38..1701ec1e7de3 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -96,6 +96,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_LRU_HASH,
 	BPF_MAP_TYPE_LRU_PERCPU_HASH,
 	BPF_MAP_TYPE_LPM_TRIE,
+	BPF_MAP_TYPE_ARRAY_OF_MAPS,
 };
 
 enum bpf_prog_type {
@@ -152,6 +153,7 @@ union bpf_attr {
 		__u32	value_size;	/* size of value in bytes */
 		__u32	max_entries;	/* max number of entries in a map */
 		__u32	map_flags;	/* prealloc or not */
+		__u32	inner_map_fd;	/* fd pointing to the inner map */
 	};
 
 	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index e1ce4f4fd7fd..e1e5e658f2db 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,7 +1,7 @@
 obj-y := core.o
 
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
-obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o
+obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
 ifeq ($(CONFIG_PERF_EVENTS),y)
 obj-$(CONFIG_BPF_SYSCALL) += stackmap.o
 endif
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 4d7d5d0ed76a..bc9da93db403 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -17,6 +17,8 @@
 #include <linux/filter.h>
 #include <linux/perf_event.h>
 
+#include "map_in_map.h"
+
 static void bpf_array_free_percpu(struct bpf_array *array)
 {
 	int i;
@@ -602,3 +604,64 @@ static int __init register_cgroup_array_map(void)
 }
 late_initcall(register_cgroup_array_map);
 #endif
+
+static struct bpf_map *array_of_map_alloc(union bpf_attr *attr)
+{
+	struct bpf_map *map, *inner_map_meta;
+
+	inner_map_meta = bpf_map_meta_alloc(attr->inner_map_fd);
+	if (IS_ERR(inner_map_meta))
+		return inner_map_meta;
+
+	map = fd_array_map_alloc(attr);
+	if (IS_ERR(map)) {
+		bpf_map_meta_free(inner_map_meta);
+		return map;
+	}
+
+	map->inner_map_meta = inner_map_meta;
+
+	return map;
+}
+
+static void array_of_map_free(struct bpf_map *map)
+{
+	/* map->inner_map_meta is only accessed by syscall which
+	 * is protected by fdget/fdput.
+	 */
+	bpf_map_meta_free(map->inner_map_meta);
+	bpf_fd_array_map_clear(map);
+	fd_array_map_free(map);
+}
+
+static void *array_of_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_map **inner_map = array_map_lookup_elem(map, key);
+
+	if (!inner_map)
+		return NULL;
+
+	return READ_ONCE(*inner_map);
+}
+
+static const struct bpf_map_ops array_of_map_ops = {
+	.map_alloc = array_of_map_alloc,
+	.map_free = array_of_map_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = array_of_map_lookup_elem,
+	.map_delete_elem = fd_array_map_delete_elem,
+	.map_fd_get_ptr = bpf_map_fd_get_ptr,
+	.map_fd_put_ptr = bpf_map_fd_put_ptr,
+};
+
+static struct bpf_map_type_list array_of_map_type __ro_after_init = {
+	.ops = &array_of_map_ops,
+	.type = BPF_MAP_TYPE_ARRAY_OF_MAPS,
+};
+
+static int __init register_array_of_map(void)
+{
+	bpf_register_map_type(&array_of_map_type);
+	return 0;
+}
+late_initcall(register_array_of_map);
diff --git a/kernel/bpf/map_in_map.c b/kernel/bpf/map_in_map.c
new file mode 100644
index 000000000000..59bcdf821ae4
--- /dev/null
+++ b/kernel/bpf/map_in_map.c
@@ -0,0 +1,97 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/slab.h>
+#include <linux/bpf.h>
+
+#include "map_in_map.h"
+
+struct bpf_map *bpf_map_meta_alloc(int inner_map_ufd)
+{
+	struct bpf_map *inner_map, *inner_map_meta;
+	struct fd f;
+
+	f = fdget(inner_map_ufd);
+	inner_map = __bpf_map_get(f);
+	if (IS_ERR(inner_map))
+		return inner_map;
+
+	/* prog_array->owner_prog_type and owner_jited
+	 * is a runtime binding.  Doing static check alone
+	 * in the verifier is not enough.
+	 */
+	if (inner_map->map_type == BPF_MAP_TYPE_PROG_ARRAY) {
+		fdput(f);
+		return ERR_PTR(-ENOTSUPP);
+	}
+
+	/* Does not support >1 level map-in-map */
+	if (inner_map->inner_map_meta) {
+		fdput(f);
+		return ERR_PTR(-EINVAL);
+	}
+
+	inner_map_meta = kzalloc(sizeof(*inner_map_meta), GFP_USER);
+	if (!inner_map_meta) {
+		fdput(f);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	inner_map_meta->map_type = inner_map->map_type;
+	inner_map_meta->key_size = inner_map->key_size;
+	inner_map_meta->value_size = inner_map->value_size;
+	inner_map_meta->map_flags = inner_map->map_flags;
+	inner_map_meta->ops = inner_map->ops;
+	inner_map_meta->max_entries = inner_map->max_entries;
+
+	fdput(f);
+	return inner_map_meta;
+}
+
+void bpf_map_meta_free(struct bpf_map *map_meta)
+{
+	kfree(map_meta);
+}
+
+bool bpf_map_meta_equal(const struct bpf_map *meta0,
+			const struct bpf_map *meta1)
+{
+	/* No need to compare ops because it is covered by map_type */
+	return meta0->map_type == meta1->map_type &&
+		meta0->key_size == meta1->key_size &&
+		meta0->value_size == meta1->value_size &&
+		meta0->map_flags == meta1->map_flags &&
+		meta0->max_entries == meta1->max_entries;
+}
+
+void *bpf_map_fd_get_ptr(struct bpf_map *map,
+			 struct file *map_file /* not used */,
+			 int ufd)
+{
+	struct bpf_map *inner_map;
+	struct fd f;
+
+	f = fdget(ufd);
+	inner_map = __bpf_map_get(f);
+	if (IS_ERR(inner_map))
+		return inner_map;
+
+	if (bpf_map_meta_equal(map->inner_map_meta, inner_map))
+		inner_map = bpf_map_inc(inner_map, false);
+	else
+		inner_map = ERR_PTR(-EINVAL);
+
+	fdput(f);
+	return inner_map;
+}
+
+void bpf_map_fd_put_ptr(void *ptr)
+{
+	/* ptr->ops->map_free() has to go through one
+	 * rcu grace period by itself.
+	 */
+	bpf_map_put(ptr);
+}
diff --git a/kernel/bpf/map_in_map.h b/kernel/bpf/map_in_map.h
new file mode 100644
index 000000000000..177fadb689dc
--- /dev/null
+++ b/kernel/bpf/map_in_map.h
@@ -0,0 +1,23 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef __MAP_IN_MAP_H__
+#define __MAP_IN_MAP_H__
+
+#include <linux/types.h>
+
+struct file;
+struct bpf_map;
+
+struct bpf_map *bpf_map_meta_alloc(int inner_map_ufd);
+void bpf_map_meta_free(struct bpf_map *map_meta);
+bool bpf_map_meta_equal(const struct bpf_map *meta0,
+			const struct bpf_map *meta1);
+void *bpf_map_fd_get_ptr(struct bpf_map *map, struct file *map_file,
+			 int ufd);
+void bpf_map_fd_put_ptr(void *ptr);
+
+#endif
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 48c914b983bd..6e24fdf1f373 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -215,7 +215,7 @@ int bpf_map_new_fd(struct bpf_map *map)
 		   offsetof(union bpf_attr, CMD##_LAST_FIELD) - \
 		   sizeof(attr->CMD##_LAST_FIELD)) != NULL
 
-#define BPF_MAP_CREATE_LAST_FIELD map_flags
+#define BPF_MAP_CREATE_LAST_FIELD inner_map_fd
 /* called via syscall */
 static int map_create(union bpf_attr *attr)
 {
@@ -352,6 +352,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 		err = bpf_percpu_array_copy(map, key, value);
 	} else if (map->map_type == BPF_MAP_TYPE_STACK_TRACE) {
 		err = bpf_stackmap_copy(map, key, value);
+	} else if (map->map_type == BPF_MAP_TYPE_ARRAY_OF_MAPS) {
+		err = -ENOTSUPP;
 	} else {
 		rcu_read_lock();
 		ptr = map->ops->map_lookup_elem(map, key);
@@ -438,7 +440,8 @@ static int map_update_elem(union bpf_attr *attr)
 		err = bpf_percpu_array_update(map, key, value, attr->flags);
 	} else if (map->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY ||
 		   map->map_type == BPF_MAP_TYPE_PROG_ARRAY ||
-		   map->map_type == BPF_MAP_TYPE_CGROUP_ARRAY) {
+		   map->map_type == BPF_MAP_TYPE_CGROUP_ARRAY ||
+		   map->map_type == BPF_MAP_TYPE_ARRAY_OF_MAPS) {
 		rcu_read_lock();
 		err = bpf_fd_array_map_update_elem(map, f.file, key, value,
 						   attr->flags);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 9bf82267f2f9..3b8f528c5473 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1199,6 +1199,9 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		    func_id != BPF_FUNC_current_task_under_cgroup)
 			goto error;
 		break;
+	case BPF_MAP_TYPE_ARRAY_OF_MAPS:
+		if (func_id != BPF_FUNC_map_lookup_elem)
+			goto error;
 	default:
 		break;
 	}
@@ -2101,14 +2104,19 @@ static void mark_map_reg(struct bpf_reg_state *regs, u32 regno, u32 id,
 	struct bpf_reg_state *reg = &regs[regno];
 
 	if (reg->type == PTR_TO_MAP_VALUE_OR_NULL && reg->id == id) {
-		reg->type = type;
+		if (type == UNKNOWN_VALUE) {
+			__mark_reg_unknown_value(regs, regno);
+		} else if (reg->map_ptr->inner_map_meta) {
+			reg->type = CONST_PTR_TO_MAP;
+			reg->map_ptr = reg->map_ptr->inner_map_meta;
+		} else {
+			reg->type = type;
+		}
 		/* We don't need id from this point onwards anymore, thus we
 		 * should better reset it, so that state pruning has chances
 		 * to take effect.
 		 */
 		reg->id = 0;
-		if (type == UNKNOWN_VALUE)
-			__mark_reg_unknown_value(regs, regno);
 	}
 }
 
@@ -3033,16 +3041,32 @@ static int do_check(struct bpf_verifier_env *env)
 	return 0;
 }
 
+static int check_map_prealloc(struct bpf_map *map)
+{
+	return (map->map_type != BPF_MAP_TYPE_HASH &&
+		map->map_type != BPF_MAP_TYPE_PERCPU_HASH) ||
+		!(map->map_flags & BPF_F_NO_PREALLOC);
+}
+
 static int check_map_prog_compatibility(struct bpf_map *map,
 					struct bpf_prog *prog)
 
 {
-	if (prog->type == BPF_PROG_TYPE_PERF_EVENT &&
-	    (map->map_type == BPF_MAP_TYPE_HASH ||
-	     map->map_type == BPF_MAP_TYPE_PERCPU_HASH) &&
-	    (map->map_flags & BPF_F_NO_PREALLOC)) {
-		verbose("perf_event programs can only use preallocated hash map\n");
-		return -EINVAL;
+	/* Make sure that BPF_PROG_TYPE_PERF_EVENT programs only use
+	 * preallocated hash maps, since doing memory allocation
+	 * in overflow_handler can crash depending on where nmi got
+	 * triggered.
+	 */
+	if (prog->type == BPF_PROG_TYPE_PERF_EVENT) {
+		if (!check_map_prealloc(map)) {
+			verbose("perf_event programs can only use preallocated hash map\n");
+			return -EINVAL;
+		}
+		if (map->inner_map_meta &&
+		    !check_map_prealloc(map->inner_map_meta)) {
+			verbose("perf_event programs can only use preallocated inner hash map\n");
+			return -EINVAL;
+		}
 	}
 	return 0;
 }
-- 
2.9.3
