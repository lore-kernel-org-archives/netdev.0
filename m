From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 tip 6/7] samples: bpf: counting example for kfree_skb and write syscall
Date: Sun,  1 Mar 2015 15:27:44 -0800
Message-ID: <1425252465-27527-7-git-send-email-ast@plumgrid.com>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40531 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbbCAX2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 18:28:15 -0500
Received: by pdev10 with SMTP id v10so34869966pde.7
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 15:28:15 -0800 (PST)
In-Reply-To: <1425252465-27527-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this example has two probes in one C file that attach to different kprove events
and use two different maps.

1st probe is x64 specific equivalent of dropmon. It attaches to kfree_skb,
retrevies 'ip' address of kfree_skb() caller and counts number of packet drops
at that 'ip' address. User space prints 'location - count' map every second.

2nd probe attaches to kprobe:sys_write and computes a histogram of different
write sizes

Usage:
$ sudo tracex2
location 0xffffffff81695995 count 1
location 0xffffffff816d0da9 count 2

location 0xffffffff81695995 count 2
location 0xffffffff816d0da9 count 2

location 0xffffffff81695995 count 3
location 0xffffffff816d0da9 count 2

557145+0 records in
557145+0 records out
285258240 bytes (285 MB) copied, 1.02379 s, 279 MB/s
           syscall write() stats
     byte_size       : count     distribution
       1 -> 1        : 3        |                                      |
       2 -> 3        : 0        |                                      |
       4 -> 7        : 0        |                                      |
       8 -> 15       : 0        |                                      |
      16 -> 31       : 2        |                                      |
      32 -> 63       : 3        |                                      |
      64 -> 127      : 1        |                                      |
     128 -> 255      : 1        |                                      |
     256 -> 511      : 0        |                                      |
     512 -> 1023     : 1118968  |************************************* |

Ctrl-C at any time. Kernel will auto cleanup maps and programs

$ addr2line -ape ./bld_x64/vmlinux 0xffffffff81695995 0xffffffff816d0da9
0xffffffff81695995: ./bld_x64/../net/ipv4/icmp.c:1038
0xffffffff816d0da9: ./bld_x64/../net/unix/af_unix.c:1231

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 ++
 samples/bpf/tracex2_kern.c |   86 +++++++++++++++++++++++++++++++++++++++
 samples/bpf/tracex2_user.c |   95 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 185 insertions(+)
 create mode 100644 samples/bpf/tracex2_kern.c
 create mode 100644 samples/bpf/tracex2_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 51f6f01e5a3a..6dd272143733 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -7,6 +7,7 @@ hostprogs-y += sock_example
 hostprogs-y += sockex1
 hostprogs-y += sockex2
 hostprogs-y += tracex1
+hostprogs-y += tracex2
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -14,12 +15,14 @@ sock_example-objs := sock_example.o libbpf.o
 sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
+tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 always += sockex1_kern.o
 always += sockex2_kern.o
 always += tracex1_kern.o
+always += tracex2_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -27,6 +30,7 @@ HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_sockex1 += -lelf
 HOSTLOADLIBES_sockex2 += -lelf
 HOSTLOADLIBES_tracex1 += -lelf
+HOSTLOADLIBES_tracex2 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/tracex2_kern.c b/samples/bpf/tracex2_kern.c
new file mode 100644
index 000000000000..a1ac1f99b665
--- /dev/null
+++ b/samples/bpf/tracex2_kern.c
@@ -0,0 +1,86 @@
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
+	.value_size = sizeof(long),
+	.max_entries = 1024,
+};
+
+/* kprobe is NOT a stable ABI
+ * This bpf+kprobe example can stop working any time.
+ */
+SEC("events/kprobes/kfree_skb")
+int bpf_prog2(struct pt_regs *ctx)
+{
+	long loc = 0;
+	long init_val = 1;
+	long *value;
+
+	/* x64 specific: read ip of kfree_skb caller.
+	 * non-portable version of __builtin_return_address(0)
+	 */
+	bpf_probe_read(&loc, sizeof(loc), (void *)ctx->sp);
+
+	value = bpf_map_lookup_elem(&my_map, &loc);
+	if (value)
+		*value += 1;
+	else
+		bpf_map_update_elem(&my_map, &loc, &init_val, BPF_ANY);
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
+	return r;
+}
+
+static unsigned int log2l(unsigned long v)
+{
+	unsigned int hi = v >> 32;
+	if (hi)
+		return log2(hi) + 32;
+	else
+		return log2(v);
+}
+
+struct bpf_map_def SEC("maps") my_hist_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 64,
+};
+
+SEC("events/kprobes/sys_write")
+int bpf_prog3(struct pt_regs *ctx)
+{
+	long write_size = ctx->dx; /* arg3 */
+	long init_val = 1;
+	long *value;
+	u32 index = log2l(write_size);
+
+	value = bpf_map_lookup_elem(&my_hist_map, &index);
+	if (value)
+		__sync_fetch_and_add(value, 1);
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
new file mode 100644
index 000000000000..91b8d0896fbb
--- /dev/null
+++ b/samples/bpf/tracex2_user.c
@@ -0,0 +1,95 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define MAX_INDEX	64
+#define MAX_STARS	38
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
+static void print_hist(int fd)
+{
+	int key;
+	long value;
+	long data[MAX_INDEX] = {};
+	char starstr[MAX_STARS];
+	int i;
+	int max_ind = -1;
+	long max_value = 0;
+
+	for (key = 0; key < MAX_INDEX; key++) {
+		bpf_lookup_elem(fd, &key, &value);
+		data[key] = value;
+		if (value && key > max_ind)
+			max_ind = key;
+		if (value > max_value)
+			max_value = value;
+	}
+
+	printf("           syscall write() stats\n");
+	printf("     byte_size       : count     distribution\n");
+	for (i = 1; i <= max_ind + 1; i++) {
+		stars(starstr, data[i - 1], max_value, MAX_STARS);
+		printf("%8ld -> %-8ld : %-8ld |%-*s|\n",
+		       (1l << i) >> 1, (1l << i) - 1, data[i - 1],
+		       MAX_STARS, starstr);
+	}
+}
+static void int_exit(int sig)
+{
+	print_hist(map_fd[1]);
+	exit(0);
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	long key, next_key, value;
+	FILE *f;
+	int i;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	signal(SIGINT, int_exit);
+
+	/* start 'ping' in the background to have some kfree_skb events */
+	f = popen("ping -c5 localhost", "r");
+	(void) f;
+
+	/* start 'dd' in the background to have plenty of 'write' syscalls */
+	f = popen("dd if=/dev/zero of=/dev/null count=5000000", "r");
+	(void) f;
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	for (i = 0; i < 5; i++) {
+		key = 0;
+		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_lookup_elem(map_fd[0], &next_key, &value);
+			printf("location 0x%lx count %ld\n", next_key, value);
+			key = next_key;
+		}
+		if (key)
+			printf("\n");
+		sleep(1);
+	}
+	print_hist(map_fd[1]);
+
+	return 0;
+}
-- 
1.7.9.5
