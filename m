From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 linux-trace 4/8] samples: bpf: simple tracing example in C
Date: Tue, 27 Jan 2015 20:06:09 -0800
Message-ID: <1422417973-10195-5-git-send-email-ast@plumgrid.com>
References: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tracex1_kern.c - C program which will be compiled into eBPF
to filter netif_receive_skb events on skb->dev->name == "lo"
The programs returns 1 to continue storing an event into trace buffer
and returns 0 - to discard an event.

tracex1_user.c - corresponding user space component that
forever reads /sys/.../trace_pipe

Usage:
$ sudo tracex1

should see:
writing bpf-4 -> /sys/kernel/debug/tracing/events/net/netif_receive_skb/filter
  ping-364   [000] ..s2     8.089771: netif_receive_skb: dev=lo skbaddr=ffff88000dfcc100 len=84
  ping-364   [000] ..s2     8.089889: netif_receive_skb: dev=lo skbaddr=ffff88000dfcc900 len=84

Ctrl-C at any time, kernel will auto cleanup

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 +++
 samples/bpf/bpf_helpers.h  |   14 +++++++++++
 samples/bpf/bpf_load.c     |   59 +++++++++++++++++++++++++++++++++++++++-----
 samples/bpf/bpf_load.h     |    3 +++
 samples/bpf/tracex1_kern.c |   28 +++++++++++++++++++++
 samples/bpf/tracex1_user.c |   24 ++++++++++++++++++
 6 files changed, 126 insertions(+), 6 deletions(-)
 create mode 100644 samples/bpf/tracex1_kern.c
 create mode 100644 samples/bpf/tracex1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 789691374562..da28e1b6d3a6 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -7,6 +7,7 @@ hostprogs-y += sock_example
 hostprogs-y += sockex1
 hostprogs-y += sockex2
 hostprogs-y += dropmon
+hostprogs-y += tracex1
 
 dropmon-objs := dropmon.o libbpf.o
 test_verifier-objs := test_verifier.o libbpf.o
@@ -14,17 +15,20 @@ test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
 sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
+tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 always += sockex1_kern.o
 always += sockex2_kern.o
+always += tracex1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_sockex1 += -lelf
 HOSTLOADLIBES_sockex2 += -lelf
+HOSTLOADLIBES_tracex1 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index ca0333146006..9c385c2eacf8 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -15,6 +15,20 @@ static int (*bpf_map_update_elem)(void *map, void *key, void *value,
 	(void *) BPF_FUNC_map_update_elem;
 static int (*bpf_map_delete_elem)(void *map, void *key) =
 	(void *) BPF_FUNC_map_delete_elem;
+static void *(*bpf_fetch_ptr)(void *unsafe_ptr) =
+	(void *) BPF_FUNC_fetch_ptr;
+static unsigned long long (*bpf_fetch_u64)(void *unsafe_ptr) =
+	(void *) BPF_FUNC_fetch_u64;
+static unsigned int (*bpf_fetch_u32)(void *unsafe_ptr) =
+	(void *) BPF_FUNC_fetch_u32;
+static unsigned short (*bpf_fetch_u16)(void *unsafe_ptr) =
+	(void *) BPF_FUNC_fetch_u16;
+static unsigned char (*bpf_fetch_u8)(void *unsafe_ptr) =
+	(void *) BPF_FUNC_fetch_u8;
+static int (*bpf_memcmp)(void *unsafe_ptr, void *safe_ptr, int size) =
+	(void *) BPF_FUNC_memcmp;
+static unsigned long long (*bpf_ktime_get_ns)(void) =
+	(void *) BPF_FUNC_ktime_get_ns;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 1831d236382b..788ac51c1024 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -14,6 +14,8 @@
 #include "bpf_helpers.h"
 #include "bpf_load.h"
 
+#define DEBUGFS "/sys/kernel/debug/tracing/"
+
 static char license[128];
 static bool processed_sec[128];
 int map_fd[MAX_MAPS];
@@ -22,15 +24,18 @@ int prog_cnt;
 
 static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 {
-	int fd;
 	bool is_socket = strncmp(event, "socket", 6) == 0;
+	enum bpf_prog_type prog_type;
+	char path[256] = DEBUGFS;
+	char fmt[32];
+	int fd, event_fd, err;
 
-	if (!is_socket)
-		/* tracing events tbd */
-		return -1;
+	if (is_socket)
+		prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
+	else
+		prog_type = BPF_PROG_TYPE_TRACING_FILTER;
 
-	fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER,
-			   prog, size, license);
+	fd = bpf_prog_load(prog_type, prog, size, license);
 
 	if (fd < 0) {
 		printf("bpf_prog_load() err=%d\n%s", errno, bpf_log_buf);
@@ -39,6 +44,28 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
+	if (is_socket)
+		return 0;
+
+	snprintf(fmt, sizeof(fmt), "bpf-%d", fd);
+
+	strcat(path, event);
+	strcat(path, "/filter");
+
+	printf("writing %s -> %s\n", fmt, path);
+
+	event_fd = open(path, O_WRONLY, 0);
+	if (event_fd < 0) {
+		printf("failed to open event %s\n", event);
+		return -1;
+	}
+
+	err = write(event_fd, fmt, strlen(fmt));
+	if (err < 0) {
+		printf("write to '%s' failed '%s'\n", event, strerror(errno));
+		return -1;
+	}
+
 	return 0;
 }
 
@@ -201,3 +228,23 @@ int load_bpf_file(char *path)
 	close(fd);
 	return 0;
 }
+
+void read_trace_pipe(void)
+{
+	int trace_fd;
+
+	trace_fd = open(DEBUGFS "trace_pipe", O_RDONLY, 0);
+	if (trace_fd < 0)
+		return;
+
+	while (1) {
+		static char buf[4096];
+		ssize_t sz;
+
+		sz = read(trace_fd, buf, sizeof(buf));
+		if (sz) {
+			buf[sz] = 0;
+			puts(buf);
+		}
+	}
+}
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index 27789a34f5e6..d154fc2b0535 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -21,4 +21,7 @@ extern int prog_fd[MAX_PROGS];
  */
 int load_bpf_file(char *path);
 
+/* forever reads /sys/.../trace_pipe */
+void read_trace_pipe(void);
+
 #endif
diff --git a/samples/bpf/tracex1_kern.c b/samples/bpf/tracex1_kern.c
new file mode 100644
index 000000000000..7849ceb4bce6
--- /dev/null
+++ b/samples/bpf/tracex1_kern.c
@@ -0,0 +1,28 @@
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include "bpf_helpers.h"
+
+SEC("events/net/netif_receive_skb")
+int bpf_prog1(struct bpf_context *ctx)
+{
+	/*
+	 * attaches to /sys/kernel/debug/tracing/events/net/netif_receive_skb
+	 * prints events for loobpack device only
+	 */
+	char devname[] = "lo";
+	struct net_device *dev;
+	struct sk_buff *skb = 0;
+
+	skb = (struct sk_buff *) ctx->arg1;
+	dev = bpf_fetch_ptr(&skb->dev);
+	if (bpf_memcmp(dev->name, devname, 2) == 0)
+		/* print event using default tracepoint format */
+		return 1;
+
+	/* drop event */
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/tracex1_user.c b/samples/bpf/tracex1_user.c
new file mode 100644
index 000000000000..e85c1b483f57
--- /dev/null
+++ b/samples/bpf/tracex1_user.c
@@ -0,0 +1,24 @@
+#include <stdio.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+int main(int ac, char **argv)
+{
+	FILE *f;
+	char filename[256];
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	f = popen("ping -c5 localhost", "r");
+	(void) f;
+
+	read_trace_pipe();
+
+	return 0;
+}
-- 
1.7.9.5
