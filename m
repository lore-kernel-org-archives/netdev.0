From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 6/6] samples/bpf: add sampleip example
Date: Fri, 26 Aug 2016 19:31:24 -0700
Message-ID: <1472265084-1767670-7-git-send-email-ast@fb.com>
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

From: Brendan Gregg <bgregg@netflix.com>

sample instruction pointer and frequency count in a BPF map

Signed-off-by: Brendan Gregg <bgregg@netflix.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile        |   4 +
 samples/bpf/sampleip_kern.c |  38 +++++++++
 samples/bpf/sampleip_user.c | 196 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 238 insertions(+)
 create mode 100644 samples/bpf/sampleip_kern.c
 create mode 100644 samples/bpf/sampleip_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index a69cf9045285..12b7304d55dc 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -26,6 +26,7 @@ hostprogs-y += xdp1
 hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
 hostprogs-y += trace_event
+hostprogs-y += sampleip
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -54,6 +55,7 @@ xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
 test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
 				       test_current_task_under_cgroup_user.o
 trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
+sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -82,6 +84,7 @@ always += xdp1_kern.o
 always += xdp2_kern.o
 always += test_current_task_under_cgroup_kern.o
 always += trace_event_kern.o
+always += sampleip_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -107,6 +110,7 @@ HOSTLOADLIBES_xdp1 += -lelf
 HOSTLOADLIBES_xdp2 += -lelf
 HOSTLOADLIBES_test_current_task_under_cgroup += -lelf
 HOSTLOADLIBES_trace_event += -lelf
+HOSTLOADLIBES_sampleip += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/sampleip_kern.c b/samples/bpf/sampleip_kern.c
new file mode 100644
index 000000000000..774a681f374a
--- /dev/null
+++ b/samples/bpf/sampleip_kern.c
@@ -0,0 +1,38 @@
+/* Copyright 2016 Netflix, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/version.h>
+#include <linux/ptrace.h>
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/bpf_perf_event.h>
+#include "bpf_helpers.h"
+
+#define MAX_IPS		8192
+
+struct bpf_map_def SEC("maps") ip_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u64),
+	.value_size = sizeof(u32),
+	.max_entries = MAX_IPS,
+};
+
+SEC("perf_event")
+int do_sample(struct bpf_perf_event_data *ctx)
+{
+	u64 ip;
+	u32 *value, init_val = 1;
+
+	ip = ctx->regs.ip;
+	value = bpf_map_lookup_elem(&ip_map, &ip);
+	if (value)
+		*value += 1;
+	else
+		/* E2BIG not tested for this example only */
+		bpf_map_update_elem(&ip_map, &ip, &init_val, BPF_NOEXIST);
+
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/sampleip_user.c b/samples/bpf/sampleip_user.c
new file mode 100644
index 000000000000..260a6bdd6413
--- /dev/null
+++ b/samples/bpf/sampleip_user.c
@@ -0,0 +1,196 @@
+/*
+ * sampleip: sample instruction pointer and frequency count in a BPF map.
+ *
+ * Copyright 2016 Netflix, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <errno.h>
+#include <signal.h>
+#include <string.h>
+#include <assert.h>
+#include <linux/perf_event.h>
+#include <linux/ptrace.h>
+#include <linux/bpf.h>
+#include <sys/ioctl.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define DEFAULT_FREQ	99
+#define DEFAULT_SECS	5
+#define MAX_IPS		8192
+#define PAGE_OFFSET	0xffff880000000000
+
+static int nr_cpus;
+
+static void usage(void)
+{
+	printf("USAGE: sampleip [-F freq] [duration]\n");
+	printf("       -F freq    # sample frequency (Hertz), default 99\n");
+	printf("       duration   # sampling duration (seconds), default 5\n");
+}
+
+static int sampling_start(int *pmu_fd, int freq)
+{
+	int i;
+
+	struct perf_event_attr pe_sample_attr = {
+		.type = PERF_TYPE_SOFTWARE,
+		.freq = 1,
+		.sample_period = freq,
+		.config = PERF_COUNT_SW_CPU_CLOCK,
+		.inherit = 1,
+	};
+
+	for (i = 0; i < nr_cpus; i++) {
+		pmu_fd[i] = perf_event_open(&pe_sample_attr, -1 /* pid */, i,
+					    -1 /* group_fd */, 0 /* flags */);
+		if (pmu_fd[i] < 0) {
+			fprintf(stderr, "ERROR: Initializing perf sampling\n");
+			return 1;
+		}
+		assert(ioctl(pmu_fd[i], PERF_EVENT_IOC_SET_BPF,
+			     prog_fd[0]) == 0);
+		assert(ioctl(pmu_fd[i], PERF_EVENT_IOC_ENABLE, 0) == 0);
+	}
+
+	return 0;
+}
+
+static void sampling_end(int *pmu_fd)
+{
+	int i;
+
+	for (i = 0; i < nr_cpus; i++)
+		close(pmu_fd[i]);
+}
+
+struct ipcount {
+	__u64 ip;
+	__u32 count;
+};
+
+/* used for sorting */
+struct ipcount counts[MAX_IPS];
+
+static int count_cmp(const void *p1, const void *p2)
+{
+	return ((struct ipcount *)p1)->count - ((struct ipcount *)p2)->count;
+}
+
+static void print_ip_map(int fd)
+{
+	struct ksym *sym;
+	__u64 key, next_key;
+	__u32 value;
+	int i, max;
+
+	printf("%-19s %-32s %s\n", "ADDR", "KSYM", "COUNT");
+
+	/* fetch IPs and counts */
+	key = 0, i = 0;
+	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_lookup_elem(fd, &next_key, &value);
+		counts[i].ip = next_key;
+		counts[i++].count = value;
+		key = next_key;
+	}
+	max = i;
+
+	/* sort and print */
+	qsort(counts, max, sizeof(struct ipcount), count_cmp);
+	for (i = 0; i < max; i++) {
+		if (counts[i].ip > PAGE_OFFSET) {
+			sym = ksym_search(counts[i].ip);
+			printf("0x%-17llx %-32s %u\n", counts[i].ip, sym->name,
+			       counts[i].count);
+		} else {
+			printf("0x%-17llx %-32s %u\n", counts[i].ip, "(user)",
+			       counts[i].count);
+		}
+	}
+
+	if (max == MAX_IPS) {
+		printf("WARNING: IP hash was full (max %d entries); ", max);
+		printf("may have dropped samples\n");
+	}
+}
+
+static void int_exit(int sig)
+{
+	printf("\n");
+	print_ip_map(map_fd[0]);
+	exit(0);
+}
+
+int main(int argc, char **argv)
+{
+	char filename[256];
+	int *pmu_fd, opt, freq = DEFAULT_FREQ, secs = DEFAULT_SECS;
+
+	/* process arguments */
+	while ((opt = getopt(argc, argv, "F:h")) != -1) {
+		switch (opt) {
+		case 'F':
+			freq = atoi(optarg);
+			break;
+		case 'h':
+		default:
+			usage();
+			return 0;
+		}
+	}
+	if (argc - optind == 1)
+		secs = atoi(argv[optind]);
+	if (freq == 0 || secs == 0) {
+		usage();
+		return 1;
+	}
+
+	/* initialize kernel symbol translation */
+	if (load_kallsyms()) {
+		fprintf(stderr, "ERROR: loading /proc/kallsyms\n");
+		return 2;
+	}
+
+	/* create perf FDs for each CPU */
+	nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	pmu_fd = malloc(nr_cpus * sizeof(int));
+	if (pmu_fd == NULL) {
+		fprintf(stderr, "ERROR: malloc of pmu_fd\n");
+		return 1;
+	}
+
+	/* load BPF program */
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	if (load_bpf_file(filename)) {
+		fprintf(stderr, "ERROR: loading BPF program (errno %d):\n",
+			errno);
+		if (strcmp(bpf_log_buf, "") == 0)
+			fprintf(stderr, "Try: ulimit -l unlimited\n");
+		else
+			fprintf(stderr, "%s", bpf_log_buf);
+		return 1;
+	}
+	signal(SIGINT, int_exit);
+
+	/* do sampling */
+	printf("Sampling at %d Hertz for %d seconds. Ctrl-C also ends.\n",
+	       freq, secs);
+	if (sampling_start(pmu_fd, freq) != 0)
+		return 1;
+	sleep(secs);
+	sampling_end(pmu_fd);
+	free(pmu_fd);
+
+	/* output sample counts */
+	print_ip_map(map_fd[0]);
+
+	return 0;
+}
-- 
2.8.0
