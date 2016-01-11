From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 2/9] bpf: array map: use pre-defined nop map function
Date: Mon, 11 Jan 2016 23:56:54 +0800
Message-ID: <1452527821-12276-3-git-send-email-tom.leiming@gmail.com>
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

So that we can remove the per-map nop map fucntions.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/arraymap.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index b0799bc..9ad9031 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -17,6 +17,8 @@
 #include <linux/filter.h>
 #include <linux/perf_event.h>
 
+#include "bpf_map.h"
+
 /* Called from syscall */
 static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 {
@@ -115,12 +117,6 @@ static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
 	return 0;
 }
 
-/* Called from syscall or from eBPF program */
-static int array_map_delete_elem(struct bpf_map *map, void *key)
-{
-	return -EINVAL;
-}
-
 /* Called when map->refcnt goes to zero, either from workqueue or from syscall */
 static void array_map_free(struct bpf_map *map)
 {
@@ -142,7 +138,7 @@ static const struct bpf_map_ops array_ops = {
 	.map_get_next_key = array_map_get_next_key,
 	.map_lookup_elem = array_map_lookup_elem,
 	.map_update_elem = array_map_update_elem,
-	.map_delete_elem = array_map_delete_elem,
+	.map_delete_elem = map_delete_elem_nop,
 };
 
 static struct bpf_map_type_list array_type __read_mostly = {
@@ -178,11 +174,6 @@ static void fd_array_map_free(struct bpf_map *map)
 	kvfree(array);
 }
 
-static void *fd_array_map_lookup_elem(struct bpf_map *map, void *key)
-{
-	return NULL;
-}
-
 /* only called from syscall */
 static int fd_array_map_update_elem(struct bpf_map *map, void *key,
 				    void *value, u64 map_flags)
@@ -262,7 +253,7 @@ static const struct bpf_map_ops prog_array_ops = {
 	.map_alloc = fd_array_map_alloc,
 	.map_free = fd_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
-	.map_lookup_elem = fd_array_map_lookup_elem,
+	.map_lookup_elem = map_lookup_elem_nop,
 	.map_update_elem = fd_array_map_update_elem,
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = prog_fd_array_get_ptr,
@@ -328,7 +319,7 @@ static const struct bpf_map_ops perf_event_array_ops = {
 	.map_alloc = fd_array_map_alloc,
 	.map_free = perf_event_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
-	.map_lookup_elem = fd_array_map_lookup_elem,
+	.map_lookup_elem = map_lookup_elem_nop,
 	.map_update_elem = fd_array_map_update_elem,
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = perf_event_fd_array_get_ptr,
-- 
1.9.1
