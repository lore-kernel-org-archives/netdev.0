From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 3/9] bpf: introduce percpu verion of lookup/update in bpf_map_ops
Date: Mon, 11 Jan 2016 23:56:55 +0800
Message-ID: <1452527821-12276-4-git-send-email-tom.leiming@gmail.com>
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

This patch is preparing for supporting percpu map, which
will be done in the following patches.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 include/linux/bpf.h   |  5 +++++
 kernel/bpf/arraymap.c |  6 ++++++
 kernel/bpf/bpf_map.h  |  4 ++++
 kernel/bpf/hashtab.c  |  4 ++++
 kernel/bpf/map.c      | 11 +++++++++++
 5 files changed, 30 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 83d1926..7fa339f 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -25,6 +25,11 @@ struct bpf_map_ops {
 	int (*map_update_elem)(struct bpf_map *map, void *key, void *value, u64 flags);
 	int (*map_delete_elem)(struct bpf_map *map, void *key);
 
+	/* funcs callable from userspace and from eBPF programs */
+	void *(*map_lookup_elem_percpu)(struct bpf_map *map, void *key, u32 cpu);
+	int (*map_update_elem_percpu)(struct bpf_map *map, void *key,
+			void *value, u64 flags, u32 cpu);
+
 	/* funcs called by prog_array and perf_event_array map */
 	void *(*map_fd_get_ptr) (struct bpf_map *map, int fd);
 	void (*map_fd_put_ptr) (void *ptr);
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 9ad9031..20b9f2c 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -139,6 +139,8 @@ static const struct bpf_map_ops array_ops = {
 	.map_lookup_elem = array_map_lookup_elem,
 	.map_update_elem = array_map_update_elem,
 	.map_delete_elem = map_delete_elem_nop,
+	.map_lookup_elem_percpu = map_lookup_elem_percpu_nop,
+	.map_update_elem_percpu = map_update_elem_percpu_nop,
 };
 
 static struct bpf_map_type_list array_type __read_mostly = {
@@ -258,6 +260,8 @@ static const struct bpf_map_ops prog_array_ops = {
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = prog_fd_array_get_ptr,
 	.map_fd_put_ptr = prog_fd_array_put_ptr,
+	.map_lookup_elem_percpu = map_lookup_elem_percpu_nop,
+	.map_update_elem_percpu = map_update_elem_percpu_nop,
 };
 
 static struct bpf_map_type_list prog_array_type __read_mostly = {
@@ -324,6 +328,8 @@ static const struct bpf_map_ops perf_event_array_ops = {
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = perf_event_fd_array_get_ptr,
 	.map_fd_put_ptr = perf_event_fd_array_put_ptr,
+	.map_lookup_elem_percpu = map_lookup_elem_percpu_nop,
+	.map_update_elem_percpu = map_update_elem_percpu_nop,
 };
 
 static struct bpf_map_type_list perf_event_array_type __read_mostly = {
diff --git a/kernel/bpf/bpf_map.h b/kernel/bpf/bpf_map.h
index 7e596c1..adab4e6 100644
--- a/kernel/bpf/bpf_map.h
+++ b/kernel/bpf/bpf_map.h
@@ -5,5 +5,9 @@
 
 extern void *map_lookup_elem_nop(struct bpf_map *map, void *key);
 extern int map_delete_elem_nop(struct bpf_map *map, void *key);
+extern void *map_lookup_elem_percpu_nop(struct bpf_map *map, void *key,
+		u32 cpu);
+extern int map_update_elem_percpu_nop(struct bpf_map *map, void *key,
+		void *value, u64 flags, u32 cpu);
 
 #endif
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index c5b30fd..893e2e4 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -14,6 +14,8 @@
 #include <linux/filter.h>
 #include <linux/vmalloc.h>
 
+#include "bpf_map.h"
+
 struct bucket {
 	struct hlist_head head;
 	raw_spinlock_t lock;
@@ -384,6 +386,8 @@ static const struct bpf_map_ops htab_ops = {
 	.map_lookup_elem = htab_map_lookup_elem,
 	.map_update_elem = htab_map_update_elem,
 	.map_delete_elem = htab_map_delete_elem,
+	.map_lookup_elem_percpu = map_lookup_elem_percpu_nop,
+	.map_update_elem_percpu = map_update_elem_percpu_nop,
 };
 
 static struct bpf_map_type_list htab_type __read_mostly = {
diff --git a/kernel/bpf/map.c b/kernel/bpf/map.c
index bf113fb..b94458a 100644
--- a/kernel/bpf/map.c
+++ b/kernel/bpf/map.c
@@ -24,3 +24,14 @@ int map_delete_elem_nop(struct bpf_map *map, void *key)
 	return -EINVAL;
 }
 
+void *map_lookup_elem_percpu_nop(struct bpf_map *map, void *key, u32 cpu)
+{
+	return NULL;
+}
+
+int map_update_elem_percpu_nop(struct bpf_map *map, void *key, void *value,
+		u64 flags, u32 cpu)
+{
+	return -EINVAL;
+}
+
-- 
1.9.1
