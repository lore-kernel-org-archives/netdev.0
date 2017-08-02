From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next 1/2] bpf: add support for sys_{enter|exit}_* tracepoints
Date: Tue, 1 Aug 2017 23:30:04 -0700
Message-ID: <20170802063005.3220186-2-yhs@fb.com>
References: <20170802063005.3220186-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <ast@fb.com>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58015 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751120AbdHBGaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 02:30:07 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v726R1cj011278
        for <netdev@vger.kernel.org>; Tue, 1 Aug 2017 23:30:07 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2c2rq1vnjd-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 23:30:07 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 05f17500774c11e7be680002c99331b0-4f441150 for <netdev@vger.kernel.org>;        Tue,
 01 Aug 2017 23:30:05 -0700
In-Reply-To: <20170802063005.3220186-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
style tracepoints. The iovisor/bcc issue #748
(https://github.com/iovisor/bcc/issues/748) documents this issue.
For example, if you try to attach a bpf program to tracepoints
syscalls/sys_enter_newfstat, you will get the following error:
   # ./tools/trace.py t:syscalls:sys_enter_newfstat
   Ioctl(PERF_EVENT_IOC_SET_BPF): Invalid argument
   Failed to attach BPF to tracepoint

The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
tracepoints are treated differently from other tracepoints and there
is no bpf hook to it.

This patch adds bpf support for these syscalls tracepoints by
  . permitting bpf attachment in ioctl PERF_EVENT_IOC_SET_BPF
  . calling bpf programs in perf_syscall_enter and perf_syscall_exit

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 kernel/events/core.c          |  9 +++++---
 kernel/trace/trace_syscalls.c | 53 +++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 57 insertions(+), 5 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 426c2ff..623c977 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8050,7 +8050,7 @@ static void perf_event_free_bpf_handler(struct perf_event *event)
 
 static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 {
-	bool is_kprobe, is_tracepoint;
+	bool is_cap_any, is_kprobe, is_tracepoint;
 	struct bpf_prog *prog;
 
 	if (event->attr.type != PERF_TYPE_TRACEPOINT)
@@ -8059,9 +8059,11 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	if (event->tp_event->prog)
 		return -EEXIST;
 
+	/* currently, CAP_ANY only for sys_enter_* and sys_exit_* tracepoints */
+	is_cap_any = event->tp_event->flags & TRACE_EVENT_FL_CAP_ANY;
 	is_kprobe = event->tp_event->flags & TRACE_EVENT_FL_UKPROBE;
 	is_tracepoint = event->tp_event->flags & TRACE_EVENT_FL_TRACEPOINT;
-	if (!is_kprobe && !is_tracepoint)
+	if (!is_cap_any && !is_kprobe && !is_tracepoint)
 		/* bpf programs can only be attached to u/kprobe or tracepoint */
 		return -EINVAL;
 
@@ -8070,7 +8072,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 		return PTR_ERR(prog);
 
 	if ((is_kprobe && prog->type != BPF_PROG_TYPE_KPROBE) ||
-	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
+	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT) ||
+	    (is_cap_any && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
 		/* valid fd, but invalid bpf program type */
 		bpf_prog_put(prog);
 		return -EINVAL;
diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
index 5e10395..3bd9e1c 100644
--- a/kernel/trace/trace_syscalls.c
+++ b/kernel/trace/trace_syscalls.c
@@ -559,11 +559,29 @@ static DECLARE_BITMAP(enabled_perf_exit_syscalls, NR_syscalls);
 static int sys_perf_refcount_enter;
 static int sys_perf_refcount_exit;
 
+static int perf_call_bpf_enter(struct bpf_prog *prog, struct pt_regs *regs,
+			      struct syscall_metadata *sys_data,
+			      struct syscall_trace_enter *rec) {
+	struct syscall_tp_t {
+		unsigned long long regs;
+		unsigned long syscall_nr;
+		unsigned long args[6]; /* maximum 6 arguments */
+	} param;
+	int i;
+
+	*(struct pt_regs **)&param = regs;
+	param.syscall_nr = rec->nr;
+	for (i = 0; i < sys_data->nb_args && i < 6; i++)
+		param.args[i] = rec->args[i];
+	return trace_call_bpf(prog, &param);
+}
+
 static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
 {
 	struct syscall_metadata *sys_data;
 	struct syscall_trace_enter *rec;
 	struct hlist_head *head;
+	struct bpf_prog *prog;
 	int syscall_nr;
 	int rctx;
 	int size;
@@ -578,8 +596,9 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
 	if (!sys_data)
 		return;
 
+	prog = READ_ONCE(sys_data->enter_event->prog);
 	head = this_cpu_ptr(sys_data->enter_event->perf_events);
-	if (hlist_empty(head))
+	if (!prog && hlist_empty(head))
 		return;
 
 	/* get the size after alignment with the u32 buffer size field */
@@ -594,6 +613,13 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
 	rec->nr = syscall_nr;
 	syscall_get_arguments(current, regs, 0, sys_data->nb_args,
 			       (unsigned long *)&rec->args);
+
+	if ((prog && !perf_call_bpf_enter(prog, regs, sys_data, rec)) ||
+	    hlist_empty(head)) {
+		perf_swevent_put_recursion_context(rctx);
+		return;
+	}
+
 	perf_trace_buf_submit(rec, size, rctx,
 			      sys_data->enter_event->event.type, 1, regs,
 			      head, NULL);
@@ -633,11 +659,26 @@ static void perf_sysenter_disable(struct trace_event_call *call)
 	mutex_unlock(&syscall_trace_lock);
 }
 
+static int perf_call_bpf_exit(struct bpf_prog *prog, struct pt_regs *regs,
+			      struct syscall_trace_exit *rec) {
+	struct syscall_tp_t {
+		unsigned long long regs;
+		unsigned long syscall_nr;
+		unsigned long ret;
+	} param;
+
+	*(struct pt_regs **)&param = regs;
+	param.syscall_nr = rec->nr;
+	param.ret = rec->ret;
+	return trace_call_bpf(prog, &param);
+}
+
 static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
 {
 	struct syscall_metadata *sys_data;
 	struct syscall_trace_exit *rec;
 	struct hlist_head *head;
+	struct bpf_prog *prog;
 	int syscall_nr;
 	int rctx;
 	int size;
@@ -652,8 +693,9 @@ static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
 	if (!sys_data)
 		return;
 
+	prog = READ_ONCE(sys_data->exit_event->prog);
 	head = this_cpu_ptr(sys_data->exit_event->perf_events);
-	if (hlist_empty(head))
+	if (!prog && hlist_empty(head))
 		return;
 
 	/* We can probably do that at build time */
@@ -666,6 +708,13 @@ static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
 
 	rec->nr = syscall_nr;
 	rec->ret = syscall_get_return_value(current, regs);
+
+	if ((prog && !perf_call_bpf_exit(prog, regs, rec)) ||
+	    hlist_empty(head)) {
+		perf_swevent_put_recursion_context(rctx);
+		return;
+	}
+
 	perf_trace_buf_submit(rec, size, rctx, sys_data->exit_event->event.type,
 			      1, regs, head, NULL);
 }
-- 
2.9.4
