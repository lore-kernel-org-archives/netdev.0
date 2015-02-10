From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 linux-trace 6/8] samples: bpf: IO latency analysis (iosnoop/heatmap)
Date: Mon,  9 Feb 2015 19:45:59 -0800
Message-ID: <1423539961-21792-7-git-send-email-ast@plumgrid.com>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eBPF C program attaches to block_rq_issue/block_rq_complete events to calculate
IO latency. Then it waits for the first 100 events to compute average latency
and uses range [0 .. ave_lat * 2] to record histogram of events in this latency
range.
User space reads this histogram map every 2 seconds and prints it as a 'heatmap'
using gray shades of text terminal. Black spaces have many events and white
spaces have very few events. Left most space is the smallest latency, right most
space is the largest latency in the range.
If kernel sees too many events that fall out of histogram range, user space
adjusts the range up, so heatmap for next 2 seconds will be more accurate.

Usage:
$ sudo ./tracex3
and do 'sudo dd if=/dev/sda of=/dev/null' in other terminal.
Observe IO latencies and how different activity (like 'make kernel') affects it.

Similar experiments can be done for network transmit latencies, syscalls, etc

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 ++
 samples/bpf/tracex3_kern.c |   98 ++++++++++++++++++++++++++++
 samples/bpf/tracex3_user.c |  152 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 254 insertions(+)
 create mode 100644 samples/bpf/tracex3_kern.c
 create mode 100644 samples/bpf/tracex3_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 416af24b01fd..da0efd8032ab 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -9,6 +9,7 @@ hostprogs-y += sockex2
 hostprogs-y += dropmon
 hostprogs-y += tracex1
 hostprogs-y += tracex2
+hostprogs-y += tracex3
 
 dropmon-objs := dropmon.o libbpf.o
 test_verifier-objs := test_verifier.o libbpf.o
@@ -18,6 +19,7 @@ sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
 tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
+tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -25,6 +27,7 @@ always += sockex1_kern.o
 always += sockex2_kern.o
 always += tracex1_kern.o
 always += tracex2_kern.o
+always += tracex3_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -33,6 +36,7 @@ HOSTLOADLIBES_sockex1 += -lelf
 HOSTLOADLIBES_sockex2 += -lelf
 HOSTLOADLIBES_tracex1 += -lelf
 HOSTLOADLIBES_tracex2 += -lelf
+HOSTLOADLIBES_tracex3 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/tracex3_kern.c b/samples/bpf/tracex3_kern.c
new file mode 100644
index 000000000000..961f3f373270
--- /dev/null
+++ b/samples/bpf/tracex3_kern.c
@@ -0,0 +1,98 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(long),
+	.value_size = sizeof(u64),
+	.max_entries = 4096,
+};
+
+SEC("events/block/block_rq_issue")
+int bpf_prog1(struct bpf_context *ctx)
+{
+	long rq = ctx->arg2;
+	u64 val = bpf_ktime_get_ns();
+
+	bpf_map_update_elem(&my_map, &rq, &val, BPF_ANY);
+	return 0;
+}
+
+struct globals {
+	u64 lat_ave;
+	u64 lat_sum;
+	u64 missed;
+	u64 max_lat;
+	int num_samples;
+};
+
+struct bpf_map_def SEC("maps") global_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(struct globals),
+	.max_entries = 1,
+};
+
+#define MAX_SLOT 32
+
+struct bpf_map_def SEC("maps") lat_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(u64),
+	.max_entries = MAX_SLOT,
+};
+
+SEC("events/block/block_rq_complete")
+int bpf_prog2(struct bpf_context *ctx)
+{
+	long rq = ctx->arg2;
+	void *value;
+
+	value = bpf_map_lookup_elem(&my_map, &rq);
+	if (!value)
+		return 0;
+
+	u64 cur_time = bpf_ktime_get_ns();
+	u64 delta = (cur_time - *(u64 *)value) / 1000;
+
+	bpf_map_delete_elem(&my_map, &rq);
+
+	int ind = 0;
+	struct globals *g = bpf_map_lookup_elem(&global_map, &ind);
+
+	if (!g)
+		return 0;
+	if (g->lat_ave == 0) {
+		g->num_samples++;
+		g->lat_sum += delta;
+		if (g->num_samples >= 100)
+			g->lat_ave = g->lat_sum / g->num_samples;
+	} else {
+		u64 max_lat = g->lat_ave * 2;
+
+		if (delta > max_lat) {
+			g->missed++;
+			if (delta > g->max_lat)
+				g->max_lat = delta;
+			return 0;
+		}
+
+		ind = delta * MAX_SLOT / max_lat;
+		value = bpf_map_lookup_elem(&lat_map, &ind);
+		if (!value)
+			return 0;
+		(*(u64 *)value)++;
+	}
+
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/tracex3_user.c b/samples/bpf/tracex3_user.c
new file mode 100644
index 000000000000..c49f41f28cba
--- /dev/null
+++ b/samples/bpf/tracex3_user.c
@@ -0,0 +1,152 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+
+struct globals {
+	__u64 lat_ave;
+	__u64 lat_sum;
+	__u64 missed;
+	__u64 max_lat;
+	int num_samples;
+};
+
+static void clear_stats(int fd)
+{
+	int key;
+	__u64 value = 0;
+
+	for (key = 0; key < 32; key++)
+		bpf_update_elem(fd, &key, &value, BPF_ANY);
+}
+
+const char *color[] = {
+	"\033[48;5;255m",
+	"\033[48;5;252m",
+	"\033[48;5;250m",
+	"\033[48;5;248m",
+	"\033[48;5;246m",
+	"\033[48;5;244m",
+	"\033[48;5;242m",
+	"\033[48;5;240m",
+	"\033[48;5;238m",
+	"\033[48;5;236m",
+	"\033[48;5;234m",
+	"\033[48;5;232m",
+};
+const int num_colors = ARRAY_SIZE(color);
+
+const char nocolor[] = "\033[00m";
+
+static void print_banner(__u64 max_lat)
+{
+	printf("0 usec     ...          %lld usec\n", max_lat);
+}
+
+static void print_hist(int fd)
+{
+	int key;
+	__u64 value;
+	__u64 cnt[32];
+	__u64 max_cnt = 0;
+	__u64 total_events = 0;
+	int max_bucket = 0;
+
+	for (key = 0; key < 32; key++) {
+		value = 0;
+		bpf_lookup_elem(fd, &key, &value);
+		if (value > 0)
+			max_bucket = key;
+		cnt[key] = value;
+		total_events += value;
+		if (value > max_cnt)
+			max_cnt = value;
+	}
+	clear_stats(fd);
+	for (key = 0; key < 32; key++) {
+		int c = num_colors * cnt[key] / (max_cnt + 1);
+
+		printf("%s %s", color[c], nocolor);
+	}
+	printf(" captured=%lld", total_events);
+
+	key = 0;
+	struct globals g = {};
+
+	bpf_lookup_elem(map_fd[1], &key, &g);
+
+	printf(" missed=%lld max_lat=%lld usec\n",
+	       g.missed, g.max_lat);
+
+	if (g.missed > 10 && g.missed > total_events / 10) {
+		printf("adjusting range UP...\n");
+		g.lat_ave = g.max_lat / 2;
+		print_banner(g.lat_ave * 2);
+	} else if (max_bucket < 4 && total_events > 100) {
+		printf("adjusting range DOWN...\n");
+		g.lat_ave = g.lat_ave / 4;
+		print_banner(g.lat_ave * 2);
+	}
+	/* clear some globals */
+	g.missed = 0;
+	g.max_lat = 0;
+	bpf_update_elem(map_fd[1], &key, &g, BPF_ANY);
+}
+
+static void int_exit(int sig)
+{
+	print_hist(map_fd[2]);
+	exit(0);
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	clear_stats(map_fd[2]);
+
+	signal(SIGINT, int_exit);
+
+	struct globals g;
+
+	printf("waiting for events to determine average latency...\n");
+	for (;;) {
+		int key = 0;
+
+		bpf_lookup_elem(map_fd[1], &key, &g);
+		if (g.lat_ave)
+			break;
+		sleep(1);
+	}
+
+	printf("  IO latency in usec\n"
+	       "  %s %s - many events with this latency\n"
+	       "  %s %s - few events\n",
+	       color[num_colors - 1], nocolor,
+	       color[0], nocolor);
+	print_banner(g.lat_ave * 2);
+	for (;;) {
+		print_hist(map_fd[2]);
+		sleep(2);
+	}
+
+	return 0;
+}
-- 
1.7.9.5
