From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH v6 tip 2/8] tracing: attach BPF programs to kprobes
Date: Thu, 12 Mar 2015 16:15:07 +0100
Message-ID: <20150312151507.GI2896@worktop.programming.kicks-ass.net>
References: <1426047534-8148-1-git-send-email-ast@plumgrid.com>
 <1426047534-8148-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1426047534-8148-3-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 10, 2015 at 09:18:48PM -0700, Alexei Starovoitov wrote:
> +unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
> +{
> +	unsigned int ret;
> +	int cpu;
> +
> +	if (in_nmi()) /* not supported yet */
> +		return 1;
> +
> +	preempt_disable_notrace();
> +
> +	cpu = raw_smp_processor_id();
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

You've so far tried very hard to not get into tracing; and then you call
rcu_read_lock() :-)

So either document why this isn't a problem, provide
rcu_read_lock_notrace() or switch to RCU-sched and thereby avoid the
problem.

> +	ret = BPF_PROG_RUN(prog, ctx);
> +	rcu_read_unlock();
> +
> + out:
> +	per_cpu(bpf_prog_active, cpu)--;
> +	preempt_enable_notrace();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(trace_call_bpf);
