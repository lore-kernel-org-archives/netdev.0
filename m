From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 linux-trace 8/8] samples: bpf: simple kprobe example
Date: Mon,  9 Feb 2015 19:46:01 -0800
Message-ID: <1423539961-21792-9-git-send-email-ast@plumgrid.com>
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

the logic of the example is similar to tracex2, but syscall 'write' statistics
is capturead from kprobe placed at sys_write function instead of through
syscall instrumentation.
Also tracex4_kern.c has a different way of doing log2 in C.
Note, unlike tracepoint and syscall programs, kprobe programs receive
'struct pt_regs' as an input. It's responsibility of the program author
or higher level dynamic tracing tool to match registers to function arguments.
Since pt_regs are architecture dependent, programs are also arch dependent,
unlike tracepoint/syscalls programs which are universal.

Usage:
$ sudo tracex4
2216443+0 records in
2216442+0 records out
1134818304 bytes (1.1 GB) copied, 2.00746 s, 565 MB/s

           kprobe sys_write() stats
     byte_size       : count     distribution
       1 -> 1        : 0        |                                      |
       2 -> 3        : 0        |                                      |
       4 -> 7        : 0        |                                      |
       8 -> 15       : 0        |                                      |
      16 -> 31       : 0        |                                      |
      32 -> 63       : 0        |                                      |
      64 -> 127      : 1        |                                      |
     128 -> 255      : 0        |                                      |
     256 -> 511      : 0        |                                      |
     512 -> 1023     : 2214734  |************************************* |

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 +++
 samples/bpf/bpf_load.c     |    3 ++
 samples/bpf/tracex4_kern.c |   36 +++++++++++++++++++
 samples/bpf/tracex4_user.c |   83 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 126 insertions(+)
 create mode 100644 samples/bpf/tracex4_kern.c
 create mode 100644 samples/bpf/tracex4_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index da0efd8032ab..22c7a38f3f95 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -10,6 +10,7 @@ hostprogs-y += dropmon
 hostprogs-y += tracex1
 hostprogs-y += tracex2
 hostprogs-y += tracex3
+hostprogs-y += tracex4
 
 dropmon-objs := dropmon.o libbpf.o
 test_verifier-objs := test_verifier.o libbpf.o
@@ -20,6 +21,7 @@ sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
 tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
 tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
+tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -28,6 +30,7 @@ always += sockex2_kern.o
 always += tracex1_kern.o
 always += tracex2_kern.o
 always += tracex3_kern.o
+always += tracex4_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -37,6 +40,7 @@ HOSTLOADLIBES_sockex2 += -lelf
 HOSTLOADLIBES_tracex1 += -lelf
 HOSTLOADLIBES_tracex2 += -lelf
 HOSTLOADLIBES_tracex3 += -lelf
+HOSTLOADLIBES_tracex4 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 2aece65963e4..2206b49df625 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -32,6 +32,7 @@ int prog_cnt;
 static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 {
 	bool is_socket = strncmp(event, "socket", 6) == 0;
+	bool is_kprobe = strncmp(event, "events/kprobes/", 15) == 0;
 	enum bpf_prog_type prog_type;
 	char path[256] = DEBUGFS;
 	char buf[32];
@@ -45,6 +46,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	if (is_socket)
 		prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
+	else if (is_kprobe)
+		prog_type = BPF_PROG_TYPE_KPROBE;
 	else
 		prog_type = BPF_PROG_TYPE_TRACEPOINT;
 
diff --git a/samples/bpf/tracex4_kern.c b/samples/bpf/tracex4_kern.c
new file mode 100644
index 000000000000..9646f9e43417
--- /dev/null
+++ b/samples/bpf/tracex4_kern.c
@@ -0,0 +1,36 @@
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include "bpf_helpers.h"
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
+struct bpf_map_def SEC("maps") my_hist_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 64,
+};
+
+SEC("events/kprobes/sys_write")
+int bpf_prog4(struct pt_regs *regs)
+{
+	long write_size = regs->dx; /* $rdx contains 3rd argument to a function */
+	long init_val = 1;
+	void *value;
+	u32 index = log2l(write_size);
+
+	value = bpf_map_lookup_elem(&my_hist_map, &index);
+	if (value)
+		__sync_fetch_and_add((long *)value, 1);
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/tracex4_user.c b/samples/bpf/tracex4_user.c
new file mode 100644
index 000000000000..741206127768
--- /dev/null
+++ b/samples/bpf/tracex4_user.c
@@ -0,0 +1,83 @@
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
+	printf("\n           kprobe sys_write() stats\n");
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
+	print_hist(map_fd[0]);
+	exit(0);
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	FILE *f;
+	int i;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	signal(SIGINT, int_exit);
+
+	i = system("echo 'p:sys_write sys_write' > /sys/kernel/debug/tracing/kprobe_events");
+	(void) i;
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
+	sleep(2);
+	kill(0, SIGINT); /* send Ctrl-C to self and to 'dd' */
+
+	return 0;
+}
-- 
1.7.9.5
