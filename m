From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/3] samples/bpf: offwaketime example
Date: Wed, 17 Feb 2016 19:58:59 -0800
Message-ID: <1455767939-2700534-4-git-send-email-ast@fb.com>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455767939-2700534-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is simplified version of Brendan Gregg's offwaketime:
This program shows kernel stack traces and task names that were blocked and
"off-CPU", along with the stack traces and task names for the threads that woke
them, and the total elapsed time from when they blocked to when they were woken
up. The combined stacks, task names, and total time is summarized in kernel
context for efficiency.

Example:
$ sudo ./offwaketime | flamegraph.pl > demo.svg
Open demo.svg in the browser as FlameGraph visualization.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile           |   4 +
 samples/bpf/bpf_helpers.h      |   2 +
 samples/bpf/offwaketime_kern.c | 131 +++++++++++++++++++++++++++++
 samples/bpf/offwaketime_user.c | 185 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 322 insertions(+)
 create mode 100644 samples/bpf/offwaketime_kern.c
 create mode 100644 samples/bpf/offwaketime_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index edd638b5825f..c4f8ae0c8afe 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -16,6 +16,7 @@ hostprogs-y += tracex5
 hostprogs-y += tracex6
 hostprogs-y += trace_output
 hostprogs-y += lathist
+hostprogs-y += offwaketime
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -32,6 +33,7 @@ tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
 tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
 trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
 lathist-objs := bpf_load.o libbpf.o lathist_user.o
+offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -47,6 +49,7 @@ always += tracex6_kern.o
 always += trace_output_kern.o
 always += tcbpf1_kern.o
 always += lathist_kern.o
+always += offwaketime_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -63,6 +66,7 @@ HOSTLOADLIBES_tracex5 += -lelf
 HOSTLOADLIBES_tracex6 += -lelf
 HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
+HOSTLOADLIBES_offwaketime += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 7ad19e1dbaf4..811bcca0f29d 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -39,6 +39,8 @@ static int (*bpf_redirect)(int ifindex, int flags) =
 	(void *) BPF_FUNC_redirect;
 static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data, int size) =
 	(void *) BPF_FUNC_perf_event_output;
+static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
+	(void *) BPF_FUNC_get_stackid;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/offwaketime_kern.c b/samples/bpf/offwaketime_kern.c
new file mode 100644
index 000000000000..c0aa5a9b9c48
--- /dev/null
+++ b/samples/bpf/offwaketime_kern.c
@@ -0,0 +1,131 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+#include <uapi/linux/ptrace.h>
+#include <uapi/linux/perf_event.h>
+#include <linux/version.h>
+#include <linux/sched.h>
+
+#define _(P) ({typeof(P) val = 0; bpf_probe_read(&val, sizeof(val), &P); val;})
+
+#define MINBLOCK_US	1
+
+struct key_t {
+	char waker[TASK_COMM_LEN];
+	char target[TASK_COMM_LEN];
+	u32 wret;
+	u32 tret;
+};
+
+struct bpf_map_def SEC("maps") counts = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct key_t),
+	.value_size = sizeof(u64),
+	.max_entries = 10000,
+};
+
+struct bpf_map_def SEC("maps") start = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(u64),
+	.max_entries = 10000,
+};
+
+struct wokeby_t {
+	char name[TASK_COMM_LEN];
+	u32 ret;
+};
+
+struct bpf_map_def SEC("maps") wokeby = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(struct wokeby_t),
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
+#define STACKID_FLAGS (0 | BPF_F_FAST_STACK_CMP)
+
+SEC("kprobe/try_to_wake_up")
+int waker(struct pt_regs *ctx)
+{
+	struct task_struct *p = (void *) PT_REGS_PARM1(ctx);
+	struct wokeby_t woke = {};
+	u32 pid;
+
+	pid = _(p->pid);
+
+	bpf_get_current_comm(&woke.name, sizeof(woke.name));
+	woke.ret = bpf_get_stackid(ctx, &stackmap, STACKID_FLAGS);
+
+	bpf_map_update_elem(&wokeby, &pid, &woke, BPF_ANY);
+	return 0;
+}
+
+static inline int update_counts(struct pt_regs *ctx, u32 pid, u64 delta)
+{
+	struct key_t key = {};
+	struct wokeby_t *woke;
+	u64 zero = 0, *val;
+
+	bpf_get_current_comm(&key.target, sizeof(key.target));
+	key.tret = bpf_get_stackid(ctx, &stackmap, STACKID_FLAGS);
+
+	woke = bpf_map_lookup_elem(&wokeby, &pid);
+	if (woke) {
+		key.wret = woke->ret;
+		__builtin_memcpy(&key.waker, woke->name, TASK_COMM_LEN);
+		bpf_map_delete_elem(&wokeby, &pid);
+	}
+
+	val = bpf_map_lookup_elem(&counts, &key);
+	if (!val) {
+		bpf_map_update_elem(&counts, &key, &zero, BPF_NOEXIST);
+		val = bpf_map_lookup_elem(&counts, &key);
+		if (!val)
+			return 0;
+	}
+	(*val) += delta;
+	return 0;
+}
+
+SEC("kprobe/finish_task_switch")
+int oncpu(struct pt_regs *ctx)
+{
+	struct task_struct *p = (void *) PT_REGS_PARM1(ctx);
+	u64 delta, ts, *tsp;
+	u32 pid;
+
+	/* record previous thread sleep time */
+	pid = _(p->pid);
+	ts = bpf_ktime_get_ns();
+	bpf_map_update_elem(&start, &pid, &ts, BPF_ANY);
+
+	/* calculate current thread's delta time */
+	pid = bpf_get_current_pid_tgid();
+	tsp = bpf_map_lookup_elem(&start, &pid);
+	if (!tsp)
+		/* missed start or filtered */
+		return 0;
+
+	delta = bpf_ktime_get_ns() - *tsp;
+	bpf_map_delete_elem(&start, &pid);
+	delta = delta / 1000;
+	if (delta < MINBLOCK_US)
+		return 0;
+
+	return update_counts(ctx, pid, delta);
+}
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/offwaketime_user.c b/samples/bpf/offwaketime_user.c
new file mode 100644
index 000000000000..17cf3024e22c
--- /dev/null
+++ b/samples/bpf/offwaketime_user.c
@@ -0,0 +1,185 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <linux/bpf.h>
+#include <string.h>
+#include <linux/perf_event.h>
+#include <errno.h>
+#include <assert.h>
+#include <stdbool.h>
+#include <sys/resource.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define MAX_SYMS 300000
+#define PRINT_RAW_ADDR 0
+
+static struct ksym {
+	long addr;
+	char *name;
+} syms[MAX_SYMS];
+static int sym_cnt;
+
+static int ksym_cmp(const void *p1, const void *p2)
+{
+	return ((struct ksym *)p1)->addr - ((struct ksym *)p2)->addr;
+}
+
+static int load_kallsyms(void)
+{
+	FILE *f = fopen("/proc/kallsyms", "r");
+	char func[256], buf[256];
+	char symbol;
+	void *addr;
+	int i = 0;
+
+	if (!f)
+		return -ENOENT;
+
+	while (!feof(f)) {
+		if (!fgets(buf, sizeof(buf), f))
+			break;
+		if (sscanf(buf, "%p %c %s", &addr, &symbol, func) != 3)
+			break;
+		if (!addr)
+			continue;
+		syms[i].addr = (long) addr;
+		syms[i].name = strdup(func);
+		i++;
+	}
+	sym_cnt = i;
+	qsort(syms, sym_cnt, sizeof(struct ksym), ksym_cmp);
+	return 0;
+}
+
+static void *search(long key)
+{
+	int start = 0, end = sym_cnt;
+	int result;
+
+	while (start < end) {
+		size_t mid = start + (end - start) / 2;
+
+		result = key - syms[mid].addr;
+		if (result < 0)
+			end = mid;
+		else if (result > 0)
+			start = mid + 1;
+		else
+			return &syms[mid];
+	}
+
+	if (start >= 1 && syms[start - 1].addr < key &&
+	    key < syms[start].addr)
+		/* valid ksym */
+		return &syms[start - 1];
+
+	/* out of range. return _stext */
+	return &syms[0];
+}
+
+static void print_ksym(__u64 addr)
+{
+	struct ksym *sym;
+
+	if (!addr)
+		return;
+	sym = search(addr);
+	if (PRINT_RAW_ADDR)
+		printf("%s/%llx;", sym->name, addr);
+	else
+		printf("%s;", sym->name);
+}
+
+#define TASK_COMM_LEN 16
+
+struct key_t {
+	char waker[TASK_COMM_LEN];
+	char target[TASK_COMM_LEN];
+	__u32 wret;
+	__u32 tret;
+};
+
+static void print_stack(struct key_t *key, __u64 count)
+{
+	__u64 ip[PERF_MAX_STACK_DEPTH] = {};
+	static bool warned;
+	int i;
+
+	printf("%s;", key->target);
+	if (bpf_lookup_elem(map_fd[3], &key->tret, ip) != 0) {
+		printf("---;");
+	} else {
+		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
+			print_ksym(ip[i]);
+	}
+	printf("-;");
+	if (bpf_lookup_elem(map_fd[3], &key->wret, ip) != 0) {
+		printf("---;");
+	} else {
+		for (i = 0; i < PERF_MAX_STACK_DEPTH; i++)
+			print_ksym(ip[i]);
+	}
+	printf(";%s %lld\n", key->waker, count);
+
+	if ((key->tret == -EEXIST || key->wret == -EEXIST) && !warned) {
+		printf("stackmap collisions seen. Consider increasing size\n");
+		warned = true;
+	} else if (((int)(key->tret) < 0 || (int)(key->wret) < 0)) {
+		printf("err stackid %d %d\n", key->tret, key->wret);
+	}
+}
+
+static void print_stacks(int fd)
+{
+	struct key_t key = {}, next_key;
+	__u64 value;
+
+	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_lookup_elem(fd, &next_key, &value);
+		print_stack(&next_key, value);
+		key = next_key;
+	}
+}
+
+static void int_exit(int sig)
+{
+	print_stacks(map_fd[0]);
+	exit(0);
+}
+
+int main(int argc, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	char filename[256];
+	int delay = 1;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	setrlimit(RLIMIT_MEMLOCK, &r);
+
+	signal(SIGINT, int_exit);
+
+	if (load_kallsyms()) {
+		printf("failed to process /proc/kallsyms\n");
+		return 2;
+	}
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	if (argc > 1)
+		delay = atoi(argv[1]);
+	sleep(delay);
+	print_stacks(map_fd[0]);
+
+	return 0;
+}
-- 
2.4.6
