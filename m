From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/8] perf, bpf: allow bpf programs attach to
 tracepoints
Date: Tue, 5 Apr 2016 16:18:57 +0200
Message-ID: <20160405141857.GN3448@twins.programming.kicks-ass.net>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <1459831974-2891931-3-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59764 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759252AbcDEOTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 10:19:09 -0400
Content-Disposition: inline
In-Reply-To: <1459831974-2891931-3-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 09:52:48PM -0700, Alexei Starovoitov wrote:
> introduce BPF_PROG_TYPE_TRACEPOINT program type and allow it to be
> attached to tracepoints.

More specifically the perf tracepoint handler, not tracepoints directly.

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

We call those apps broken..

> Same rule applies here: static tracepoint fields should only be accessed
> in a format defined in tracepoint/format. The order of fields and
> field sizes are not an ABI.


> @@ -56,8 +57,9 @@ perf_trace_##call(void *__data, proto)					\
>  			     sizeof(u64));				\
>  	__entry_size -= sizeof(u32);					\
>  									\
> -	entry = perf_trace_buf_prepare(__entry_size,			\
> -			event_call->event.type, &__regs, &rctx);	\
> +	event_type = prog ? TRACE_EVENT_TYPE_MAX : event_call->event.type; \
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

So if the prog 'fails' you consume the entry,

> +		}							\
> +		memset(&entry->ent, 0, sizeof(entry->ent));		\

But if not, you destroy it and then feed it to perf?

> +	}								\
>  	perf_trace_buf_submit(entry, __entry_size, rctx, __addr,	\
>  		__count, __regs, head, __task);				\
>  }


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

What's this hunk do? Why can you skip this stuff for BPF attached
events?
