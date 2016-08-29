From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 4/6] perf, bpf: add perf events core support for
 BPF_PROG_TYPE_PERF_EVENT programs
Date: Mon, 29 Aug 2016 14:17:18 +0200
Message-ID: <20160829121718.GN10153@twins.programming.kicks-ass.net>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
 <1472265084-1767670-5-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472265084-1767670-5-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2016 at 07:31:22PM -0700, Alexei Starovoitov wrote:
> +static int perf_event_set_bpf_handler(struct perf_event *event, u32 prog_fd)
> +{
> +	struct bpf_prog *prog;
> +
> +	if (event->overflow_handler_context)
> +		/* hw breakpoint or kernel counter */
> +		return -EINVAL;
> +
> +	if (event->prog)
> +		return -EEXIST;
> +
> +	prog = bpf_prog_get_type(prog_fd, BPF_PROG_TYPE_PERF_EVENT);
> +	if (IS_ERR(prog))
> +		return PTR_ERR(prog);
> +
> +	event->prog = prog;
> +	event->orig_overflow_handler = READ_ONCE(event->overflow_handler);
> +	WRITE_ONCE(event->overflow_handler, bpf_overflow_handler);
> +	return 0;
> +}
> +
> +static void perf_event_free_bpf_handler(struct perf_event *event)
> +{
> +	struct bpf_prog *prog = event->prog;
> +
> +	if (!prog)
> +		return;

Does it make sense to do something like:

	WARN_ON_ONCE(event->overflow_handler != bpf_overflow_handler);

?

> +
> +	WRITE_ONCE(event->overflow_handler, event->orig_overflow_handler);
> +	event->prog = NULL;
> +	bpf_prog_put(prog);
> +}


>  static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  {
>  	bool is_kprobe, is_tracepoint;
>  	struct bpf_prog *prog;
>  
> +	if (event->attr.type == PERF_TYPE_HARDWARE ||
> +	    event->attr.type == PERF_TYPE_SOFTWARE)
> +		return perf_event_set_bpf_handler(event, prog_fd);
> +
>  	if (event->attr.type != PERF_TYPE_TRACEPOINT)
>  		return -EINVAL;
>  
> @@ -7647,6 +7711,8 @@ static void perf_event_free_bpf_prog(struct perf_event *event)
>  {
>  	struct bpf_prog *prog;
>  
> +	perf_event_free_bpf_handler(event);
> +
>  	if (!event->tp_event)
>  		return;
>  

Does it at all make sense to merge the tp_event->prog thing into this
new event->prog?

>  #ifdef CONFIG_HAVE_HW_BREAKPOINT
> @@ -8957,6 +9029,14 @@ perf_event_alloc(struct perf_event_attr *attr, int cpu,
>  	if (!overflow_handler && parent_event) {
>  		overflow_handler = parent_event->overflow_handler;
>  		context = parent_event->overflow_handler_context;
> +		if (overflow_handler == bpf_overflow_handler) {
> +			event->prog = bpf_prog_inc(parent_event->prog);
> +			event->orig_overflow_handler = parent_event->orig_overflow_handler;
> +			if (IS_ERR(event->prog)) {
> +				event->prog = NULL;
> +				overflow_handler = NULL;
> +			}
> +		}
>  	}

Should we not fail the entire perf_event_alloc() call in that IS_ERR()
case?
