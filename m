From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 3/4] bpf: Add hash of maps support
Date: Wed, 22 Mar 2017 10:00:34 -0700
Message-ID: <20170322170035.923581-4-kafai@fb.com>
References: <20170322170035.923581-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        FB Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37653 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760962AbdCVRAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:00:47 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2MGwfkQ004764
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29bnhq2ae4-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:36 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 1135d8e00f2111e78c7c0002c9dfb610-93f99a0 for <netdev@vger.kernel.org>; Wed,
 22 Mar 2017 10:00:35 -0700
In-Reply-To: <20170322170035.923581-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds hash of maps support (hashmap->bpf_map).
BPF_MAP_TYPE_HASH_OF_MAPS is added.

A map-in-map contains a pointer to another map and lets call
this pointer 'inner_map_ptr'.

Notes on deleting inner_map_ptr from a hash map:

1. For BPF_F_NO_PREALLOC map-in-map, when deleting
   an inner_map_ptr, the htab_elem itself will go through
   a rcu grace period and the inner_map_ptr resides
   in the htab_elem.

2. For pre-allocated htab_elem (!BPF_F_NO_PREALLOC),
   when deleting an inner_map_ptr, the htab_elem may
   get reused immediately.  This situation is similar
   to the existing prealloc-ated use cases.

   However, the bpf_map_fd_put_ptr() calls bpf_map_put() which calls
   inner_map->ops->map_free(inner_map) which will go
   through a rcu grace period (i.e. all bpf_map's map_free
   currently goes through a rcu grace period).  Hence,
   the inner_map_ptr is still safe for the rcu reader side.

This patch also includes BPF_MAP_TYPE_HASH_OF_MAPS to the
check_map_prealloc() in the verifier.  preallocation is a
must for BPF_PROG_TYPE_PERF_EVENT.  Hence, even we don't expect
heavy updates to map-in-map, enforcing BPF_F_NO_PREALLOC for map-in-map
is impossible without disallowing BPF_PROG_TYPE_PERF_EVENT from using
map-in-map first.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      |   2 +
 include/uapi/linux/bpf.h |   1 +
 kernel/bpf/hashtab.c     | 121 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c     |   8 +++-
 kernel/bpf/verifier.c    |   4 +-
 5 files changed, 134 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 3f3cdf9b15e8..2ae39a3e9ead 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -277,6 +277,8 @@ int bpf_stackmap_copy(struct bpf_map *map, void *key, void *value);
 int bpf_fd_array_map_update_elem(struct bpf_map *map, struct file *map_file,
 				 void *key, void *value, u64 map_flags);
 void bpf_fd_array_map_clear(struct bpf_map *map);
+int bpf_fd_htab_map_update_elem(struct bpf_map *map, struct file *map_file,
+				void *key, void *value, u64 map_flags);
 
 /* memcpy that is used with 8-byte aligned pointers, power-of-8 size and
  * forced to use 'long' read/writes to try to atomically copy long counters.
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1701ec1e7de3..ce6f029ac368 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -97,6 +97,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_LRU_PERCPU_HASH,
 	BPF_MAP_TYPE_LPM_TRIE,
 	BPF_MAP_TYPE_ARRAY_OF_MAPS,
+	BPF_MAP_TYPE_HASH_OF_MAPS,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 000153acb6d5..343fb5394c95 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -16,6 +16,7 @@
 #include <linux/rculist_nulls.h>
 #include "percpu_freelist.h"
 #include "bpf_lru_list.h"
+#include "map_in_map.h"
 
 struct bucket {
 	struct hlist_nulls_head head;
@@ -88,6 +89,11 @@ static inline void __percpu *htab_elem_get_ptr(struct htab_elem *l, u32 key_size
 	return *(void __percpu **)(l->key + key_size);
 }
 
+static void *fd_htab_map_get_ptr(const struct bpf_map *map, struct htab_elem *l)
+{
+	return *(void **)(l->key + roundup(map->key_size, 8));
+}
+
 static struct htab_elem *get_htab_elem(struct bpf_htab *htab, int i)
 {
 	return (struct htab_elem *) (htab->elems + i * htab->elem_size);
@@ -603,6 +609,14 @@ static void htab_elem_free_rcu(struct rcu_head *head)
 
 static void free_htab_elem(struct bpf_htab *htab, struct htab_elem *l)
 {
+	struct bpf_map *map = &htab->map;
+
+	if (map->ops->map_fd_put_ptr) {
+		void *ptr = fd_htab_map_get_ptr(map, l);
+
+		map->ops->map_fd_put_ptr(ptr);
+	}
+
 	if (l->state == HTAB_EXTRA_ELEM_USED) {
 		l->state = HTAB_EXTRA_ELEM_FREE;
 		return;
@@ -1057,6 +1071,7 @@ static void delete_all_elements(struct bpf_htab *htab)
 		}
 	}
 }
+
 /* Called when map->refcnt goes to zero, either from workqueue or from syscall */
 static void htab_map_free(struct bpf_map *map)
 {
@@ -1213,12 +1228,118 @@ static struct bpf_map_type_list htab_lru_percpu_type __ro_after_init = {
 	.type = BPF_MAP_TYPE_LRU_PERCPU_HASH,
 };
 
+static struct bpf_map *fd_htab_map_alloc(union bpf_attr *attr)
+{
+	struct bpf_map *map;
+
+	if (attr->value_size != sizeof(u32))
+		return ERR_PTR(-EINVAL);
+
+	/* pointer is stored internally */
+	attr->value_size = sizeof(void *);
+	map = htab_map_alloc(attr);
+	attr->value_size = sizeof(u32);
+
+	return map;
+}
+
+static void fd_htab_map_free(struct bpf_map *map)
+{
+	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
+	struct hlist_nulls_node *n;
+	struct hlist_nulls_head *head;
+	struct htab_elem *l;
+	int i;
+
+	for (i = 0; i < htab->n_buckets; i++) {
+		head = select_bucket(htab, i);
+
+		hlist_nulls_for_each_entry_safe(l, n, head, hash_node) {
+			void *ptr = fd_htab_map_get_ptr(map, l);
+
+			map->ops->map_fd_put_ptr(ptr);
+		}
+	}
+
+	htab_map_free(map);
+}
+
+/* only called from syscall */
+int bpf_fd_htab_map_update_elem(struct bpf_map *map, struct file *map_file,
+				void *key, void *value, u64 map_flags)
+{
+	void *ptr;
+	int ret;
+	u32 ufd = *(u32 *)value;
+
+	ptr = map->ops->map_fd_get_ptr(map, map_file, ufd);
+	if (IS_ERR(ptr))
+		return PTR_ERR(ptr);
+
+	ret = htab_map_update_elem(map, key, &ptr, map_flags);
+	if (ret)
+		map->ops->map_fd_put_ptr(ptr);
+
+	return ret;
+}
+
+static struct bpf_map *htab_of_map_alloc(union bpf_attr *attr)
+{
+	struct bpf_map *map, *inner_map_meta;
+
+	inner_map_meta = bpf_map_meta_alloc(attr->inner_map_fd);
+	if (IS_ERR(inner_map_meta))
+		return inner_map_meta;
+
+	map = fd_htab_map_alloc(attr);
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
+static void *htab_of_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_map **inner_map  = htab_map_lookup_elem(map, key);
+
+	if (!inner_map)
+		return NULL;
+
+	return READ_ONCE(*inner_map);
+}
+
+static void htab_of_map_free(struct bpf_map *map)
+{
+	bpf_map_meta_free(map->inner_map_meta);
+	fd_htab_map_free(map);
+}
+
+static const struct bpf_map_ops htab_of_map_ops = {
+	.map_alloc = htab_of_map_alloc,
+	.map_free = htab_of_map_free,
+	.map_get_next_key = htab_map_get_next_key,
+	.map_lookup_elem = htab_of_map_lookup_elem,
+	.map_delete_elem = htab_map_delete_elem,
+	.map_fd_get_ptr = bpf_map_fd_get_ptr,
+	.map_fd_put_ptr = bpf_map_fd_put_ptr,
+};
+
+static struct bpf_map_type_list htab_of_map_type __ro_after_init = {
+	.ops = &htab_of_map_ops,
+	.type = BPF_MAP_TYPE_HASH_OF_MAPS,
+};
+
 static int __init register_htab_map(void)
 {
 	bpf_register_map_type(&htab_type);
 	bpf_register_map_type(&htab_percpu_type);
 	bpf_register_map_type(&htab_lru_type);
 	bpf_register_map_type(&htab_lru_percpu_type);
+	bpf_register_map_type(&htab_of_map_type);
 	return 0;
 }
 late_initcall(register_htab_map);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 6e24fdf1f373..c35ebfe6d84d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -352,7 +352,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 		err = bpf_percpu_array_copy(map, key, value);
 	} else if (map->map_type == BPF_MAP_TYPE_STACK_TRACE) {
 		err = bpf_stackmap_copy(map, key, value);
-	} else if (map->map_type == BPF_MAP_TYPE_ARRAY_OF_MAPS) {
+	} else if (map->map_type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
+		   map->map_type == BPF_MAP_TYPE_HASH_OF_MAPS) {
 		err = -ENOTSUPP;
 	} else {
 		rcu_read_lock();
@@ -446,6 +447,11 @@ static int map_update_elem(union bpf_attr *attr)
 		err = bpf_fd_array_map_update_elem(map, f.file, key, value,
 						   attr->flags);
 		rcu_read_unlock();
+	} else if (map->map_type == BPF_MAP_TYPE_HASH_OF_MAPS) {
+		rcu_read_lock();
+		err = bpf_fd_htab_map_update_elem(map, f.file, key, value,
+						  attr->flags);
+		rcu_read_unlock();
 	} else {
 		rcu_read_lock();
 		err = map->ops->map_update_elem(map, key, value, attr->flags);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 3b8f528c5473..09923cc5c7c7 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1200,6 +1200,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 			goto error;
 		break;
 	case BPF_MAP_TYPE_ARRAY_OF_MAPS:
+	case BPF_MAP_TYPE_HASH_OF_MAPS:
 		if (func_id != BPF_FUNC_map_lookup_elem)
 			goto error;
 	default:
@@ -3044,7 +3045,8 @@ static int do_check(struct bpf_verifier_env *env)
 static int check_map_prealloc(struct bpf_map *map)
 {
 	return (map->map_type != BPF_MAP_TYPE_HASH &&
-		map->map_type != BPF_MAP_TYPE_PERCPU_HASH) ||
+		map->map_type != BPF_MAP_TYPE_PERCPU_HASH &&
+		map->map_type != BPF_MAP_TYPE_HASH_OF_MAPS) ||
 		!(map->map_flags & BPF_F_NO_PREALLOC);
 }
 
-- 
2.9.3
