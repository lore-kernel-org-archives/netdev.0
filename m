From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 25/26] samples: bpf: counting eBPF example in C
Date: Wed, 13 Aug 2014 00:57:36 -0700
Message-ID: <1407916658-8731-26-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this example has two probes in C that use two different maps.

1st probe is the similar to dropmon.c. It attaches to kfree_skb tracepoint and
count number of packet drops at different locations

2nd probe attaches to kprobe/sys_write and computes a histogram of different
write sizes

Usage:
$ sudo ex2

Should see:
writing bpf-5 -> /sys/kernel/debug/tracing/events/skb/kfree_skb/filter
writing bpf-8 -> /sys/kernel/debug/tracing/events/kprobes/sys_write/filter
location 0xffffffff816efc67 count 1

location 0xffffffff815d8030 count 1
location 0xffffffff816efc67 count 3

location 0xffffffff815d8030 count 4
location 0xffffffff816efc67 count 9

           syscall write() stats
     byte_size       : count     distribution
       1 -> 1        : 3141     |****                                  |
       2 -> 3        : 2        |                                      |
       4 -> 7        : 14       |                                      |
       8 -> 15       : 3268     |*****                                 |
      16 -> 31       : 732      |                                      |
      32 -> 63       : 20042    |************************************* |
      64 -> 127      : 12154    |**********************                |
     128 -> 255      : 2215     |***                                   |
     256 -> 511      : 9        |                                      |
     512 -> 1023     : 0        |                                      |
    1024 -> 2047     : 1        |                                      |

Ctrl-C at any time. Kernel will auto cleanup maps and programs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile   |    6 ++--
 samples/bpf/ex2_kern.c |   73 +++++++++++++++++++++++++++++++++++++
 samples/bpf/ex2_user.c |   94 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 171 insertions(+), 2 deletions(-)
 create mode 100644 samples/bpf/ex2_kern.c
 create mode 100644 samples/bpf/ex2_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index c97f408fcd6d..b865a5df5c60 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,19 +2,21 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := sock_example dropmon ex1
+hostprogs-y := sock_example dropmon ex1 ex2
 
 sock_example-objs := sock_example.o libbpf.o
 dropmon-objs := dropmon.o libbpf.o
 ex1-objs := bpf_load.o libbpf.o ex1_user.o
+ex2-objs := bpf_load.o libbpf.o ex2_user.o
 
 # Tell kbuild to always build the programs
-always := $(hostprogs-y) ex1_kern.o
+always := $(hostprogs-y) ex1_kern.o ex2_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_ex1 += -lelf
+HOSTLOADLIBES_ex2 += -lelf
 
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
 
diff --git a/samples/bpf/ex2_kern.c b/samples/bpf/ex2_kern.c
new file mode 100644
index 000000000000..2daa50b27ce5
--- /dev/null
+++ b/samples/bpf/ex2_kern.c
@@ -0,0 +1,73 @@
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
+	void *value;
+
+	value = bpf_map_lookup_elem(&my_map, &loc);
+	if (value)
+		(*(long *) value) += 1;
+	else
+		bpf_map_update_elem(&my_map, &loc, &init_val);
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
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 64,
+};
+
+SEC("events/kprobes/sys_write")
+int bpf_prog3(struct bpf_context *ctx)
+{
+	long write_size = ctx->arg3;
+	long init_val = 1;
+	void *value;
+	u32 index = log2l(write_size);
+
+	value = bpf_map_lookup_elem(&my_hist_map, &index);
+	if (value)
+		__sync_fetch_and_add((long *)value, 1);
+	else
+		bpf_map_update_elem(&my_hist_map, &index, &init_val);
+	return 0;
+}
+char license[] SEC("license") = "GPL";
diff --git a/samples/bpf/ex2_user.c b/samples/bpf/ex2_user.c
new file mode 100644
index 000000000000..fd5ce21ae60a
--- /dev/null
+++ b/samples/bpf/ex2_user.c
@@ -0,0 +1,94 @@
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
+	int key, next_key;
+	long value;
+	long data[MAX_INDEX] = {};
+	char starstr[MAX_STARS];
+	int i;
+	int max_ind = -1;
+	long max_value = 0;
+
+	key = -1; /* some unknown key */
+	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_lookup_elem(fd, &next_key, &value);
+		if (next_key > MAX_INDEX) {
+			printf("BUG: invalid index %d\n", next_key);
+		} else {
+			data[next_key] = value;
+			if (next_key > max_ind)
+				max_ind = next_key;
+			if (value > max_value)
+				max_value = value;
+		}
+		key = next_key;
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
+	int i;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	signal(SIGINT, int_exit);
+
+	i = system("echo 'p:sys_write sys_write' > /sys/kernel/debug/tracing/kprobe_events");
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
