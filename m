From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v6 3/4] bpf: add helper bpf_perf_prog_read_value
Date: Mon, 2 Oct 2017 15:42:17 -0700
Message-ID: <20171002224218.3181418-4-yhs@fb.com>
References: <20171002224218.3181418-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38568 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750770AbdJBWmW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 18:42:22 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v92MfjwZ024219
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 15:42:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2dbvgsrk2j-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 15:42:21 -0700
In-Reply-To: <20171002224218.3181418-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds helper bpf_perf_prog_read_cvalue for perf event based bpf
programs, to read event counter and enabled/running time.
The enabled/running time is accumulated since the perf event open.

The typical use case for perf event based bpf program is to attach itself
to a single event. In such cases, if it is desirable to get scaling factor
between two bpf invocations, users can can save the time values in a map,
and use the value from the map and the current value to calculate
the scaling factor.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 include/linux/perf_event.h |  1 +
 include/uapi/linux/bpf.h   | 10 +++++++++-
 kernel/events/core.c       |  1 +
 kernel/trace/bpf_trace.c   | 28 ++++++++++++++++++++++++++++
 4 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 21d8c12..79b18a2 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -806,6 +806,7 @@ struct perf_output_handle {
 struct bpf_perf_event_data_kern {
 	struct pt_regs *regs;
 	struct perf_sample_data *data;
+	struct perf_event *event;
 };
 
 #ifdef CONFIG_CGROUP_PERF
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4bdd4b2..6f6a236 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -599,6 +599,13 @@ union bpf_attr {
  *     @buf: buf to fill
  *     @buf_size: size of the buf
  *     Return: 0 on success or negative error code
+ *
+ * int bpf_perf_prog_read_value(ctx, buf, buf_size)
+ *     read perf prog attached perf event counter and enabled/running time
+ *     @ctx: pointer to ctx
+ *     @buf: buf to fill
+ *     @buf_size: size of the buf
+ *     Return : 0 on success or negative error code
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -656,7 +663,8 @@ union bpf_attr {
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
 	FN(xdp_adjust_meta),		\
-	FN(perf_event_read_value),
+	FN(perf_event_read_value),	\
+	FN(perf_prog_read_value),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/events/core.c b/kernel/events/core.c
index c761ef4..d1efac2 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8081,6 +8081,7 @@ static void bpf_overflow_handler(struct perf_event *event,
 	struct bpf_perf_event_data_kern ctx = {
 		.data = data,
 		.regs = regs,
+		.event = event,
 	};
 	int ret = 0;
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 686dfa1..c4d617a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -612,6 +612,32 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_3(bpf_perf_prog_read_value_tp, struct bpf_perf_event_data_kern *, ctx,
+	   struct bpf_perf_event_value *, buf, u32, size)
+{
+	int err;
+
+	if (unlikely(size != sizeof(struct bpf_perf_event_value)))
+		return -EINVAL;
+
+	err = perf_event_read_local(ctx->event, &buf->counter, &buf->enabled,
+				    &buf->running);
+	if (unlikely(err)) {
+		memset(buf, 0, size);
+		return err;
+	}
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_perf_prog_read_value_proto_tp = {
+         .func           = bpf_perf_prog_read_value_tp,
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
@@ -619,6 +645,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 		return &bpf_perf_event_output_proto_tp;
 	case BPF_FUNC_get_stackid:
 		return &bpf_get_stackid_proto_tp;
+	case BPF_FUNC_perf_prog_read_value:
+		return &bpf_perf_prog_read_value_proto_tp;
 	default:
 		return tracing_func_proto(func_id);
 	}
-- 
2.9.5
