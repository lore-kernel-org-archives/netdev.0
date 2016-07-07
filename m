From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: introduce bpf_get_current_task() helper
Date: Wed, 6 Jul 2016 22:38:36 -0700
Message-ID: <1467869916-2313494-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40091 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750776AbcGGFij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:38:39 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u675b2Er011804
	for <netdev@vger.kernel.org>; Wed, 6 Jul 2016 22:38:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 241c909gbg-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 22:38:39 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 0d705d6c440511e69be10002c992ebde-10ffbaf0 for <netdev@vger.kernel.org>;	Wed,
 06 Jul 2016 22:38:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

over time there were multiple requests to access different data
structures and fields of task_struct current, so finally add
the helper to access 'current' as-is. Tracing bpf programs will do
the rest of walking the pointers via bpf_probe_read().
Note that current can be null and bpf program has to deal it with,
but even dumb passing null into bpf_probe_read() is still safe.

Suggested-by: Brendan Gregg <brendan.d.gregg@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
requests for different helpers that can be addressed by walking 'current':
https://github.com/iovisor/bcc/issues/220
https://github.com/iovisor/bcc/issues/237
https://github.com/iovisor/bcc/issues/364
---
 include/uapi/linux/bpf.h |  7 +++++++
 kernel/trace/bpf_trace.c | 13 +++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index c14ca1cd6297..262a7e883b19 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -357,6 +357,13 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_get_hash_recalc,
 
+	/**
+	 * u64 bpf_get_current_task(void)
+	 * Returns current task_struct
+	 * Return: current
+	 */
+	BPF_FUNC_get_current_task,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 19c5b4a5c3eb..094c716154ed 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -312,6 +312,17 @@ const struct bpf_func_proto *bpf_get_event_output_proto(void)
 	return &bpf_event_output_proto;
 }
 
+static u64 bpf_get_current_task(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return (long) current;
+}
+
+static const struct bpf_func_proto bpf_get_current_task_proto = {
+	.func		= bpf_get_current_task,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+};
+
 static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -329,6 +340,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_tail_call_proto;
 	case BPF_FUNC_get_current_pid_tgid:
 		return &bpf_get_current_pid_tgid_proto;
+	case BPF_FUNC_get_current_task:
+		return &bpf_get_current_task_proto;
 	case BPF_FUNC_get_current_uid_gid:
 		return &bpf_get_current_uid_gid_proto;
 	case BPF_FUNC_get_current_comm:
-- 
2.8.0
