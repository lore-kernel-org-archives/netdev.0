From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/8] bpf: register BPF_PROG_TYPE_TRACEPOINT program type
Date: Mon, 4 Apr 2016 21:52:49 -0700
Message-ID: <1459831974-2891931-4-git-send-email-ast@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58577 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754726AbcDEEw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:52:58 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u354mt0T007390
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2016 21:52:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 222xhcb93g-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 21:52:56 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 42a9f150faea11e582e40002c9dfb610-12ff93f0 for <netdev@vger.kernel.org>;	Mon,
 04 Apr 2016 21:52:55 -0700
In-Reply-To: <1459831974-2891931-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register tracepoint bpf program type and let it call the same set
of helper functions as BPF_PROG_TYPE_KPROBE

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3e4ffb3ace5f..3e5ebe3254d2 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -268,7 +268,7 @@ static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
 
-static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -295,12 +295,20 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	default:
+		return NULL;
+	}
+}
+
+static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
 		return &bpf_perf_event_output_proto;
 	case BPF_FUNC_get_stackid:
 		return &bpf_get_stackid_proto;
 	default:
-		return NULL;
+		return tracing_func_proto(func_id);
 	}
 }
 
@@ -332,9 +340,42 @@ static struct bpf_prog_type_list kprobe_tl = {
 	.type	= BPF_PROG_TYPE_KPROBE,
 };
 
+static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_perf_event_output:
+	case BPF_FUNC_get_stackid:
+		return NULL;
+	default:
+		return tracing_func_proto(func_id);
+	}
+}
+
+static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type)
+{
+	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
+		return false;
+	if (type != BPF_READ)
+		return false;
+	if (off % size != 0)
+		return false;
+	return true;
+}
+
+static const struct bpf_verifier_ops tracepoint_prog_ops = {
+	.get_func_proto  = tp_prog_func_proto,
+	.is_valid_access = tp_prog_is_valid_access,
+};
+
+static struct bpf_prog_type_list tracepoint_tl = {
+	.ops	= &tracepoint_prog_ops,
+	.type	= BPF_PROG_TYPE_TRACEPOINT,
+};
+
 static int __init register_kprobe_prog_ops(void)
 {
 	bpf_register_prog_type(&kprobe_tl);
+	bpf_register_prog_type(&tracepoint_tl);
 	return 0;
 }
 late_initcall(register_kprobe_prog_ops);
-- 
2.8.0
