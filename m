From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 1/2] bpf: Add syscall lookup support for fd array and htab
Date: Tue, 27 Jun 2017 23:08:34 -0700
Message-ID: <20170628060835.2142549-2-kafai@fb.com>
References: <20170628060835.2142549-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33573 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751571AbdF1GIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 02:08:38 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5S66UkA007777
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:08:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2bc05j8ukh-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:08:38 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 38c2d5ae5bc811e7a3920002c991e86a-20b398f0 for <netdev@vger.kernel.org>;        Tue,
 27 Jun 2017 23:08:36 -0700
In-Reply-To: <20170628060835.2142549-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows userspace to do BPF_MAP_LOOKUP_ELEM on
BPF_MAP_TYPE_PROG_ARRAY,
BPF_MAP_TYPE_ARRAY_OF_MAPS and
BPF_MAP_TYPE_HASH_OF_MAPS.

The lookup returns a prog-id or map-id to the userspace.
The userspace can then use the BPF_PROG_GET_FD_BY_ID
or BPF_MAP_GET_FD_BY_ID to get a fd.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h     |  3 +++
 kernel/bpf/arraymap.c   | 27 +++++++++++++++++++++++++++
 kernel/bpf/hashtab.c    | 21 +++++++++++++++++++++
 kernel/bpf/map_in_map.c |  5 +++++
 kernel/bpf/map_in_map.h |  1 +
 kernel/bpf/syscall.c    | 16 +++++++++++++---
 6 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index deca4e7f2845..5175729270d7 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -36,6 +36,7 @@ struct bpf_map_ops {
 				int fd);
 	void (*map_fd_put_ptr)(void *ptr);
 	u32 (*map_gen_lookup)(struct bpf_map *map, struct bpf_insn *insn_buf);
+	u32 (*map_fd_sys_lookup_elem)(void *ptr);
 };
 
 struct bpf_map {
@@ -288,9 +289,11 @@ int bpf_stackmap_copy(struct bpf_map *map, void *key, void *value);
 
 int bpf_fd_array_map_update_elem(struct bpf_map *map, struct file *map_file,
 				 void *key, void *value, u64 map_flags);
+int bpf_fd_array_map_lookup_elem(struct bpf_map *map, void *key, u32 *value);
 void bpf_fd_array_map_clear(struct bpf_map *map);
 int bpf_fd_htab_map_update_elem(struct bpf_map *map, struct file *map_file,
 				void *key, void *value, u64 map_flags);
+int bpf_fd_htab_map_lookup_elem(struct bpf_map *map, void *key, u32 *value);
 
 /* memcpy that is used with 8-byte aligned pointers, power-of-8 size and
  * forced to use 'long' read/writes to try to atomically copy long counters.
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index ecb43542246e..d771a3872500 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -335,6 +335,26 @@ static void *fd_array_map_lookup_elem(struct bpf_map *map, void *key)
 }
 
 /* only called from syscall */
+int bpf_fd_array_map_lookup_elem(struct bpf_map *map, void *key, u32 *value)
+{
+	void **elem, *ptr;
+	int ret =  0;
+
+	if (!map->ops->map_fd_sys_lookup_elem)
+		return -ENOTSUPP;
+
+	rcu_read_lock();
+	elem = array_map_lookup_elem(map, key);
+	if (elem && (ptr = READ_ONCE(*elem)))
+		*value = map->ops->map_fd_sys_lookup_elem(ptr);
+	else
+		ret = -ENOENT;
+	rcu_read_unlock();
+
+	return ret;
+}
+
+/* only called from syscall */
 int bpf_fd_array_map_update_elem(struct bpf_map *map, struct file *map_file,
 				 void *key, void *value, u64 map_flags)
 {
@@ -400,6 +420,11 @@ static void prog_fd_array_put_ptr(void *ptr)
 	bpf_prog_put(ptr);
 }
 
+static u32 prog_fd_array_sys_lookup_elem(void *ptr)
+{
+	return ((struct bpf_prog *)ptr)->aux->id;
+}
+
 /* decrement refcnt of all bpf_progs that are stored in this map */
 void bpf_fd_array_map_clear(struct bpf_map *map)
 {
@@ -418,6 +443,7 @@ const struct bpf_map_ops prog_array_map_ops = {
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = prog_fd_array_get_ptr,
 	.map_fd_put_ptr = prog_fd_array_put_ptr,
+	.map_fd_sys_lookup_elem = prog_fd_array_sys_lookup_elem,
 };
 
 static struct bpf_event_entry *bpf_event_entry_gen(struct file *perf_file,
@@ -585,4 +611,5 @@ const struct bpf_map_ops array_of_maps_map_ops = {
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = bpf_map_fd_get_ptr,
 	.map_fd_put_ptr = bpf_map_fd_put_ptr,
+	.map_fd_sys_lookup_elem = bpf_map_fd_sys_lookup_elem,
 };
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 004334ea13ba..4fb463172aa8 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -1244,6 +1244,26 @@ static void fd_htab_map_free(struct bpf_map *map)
 }
 
 /* only called from syscall */
+int bpf_fd_htab_map_lookup_elem(struct bpf_map *map, void *key, u32 *value)
+{
+	void **ptr;
+	int ret = 0;
+
+	if (!map->ops->map_fd_sys_lookup_elem)
+		return -ENOTSUPP;
+
+	rcu_read_lock();
+	ptr = htab_map_lookup_elem(map, key);
+	if (ptr)
+		*value = map->ops->map_fd_sys_lookup_elem(READ_ONCE(*ptr));
+	else
+		ret = -ENOENT;
+	rcu_read_unlock();
+
+	return ret;
+}
+
+/* only called from syscall */
 int bpf_fd_htab_map_update_elem(struct bpf_map *map, struct file *map_file,
 				void *key, void *value, u64 map_flags)
 {
@@ -1305,4 +1325,5 @@ const struct bpf_map_ops htab_of_maps_map_ops = {
 	.map_delete_elem = htab_map_delete_elem,
 	.map_fd_get_ptr = bpf_map_fd_get_ptr,
 	.map_fd_put_ptr = bpf_map_fd_put_ptr,
+	.map_fd_sys_lookup_elem = bpf_map_fd_sys_lookup_elem,
 };
diff --git a/kernel/bpf/map_in_map.c b/kernel/bpf/map_in_map.c
index 59bcdf821ae4..1da574612bea 100644
--- a/kernel/bpf/map_in_map.c
+++ b/kernel/bpf/map_in_map.c
@@ -95,3 +95,8 @@ void bpf_map_fd_put_ptr(void *ptr)
 	 */
 	bpf_map_put(ptr);
 }
+
+u32 bpf_map_fd_sys_lookup_elem(void *ptr)
+{
+	return ((struct bpf_map *)ptr)->id;
+}
diff --git a/kernel/bpf/map_in_map.h b/kernel/bpf/map_in_map.h
index 177fadb689dc..6183db9ec08c 100644
--- a/kernel/bpf/map_in_map.h
+++ b/kernel/bpf/map_in_map.h
@@ -19,5 +19,6 @@ bool bpf_map_meta_equal(const struct bpf_map *meta0,
 void *bpf_map_fd_get_ptr(struct bpf_map *map, struct file *map_file,
 			 int ufd);
 void bpf_map_fd_put_ptr(void *ptr);
+u32 bpf_map_fd_sys_lookup_elem(void *ptr);
 
 #endif
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 8942c820d620..4409ccca8831 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -24,6 +24,13 @@
 #include <linux/kernel.h>
 #include <linux/idr.h>
 
+#define IS_FD_ARRAY(map) ((map)->map_type == BPF_MAP_TYPE_PROG_ARRAY || \
+			   (map)->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY || \
+			   (map)->map_type == BPF_MAP_TYPE_CGROUP_ARRAY || \
+			   (map)->map_type == BPF_MAP_TYPE_ARRAY_OF_MAPS)
+#define IS_FD_HASH(map) ((map)->map_type == BPF_MAP_TYPE_HASH_OF_MAPS)
+#define IS_FD_MAP(map) (IS_FD_ARRAY(map) || IS_FD_HASH(map))
+
 DEFINE_PER_CPU(int, bpf_prog_active);
 static DEFINE_IDR(prog_idr);
 static DEFINE_SPINLOCK(prog_idr_lock);
@@ -411,6 +418,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 	    map->map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH ||
 	    map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
 		value_size = round_up(map->value_size, 8) * num_possible_cpus();
+	else if (IS_FD_MAP(map))
+		value_size = sizeof(u32);
 	else
 		value_size = map->value_size;
 
@@ -426,9 +435,10 @@ static int map_lookup_elem(union bpf_attr *attr)
 		err = bpf_percpu_array_copy(map, key, value);
 	} else if (map->map_type == BPF_MAP_TYPE_STACK_TRACE) {
 		err = bpf_stackmap_copy(map, key, value);
-	} else if (map->map_type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
-		   map->map_type == BPF_MAP_TYPE_HASH_OF_MAPS) {
-		err = -ENOTSUPP;
+	} else if (IS_FD_ARRAY(map)) {
+		err = bpf_fd_array_map_lookup_elem(map, key, value);
+	} else if (IS_FD_HASH(map)) {
+		err = bpf_fd_htab_map_lookup_elem(map, key, value);
 	} else {
 		rcu_read_lock();
 		ptr = map->ops->map_lookup_elem(map, key);
-- 
2.9.3
