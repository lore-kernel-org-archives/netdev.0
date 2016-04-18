From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next 2/8] perf, bpf: allow bpf programs attach to
 tracepoints
Date: Mon, 18 Apr 2016 16:29:05 -0400
Message-ID: <20160418162905.220df2f4@gandalf.local.home>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
	<1459831974-2891931-3-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459831974-2891931-3-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 4 Apr 2016 21:52:48 -0700
Alexei Starovoitov <ast@fb.com> wrote:

> introduce BPF_PROG_TYPE_TRACEPOINT program type and allow it to be
> attached to tracepoints.
> The tracepoint will copy the arguments in the per-cpu buffer and pass
> it to the bpf program as its first argument.
> The layout of the fields can be discovered by doing
> 'cat /sys/kernel/debug/tracing/events/sched/sched_switch/format'
> prior to the compilation of the program with exception that first 8 bytes
> are reserved and not accessible to the program. This area is used to store
> the pointer to 'struct pt_regs' which some of the bpf helpers will use:
> +---------+
> | 8 bytes | hidden 'struct pt_regs *' (inaccessible to bpf program)
> +---------+
> | N bytes | static tracepoint fields defined in tracepoint/format (bpf readonly)
> +---------+
> | dynamic | __dynamic_array bytes of tracepoint (inaccessible to bpf yet)
> +---------+
> 
> Not that all of the fields are already dumped to user space via perf ring buffer
> and some application access it directly without consulting tracepoint/format.
> Same rule applies here: static tracepoint fields should only be accessed
> in a format defined in tracepoint/format. The order of fields and
> field sizes are not an ABI.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  include/trace/perf.h            | 18 ++++++++++++++----
>  include/uapi/linux/bpf.h        |  1 +
>  kernel/events/core.c            | 13 +++++++++----
>  kernel/trace/trace_event_perf.c |  3 +++
>  4 files changed, 27 insertions(+), 8 deletions(-)
> 
> diff --git a/include/trace/perf.h b/include/trace/perf.h
> index 26486fcd74ce..55feb69c873f 100644
> --- a/include/trace/perf.h
> +++ b/include/trace/perf.h
> @@ -37,18 +37,19 @@ perf_trace_##call(void *__data, proto)					\
>  	struct trace_event_call *event_call = __data;			\
>  	struct trace_event_data_offsets_##call __maybe_unused __data_offsets;\
>  	struct trace_event_raw_##call *entry;				\
> +	struct bpf_prog *prog = event_call->prog;			\
>  	struct pt_regs *__regs;						\
>  	u64 __addr = 0, __count = 1;					\
>  	struct task_struct *__task = NULL;				\
>  	struct hlist_head *head;					\
>  	int __entry_size;						\
>  	int __data_size;						\
> -	int rctx;							\
> +	int rctx, event_type;						\
>  									\
>  	__data_size = trace_event_get_offsets_##call(&__data_offsets, args); \
>  									\
>  	head = this_cpu_ptr(event_call->perf_events);			\
> -	if (__builtin_constant_p(!__task) && !__task &&			\
> +	if (!prog && __builtin_constant_p(!__task) && !__task &&	\
>  				hlist_empty(head))			\
>  		return;							\
>  									\
> @@ -56,8 +57,9 @@ perf_trace_##call(void *__data, proto)					\
>  			     sizeof(u64));				\
>  	__entry_size -= sizeof(u32);					\
>  									\
> -	entry = perf_trace_buf_prepare(__entry_size,			\
> -			event_call->event.type, &__regs, &rctx);	\
> +	event_type = prog ? TRACE_EVENT_TYPE_MAX : event_call->event.type; \

Can you move this into perf_trace_entry_prepare?

> +	entry = perf_trace_buf_prepare(__entry_size, event_type,	\
> +				       &__regs, &rctx);			\
>  	if (!entry)							\
>  		return;							\
>  									\
> @@ -67,6 +69,14 @@ perf_trace_##call(void *__data, proto)					\
>  									\
>  	{ assign; }							\
>  									\
> +	if (prog) {							\
> +		*(struct pt_regs **)entry = __regs;			\
> +		if (!trace_call_bpf(prog, entry) || hlist_empty(head)) { \
> +			perf_swevent_put_recursion_context(rctx);	\
> +			return;						\
> +		}							\
> +		memset(&entry->ent, 0, sizeof(entry->ent));		\
> +	}								\

And perhaps this into perf_trace_buf_submit()?

Tracepoints are a major cause of bloat, and the reasons for these
prepare and submit functions is to move code out of the macros. Every
tracepoint in the kernel (1000 and counting) will include this code.
I've already had complaints that each tracepoint can add up to 5k to
the core.

-- Steve


>  	perf_trace_buf_submit(entry, __entry_size, rctx, __addr,	\
>  		__count, __regs, head, __task);				\
>  }
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 23917bb47bf3..70eda5aeb304 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -92,6 +92,7 @@ enum bpf_prog_type {
>  	BPF_PROG_TYPE_KPROBE,
>  	BPF_PROG_TYPE_SCHED_CLS,
>  	BPF_PROG_TYPE_SCHED_ACT,
> +	BPF_PROG_TYPE_TRACEPOINT,
>  };
>  
>  #define BPF_PSEUDO_MAP_FD	1
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index de24fbce5277..58fc9a7d1562 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -6725,12 +6725,13 @@ int perf_swevent_get_recursion_context(void)
>  }
>  EXPORT_SYMBOL_GPL(perf_swevent_get_recursion_context);
>  
> -inline void perf_swevent_put_recursion_context(int rctx)
> +void perf_swevent_put_recursion_context(int rctx)
>  {
>  	struct swevent_htable *swhash = this_cpu_ptr(&swevent_htable);
>  
>  	put_recursion_context(swhash->recursion, rctx);
>  }
> +EXPORT_SYMBOL_GPL(perf_swevent_put_recursion_context);
>  
>  void ___perf_sw_event(u32 event_id, u64 nr, struct pt_regs *regs, u64 addr)
>  {
> @@ -7104,6 +7105,7 @@ static void perf_event_free_filter(struct perf_event *event)
>  
>  static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  {
> +	bool is_kprobe, is_tracepoint;
>  	struct bpf_prog *prog;
>  
>  	if (event->attr.type != PERF_TYPE_TRACEPOINT)
> @@ -7112,15 +7114,18 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  	if (event->tp_event->prog)
>  		return -EEXIST;
>  
> -	if (!(event->tp_event->flags & TRACE_EVENT_FL_UKPROBE))
> -		/* bpf programs can only be attached to u/kprobes */
> +	is_kprobe = event->tp_event->flags & TRACE_EVENT_FL_UKPROBE;
> +	is_tracepoint = event->tp_event->flags & TRACE_EVENT_FL_TRACEPOINT;
> +	if (!is_kprobe && !is_tracepoint)
> +		/* bpf programs can only be attached to u/kprobe or tracepoint */
>  		return -EINVAL;
>  
>  	prog = bpf_prog_get(prog_fd);
>  	if (IS_ERR(prog))
>  		return PTR_ERR(prog);
>  
> -	if (prog->type != BPF_PROG_TYPE_KPROBE) {
> +	if ((is_kprobe && prog->type != BPF_PROG_TYPE_KPROBE) ||
> +	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
>  		/* valid fd, but invalid bpf program type */
>  		bpf_prog_put(prog);
>  		return -EINVAL;
> diff --git a/kernel/trace/trace_event_perf.c b/kernel/trace/trace_event_perf.c
> index 7a68afca8249..7ada829029d3 100644
> --- a/kernel/trace/trace_event_perf.c
> +++ b/kernel/trace/trace_event_perf.c
> @@ -284,6 +284,9 @@ void *perf_trace_buf_prepare(int size, unsigned short type,
>  		*regs = this_cpu_ptr(&__perf_regs[*rctxp]);
>  	raw_data = this_cpu_ptr(perf_trace_buf[*rctxp]);
>  
> +	if (type == TRACE_EVENT_TYPE_MAX)
> +		return raw_data;
> +
>  	/* zero the dead bytes from align to not leak stack to user */
>  	memset(&raw_data[size - sizeof(u64)], 0, sizeof(u64));
>  
