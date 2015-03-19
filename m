From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v7 tip 2/8] tracing: attach BPF programs to kprobes
Date: Thu, 19 Mar 2015 11:07:42 -0400
Message-ID: <20150319110742.7dc9473d@gandalf.local.home>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>
	<1426542584-9406-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426542584-9406-3-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Mar 2015 14:49:38 -0700
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> User interface:
> struct perf_event_attr attr = {.type = PERF_TYPE_TRACEPOINT, .config = event_id, ...};
> event_fd = perf_event_open(&attr,...);
> ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);
> 
> prog_fd is a file descriptor associated with BPF program previously loaded.
> event_id is an ID of created kprobe
> 
> close(event_fd) - automatically detaches BPF program from it
> 
> BPF programs can call in-kernel helper functions to:
> - lookup/update/delete elements in maps
> - probe_read - wraper of probe_kernel_read() used to access any kernel
>   data structures
> 
> BPF programs receive 'struct pt_regs *' as an input
> ('struct pt_regs' is architecture dependent)
> 
> Note, kprobes are _not_ a stable kernel ABI, so bpf programs attached to
> kprobes must be recompiled for every kernel version and user must supply correct
> LINUX_VERSION_CODE in attr.kern_version during bpf_prog_load() call.
> 
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> ---
>  include/linux/ftrace_event.h    |   14 +++++
>  include/uapi/linux/bpf.h        |    3 +
>  include/uapi/linux/perf_event.h |    1 +
>  kernel/bpf/syscall.c            |    7 ++-
>  kernel/events/core.c            |   59 +++++++++++++++++++
>  kernel/trace/Makefile           |    1 +
>  kernel/trace/bpf_trace.c        |  119 +++++++++++++++++++++++++++++++++++++++
>  kernel/trace/trace_kprobe.c     |   10 +++-
>  8 files changed, 212 insertions(+), 2 deletions(-)
>  create mode 100644 kernel/trace/bpf_trace.c
> 
> diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
> index c674ee8f7fca..0aa535bc9f05 100644
> --- a/include/linux/ftrace_event.h
> +++ b/include/linux/ftrace_event.h
> @@ -13,6 +13,7 @@ struct trace_array;
>  struct trace_buffer;
>  struct tracer;
>  struct dentry;
> +struct bpf_prog;
>  
>  struct trace_print_flags {
>  	unsigned long		mask;
> @@ -252,6 +253,7 @@ enum {
>  	TRACE_EVENT_FL_WAS_ENABLED_BIT,
>  	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
>  	TRACE_EVENT_FL_TRACEPOINT_BIT,
> +	TRACE_EVENT_FL_KPROBE_BIT,

I think this should be broken up into two patches. One that adds the
KPROBE_BIT flag to kprobe events, and the other that adds the bpf
program.

>  };
>  
>  /*
> @@ -265,6 +267,7 @@ enum {
>   *                     it is best to clear the buffers that used it).
>   *  USE_CALL_FILTER - For ftrace internal events, don't use file filter
>   *  TRACEPOINT    - Event is a tracepoint
> + *  KPROBE        - Event is a kprobe
>   */
>  enum {
>  	TRACE_EVENT_FL_FILTERED		= (1 << TRACE_EVENT_FL_FILTERED_BIT),
> @@ -274,6 +277,7 @@ enum {
>  	TRACE_EVENT_FL_WAS_ENABLED	= (1 << TRACE_EVENT_FL_WAS_ENABLED_BIT),
>  	TRACE_EVENT_FL_USE_CALL_FILTER	= (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
>  	TRACE_EVENT_FL_TRACEPOINT	= (1 << TRACE_EVENT_FL_TRACEPOINT_BIT),
> +	TRACE_EVENT_FL_KPROBE		= (1 << TRACE_EVENT_FL_KPROBE_BIT),
>  };
>  
>  struct ftrace_event_call {
> @@ -303,6 +307,7 @@ struct ftrace_event_call {
>  #ifdef CONFIG_PERF_EVENTS
>  	int				perf_refcount;
>  	struct hlist_head __percpu	*perf_events;
> +	struct bpf_prog			*prog;
>  
>  	int	(*perf_perm)(struct ftrace_event_call *,
>  			     struct perf_event *);
> @@ -548,6 +553,15 @@ event_trigger_unlock_commit_regs(struct ftrace_event_file *file,
>  		event_triggers_post_call(file, tt);
>  }
>  



> --- /dev/null
> +++ b/kernel/trace/bpf_trace.c
> @@ -0,0 +1,119 @@
> +/* Copyright (c) 2011-2015 PLUMgrid, http://plumgrid.com
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/slab.h>
> +#include <linux/bpf.h>
> +#include <linux/filter.h>
> +#include <linux/uaccess.h>
> +#include "trace.h"
> +
> +static DEFINE_PER_CPU(int, bpf_prog_active);
> +

There should be kerneldoc comments above this function.

> +unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
> +{
> +	unsigned int ret;
> +	int cpu;
> +
> +	if (in_nmi()) /* not supported yet */
> +		return 1;
> +
> +	preempt_disable();
> +
> +	cpu = raw_smp_processor_id();

Perhaps remove the above two lines and replace with:

	cpu = get_cpu();

> +	if (unlikely(per_cpu(bpf_prog_active, cpu)++ != 0)) {
> +		/* since some bpf program is already running on this cpu,
> +		 * don't call into another bpf program (same or different)
> +		 * and don't send kprobe event into ring-buffer,
> +		 * so return zero here
> +		 */
> +		ret = 0;
> +		goto out;
> +	}
> +
> +	rcu_read_lock();
> +	ret = BPF_PROG_RUN(prog, ctx);
> +	rcu_read_unlock();
> +
> + out:
> +	per_cpu(bpf_prog_active, cpu)--;

Hmm, as cpu == smp_processor_id(), you should be using
__this_cpu_inc_return(), and __this_cpu_dec().

> +	preempt_enable();

	put_cpu();


If you replace the above with __this_cpu*, then you could use
preempt_enable/disable() and get rid of the "cpu" var.

> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(trace_call_bpf);
> +
> +static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	void *dst = (void *) (long) r1;
> +	int size = (int) r2;
> +	void *unsafe_ptr = (void *) (long) r3;
> +
> +	return probe_kernel_read(dst, unsafe_ptr, size);
> +}
> +
> +static struct bpf_func_proto kprobe_prog_funcs[] = {
> +	[BPF_FUNC_probe_read] = {
> +		.func = bpf_probe_read,
> +		.gpl_only = true,
> +		.ret_type = RET_INTEGER,
> +		.arg1_type = ARG_PTR_TO_STACK,
> +		.arg2_type = ARG_CONST_STACK_SIZE,
> +		.arg3_type = ARG_ANYTHING,
> +	},
> +};
> +
> +static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
> +{
> +	switch (func_id) {
> +	case BPF_FUNC_map_lookup_elem:
> +		return &bpf_map_lookup_elem_proto;
> +	case BPF_FUNC_map_update_elem:
> +		return &bpf_map_update_elem_proto;
> +	case BPF_FUNC_map_delete_elem:
> +		return &bpf_map_delete_elem_proto;
> +	default:
> +		if (func_id < 0 || func_id >= ARRAY_SIZE(kprobe_prog_funcs))
> +			return NULL;
> +		return &kprobe_prog_funcs[func_id];
> +	}
> +}

Why not just make kprobe_prog_funcs[] = {
	[BPF_FUNC_map_lookup_elem] = &bpf_map_lookup_elem_proto,
	[BPF_FUNC_map_update_elem] = &bpf_map_update_elem_proto,
	[BPF_FUNC_map_delete_elem] = &bpf_map_delete_elem_proto,
	[BPF_FUNC_probe_read] = &kprobe_prog_proto,

And define kprobe_prog_proto separately.

And then you don't need the switch statement, you could just use the
if (func_id < 0 || func_id >= ARRAY_SIZE(kprobe_prog_funcs))
	return kprobe_prog_funcs[func_id];

I think there's several advantages to my approach. One, is that you are
not wasting memory with empty objects in the array. Also, if the array
gets out of sync with the enum, it would be possible to return an empty
object. That is, &kprobe_prog_funcs[out_of_sync_func_id], would not be
NULL if in the future someone added an enum before BPF_FUNC_probe_read,
and the func_id passed in is that enum.


> +
> +/* bpf+kprobe programs can access fields of 'struct pt_regs' */
> +static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type)
> +{
> +	/* check bounds */
> +	if (off < 0 || off >= sizeof(struct pt_regs))
> +		return false;
> +
> +	/* only read is allowed */
> +	if (type != BPF_READ)
> +		return false;
> +
> +	/* disallow misaligned access */
> +	if (off % size != 0)
> +		return false;
> +
> +	return true;
> +}
> +
> +static struct bpf_verifier_ops kprobe_prog_ops = {
> +	.get_func_proto = kprobe_prog_func_proto,
> +	.is_valid_access = kprobe_prog_is_valid_access,
> +};
> +
> +static struct bpf_prog_type_list kprobe_tl = {
> +	.ops = &kprobe_prog_ops,
> +	.type = BPF_PROG_TYPE_KPROBE,
> +};
> +
> +static int __init register_kprobe_prog_ops(void)
> +{
> +	bpf_register_prog_type(&kprobe_tl);
> +	return 0;
> +}
> +late_initcall(register_kprobe_prog_ops);
> diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
> index d73f565b4e06..dc3462507d7c 100644
> --- a/kernel/trace/trace_kprobe.c
> +++ b/kernel/trace/trace_kprobe.c
> @@ -1134,11 +1134,15 @@ static void
>  kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
>  {
>  	struct ftrace_event_call *call = &tk->tp.call;
> +	struct bpf_prog *prog = call->prog;
>  	struct kprobe_trace_entry_head *entry;
>  	struct hlist_head *head;
>  	int size, __size, dsize;
>  	int rctx;
>  
> +	if (prog && !trace_call_bpf(prog, regs))
> +		return;
> +
>  	head = this_cpu_ptr(call->perf_events);
>  	if (hlist_empty(head))
>  		return;
> @@ -1165,11 +1169,15 @@ kretprobe_perf_func(struct trace_kprobe *tk, struct kretprobe_instance *ri,
>  		    struct pt_regs *regs)
>  {
>  	struct ftrace_event_call *call = &tk->tp.call;
> +	struct bpf_prog *prog = call->prog;
>  	struct kretprobe_trace_entry_head *entry;
>  	struct hlist_head *head;
>  	int size, __size, dsize;
>  	int rctx;
>  
> +	if (prog && !trace_call_bpf(prog, regs))
> +		return;
> +
>  	head = this_cpu_ptr(call->perf_events);
>  	if (hlist_empty(head))
>  		return;
> @@ -1286,7 +1294,7 @@ static int register_kprobe_event(struct trace_kprobe *tk)
>  		kfree(call->print_fmt);
>  		return -ENODEV;
>  	}
> -	call->flags = 0;
> +	call->flags = TRACE_EVENT_FL_KPROBE;

Again, split out the adding of TRACE_EVENT_FL_KPROBE into a separate
patch.

-- Steve

>  	call->class->reg = kprobe_register;
>  	call->data = tk;
>  	ret = trace_add_event_call(call);
