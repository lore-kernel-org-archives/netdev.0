From: Yonghong Song <yhs@fb.com>
Subject: [PATCH v2 net-next 2/4] bpf: add a test case to read enabled/running time for perf array
Date: Fri, 1 Sep 2017 22:48:22 -0700
Message-ID: <20170902054824.371962-3-yhs@fb.com>
References: <20170902054824.371962-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56705 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751095AbdIBFs1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 01:48:27 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8258Hqw002578
        for <netdev@vger.kernel.org>; Fri, 1 Sep 2017 22:48:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2cqe04h6yc-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 22:48:25 -0700
In-Reply-To: <20170902054824.371962-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bpf sample program tracex6 is enhanced to use the new
helper to read enabled/running time as well.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 samples/bpf/tracex6_kern.c                | 26 ++++++++++++++++++++++++++
 samples/bpf/tracex6_user.c                | 13 ++++++++++++-
 tools/testing/selftests/bpf/bpf_helpers.h |  4 ++++
 3 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/tracex6_kern.c b/samples/bpf/tracex6_kern.c
index e7d1803..46acfef 100644
--- a/samples/bpf/tracex6_kern.c
+++ b/samples/bpf/tracex6_kern.c
@@ -15,6 +15,12 @@ struct bpf_map_def SEC("maps") values = {
 	.value_size = sizeof(u64),
 	.max_entries = 64,
 };
+struct bpf_map_def SEC("maps") values2 = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(int),
+	.value_size = sizeof(struct bpf_perf_counter_time),
+	.max_entries = 64,
+};
 
 SEC("kprobe/htab_map_get_next_key")
 int bpf_prog1(struct pt_regs *ctx)
@@ -37,5 +43,25 @@ int bpf_prog1(struct pt_regs *ctx)
 	return 0;
 }
 
+SEC("kprobe/htab_map_lookup_elem")
+int bpf_prog2(struct pt_regs *ctx)
+{
+	u32 key = bpf_get_smp_processor_id();
+	struct bpf_perf_counter_time *val, buf;
+	int error;
+
+	error = bpf_perf_read_counter_time(&counters, key, &buf, sizeof(buf));
+	if (error)
+		return 0;
+
+	val = bpf_map_lookup_elem(&values2, &key);
+	if (val)
+		*val = buf;
+	else
+		bpf_map_update_elem(&values2, &key, &buf, BPF_NOEXIST);
+
+	return 0;
+}
+
 char _license[] SEC("license") = "GPL";
 u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
index a05a99a..2a0c5d8 100644
--- a/samples/bpf/tracex6_user.c
+++ b/samples/bpf/tracex6_user.c
@@ -22,6 +22,7 @@
 
 static void check_on_cpu(int cpu, struct perf_event_attr *attr)
 {
+	struct bpf_perf_counter_time value2;
 	int pmu_fd, error = 0;
 	cpu_set_t set;
 	__u64 value;
@@ -46,8 +47,18 @@ static void check_on_cpu(int cpu, struct perf_event_attr *attr)
 		fprintf(stderr, "Value missing for CPU %d\n", cpu);
 		error = 1;
 		goto on_exit;
+	} else {
+		fprintf(stderr, "CPU %d: %llu\n", cpu, value);
+	}
+	/* The above bpf_map_lookup_elem should trigger the second kprobe */
+	if (bpf_map_lookup_elem(map_fd[2], &cpu, &value2)) {
+		fprintf(stderr, "Value2 missing for CPU %d\n", cpu);
+		error = 1;
+		goto on_exit;
+	} else {
+		fprintf(stderr, "CPU %d: counter: %llu, enabled: %llu, running: %llu\n", cpu,
+			value2.counter, value2.time.enabled, value2.time.running);
 	}
-	fprintf(stderr, "CPU %d: %llu\n", cpu, value);
 
 on_exit:
 	assert(bpf_map_delete_elem(map_fd[0], &cpu) == 0 || error);
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index 36fb916..fe41852 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -70,6 +70,10 @@ static int (*bpf_sk_redirect_map)(void *map, int key, int flags) =
 static int (*bpf_sock_map_update)(void *map, void *key, void *value,
 				  unsigned long long flags) =
 	(void *) BPF_FUNC_sock_map_update;
+static int (*bpf_perf_read_counter_time)(void *map, unsigned long long flags,
+				       void *counter_time_buf,
+				       unsigned int buf_size) =
+	(void *) BPF_FUNC_perf_read_counter_time;
 
 
 /* llvm builtin functions that eBPF C program may use to
-- 
2.9.5
