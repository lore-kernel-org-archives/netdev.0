From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 3/3] samples: bpf: add bpf_perf_event_output example
Date: Tue, 20 Oct 2015 20:02:35 -0700
Message-ID: <1445396556-4854-4-git-send-email-ast@kernel.org>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445396556-4854-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Performance test and example of bpf_perf_event_output().
kprobe is attached to sys_write() and trivial bpf program streams
pid+cookie into userspace via PERF_COUNT_SW_BPF_OUTPUT event.

Usage:
$ sudo ./bld_x64/samples/bpf/trace_output
recv 2968913 events per sec

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile            |    7 ++
 samples/bpf/bpf_helpers.h       |    2 +
 samples/bpf/trace_output_kern.c |   31 +++++++
 samples/bpf/trace_output_user.c |  196 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 236 insertions(+)
 create mode 100644 samples/bpf/trace_output_kern.c
 create mode 100644 samples/bpf/trace_output_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 63e7d50e6a4f..b30514514e37 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -13,6 +13,7 @@ hostprogs-y += tracex3
 hostprogs-y += tracex4
 hostprogs-y += tracex5
 hostprogs-y += tracex6
+hostprogs-y += trace_output
 hostprogs-y += lathist
 
 test_verifier-objs := test_verifier.o libbpf.o
@@ -27,6 +28,7 @@ tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
 tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
 tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
 tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
+trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
 lathist-objs := bpf_load.o libbpf.o lathist_user.o
 
 # Tell kbuild to always build the programs
@@ -40,6 +42,7 @@ always += tracex3_kern.o
 always += tracex4_kern.o
 always += tracex5_kern.o
 always += tracex6_kern.o
+always += trace_output_kern.o
 always += tcbpf1_kern.o
 always += lathist_kern.o
 
@@ -55,6 +58,7 @@ HOSTLOADLIBES_tracex3 += -lelf
 HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
 HOSTLOADLIBES_tracex6 += -lelf
+HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
 
 # point this to your LLVM backend with bpf support
@@ -64,3 +68,6 @@ $(obj)/%.o: $(src)/%.c
 	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
 		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
+	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
+		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=asm -o $@.s
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 21aa1b44c30c..b35c21e0b43f 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -37,6 +37,8 @@ static int (*bpf_clone_redirect)(void *ctx, int ifindex, int flags) =
 	(void *) BPF_FUNC_clone_redirect;
 static int (*bpf_redirect)(int ifindex, int flags) =
 	(void *) BPF_FUNC_redirect;
+static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data, int size) =
+	(void *) BPF_FUNC_perf_event_output;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/trace_output_kern.c b/samples/bpf/trace_output_kern.c
new file mode 100644
index 000000000000..8d8d1ec429eb
--- /dev/null
+++ b/samples/bpf/trace_output_kern.c
@@ -0,0 +1,31 @@
+#include <linux/ptrace.h>
+#include <linux/version.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(u32),
+	.max_entries = 2,
+};
+
+SEC("kprobe/sys_write")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	struct S {
+		u64 pid;
+		u64 cookie;
+	} data;
+
+	memset(&data, 0, sizeof(data));
+	data.pid = bpf_get_current_pid_tgid();
+	data.cookie = 0x12345678;
+
+	bpf_perf_event_output(ctx, &my_map, 0, &data, sizeof(data));
+
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/trace_output_user.c b/samples/bpf/trace_output_user.c
new file mode 100644
index 000000000000..661a7d052f2c
--- /dev/null
+++ b/samples/bpf/trace_output_user.c
@@ -0,0 +1,196 @@
+/* This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <string.h>
+#include <fcntl.h>
+#include <poll.h>
+#include <sys/ioctl.h>
+#include <linux/perf_event.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <assert.h>
+#include <sys/syscall.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <time.h>
+#include <signal.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+static int pmu_fd;
+
+int page_size;
+int page_cnt = 8;
+volatile struct perf_event_mmap_page *header;
+
+typedef void (*print_fn)(void *data, int size);
+
+static int perf_event_mmap(int fd)
+{
+	void *base;
+	int mmap_size;
+
+	page_size = getpagesize();
+	mmap_size = page_size * (page_cnt + 1);
+
+	base = mmap(NULL, mmap_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
+	if (base == MAP_FAILED) {
+		printf("mmap err\n");
+		return -1;
+	}
+
+	header = base;
+	return 0;
+}
+
+static int perf_event_poll(int fd)
+{
+	struct pollfd pfd = { .fd = fd, .events = POLLIN };
+
+	return poll(&pfd, 1, 1000);
+}
+
+struct perf_event_sample {
+	struct perf_event_header header;
+	__u32 size;
+	char data[];
+};
+
+void perf_event_read(print_fn fn)
+{
+	__u64 data_tail = header->data_tail;
+	__u64 data_head = header->data_head;
+	__u64 buffer_size = page_cnt * page_size;
+	void *base, *begin, *end;
+	char buf[256];
+
+	asm volatile("" ::: "memory"); /* in real code it should be smp_rmb() */
+	if (data_head == data_tail)
+		return;
+
+	base = ((char *)header) + page_size;
+
+	begin = base + data_tail % buffer_size;
+	end = base + data_head % buffer_size;
+
+	while (begin != end) {
+		struct perf_event_sample *e;
+
+		e = begin;
+		if (begin + e->header.size > base + buffer_size) {
+			long len = base + buffer_size - begin;
+
+			assert(len < e->header.size);
+			memcpy(buf, begin, len);
+			memcpy(buf + len, base, e->header.size - len);
+			e = (void *) buf;
+			begin = base + e->header.size - len;
+		} else if (begin + e->header.size == base + buffer_size) {
+			begin = base;
+		} else {
+			begin += e->header.size;
+		}
+
+		if (e->header.type == PERF_RECORD_SAMPLE) {
+			fn(e->data, e->size);
+		} else if (e->header.type == PERF_RECORD_LOST) {
+			struct {
+				struct perf_event_header header;
+				__u64 id;
+				__u64 lost;
+			} *lost = (void *) e;
+			printf("lost %lld events\n", lost->lost);
+		} else {
+			printf("unknown event type=%d size=%d\n",
+			       e->header.type, e->header.size);
+		}
+	}
+
+	__sync_synchronize(); /* smp_mb() */
+	header->data_tail = data_head;
+}
+
+static __u64 time_get_ns(void)
+{
+	struct timespec ts;
+
+	clock_gettime(CLOCK_MONOTONIC, &ts);
+	return ts.tv_sec * 1000000000ull + ts.tv_nsec;
+}
+
+static __u64 start_time;
+
+#define MAX_CNT 100000ll
+
+static void print_bpf_output(void *data, int size)
+{
+	static __u64 cnt;
+	struct {
+		__u64 pid;
+		__u64 cookie;
+	} *e = data;
+
+	if (e->cookie != 0x12345678) {
+		printf("BUG pid %llx cookie %llx sized %d\n",
+		       e->pid, e->cookie, size);
+		kill(0, SIGINT);
+	}
+
+	cnt++;
+
+	if (cnt == MAX_CNT) {
+		printf("recv %lld events per sec\n",
+		       MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+		kill(0, SIGINT);
+	}
+}
+
+static void test_bpf_perf_event(void)
+{
+	struct perf_event_attr attr = {
+		.sample_type = PERF_SAMPLE_RAW,
+		.type = PERF_TYPE_SOFTWARE,
+		.config = PERF_COUNT_SW_BPF_OUTPUT,
+	};
+	int key = 0;
+
+	pmu_fd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
+
+	assert(pmu_fd >= 0);
+	assert(bpf_update_elem(map_fd[0], &key, &pmu_fd, BPF_ANY) == 0);
+	ioctl(pmu_fd, PERF_EVENT_IOC_ENABLE, 0);
+}
+
+int main(int argc, char **argv)
+{
+	char filename[256];
+	FILE *f;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	test_bpf_perf_event();
+
+	if (perf_event_mmap(pmu_fd) < 0)
+		return 1;
+
+	f = popen("taskset 1 dd if=/dev/zero of=/dev/null", "r");
+	(void) f;
+
+	start_time = time_get_ns();
+	for (;;) {
+		perf_event_poll(pmu_fd);
+		perf_event_read(print_bpf_output);
+	}
+
+	return 0;
+}
-- 
1.7.9.5
