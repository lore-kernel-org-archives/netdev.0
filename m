From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next 4/4] bpf: add a test case for helper bpf_perf_prog_read_time
Date: Fri, 1 Sep 2017 09:53:57 -0700
Message-ID: <20170901165357.465121-5-yhs@fb.com>
References: <20170901165357.465121-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:53989 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752292AbdIAQx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:53:59 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v81GpjL2020992
        for <netdev@vger.kernel.org>; Fri, 1 Sep 2017 09:53:59 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2cq176jkjq-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:53:59 -0700
In-Reply-To: <20170901165357.465121-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bpf sample program trace_event is enhanced to use the new
helper to print out enabled/running time.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 samples/bpf/trace_event_kern.c            | 5 +++++
 tools/testing/selftests/bpf/bpf_helpers.h | 3 +++
 2 files changed, 8 insertions(+)

diff --git a/samples/bpf/trace_event_kern.c b/samples/bpf/trace_event_kern.c
index 41b6115..f372660 100644
--- a/samples/bpf/trace_event_kern.c
+++ b/samples/bpf/trace_event_kern.c
@@ -37,8 +37,10 @@ struct bpf_map_def SEC("maps") stackmap = {
 SEC("perf_event")
 int bpf_prog1(struct bpf_perf_event_data *ctx)
 {
+	char time_fmt[] = "Time Enabled: %lld, Time Running: %lld";
 	char fmt[] = "CPU-%d period %lld ip %llx";
 	u32 cpu = bpf_get_smp_processor_id();
+	struct bpf_perf_time time_buf;
 	struct key_t key;
 	u64 *val, one = 1;
 
@@ -54,6 +56,9 @@ int bpf_prog1(struct bpf_perf_event_data *ctx)
 		return 0;
 	}
 
+	bpf_perf_prog_read_time(ctx, (void *)&time_buf, sizeof(struct bpf_perf_time));
+	bpf_trace_printk(time_fmt, sizeof(time_fmt), time_buf.enabled, time_buf.running);
+
 	val = bpf_map_lookup_elem(&counts, &key);
 	if (val)
 		(*val)++;
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index fe41852..ddad690 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -74,6 +74,9 @@ static int (*bpf_perf_read_counter_time)(void *map, unsigned long long flags,
 				       void *counter_time_buf,
 				       unsigned int buf_size) =
 	(void *) BPF_FUNC_perf_read_counter_time;
+static int (*bpf_perf_prog_read_time)(void *ctx, void *time_buf,
+				      unsigned int size) =
+	(void *) BPF_FUNC_perf_prog_read_time;
 
 
 /* llvm builtin functions that eBPF C program may use to
-- 
2.9.5
