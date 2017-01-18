From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: don't trigger OOM killer under pressure with map alloc
Date: Wed, 18 Jan 2017 15:14:17 +0100
Message-ID: <1f39f6b28b1ec25a88b90dd95aa4ea7820d0d53a.1484747846.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41777 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752546AbdAROOq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 09:14:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two helpers, bpf_map_area_alloc() and bpf_map_area_free(),
that are to be used for map allocations. Using kmalloc() for very large
allocations can cause excessive work within the page allocator, so i) fall
back earlier to vmalloc() when the attempt is considered costly anyway,
and even more importantly ii) don't trigger OOM killer with any of the
allocators.

Since this is based on a user space request, for example, when creating
maps with element pre-allocation, we really want such requests to fail
instead of killing other user space processes.

Also, don't spam the kernel log with warnings should any of the allocations
fail under pressure. Given that, we can make backend selection in
bpf_map_area_alloc() generic, and convert all maps over to use this API
for spots with potentially large allocation requests.

Note, replacing the one kmalloc_array() is fine as overflow checks happen
earlier in htab_map_alloc(), since it must also protect the multiplication
for vmalloc() should kmalloc_array() fail.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h   |  2 ++
 kernel/bpf/arraymap.c | 18 +++++++-----------
 kernel/bpf/hashtab.c  | 22 +++++++++-------------
 kernel/bpf/stackmap.c | 20 ++++++++------------
 kernel/bpf/syscall.c  | 26 ++++++++++++++++++++++++++
 5 files changed, 52 insertions(+), 36 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 05cf951..3ed1f3b 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -247,6 +247,8 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 void bpf_map_put_with_uref(struct bpf_map *map);
 void bpf_map_put(struct bpf_map *map);
 int bpf_map_precharge_memlock(u32 pages);
+void *bpf_map_area_alloc(size_t size);
+void bpf_map_area_free(void *base);
 
 extern int sysctl_unprivileged_bpf_disabled;
 
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 229a5d5..3d55d95 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -11,7 +11,6 @@
  */
 #include <linux/bpf.h>
 #include <linux/err.h>
-#include <linux/vmalloc.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/filter.h>
@@ -74,14 +73,10 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	if (array_size >= U32_MAX - PAGE_SIZE)
 		return ERR_PTR(-ENOMEM);
 
-
 	/* allocate all map elements and zero-initialize them */
-	array = kzalloc(array_size, GFP_USER | __GFP_NOWARN);
-	if (!array) {
-		array = vzalloc(array_size);
-		if (!array)
-			return ERR_PTR(-ENOMEM);
-	}
+	array = bpf_map_area_alloc(array_size);
+	if (!array)
+		return ERR_PTR(-ENOMEM);
 
 	/* copy mandatory map attributes */
 	array->map.map_type = attr->map_type;
@@ -97,7 +92,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 
 	if (array_size >= U32_MAX - PAGE_SIZE ||
 	    elem_size > PCPU_MIN_UNIT_SIZE || bpf_array_alloc_percpu(array)) {
-		kvfree(array);
+		bpf_map_area_free(array);
 		return ERR_PTR(-ENOMEM);
 	}
 out:
@@ -262,7 +257,7 @@ static void array_map_free(struct bpf_map *map)
 	if (array->map.map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
 		bpf_array_free_percpu(array);
 
-	kvfree(array);
+	bpf_map_area_free(array);
 }
 
 static const struct bpf_map_ops array_ops = {
@@ -319,7 +314,8 @@ static void fd_array_map_free(struct bpf_map *map)
 	/* make sure it's empty */
 	for (i = 0; i < array->map.max_entries; i++)
 		BUG_ON(array->ptrs[i] != NULL);
-	kvfree(array);
+
+	bpf_map_area_free(array);
 }
 
 static void *fd_array_map_lookup_elem(struct bpf_map *map, void *key)
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 3f2bb58..a753bbe 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -13,7 +13,6 @@
 #include <linux/bpf.h>
 #include <linux/jhash.h>
 #include <linux/filter.h>
-#include <linux/vmalloc.h>
 #include "percpu_freelist.h"
 #include "bpf_lru_list.h"
 
@@ -103,7 +102,7 @@ static void htab_free_elems(struct bpf_htab *htab)
 		free_percpu(pptr);
 	}
 free_elems:
-	vfree(htab->elems);
+	bpf_map_area_free(htab->elems);
 }
 
 static struct htab_elem *prealloc_lru_pop(struct bpf_htab *htab, void *key,
@@ -125,7 +124,8 @@ static int prealloc_init(struct bpf_htab *htab)
 {
 	int err = -ENOMEM, i;
 
-	htab->elems = vzalloc(htab->elem_size * htab->map.max_entries);
+	htab->elems = bpf_map_area_alloc(htab->elem_size *
+					 htab->map.max_entries);
 	if (!htab->elems)
 		return -ENOMEM;
 
@@ -320,14 +320,10 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		goto free_htab;
 
 	err = -ENOMEM;
-	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct bucket),
-				      GFP_USER | __GFP_NOWARN);
-
-	if (!htab->buckets) {
-		htab->buckets = vmalloc(htab->n_buckets * sizeof(struct bucket));
-		if (!htab->buckets)
-			goto free_htab;
-	}
+	htab->buckets = bpf_map_area_alloc(htab->n_buckets *
+					   sizeof(struct bucket));
+	if (!htab->buckets)
+		goto free_htab;
 
 	for (i = 0; i < htab->n_buckets; i++) {
 		INIT_HLIST_HEAD(&htab->buckets[i].head);
@@ -354,7 +350,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 free_extra_elems:
 	free_percpu(htab->extra_elems);
 free_buckets:
-	kvfree(htab->buckets);
+	bpf_map_area_free(htab->buckets);
 free_htab:
 	kfree(htab);
 	return ERR_PTR(err);
@@ -1014,7 +1010,7 @@ static void htab_map_free(struct bpf_map *map)
 		prealloc_destroy(htab);
 
 	free_percpu(htab->extra_elems);
-	kvfree(htab->buckets);
+	bpf_map_area_free(htab->buckets);
 	kfree(htab);
 }
 
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 732ae16..be85191 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -7,7 +7,6 @@
 #include <linux/bpf.h>
 #include <linux/jhash.h>
 #include <linux/filter.h>
-#include <linux/vmalloc.h>
 #include <linux/stacktrace.h>
 #include <linux/perf_event.h>
 #include "percpu_freelist.h"
@@ -32,7 +31,7 @@ static int prealloc_elems_and_freelist(struct bpf_stack_map *smap)
 	u32 elem_size = sizeof(struct stack_map_bucket) + smap->map.value_size;
 	int err;
 
-	smap->elems = vzalloc(elem_size * smap->map.max_entries);
+	smap->elems = bpf_map_area_alloc(elem_size * smap->map.max_entries);
 	if (!smap->elems)
 		return -ENOMEM;
 
@@ -45,7 +44,7 @@ static int prealloc_elems_and_freelist(struct bpf_stack_map *smap)
 	return 0;
 
 free_elems:
-	vfree(smap->elems);
+	bpf_map_area_free(smap->elems);
 	return err;
 }
 
@@ -76,12 +75,9 @@ static struct bpf_map *stack_map_alloc(union bpf_attr *attr)
 	if (cost >= U32_MAX - PAGE_SIZE)
 		return ERR_PTR(-E2BIG);
 
-	smap = kzalloc(cost, GFP_USER | __GFP_NOWARN);
-	if (!smap) {
-		smap = vzalloc(cost);
-		if (!smap)
-			return ERR_PTR(-ENOMEM);
-	}
+	smap = bpf_map_area_alloc(cost);
+	if (!smap)
+		return ERR_PTR(-ENOMEM);
 
 	err = -E2BIG;
 	cost += n_buckets * (value_size + sizeof(struct stack_map_bucket));
@@ -112,7 +108,7 @@ static struct bpf_map *stack_map_alloc(union bpf_attr *attr)
 put_buffers:
 	put_callchain_buffers();
 free_smap:
-	kvfree(smap);
+	bpf_map_area_free(smap);
 	return ERR_PTR(err);
 }
 
@@ -262,9 +258,9 @@ static void stack_map_free(struct bpf_map *map)
 	/* wait for bpf programs to complete before freeing stack map */
 	synchronize_rcu();
 
-	vfree(smap->elems);
+	bpf_map_area_free(smap->elems);
 	pcpu_freelist_destroy(&smap->freelist);
-	kvfree(smap);
+	bpf_map_area_free(smap);
 	put_callchain_buffers();
 }
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 1d6b29e..19b6129 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -12,6 +12,8 @@
 #include <linux/bpf.h>
 #include <linux/syscalls.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/mmzone.h>
 #include <linux/anon_inodes.h>
 #include <linux/file.h>
 #include <linux/license.h>
@@ -49,6 +51,30 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
 	list_add(&tl->list_node, &bpf_map_types);
 }
 
+void *bpf_map_area_alloc(size_t size)
+{
+	/* We definitely need __GFP_NORETRY, so OOM killer doesn't
+	 * trigger under memory pressure as we really just want to
+	 * fail instead.
+	 */
+	const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
+	void *area;
+
+	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
+		area = kmalloc(size, GFP_USER | flags);
+		if (area != NULL)
+			return area;
+	}
+
+	return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | flags,
+			 PAGE_KERNEL);
+}
+
+void bpf_map_area_free(void *area)
+{
+	kvfree(area);
+}
+
 int bpf_map_precharge_memlock(u32 pages)
 {
 	struct user_struct *user = get_current_user();
-- 
1.9.3
