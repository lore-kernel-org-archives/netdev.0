From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read()
 that get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 12:04:25 +0200
Message-ID: <20150805100425.GZ25159@twins.programming.kicks-ass.net>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@plumgrid.com, davem@davemloft.net, acme@kernel.org,
	mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46931 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbbHEKEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 06:04:43 -0400
Content-Disposition: inline
In-Reply-To: <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2015 at 08:58:15AM +0000, Kaixu Xia wrote:
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 6251b53..726ca1b 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -8599,6 +8599,25 @@ struct perf_event_attr *perf_event_attrs(struct perf_event *event)
>  	return &event->attr;
>  }
>  
> +u64 perf_event_read_internal(struct perf_event *event)

Maybe: perf_event_read_local(), as this is this function only works for
events active on the current CPU.

> +{
> +	if (!event)
> +		return -EINVAL;
> +
> +	if (unlikely(event->state != PERF_EVENT_STATE_ACTIVE))
> +		return -EINVAL;

You can return perf_event_count() in that case.

> +
> +	if (event->oncpu != raw_smp_processor_id() &&

That _must_ be smp_processor_id(). If that gives a warning (ie.
preemption is not disabled or we're not affine to this one cpu) then the
warning is valid.

> +	    event->ctx->task != current)

Write it like:

	if (event->ctx->task != current &&
	    event->oncpu != smp_processor_id())

That way you'll not evaluate smp_processor_id() for current task events.

> +		return -EINVAL;
> +
> +	if (unlikely(event->attr.inherit))
> +		return -EINVAL;

This should be in your accept function, inherited events should never
get this far.

You need IRQs disabled while calling __perf_event_read(), did you test
with lockdep enabled?

> +	__perf_event_read(event);
> +	return perf_event_count(event);
> +}

Also, you probably want a WARN_ON(in_nmi()) there, this function is
_NOT_ NMI safe.
