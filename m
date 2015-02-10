From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 linux-trace 4/8] samples: bpf: simple tracing example in C
Date: Mon,  9 Feb 2015 19:45:57 -0800
Message-ID: <1423539961-21792-5-git-send-email-ast@plumgrid.com>
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

tracex1_kern.c - C program which will be compiled into eBPF
to filter netif_receive_skb events on skb->dev->name == "lo"
The programs returns 1 to store an event into ring_buffer
and returns 0 - to discard an event.

tracex1_user.c - corresponding user space component that:
- loads bpf program via bpf() syscall
- opens net:netif_receive_skb event via perf_event_open() syscall
- attaches the program to event via ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);
- mmaps event_fd
- polls event_fd, walks ring_buffer and prints events

Usage:
$ sudo tracex1
pid 29241 skb 0xffff88045e58c500 len 84 dev lo
pid 29241 skb 0xffff88045e58cd00 len 84 dev lo
pid 29241 skb 0xffff880074c35000 len 84 dev lo
pid 29241 skb 0xffff880074c35200 len 84 dev lo

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 ++
 samples/bpf/bpf_helpers.h  |   14 +++++
 samples/bpf/bpf_load.c     |  129 +++++++++++++++++++++++++++++++++++++++++---
 samples/bpf/bpf_load.h     |   12 +++++
 samples/bpf/tracex1_kern.c |   28 ++++++++++
 samples/bpf/tracex1_user.c |   50 +++++++++++++++++
 6 files changed, 231 insertions(+), 6 deletions(-)
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
index ca0333146006..406e9705d99e 100644
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
+static int (*bpf_probe_memcmp)(void *unsafe_ptr, void *safe_ptr, int size) =
+	(void *) BPF_FUNC_probe_memcmp;
+static unsigned long long (*bpf_ktime_get_ns)(void) =
+	(void *) BPF_FUNC_ktime_get_ns;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 1831d236382b..2aece65963e4 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -8,29 +8,47 @@
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
 static bool processed_sec[128];
 int map_fd[MAX_MAPS];
 int prog_fd[MAX_PROGS];
+int event_fd[MAX_PROGS];
 int prog_cnt;
 
 static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 {
-	int fd;
 	bool is_socket = strncmp(event, "socket", 6) == 0;
+	enum bpf_prog_type prog_type;
+	char path[256] = DEBUGFS;
+	char buf[32];
+	int fd, efd, err, id;
+	struct perf_event_attr attr;
 
-	if (!is_socket)
-		/* tracing events tbd */
-		return -1;
+	attr.type = PERF_TYPE_TRACEPOINT;
+	attr.sample_type = PERF_SAMPLE_RAW;
+	attr.sample_period = 1;
+	attr.wakeup_events = 1;
+
+	if (is_socket)
+		prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
+	else
+		prog_type = BPF_PROG_TYPE_TRACEPOINT;
 
-	fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER,
-			   prog, size, license);
+	fd = bpf_prog_load(prog_type, prog, size, license);
 
 	if (fd < 0) {
 		printf("bpf_prog_load() err=%d\n%s", errno, bpf_log_buf);
@@ -39,6 +57,39 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
+	if (is_socket)
+		return 0;
+
+	strcat(path, event);
+	strcat(path, "/id");
+
+	efd = open(path, O_RDONLY, 0);
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
 
@@ -201,3 +252,69 @@ int load_bpf_file(char *path)
 	close(fd);
 	return 0;
 }
+
+int page_size;
+int page_cnt = 8;
+volatile struct perf_event_mmap_page *header;
+
+int perf_event_mmap(int fd)
+{
+	void *base;
+	int mmap_size;
+
+	page_size = getpagesize();
+	mmap_size = page_size * (page_cnt + 1);
+
+	base = mmap(NULL, mmap_size, PROT_READ, MAP_SHARED, fd, 0);
+	if (base == MAP_FAILED) {
+		printf("mmap err\n");
+		return -1;
+	}
+
+	header = base;
+	return 0;
+}
+
+int perf_event_poll(int fd)
+{
+	struct pollfd pfd = {.fd = fd, .events = POLLIN};
+	return poll(&pfd, 1, -1);
+}
+
+struct perf_event_sample {
+	  struct perf_event_header header;
+	  __u32 size;
+	  char data[];
+};
+
+void perf_event_read(print_fn fn)
+{
+	static __u64 old_data_head = 0;
+	__u64 data_head = header->data_head;
+	__u64 buffer_size = page_cnt * page_size;
+	void *base, *begin, *end;
+
+	if (data_head == old_data_head)
+		return;
+
+	base = ((char *)header) + page_size;
+
+	begin = base + old_data_head % buffer_size;
+	end = base + data_head % buffer_size;
+
+	while (begin < end) {
+		struct perf_event_sample *e;
+
+		e = begin;
+
+		if (e->header.type != PERF_RECORD_SAMPLE) {
+			printf("event is not a sample type %d\n", e->header.type);
+		}
+
+		begin += sizeof(*e) + e->size;
+		fn(e->data, e->size);
+	}
+	/* else when end > begin - the events had wrapped. ignored for now */
+
+	old_data_head = data_head;
+}
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index 27789a34f5e6..cf55663405da 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -6,6 +6,7 @@
 
 extern int map_fd[MAX_MAPS];
 extern int prog_fd[MAX_PROGS];
+extern int event_fd[MAX_PROGS];
 
 /* parses elf file compiled by llvm .c->.o
  * . parses 'maps' section and creates maps via BPF syscall
@@ -21,4 +22,15 @@ extern int prog_fd[MAX_PROGS];
  */
 int load_bpf_file(char *path);
 
+int perf_event_mmap(int fd);
+int perf_event_poll(int fd);
+typedef void (*print_fn)(void *data, int size);
+void perf_event_read(print_fn fn);
+struct trace_entry {
+	unsigned short          type;
+	unsigned char           flags;
+	unsigned char           preempt_count;
+	int                     pid;
+};
+
 #endif
diff --git a/samples/bpf/tracex1_kern.c b/samples/bpf/tracex1_kern.c
new file mode 100644
index 000000000000..449db961c642
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
+	 * attaches to net:netif_receive_skb
+	 * and filters events for loobpack device only
+	 */
+	char devname[] = "lo";
+	struct net_device *dev;
+	struct sk_buff *skb = 0;
+
+	skb = (struct sk_buff *) ctx->arg1;
+	dev = bpf_fetch_ptr(&skb->dev);
+	if (bpf_probe_memcmp(dev->name, devname, 2) == 0)
+		/* pass event to userspace via perf ring_buffer */
+		return 1;
+
+	/* drop event */
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/tracex1_user.c b/samples/bpf/tracex1_user.c
new file mode 100644
index 000000000000..a49de23eb30b
--- /dev/null
+++ b/samples/bpf/tracex1_user.c
@@ -0,0 +1,50 @@
+#include <stdio.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+static char *get_str(void *entry, __u32 arrloc)
+{
+	int off = arrloc & 0xffff;
+	return entry + off;
+}
+
+static void print_netif_receive_skb(void *data, int size)
+{
+	struct ftrace_raw_netif_receive_skb {
+		struct trace_entry t;
+		void *skb;
+		__u32 len;
+		__u32 name;
+	} *e = data;
+
+	printf("pid %d skb %p len %d dev %s\n",
+	       e->t.pid, e->skb, e->len, get_str(e, e->name));
+}
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
+	if (perf_event_mmap(event_fd[0]) < 0)
+		return 1;
+
+	f = popen("taskset 1 ping -c5 localhost", "r");
+	(void) f;
+
+	for (;;) {
+		perf_event_poll(event_fd[0]);
+		perf_event_read(print_netif_receive_skb);
+	}
+
+	return 0;
+}
-- 
1.7.9.5
