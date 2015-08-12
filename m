From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH net-next] bpf: fix build warnings and add function read_trace_pipe()
Date: Wed, 12 Aug 2015 09:37:53 +0000
Message-ID: <1439372273-69958-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<wangnan0@huawei.com>, <pi3orama@163.com>, <xiakaixu@huawei.com>
To: <daniel@iogearbox.net>, <davem@davemloft.net>, <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two improvements in this patch:
 1. Fix the build warnings;
 2. Add function read_trace_pipe() to print the result on
    the screen;

Before this patch, we can get the result through /sys/kernel/de
bug/tracing/trace_pipe and get nothing on the screen.
By applying this patch, the result can be printed on the screen.
  $ ./tracex6
	...
         tracex6-705   [003] d..1   131.428593: : CPU-3   19981414
            sshd-683   [000] d..1   131.428727: : CPU-0   221682321
            sshd-683   [000] d..1   131.428821: : CPU-0   221808766
            sshd-683   [000] d..1   131.428950: : CPU-0   221982984
            sshd-683   [000] d..1   131.429045: : CPU-0   222111851
         tracex6-705   [003] d..1   131.429168: : CPU-3   20757551
            sshd-683   [000] d..1   131.429170: : CPU-0   222281240
            sshd-683   [000] d..1   131.429261: : CPU-0   222403340
            sshd-683   [000] d..1   131.429378: : CPU-0   222561024
	...

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 samples/bpf/tracex6_kern.c |  1 +
 samples/bpf/tracex6_user.c | 22 +++++++++++++---------
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/samples/bpf/tracex6_kern.c b/samples/bpf/tracex6_kern.c
index 23d1cff..be479c4 100644
--- a/samples/bpf/tracex6_kern.c
+++ b/samples/bpf/tracex6_kern.c
@@ -1,3 +1,4 @@
+#include <linux/ptrace.h>
 #include <linux/version.h>
 #include <uapi/linux/bpf.h>
 #include "bpf_helpers.h"
diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
index 928f05e..8ea4976 100644
--- a/samples/bpf/tracex6_user.c
+++ b/samples/bpf/tracex6_user.c
@@ -17,8 +17,7 @@ static void test_bpf_perf_event(void)
 {
 	int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
 	int *pmu_fd = malloc(nr_cpus * sizeof(int));
-	unsigned long value;
-	int i;
+	int status, i;
 
 	struct perf_event_attr attr_insn_pmu = {
 		.freq = 0,
@@ -32,22 +31,26 @@ static void test_bpf_perf_event(void)
 
 	for (i = 0; i < nr_cpus; i++) {
 		pmu_fd[i] = perf_event_open(&attr_insn_pmu, -1/*pid*/, i/*cpu*/, -1/*group_fd*/, 0);
-		if (pmu_fd[i] < 0)
+		if (pmu_fd[i] < 0) {
 			printf("event syscall failed\n");
+			goto exit;
+		}
 
 		bpf_update_elem(map_fd[0], &i, &pmu_fd[i], BPF_ANY);
 		ioctl(pmu_fd[i], PERF_EVENT_IOC_ENABLE, 0);
 	}
 
-	system("ls");
-	system("pwd");
-	system("sleep 2");
+	status = system("ls > /dev/null");
+	if (status)
+		goto exit;
+	status = system("sleep 2");
+	if (status)
+		goto exit;
 
+exit:
 	for (i = 0; i < nr_cpus; i++)
 		close(pmu_fd[i]);
-
-	close(map_fd);
-
+	close(map_fd[0]);
 	free(pmu_fd);
 }
 
@@ -63,6 +66,7 @@ int main(int argc, char **argv)
 	}
 
 	test_bpf_perf_event();
+	read_trace_pipe();
 
 	return 0;
 }
-- 
1.8.3.4
