From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v7 4/5] bpf: add helper bpf_perf_prog_read_value
Date: Thu, 5 Oct 2017 09:19:22 -0700
Message-ID: <20171005161923.332790-5-yhs@fb.com>
References: <20171005161923.332790-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56200 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751402AbdJEQT1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:19:27 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v95GGU27016402
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 09:19:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2ddqfw0822-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 09:19:26 -0700
In-Reply-To: <20171005161923.332790-1-yhs@fb.com>
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
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h | 10 +++++++++-
 kernel/trace/bpf_trace.c | 28 ++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 93f3d1f..5dc44d1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -649,6 +649,13 @@ union bpf_attr {
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
@@ -706,7 +713,8 @@ union bpf_attr {
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
 	FN(xdp_adjust_meta),		\
-	FN(perf_event_read_value),
+	FN(perf_event_read_value),	\
+	FN(perf_prog_read_value),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 0be86cc..04ea531 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -613,6 +613,32 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_3(bpf_perf_prog_read_value_tp, struct bpf_perf_event_data_kern *, ctx,
+	   struct bpf_perf_event_value *, buf, u32, size)
+{
+	int err = -EINVAL;
+
+	if (unlikely(size != sizeof(struct bpf_perf_event_value)))
+		goto clear;
+	err = perf_event_read_local(ctx->event, &buf->counter, &buf->enabled,
+				    &buf->running);
+	if (unlikely(err))
+		goto clear;
+	return 0;
+clear:
+	memset(buf, 0, size);
+	return err;
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
@@ -620,6 +646,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
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
