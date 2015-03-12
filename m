From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 tip 2/8] tracing: attach BPF programs to kprobes
Date: Thu, 12 Mar 2015 09:18:34 -0700
Message-ID: <5501BC5A.6000204@plumgrid.com>
References: <1426047534-8148-1-git-send-email-ast@plumgrid.com> <1426047534-8148-3-git-send-email-ast@plumgrid.com> <20150312151507.GI2896@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150312151507.GI2896@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/12/15 8:15 AM, Peter Zijlstra wrote:
> On Tue, Mar 10, 2015 at 09:18:48PM -0700, Alexei Starovoitov wrote:
>> +unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
>> +{
>> +	unsigned int ret;
>> +	int cpu;
>> +
>> +	if (in_nmi()) /* not supported yet */
>> +		return 1;
>> +
>> +	preempt_disable_notrace();
>> +
>> +	cpu = raw_smp_processor_id();
>> +	if (unlikely(per_cpu(bpf_prog_active, cpu)++ != 0)) {
>> +		/* since some bpf program is already running on this cpu,
>> +		 * don't call into another bpf program (same or different)
>> +		 * and don't send kprobe event into ring-buffer,
>> +		 * so return zero here
>> +		 */
>> +		ret = 0;
>> +		goto out;
>> +	}
>> +
>> +	rcu_read_lock();
>
> You've so far tried very hard to not get into tracing; and then you call
> rcu_read_lock() :-)
>
> So either document why this isn't a problem, provide
> rcu_read_lock_notrace() or switch to RCU-sched and thereby avoid the
> problem.

I don't see the problem.
I actually do turn on func and func_graph tracers from time to time to
debug bpf core itself. Why would tracing interfere with anything that
this patch is doing? When we're inside tracing processing, we need to
use only _notrace() helpers otherwise recursion will hurt, but this
code is not invoked from there. It's called from 
kprobe_ftrace_handler|kprobe_int3_handler->kprobe_dispatcher->
kprobe_perf_func->trace_call_bpf which all are perfectly traceable.
Probably my copy paste of preempt_disable_notrace() line from
stack_trace_call() became source of confusion? I believe
normal preempt_disable() here will be just fine.
It's actually redundant too, since preemption is disabled by kprobe
anyway. Please help me understand what I'm missing.
