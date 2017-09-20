From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next v5 1/4] bpf: add helper
 bpf_perf_event_read_value for perf event array map
Date: Wed, 20 Sep 2017 19:26:51 +0200
Message-ID: <20170920172651.zx4nfmj2lpgxzubq@hirez.programming.kicks-ass.net>
References: <20170920060935.1102268-1-yhs@fb.com>
 <20170920060935.1102268-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-team@fb.com,
        David Miller <davem@davemloft.net>
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:49120 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbdITR1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 13:27:07 -0400
Content-Disposition: inline
In-Reply-To: <20170920060935.1102268-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 11:09:32PM -0700, Yonghong Song wrote:
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 3e691b7..2d5bbe5 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3684,10 +3684,12 @@ static inline u64 perf_event_count(struct perf_event *event)
>   *     will not be local and we cannot read them atomically
>   *   - must not have a pmu::count method
>   */
> -int perf_event_read_local(struct perf_event *event, u64 *value)
> +int perf_event_read_local(struct perf_event *event, u64 *value,
> +			  u64 *enabled, u64 *running)
>  {
>  	unsigned long flags;
>  	int ret = 0;
> +	u64 now;
>  
>  	/*
>  	 * Disabling interrupts avoids all counter scheduling (context
> @@ -3718,14 +3720,21 @@ int perf_event_read_local(struct perf_event *event, u64 *value)
>  		goto out;
>  	}
>  
> +	now = event->shadow_ctx_time + perf_clock();
> +	if (enabled)
> +		*enabled = now - event->tstamp_enabled;
>  	/*
>  	 * If the event is currently on this CPU, its either a per-task event,
>  	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
>  	 * oncpu == -1).
>  	 */
> -	if (event->oncpu == smp_processor_id())
> +	if (event->oncpu == smp_processor_id()) {
>  		event->pmu->read(event);
> -
> +		if (running)
> +			*running = now - event->tstamp_running;
> +	} else if (running) {
> +		*running = event->total_time_running;
> +	}
>  	*value = local64_read(&event->count);
>  out:
>  	local_irq_restore(flags);

Yeah, this looks about right.

Dave, could we have this in a topic tree of sorts, because I have a
pending series to rework all the timekeeping and it might be nice to not
have sfr run into all sorts of conflicts.
