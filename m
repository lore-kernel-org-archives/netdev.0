From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 6/6] bpf: lru: Add map-in-map LRU example
Date: Fri, 14 Apr 2017 10:30:30 -0700
Message-ID: <20170414173030.2853860-7-kafai@fb.com>
References: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59603 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754026AbdDNRac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 13:30:32 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v3EHOAZd009842
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 29tp4aaphq-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 0ea0a230213811e7b85a0002c9dfb610-59de09a0 for <netdev@vger.kernel.org>;        Fri,
 14 Apr 2017 10:30:30 -0700
In-Reply-To: <20170414173030.2853860-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a map-in-map LRU example.
If we know only a subset of cores will use the
LRU, we can allocate a common LRU list per targeting core
and store it into an array-of-hashs.

It allows using the common LRU map with map-update performance
comparable to the BPF_F_NO_COMMON_LRU map but without wasting memory
on the unused cores that we know they will never access the LRU map.

BPF_F_NO_COMMON_LRU:
> map_perf_test 32 8 10000000 10000000 | awk '{sum += $3}END{print sum}'
9234314 (9.23M/s)

map-in-map LRU:
> map_perf_test 512 8 1260000 80000000 | awk '{sum += $3}END{print sum}'
9962743 (9.96M/s)

Notes that the max_entries for the map-in-map LRU test is 1260000 which
is the max_entries for each inner LRU map.  8 processes have been
started, so 8 * 1260000 = 10080000 (~10M) which is close to what is
used in the BPF_F_NO_COMMON_LRU test.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 samples/bpf/map_perf_test_kern.c | 34 ++++++++++++++++++++--
 samples/bpf/map_perf_test_user.c | 62 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 93 insertions(+), 3 deletions(-)

diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
index 404ed53b8a53..245165817fbe 100644
--- a/samples/bpf/map_perf_test_kern.c
+++ b/samples/bpf/map_perf_test_kern.c
@@ -11,6 +11,7 @@
 #include "bpf_helpers.h"
 
 #define MAX_ENTRIES 1000
+#define MAX_NR_CPUS 1024
 
 struct bpf_map_def SEC("maps") hash_map = {
 	.type = BPF_MAP_TYPE_HASH,
@@ -34,6 +35,19 @@ struct bpf_map_def SEC("maps") nocommon_lru_hash_map = {
 	.map_flags = BPF_F_NO_COMMON_LRU,
 };
 
+struct bpf_map_def SEC("maps") inner_lru_hash_map = {
+	.type = BPF_MAP_TYPE_LRU_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = MAX_ENTRIES,
+};
+
+struct bpf_map_def SEC("maps") array_of_lru_hashs = {
+	.type = BPF_MAP_TYPE_ARRAY_OF_MAPS,
+	.key_size = sizeof(u32),
+	.max_entries = MAX_NR_CPUS,
+};
+
 struct bpf_map_def SEC("maps") percpu_hash_map = {
 	.type = BPF_MAP_TYPE_PERCPU_HASH,
 	.key_size = sizeof(u32),
@@ -154,13 +168,27 @@ int stress_lru_hmap_alloc(struct pt_regs *ctx)
 
 	test_case = dst6[7];
 
-	if (test_case == 0)
+	if (test_case == 0) {
 		ret = bpf_map_update_elem(&lru_hash_map, &key, &val, BPF_ANY);
-	else if (test_case == 1)
+	} else if (test_case == 1) {
 		ret = bpf_map_update_elem(&nocommon_lru_hash_map, &key, &val,
 					  BPF_ANY);
-	else
+	} else if (test_case == 2) {
+		void *nolocal_lru_map;
+		int cpu = bpf_get_smp_processor_id();
+
+		nolocal_lru_map = bpf_map_lookup_elem(&array_of_lru_hashs,
+						      &cpu);
+		if (!nolocal_lru_map) {
+			ret = -ENOENT;
+			goto done;
+		}
+
+		ret = bpf_map_update_elem(nolocal_lru_map, &key, &val,
+					  BPF_ANY);
+	} else {
 		ret = -EINVAL;
+	}
 
 done:
 	if (ret)
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 2a12f48b5c6d..6ac778153315 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -25,6 +25,7 @@
 #include "bpf_load.h"
 
 #define TEST_BIT(t) (1U << (t))
+#define MAX_NR_CPUS 1024
 
 static __u64 time_get_ns(void)
 {
@@ -44,6 +45,7 @@ enum test_type {
 	LPM_KMALLOC,
 	HASH_LOOKUP,
 	ARRAY_LOOKUP,
+	INNER_LRU_HASH_PREALLOC,
 	NR_TESTS,
 };
 
@@ -57,10 +59,14 @@ const char *test_map_names[NR_TESTS] = {
 	[LPM_KMALLOC] = "lpm_trie_map_alloc",
 	[HASH_LOOKUP] = "hash_map",
 	[ARRAY_LOOKUP] = "array_map",
+	[INNER_LRU_HASH_PREALLOC] = "inner_lru_hash_map",
 };
 
 static int test_flags = ~0;
 static uint32_t num_map_entries;
+static uint32_t inner_lru_hash_size;
+static int inner_lru_hash_idx = -1;
+static int array_of_lru_hashs_idx = -1;
 static uint32_t max_cnt = 1000000;
 
 static int check_test_flags(enum test_type t)
@@ -82,11 +88,42 @@ static void test_hash_prealloc(int cpu)
 
 static void do_test_lru(enum test_type test, int cpu)
 {
+	static int inner_lru_map_fds[MAX_NR_CPUS];
+
 	struct sockaddr_in6 in6 = { .sin6_family = AF_INET6 };
 	const char *test_name;
 	__u64 start_time;
 	int i, ret;
 
+	if (test == INNER_LRU_HASH_PREALLOC) {
+		int outer_fd = map_fd[array_of_lru_hashs_idx];
+
+		assert(cpu < MAX_NR_CPUS);
+
+		if (cpu) {
+			inner_lru_map_fds[cpu] =
+				bpf_create_map(BPF_MAP_TYPE_LRU_HASH,
+					       sizeof(uint32_t), sizeof(long),
+					       inner_lru_hash_size, 0);
+			if (inner_lru_map_fds[cpu] == -1) {
+				printf("cannot create BPF_MAP_TYPE_LRU_HASH %s(%d)\n",
+				       strerror(errno), errno);
+				exit(1);
+			}
+		} else {
+			inner_lru_map_fds[cpu] = map_fd[inner_lru_hash_idx];
+		}
+
+		ret = bpf_map_update_elem(outer_fd, &cpu,
+					  &inner_lru_map_fds[cpu],
+					  BPF_ANY);
+		if (ret) {
+			printf("cannot update ARRAY_OF_LRU_HASHS with key:%u. %s(%d)\n",
+			       cpu, strerror(errno), errno);
+			exit(1);
+		}
+	}
+
 	in6.sin6_addr.s6_addr16[0] = 0xdead;
 	in6.sin6_addr.s6_addr16[1] = 0xbeef;
 
@@ -96,6 +133,9 @@ static void do_test_lru(enum test_type test, int cpu)
 	} else if (test == NOCOMMON_LRU_HASH_PREALLOC) {
 		test_name = "nocommon_lru_hash_map_perf";
 		in6.sin6_addr.s6_addr16[7] = 1;
+	} else if (test == INNER_LRU_HASH_PREALLOC) {
+		test_name = "inner_lru_hash_map_perf";
+		in6.sin6_addr.s6_addr16[7] = 2;
 	} else {
 		assert(0);
 	}
@@ -120,6 +160,11 @@ static void test_nocommon_lru_hash_prealloc(int cpu)
 	do_test_lru(NOCOMMON_LRU_HASH_PREALLOC, cpu);
 }
 
+static void test_inner_lru_hash_prealloc(int cpu)
+{
+	do_test_lru(INNER_LRU_HASH_PREALLOC, cpu);
+}
+
 static void test_percpu_hash_prealloc(int cpu)
 {
 	__u64 start_time;
@@ -203,6 +248,7 @@ const test_func test_funcs[] = {
 	[LPM_KMALLOC] = test_lpm_kmalloc,
 	[HASH_LOOKUP] = test_hash_lookup,
 	[ARRAY_LOOKUP] = test_array_lookup,
+	[INNER_LRU_HASH_PREALLOC] = test_inner_lru_hash_prealloc,
 };
 
 static void loop(int cpu)
@@ -278,9 +324,25 @@ static void fixup_map(struct bpf_map_def *map, const char *name, int idx)
 {
 	int i;
 
+	if (!strcmp("inner_lru_hash_map", name)) {
+		inner_lru_hash_idx = idx;
+		inner_lru_hash_size = map->max_entries;
+	}
+
+	if (!strcmp("array_of_lru_hashs", name)) {
+		if (inner_lru_hash_idx == -1) {
+			printf("inner_lru_hash_map must be defined before array_of_lru_hashs\n");
+			exit(1);
+		}
+		map->inner_map_idx = inner_lru_hash_idx;
+		array_of_lru_hashs_idx = idx;
+	}
+
 	if (num_map_entries <= 0)
 		return;
 
+	inner_lru_hash_size = num_map_entries;
+
 	/* Only change the max_entries for the enabled test(s) */
 	for (i = 0; i < NR_TESTS; i++) {
 		if (!strcmp(test_map_names[i], name) &&
-- 
2.9.3
