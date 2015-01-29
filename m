From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH v2 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Thu, 29 Jan 2015 09:46:31 +0900
Message-ID: <20150129004631.GA24182@sejong>
References: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
 <1422417973-10195-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422417973-10195-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Tue, Jan 27, 2015 at 08:06:06PM -0800, Alexei Starovoitov wrote:
> User interface:
> fd = open("/sys/kernel/debug/tracing/__event__/filter")
> 
> write(fd, "bpf_123")
> 
> where 123 is process local FD associated with eBPF program previously loaded.
> __event__ is static tracepoint event or syscall.
> (kprobe support is in next patch)
> Once program is successfully attached to tracepoint event, the tracepoint
> will be auto-enabled
> 
> close(fd)
> auto-disables tracepoint event and detaches eBPF program from it
> 
> eBPF programs can call in-kernel helper functions to:
> - lookup/update/delete elements in maps
> - memcmp
> - fetch_ptr/u64/u32/u16/u8 values from unsafe address via probe_kernel_read(),
>   so that eBPF program can walk any kernel data structures
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---

[SNIP]
> diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
> index b03a0ea77b99..70482817231a 100644
> --- a/kernel/trace/trace_events.c
> +++ b/kernel/trace/trace_events.c
> @@ -1084,6 +1084,26 @@ event_filter_read(struct file *filp, char __user *ubuf, size_t cnt,
>  	return r;
>  }
>  
> +static int event_filter_release(struct inode *inode, struct file *filp)
> +{
> +	struct ftrace_event_file *file;
> +	char buf[2] = "0";
> +
> +	mutex_lock(&event_mutex);
> +	file = event_file_data(filp);
> +	if (file) {
> +		if (file->flags & TRACE_EVENT_FL_BPF) {
> +			/* auto-disable the filter */
> +			ftrace_event_enable_disable(file, 0);

Hmm.. what if user already enabled an event, attached a bpf filter and
then detached the filter - I'm not sure we can always auto-disable
it..


> +
> +			/* if BPF filter was used, clear it on fd close */
> +			apply_event_filter(file, buf);
> +		}
> +	}
> +	mutex_unlock(&event_mutex);
> +	return 0;
> +}
> +
>  static ssize_t
>  event_filter_write(struct file *filp, const char __user *ubuf, size_t cnt,
>  		   loff_t *ppos)
> @@ -1107,8 +1127,18 @@ event_filter_write(struct file *filp, const char __user *ubuf, size_t cnt,
>  
>  	mutex_lock(&event_mutex);
>  	file = event_file_data(filp);
> -	if (file)
> +	if (file) {
> +		/*
> +		 * note to user space tools:
> +		 * write() into debugfs/tracing/events/xxx/filter file
> +		 * must be done with the same privilege level as open()
> +		 */
>  		err = apply_event_filter(file, buf);
> +		if (!err && file->flags & TRACE_EVENT_FL_BPF)
> +			/* once filter is applied, auto-enable it */
> +			ftrace_event_enable_disable(file, 1);
> +	}
> +
>  	mutex_unlock(&event_mutex);
>  
>  	free_page((unsigned long) buf);
> @@ -1363,6 +1393,7 @@ static const struct file_operations ftrace_event_filter_fops = {
>  	.open = tracing_open_generic,
>  	.read = event_filter_read,
>  	.write = event_filter_write,
> +	.release = event_filter_release,
>  	.llseek = default_llseek,
>  };
>  
> diff --git a/kernel/trace/trace_events_filter.c b/kernel/trace/trace_events_filter.c
> index ced69da0ff55..e0303b3cc9fb 100644
> --- a/kernel/trace/trace_events_filter.c
> +++ b/kernel/trace/trace_events_filter.c
> @@ -23,6 +23,9 @@
>  #include <linux/mutex.h>
>  #include <linux/perf_event.h>
>  #include <linux/slab.h>
> +#include <linux/bpf.h>
> +#include <trace/bpf_trace.h>
> +#include <linux/filter.h>
>  
>  #include "trace.h"
>  #include "trace_output.h"
> @@ -541,6 +544,21 @@ static int filter_match_preds_cb(enum move_type move, struct filter_pred *pred,
>  	return WALK_PRED_DEFAULT;
>  }
>  
> +unsigned int trace_filter_call_bpf(struct event_filter *filter, void *ctx)
> +{
> +	unsigned int ret;
> +
> +	if (in_nmi()) /* not supported yet */
> +		return 0;

But doesn't this mean to auto-disable all attached events during NMI
as returning 0 will prevent the event going to ring buffer?

I think it'd be better to keep an attached event in a soft-disabled
state like event trigger and give control of enabling to users..

Thanks,
Namhyung


> +
> +	rcu_read_lock();
> +	ret = BPF_PROG_RUN(filter->prog, ctx);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(trace_filter_call_bpf);
