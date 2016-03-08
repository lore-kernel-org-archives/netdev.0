From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 08/12] samples/bpf: add map_flags to bpf loader
Date: Mon, 7 Mar 2016 21:57:20 -0800
Message-ID: <1457416641-306326-9-git-send-email-ast@fb.com>
References: <1457416641-306326-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457416641-306326-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

note old loader is compatible with new kernel.
map_flags are optional

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/bpf_helpers.h   |  1 +
 samples/bpf/bpf_load.c      |  3 ++-
 samples/bpf/fds_example.c   |  2 +-
 samples/bpf/libbpf.c        |  5 +++--
 samples/bpf/libbpf.h        |  2 +-
 samples/bpf/sock_example.c  |  2 +-
 samples/bpf/test_maps.c     | 19 ++++++++++++-------
 samples/bpf/test_verifier.c |  4 ++--
 8 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 811bcca0f29d..9363500131a7 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -61,6 +61,7 @@ struct bpf_map_def {
 	unsigned int key_size;
 	unsigned int value_size;
 	unsigned int max_entries;
+	unsigned int map_flags;
 };
 
 static int (*bpf_skb_store_bytes)(void *ctx, int off, void *from, int len, int flags) =
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index d16864293c00..58f86bd11b3d 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -157,7 +157,8 @@ static int load_maps(struct bpf_map_def *maps, int len)
 		map_fd[i] = bpf_create_map(maps[i].type,
 					   maps[i].key_size,
 					   maps[i].value_size,
-					   maps[i].max_entries);
+					   maps[i].max_entries,
+					   maps[i].map_flags);
 		if (map_fd[i] < 0) {
 			printf("failed to create a map: %d %s\n",
 			       errno, strerror(errno));
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index e2fd16c3d0f0..625e797be6ef 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -44,7 +44,7 @@ static void usage(void)
 static int bpf_map_create(void)
 {
 	return bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(uint32_t),
-			      sizeof(uint32_t), 1024);
+			      sizeof(uint32_t), 1024, 0);
 }
 
 static int bpf_prog_create(const char *object)
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 65a8d48d2799..9969e35550c3 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -19,13 +19,14 @@ static __u64 ptr_to_u64(void *ptr)
 }
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries)
+		   int max_entries, int map_flags)
 {
 	union bpf_attr attr = {
 		.map_type = map_type,
 		.key_size = key_size,
 		.value_size = value_size,
-		.max_entries = max_entries
+		.max_entries = max_entries,
+		.map_flags = map_flags,
 	};
 
 	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 014aacf916e4..364582b77888 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -5,7 +5,7 @@
 struct bpf_insn;
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries);
+		   int max_entries, int map_flags);
 int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
 int bpf_lookup_elem(int fd, void *key, void *value);
 int bpf_delete_elem(int fd, void *key);
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index a0ce251c5390..28b60baa9fa8 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -34,7 +34,7 @@ static int test_sock(void)
 	long long value = 0, tcp_cnt, udp_cnt, icmp_cnt;
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value),
-				256);
+				256, 0);
 	if (map_fd < 0) {
 		printf("failed to create map '%s'\n", strerror(errno));
 		goto cleanup;
diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index ad466ed33093..7bd9edd02d9b 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -2,6 +2,7 @@
  * Testsuite for eBPF maps
  *
  * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2016 Facebook
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -17,13 +18,16 @@
 #include <stdlib.h>
 #include "libbpf.h"
 
+static int map_flags;
+
 /* sanity tests for map API */
 static void test_hashmap_sanity(int i, void *data)
 {
 	long long key, next_key, value;
 	int map_fd;
 
-	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 2);
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+				2, map_flags);
 	if (map_fd < 0) {
 		printf("failed to create hashmap '%s'\n", strerror(errno));
 		exit(1);
@@ -99,7 +103,7 @@ static void test_percpu_hashmap_sanity(int task, void *data)
 	int map_fd, i;
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
-				sizeof(value[0]), 2);
+				sizeof(value[0]), 2, map_flags);
 	if (map_fd < 0) {
 		printf("failed to create hashmap '%s'\n", strerror(errno));
 		exit(1);
@@ -188,7 +192,8 @@ static void test_arraymap_sanity(int i, void *data)
 	int key, next_key, map_fd;
 	long long value;
 
-	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value), 2);
+	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value),
+				2, 0);
 	if (map_fd < 0) {
 		printf("failed to create arraymap '%s'\n", strerror(errno));
 		exit(1);
@@ -244,7 +249,7 @@ static void test_percpu_arraymap_many_keys(void)
 	int key, map_fd, i;
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
-				sizeof(values[0]), nr_keys);
+				sizeof(values[0]), nr_keys, 0);
 	if (map_fd < 0) {
 		printf("failed to create per-cpu arraymap '%s'\n",
 		       strerror(errno));
@@ -275,7 +280,7 @@ static void test_percpu_arraymap_sanity(int i, void *data)
 	int key, next_key, map_fd;
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
-				sizeof(values[0]), 2);
+				sizeof(values[0]), 2, 0);
 	if (map_fd < 0) {
 		printf("failed to create arraymap '%s'\n", strerror(errno));
 		exit(1);
@@ -336,7 +341,7 @@ static void test_map_large(void)
 
 	/* allocate 4Mbyte of memory */
 	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
-				MAP_SIZE);
+				MAP_SIZE, map_flags);
 	if (map_fd < 0) {
 		printf("failed to create large map '%s'\n", strerror(errno));
 		exit(1);
@@ -421,7 +426,7 @@ static void test_map_parallel(void)
 	int data[2];
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
-				MAP_SIZE);
+				MAP_SIZE, map_flags);
 	if (map_fd < 0) {
 		printf("failed to create map for parallel test '%s'\n",
 		       strerror(errno));
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 563c507c0a09..4b51a9039c0d 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -1198,7 +1198,7 @@ static int create_map(void)
 	int map_fd;
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH,
-				sizeof(long long), sizeof(long long), 1024);
+				sizeof(long long), sizeof(long long), 1024, 0);
 	if (map_fd < 0)
 		printf("failed to create map '%s'\n", strerror(errno));
 
@@ -1210,7 +1210,7 @@ static int create_prog_array(void)
 	int map_fd;
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_PROG_ARRAY,
-				sizeof(int), sizeof(int), 4);
+				sizeof(int), sizeof(int), 4, 0);
 	if (map_fd < 0)
 		printf("failed to create prog_array '%s'\n", strerror(errno));
 
-- 
2.8.0.rc1
