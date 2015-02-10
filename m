From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v3 linux-trace 5/8] samples: bpf: counting example for kfree_skb tracepoint and write syscall
Date: Mon,  9 Feb 2015 19:45:58 -0800
Message-ID: <1423539961-21792-6-git-send-email-ast@plumgrid.com>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423539961-21792-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

this example has two probes in one C file that attach to different tracepoints
and use two different maps.

1st probe is the similar to dropmon.c. It attaches to kfree_skb tracepoint and
count number of packet drops at different locations

2nd probe attaches to syscalls/sys_enter_write and computes a histogram of different
write sizes

Usage:
$ sudo tracex2
location 0xffffffff816959a5 count 1

location 0xffffffff816959a5 count 2

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

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 samples/bpf/Makefile       |    4 ++
 samples/bpf/tracex2_kern.c |   71 +++++++++++++++++++++++++++++++++
 samples/bpf/tracex2_user.c |   95 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 170 insertions(+)
 create mode 100644 samples/bpf/tracex2_kern.c
 create mode 100644 samples/bpf/tracex2_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index da28e1b6d3a6..416af24b01fd 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -8,6 +8,7 @@ hostprogs-y += sockex1
 hostprogs-y += sockex2
 hostprogs-y += dropmon
 hostprogs-y += tracex1
+hostprogs-y += tracex2
 
 dropmon-objs := dropmon.o libbpf.o
 test_verifier-objs := test_verifier.o libbpf.o
@@ -16,12 +17,14 @@ sock_example-objs := sock_example.o libbpf.o
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
 
@@ -29,6 +32,7 @@ HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_sockex1 += -lelf
 HOSTLOADLIBES_sockex2 += -lelf
 HOSTLOADLIBES_tracex1 += -lelf
+HOSTLOADLIBES_tracex2 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/tracex2_kern.c b/samples/bpf/tracex2_kern.c
new file mode 100644
index 000000000000..a789c456c1b4
--- /dev/null
+++ b/samples/bpf/tracex2_kern.c
@@ -0,0 +1,71 @@
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(long),
+	.value_size = sizeof(long),
+	.max_entries = 1024,
+};
+
+SEC("events/skb/kfree_skb")
+int bpf_prog2(struct bpf_context *ctx)
+{
+	long loc = ctx->arg2;
+	long init_val = 1;
+	long *value;
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
+SEC("events/syscalls/sys_enter_write")
+int bpf_prog3(struct bpf_context *ctx)
+{
+	long write_size = ctx->arg3;
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
