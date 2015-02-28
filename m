From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 tip 7/7] samples: bpf: IO latency analysis (iosnoop/heatmap)
Date: Fri, 27 Feb 2015 16:08:55 -0800
Message-ID: <1425082135-11967-8-git-send-email-ast@plumgrid.com>
References: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF C program attaches to blk_mq_start_request/blk_update_request kprobe events
to calculate IO latency.
For every completed block IO event it computes the time delta in nsec
and records in a histogram map: map[log10(delta)*10]++
User space reads this histogram map every 2 seconds and prints it as a 'heatmap'
using gray shades of text terminal. Black spaces have many events and white
spaces have very few events. Left most space is the smallest latency, right most
space is the largest latency in the range.

Usage:
$ sudo ./tracex3
and do 'sudo dd if=/dev/sda of=/dev/null' in other terminal.
Observe IO latencies and how different activity (like 'make kernel') affects it.

Similar experiments can be done for network transmit latencies, syscalls, etc

'-t' flag prints the heatmap using normal ascii characters:

$ sudo ./tracex3 -t
  heatmap of IO latency
  # - many events with this latency
    - few events
|1us      |10us     |100us    |1ms      |10ms     |100ms    |1s       |10s
                         *ooo. *O.#.                                    # 221
                      .  *#     .                                       # 125
                         ..   .o#*..                                    # 55
                    .  . .  .  .#O                                      # 37
                         .#                                             # 175
                               .#*.                                     # 37
                          #                                             # 199
              .              . *#*.                                     # 55
                               *#..*                                    # 42
                          #                                             # 266
                      ...***Oo#*OO**o#* .                               # 629
                          #                                             # 271
                              . .#o* o.*o*                              # 221
                        . . o* *#O..                                    # 50

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 ++
 samples/bpf/tracex3_kern.c |   89 ++++++++++++++++++++++++++
 samples/bpf/tracex3_user.c |  150 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 243 insertions(+)
 create mode 100644 samples/bpf/tracex3_kern.c
 create mode 100644 samples/bpf/tracex3_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 6dd272143733..dcd850546d52 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -8,6 +8,7 @@ hostprogs-y += sockex1
 hostprogs-y += sockex2
 hostprogs-y += tracex1
 hostprogs-y += tracex2
+hostprogs-y += tracex3
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -16,6 +17,7 @@ sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
 tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
+tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -23,6 +25,7 @@ always += sockex1_kern.o
 always += sockex2_kern.o
 always += tracex1_kern.o
 always += tracex2_kern.o
+always += tracex3_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -31,6 +34,7 @@ HOSTLOADLIBES_sockex1 += -lelf
 HOSTLOADLIBES_sockex2 += -lelf
 HOSTLOADLIBES_tracex1 += -lelf
 HOSTLOADLIBES_tracex2 += -lelf
+HOSTLOADLIBES_tracex3 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/tracex3_kern.c b/samples/bpf/tracex3_kern.c
new file mode 100644
index 000000000000..64f1c0b01a30
--- /dev/null
+++ b/samples/bpf/tracex3_kern.c
@@ -0,0 +1,89 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
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
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(long),
+	.value_size = sizeof(u64),
+	.max_entries = 4096,
+};
+
+/* kprobe is NOT a stable ABI
+ * This bpf+kprobe example can stop working any time.
+ */
+SEC("events/kprobes/blk_mq_start_request")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	long rq = ctx->di;
+	u64 val = bpf_ktime_get_ns();
+
+	bpf_map_update_elem(&my_map, &rq, &val, BPF_ANY);
+	return 0;
+}
+
+static unsigned int log2l(unsigned long long n)
+{
+#define S(k) if (n >= (1ull << k)) { i += k; n >>= k; }
+	int i = -(n == 0);
+	S(32); S(16); S(8); S(4); S(2); S(1);
+	return i;
+#undef S
+}
+
+#define SLOTS 100
+
+struct bpf_map_def SEC("maps") lat_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(u64),
+	.max_entries = SLOTS,
+};
+
+SEC("events/kprobes/blk_update_request")
+int bpf_prog2(struct pt_regs *ctx)
+{
+	long rq = ctx->di;
+	u64 *value, l, base;
+	u32 index;
+
+	value = bpf_map_lookup_elem(&my_map, &rq);
+	if (!value)
+		return 0;
+
+	u64 cur_time = bpf_ktime_get_ns();
+	u64 delta = cur_time - *value;
+
+	bpf_map_delete_elem(&my_map, &rq);
+
+	/* the lines below are computing index = log10(delta)*10
+	 * using integer arithmetic
+	 * index = 29 ~ 1 usec
+	 * index = 59 ~ 1 msec
+	 * index = 89 ~ 1 sec
+	 * index = 99 ~ 10sec or more
+	 * log10(x)*10 = log2(x)*10/log2(10) = log2(x)*3
+	 */
+	l = log2l(delta);
+	base = 1ll << l;
+	index = (l * 64 + (delta - base) * 64 / base) * 3 / 64;
+
+	if (index >= SLOTS)
+		index = SLOTS - 1;
+
+	value = bpf_map_lookup_elem(&lat_map, &index);
+	if (value)
+		__sync_fetch_and_add((long *)value, 1);
+
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex3_user.c b/samples/bpf/tracex3_user.c
new file mode 100644
index 000000000000..0aaa933ab938
--- /dev/null
+++ b/samples/bpf/tracex3_user.c
@@ -0,0 +1,150 @@
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
+#include <stdbool.h>
+#include <string.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+
+#define SLOTS 100
+
+static void clear_stats(int fd)
+{
+	__u32 key;
+	__u64 value = 0;
+
+	for (key = 0; key < SLOTS; key++)
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
+const char *sym[] = {
+	" ",
+	" ",
+	".",
+	".",
+	"*",
+	"*",
+	"o",
+	"o",
+	"O",
+	"O",
+	"#",
+	"#",
+};
+
+bool full_range = false;
+bool text_only = false;
+
+static void print_banner(void)
+{
+	if (full_range)
+		printf("|1ns     |10ns     |100ns    |1us      |10us     |100us"
+		       "    |1ms      |10ms     |100ms    |1s       |10s\n");
+	else
+		printf("|1us      |10us     |100us    |1ms      |10ms     "
+		       "|100ms    |1s       |10s\n");
+}
+
+static void print_hist(int fd)
+{
+	__u32 key;
+	__u64 value;
+	__u64 cnt[SLOTS];
+	__u64 max_cnt = 0;
+	__u64 total_events = 0;
+
+	for (key = 0; key < SLOTS; key++) {
+		value = 0;
+		bpf_lookup_elem(fd, &key, &value);
+		cnt[key] = value;
+		total_events += value;
+		if (value > max_cnt)
+			max_cnt = value;
+	}
+	clear_stats(fd);
+	for (key = full_range ? 0 : 29; key < SLOTS; key++) {
+		int c = num_colors * cnt[key] / (max_cnt + 1);
+
+		if (text_only)
+			printf("%s", sym[c]);
+		else
+			printf("%s %s", color[c], nocolor);
+	}
+	printf(" # %lld\n", total_events);
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	int i;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	for (i = 1; i < ac; i++) {
+		if (strcmp(argv[i], "-a") == 0) {
+			full_range = true;
+		} else if (strcmp(argv[i], "-t") == 0) {
+			text_only = true;
+		} else if (strcmp(argv[i], "-h") == 0) {
+			printf("Usage:\n"
+			       "  -a display wider latency range\n"
+			       "  -t text only\n");
+			return 1;
+		}
+	}
+
+	printf("  heatmap of IO latency\n");
+	if (text_only)
+		printf("  %s", sym[num_colors - 1]);
+	else
+		printf("  %s %s", color[num_colors - 1], nocolor);
+	printf(" - many events with this latency\n");
+
+	if (text_only)
+		printf("  %s", sym[0]);
+	else
+		printf("  %s %s", color[0], nocolor);
+	printf(" - few events\n");
+
+	for (i = 0; ; i++) {
+		if (i % 20 == 0)
+			print_banner();
+		print_hist(map_fd[1]);
+		sleep(2);
+	}
+
+	return 0;
+}
-- 
1.7.9.5
