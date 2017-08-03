From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v3 1/2] bpf: add support for sys_enter_* and sys_exit_* tracepoints
Date: Thu, 3 Aug 2017 09:29:50 -0700
Message-ID: <20170803162951.1564963-2-yhs@fb.com>
References: <20170803162951.1564963-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38833 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751234AbdHCQ3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:29:55 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v73GT2NE031302
        for <netdev@vger.kernel.org>; Thu, 3 Aug 2017 09:29:54 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2c40y29sm8-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 09:29:54 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 f997d056786811e787480002c99293a0-582e1150 for <netdev@vger.kernel.org>;        Thu,
 03 Aug 2017 09:29:51 -0700
In-Reply-To: <20170803162951.1564963-1-yhs@fb.com>
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
 include/linux/syscalls.h      | 12 ++++++++++
 kernel/events/core.c          |  8 ++++---
 kernel/trace/trace_syscalls.c | 53 +++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 68 insertions(+), 5 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3cb15ea..c917021 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -172,8 +172,20 @@ extern struct trace_event_functions exit_syscall_print_funcs;
 	static struct syscall_metadata __used			\
 	  __attribute__((section("__syscalls_metadata")))	\
 	 *__p_syscall_meta_##sname = &__syscall_meta_##sname;
+
+static inline int is_syscall_trace_event(struct trace_event_call *tp_event)
+{
+	return tp_event->class == &event_class_syscall_enter ||
+	       tp_event->class == &event_class_syscall_exit;
+}
+
 #else
 #define SYSCALL_METADATA(sname, nb, ...)
+
+static inline int is_syscall_trace_event(struct trace_event_call *tp_event)
+{
+	return 0;
+}
 #endif
 
 #define SYSCALL_DEFINE0(sname)					\
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 426c2ff..750b8d3 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8050,7 +8050,7 @@ static void perf_event_free_bpf_handler(struct perf_event *event)
 
 static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 {
-	bool is_kprobe, is_tracepoint;
+	bool is_kprobe, is_tracepoint, is_syscall_tp;
 	struct bpf_prog *prog;
 
 	if (event->attr.type != PERF_TYPE_TRACEPOINT)
@@ -8061,7 +8061,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 
 	is_kprobe = event->tp_event->flags & TRACE_EVENT_FL_UKPROBE;
 	is_tracepoint = event->tp_event->flags & TRACE_EVENT_FL_TRACEPOINT;
-	if (!is_kprobe && !is_tracepoint)
+	is_syscall_tp = is_syscall_trace_event(event->tp_event);
+	if (!is_kprobe && !is_tracepoint && !is_syscall_tp)
 		/* bpf programs can only be attached to u/kprobe or tracepoint */
 		return -EINVAL;
 
@@ -8070,7 +8071,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 		return PTR_ERR(prog);
 
 	if ((is_kprobe && prog->type != BPF_PROG_TYPE_KPROBE) ||
-	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
+	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT) ||
+	    (is_syscall_tp && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
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
