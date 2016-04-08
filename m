From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next 1/8] perf: optimize perf_fetch_caller_regs
Date: Fri, 8 Apr 2016 18:12:19 -0400
Message-ID: <20160408181219.036c1216@gandalf.local.home>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
	<1459831974-2891931-2-git-send-email-ast@fb.com>
	<20160405120626.GM3448@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160405120626.GM3448@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2016 14:06:26 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Apr 04, 2016 at 09:52:47PM -0700, Alexei Starovoitov wrote:
> > avoid memset in perf_fetch_caller_regs, since it's the critical path of all tracepoints.
> > It's called from perf_sw_event_sched, perf_event_task_sched_in and all of perf_trace_##call
> > with this_cpu_ptr(&__perf_regs[..]) which are zero initialized by perpcu_alloc  
> 
> Its not actually allocated; but because its a static uninitialized
> variable we get .bss like behaviour and the initial value is copied to
> all CPUs when the per-cpu allocator thingy bootstraps SMP IIRC.
> 
> > and
> > subsequent call to perf_arch_fetch_caller_regs initializes the same fields on all archs,
> > so we can safely drop memset from all of the above cases and   
> 
> Indeed.
> 
> > move it into
> > perf_ftrace_function_call that calls it with stack allocated pt_regs.  
> 
> Hmm, is there a reason that's still on-stack instead of using the
> per-cpu thing, Steve?

Well, what do you do when you are tracing with regs in an interrupt
that already set the per cpu regs field? We could create our own
per-cpu one as well, but then that would require checking which level
we are in, as we can have one for normal context, one for softirq
context, one for irq context and one for nmi context.

-- Steve



> 
> > Signed-off-by: Alexei Starovoitov <ast@kernel.org>  
> 
> In any case,
> 
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
