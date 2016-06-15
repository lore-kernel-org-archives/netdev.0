From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf, maps: extend map_fd_get_ptr arguments
Date: Wed, 15 Jun 2016 22:47:13 +0200
Message-ID: <7d613ab3d6d71f9d21fd2574dcb99fd33ae1d3d3.1466021686.git.daniel@iogearbox.net>
References: <cover.1466021686.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42938 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbcFOUr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 16:47:28 -0400
In-Reply-To: <cover.1466021686.git.daniel@iogearbox.net>
In-Reply-To: <cover.1466021686.git.daniel@iogearbox.net>
References: <cover.1466021686.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends map_fd_get_ptr() callback that is used by fd array
maps, so that struct file pointer from the related map can be passed
in. It's safe to remove map_update_elem() callback for the two maps since
this is only allowed from syscall side, but not from eBPF programs for these
two map types. Like in per-cpu map case, bpf_fd_array_map_update_elem()
needs to be called directly here due to the extra argument.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h   | 12 +++++++++---
 kernel/bpf/arraymap.c | 16 +++++++++-------
 kernel/bpf/syscall.c  |  6 ++++++
 3 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 29b5a1a..d7b43e7 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -29,8 +29,9 @@ struct bpf_map_ops {
 	int (*map_delete_elem)(struct bpf_map *map, void *key);
 
 	/* funcs called by prog_array and perf_event_array map */
-	void *(*map_fd_get_ptr) (struct bpf_map *map, int fd);
-	void (*map_fd_put_ptr) (void *ptr);
+	void *(*map_fd_get_ptr)(struct bpf_map *map, struct file *map_file,
+				int fd);
+	void (*map_fd_put_ptr)(void *ptr);
 };
 
 struct bpf_map {
@@ -169,7 +170,7 @@ struct bpf_array {
 
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
-void bpf_fd_array_map_clear(struct bpf_map *map);
+
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
@@ -207,8 +208,13 @@ int bpf_percpu_hash_update(struct bpf_map *map, void *key, void *value,
 			   u64 flags);
 int bpf_percpu_array_update(struct bpf_map *map, void *key, void *value,
 			    u64 flags);
+
 int bpf_stackmap_copy(struct bpf_map *map, void *key, void *value);
 
+int bpf_fd_array_map_update_elem(struct bpf_map *map, struct file *map_file,
+				 void *key, void *value, u64 map_flags);
+void bpf_fd_array_map_clear(struct bpf_map *map);
+
 /* memcpy that is used with 8-byte aligned pointers, power-of-8 size and
  * forced to use 'long' read/writes to try to atomically copy long counters.
  * Best-effort only.  No barriers here, since it _will_ race with concurrent
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 76d5a79..bfedcbd 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -328,8 +328,8 @@ static void *fd_array_map_lookup_elem(struct bpf_map *map, void *key)
 }
 
 /* only called from syscall */
-static int fd_array_map_update_elem(struct bpf_map *map, void *key,
-				    void *value, u64 map_flags)
+int bpf_fd_array_map_update_elem(struct bpf_map *map, struct file *map_file,
+				 void *key, void *value, u64 map_flags)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	void *new_ptr, *old_ptr;
@@ -342,7 +342,7 @@ static int fd_array_map_update_elem(struct bpf_map *map, void *key,
 		return -E2BIG;
 
 	ufd = *(u32 *)value;
-	new_ptr = map->ops->map_fd_get_ptr(map, ufd);
+	new_ptr = map->ops->map_fd_get_ptr(map, map_file, ufd);
 	if (IS_ERR(new_ptr))
 		return PTR_ERR(new_ptr);
 
@@ -371,10 +371,12 @@ static int fd_array_map_delete_elem(struct bpf_map *map, void *key)
 	}
 }
 
-static void *prog_fd_array_get_ptr(struct bpf_map *map, int fd)
+static void *prog_fd_array_get_ptr(struct bpf_map *map,
+				   struct file *map_file, int fd)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	struct bpf_prog *prog = bpf_prog_get(fd);
+
 	if (IS_ERR(prog))
 		return prog;
 
@@ -382,6 +384,7 @@ static void *prog_fd_array_get_ptr(struct bpf_map *map, int fd)
 		bpf_prog_put(prog);
 		return ERR_PTR(-EINVAL);
 	}
+
 	return prog;
 }
 
@@ -407,7 +410,6 @@ static const struct bpf_map_ops prog_array_ops = {
 	.map_free = fd_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
 	.map_lookup_elem = fd_array_map_lookup_elem,
-	.map_update_elem = fd_array_map_update_elem,
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = prog_fd_array_get_ptr,
 	.map_fd_put_ptr = prog_fd_array_put_ptr,
@@ -431,7 +433,8 @@ static void perf_event_array_map_free(struct bpf_map *map)
 	fd_array_map_free(map);
 }
 
-static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
+static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
+					 struct file *map_file, int fd)
 {
 	struct perf_event *event;
 	const struct perf_event_attr *attr;
@@ -474,7 +477,6 @@ static const struct bpf_map_ops perf_event_array_ops = {
 	.map_free = perf_event_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
 	.map_lookup_elem = fd_array_map_lookup_elem,
-	.map_update_elem = fd_array_map_update_elem,
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = perf_event_fd_array_get_ptr,
 	.map_fd_put_ptr = perf_event_fd_array_put_ptr,
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index fc3adcd..c23a4e93 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -392,6 +392,12 @@ static int map_update_elem(union bpf_attr *attr)
 		err = bpf_percpu_hash_update(map, key, value, attr->flags);
 	} else if (map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY) {
 		err = bpf_percpu_array_update(map, key, value, attr->flags);
+	} else if (map->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY ||
+		   map->map_type == BPF_MAP_TYPE_PROG_ARRAY) {
+		rcu_read_lock();
+		err = bpf_fd_array_map_update_elem(map, f.file, key, value,
+						   attr->flags);
+		rcu_read_unlock();
 	} else {
 		rcu_read_lock();
 		err = map->ops->map_update_elem(map, key, value, attr->flags);
-- 
1.9.3
