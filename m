From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 4/6] perf, bpf: add perf events core support for
 BPF_PROG_TYPE_PERF_EVENT programs
Date: Tue, 30 Aug 2016 20:40:10 -0700
Message-ID: <20160831034008.GA79785@ast-mbp.thefacebook.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
 <1472265084-1767670-5-git-send-email-ast@fb.com>
 <20160829121718.GN10153@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160829121718.GN10153@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2016 at 02:17:18PM +0200, Peter Zijlstra wrote:
> On Fri, Aug 26, 2016 at 07:31:22PM -0700, Alexei Starovoitov wrote:
> > +static int perf_event_set_bpf_handler(struct perf_event *event, u32 prog_fd)
> > +{
> > +	struct bpf_prog *prog;
> > +
> > +	if (event->overflow_handler_context)
> > +		/* hw breakpoint or kernel counter */
> > +		return -EINVAL;
> > +
> > +	if (event->prog)
> > +		return -EEXIST;
> > +
> > +	prog = bpf_prog_get_type(prog_fd, BPF_PROG_TYPE_PERF_EVENT);
> > +	if (IS_ERR(prog))
> > +		return PTR_ERR(prog);
> > +
> > +	event->prog = prog;
> > +	event->orig_overflow_handler = READ_ONCE(event->overflow_handler);
> > +	WRITE_ONCE(event->overflow_handler, bpf_overflow_handler);
> > +	return 0;
> > +}
> > +
> > +static void perf_event_free_bpf_handler(struct perf_event *event)
> > +{
> > +	struct bpf_prog *prog = event->prog;
> > +
> > +	if (!prog)
> > +		return;
> 
> Does it make sense to do something like:
> 
> 	WARN_ON_ONCE(event->overflow_handler != bpf_overflow_handler);

Yes that's an implicit assumption here, but checking for that
would be overkill. event->overflow_handler and event->prog are set
back to back in two places and reset here once together.
Such warn_on will only make people reading this code in the future
think that this bit is too complex to analyze by hand.

> > +
> > +	WRITE_ONCE(event->overflow_handler, event->orig_overflow_handler);
> > +	event->prog = NULL;
> > +	bpf_prog_put(prog);
> > +}
> 
> 
> >  static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
> >  {
> >  	bool is_kprobe, is_tracepoint;
> >  	struct bpf_prog *prog;
> >  
> > +	if (event->attr.type == PERF_TYPE_HARDWARE ||
> > +	    event->attr.type == PERF_TYPE_SOFTWARE)
> > +		return perf_event_set_bpf_handler(event, prog_fd);
> > +
> >  	if (event->attr.type != PERF_TYPE_TRACEPOINT)
> >  		return -EINVAL;
> >  
> > @@ -7647,6 +7711,8 @@ static void perf_event_free_bpf_prog(struct perf_event *event)
> >  {
> >  	struct bpf_prog *prog;
> >  
> > +	perf_event_free_bpf_handler(event);
> > +
> >  	if (!event->tp_event)
> >  		return;
> >  
> 
> Does it at all make sense to merge the tp_event->prog thing into this
> new event->prog?

'struct trace_event_call *tp_event' is global while tp_event->perf_events
are per cpu, so I don't see how we can do that without breaking user space
logic. Right now users do single perf_event_open of kprobe and attach prog
that is executed on all cpus where kprobe is firing. Additional per-cpu
filtering is done from within bpf prog.

> >  #ifdef CONFIG_HAVE_HW_BREAKPOINT
> > @@ -8957,6 +9029,14 @@ perf_event_alloc(struct perf_event_attr *attr, int cpu,
> >  	if (!overflow_handler && parent_event) {
> >  		overflow_handler = parent_event->overflow_handler;
> >  		context = parent_event->overflow_handler_context;
> > +		if (overflow_handler == bpf_overflow_handler) {
> > +			event->prog = bpf_prog_inc(parent_event->prog);
> > +			event->orig_overflow_handler = parent_event->orig_overflow_handler;
> > +			if (IS_ERR(event->prog)) {
> > +				event->prog = NULL;
> > +				overflow_handler = NULL;
> > +			}
> > +		}
> >  	}
> 
> Should we not fail the entire perf_event_alloc() call in that IS_ERR()
> case?

Yes. Good point. Will do.
