From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 1/4] bpf: add helper
 bpf_perf_read_counter_time for perf event array map
Date: Mon, 4 Sep 2017 09:46:36 +0200
Message-ID: <20170904074636.smsygnxfofr46we5@hirez.programming.kicks-ass.net>
References: <20170902054824.371962-1-yhs@fb.com>
 <20170902054824.371962-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:60970 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753259AbdIDHqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 03:46:44 -0400
Content-Disposition: inline
In-Reply-To: <20170902054824.371962-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 10:48:21PM -0700, Yonghong Song wrote:
> diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
> index b14095b..5a50808 100644
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -898,7 +898,8 @@ perf_event_create_kernel_counter(struct perf_event_attr *attr,
>  				void *context);
>  extern void perf_pmu_migrate_context(struct pmu *pmu,
>  				int src_cpu, int dst_cpu);
> -int perf_event_read_local(struct perf_event *event, u64 *value);
> +int perf_event_read_local(struct perf_event *event, u64 *value,
> +			  u64 *enabled, u64 *running);
>  extern u64 perf_event_read_value(struct perf_event *event,
>  				 u64 *enabled, u64 *running);
>  

> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 8c01572..20c4039 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3670,7 +3670,8 @@ static inline u64 perf_event_count(struct perf_event *event)
>   *     will not be local and we cannot read them atomically
>   *   - must not have a pmu::count method
>   */
> -int perf_event_read_local(struct perf_event *event, u64 *value)
> +int perf_event_read_local(struct perf_event *event, u64 *value,
> +			  u64 *enabled, u64 *running)
>  {
>  	unsigned long flags;
>  	int ret = 0;
> @@ -3694,7 +3695,7 @@ int perf_event_read_local(struct perf_event *event, u64 *value)
>  	 * It must not have a pmu::count method, those are not
>  	 * NMI safe.
>  	 */
> -	if (event->pmu->count) {
> +	if (value && event->pmu->count) {
>  		ret = -EOPNOTSUPP;
>  		goto out;
>  	}

No, value _must_ be !NULL. Otherwise you allow getting timestamps
independently from the count value and that is broken.

The {value, enabled, running} tuple is temporally related.

> @@ -3718,10 +3719,16 @@ int perf_event_read_local(struct perf_event *event, u64 *value)
>  	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
>  	 * oncpu == -1).
>  	 */
> -	if (event->oncpu == smp_processor_id())
> -		event->pmu->read(event);
> -
> -	*value = local64_read(&event->count);
> +	if (value) {
> +		if (event->oncpu == smp_processor_id())
> +			event->pmu->read(event);
> +		*value = local64_read(&event->count);
> +	}
> +	if (enabled && running) {
> +		u64 ctx_time = event->shadow_ctx_time + perf_clock();
> +		*enabled = ctx_time - event->tstamp_enabled;
> +		*running = ctx_time - event->tstamp_running;
> +	}
>  out:
>  	local_irq_restore(flags);

Please make that something like:


	u64 now = event->shadow_ctx_time + perf_clock();

	if (enabled)
		*enabled = now - event->tstamp_enabled;

	if (event->oncpu == smp_processor_id()) {
		event->pmu->read(event);
		if (running)
			*running = now - event->tstamp_running;
	} else {
		*running = event->total_time_running;
	}

And I'll fix it up when I make:

  https://lkml.kernel.org/r/20170831171837.njnc6r6elsvkl7lt@hirez.programming.kicks-ass.net

happen.
