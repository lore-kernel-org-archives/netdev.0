From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 tip 5/7] samples: bpf: simple non-portable kprobe filter example
Date: Fri, 27 Feb 2015 16:08:53 -0800
Message-ID: <1425082135-11967-6-git-send-email-ast@plumgrid.com>
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

tracex1_kern.c - C program compiled into BPF.
It attaches to kprobe:netif_receive_skb
When skb->dev->name == "lo", it prints sample debug message into trace_pipe
via bpf_trace_printk() helper function.

tracex1_user.c - corresponding user space component that:
- loads bpf program via bpf() syscall
- opens kprobes:netif_receive_skb event via perf_event_open() syscall
- attaches the program to event via ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);
- prints from trace_pipe

Note, this bpf program is completely non-portable. It must be recompiled
with current kernel headers. kprobe is not a stable ABI and bpf+kprobe scripts
may stop working any time.

bpf verifier will detect that it's using bpf_trace_printk() and kernel will
print warning banner:
** trace_printk() being used. Allocating extra memory.  **
**                                                      **
** This means that this is a DEBUG kernel and it is     **
** unsafe for production use.                           **

bpf_trace_printk() should be used for debugging of bpf program only.

Usage:
$ sudo tracex1
            ping-19826 [000] d.s2 63103.382648: : skb ffff880466b1ca00 len 84
            ping-19826 [000] d.s2 63103.382684: : skb ffff880466b1d300 len 84

            ping-19826 [000] d.s2 63104.382533: : skb ffff880466b1ca00 len 84
            ping-19826 [000] d.s2 63104.382594: : skb ffff880466b1d300 len 84

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile        |    4 ++
 samples/bpf/bpf_helpers.h   |    6 +++
 samples/bpf/bpf_load.c      |  112 ++++++++++++++++++++++++++++++++++++++++---
 samples/bpf/bpf_load.h      |    3 ++
 samples/bpf/libbpf.c        |   10 +++-
 samples/bpf/libbpf.h        |    5 +-
 samples/bpf/sock_example.c  |    2 +-
 samples/bpf/test_verifier.c |    2 +-
 samples/bpf/tracex1_kern.c  |   50 +++++++++++++++++++
 samples/bpf/tracex1_user.c  |   25 ++++++++++
 10 files changed, 209 insertions(+), 10 deletions(-)
 create mode 100644 samples/bpf/tracex1_kern.c
 create mode 100644 samples/bpf/tracex1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index b5b3600dcdf5..51f6f01e5a3a 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -6,23 +6,27 @@ hostprogs-y := test_verifier test_maps
 hostprogs-y += sock_example
 hostprogs-y += sockex1
 hostprogs-y += sockex2
+hostprogs-y += tracex1
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
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
index ca0333146006..1c872bcf5a80 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -15,6 +15,12 @@ static int (*bpf_map_update_elem)(void *map, void *key, void *value,
 	(void *) BPF_FUNC_map_update_elem;
 static int (*bpf_map_delete_elem)(void *map, void *key) =
 	(void *) BPF_FUNC_map_delete_elem;
+static int (*bpf_probe_read)(void *dst, int size, void *unsafe_ptr) =
+	(void *) BPF_FUNC_probe_read;
+static unsigned long long (*bpf_ktime_get_ns)(void) =
+	(void *) BPF_FUNC_ktime_get_ns;
+static int (*bpf_trace_printk)(const char *fmt, int fmt_size, ...) =
+	(void *) BPF_FUNC_trace_printk;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 1831d236382b..8b42adb0b099 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -8,29 +8,64 @@
 #include <unistd.h>
 #include <string.h>
 #include <stdbool.h>
+#include <stdlib.h>
 #include <linux/bpf.h>
 #include <linux/filter.h>
+#include <linux/perf_event.h>
+#include <sys/syscall.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <poll.h>
 #include "libbpf.h"
 #include "bpf_helpers.h"
 #include "bpf_load.h"
 
+#define DEBUGFS "/sys/kernel/debug/tracing/"
+
 static char license[128];
+static int kern_version;
 static bool processed_sec[128];
 int map_fd[MAX_MAPS];
 int prog_fd[MAX_PROGS];
+int event_fd[MAX_PROGS];
 int prog_cnt;
 
 static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 {
-	int fd;
 	bool is_socket = strncmp(event, "socket", 6) == 0;
-
-	if (!is_socket)
-		/* tracing events tbd */
+	bool is_kprobe = strncmp(event, "events/kprobes/", 15) == 0;
+	enum bpf_prog_type prog_type;
+	char buf[256];
+	int fd, efd, err, id;
+	struct perf_event_attr attr = {};
+
+	attr.type = PERF_TYPE_TRACEPOINT;
+	attr.sample_type = PERF_SAMPLE_RAW;
+	attr.sample_period = 1;
+	attr.wakeup_events = 1;
+
+	if (is_socket) {
+		prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
+	} else if (is_kprobe) {
+		prog_type = BPF_PROG_TYPE_KPROBE;
+	} else {
+		printf("Unknown event '%s'\n", event);
 		return -1;
+	}
+
+	if (is_kprobe) {
+		snprintf(buf, sizeof(buf),
+			 "echo 'p:%s %s' >> /sys/kernel/debug/tracing/kprobe_events",
+			 event + 15, event + 15);
+		err = system(buf);
+		if (err < 0) {
+			printf("failed to create kprobe '%s' error '%s'\n",
+			       event + 15, strerror(errno));
+			return -1;
+		}
+	}
 
-	fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER,
-			   prog, size, license);
+	fd = bpf_prog_load(prog_type, prog, size, license, kern_version);
 
 	if (fd < 0) {
 		printf("bpf_prog_load() err=%d\n%s", errno, bpf_log_buf);
@@ -39,6 +74,40 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
+	if (is_socket)
+		return 0;
+
+	strcpy(buf, DEBUGFS);
+	strcat(buf, event);
+	strcat(buf, "/id");
+
+	efd = open(buf, O_RDONLY, 0);
+	if (efd < 0) {
+		printf("failed to open event %s\n", event);
+		return -1;
+	}
+
+	err = read(efd, buf, sizeof(buf));
+	if (err < 0 || err >= sizeof(buf)) {
+		printf("read from '%s' failed '%s'\n", event, strerror(errno));
+		return -1;
+	}
+
+	close(efd);
+
+	buf[err] = 0;
+	id = atoi(buf);
+	attr.config = id;
+
+	efd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
+	if (efd < 0) {
+		printf("event %d fd %d err %s\n", id, efd, strerror(errno));
+		return -1;
+	}
+	event_fd[prog_cnt - 1] = efd;
+	ioctl(efd, PERF_EVENT_IOC_ENABLE, 0);
+	ioctl(efd, PERF_EVENT_IOC_SET_BPF, fd);
+
 	return 0;
 }
 
@@ -135,6 +204,9 @@ int load_bpf_file(char *path)
 	if (gelf_getehdr(elf, &ehdr) != &ehdr)
 		return 1;
 
+	/* clear all kprobes */
+	i = system("echo \"\" > /sys/kernel/debug/tracing/kprobe_events");
+
 	/* scan over all elf sections to get license and map info */
 	for (i = 1; i < ehdr.e_shnum; i++) {
 
@@ -149,6 +221,14 @@ int load_bpf_file(char *path)
 		if (strcmp(shname, "license") == 0) {
 			processed_sec[i] = true;
 			memcpy(license, data->d_buf, data->d_size);
+		} else if (strcmp(shname, "version") == 0) {
+			processed_sec[i] = true;
+			if (data->d_size != sizeof(int)) {
+				printf("invalid size of version section %zd\n",
+				       data->d_size);
+				return 1;
+			}
+			memcpy(&kern_version, data->d_buf, sizeof(int));
 		} else if (strcmp(shname, "maps") == 0) {
 			processed_sec[i] = true;
 			if (load_maps(data->d_buf, data->d_size))
@@ -201,3 +281,23 @@ int load_bpf_file(char *path)
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
index 27789a34f5e6..cbd7c2b532b9 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -6,6 +6,7 @@
 
 extern int map_fd[MAX_MAPS];
 extern int prog_fd[MAX_PROGS];
+extern int event_fd[MAX_PROGS];
 
 /* parses elf file compiled by llvm .c->.o
  * . parses 'maps' section and creates maps via BPF syscall
@@ -21,4 +22,6 @@ extern int prog_fd[MAX_PROGS];
  */
 int load_bpf_file(char *path);
 
+void read_trace_pipe(void);
+
 #endif
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 46d50b7ddf79..a2f9810ff967 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -81,7 +81,7 @@ char bpf_log_buf[LOG_BUF_SIZE];
 
 int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int prog_len,
-		  const char *license)
+		  const char *license, int kern_version)
 {
 	union bpf_attr attr = {
 		.prog_type = prog_type,
@@ -91,6 +91,7 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 		.log_buf = ptr_to_u64(bpf_log_buf),
 		.log_size = LOG_BUF_SIZE,
 		.log_level = 1,
+		.kern_version = kern_version,
 	};
 
 	bpf_log_buf[0] = 0;
@@ -121,3 +122,10 @@ int open_raw_sock(const char *name)
 
 	return sock;
 }
+
+int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
+		    int group_fd, unsigned long flags)
+{
+	return syscall(__NR_perf_event_open, attr, pid, cpu,
+		       group_fd, flags);
+}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 58c5fe1bdba1..ac7b09672b46 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -13,7 +13,7 @@ int bpf_get_next_key(int fd, void *key, void *next_key);
 
 int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int insn_len,
-		  const char *license);
+		  const char *license, int kern_version);
 
 #define LOG_BUF_SIZE 65536
 extern char bpf_log_buf[LOG_BUF_SIZE];
@@ -182,4 +182,7 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
 /* create RAW socket and bind to interface 'name' */
 int open_raw_sock(const char *name);
 
+struct perf_event_attr;
+int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
+		    int group_fd, unsigned long flags);
 #endif
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index c8ad0404416f..a0ce251c5390 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -56,7 +56,7 @@ static int test_sock(void)
 	};
 
 	prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
-				"GPL");
+				"GPL", 0);
 	if (prog_fd < 0) {
 		printf("failed to load prog '%s'\n", strerror(errno));
 		goto cleanup;
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index b96175e90363..740ce97cda5e 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -689,7 +689,7 @@ static int test(void)
 
 		prog_fd = bpf_prog_load(BPF_PROG_TYPE_UNSPEC, prog,
 					prog_len * sizeof(struct bpf_insn),
-					"GPL");
+					"GPL", 0);
 
 		if (tests[i].result == ACCEPT) {
 			if (prog_fd < 0) {
diff --git a/samples/bpf/tracex1_kern.c b/samples/bpf/tracex1_kern.c
new file mode 100644
index 000000000000..69ab7ed15510
--- /dev/null
+++ b/samples/bpf/tracex1_kern.c
@@ -0,0 +1,50 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <linux/version.h>
+#include "bpf_helpers.h"
+
+#define _(P) ({typeof(P) val = 0; bpf_probe_read(&val, sizeof(val), &P); val;})
+
+/* kprobe is NOT a stable ABI
+ * kernel functions can be removed, renamed or completely change semantics.
+ * Number of argumnets and their posistions can change, etc.
+ * This bpf+kprobe example can stop working any time.
+ */
+SEC("events/kprobes/__netif_receive_skb_core")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	/* attaches to kprobe netif_receive_skb,
+	 * looks for packets on loobpack device and prints them
+	 */
+	char devname[IFNAMSIZ] = {};
+	struct net_device *dev;
+	struct sk_buff *skb;
+	int len;
+
+	/* non-portable! works for the given kernel only */
+	skb = (struct sk_buff *) ctx->di;
+
+	dev = _(skb->dev);
+
+	len = _(skb->len);
+
+	bpf_probe_read(devname, sizeof(devname), dev->name);
+
+	if (devname[0] == 'l' && devname[1] == 'o') {
+		char fmt[] = "skb %p len %d\n";
+		/* using bpf_trace_printk() for DEBUG ONLY */
+		bpf_trace_printk(fmt, sizeof(fmt), skb, len);
+	}
+
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex1_user.c b/samples/bpf/tracex1_user.c
new file mode 100644
index 000000000000..31a48183beea
--- /dev/null
+++ b/samples/bpf/tracex1_user.c
@@ -0,0 +1,25 @@
+#include <stdio.h>
+#include <linux/bpf.h>
+#include <unistd.h>
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
+	f = popen("taskset 1 ping -c5 localhost", "r");
+	(void) f;
+
+	read_trace_pipe();
+
+	return 0;
+}
-- 
1.7.9.5
