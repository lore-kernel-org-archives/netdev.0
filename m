From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v8 tip 3/9] tracing: attach BPF programs to kprobes
Date: Fri, 20 Mar 2015 17:09:07 -0400
Message-ID: <20150320170907.388d8c33@gandalf.local.home>
References: <1426816787-5001-1-git-send-email-ast@plumgrid.com>
	<1426816787-5001-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426816787-5001-4-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Mar 2015 18:59:41 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

Some nits...



> --- /dev/null
> +++ b/kernel/trace/bpf_trace.c
> @@ -0,0 +1,123 @@
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
> +/**
> + * trace_call_bpf - invoke BPF program
> + * @prog - BPF program
> + * @ctx - opaque context pointer
> + *
> + * kprobe handlers execute BPF programs via this helper.
> + * Can be used from static tracepoints in the future.

Should also state what the expected return values are. What does a
return of "1" mean?

> + */
> +unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
> +{
> +	unsigned int ret;
> +
> +	if (in_nmi()) /* not supported yet */
> +		return 1;
> +
> +	preempt_disable();
> +
> +	if (unlikely(__this_cpu_inc_return(bpf_prog_active) != 1)) {
> +		/* since some bpf program is already running on this cpu,

You are no longer in the net/ world. The rest of the Linux coding style
is:

	/*
	 * multi line comments
	 */

Only DaveM gets away with that format ;-)

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
> +	__this_cpu_dec(bpf_prog_active);
> +	preempt_enable();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(trace_call_bpf);

The rest looks fine. For that..

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
