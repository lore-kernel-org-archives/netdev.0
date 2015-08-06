From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v7 5/5] samples/bpf: example of get selected PMU counter value
Date: Thu, 6 Aug 2015 07:02:36 +0000
Message-ID: <1438844556-27064-6-git-send-email-xiakaixu@huawei.com>
References: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a simple example and shows how to use the new ability
to get the selected Hardware PMU counter value.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 samples/bpf/Makefile       |  4 +++
 samples/bpf/bpf_helpers.h  |  2 ++
 samples/bpf/tracex6_kern.c | 26 ++++++++++++++++++
 samples/bpf/tracex6_user.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 100 insertions(+)
 create mode 100644 samples/bpf/tracex6_kern.c
 create mode 100644 samples/bpf/tracex6_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 4450fed..63e7d50 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -12,6 +12,7 @@ hostprogs-y += tracex2
 hostprogs-y += tracex3
 hostprogs-y += tracex4
 hostprogs-y += tracex5
+hostprogs-y += tracex6
 hostprogs-y += lathist
 
 test_verifier-objs := test_verifier.o libbpf.o
@@ -25,6 +26,7 @@ tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
 tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
 tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
 tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
+tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
 lathist-objs := bpf_load.o libbpf.o lathist_user.o
 
 # Tell kbuild to always build the programs
@@ -37,6 +39,7 @@ always += tracex2_kern.o
 always += tracex3_kern.o
 always += tracex4_kern.o
 always += tracex5_kern.o
+always += tracex6_kern.o
 always += tcbpf1_kern.o
 always += lathist_kern.o
 
@@ -51,6 +54,7 @@ HOSTLOADLIBES_tracex2 += -lelf
 HOSTLOADLIBES_tracex3 += -lelf
 HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
+HOSTLOADLIBES_tracex6 += -lelf
 HOSTLOADLIBES_lathist += -lelf
 
 # point this to your LLVM backend with bpf support
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index c77c872..3a44d3a 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -31,6 +31,8 @@ static unsigned long long (*bpf_get_current_uid_gid)(void) =
 	(void *) BPF_FUNC_get_current_uid_gid;
 static int (*bpf_get_current_comm)(void *buf, int buf_size) =
 	(void *) BPF_FUNC_get_current_comm;
+static int (*bpf_perf_event_read)(void *map, int index) =
+	(void *) BPF_FUNC_perf_event_read;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/tracex6_kern.c b/samples/bpf/tracex6_kern.c
new file mode 100644
index 0000000..23d1cff
--- /dev/null
+++ b/samples/bpf/tracex6_kern.c
@@ -0,0 +1,26 @@
+#include <linux/version.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(u32),
+	.max_entries = 32,
+};
+
+SEC("kprobe/sys_write")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	u64 count;
+	u32 key = bpf_get_smp_processor_id();
+	char fmt[] = "CPU-%d   %llu\n";
+
+	count = bpf_perf_event_read(&my_map, key);
+	bpf_trace_printk(fmt, sizeof(fmt), key, count);
+
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
new file mode 100644
index 0000000..928f05e
--- /dev/null
+++ b/samples/bpf/tracex6_user.c
@@ -0,0 +1,68 @@
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
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define SAMPLE_PERIOD  0x7fffffffffffffffULL
+
+static void test_bpf_perf_event(void)
+{
+	int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	int *pmu_fd = malloc(nr_cpus * sizeof(int));
+	unsigned long value;
+	int i;
+
+	struct perf_event_attr attr_insn_pmu = {
+		.freq = 0,
+		.sample_period = SAMPLE_PERIOD,
+		.inherit = 0,
+		.type = PERF_TYPE_HARDWARE,
+		.read_format = 0,
+		.sample_type = 0,
+		.config = 0,/* PMU: cycles */
+	};
+
+	for (i = 0; i < nr_cpus; i++) {
+		pmu_fd[i] = perf_event_open(&attr_insn_pmu, -1/*pid*/, i/*cpu*/, -1/*group_fd*/, 0);
+		if (pmu_fd[i] < 0)
+			printf("event syscall failed\n");
+
+		bpf_update_elem(map_fd[0], &i, &pmu_fd[i], BPF_ANY);
+		ioctl(pmu_fd[i], PERF_EVENT_IOC_ENABLE, 0);
+	}
+
+	system("ls");
+	system("pwd");
+	system("sleep 2");
+
+	for (i = 0; i < nr_cpus; i++)
+		close(pmu_fd[i]);
+
+	close(map_fd);
+
+	free(pmu_fd);
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
+	test_bpf_perf_event();
+
+	return 0;
+}
-- 
1.8.3.4
