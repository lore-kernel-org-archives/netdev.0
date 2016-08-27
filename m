From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 5/6] samples/bpf: add perf_event+bpf example
Date: Fri, 26 Aug 2016 19:31:23 -0700
Message-ID: <1472265084-1767670-6-git-send-email-ast@fb.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472265084-1767670-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bpf program is called 50 times a second and does hashmap[kern&user_stackid]++
It's primary purpose to check that key bpf helpers like map lookup, update,
get_stackid, trace_printk and ctx access are all working.
It checks:
- PERF_COUNT_HW_CPU_CYCLES on all cpus
- PERF_COUNT_HW_CPU_CYCLES for current process and inherited perf_events to children
- PERF_COUNT_SW_CPU_CLOCK on all cpus
- PERF_COUNT_SW_CPU_CLOCK for current process

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile           |   4 +
 samples/bpf/bpf_helpers.h      |   2 +
 samples/bpf/bpf_load.c         |   7 +-
 samples/bpf/trace_event_kern.c |  65 +++++++++++++
 samples/bpf/trace_event_user.c | 213 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 290 insertions(+), 1 deletion(-)
 create mode 100644 samples/bpf/trace_event_kern.c
 create mode 100644 samples/bpf/trace_event_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index db3cb061bfcd..a69cf9045285 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -25,6 +25,7 @@ hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += xdp1
 hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
+hostprogs-y += trace_event
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -52,6 +53,7 @@ xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
 test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
 				       test_current_task_under_cgroup_user.o
+trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -79,6 +81,7 @@ always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
 always += test_current_task_under_cgroup_kern.o
+always += trace_event_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -103,6 +106,7 @@ HOSTLOADLIBES_test_overhead += -lelf -lrt
 HOSTLOADLIBES_xdp1 += -lelf
 HOSTLOADLIBES_xdp2 += -lelf
 HOSTLOADLIBES_test_current_task_under_cgroup += -lelf
+HOSTLOADLIBES_trace_event += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index bbdf62a1e45e..90f44bd2045e 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -55,6 +55,8 @@ static int (*bpf_skb_get_tunnel_opt)(void *ctx, void *md, int size) =
 	(void *) BPF_FUNC_skb_get_tunnel_opt;
 static int (*bpf_skb_set_tunnel_opt)(void *ctx, void *md, int size) =
 	(void *) BPF_FUNC_skb_set_tunnel_opt;
+static unsigned long long (*bpf_get_prandom_u32)(void) =
+	(void *) BPF_FUNC_get_prandom_u32;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 0cfda2320320..97913e109b14 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -51,6 +51,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_kretprobe = strncmp(event, "kretprobe/", 10) == 0;
 	bool is_tracepoint = strncmp(event, "tracepoint/", 11) == 0;
 	bool is_xdp = strncmp(event, "xdp", 3) == 0;
+	bool is_perf_event = strncmp(event, "perf_event", 10) == 0;
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -69,6 +70,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_TRACEPOINT;
 	} else if (is_xdp) {
 		prog_type = BPF_PROG_TYPE_XDP;
+	} else if (is_perf_event) {
+		prog_type = BPF_PROG_TYPE_PERF_EVENT;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -82,7 +85,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
-	if (is_xdp)
+	if (is_xdp || is_perf_event)
 		return 0;
 
 	if (is_socket) {
@@ -326,6 +329,7 @@ int load_bpf_file(char *path)
 			    memcmp(shname_prog, "kretprobe/", 10) == 0 ||
 			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
 			    memcmp(shname_prog, "xdp", 3) == 0 ||
+			    memcmp(shname_prog, "perf_event", 10) == 0 ||
 			    memcmp(shname_prog, "socket", 6) == 0)
 				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
@@ -344,6 +348,7 @@ int load_bpf_file(char *path)
 		    memcmp(shname, "kretprobe/", 10) == 0 ||
 		    memcmp(shname, "tracepoint/", 11) == 0 ||
 		    memcmp(shname, "xdp", 3) == 0 ||
+		    memcmp(shname, "perf_event", 10) == 0 ||
 		    memcmp(shname, "socket", 6) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
diff --git a/samples/bpf/trace_event_kern.c b/samples/bpf/trace_event_kern.c
new file mode 100644
index 000000000000..71a8ed32823e
--- /dev/null
+++ b/samples/bpf/trace_event_kern.c
@@ -0,0 +1,65 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/ptrace.h>
+#include <linux/version.h>
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/bpf_perf_event.h>
+#include <uapi/linux/perf_event.h>
+#include "bpf_helpers.h"
+
+struct key_t {
+	char comm[TASK_COMM_LEN];
+	u32 kernstack;
+	u32 userstack;
+};
+
+struct bpf_map_def SEC("maps") counts = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct key_t),
+	.value_size = sizeof(u64),
+	.max_entries = 10000,
+};
+
+struct bpf_map_def SEC("maps") stackmap = {
+	.type = BPF_MAP_TYPE_STACK_TRACE,
+	.key_size = sizeof(u32),
+	.value_size = PERF_MAX_STACK_DEPTH * sizeof(u64),
+	.max_entries = 10000,
+};
+
+#define KERN_STACKID_FLAGS (0 | BPF_F_FAST_STACK_CMP)
+#define USER_STACKID_FLAGS (0 | BPF_F_FAST_STACK_CMP | BPF_F_USER_STACK)
+
+SEC("perf_event")
+int bpf_prog1(struct bpf_perf_event_data *ctx)
+{
+	char fmt[] = "CPU-%d period %lld ip %llx";
+	u32 cpu = bpf_get_smp_processor_id();
+	struct key_t key;
+	u64 *val, one = 1;
+
+	if (ctx->sample_period < 10000)
+		/* ignore warmup */
+		return 0;
+	bpf_get_current_comm(&key.comm, sizeof(key.comm));
+	key.kernstack = bpf_get_stackid(ctx, &stackmap, KERN_STACKID_FLAGS);
+	key.userstack = bpf_get_stackid(ctx, &stackmap, USER_STACKID_FLAGS);
+	if ((int)key.kernstack < 0 && (int)key.userstack < 0) {
+		bpf_trace_printk(fmt, sizeof(fmt), cpu, ctx->sample_period,
+				 ctx->regs.ip);
+		return 0;
+	}
+
+	val = bpf_map_lookup_elem(&counts, &key);
+	if (val)
+		(*val)++;
+	else
+		bpf_map_update_elem(&counts, &key, &one, BPF_NOEXIST);
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
new file mode 100644
index 000000000000..9a130d31ecf2
--- /dev/null
+++ b/samples/bpf/trace_event_user.c
@@ -0,0 +1,213 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <string.h>
+#include <fcntl.h>
+#include <poll.h>
+#include <sys/ioctl.h>
+#include <linux/perf_event.h>
+#include <linux/bpf.h>
+#include <signal.h>
+#include <assert.h>
+#include <errno.h>
+#include <sys/resource.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define SAMPLE_FREQ 50
+
+static bool sys_read_seen, sys_write_seen;
+
+static void print_ksym(__u64 addr)
+{
+	struct ksym *sym;
+
+	if (!addr)
+		return;
+	sym = ksym_search(addr);
+	printf("%s;", sym->name);
+	if (!strcmp(sym->name, "sys_read"))
+		sys_read_seen = true;
+	else if (!strcmp(sym->name, "sys_write"))
+		sys_write_seen = true;
+}
+
+static void print_addr(__u64 addr)
+{
+	if (!addr)
+		return;
+	printf("%llx;", addr);
+}
+
+#define TASK_COMM_LEN 16
+
+struct key_t {
+	char comm[TASK_COMM_LEN];
+	__u32 kernstack;
+	__u32 userstack;
+};
+
+static void print_stack(struct key_t *key, __u64 count)
+{
+	__u64 ip[PERF_MAX_STACK_DEPTH] = {};
+	static bool warned;
+	int i;
+
+	printf("%3lld %s;", count, key->comm);
+	if (bpf_lookup_elem(map_fd[1], &key->kernstack, ip) != 0) {
+		printf("---;");
+	} else {
+		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
+			print_ksym(ip[i]);
+	}
+	printf("-;");
+	if (bpf_lookup_elem(map_fd[1], &key->userstack, ip) != 0) {
+		printf("---;");
+	} else {
+		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
+			print_addr(ip[i]);
+	}
+	printf("\n");
+
+	if (key->kernstack == -EEXIST && !warned) {
+		printf("stackmap collisions seen. Consider increasing size\n");
+		warned = true;
+	} else if ((int)key->kernstack < 0 && (int)key->userstack < 0) {
+		printf("err stackid %d %d\n", key->kernstack, key->userstack);
+	}
+}
+
+static void int_exit(int sig)
+{
+	kill(0, SIGKILL);
+	exit(0);
+}
+
+static void print_stacks(void)
+{
+	struct key_t key = {}, next_key;
+	__u64 value;
+	__u32 stackid = 0, next_id;
+	int fd = map_fd[0], stack_map = map_fd[1];
+
+	sys_read_seen = sys_write_seen = false;
+	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_lookup_elem(fd, &next_key, &value);
+		print_stack(&next_key, value);
+		bpf_delete_elem(fd, &next_key);
+		key = next_key;
+	}
+
+	if (!sys_read_seen || !sys_write_seen) {
+		printf("BUG kernel stack doesn't contain sys_read() and sys_write()\n");
+		int_exit(0);
+	}
+
+	/* clear stack map */
+	while (bpf_get_next_key(stack_map, &stackid, &next_id) == 0) {
+		bpf_delete_elem(stack_map, &next_id);
+		stackid = next_id;
+	}
+}
+
+static void test_perf_event_all_cpu(struct perf_event_attr *attr)
+{
+	int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	int *pmu_fd = malloc(nr_cpus * sizeof(int));
+	int i;
+
+	/* open perf_event on all cpus */
+	for (i = 0; i < nr_cpus; i++) {
+		pmu_fd[i] = perf_event_open(attr, -1, i, -1, 0);
+		if (pmu_fd[i] < 0) {
+			printf("perf_event_open failed\n");
+			goto all_cpu_err;
+		}
+		assert(ioctl(pmu_fd[i], PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
+		assert(ioctl(pmu_fd[i], PERF_EVENT_IOC_ENABLE, 0) == 0);
+	}
+	system("dd if=/dev/zero of=/dev/null count=5000k");
+	print_stacks();
+all_cpu_err:
+	for (i--; i >= 0; i--)
+		close(pmu_fd[i]);
+	free(pmu_fd);
+}
+
+static void test_perf_event_task(struct perf_event_attr *attr)
+{
+	int pmu_fd;
+
+	/* open task bound event */
+	pmu_fd = perf_event_open(attr, 0, -1, -1, 0);
+	if (pmu_fd < 0) {
+		printf("perf_event_open failed\n");
+		return;
+	}
+	assert(ioctl(pmu_fd, PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
+	assert(ioctl(pmu_fd, PERF_EVENT_IOC_ENABLE, 0) == 0);
+	system("dd if=/dev/zero of=/dev/null count=5000k");
+	print_stacks();
+	close(pmu_fd);
+}
+
+static void test_bpf_perf_event(void)
+{
+	struct perf_event_attr attr_type_hw = {
+		.sample_freq = SAMPLE_FREQ,
+		.freq = 1,
+		.type = PERF_TYPE_HARDWARE,
+		.config = PERF_COUNT_HW_CPU_CYCLES,
+		.inherit = 1,
+	};
+	struct perf_event_attr attr_type_sw = {
+		.sample_freq = SAMPLE_FREQ,
+		.freq = 1,
+		.type = PERF_TYPE_SOFTWARE,
+		.config = PERF_COUNT_SW_CPU_CLOCK,
+		.inherit = 1,
+	};
+
+	test_perf_event_all_cpu(&attr_type_hw);
+	test_perf_event_task(&attr_type_hw);
+	test_perf_event_all_cpu(&attr_type_sw);
+	test_perf_event_task(&attr_type_sw);
+}
+
+
+int main(int argc, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	char filename[256];
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	setrlimit(RLIMIT_MEMLOCK, &r);
+
+	signal(SIGINT, int_exit);
+
+	if (load_kallsyms()) {
+		printf("failed to process /proc/kallsyms\n");
+		return 1;
+	}
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 2;
+	}
+
+	if (fork() == 0) {
+		read_trace_pipe();
+		return 0;
+	}
+	test_bpf_perf_event();
+
+	int_exit(0);
+	return 0;
+}
-- 
2.8.0
