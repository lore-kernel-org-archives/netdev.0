From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next v2 1/2] bpf: add support for sys_enter_* and
 sys_exit_* tracepoints
Date: Thu, 3 Aug 2017 10:08:31 +0200
Message-ID: <20170803080831.6molm6xv6wngcy7l@hirez.programming.kicks-ass.net>
References: <20170803052828.2303723-1-yhs@fb.com>
 <20170803052828.2303723-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-team@fb.com, Steven Rostedt <rostedt@goodmis.org>
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:36647 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbdHCIIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 04:08:41 -0400
Content-Disposition: inline
In-Reply-To: <20170803052828.2303723-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 02, 2017 at 10:28:27PM -0700, Yonghong Song wrote:
> Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
> style tracepoints. The iovisor/bcc issue #748
> (https://github.com/iovisor/bcc/issues/748) documents this issue.
> For example, if you try to attach a bpf program to tracepoints
> syscalls/sys_enter_newfstat, you will get the following error:
>    # ./tools/trace.py t:syscalls:sys_enter_newfstat
>    Ioctl(PERF_EVENT_IOC_SET_BPF): Invalid argument
>    Failed to attach BPF to tracepoint
> 
> The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
> tracepoints are treated differently from other tracepoints and there
> is no bpf hook to it.
> 
> This patch adds bpf support for these syscalls tracepoints by
>   . permitting bpf attachment in ioctl PERF_EVENT_IOC_SET_BPF
>   . calling bpf programs in perf_syscall_enter and perf_syscall_exit
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>

Ack for the perf bits, but you should've Cc'ed steve too I suppose.

> ---
>  include/linux/syscalls.h      |  6 +++++
>  kernel/events/core.c          |  8 ++++---
>  kernel/trace/trace_syscalls.c | 53 +++++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 62 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 3cb15ea..00fa3eb 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -117,6 +117,12 @@ extern struct trace_event_class event_class_syscall_exit;
>  extern struct trace_event_functions enter_syscall_print_funcs;
>  extern struct trace_event_functions exit_syscall_print_funcs;
>  
> +static inline int is_syscall_trace_event(struct trace_event_call *tp_event)
> +{
> +	return tp_event->class == &event_class_syscall_enter ||
> +	       tp_event->class == &event_class_syscall_exit;
> +}
> +
>  #define SYSCALL_TRACE_ENTER_EVENT(sname)				\
>  	static struct syscall_metadata __syscall_meta_##sname;		\
>  	static struct trace_event_call __used				\
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 426c2ff..750b8d3 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -8050,7 +8050,7 @@ static void perf_event_free_bpf_handler(struct perf_event *event)
>  
>  static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  {
> -	bool is_kprobe, is_tracepoint;
> +	bool is_kprobe, is_tracepoint, is_syscall_tp;
>  	struct bpf_prog *prog;
>  
>  	if (event->attr.type != PERF_TYPE_TRACEPOINT)
> @@ -8061,7 +8061,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  
>  	is_kprobe = event->tp_event->flags & TRACE_EVENT_FL_UKPROBE;
>  	is_tracepoint = event->tp_event->flags & TRACE_EVENT_FL_TRACEPOINT;
> -	if (!is_kprobe && !is_tracepoint)
> +	is_syscall_tp = is_syscall_trace_event(event->tp_event);
> +	if (!is_kprobe && !is_tracepoint && !is_syscall_tp)
>  		/* bpf programs can only be attached to u/kprobe or tracepoint */
>  		return -EINVAL;
>  
> @@ -8070,7 +8071,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  		return PTR_ERR(prog);
>  
>  	if ((is_kprobe && prog->type != BPF_PROG_TYPE_KPROBE) ||
> -	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
> +	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT) ||
> +	    (is_syscall_tp && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
>  		/* valid fd, but invalid bpf program type */
>  		bpf_prog_put(prog);
>  		return -EINVAL;
> diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
> index 5e10395..3bd9e1c 100644
> --- a/kernel/trace/trace_syscalls.c
> +++ b/kernel/trace/trace_syscalls.c
> @@ -559,11 +559,29 @@ static DECLARE_BITMAP(enabled_perf_exit_syscalls, NR_syscalls);
>  static int sys_perf_refcount_enter;
>  static int sys_perf_refcount_exit;
>  
> +static int perf_call_bpf_enter(struct bpf_prog *prog, struct pt_regs *regs,
> +			      struct syscall_metadata *sys_data,
> +			      struct syscall_trace_enter *rec) {
> +	struct syscall_tp_t {
> +		unsigned long long regs;
> +		unsigned long syscall_nr;
> +		unsigned long args[6]; /* maximum 6 arguments */
> +	} param;
> +	int i;
> +
> +	*(struct pt_regs **)&param = regs;
> +	param.syscall_nr = rec->nr;
> +	for (i = 0; i < sys_data->nb_args && i < 6; i++)
> +		param.args[i] = rec->args[i];
> +	return trace_call_bpf(prog, &param);
> +}
> +
>  static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
>  {
>  	struct syscall_metadata *sys_data;
>  	struct syscall_trace_enter *rec;
>  	struct hlist_head *head;
> +	struct bpf_prog *prog;
>  	int syscall_nr;
>  	int rctx;
>  	int size;
> @@ -578,8 +596,9 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
>  	if (!sys_data)
>  		return;
>  
> +	prog = READ_ONCE(sys_data->enter_event->prog);
>  	head = this_cpu_ptr(sys_data->enter_event->perf_events);
> -	if (hlist_empty(head))
> +	if (!prog && hlist_empty(head))
>  		return;
>  
>  	/* get the size after alignment with the u32 buffer size field */
> @@ -594,6 +613,13 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
>  	rec->nr = syscall_nr;
>  	syscall_get_arguments(current, regs, 0, sys_data->nb_args,
>  			       (unsigned long *)&rec->args);
> +
> +	if ((prog && !perf_call_bpf_enter(prog, regs, sys_data, rec)) ||
> +	    hlist_empty(head)) {
> +		perf_swevent_put_recursion_context(rctx);
> +		return;
> +	}
> +
>  	perf_trace_buf_submit(rec, size, rctx,
>  			      sys_data->enter_event->event.type, 1, regs,
>  			      head, NULL);
> @@ -633,11 +659,26 @@ static void perf_sysenter_disable(struct trace_event_call *call)
>  	mutex_unlock(&syscall_trace_lock);
>  }
>  
> +static int perf_call_bpf_exit(struct bpf_prog *prog, struct pt_regs *regs,
> +			      struct syscall_trace_exit *rec) {
> +	struct syscall_tp_t {
> +		unsigned long long regs;
> +		unsigned long syscall_nr;
> +		unsigned long ret;
> +	} param;
> +
> +	*(struct pt_regs **)&param = regs;
> +	param.syscall_nr = rec->nr;
> +	param.ret = rec->ret;
> +	return trace_call_bpf(prog, &param);
> +}
> +
>  static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
>  {
>  	struct syscall_metadata *sys_data;
>  	struct syscall_trace_exit *rec;
>  	struct hlist_head *head;
> +	struct bpf_prog *prog;
>  	int syscall_nr;
>  	int rctx;
>  	int size;
> @@ -652,8 +693,9 @@ static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
>  	if (!sys_data)
>  		return;
>  
> +	prog = READ_ONCE(sys_data->exit_event->prog);
>  	head = this_cpu_ptr(sys_data->exit_event->perf_events);
> -	if (hlist_empty(head))
> +	if (!prog && hlist_empty(head))
>  		return;
>  
>  	/* We can probably do that at build time */
> @@ -666,6 +708,13 @@ static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
>  
>  	rec->nr = syscall_nr;
>  	rec->ret = syscall_get_return_value(current, regs);
> +
> +	if ((prog && !perf_call_bpf_exit(prog, regs, rec)) ||
> +	    hlist_empty(head)) {
> +		perf_swevent_put_recursion_context(rctx);
> +		return;
> +	}
> +
>  	perf_trace_buf_submit(rec, size, rctx, sys_data->exit_event->event.type,
>  			      1, regs, head, NULL);
>  }
> -- 
> 2.9.4
> 
