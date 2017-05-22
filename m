From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/2] samples/bpf: add samples for HW_CACHE / RAW events
Date: Mon, 22 May 2017 15:48:40 -0700
Message-ID: <20170522224840.810121-3-ast@fb.com>
References: <20170522224840.810121-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522224840.810121-1-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Teng Qin <qinteng@fb.com>

This commit adds sample to test attach BPF to HW_CACHE and RAW type
events into the trace_event sample. The test outputs a lot of things to
screen, therefore make sure it aborts on error so it's easier to see if
everything works. Also update clean-up logic to disable the perf event
before closing pmu_fd.

This commit also adds sample to test read HW_CACHE and RAW type event
counters from BPF program using bpf_perf_event_read. Refactored the
existing sample to fork individual task on each CPU, attach kprobe to
more controllable function, and more accurately check if each read on
every CPU returned with good value.

Signed-off-by: Teng Qin <qinteng@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/bpf_helpers.h      |   2 +-
 samples/bpf/trace_event_user.c |  46 +++++++++++-
 samples/bpf/tracex6_kern.c     |  28 ++++++--
 samples/bpf/tracex6_user.c     | 155 +++++++++++++++++++++++++++++++----------
 4 files changed, 182 insertions(+), 49 deletions(-)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 9a9c95f2c9fb..bbe1388ad149 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -31,7 +31,7 @@ static unsigned long long (*bpf_get_current_uid_gid)(void) =
 	(void *) BPF_FUNC_get_current_uid_gid;
 static int (*bpf_get_current_comm)(void *buf, int buf_size) =
 	(void *) BPF_FUNC_get_current_comm;
-static int (*bpf_perf_event_read)(void *map, int index) =
+static u64 (*bpf_perf_event_read)(void *map, u64 flags) =
 	(void *) BPF_FUNC_perf_event_read;
 static int (*bpf_clone_redirect)(void *ctx, int ifindex, int flags) =
 	(void *) BPF_FUNC_clone_redirect;
diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
index fa4336423da5..666761773fda 100644
--- a/samples/bpf/trace_event_user.c
+++ b/samples/bpf/trace_event_user.c
@@ -122,13 +122,14 @@ static void test_perf_event_all_cpu(struct perf_event_attr *attr)
 {
 	int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
 	int *pmu_fd = malloc(nr_cpus * sizeof(int));
-	int i;
+	int i, error = 0;
 
 	/* open perf_event on all cpus */
 	for (i = 0; i < nr_cpus; i++) {
 		pmu_fd[i] = sys_perf_event_open(attr, -1, i, -1, 0);
 		if (pmu_fd[i] < 0) {
 			printf("sys_perf_event_open failed\n");
+			error = 1;
 			goto all_cpu_err;
 		}
 		assert(ioctl(pmu_fd[i], PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
@@ -137,9 +138,13 @@ static void test_perf_event_all_cpu(struct perf_event_attr *attr)
 	system("dd if=/dev/zero of=/dev/null count=5000k");
 	print_stacks();
 all_cpu_err:
-	for (i--; i >= 0; i--)
+	for (i--; i >= 0; i--) {
+		ioctl(pmu_fd[i], PERF_EVENT_IOC_DISABLE, 0);
 		close(pmu_fd[i]);
+	}
 	free(pmu_fd);
+	if (error)
+		int_exit(0);
 }
 
 static void test_perf_event_task(struct perf_event_attr *attr)
@@ -150,7 +155,7 @@ static void test_perf_event_task(struct perf_event_attr *attr)
 	pmu_fd = sys_perf_event_open(attr, 0, -1, -1, 0);
 	if (pmu_fd < 0) {
 		printf("sys_perf_event_open failed\n");
-		return;
+		int_exit(0);
 	}
 	assert(ioctl(pmu_fd, PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
 	assert(ioctl(pmu_fd, PERF_EVENT_IOC_ENABLE, 0) == 0);
@@ -175,11 +180,45 @@ static void test_bpf_perf_event(void)
 		.config = PERF_COUNT_SW_CPU_CLOCK,
 		.inherit = 1,
 	};
+	struct perf_event_attr attr_hw_cache_l1d = {
+		.sample_freq = SAMPLE_FREQ,
+		.freq = 1,
+		.type = PERF_TYPE_HW_CACHE,
+		.config =
+			PERF_COUNT_HW_CACHE_L1D |
+			(PERF_COUNT_HW_CACHE_OP_READ << 8) |
+			(PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16),
+		.inherit = 1,
+	};
+	struct perf_event_attr attr_hw_cache_branch_miss = {
+		.sample_freq = SAMPLE_FREQ,
+		.freq = 1,
+		.type = PERF_TYPE_HW_CACHE,
+		.config =
+			PERF_COUNT_HW_CACHE_BPU |
+			(PERF_COUNT_HW_CACHE_OP_READ << 8) |
+			(PERF_COUNT_HW_CACHE_RESULT_MISS << 16),
+		.inherit = 1,
+	};
+	struct perf_event_attr attr_type_raw = {
+		.sample_freq = SAMPLE_FREQ,
+		.freq = 1,
+		.type = PERF_TYPE_RAW,
+		/* Intel Instruction Retired */
+		.config = 0xc0,
+		.inherit = 1,
+	};
 
 	test_perf_event_all_cpu(&attr_type_hw);
 	test_perf_event_task(&attr_type_hw);
 	test_perf_event_all_cpu(&attr_type_sw);
 	test_perf_event_task(&attr_type_sw);
+	test_perf_event_all_cpu(&attr_hw_cache_l1d);
+	test_perf_event_task(&attr_hw_cache_l1d);
+	test_perf_event_all_cpu(&attr_hw_cache_branch_miss);
+	test_perf_event_task(&attr_hw_cache_branch_miss);
+	test_perf_event_all_cpu(&attr_type_raw);
+	test_perf_event_task(&attr_type_raw);
 }
 
 
@@ -210,6 +249,7 @@ int main(int argc, char **argv)
 	}
 	test_bpf_perf_event();
 
+	printf("Success!\n");
 	int_exit(0);
 	return 0;
 }
diff --git a/samples/bpf/tracex6_kern.c b/samples/bpf/tracex6_kern.c
index be479c4af9e2..646f86426d09 100644
--- a/samples/bpf/tracex6_kern.c
+++ b/samples/bpf/tracex6_kern.c
@@ -3,22 +3,36 @@
 #include <uapi/linux/bpf.h>
 #include "bpf_helpers.h"
 
-struct bpf_map_def SEC("maps") my_map = {
+struct bpf_map_def SEC("maps") counters = {
 	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
 	.key_size = sizeof(int),
 	.value_size = sizeof(u32),
-	.max_entries = 32,
+	.max_entries = 64,
+};
+struct bpf_map_def SEC("maps") values = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(int),
+	.value_size = sizeof(u64),
+	.max_entries = 64,
 };
 
-SEC("kprobe/sys_write")
+SEC("kprobe/htab_map_get_next_key")
 int bpf_prog1(struct pt_regs *ctx)
 {
-	u64 count;
+	u64 count, *val;
+	s64 error;
 	u32 key = bpf_get_smp_processor_id();
-	char fmt[] = "CPU-%d   %llu\n";
 
-	count = bpf_perf_event_read(&my_map, key);
-	bpf_trace_printk(fmt, sizeof(fmt), key, count);
+	count = bpf_perf_event_read(&counters, key);
+	error = (s64)count;
+	if (error < 0 && error > -256)
+		return 0;
+
+	val = bpf_map_lookup_elem(&values, &key);
+	if (val)
+		*val = count;
+	else
+		bpf_map_update_elem(&values, &key, &count, BPF_NOEXIST);
 
 	return 0;
 }
diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
index ca7874ed77f4..3455ac458234 100644
--- a/samples/bpf/tracex6_user.c
+++ b/samples/bpf/tracex6_user.c
@@ -1,73 +1,152 @@
-#include <stdio.h>
-#include <unistd.h>
-#include <stdlib.h>
-#include <stdbool.h>
-#include <string.h>
+#define _GNU_SOURCE
+
+#include <assert.h>
 #include <fcntl.h>
-#include <poll.h>
-#include <sys/ioctl.h>
 #include <linux/perf_event.h>
 #include <linux/bpf.h>
-#include "libbpf.h"
+#include <sched.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/ioctl.h>
+#include <sys/resource.h>
+#include <sys/time.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <unistd.h>
+
 #include "bpf_load.h"
+#include "libbpf.h"
 #include "perf-sys.h"
 
 #define SAMPLE_PERIOD  0x7fffffffffffffffULL
 
-static void test_bpf_perf_event(void)
+static void check_on_cpu(int cpu, struct perf_event_attr *attr)
 {
-	int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
-	int *pmu_fd = malloc(nr_cpus * sizeof(int));
-	int status, i;
+	cpu_set_t set;
+	int pmu_fd;
+	__u64 value;
+	int error = 0;
+	/* Move to target CPU */
+	CPU_ZERO(&set);
+	CPU_SET(cpu, &set);
+	assert(sched_setaffinity(0, sizeof(set), &set) == 0);
+	/* Open perf event and attach to the perf_event_array */
+	pmu_fd = sys_perf_event_open(attr, -1/*pid*/, cpu/*cpu*/, -1/*group_fd*/, 0);
+	if (pmu_fd < 0) {
+		fprintf(stderr, "sys_perf_event_open failed on CPU %d\n", cpu);
+		error = 1;
+		goto on_exit;
+	}
+	assert(bpf_map_update_elem(map_fd[0], &cpu, &pmu_fd, BPF_ANY) == 0);
+	assert(ioctl(pmu_fd, PERF_EVENT_IOC_ENABLE, 0) == 0);
+	/* Trigger the kprobe */
+	bpf_map_get_next_key(map_fd[1], &cpu, NULL);
+	/* Check the value */
+	if (bpf_map_lookup_elem(map_fd[1], &cpu, &value)) {
+		fprintf(stderr, "Value missing for CPU %d\n", cpu);
+		error = 1;
+		goto on_exit;
+	}
+	fprintf(stderr, "CPU %d: %llu\n", cpu, value);
+
+on_exit:
+	assert(bpf_map_delete_elem(map_fd[0], &cpu) == 0 || error);
+	assert(ioctl(pmu_fd, PERF_EVENT_IOC_DISABLE, 0) == 0 || error);
+	assert(close(pmu_fd) == 0 || error);
+	assert(bpf_map_delete_elem(map_fd[1], &cpu) == 0 || error);
+	exit(error);
+}
 
-	struct perf_event_attr attr_insn_pmu = {
+static void test_perf_event_array(struct perf_event_attr *attr,
+				  const char *name)
+{
+	int i, status, nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	pid_t pid[nr_cpus];
+
+	printf("Test reading %s counters\n", name);
+
+	for (i = 0; i < nr_cpus; i++) {
+		pid[i] = fork();
+		assert(pid[i] >= 0);
+		if (pid[i] == 0) {
+			check_on_cpu(i, attr);
+			exit(1);
+		}
+	}
+
+	for (i = 0; i < nr_cpus; i++) {
+		assert(waitpid(pid[i], &status, 0) == pid[i]);
+		assert(status == 0);
+	}
+}
+
+static void test_bpf_perf_event(void)
+{
+	struct perf_event_attr attr_cycles = {
 		.freq = 0,
 		.sample_period = SAMPLE_PERIOD,
 		.inherit = 0,
 		.type = PERF_TYPE_HARDWARE,
 		.read_format = 0,
 		.sample_type = 0,
-		.config = 0,/* PMU: cycles */
+		.config = PERF_COUNT_HW_CPU_CYCLES,
+	};
+	struct perf_event_attr attr_raw = {
+		.freq = 0,
+		.sample_period = SAMPLE_PERIOD,
+		.inherit = 0,
+		.type = PERF_TYPE_RAW,
+		.read_format = 0,
+		.sample_type = 0,
+		/* Intel Instruction Retired */
+		.config = 0xc0,
+	};
+	struct perf_event_attr attr_l1d_load = {
+		.freq = 0,
+		.sample_period = SAMPLE_PERIOD,
+		.inherit = 0,
+		.type = PERF_TYPE_HW_CACHE,
+		.read_format = 0,
+		.sample_type = 0,
+		.config =
+			PERF_COUNT_HW_CACHE_L1D |
+			(PERF_COUNT_HW_CACHE_OP_READ << 8) |
+			(PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16),
+	};
+	struct perf_event_attr attr_llc_miss = {
+		.freq = 0,
+		.sample_period = SAMPLE_PERIOD,
+		.inherit = 0,
+		.type = PERF_TYPE_HW_CACHE,
+		.read_format = 0,
+		.sample_type = 0,
+		.config =
+			PERF_COUNT_HW_CACHE_LL |
+			(PERF_COUNT_HW_CACHE_OP_READ << 8) |
+			(PERF_COUNT_HW_CACHE_RESULT_MISS << 16),
 	};
 
-	for (i = 0; i < nr_cpus; i++) {
-		pmu_fd[i] = sys_perf_event_open(&attr_insn_pmu, -1/*pid*/, i/*cpu*/, -1/*group_fd*/, 0);
-		if (pmu_fd[i] < 0) {
-			printf("event syscall failed\n");
-			goto exit;
-		}
-
-		bpf_map_update_elem(map_fd[0], &i, &pmu_fd[i], BPF_ANY);
-		ioctl(pmu_fd[i], PERF_EVENT_IOC_ENABLE, 0);
-	}
-
-	status = system("ls > /dev/null");
-	if (status)
-		goto exit;
-	status = system("sleep 2");
-	if (status)
-		goto exit;
-
-exit:
-	for (i = 0; i < nr_cpus; i++)
-		close(pmu_fd[i]);
-	close(map_fd[0]);
-	free(pmu_fd);
+	test_perf_event_array(&attr_cycles, "HARDWARE-cycles");
+	test_perf_event_array(&attr_raw, "RAW-instruction-retired");
+	test_perf_event_array(&attr_l1d_load, "HW_CACHE-L1D-load");
+	test_perf_event_array(&attr_llc_miss, "HW_CACHE-LLC-miss");
 }
 
 int main(int argc, char **argv)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	char filename[256];
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
+	setrlimit(RLIMIT_MEMLOCK, &r);
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
 		return 1;
 	}
 
 	test_bpf_perf_event();
-	read_trace_pipe();
 
+	printf("Success!\n");
 	return 0;
 }
-- 
2.9.3
