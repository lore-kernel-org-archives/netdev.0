From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: [PATCH v2] bpf: BPF based latency tracing
Date: Fri, 19 Jun 2015 16:00:44 +0200
Message-ID: <1434722444-10200-1-git-send-email-daniel.wagner@bmw-carit.de>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmw-carit.de ([62.245.222.98]:49498 "EHLO
	linuxmail.bmw-carit.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752136AbbFSOAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 10:00:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF offers another way to generate latency histograms. We attach
kprobes at trace_preempt_off and trace_preempt_on and calculate the
time it takes to from seeing the off/on transition.

The first array is used to store the start time stamp. The key is the
CPU id. The second array stores the log2(time diff). We need to use
static allocation here (array and not hash tables). The kprobes
hooking into trace_preempt_on|off should not calling any dynamic
memory allocation or free path. We need to avoid recursivly
getting called. Besides that, it reduces jitter in the measurement.

CPU 0
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 166723   |*************************************** |
    4096 -> 8191     : 19870    |***                                     |
    8192 -> 16383    : 6324     |                                        |
   16384 -> 32767    : 1098     |                                        |
   32768 -> 65535    : 190      |                                        |
   65536 -> 131071   : 179      |                                        |
  131072 -> 262143   : 18       |                                        |
  262144 -> 524287   : 4        |                                        |
  524288 -> 1048575  : 1363     |                                        |
CPU 1
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 114042   |*************************************** |
    4096 -> 8191     : 9587     |**                                      |
    8192 -> 16383    : 4140     |                                        |
   16384 -> 32767    : 673      |                                        |
   32768 -> 65535    : 179      |                                        |
   65536 -> 131071   : 29       |                                        |
  131072 -> 262143   : 4        |                                        |
  262144 -> 524287   : 1        |                                        |
  524288 -> 1048575  : 364      |                                        |
CPU 2
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 40147    |*************************************** |
    4096 -> 8191     : 2300     |*                                       |
    8192 -> 16383    : 828      |                                        |
   16384 -> 32767    : 178      |                                        |
   32768 -> 65535    : 59       |                                        |
   65536 -> 131071   : 2        |                                        |
  131072 -> 262143   : 0        |                                        |
  262144 -> 524287   : 1        |                                        |
  524288 -> 1048575  : 174      |                                        |
CPU 3
      latency        : count     distribution
       1 -> 1        : 0        |                                        |
       2 -> 3        : 0        |                                        |
       4 -> 7        : 0        |                                        |
       8 -> 15       : 0        |                                        |
      16 -> 31       : 0        |                                        |
      32 -> 63       : 0        |                                        |
      64 -> 127      : 0        |                                        |
     128 -> 255      : 0        |                                        |
     256 -> 511      : 0        |                                        |
     512 -> 1023     : 0        |                                        |
    1024 -> 2047     : 0        |                                        |
    2048 -> 4095     : 29626    |*************************************** |
    4096 -> 8191     : 2704     |**                                      |
    8192 -> 16383    : 1090     |                                        |
   16384 -> 32767    : 160      |                                        |
   32768 -> 65535    : 72       |                                        |
   65536 -> 131071   : 32       |                                        |
  131072 -> 262143   : 26       |                                        |
  262144 -> 524287   : 12       |                                        |
  524288 -> 1048575  : 298      |                                        |

All this is based on the trace3 examples written by
Alexei Starovoitov <ast@plumgrid.com>.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
Hi Alexei,

Something broke in my toolchain and it took me a while to figure out whats
going on.

With the rebase on net-next no additinal patches are needed and this
thing here runs fine.

This time with code...

cheers,
daniel

changes

v2:	- forgot to do a git add... 
v1:	- rebases on net-next

v0:
	- renamed to lathist since there is no direct hw latency involved
	-  use arrays instead of hash tables

samples/bpf/Makefile       |   4 ++
 samples/bpf/lathist_kern.c |  99 +++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/lathist_user.c | 103 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 206 insertions(+)
 create mode 100644 samples/bpf/lathist_kern.c
 create mode 100644 samples/bpf/lathist_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 46c6a8c..4450fed 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -12,6 +12,7 @@ hostprogs-y += tracex2
 hostprogs-y += tracex3
 hostprogs-y += tracex4
 hostprogs-y += tracex5
+hostprogs-y += lathist
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -24,6 +25,7 @@ tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
 tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
 tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
 tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
+lathist-objs := bpf_load.o libbpf.o lathist_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -36,6 +38,7 @@ always += tracex3_kern.o
 always += tracex4_kern.o
 always += tracex5_kern.o
 always += tcbpf1_kern.o
+always += lathist_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -48,6 +51,7 @@ HOSTLOADLIBES_tracex2 += -lelf
 HOSTLOADLIBES_tracex3 += -lelf
 HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
+HOSTLOADLIBES_lathist += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/lathist_kern.c b/samples/bpf/lathist_kern.c
new file mode 100644
index 0000000..18fa088
--- /dev/null
+++ b/samples/bpf/lathist_kern.c
@@ -0,0 +1,99 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2015 BMW Car IT GmbH
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
+#define MAX_ENTRIES	20
+#define MAX_CPU		4
+
+/* We need to stick to static allocated memory (an array instead of
+ * hash table) because managing dynamic memory from the
+ * trace_preempt_[on|off] tracepoints hooks is not supported.
+ */
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(u64),
+	.max_entries = MAX_CPU,
+};
+
+SEC("kprobe/trace_preempt_off")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	int cpu = bpf_get_smp_processor_id();
+	u64 *ts = bpf_map_lookup_elem(&my_map, &cpu);
+
+	if (ts)
+		*ts = bpf_ktime_get_ns();
+
+	return 0;
+}
+
+static unsigned int log2(unsigned int v)
+{
+	unsigned int r;
+	unsigned int shift;
+
+	r = (v > 0xFFFF) << 4; v >>= r;
+	shift = (v > 0xFF) << 3; v >>= shift; r |= shift;
+	shift = (v > 0xF) << 2; v >>= shift; r |= shift;
+	shift = (v > 0x3) << 1; v >>= shift; r |= shift;
+	r |= (v >> 1);
+
+	return r;
+}
+
+static unsigned int log2l(unsigned long v)
+{
+	unsigned int hi = v >> 32;
+
+	if (hi)
+		return log2(hi) + 32;
+	else
+		return log2(v);
+}
+
+struct bpf_map_def SEC("maps") my_lat = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(long),
+	.max_entries = MAX_CPU * MAX_ENTRIES,
+};
+
+SEC("kprobe/trace_preempt_on")
+int bpf_prog2(struct pt_regs *ctx)
+{
+	u64 *ts, cur_ts, delta;
+	int key, cpu;
+	long *val;
+
+	cpu = bpf_get_smp_processor_id();
+	ts = bpf_map_lookup_elem(&my_map, &cpu);
+	if (!ts)
+		return 0;
+
+	cur_ts = bpf_ktime_get_ns();
+	delta = log2l(cur_ts - *ts);
+
+	if (delta > MAX_ENTRIES - 1)
+		delta = MAX_ENTRIES - 1;
+
+	key = cpu * MAX_ENTRIES + delta;
+	val = bpf_map_lookup_elem(&my_lat, &key);
+	if (val)
+		__sync_fetch_and_add((long *)val, 1);
+
+	return 0;
+
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/lathist_user.c b/samples/bpf/lathist_user.c
new file mode 100644
index 0000000..65da8c1
--- /dev/null
+++ b/samples/bpf/lathist_user.c
@@ -0,0 +1,103 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2015 BMW Car IT GmbH
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
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define MAX_ENTRIES	20
+#define MAX_CPU		4
+#define MAX_STARS	40
+
+struct cpu_hist {
+	long data[MAX_ENTRIES];
+	long max;
+};
+
+static struct cpu_hist cpu_hist[MAX_CPU];
+
+static void stars(char *str, long val, long max, int width)
+{
+	int i;
+
+	for (i = 0; i < (width * val / max) - 1 && i < width - 1; i++)
+		str[i] = '*';
+	if (val > max)
+		str[i - 1] = '+';
+	str[i] = '\0';
+}
+
+static void print_hist(void)
+{
+	char starstr[MAX_STARS];
+	struct cpu_hist *hist;
+	int i, j;
+
+	/* clear screen */
+	printf("\033[2J");
+
+	for (j = 0; j < MAX_CPU; j++) {
+		hist = &cpu_hist[j];
+
+		/* ignore CPUs without data (maybe offline?) */
+		if (hist->max == 0)
+			continue;
+
+		printf("CPU %d\n", j);
+		printf("      latency        : count     distribution\n");
+		for (i = 1; i <= MAX_ENTRIES; i++) {
+			stars(starstr, hist->data[i - 1], hist->max, MAX_STARS);
+			printf("%8ld -> %-8ld : %-8ld |%-*s|\n",
+				(1l << i) >> 1, (1l << i) - 1,
+				hist->data[i - 1], MAX_STARS, starstr);
+		}
+	}
+}
+
+static void get_data(int fd)
+{
+	long key, value;
+	int c, i;
+
+	for (i = 0; i < MAX_CPU; i++)
+		cpu_hist[i].max = 0;
+
+	for (c = 0; c < MAX_CPU; c++) {
+		for (i = 0; i < MAX_ENTRIES; i++) {
+			key = c * MAX_ENTRIES + i;
+			bpf_lookup_elem(fd, &key, &value);
+
+			cpu_hist[c].data[i] = value;
+			if (value > cpu_hist[c].max)
+				cpu_hist[c].max = value;
+		}
+	}
+}
+
+int main(int argc, char **argv)
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
+	while (1) {
+		get_data(map_fd[1]);
+		print_hist();
+		sleep(5);
+	}
+
+	return 0;
+}
-- 
2.1.0
