From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 4/7] samples/bpf: Make samples more libbpf-centric
Date: Thu,  8 Dec 2016 18:46:17 -0800
Message-ID: <20161209024620.31660-5-joe@ovn.org>
References: <20161209024620.31660-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        acme@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209024620.31660-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch all of the sample code to use the function names from
tools/lib/bpf so that they're consistent with that, and to declare their
own log buffers. This allow the next commit to be purely devoted to
getting rid of the duplicate library in samples/bpf.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
 samples/bpf/bpf_load.c                            |  17 ++-
 samples/bpf/fds_example.c                         |   9 +-
 samples/bpf/lathist_user.c                        |   3 +-
 samples/bpf/libbpf.c                              |  23 ++--
 samples/bpf/libbpf.h                              |  18 +--
 samples/bpf/map_perf_test_user.c                  |   1 +
 samples/bpf/offwaketime_user.c                    |  10 +-
 samples/bpf/sampleip_user.c                       |   5 +-
 samples/bpf/sock_example.c                        |  10 +-
 samples/bpf/sockex1_user.c                        |   8 +-
 samples/bpf/sockex2_user.c                        |   6 +-
 samples/bpf/sockex3_user.c                        |   6 +-
 samples/bpf/spintest_user.c                       |  10 +-
 samples/bpf/tc_l2_redirect_user.c                 |   4 +-
 samples/bpf/test_cgrp2_array_pin.c                |   4 +-
 samples/bpf/test_current_task_under_cgroup_user.c |  10 +-
 samples/bpf/test_maps.c                           | 142 +++++++++++-----------
 samples/bpf/test_overhead_user.c                  |   2 +
 samples/bpf/test_probe_write_user_user.c          |   4 +-
 samples/bpf/test_verifier.c                       |   8 +-
 samples/bpf/trace_event_user.c                    |  15 +--
 samples/bpf/trace_output_user.c                   |   3 +-
 samples/bpf/tracex1_user.c                        |   2 +
 samples/bpf/tracex2_user.c                        |  12 +-
 samples/bpf/tracex3_user.c                        |   6 +-
 samples/bpf/tracex4_user.c                        |   6 +-
 samples/bpf/tracex5_user.c                        |   2 +
 samples/bpf/tracex6_user.c                        |   4 +-
 samples/bpf/xdp1_user.c                           |   4 +-
 29 files changed, 200 insertions(+), 154 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 97913e109b14..f8e3c58a0897 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -18,7 +18,6 @@
 #include <poll.h>
 #include <ctype.h>
 #include "libbpf.h"
-#include "bpf_helpers.h"
 #include "bpf_load.h"
 
 #define DEBUGFS "/sys/kernel/debug/tracing/"
@@ -26,17 +25,26 @@
 static char license[128];
 static int kern_version;
 static bool processed_sec[128];
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
 int map_fd[MAX_MAPS];
 int prog_fd[MAX_PROGS];
 int event_fd[MAX_PROGS];
 int prog_cnt;
 int prog_array_fd = -1;
 
+struct bpf_map_def {
+	unsigned int type;
+	unsigned int key_size;
+	unsigned int value_size;
+	unsigned int max_entries;
+	unsigned int map_flags;
+};
+
 static int populate_prog_array(const char *event, int prog_fd)
 {
 	int ind = atoi(event), err;
 
-	err = bpf_update_elem(prog_array_fd, &ind, &prog_fd, BPF_ANY);
+	err = bpf_map_update_elem(prog_array_fd, &ind, &prog_fd, BPF_ANY);
 	if (err < 0) {
 		printf("failed to store prog_fd in prog_array\n");
 		return -1;
@@ -77,9 +85,10 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		return -1;
 	}
 
-	fd = bpf_prog_load(prog_type, prog, size, license, kern_version);
+	fd = bpf_load_program(prog_type, prog, size, license, kern_version,
+			      NULL, 0);
 	if (fd < 0) {
-		printf("bpf_prog_load() err=%d\n%s", errno, bpf_log_buf);
+		printf("bpf_load_program() err=%d\n%s", errno, bpf_log_buf);
 		return -1;
 	}
 
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 625e797be6ef..4ffd8f340496 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -58,8 +58,9 @@ static int bpf_prog_create(const char *object)
 		assert(!load_bpf_file((char *)object));
 		return prog_fd[0];
 	} else {
-		return bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER,
-				     insns, sizeof(insns), "GPL", 0);
+		return bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER,
+					insns, sizeof(insns), "GPL", 0, NULL,
+					0);
 	}
 }
 
@@ -83,12 +84,12 @@ static int bpf_do_map(const char *file, uint32_t flags, uint32_t key,
 	}
 
 	if ((flags & BPF_F_KEY_VAL) == BPF_F_KEY_VAL) {
-		ret = bpf_update_elem(fd, &key, &value, 0);
+		ret = bpf_map_update_elem(fd, &key, &value, 0);
 		printf("bpf: fd:%d u->(%u:%u) ret:(%d,%s)\n", fd, key, value,
 		       ret, strerror(errno));
 		assert(ret == 0);
 	} else if (flags & BPF_F_KEY) {
-		ret = bpf_lookup_elem(fd, &key, &value);
+		ret = bpf_map_lookup_elem(fd, &key, &value);
 		printf("bpf: fd:%d l->(%u):%u ret:(%d,%s)\n", fd, key, value,
 		       ret, strerror(errno));
 		assert(ret == 0);
diff --git a/samples/bpf/lathist_user.c b/samples/bpf/lathist_user.c
index 65da8c1576de..bcdee00816b2 100644
--- a/samples/bpf/lathist_user.c
+++ b/samples/bpf/lathist_user.c
@@ -23,6 +23,7 @@ struct cpu_hist {
 };
 
 static struct cpu_hist cpu_hist[MAX_CPU];
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
 static void stars(char *str, long val, long max, int width)
 {
@@ -73,7 +74,7 @@ static void get_data(int fd)
 	for (c = 0; c < MAX_CPU; c++) {
 		for (i = 0; i < MAX_ENTRIES; i++) {
 			key = c * MAX_ENTRIES + i;
-			bpf_lookup_elem(fd, &key, &value);
+			bpf_map_lookup_elem(fd, &key, &value);
 
 			cpu_hist[c].data[i] = value;
 			if (value > cpu_hist[c].max)
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 9969e35550c3..e5c5a69996fc 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -32,7 +32,7 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
+int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -44,7 +44,7 @@ int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
 	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_lookup_elem(int fd, void *key, void *value)
+int bpf_map_lookup_elem(int fd, void *key, void *value)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -55,7 +55,7 @@ int bpf_lookup_elem(int fd, void *key, void *value)
 	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_delete_elem(int fd, void *key)
+int bpf_map_delete_elem(int fd, void *key)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -65,7 +65,7 @@ int bpf_delete_elem(int fd, void *key)
 	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_get_next_key(int fd, void *key, void *next_key)
+int bpf_map_get_next_key(int fd, void *key, void *next_key)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -78,19 +78,18 @@ int bpf_get_next_key(int fd, void *key, void *next_key)
 
 #define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
 
-char bpf_log_buf[LOG_BUF_SIZE];
-
-int bpf_prog_load(enum bpf_prog_type prog_type,
-		  const struct bpf_insn *insns, int prog_len,
-		  const char *license, int kern_version)
+int bpf_load_program(enum bpf_prog_type prog_type,
+		     const struct bpf_insn *insns, int prog_len,
+		     const char *license, int kern_version,
+		     char *log_buf, size_t log_buf_sz)
 {
 	union bpf_attr attr = {
 		.prog_type = prog_type,
 		.insns = ptr_to_u64((void *) insns),
 		.insn_cnt = prog_len / sizeof(struct bpf_insn),
 		.license = ptr_to_u64((void *) license),
-		.log_buf = ptr_to_u64(bpf_log_buf),
-		.log_size = LOG_BUF_SIZE,
+		.log_buf = ptr_to_u64(log_buf),
+		.log_size = log_buf_sz,
 		.log_level = 1,
 	};
 
@@ -99,7 +98,7 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 	 */
 	attr.kern_version = kern_version;
 
-	bpf_log_buf[0] = 0;
+	log_buf[0] = 0;
 
 	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
 }
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index ac6edb61b64a..1325152be4cd 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -6,20 +6,20 @@ struct bpf_insn;
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries, int map_flags);
-int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
-int bpf_lookup_elem(int fd, void *key, void *value);
-int bpf_delete_elem(int fd, void *key);
-int bpf_get_next_key(int fd, void *key, void *next_key);
+int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags);
+int bpf_map_lookup_elem(int fd, void *key, void *value);
+int bpf_map_delete_elem(int fd, void *key);
+int bpf_map_get_next_key(int fd, void *key, void *next_key);
 
-int bpf_prog_load(enum bpf_prog_type prog_type,
-		  const struct bpf_insn *insns, int insn_len,
-		  const char *license, int kern_version);
+int bpf_load_program(enum bpf_prog_type prog_type,
+		     const struct bpf_insn *insns, int insn_len,
+		     const char *license, int kern_version,
+		     char *log_buf, size_t log_buf_sz);
 
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
 
-#define LOG_BUF_SIZE 65536
-extern char bpf_log_buf[LOG_BUF_SIZE];
+#define BPF_LOG_BUF_SIZE 65536
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 3147377e8fd3..62ed870590cc 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -37,6 +37,7 @@ static __u64 time_get_ns(void)
 #define PERCPU_HASH_KMALLOC	(1 << 3)
 
 static int test_flags = ~0;
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
 static void test_hash_prealloc(int cpu)
 {
diff --git a/samples/bpf/offwaketime_user.c b/samples/bpf/offwaketime_user.c
index 6f002a9c24fa..dd2598b1fabc 100644
--- a/samples/bpf/offwaketime_user.c
+++ b/samples/bpf/offwaketime_user.c
@@ -20,6 +20,8 @@
 
 #define PRINT_RAW_ADDR 0
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static void print_ksym(__u64 addr)
 {
 	struct ksym *sym;
@@ -49,14 +51,14 @@ static void print_stack(struct key_t *key, __u64 count)
 	int i;
 
 	printf("%s;", key->target);
-	if (bpf_lookup_elem(map_fd[3], &key->tret, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[3], &key->tret, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
 			print_ksym(ip[i]);
 	}
 	printf("-;");
-	if (bpf_lookup_elem(map_fd[3], &key->wret, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[3], &key->wret, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = 0; i < PERF_MAX_STACK_DEPTH; i++)
@@ -77,8 +79,8 @@ static void print_stacks(int fd)
 	struct key_t key = {}, next_key;
 	__u64 value;
 
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
-		bpf_lookup_elem(fd, &next_key, &value);
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_map_lookup_elem(fd, &next_key, &value);
 		print_stack(&next_key, value);
 		key = next_key;
 	}
diff --git a/samples/bpf/sampleip_user.c b/samples/bpf/sampleip_user.c
index 260a6bdd6413..09ab620b324c 100644
--- a/samples/bpf/sampleip_user.c
+++ b/samples/bpf/sampleip_user.c
@@ -28,6 +28,7 @@
 #define PAGE_OFFSET	0xffff880000000000
 
 static int nr_cpus;
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
 static void usage(void)
 {
@@ -95,8 +96,8 @@ static void print_ip_map(int fd)
 
 	/* fetch IPs and counts */
 	key = 0, i = 0;
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
-		bpf_lookup_elem(fd, &next_key, &value);
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_map_lookup_elem(fd, &next_key, &value);
 		counts[i].ip = next_key;
 		counts[i++].count = value;
 		key = next_key;
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index 28b60baa9fa8..7ab636c30154 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -55,8 +55,8 @@ static int test_sock(void)
 		BPF_EXIT_INSN(),
 	};
 
-	prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
-				"GPL", 0);
+	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
+				   "GPL", 0, NULL, 0);
 	if (prog_fd < 0) {
 		printf("failed to load prog '%s'\n", strerror(errno));
 		goto cleanup;
@@ -72,13 +72,13 @@ static int test_sock(void)
 
 	for (i = 0; i < 10; i++) {
 		key = IPPROTO_TCP;
-		assert(bpf_lookup_elem(map_fd, &key, &tcp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &tcp_cnt) == 0);
 
 		key = IPPROTO_UDP;
-		assert(bpf_lookup_elem(map_fd, &key, &udp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &udp_cnt) == 0);
 
 		key = IPPROTO_ICMP;
-		assert(bpf_lookup_elem(map_fd, &key, &icmp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &icmp_cnt) == 0);
 
 		printf("TCP %lld UDP %lld ICMP %lld packets\n",
 		       tcp_cnt, udp_cnt, icmp_cnt);
diff --git a/samples/bpf/sockex1_user.c b/samples/bpf/sockex1_user.c
index 678ce4693551..2956d893d732 100644
--- a/samples/bpf/sockex1_user.c
+++ b/samples/bpf/sockex1_user.c
@@ -6,6 +6,8 @@
 #include <unistd.h>
 #include <arpa/inet.h>
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 int main(int ac, char **argv)
 {
 	char filename[256];
@@ -32,13 +34,13 @@ int main(int ac, char **argv)
 		int key;
 
 		key = IPPROTO_TCP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &tcp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd[0], &key, &tcp_cnt) == 0);
 
 		key = IPPROTO_UDP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &udp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd[0], &key, &udp_cnt) == 0);
 
 		key = IPPROTO_ICMP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &icmp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd[0], &key, &icmp_cnt) == 0);
 
 		printf("TCP %lld UDP %lld ICMP %lld bytes\n",
 		       tcp_cnt, udp_cnt, icmp_cnt);
diff --git a/samples/bpf/sockex2_user.c b/samples/bpf/sockex2_user.c
index 8a4085c2d117..c43958a67cca 100644
--- a/samples/bpf/sockex2_user.c
+++ b/samples/bpf/sockex2_user.c
@@ -7,6 +7,8 @@
 #include <arpa/inet.h>
 #include <sys/resource.h>
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 struct pair {
 	__u64 packets;
 	__u64 bytes;
@@ -39,8 +41,8 @@ int main(int ac, char **argv)
 		int key = 0, next_key;
 		struct pair value;
 
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[0], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[0], &next_key, &value);
 			printf("ip %s bytes %lld packets %lld\n",
 			       inet_ntoa((struct in_addr){htonl(next_key)}),
 			       value.bytes, value.packets);
diff --git a/samples/bpf/sockex3_user.c b/samples/bpf/sockex3_user.c
index 3fcfd8c4b2a3..2cb9011ea440 100644
--- a/samples/bpf/sockex3_user.c
+++ b/samples/bpf/sockex3_user.c
@@ -7,6 +7,8 @@
 #include <arpa/inet.h>
 #include <sys/resource.h>
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 struct bpf_flow_keys {
 	__be32 src;
 	__be32 dst;
@@ -54,8 +56,8 @@ int main(int argc, char **argv)
 
 		sleep(1);
 		printf("IP     src.port -> dst.port               bytes      packets\n");
-		while (bpf_get_next_key(map_fd[2], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[2], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[2], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[2], &next_key, &value);
 			printf("%s.%05d -> %s.%05d %12lld %12lld\n",
 			       inet_ntoa((struct in_addr){htonl(next_key.src)}),
 			       next_key.port16[0],
diff --git a/samples/bpf/spintest_user.c b/samples/bpf/spintest_user.c
index 311ede532230..8950a3d27a92 100644
--- a/samples/bpf/spintest_user.c
+++ b/samples/bpf/spintest_user.c
@@ -7,6 +7,8 @@
 #include "libbpf.h"
 #include "bpf_load.h"
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 int main(int ac, char **argv)
 {
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
@@ -31,8 +33,8 @@ int main(int ac, char **argv)
 	for (i = 0; i < 5; i++) {
 		key = 0;
 		printf("kprobing funcs:");
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[0], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[0], &next_key, &value);
 			assert(next_key == value);
 			sym = ksym_search(value);
 			printf(" %s", sym->name);
@@ -41,8 +43,8 @@ int main(int ac, char **argv)
 		if (key)
 			printf("\n");
 		key = 0;
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0)
-			bpf_delete_elem(map_fd[0], &next_key);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0)
+			bpf_map_delete_elem(map_fd[0], &next_key);
 		sleep(1);
 	}
 
diff --git a/samples/bpf/tc_l2_redirect_user.c b/samples/bpf/tc_l2_redirect_user.c
index 4013c5337b91..28995a776560 100644
--- a/samples/bpf/tc_l2_redirect_user.c
+++ b/samples/bpf/tc_l2_redirect_user.c
@@ -60,9 +60,9 @@ int main(int argc, char **argv)
 	}
 
 	/* bpf_tunnel_key.remote_ipv4 expects host byte orders */
-	ret = bpf_update_elem(array_fd, &array_key, &ifindex, 0);
+	ret = bpf_map_update_elem(array_fd, &array_key, &ifindex, 0);
 	if (ret) {
-		perror("bpf_update_elem");
+		perror("bpf_map_update_elem");
 		goto out;
 	}
 
diff --git a/samples/bpf/test_cgrp2_array_pin.c b/samples/bpf/test_cgrp2_array_pin.c
index 70e86f7be69d..8a1b8b5d8def 100644
--- a/samples/bpf/test_cgrp2_array_pin.c
+++ b/samples/bpf/test_cgrp2_array_pin.c
@@ -85,9 +85,9 @@ int main(int argc, char **argv)
 		}
 	}
 
-	ret = bpf_update_elem(array_fd, &array_key, &cg2_fd, 0);
+	ret = bpf_map_update_elem(array_fd, &array_key, &cg2_fd, 0);
 	if (ret) {
-		perror("bpf_update_elem");
+		perror("bpf_map_update_elem");
 		goto out;
 	}
 
diff --git a/samples/bpf/test_current_task_under_cgroup_user.c b/samples/bpf/test_current_task_under_cgroup_user.c
index 30b0bce884f9..054915324aeb 100644
--- a/samples/bpf/test_current_task_under_cgroup_user.c
+++ b/samples/bpf/test_current_task_under_cgroup_user.c
@@ -28,6 +28,8 @@
 #define log_err(MSG, ...) fprintf(stderr, "(%s:%d: errno: %s) " MSG "\n", \
 	__FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static int join_cgroup(char *path)
 {
 	int fd, rc = 0;
@@ -94,7 +96,7 @@ int main(int argc, char **argv)
 		goto cleanup_cgroup_err;
 	}
 
-	if (bpf_update_elem(map_fd[0], &idx, &cg2, BPF_ANY)) {
+	if (bpf_map_update_elem(map_fd[0], &idx, &cg2, BPF_ANY)) {
 		log_err("Adding target cgroup to map");
 		goto cleanup_cgroup_err;
 	}
@@ -109,7 +111,7 @@ int main(int argc, char **argv)
 	 */
 
 	sync();
-	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
+	bpf_map_lookup_elem(map_fd[1], &idx, &remote_pid);
 
 	if (local_pid != remote_pid) {
 		fprintf(stderr,
@@ -123,10 +125,10 @@ int main(int argc, char **argv)
 		goto leave_cgroup_err;
 
 	remote_pid = 0;
-	bpf_update_elem(map_fd[1], &idx, &remote_pid, BPF_ANY);
+	bpf_map_update_elem(map_fd[1], &idx, &remote_pid, BPF_ANY);
 
 	sync();
-	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
+	bpf_map_lookup_elem(map_fd[1], &idx, &remote_pid);
 
 	if (local_pid == remote_pid) {
 		fprintf(stderr, "BPF cgroup negative test did not work\n");
diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index cce2b59751eb..2618394a3cc7 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -36,68 +36,68 @@ static void test_hashmap_sanity(int i, void *data)
 	key = 1;
 	value = 1234;
 	/* insert key=1 element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
 
 	value = 0;
 	/* BPF_NOEXIST means: add new element if it doesn't exist */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       /* key=1 already exists */
 	       errno == EEXIST);
 
-	assert(bpf_update_elem(map_fd, &key, &value, -1) == -1 && errno == EINVAL);
+	assert(bpf_map_update_elem(map_fd, &key, &value, -1) == -1 && errno == EINVAL);
 
 	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
+	assert(bpf_map_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
 
 	key = 2;
 	/* check that key=2 is not found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means: update existing element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
 	       /* key=2 is not there */
 	       errno == ENOENT);
 
 	/* insert key=2 element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
 
 	/* key=1 and key=2 were inserted, check that key=0 cannot be inserted
 	 * due to max_entries limit
 	 */
 	key = 0;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* update existing element, thought the map is full */
 	key = 1;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
 	key = 2;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
 	key = 1;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
 
 	/* check that key = 0 doesn't exist */
 	key = 0;
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
 
 	/* iterate over two elements */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(map_fd, &key, &next_key) == 0 &&
 	       (next_key == 1 || next_key == 2));
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(map_fd, &next_key, &next_key) == 0 &&
 	       (next_key == 1 || next_key == 2));
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(map_fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	/* delete both elements */
 	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
+	assert(bpf_map_delete_elem(map_fd, &key) == 0);
 	key = 2;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(map_fd, &key) == 0);
+	assert(bpf_map_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
 
 	key = 0;
 	/* check that map is empty */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(map_fd, &key, &next_key) == -1 &&
 	       errno == ENOENT);
 	close(map_fd);
 }
@@ -123,54 +123,54 @@ static void test_percpu_hashmap_sanity(int task, void *data)
 	key = 1;
 	/* insert key=1 element */
 	assert(!(expected_key_mask & key));
-	assert(bpf_update_elem(map_fd, &key, value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, value, BPF_ANY) == 0);
 	expected_key_mask |= key;
 
 	/* BPF_NOEXIST means: add new element if it doesn't exist */
-	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
 	       /* key=1 already exists */
 	       errno == EEXIST);
 
 	/* -1 is an invalid flag */
-	assert(bpf_update_elem(map_fd, &key, value, -1) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, value, -1) == -1 &&
 	       errno == EINVAL);
 
 	/* check that key=1 can be found. value could be 0 if the lookup
 	 * was run from a different cpu.
 	 */
 	value[0] = 1;
-	assert(bpf_lookup_elem(map_fd, &key, value) == 0 && value[0] == 100);
+	assert(bpf_map_lookup_elem(map_fd, &key, value) == 0 && value[0] == 100);
 
 	key = 2;
 	/* check that key=2 is not found */
-	assert(bpf_lookup_elem(map_fd, &key, value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(map_fd, &key, value) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means: update existing element */
-	assert(bpf_update_elem(map_fd, &key, value, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, value, BPF_EXIST) == -1 &&
 	       /* key=2 is not there */
 	       errno == ENOENT);
 
 	/* insert key=2 element */
 	assert(!(expected_key_mask & key));
-	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST) == 0);
 	expected_key_mask |= key;
 
 	/* key=1 and key=2 were inserted, check that key=0 cannot be inserted
 	 * due to max_entries limit
 	 */
 	key = 0;
-	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* check that key = 0 doesn't exist */
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
 
 	/* iterate over two elements */
-	while (!bpf_get_next_key(map_fd, &key, &next_key)) {
+	while (!bpf_map_get_next_key(map_fd, &key, &next_key)) {
 		assert((expected_key_mask & next_key) == next_key);
 		expected_key_mask &= ~next_key;
 
-		assert(bpf_lookup_elem(map_fd, &next_key, value) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &next_key, value) == 0);
 		for (i = 0; i < nr_cpus; i++)
 			assert(value[i] == i + 100);
 
@@ -180,18 +180,18 @@ static void test_percpu_hashmap_sanity(int task, void *data)
 
 	/* Update with BPF_EXIST */
 	key = 1;
-	assert(bpf_update_elem(map_fd, &key, value, BPF_EXIST) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, value, BPF_EXIST) == 0);
 
 	/* delete both elements */
 	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
+	assert(bpf_map_delete_elem(map_fd, &key) == 0);
 	key = 2;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(map_fd, &key) == 0);
+	assert(bpf_map_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
 
 	key = 0;
 	/* check that map is empty */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(map_fd, &key, &next_key) == -1 &&
 	       errno == ENOENT);
 	close(map_fd);
 }
@@ -211,41 +211,41 @@ static void test_arraymap_sanity(int i, void *data)
 	key = 1;
 	value = 1234;
 	/* insert key=1 element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
 
 	value = 0;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == EEXIST);
 
 	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
+	assert(bpf_map_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
 
 	key = 0;
 	/* check that key=0 is also found and zero initialized */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
+	assert(bpf_map_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
 
 
 	/* key=0 and key=1 were inserted, check that key=2 cannot be inserted
 	 * due to max_entries limit
 	 */
 	key = 2;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* check that key = 2 doesn't exist */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
 
 	/* iterate over two elements */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(map_fd, &key, &next_key) == 0 &&
 	       next_key == 0);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(map_fd, &next_key, &next_key) == 0 &&
 	       next_key == 1);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(map_fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	/* delete shouldn't succeed */
 	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == EINVAL);
+	assert(bpf_map_delete_elem(map_fd, &key) == -1 && errno == EINVAL);
 
 	close(map_fd);
 }
@@ -269,12 +269,12 @@ static void test_percpu_arraymap_many_keys(void)
 		values[i] = i + 10;
 
 	for (key = 0; key < nr_keys; key++)
-		assert(bpf_update_elem(map_fd, &key, values, BPF_ANY) == 0);
+		assert(bpf_map_update_elem(map_fd, &key, values, BPF_ANY) == 0);
 
 	for (key = 0; key < nr_keys; key++) {
 		for (i = 0; i < nr_cpus; i++)
 			values[i] = 0;
-		assert(bpf_lookup_elem(map_fd, &key, values) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, values) == 0);
 		for (i = 0; i < nr_cpus; i++)
 			assert(values[i] == i + 10);
 	}
@@ -300,40 +300,40 @@ static void test_percpu_arraymap_sanity(int i, void *data)
 
 	key = 1;
 	/* insert key=1 element */
-	assert(bpf_update_elem(map_fd, &key, values, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd, &key, values, BPF_ANY) == 0);
 
 	values[0] = 0;
-	assert(bpf_update_elem(map_fd, &key, values, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, values, BPF_NOEXIST) == -1 &&
 	       errno == EEXIST);
 
 	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, values) == 0 && values[0] == 100);
+	assert(bpf_map_lookup_elem(map_fd, &key, values) == 0 && values[0] == 100);
 
 	key = 0;
 	/* check that key=0 is also found and zero initialized */
-	assert(bpf_lookup_elem(map_fd, &key, values) == 0 &&
+	assert(bpf_map_lookup_elem(map_fd, &key, values) == 0 &&
 	       values[0] == 0 && values[nr_cpus - 1] == 0);
 
 
 	/* check that key=2 cannot be inserted due to max_entries limit */
 	key = 2;
-	assert(bpf_update_elem(map_fd, &key, values, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, values, BPF_EXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* check that key = 2 doesn't exist */
-	assert(bpf_lookup_elem(map_fd, &key, values) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(map_fd, &key, values) == -1 && errno == ENOENT);
 
 	/* iterate over two elements */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(map_fd, &key, &next_key) == 0 &&
 	       next_key == 0);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(map_fd, &next_key, &next_key) == 0 &&
 	       next_key == 1);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(map_fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	/* delete shouldn't succeed */
 	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == EINVAL);
+	assert(bpf_map_delete_elem(map_fd, &key) == -1 && errno == EINVAL);
 
 	close(map_fd);
 }
@@ -359,21 +359,21 @@ static void test_map_large(void)
 	for (i = 0; i < MAP_SIZE; i++) {
 		key = (struct bigkey) {.c = i};
 		value = i;
-		assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
+		assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
 	}
 	key.c = -1;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* iterate through all elements */
 	for (i = 0; i < MAP_SIZE; i++)
-		assert(bpf_get_next_key(map_fd, &key, &key) == 0);
-	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
+		assert(bpf_map_get_next_key(map_fd, &key, &key) == 0);
+	assert(bpf_map_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
 
 	key.c = 0;
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
+	assert(bpf_map_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
 	key.a = 1;
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
 
 	close(map_fd);
 }
@@ -423,10 +423,10 @@ static void do_work(int fn, void *data)
 	for (i = fn; i < MAP_SIZE; i += TASKS) {
 		key = value = i;
 		if (do_update) {
-			assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
-			assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
+			assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
+			assert(bpf_map_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
 		} else {
-			assert(bpf_delete_elem(map_fd, &key) == 0);
+			assert(bpf_map_delete_elem(map_fd, &key) == 0);
 		}
 	}
 }
@@ -454,19 +454,19 @@ static void test_map_parallel(void)
 	run_parallel(TASKS, do_work, data);
 
 	/* check that key=0 is already there */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == EEXIST);
 
 	/* check that all elements were inserted */
 	key = -1;
 	for (i = 0; i < MAP_SIZE; i++)
-		assert(bpf_get_next_key(map_fd, &key, &key) == 0);
-	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
+		assert(bpf_map_get_next_key(map_fd, &key, &key) == 0);
+	assert(bpf_map_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
 
 	/* another check for all elements */
 	for (i = 0; i < MAP_SIZE; i++) {
 		key = MAP_SIZE - i - 1;
-		assert(bpf_lookup_elem(map_fd, &key, &value) == 0 &&
+		assert(bpf_map_lookup_elem(map_fd, &key, &value) == 0 &&
 		       value == key);
 	}
 
@@ -476,7 +476,7 @@ static void test_map_parallel(void)
 
 	/* nothing should be left */
 	key = -1;
-	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
 }
 
 static void run_all_tests(void)
diff --git a/samples/bpf/test_overhead_user.c b/samples/bpf/test_overhead_user.c
index d291167fd3c7..74b79af98ba2 100644
--- a/samples/bpf/test_overhead_user.c
+++ b/samples/bpf/test_overhead_user.c
@@ -24,6 +24,8 @@
 
 #define MAX_CNT 1000000
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static __u64 time_get_ns(void)
 {
 	struct timespec ts;
diff --git a/samples/bpf/test_probe_write_user_user.c b/samples/bpf/test_probe_write_user_user.c
index a44bf347bedd..29af2160e4e2 100644
--- a/samples/bpf/test_probe_write_user_user.c
+++ b/samples/bpf/test_probe_write_user_user.c
@@ -9,6 +9,8 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 int main(int ac, char **argv)
 {
 	int serverfd, serverconnfd, clientfd;
@@ -50,7 +52,7 @@ int main(int ac, char **argv)
 	mapped_addr_in->sin_port = htons(5555);
 	mapped_addr_in->sin_addr.s_addr = inet_addr("255.255.255.255");
 
-	assert(!bpf_update_elem(map_fd[0], &mapped_addr, &serv_addr, BPF_ANY));
+	assert(!bpf_map_update_elem(map_fd[0], &mapped_addr, &serv_addr, BPF_ANY));
 
 	assert(listen(serverfd, 5) == 0);
 
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 369ffaad3799..2e85a8e2d696 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -24,6 +24,8 @@
 
 #define MAX_FIXUPS 8
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 struct bpf_test {
 	const char *descr;
 	struct bpf_insn	insns[MAX_INSNS];
@@ -2466,9 +2468,9 @@ static int test(void)
 
 		printf("#%d %s ", i, tests[i].descr);
 
-		prog_fd = bpf_prog_load(prog_type ?: BPF_PROG_TYPE_SOCKET_FILTER,
-					prog, prog_len * sizeof(struct bpf_insn),
-					"GPL", 0);
+		prog_fd = bpf_load_program(prog_type ?: BPF_PROG_TYPE_SOCKET_FILTER,
+					   prog, prog_len * sizeof(struct bpf_insn),
+					   "GPL", 0, NULL, 0);
 
 		if (unpriv && tests[i].result_unpriv != UNDEF)
 			expected_result = tests[i].result_unpriv;
diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
index 9a130d31ecf2..de8fd0266d78 100644
--- a/samples/bpf/trace_event_user.c
+++ b/samples/bpf/trace_event_user.c
@@ -24,6 +24,7 @@
 #define SAMPLE_FREQ 50
 
 static bool sys_read_seen, sys_write_seen;
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
 static void print_ksym(__u64 addr)
 {
@@ -61,14 +62,14 @@ static void print_stack(struct key_t *key, __u64 count)
 	int i;
 
 	printf("%3lld %s;", count, key->comm);
-	if (bpf_lookup_elem(map_fd[1], &key->kernstack, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[1], &key->kernstack, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
 			print_ksym(ip[i]);
 	}
 	printf("-;");
-	if (bpf_lookup_elem(map_fd[1], &key->userstack, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[1], &key->userstack, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
@@ -98,10 +99,10 @@ static void print_stacks(void)
 	int fd = map_fd[0], stack_map = map_fd[1];
 
 	sys_read_seen = sys_write_seen = false;
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
-		bpf_lookup_elem(fd, &next_key, &value);
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_map_lookup_elem(fd, &next_key, &value);
 		print_stack(&next_key, value);
-		bpf_delete_elem(fd, &next_key);
+		bpf_map_delete_elem(fd, &next_key);
 		key = next_key;
 	}
 
@@ -111,8 +112,8 @@ static void print_stacks(void)
 	}
 
 	/* clear stack map */
-	while (bpf_get_next_key(stack_map, &stackid, &next_id) == 0) {
-		bpf_delete_elem(stack_map, &next_id);
+	while (bpf_map_get_next_key(stack_map, &stackid, &next_id) == 0) {
+		bpf_map_delete_elem(stack_map, &next_id);
 		stackid = next_id;
 	}
 }
diff --git a/samples/bpf/trace_output_user.c b/samples/bpf/trace_output_user.c
index 661a7d052f2c..9c38f7aa4515 100644
--- a/samples/bpf/trace_output_user.c
+++ b/samples/bpf/trace_output_user.c
@@ -27,6 +27,7 @@ static int pmu_fd;
 int page_size;
 int page_cnt = 8;
 volatile struct perf_event_mmap_page *header;
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
 typedef void (*print_fn)(void *data, int size);
 
@@ -162,7 +163,7 @@ static void test_bpf_perf_event(void)
 	pmu_fd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
 
 	assert(pmu_fd >= 0);
-	assert(bpf_update_elem(map_fd[0], &key, &pmu_fd, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd[0], &key, &pmu_fd, BPF_ANY) == 0);
 	ioctl(pmu_fd, PERF_EVENT_IOC_ENABLE, 0);
 }
 
diff --git a/samples/bpf/tracex1_user.c b/samples/bpf/tracex1_user.c
index 31a48183beea..aa60cc3ef38c 100644
--- a/samples/bpf/tracex1_user.c
+++ b/samples/bpf/tracex1_user.c
@@ -4,6 +4,8 @@
 #include "libbpf.h"
 #include "bpf_load.h"
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 int main(int ac, char **argv)
 {
 	FILE *f;
diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
index ab5b19e68acf..5dd128cc5785 100644
--- a/samples/bpf/tracex2_user.c
+++ b/samples/bpf/tracex2_user.c
@@ -10,6 +10,8 @@
 #define MAX_INDEX	64
 #define MAX_STARS	38
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static void stars(char *str, long val, long max, int width)
 {
 	int i;
@@ -46,12 +48,12 @@ static void print_hist_for_pid(int fd, void *task)
 	long max_value = 0;
 	int i, ind;
 
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
 		if (memcmp(&next_key, task, SIZE)) {
 			key = next_key;
 			continue;
 		}
-		bpf_lookup_elem(fd, &next_key, values);
+		bpf_map_lookup_elem(fd, &next_key, values);
 		value = 0;
 		for (i = 0; i < nr_cpus; i++)
 			value += values[i];
@@ -81,7 +83,7 @@ static void print_hist(int fd)
 	int task_cnt = 0;
 	int i;
 
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
 		int found = 0;
 
 		for (i = 0; i < task_cnt; i++)
@@ -134,8 +136,8 @@ int main(int ac, char **argv)
 
 	for (i = 0; i < 5; i++) {
 		key = 0;
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[0], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[0], &next_key, &value);
 			printf("location 0x%lx count %ld\n", next_key, value);
 			key = next_key;
 		}
diff --git a/samples/bpf/tracex3_user.c b/samples/bpf/tracex3_user.c
index 48716f7f0d8b..9c6ee595a882 100644
--- a/samples/bpf/tracex3_user.c
+++ b/samples/bpf/tracex3_user.c
@@ -18,6 +18,8 @@
 
 #define SLOTS 100
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static void clear_stats(int fd)
 {
 	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
@@ -26,7 +28,7 @@ static void clear_stats(int fd)
 
 	memset(values, 0, sizeof(values));
 	for (key = 0; key < SLOTS; key++)
-		bpf_update_elem(fd, &key, values, BPF_ANY);
+		bpf_map_update_elem(fd, &key, values, BPF_ANY);
 }
 
 const char *color[] = {
@@ -87,7 +89,7 @@ static void print_hist(int fd)
 	int i;
 
 	for (key = 0; key < SLOTS; key++) {
-		bpf_lookup_elem(fd, &key, values);
+		bpf_map_lookup_elem(fd, &key, values);
 		value = 0;
 		for (i = 0; i < nr_cpus; i++)
 			value += values[i];
diff --git a/samples/bpf/tracex4_user.c b/samples/bpf/tracex4_user.c
index bc4a3bdea6ed..8b2f98c6c99a 100644
--- a/samples/bpf/tracex4_user.c
+++ b/samples/bpf/tracex4_user.c
@@ -15,6 +15,8 @@
 #include "libbpf.h"
 #include "bpf_load.h"
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 struct pair {
 	long long val;
 	__u64 ip;
@@ -37,8 +39,8 @@ static void print_old_objects(int fd)
 	key = write(1, "\e[1;1H\e[2J", 12); /* clear screen */
 
 	key = -1;
-	while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-		bpf_lookup_elem(map_fd[0], &next_key, &v);
+	while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+		bpf_map_lookup_elem(map_fd[0], &next_key, &v);
 		key = next_key;
 		if (val - v.val < 1000000000ll)
 			/* object was allocated more then 1 sec ago */
diff --git a/samples/bpf/tracex5_user.c b/samples/bpf/tracex5_user.c
index 36b5925bb137..035beea6b31c 100644
--- a/samples/bpf/tracex5_user.c
+++ b/samples/bpf/tracex5_user.c
@@ -8,6 +8,8 @@
 #include "bpf_load.h"
 #include <sys/resource.h>
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 /* install fake seccomp program to enable seccomp code path inside the kernel,
  * so that our kprobe attached to seccomp_phase1() can be triggered
  */
diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
index 8ea4976cfcf1..7a3b4a4b19f3 100644
--- a/samples/bpf/tracex6_user.c
+++ b/samples/bpf/tracex6_user.c
@@ -13,6 +13,8 @@
 
 #define SAMPLE_PERIOD  0x7fffffffffffffffULL
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static void test_bpf_perf_event(void)
 {
 	int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
@@ -36,7 +38,7 @@ static void test_bpf_perf_event(void)
 			goto exit;
 		}
 
-		bpf_update_elem(map_fd[0], &i, &pmu_fd[i], BPF_ANY);
+		bpf_map_update_elem(map_fd[0], &i, &pmu_fd[i], BPF_ANY);
 		ioctl(pmu_fd[i], PERF_EVENT_IOC_ENABLE, 0);
 	}
 
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index a5e109e398a1..7302322f26ff 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -18,6 +18,8 @@
 #include "bpf_load.h"
 #include "libbpf.h"
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static int set_link_xdp_fd(int ifindex, int fd)
 {
 	struct sockaddr_nl sa;
@@ -134,7 +136,7 @@ static void poll_stats(int interval)
 		for (key = 0; key < nr_keys; key++) {
 			__u64 sum = 0;
 
-			assert(bpf_lookup_elem(map_fd[0], &key, values) == 0);
+			assert(bpf_map_lookup_elem(map_fd[0], &key, values) == 0);
 			for (i = 0; i < nr_cpus; i++)
 				sum += (values[i] - prev[key][i]);
 			if (sum)
-- 
2.10.2
