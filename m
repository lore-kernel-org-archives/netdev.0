From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next 3/4] bpf: add helper bpf_perf_prog_read_time
Date: Fri, 1 Sep 2017 09:53:56 -0700
Message-ID: <20170901165357.465121-4-yhs@fb.com>
References: <20170901165357.465121-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54168 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752302AbdIAQyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:54:00 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v81GnENU014110
        for <netdev@vger.kernel.org>; Fri, 1 Sep 2017 09:54:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2cqabj0c2t-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:53:59 -0700
In-Reply-To: <20170901165357.465121-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds helper bpf_perf_prog_read_time for perf event based bpf
programs, to read event enabled/running time.
The enabled/running time is accumulated since the perf event open.

The typical use case for perf event based bpf program is to attach itself
to a single event. In such cases, if it is desirable to get scaling factor
between two bpf invocations, users can can save the time values in a map,
and use the value from the map and the current value to calculate
the scaling factor.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 include/linux/perf_event.h |  1 +
 include/uapi/linux/bpf.h   |  8 ++++++++
 kernel/events/core.c       |  1 +
 kernel/trace/bpf_trace.c   | 24 ++++++++++++++++++++++++
 4 files changed, 34 insertions(+)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 7fd5e94..92955fc 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -821,6 +821,7 @@ struct perf_output_handle {
 struct bpf_perf_event_data_kern {
 	struct pt_regs *regs;
 	struct perf_sample_data *data;
+	struct perf_event *event;
 };
 
 #ifdef CONFIG_CGROUP_PERF
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 9c23bef..1ae55c8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -590,6 +590,13 @@ union bpf_attr {
  *     @counter_time_buf: buf to fill
  *     @buf_size: size of the counter_time_buf
  *     Return: 0 on success or negative error code
+ *
+ * int bpf_perf_prog_read_time(ctx, time_buf, buf_size)
+ *     Read perf event enabled and running time
+ *     @ctx: pointer to ctx
+ *     @time_buf: buf to fill
+ *     @buf_size: size of the time_buf
+ *     Return : 0 on success or negative error code
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -647,6 +654,7 @@ union bpf_attr {
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
 	FN(perf_read_counter_time),		\
+	FN(perf_prog_read_time),		\
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/events/core.c b/kernel/events/core.c
index ef5c7fb..1f16f1f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8019,6 +8019,7 @@ static void bpf_overflow_handler(struct perf_event *event,
 	struct bpf_perf_event_data_kern ctx = {
 		.data = data,
 		.regs = regs,
+		.event = event,
 	};
 	int ret = 0;
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index b807b1a..e97620a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -608,6 +608,19 @@ BPF_CALL_3(bpf_get_stackid_tp, void *, tp_buff, struct bpf_map *, map,
 			       flags, 0, 0);
 }
 
+BPF_CALL_3(bpf_perf_prog_read_time_tp, void *, ctx, struct bpf_perf_time *,
+	time_buf, u32, size)
+{
+	struct bpf_perf_event_data_kern *kctx = (struct bpf_perf_event_data_kern *)ctx;
+	u64 now;
+
+	if (size != sizeof(struct bpf_perf_time))
+		return -EINVAL;
+
+	calc_timer_values(kctx->event, &now, &time_buf->enabled, &time_buf->running);
+	return 0;
+}
+
 static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.func		= bpf_get_stackid_tp,
 	.gpl_only	= true,
@@ -617,6 +630,15 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static const struct bpf_func_proto bpf_perf_prog_read_time_proto_tp = {
+         .func           = bpf_perf_prog_read_time_tp,
+         .gpl_only       = true,
+         .ret_type       = RET_INTEGER,
+         .arg1_type      = ARG_PTR_TO_CTX,
+         .arg2_type      = ARG_PTR_TO_UNINIT_MEM,
+         .arg3_type      = ARG_CONST_SIZE,
+};
+
 static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -624,6 +646,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 		return &bpf_perf_event_output_proto_tp;
 	case BPF_FUNC_get_stackid:
 		return &bpf_get_stackid_proto_tp;
+	case BPF_FUNC_perf_prog_read_time:
+		return &bpf_perf_prog_read_time_proto_tp;
 	default:
 		return tracing_func_proto(func_id);
 	}
-- 
2.9.5
