From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 10/10] samples/bpf: add tracepoint vs kprobe performance tests
Date: Wed, 6 Apr 2016 18:43:31 -0700
Message-ID: <1459993411-2754735-11-git-send-email-ast@fb.com>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:29238 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754792AbcDGBnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 21:43:41 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u371hdK9027711
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 18:43:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 225a0392d4-5
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 18:43:41 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 241a2e2afc6211e5a62f24be0593f280-307fc3f0 for <netdev@vger.kernel.org>;	Wed,
 06 Apr 2016 18:43:34 -0700
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the first microbenchmark does
fd=open("/proc/self/comm");
for() {
  write(fd, "test");
}
and on 4 cpus in parallel:
                                      writes per sec
base (no tracepoints, no kprobes)         930k
with kprobe at __set_task_comm()          420k
with tracepoint at task:task_rename       730k

For kprobe + full bpf program manully fetches oldcomm, newcomm via bpf_probe_read.
For tracepint bpf program does nothing, since arguments are copied by tracepoint.

2nd microbenchmark does:
fd=open("/dev/urandom");
for() {
  read(fd, buf);
}
and on 4 cpus in parallel:
                                       reads per sec
base (no tracepoints, no kprobes)         300k
with kprobe at urandom_read()             279k
with tracepoint at random:urandom_read    290k

bpf progs attached to kprobe and tracepoint are noop.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile                    |   5 +
 samples/bpf/test_overhead_kprobe_kern.c |  41 ++++++++
 samples/bpf/test_overhead_tp_kern.c     |  36 +++++++
 samples/bpf/test_overhead_user.c        | 162 ++++++++++++++++++++++++++++++++
 4 files changed, 244 insertions(+)
 create mode 100644 samples/bpf/test_overhead_kprobe_kern.c
 create mode 100644 samples/bpf/test_overhead_tp_kern.c
 create mode 100644 samples/bpf/test_overhead_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 502c9fc8db85..9959771bf808 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -19,6 +19,7 @@ hostprogs-y += lathist
 hostprogs-y += offwaketime
 hostprogs-y += spintest
 hostprogs-y += map_perf_test
+hostprogs-y += test_overhead
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -38,6 +39,7 @@ lathist-objs := bpf_load.o libbpf.o lathist_user.o
 offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
 spintest-objs := bpf_load.o libbpf.o spintest_user.o
 map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
+test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -56,6 +58,8 @@ always += lathist_kern.o
 always += offwaketime_kern.o
 always += spintest_kern.o
 always += map_perf_test_kern.o
+always += test_overhead_tp_kern.o
+always += test_overhead_kprobe_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -75,6 +79,7 @@ HOSTLOADLIBES_lathist += -lelf
 HOSTLOADLIBES_offwaketime += -lelf
 HOSTLOADLIBES_spintest += -lelf
 HOSTLOADLIBES_map_perf_test += -lelf -lrt
+HOSTLOADLIBES_test_overhead += -lelf -lrt
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/test_overhead_kprobe_kern.c b/samples/bpf/test_overhead_kprobe_kern.c
new file mode 100644
index 000000000000..468a66a92ef9
--- /dev/null
+++ b/samples/bpf/test_overhead_kprobe_kern.c
@@ -0,0 +1,41 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/version.h>
+#include <linux/ptrace.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+#define _(P) ({typeof(P) val = 0; bpf_probe_read(&val, sizeof(val), &P); val;})
+
+SEC("kprobe/__set_task_comm")
+int prog(struct pt_regs *ctx)
+{
+	struct signal_struct *signal;
+	struct task_struct *tsk;
+	char oldcomm[16] = {};
+	char newcomm[16] = {};
+	u16 oom_score_adj;
+	u32 pid;
+
+	tsk = (void *)PT_REGS_PARM1(ctx);
+
+	pid = _(tsk->pid);
+	bpf_probe_read(oldcomm, sizeof(oldcomm), &tsk->comm);
+	bpf_probe_read(newcomm, sizeof(newcomm), (void *)PT_REGS_PARM2(ctx));
+	signal = _(tsk->signal);
+	oom_score_adj = _(signal->oom_score_adj);
+	return 0;
+}
+
+SEC("kprobe/urandom_read")
+int prog2(struct pt_regs *ctx)
+{
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/test_overhead_tp_kern.c b/samples/bpf/test_overhead_tp_kern.c
new file mode 100644
index 000000000000..38f5c0b9da9f
--- /dev/null
+++ b/samples/bpf/test_overhead_tp_kern.c
@@ -0,0 +1,36 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+/* from /sys/kernel/debug/tracing/events/task/task_rename/format */
+struct task_rename {
+	__u64 pad;
+	__u32 pid;
+	char oldcomm[16];
+	char newcomm[16];
+	__u16 oom_score_adj;
+};
+SEC("tracepoint/task/task_rename")
+int prog(struct task_rename *ctx)
+{
+	return 0;
+}
+
+/* from /sys/kernel/debug/tracing/events/random/urandom_read/format */
+struct urandom_read {
+	__u64 pad;
+	int got_bits;
+	int pool_left;
+	int input_left;
+};
+SEC("tracepoint/random/urandom_read")
+int prog2(struct urandom_read *ctx)
+{
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/test_overhead_user.c b/samples/bpf/test_overhead_user.c
new file mode 100644
index 000000000000..d291167fd3c7
--- /dev/null
+++ b/samples/bpf/test_overhead_user.c
@@ -0,0 +1,162 @@
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
+#include <fcntl.h>
+#include <unistd.h>
+#include <assert.h>
+#include <sys/wait.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <linux/bpf.h>
+#include <string.h>
+#include <time.h>
+#include <sys/resource.h>
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
+static void test_task_rename(int cpu)
+{
+	__u64 start_time;
+	char buf[] = "test\n";
+	int i, fd;
+
+	fd = open("/proc/self/comm", O_WRONLY|O_TRUNC);
+	if (fd < 0) {
+		printf("couldn't open /proc\n");
+		exit(1);
+	}
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		write(fd, buf, sizeof(buf));
+	printf("task_rename:%d: %lld events per sec\n",
+	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	close(fd);
+}
+
+static void test_urandom_read(int cpu)
+{
+	__u64 start_time;
+	char buf[4];
+	int i, fd;
+
+	fd = open("/dev/urandom", O_RDONLY);
+	if (fd < 0) {
+		printf("couldn't open /dev/urandom\n");
+		exit(1);
+	}
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		read(fd, buf, sizeof(buf));
+	printf("urandom_read:%d: %lld events per sec\n",
+	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	close(fd);
+}
+
+static void loop(int cpu, int flags)
+{
+	cpu_set_t cpuset;
+
+	CPU_ZERO(&cpuset);
+	CPU_SET(cpu, &cpuset);
+	sched_setaffinity(0, sizeof(cpuset), &cpuset);
+
+	if (flags & 1)
+		test_task_rename(cpu);
+	if (flags & 2)
+		test_urandom_read(cpu);
+}
+
+static void run_perf_test(int tasks, int flags)
+{
+	pid_t pid[tasks];
+	int i;
+
+	for (i = 0; i < tasks; i++) {
+		pid[i] = fork();
+		if (pid[i] == 0) {
+			loop(i, flags);
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
+static void unload_progs(void)
+{
+	close(prog_fd[0]);
+	close(prog_fd[1]);
+	close(event_fd[0]);
+	close(event_fd[1]);
+}
+
+int main(int argc, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	char filename[256];
+	int num_cpu = 8;
+	int test_flags = ~0;
+
+	setrlimit(RLIMIT_MEMLOCK, &r);
+
+	if (argc > 1)
+		test_flags = atoi(argv[1]) ? : test_flags;
+	if (argc > 2)
+		num_cpu = atoi(argv[2]) ? : num_cpu;
+
+	if (test_flags & 0x3) {
+		printf("BASE\n");
+		run_perf_test(num_cpu, test_flags);
+	}
+
+	if (test_flags & 0xC) {
+		snprintf(filename, sizeof(filename),
+			 "%s_kprobe_kern.o", argv[0]);
+		if (load_bpf_file(filename)) {
+			printf("%s", bpf_log_buf);
+			return 1;
+		}
+		printf("w/KPROBE\n");
+		run_perf_test(num_cpu, test_flags >> 2);
+		unload_progs();
+	}
+
+	if (test_flags & 0x30) {
+		snprintf(filename, sizeof(filename),
+			 "%s_tp_kern.o", argv[0]);
+		if (load_bpf_file(filename)) {
+			printf("%s", bpf_log_buf);
+			return 1;
+		}
+		printf("w/TRACEPOINT\n");
+		run_perf_test(num_cpu, test_flags >> 4);
+		unload_progs();
+	}
+
+	return 0;
+}
-- 
2.8.0
