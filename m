From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 4/6] bpf: Allow bpf sample programs (*_user.c) to change bpf_map_def
Date: Fri, 14 Apr 2017 10:30:28 -0700
Message-ID: <20170414173030.2853860-5-kafai@fb.com>
References: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41834 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754004AbdDNRac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 13:30:32 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EHPGWn026230
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29u1phrfm0-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 0e8da2d4213811e7911c0002c99331b0-b63fb9a0 for <netdev@vger.kernel.org>;        Fri,
 14 Apr 2017 10:30:30 -0700
In-Reply-To: <20170414173030.2853860-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current bpf_map_def is statically defined during compile
time.  This patch allows the *_user.c program to change it during
runtime.  It is done by adding load_bpf_file_fixup_map() which
takes a callback.  The callback will be called before creating
each map so that it has a chance to modify the bpf_map_def.

The current usecase is to change max_entries in map_perf_test.
It is interesting to test with a much bigger map size in
some cases (e.g. the following patch on bpf_lru_map.c).
However,  it is hard to find one size to fit all testing
environment.  Hence, it is handy to take the max_entries
as a cmdline arg and then configure the bpf_map_def during
runtime.

This patch adds two cmdline args.  One is to configure
the map's max_entries.  Another is to configure the max_cnt
which controls how many times a syscall is called.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/bpf_load.c           | 114 +++++++++++++++++++++++++-----
 samples/bpf/bpf_load.h           |  13 ++++
 samples/bpf/map_perf_test_user.c | 148 ++++++++++++++++++++++++---------------
 3 files changed, 201 insertions(+), 74 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index dcdce1270d38..0d449d8032d1 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -21,6 +21,7 @@
 #include <sys/mman.h>
 #include <poll.h>
 #include <ctype.h>
+#include <assert.h>
 #include "libbpf.h"
 #include "bpf_load.h"
 #include "perf-sys.h"
@@ -37,15 +38,6 @@ int event_fd[MAX_PROGS];
 int prog_cnt;
 int prog_array_fd = -1;
 
-struct bpf_map_def {
-	unsigned int type;
-	unsigned int key_size;
-	unsigned int value_size;
-	unsigned int max_entries;
-	unsigned int map_flags;
-	unsigned int inner_map_idx;
-};
-
 static int populate_prog_array(const char *event, int prog_fd)
 {
 	int ind = atoi(event), err;
@@ -193,11 +185,14 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	return 0;
 }
 
-static int load_maps(struct bpf_map_def *maps, int len)
+static int load_maps(struct bpf_map_def *maps, int len,
+		     const char **map_names, fixup_map_cb fixup_map)
 {
 	int i;
 
 	for (i = 0; i < len / sizeof(struct bpf_map_def); i++) {
+		if (fixup_map)
+			fixup_map(&maps[i], map_names[i], i);
 
 		if (maps[i].type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
 		    maps[i].type == BPF_MAP_TYPE_HASH_OF_MAPS) {
@@ -280,14 +275,64 @@ static int parse_relo_and_apply(Elf_Data *data, Elf_Data *symbols,
 	return 0;
 }
 
-int load_bpf_file(char *path)
+static int cmp_symbols(const void *l, const void *r)
+{
+	const GElf_Sym *lsym = (const GElf_Sym *)l;
+	const GElf_Sym *rsym = (const GElf_Sym *)r;
+
+	if (lsym->st_value < rsym->st_value)
+		return -1;
+	else if (lsym->st_value > rsym->st_value)
+		return 1;
+	else
+		return 0;
+}
+
+static int get_sorted_map_names(Elf *elf, Elf_Data *symbols, int maps_shndx,
+				int strtabidx, char **map_names)
+{
+	GElf_Sym map_symbols[MAX_MAPS];
+	int i, nr_maps = 0;
+
+	for (i = 0; i < symbols->d_size / sizeof(GElf_Sym); i++) {
+		assert(nr_maps < MAX_MAPS);
+		if (!gelf_getsym(symbols, i, &map_symbols[nr_maps]))
+			continue;
+		if (map_symbols[nr_maps].st_shndx != maps_shndx)
+			continue;
+		nr_maps++;
+	}
+
+	qsort(map_symbols, nr_maps, sizeof(GElf_Sym), cmp_symbols);
+
+	for (i = 0; i < nr_maps; i++) {
+		char *map_name;
+
+		map_name = elf_strptr(elf, strtabidx, map_symbols[i].st_name);
+		if (!map_name) {
+			printf("cannot get map symbol\n");
+			return 1;
+		}
+
+		map_names[i] = strdup(map_name);
+		if (!map_names[i]) {
+			printf("strdup(%s): %s(%d)\n", map_name,
+			       strerror(errno), errno);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 {
-	int fd, i;
+	int fd, i, ret, maps_shndx = -1, strtabidx = -1;
 	Elf *elf;
 	GElf_Ehdr ehdr;
 	GElf_Shdr shdr, shdr_prog;
-	Elf_Data *data, *data_prog, *symbols = NULL;
-	char *shname, *shname_prog;
+	Elf_Data *data, *data_prog, *data_maps = NULL, *symbols = NULL;
+	char *shname, *shname_prog, *map_names[MAX_MAPS] = { NULL };
 
 	/* reset global variables */
 	kern_version = 0;
@@ -335,14 +380,33 @@ int load_bpf_file(char *path)
 			}
 			memcpy(&kern_version, data->d_buf, sizeof(int));
 		} else if (strcmp(shname, "maps") == 0) {
-			processed_sec[i] = true;
-			if (load_maps(data->d_buf, data->d_size))
-				return 1;
+			maps_shndx = i;
+			data_maps = data;
 		} else if (shdr.sh_type == SHT_SYMTAB) {
+			strtabidx = shdr.sh_link;
 			symbols = data;
 		}
 	}
 
+	ret = 1;
+
+	if (!symbols) {
+		printf("missing SHT_SYMTAB section\n");
+		goto done;
+	}
+
+	if (data_maps) {
+		if (get_sorted_map_names(elf, symbols, maps_shndx, strtabidx,
+					 map_names))
+			goto done;
+
+		if (load_maps(data_maps->d_buf, data_maps->d_size,
+			      (const char **)map_names, fixup_map))
+			goto done;
+
+		processed_sec[maps_shndx] = true;
+	}
+
 	/* load programs that need map fixup (relocations) */
 	for (i = 1; i < ehdr.e_shnum; i++) {
 		if (processed_sec[i])
@@ -399,8 +463,22 @@ int load_bpf_file(char *path)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
 
+	ret = 0;
+done:
+	for (i = 0; i < MAX_MAPS; i++)
+		free(map_names[i]);
 	close(fd);
-	return 0;
+	return ret;
+}
+
+int load_bpf_file(char *path)
+{
+	return do_load_bpf_file(path, NULL);
+}
+
+int load_bpf_file_fixup_map(const char *path, fixup_map_cb fixup_map)
+{
+	return do_load_bpf_file(path, fixup_map);
 }
 
 void read_trace_pipe(void)
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index c827827299b3..68f6b2d22507 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -6,6 +6,18 @@
 #define MAX_MAPS 32
 #define MAX_PROGS 32
 
+struct bpf_map_def {
+	unsigned int type;
+	unsigned int key_size;
+	unsigned int value_size;
+	unsigned int max_entries;
+	unsigned int map_flags;
+	unsigned int inner_map_idx;
+};
+
+typedef void (*fixup_map_cb)(struct bpf_map_def *map, const char *map_name,
+			     int idx);
+
 extern int map_fd[MAX_MAPS];
 extern int prog_fd[MAX_PROGS];
 extern int event_fd[MAX_PROGS];
@@ -25,6 +37,7 @@ extern int prog_cnt;
  * returns zero on success
  */
 int load_bpf_file(char *path);
+int load_bpf_file_fixup_map(const char *path, fixup_map_cb fixup_map);
 
 void read_trace_pipe(void);
 struct ksym {
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 51cb8f238aa2..2a12f48b5c6d 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -24,7 +24,7 @@
 #include "libbpf.h"
 #include "bpf_load.h"
 
-#define MAX_CNT 1000000
+#define TEST_BIT(t) (1U << (t))
 
 static __u64 time_get_ns(void)
 {
@@ -34,17 +34,39 @@ static __u64 time_get_ns(void)
 	return ts.tv_sec * 1000000000ull + ts.tv_nsec;
 }
 
-#define HASH_PREALLOC		(1 << 0)
-#define PERCPU_HASH_PREALLOC	(1 << 1)
-#define HASH_KMALLOC		(1 << 2)
-#define PERCPU_HASH_KMALLOC	(1 << 3)
-#define LRU_HASH_PREALLOC	(1 << 4)
-#define NOCOMMON_LRU_HASH_PREALLOC	(1 << 5)
-#define LPM_KMALLOC		(1 << 6)
-#define HASH_LOOKUP		(1 << 7)
-#define ARRAY_LOOKUP		(1 << 8)
+enum test_type {
+	HASH_PREALLOC,
+	PERCPU_HASH_PREALLOC,
+	HASH_KMALLOC,
+	PERCPU_HASH_KMALLOC,
+	LRU_HASH_PREALLOC,
+	NOCOMMON_LRU_HASH_PREALLOC,
+	LPM_KMALLOC,
+	HASH_LOOKUP,
+	ARRAY_LOOKUP,
+	NR_TESTS,
+};
+
+const char *test_map_names[NR_TESTS] = {
+	[HASH_PREALLOC] = "hash_map",
+	[PERCPU_HASH_PREALLOC] = "percpu_hash_map",
+	[HASH_KMALLOC] = "hash_map_alloc",
+	[PERCPU_HASH_KMALLOC] = "percpu_hash_map_alloc",
+	[LRU_HASH_PREALLOC] = "lru_hash_map",
+	[NOCOMMON_LRU_HASH_PREALLOC] = "nocommon_lru_hash_map",
+	[LPM_KMALLOC] = "lpm_trie_map_alloc",
+	[HASH_LOOKUP] = "hash_map",
+	[ARRAY_LOOKUP] = "array_map",
+};
 
 static int test_flags = ~0;
+static uint32_t num_map_entries;
+static uint32_t max_cnt = 1000000;
+
+static int check_test_flags(enum test_type t)
+{
+	return test_flags & TEST_BIT(t);
+}
 
 static void test_hash_prealloc(int cpu)
 {
@@ -52,13 +74,13 @@ static void test_hash_prealloc(int cpu)
 	int i;
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
+	for (i = 0; i < max_cnt; i++)
 		syscall(__NR_getuid);
 	printf("%d:hash_map_perf pre-alloc %lld events per sec\n",
-	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	       cpu, max_cnt * 1000000000ll / (time_get_ns() - start_time));
 }
 
-static void do_test_lru(int lru_test_flag, int cpu)
+static void do_test_lru(enum test_type test, int cpu)
 {
 	struct sockaddr_in6 in6 = { .sin6_family = AF_INET6 };
 	const char *test_name;
@@ -68,10 +90,10 @@ static void do_test_lru(int lru_test_flag, int cpu)
 	in6.sin6_addr.s6_addr16[0] = 0xdead;
 	in6.sin6_addr.s6_addr16[1] = 0xbeef;
 
-	if (lru_test_flag & LRU_HASH_PREALLOC) {
+	if (test == LRU_HASH_PREALLOC) {
 		test_name = "lru_hash_map_perf";
 		in6.sin6_addr.s6_addr16[7] = 0;
-	} else if (lru_test_flag & NOCOMMON_LRU_HASH_PREALLOC) {
+	} else if (test == NOCOMMON_LRU_HASH_PREALLOC) {
 		test_name = "nocommon_lru_hash_map_perf";
 		in6.sin6_addr.s6_addr16[7] = 1;
 	} else {
@@ -79,13 +101,13 @@ static void do_test_lru(int lru_test_flag, int cpu)
 	}
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++) {
+	for (i = 0; i < max_cnt; i++) {
 		ret = connect(-1, (const struct sockaddr *)&in6, sizeof(in6));
 		assert(ret == -1 && errno == EBADF);
 	}
 	printf("%d:%s pre-alloc %lld events per sec\n",
 	       cpu, test_name,
-	       MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	       max_cnt * 1000000000ll / (time_get_ns() - start_time));
 }
 
 static void test_lru_hash_prealloc(int cpu)
@@ -104,10 +126,10 @@ static void test_percpu_hash_prealloc(int cpu)
 	int i;
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
+	for (i = 0; i < max_cnt; i++)
 		syscall(__NR_geteuid);
 	printf("%d:percpu_hash_map_perf pre-alloc %lld events per sec\n",
-	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	       cpu, max_cnt * 1000000000ll / (time_get_ns() - start_time));
 }
 
 static void test_hash_kmalloc(int cpu)
@@ -116,10 +138,10 @@ static void test_hash_kmalloc(int cpu)
 	int i;
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
+	for (i = 0; i < max_cnt; i++)
 		syscall(__NR_getgid);
 	printf("%d:hash_map_perf kmalloc %lld events per sec\n",
-	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	       cpu, max_cnt * 1000000000ll / (time_get_ns() - start_time));
 }
 
 static void test_percpu_hash_kmalloc(int cpu)
@@ -128,10 +150,10 @@ static void test_percpu_hash_kmalloc(int cpu)
 	int i;
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
+	for (i = 0; i < max_cnt; i++)
 		syscall(__NR_getegid);
 	printf("%d:percpu_hash_map_perf kmalloc %lld events per sec\n",
-	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	       cpu, max_cnt * 1000000000ll / (time_get_ns() - start_time));
 }
 
 static void test_lpm_kmalloc(int cpu)
@@ -140,10 +162,10 @@ static void test_lpm_kmalloc(int cpu)
 	int i;
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
+	for (i = 0; i < max_cnt; i++)
 		syscall(__NR_gettid);
 	printf("%d:lpm_perf kmalloc %lld events per sec\n",
-	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	       cpu, max_cnt * 1000000000ll / (time_get_ns() - start_time));
 }
 
 static void test_hash_lookup(int cpu)
@@ -152,10 +174,10 @@ static void test_hash_lookup(int cpu)
 	int i;
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
+	for (i = 0; i < max_cnt; i++)
 		syscall(__NR_getpgid, 0);
 	printf("%d:hash_lookup %lld lookups per sec\n",
-	       cpu, MAX_CNT * 1000000000ll * 64 / (time_get_ns() - start_time));
+	       cpu, max_cnt * 1000000000ll * 64 / (time_get_ns() - start_time));
 }
 
 static void test_array_lookup(int cpu)
@@ -164,46 +186,38 @@ static void test_array_lookup(int cpu)
 	int i;
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
+	for (i = 0; i < max_cnt; i++)
 		syscall(__NR_getpgrp, 0);
 	printf("%d:array_lookup %lld lookups per sec\n",
-	       cpu, MAX_CNT * 1000000000ll * 64 / (time_get_ns() - start_time));
+	       cpu, max_cnt * 1000000000ll * 64 / (time_get_ns() - start_time));
 }
 
+typedef void (*test_func)(int cpu);
+const test_func test_funcs[] = {
+	[HASH_PREALLOC] = test_hash_prealloc,
+	[PERCPU_HASH_PREALLOC] = test_percpu_hash_prealloc,
+	[HASH_KMALLOC] = test_hash_kmalloc,
+	[PERCPU_HASH_KMALLOC] = test_percpu_hash_kmalloc,
+	[LRU_HASH_PREALLOC] = test_lru_hash_prealloc,
+	[NOCOMMON_LRU_HASH_PREALLOC] = test_nocommon_lru_hash_prealloc,
+	[LPM_KMALLOC] = test_lpm_kmalloc,
+	[HASH_LOOKUP] = test_hash_lookup,
+	[ARRAY_LOOKUP] = test_array_lookup,
+};
+
 static void loop(int cpu)
 {
 	cpu_set_t cpuset;
+	int i;
 
 	CPU_ZERO(&cpuset);
 	CPU_SET(cpu, &cpuset);
 	sched_setaffinity(0, sizeof(cpuset), &cpuset);
 
-	if (test_flags & HASH_PREALLOC)
-		test_hash_prealloc(cpu);
-
-	if (test_flags & PERCPU_HASH_PREALLOC)
-		test_percpu_hash_prealloc(cpu);
-
-	if (test_flags & HASH_KMALLOC)
-		test_hash_kmalloc(cpu);
-
-	if (test_flags & PERCPU_HASH_KMALLOC)
-		test_percpu_hash_kmalloc(cpu);
-
-	if (test_flags & LRU_HASH_PREALLOC)
-		test_lru_hash_prealloc(cpu);
-
-	if (test_flags & NOCOMMON_LRU_HASH_PREALLOC)
-		test_nocommon_lru_hash_prealloc(cpu);
-
-	if (test_flags & LPM_KMALLOC)
-		test_lpm_kmalloc(cpu);
-
-	if (test_flags & HASH_LOOKUP)
-		test_hash_lookup(cpu);
-
-	if (test_flags & ARRAY_LOOKUP)
-		test_array_lookup(cpu);
+	for (i = 0; i < NR_TESTS; i++) {
+		if (check_test_flags(i))
+			test_funcs[i](cpu);
+	}
 }
 
 static void run_perf_test(int tasks)
@@ -260,6 +274,22 @@ static void fill_lpm_trie(void)
 	assert(!r);
 }
 
+static void fixup_map(struct bpf_map_def *map, const char *name, int idx)
+{
+	int i;
+
+	if (num_map_entries <= 0)
+		return;
+
+	/* Only change the max_entries for the enabled test(s) */
+	for (i = 0; i < NR_TESTS; i++) {
+		if (!strcmp(test_map_names[i], name) &&
+		    (check_test_flags(i))) {
+			map->max_entries = num_map_entries;
+		}
+	}
+}
+
 int main(int argc, char **argv)
 {
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
@@ -275,7 +305,13 @@ int main(int argc, char **argv)
 	if (argc > 2)
 		num_cpu = atoi(argv[2]) ? : num_cpu;
 
-	if (load_bpf_file(filename)) {
+	if (argc > 3)
+		num_map_entries = atoi(argv[3]);
+
+	if (argc > 4)
+		max_cnt = atoi(argv[4]);
+
+	if (load_bpf_file_fixup_map(filename, fixup_map)) {
 		printf("%s", bpf_log_buf);
 		return 1;
 	}
-- 
2.9.3
