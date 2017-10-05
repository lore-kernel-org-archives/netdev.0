From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v7 5/5] bpf: add a test case for helper bpf_perf_prog_read_value
Date: Thu, 5 Oct 2017 09:19:23 -0700
Message-ID: <20171005161923.332790-6-yhs@fb.com>
References: <20171005161923.332790-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56226 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751620AbdJEQT2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:19:28 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v95GGU2C016402
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 09:19:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2ddqfw0822-8
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 09:19:27 -0700
In-Reply-To: <20171005161923.332790-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bpf sample program trace_event is enhanced to use the new
helper to print out enabled/running time.

Signed-off-by: Yonghong Song <yhs@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/trace_event_kern.c            | 10 ++++++++++
 samples/bpf/trace_event_user.c            | 13 ++++++++-----
 tools/include/uapi/linux/bpf.h            |  3 ++-
 tools/testing/selftests/bpf/bpf_helpers.h |  3 +++
 4 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/samples/bpf/trace_event_kern.c b/samples/bpf/trace_event_kern.c
index 41b6115..a77a583d 100644
--- a/samples/bpf/trace_event_kern.c
+++ b/samples/bpf/trace_event_kern.c
@@ -37,10 +37,14 @@ struct bpf_map_def SEC("maps") stackmap = {
 SEC("perf_event")
 int bpf_prog1(struct bpf_perf_event_data *ctx)
 {
+	char time_fmt1[] = "Time Enabled: %llu, Time Running: %llu";
+	char time_fmt2[] = "Get Time Failed, ErrCode: %d";
 	char fmt[] = "CPU-%d period %lld ip %llx";
 	u32 cpu = bpf_get_smp_processor_id();
+	struct bpf_perf_event_value value_buf;
 	struct key_t key;
 	u64 *val, one = 1;
+	int ret;
 
 	if (ctx->sample_period < 10000)
 		/* ignore warmup */
@@ -54,6 +58,12 @@ int bpf_prog1(struct bpf_perf_event_data *ctx)
 		return 0;
 	}
 
+	ret = bpf_perf_prog_read_value(ctx, (void *)&value_buf, sizeof(struct bpf_perf_event_value));
+	if (!ret)
+	  bpf_trace_printk(time_fmt1, sizeof(time_fmt1), value_buf.enabled, value_buf.running);
+	else
+	  bpf_trace_printk(time_fmt2, sizeof(time_fmt2), ret);
+
 	val = bpf_map_lookup_elem(&counts, &key);
 	if (val)
 		(*val)++;
diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
index 7bd827b..bf4f1b6 100644
--- a/samples/bpf/trace_event_user.c
+++ b/samples/bpf/trace_event_user.c
@@ -127,6 +127,9 @@ static void test_perf_event_all_cpu(struct perf_event_attr *attr)
 	int *pmu_fd = malloc(nr_cpus * sizeof(int));
 	int i, error = 0;
 
+	/* system wide perf event, no need to inherit */
+	attr->inherit = 0;
+
 	/* open perf_event on all cpus */
 	for (i = 0; i < nr_cpus; i++) {
 		pmu_fd[i] = sys_perf_event_open(attr, -1, i, -1, 0);
@@ -154,6 +157,11 @@ static void test_perf_event_task(struct perf_event_attr *attr)
 {
 	int pmu_fd;
 
+	/* per task perf event, enable inherit so the "dd ..." command can be traced properly.
+	 * Enabling inherit will cause bpf_perf_prog_read_time helper failure.
+	 */
+	attr->inherit = 1;
+
 	/* open task bound event */
 	pmu_fd = sys_perf_event_open(attr, 0, -1, -1, 0);
 	if (pmu_fd < 0) {
@@ -175,14 +183,12 @@ static void test_bpf_perf_event(void)
 		.freq = 1,
 		.type = PERF_TYPE_HARDWARE,
 		.config = PERF_COUNT_HW_CPU_CYCLES,
-		.inherit = 1,
 	};
 	struct perf_event_attr attr_type_sw = {
 		.sample_freq = SAMPLE_FREQ,
 		.freq = 1,
 		.type = PERF_TYPE_SOFTWARE,
 		.config = PERF_COUNT_SW_CPU_CLOCK,
-		.inherit = 1,
 	};
 	struct perf_event_attr attr_hw_cache_l1d = {
 		.sample_freq = SAMPLE_FREQ,
@@ -192,7 +198,6 @@ static void test_bpf_perf_event(void)
 			PERF_COUNT_HW_CACHE_L1D |
 			(PERF_COUNT_HW_CACHE_OP_READ << 8) |
 			(PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16),
-		.inherit = 1,
 	};
 	struct perf_event_attr attr_hw_cache_branch_miss = {
 		.sample_freq = SAMPLE_FREQ,
@@ -202,7 +207,6 @@ static void test_bpf_perf_event(void)
 			PERF_COUNT_HW_CACHE_BPU |
 			(PERF_COUNT_HW_CACHE_OP_READ << 8) |
 			(PERF_COUNT_HW_CACHE_RESULT_MISS << 16),
-		.inherit = 1,
 	};
 	struct perf_event_attr attr_type_raw = {
 		.sample_freq = SAMPLE_FREQ,
@@ -210,7 +214,6 @@ static void test_bpf_perf_event(void)
 		.type = PERF_TYPE_RAW,
 		/* Intel Instruction Retired */
 		.config = 0xc0,
-		.inherit = 1,
 	};
 
 	printf("Test HW_CPU_CYCLES\n");
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index cdf6c4f..0894fd2 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -698,7 +698,8 @@ union bpf_attr {
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
 	FN(xdp_adjust_meta),		\
-	FN(perf_event_read_value),
+	FN(perf_event_read_value),	\
+	FN(perf_prog_read_value),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index c15ca83..e25dbf6 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -75,6 +75,9 @@ static int (*bpf_sock_map_update)(void *map, void *key, void *value,
 static int (*bpf_perf_event_read_value)(void *map, unsigned long long flags,
 					void *buf, unsigned int buf_size) =
 	(void *) BPF_FUNC_perf_event_read_value;
+static int (*bpf_perf_prog_read_value)(void *ctx, void *buf,
+				       unsigned int buf_size) =
+	(void *) BPF_FUNC_perf_prog_read_value;
 
 
 /* llvm builtin functions that eBPF C program may use to
-- 
2.9.5
