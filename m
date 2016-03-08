From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/3] samples/bpf: add map performance test
Date: Tue, 8 Mar 2016 15:07:54 -0800
Message-ID: <1457478474-1614041-3-git-send-email-ast@fb.com>
References: <1457478474-1614041-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457478474-1614041-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

performance tests for hash map and per-cpu hash map
with and without pre-allocation

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile             |   4 +
 samples/bpf/map_perf_test_kern.c | 100 +++++++++++++++++++++++++
 samples/bpf/map_perf_test_user.c | 155 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 259 insertions(+)
 create mode 100644 samples/bpf/map_perf_test_kern.c
 create mode 100644 samples/bpf/map_perf_test_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 75a13e742ab4..502c9fc8db85 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -18,6 +18,7 @@ hostprogs-y += trace_output
 hostprogs-y += lathist
 hostprogs-y += offwaketime
 hostprogs-y += spintest
+hostprogs-y += map_perf_test
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -36,6 +37,7 @@ trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
 lathist-objs := bpf_load.o libbpf.o lathist_user.o
 offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
 spintest-objs := bpf_load.o libbpf.o spintest_user.o
+map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -53,6 +55,7 @@ always += tcbpf1_kern.o
 always += lathist_kern.o
 always += offwaketime_kern.o
 always += spintest_kern.o
+always += map_perf_test_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -71,6 +74,7 @@ HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
 HOSTLOADLIBES_offwaketime += -lelf
 HOSTLOADLIBES_spintest += -lelf
+HOSTLOADLIBES_map_perf_test += -lelf -lrt
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
new file mode 100644
index 000000000000..311538e5a701
--- /dev/null
+++ b/samples/bpf/map_perf_test_kern.c
@@ -0,0 +1,100 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/version.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+#define MAX_ENTRIES 1000
+
+struct bpf_map_def SEC("maps") hash_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = MAX_ENTRIES,
+};
+
+struct bpf_map_def SEC("maps") percpu_hash_map = {
+	.type = BPF_MAP_TYPE_PERCPU_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = MAX_ENTRIES,
+};
+
+struct bpf_map_def SEC("maps") hash_map_alloc = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = MAX_ENTRIES,
+	.map_flags = BPF_F_NO_PREALLOC,
+};
+
+struct bpf_map_def SEC("maps") percpu_hash_map_alloc = {
+	.type = BPF_MAP_TYPE_PERCPU_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = MAX_ENTRIES,
+	.map_flags = BPF_F_NO_PREALLOC,
+};
+
+SEC("kprobe/sys_getuid")
+int stress_hmap(struct pt_regs *ctx)
+{
+	u32 key = bpf_get_current_pid_tgid();
+	long init_val = 1;
+	long *value;
+
+	bpf_map_update_elem(&hash_map, &key, &init_val, BPF_ANY);
+	value = bpf_map_lookup_elem(&hash_map, &key);
+	if (value)
+		bpf_map_delete_elem(&hash_map, &key);
+	return 0;
+}
+
+SEC("kprobe/sys_geteuid")
+int stress_percpu_hmap(struct pt_regs *ctx)
+{
+	u32 key = bpf_get_current_pid_tgid();
+	long init_val = 1;
+	long *value;
+
+	bpf_map_update_elem(&percpu_hash_map, &key, &init_val, BPF_ANY);
+	value = bpf_map_lookup_elem(&percpu_hash_map, &key);
+	if (value)
+		bpf_map_delete_elem(&percpu_hash_map, &key);
+	return 0;
+}
+SEC("kprobe/sys_getgid")
+int stress_hmap_alloc(struct pt_regs *ctx)
+{
+	u32 key = bpf_get_current_pid_tgid();
+	long init_val = 1;
+	long *value;
+
+	bpf_map_update_elem(&hash_map_alloc, &key, &init_val, BPF_ANY);
+	value = bpf_map_lookup_elem(&hash_map_alloc, &key);
+	if (value)
+		bpf_map_delete_elem(&hash_map_alloc, &key);
+	return 0;
+}
+
+SEC("kprobe/sys_getegid")
+int stress_percpu_hmap_alloc(struct pt_regs *ctx)
+{
+	u32 key = bpf_get_current_pid_tgid();
+	long init_val = 1;
+	long *value;
+
+	bpf_map_update_elem(&percpu_hash_map_alloc, &key, &init_val, BPF_ANY);
+	value = bpf_map_lookup_elem(&percpu_hash_map_alloc, &key);
+	if (value)
+		bpf_map_delete_elem(&percpu_hash_map_alloc, &key);
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
new file mode 100644
index 000000000000..95af56ec5739
--- /dev/null
+++ b/samples/bpf/map_perf_test_user.c
@@ -0,0 +1,155 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#define _GNU_SOURCE
+#include <sched.h>
+#include <stdio.h>
+#include <sys/types.h>
+#include <asm/unistd.h>
+#include <unistd.h>
+#include <assert.h>
+#include <sys/wait.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <linux/bpf.h>
+#include <string.h>
+#include <time.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define MAX_CNT 1000000
+
+static __u64 time_get_ns(void)
+{
+	struct timespec ts;
+
+	clock_gettime(CLOCK_MONOTONIC, &ts);
+	return ts.tv_sec * 1000000000ull + ts.tv_nsec;
+}
+
+#define HASH_PREALLOC		(1 << 0)
+#define PERCPU_HASH_PREALLOC	(1 << 1)
+#define HASH_KMALLOC		(1 << 2)
+#define PERCPU_HASH_KMALLOC	(1 << 3)
+
+static int test_flags = ~0;
+
+static void test_hash_prealloc(int cpu)
+{
+	__u64 start_time;
+	int i;
+
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		syscall(__NR_getuid);
+	printf("%d:hash_map_perf pre-alloc %lld events per sec\n",
+	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+}
+
+static void test_percpu_hash_prealloc(int cpu)
+{
+	__u64 start_time;
+	int i;
+
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		syscall(__NR_geteuid);
+	printf("%d:percpu_hash_map_perf pre-alloc %lld events per sec\n",
+	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+}
+
+static void test_hash_kmalloc(int cpu)
+{
+	__u64 start_time;
+	int i;
+
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		syscall(__NR_getgid);
+	printf("%d:hash_map_perf kmalloc %lld events per sec\n",
+	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+}
+
+static void test_percpu_hash_kmalloc(int cpu)
+{
+	__u64 start_time;
+	int i;
+
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		syscall(__NR_getegid);
+	printf("%d:percpu_hash_map_perf kmalloc %lld events per sec\n",
+	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+}
+
+static void loop(int cpu)
+{
+	cpu_set_t cpuset;
+
+	CPU_ZERO(&cpuset);
+	CPU_SET(cpu, &cpuset);
+	sched_setaffinity(0, sizeof(cpuset), &cpuset);
+
+	if (test_flags & HASH_PREALLOC)
+		test_hash_prealloc(cpu);
+
+	if (test_flags & PERCPU_HASH_PREALLOC)
+		test_percpu_hash_prealloc(cpu);
+
+	if (test_flags & HASH_KMALLOC)
+		test_hash_kmalloc(cpu);
+
+	if (test_flags & PERCPU_HASH_KMALLOC)
+		test_percpu_hash_kmalloc(cpu);
+}
+
+static void run_perf_test(int tasks)
+{
+	pid_t pid[tasks];
+	int i;
+
+	for (i = 0; i < tasks; i++) {
+		pid[i] = fork();
+		if (pid[i] == 0) {
+			loop(i);
+			exit(0);
+		} else if (pid[i] == -1) {
+			printf("couldn't spawn #%d process\n", i);
+			exit(1);
+		}
+	}
+	for (i = 0; i < tasks; i++) {
+		int status;
+
+		assert(waitpid(pid[i], &status, 0) == pid[i]);
+		assert(status == 0);
+	}
+}
+
+int main(int argc, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	char filename[256];
+	int num_cpu = 8;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	setrlimit(RLIMIT_MEMLOCK, &r);
+
+	if (argc > 1)
+		test_flags = atoi(argv[1]) ? : test_flags;
+
+	if (argc > 2)
+		num_cpu = atoi(argv[2]) ? : num_cpu;
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	run_perf_test(num_cpu);
+
+	return 0;
+}
-- 
2.8.0.rc1
