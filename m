From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 06/10] bpf: support bpf_get_stackid() and bpf_perf_event_output() in tracepoint programs
Date: Wed, 6 Apr 2016 18:43:27 -0700
Message-ID: <1459993411-2754735-7-git-send-email-ast@fb.com>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34300 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbcDGBnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 21:43:37 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u371gJbY025463
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 18:43:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2259grh0ny-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 18:43:36 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 240a2f34fc6211e5899324be0593f280-279da3f0 for <netdev@vger.kernel.org>;	Wed,
 06 Apr 2016 18:43:34 -0700
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

needs two wrapper functions to fetch 'struct pt_regs *' to convert
tracepoint bpf context into kprobe bpf context to reuse existing
helper functions

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  1 +
 kernel/bpf/stackmap.c    |  2 +-
 kernel/trace/bpf_trace.c | 42 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 21ee41b92e8a..198f6ace70ec 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -160,6 +160,7 @@ struct bpf_array {
 #define MAX_TAIL_CALL_CNT 32
 
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
+u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 void bpf_fd_array_map_clear(struct bpf_map *map);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 499d9e933f8e..35114725cf30 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -116,7 +116,7 @@ free_smap:
 	return ERR_PTR(err);
 }
 
-static u64 bpf_get_stackid(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
+u64 bpf_get_stackid(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
 {
 	struct pt_regs *regs = (struct pt_regs *) (long) r1;
 	struct bpf_map *map = (struct bpf_map *) (long) r2;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3e5ebe3254d2..413ec5614180 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -340,12 +340,52 @@ static struct bpf_prog_type_list kprobe_tl = {
 	.type	= BPF_PROG_TYPE_KPROBE,
 };
 
+static u64 bpf_perf_event_output_tp(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
+{
+	/*
+	 * r1 points to perf tracepoint buffer where first 8 bytes are hidden
+	 * from bpf program and contain a pointer to 'struct pt_regs'. Fetch it
+	 * from there and call the same bpf_perf_event_output() helper
+	 */
+	u64 ctx = *(long *)r1;
+
+	return bpf_perf_event_output(ctx, r2, index, r4, size);
+}
+
+static const struct bpf_func_proto bpf_perf_event_output_proto_tp = {
+	.func		= bpf_perf_event_output_tp,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STACK,
+	.arg5_type	= ARG_CONST_STACK_SIZE,
+};
+
+static u64 bpf_get_stackid_tp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	u64 ctx = *(long *)r1;
+
+	return bpf_get_stackid(ctx, r2, r3, r4, r5);
+}
+
+static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
+	.func		= bpf_get_stackid_tp,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
+		return &bpf_perf_event_output_proto_tp;
 	case BPF_FUNC_get_stackid:
-		return NULL;
+		return &bpf_get_stackid_proto_tp;
 	default:
 		return tracing_func_proto(func_id);
 	}
-- 
2.8.0
