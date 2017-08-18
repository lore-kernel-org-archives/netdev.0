From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/2] bpf: Allow numa selection in INNER_LRU_HASH_PREALLOC test of map_perf_test
Date: Fri, 18 Aug 2017 11:28:01 -0700
Message-ID: <20170818182801.2518162-3-kafai@fb.com>
References: <20170818182801.2518162-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54648 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751558AbdHRS2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 14:28:04 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7IIN9M3020033
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 11:28:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2ce567g2t2-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 11:28:03 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 f80ed6ea844211e7afb00002c99293a0-3a617150 for <netdev@vger.kernel.org>;        Fri,
 18 Aug 2017 11:28:02 -0700
In-Reply-To: <20170818182801.2518162-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the needed changes to allow each process of
the INNER_LRU_HASH_PREALLOC test to provide its numa node id
when creating the lru map.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@fb.com>
---
 samples/bpf/bpf_load.c                    | 21 ++++++++++++--------
 samples/bpf/bpf_load.h                    |  1 +
 samples/bpf/map_perf_test_kern.c          |  2 ++
 samples/bpf/map_perf_test_user.c          | 12 +++++++++---
 tools/include/uapi/linux/bpf.h            | 10 +++++++++-
 tools/lib/bpf/bpf.c                       | 32 +++++++++++++++++++++++++++----
 tools/lib/bpf/bpf.h                       |  6 ++++++
 tools/testing/selftests/bpf/bpf_helpers.h |  1 +
 8 files changed, 69 insertions(+), 16 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index a8552b8a2ab6..6aa50098dfb8 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -201,7 +201,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 static int load_maps(struct bpf_map_data *maps, int nr_maps,
 		     fixup_map_cb fixup_map)
 {
-	int i;
+	int i, numa_node;
 
 	for (i = 0; i < nr_maps; i++) {
 		if (fixup_map) {
@@ -213,21 +213,26 @@ static int load_maps(struct bpf_map_data *maps, int nr_maps,
 			}
 		}
 
+		numa_node = maps[i].def.map_flags & BPF_F_NUMA_NODE ?
+			maps[i].def.numa_node : -1;
+
 		if (maps[i].def.type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
 		    maps[i].def.type == BPF_MAP_TYPE_HASH_OF_MAPS) {
 			int inner_map_fd = map_fd[maps[i].def.inner_map_idx];
 
-			map_fd[i] = bpf_create_map_in_map(maps[i].def.type,
+			map_fd[i] = bpf_create_map_in_map_node(maps[i].def.type,
 							maps[i].def.key_size,
 							inner_map_fd,
 							maps[i].def.max_entries,
-							maps[i].def.map_flags);
+							maps[i].def.map_flags,
+							numa_node);
 		} else {
-			map_fd[i] = bpf_create_map(maps[i].def.type,
-						   maps[i].def.key_size,
-						   maps[i].def.value_size,
-						   maps[i].def.max_entries,
-						   maps[i].def.map_flags);
+			map_fd[i] = bpf_create_map_node(maps[i].def.type,
+							maps[i].def.key_size,
+							maps[i].def.value_size,
+							maps[i].def.max_entries,
+							maps[i].def.map_flags,
+							numa_node);
 		}
 		if (map_fd[i] < 0) {
 			printf("failed to create a map: %d %s\n",
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index ca0563d04744..453e3226b4ce 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -13,6 +13,7 @@ struct bpf_map_def {
 	unsigned int max_entries;
 	unsigned int map_flags;
 	unsigned int inner_map_idx;
+	unsigned int numa_node;
 };
 
 struct bpf_map_data {
diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
index 245165817fbe..ca3b22ed577a 100644
--- a/samples/bpf/map_perf_test_kern.c
+++ b/samples/bpf/map_perf_test_kern.c
@@ -40,6 +40,8 @@ struct bpf_map_def SEC("maps") inner_lru_hash_map = {
 	.key_size = sizeof(u32),
 	.value_size = sizeof(long),
 	.max_entries = MAX_ENTRIES,
+	.map_flags = BPF_F_NUMA_NODE,
+	.numa_node = 0,
 };
 
 struct bpf_map_def SEC("maps") array_of_lru_hashs = {
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 1a8894b5ac51..bccbf8478e43 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -97,14 +97,20 @@ static void do_test_lru(enum test_type test, int cpu)
 
 	if (test == INNER_LRU_HASH_PREALLOC) {
 		int outer_fd = map_fd[array_of_lru_hashs_idx];
+		unsigned int mycpu, mynode;
 
 		assert(cpu < MAX_NR_CPUS);
 
 		if (cpu) {
+			ret = syscall(__NR_getcpu, &mycpu, &mynode, NULL);
+			assert(!ret);
+
 			inner_lru_map_fds[cpu] =
-				bpf_create_map(BPF_MAP_TYPE_LRU_HASH,
-					       sizeof(uint32_t), sizeof(long),
-					       inner_lru_hash_size, 0);
+				bpf_create_map_node(BPF_MAP_TYPE_LRU_HASH,
+						    sizeof(uint32_t),
+						    sizeof(long),
+						    inner_lru_hash_size, 0,
+						    mynode);
 			if (inner_lru_map_fds[cpu] == -1) {
 				printf("cannot create BPF_MAP_TYPE_LRU_HASH %s(%d)\n",
 				       strerror(errno), errno);
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 2d97dd27c8f6..f8f6377fd541 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -168,6 +168,7 @@ enum bpf_sockmap_flags {
 #define BPF_NOEXIST	1 /* create new element if it didn't exist */
 #define BPF_EXIST	2 /* update existing element */
 
+/* flags for BPF_MAP_CREATE command */
 #define BPF_F_NO_PREALLOC	(1U << 0)
 /* Instead of having one common LRU list in the
  * BPF_MAP_TYPE_LRU_[PERCPU_]HASH map, use a percpu LRU list
@@ -176,6 +177,8 @@ enum bpf_sockmap_flags {
  * across different LRU lists.
  */
 #define BPF_F_NO_COMMON_LRU	(1U << 1)
+/* Specify numa node during map creation */
+#define BPF_F_NUMA_NODE		(1U << 2)
 
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
@@ -183,8 +186,13 @@ union bpf_attr {
 		__u32	key_size;	/* size of key in bytes */
 		__u32	value_size;	/* size of value in bytes */
 		__u32	max_entries;	/* max number of entries in a map */
-		__u32	map_flags;	/* prealloc or not */
+		__u32	map_flags;	/* BPF_MAP_CREATE related
+					 * flags defined above.
+					 */
 		__u32	inner_map_fd;	/* fd pointing to the inner map */
+		__u32	numa_node;	/* numa node (effective only if
+					 * BPF_F_NUMA_NODE is set).
+					 */
 	};
 
 	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 77660157a684..a0717610b116 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -57,8 +57,9 @@ static inline int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
 	return syscall(__NR_bpf, cmd, attr, size);
 }
 
-int bpf_create_map(enum bpf_map_type map_type, int key_size,
-		   int value_size, int max_entries, __u32 map_flags)
+int bpf_create_map_node(enum bpf_map_type map_type, int key_size,
+			int value_size, int max_entries, __u32 map_flags,
+			int node)
 {
 	union bpf_attr attr;
 
@@ -69,12 +70,24 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size,
 	attr.value_size = value_size;
 	attr.max_entries = max_entries;
 	attr.map_flags = map_flags;
+	if (node >= 0) {
+		attr.map_flags |= BPF_F_NUMA_NODE;
+		attr.numa_node = node;
+	}
 
 	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
-			  int inner_map_fd, int max_entries, __u32 map_flags)
+int bpf_create_map(enum bpf_map_type map_type, int key_size,
+		   int value_size, int max_entries, __u32 map_flags)
+{
+	return bpf_create_map_node(map_type, key_size, value_size,
+				   max_entries, map_flags, -1);
+}
+
+int bpf_create_map_in_map_node(enum bpf_map_type map_type, int key_size,
+			       int inner_map_fd, int max_entries,
+			       __u32 map_flags, int node)
 {
 	union bpf_attr attr;
 
@@ -86,10 +99,21 @@ int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
 	attr.inner_map_fd = inner_map_fd;
 	attr.max_entries = max_entries;
 	attr.map_flags = map_flags;
+	if (node >= 0) {
+		attr.map_flags |= BPF_F_NUMA_NODE;
+		attr.numa_node = node;
+	}
 
 	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
+int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
+			  int inner_map_fd, int max_entries, __u32 map_flags)
+{
+	return bpf_create_map_in_map_node(map_type, key_size, inner_map_fd,
+					  max_entries, map_flags, -1);
+}
+
 int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index eaee585c1cea..90e9d4e85d08 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -24,8 +24,14 @@
 #include <linux/bpf.h>
 #include <stddef.h>
 
+int bpf_create_map_node(enum bpf_map_type map_type, int key_size,
+			int value_size, int max_entries, __u32 map_flags,
+			int node);
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries, __u32 map_flags);
+int bpf_create_map_in_map_node(enum bpf_map_type map_type, int key_size,
+			       int inner_map_fd, int max_entries,
+			       __u32 map_flags, int node);
 int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
 			  int inner_map_fd, int max_entries, __u32 map_flags);
 
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index 73092d4a898e..98f3be26d390 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -94,6 +94,7 @@ struct bpf_map_def {
 	unsigned int max_entries;
 	unsigned int map_flags;
 	unsigned int inner_map_idx;
+	unsigned int numa_node;
 };
 
 static int (*bpf_skb_load_bytes)(void *ctx, int off, void *to, int len) =
-- 
2.9.5
