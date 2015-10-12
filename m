From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 1/2] perf: Add the flag sample_disable not to output
 data on samples
Date: Mon, 12 Oct 2015 14:02:57 +0200
Message-ID: <20151012120257.GO3816@twins.programming.kicks-ass.net>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@plumgrid.com, davem@davemloft.net, acme@kernel.org,
	mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 09:02:42AM +0000, Kaixu Xia wrote:
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -483,6 +483,8 @@ struct perf_event {
>  	perf_overflow_handler_t		overflow_handler;
>  	void				*overflow_handler_context;
>  
> +	atomic_t			*sample_disable;
> +
>  #ifdef CONFIG_EVENT_TRACING
>  	struct trace_event_call		*tp_event;
>  	struct event_filter		*filter;

> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index b11756f..f6ef45c 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
>  		irq_work_queue(&event->pending);
>  	}
>  
> +	if ((event->sample_disable) && atomic_read(event->sample_disable))
> +		return ret;
> +
>  	if (event->overflow_handler)
>  		event->overflow_handler(event, data, regs);
>  	else

Try and guarantee sample_disable lives in the same cacheline as
overflow_handler.

I think we should at the very least replace the kzalloc() currently used
with a cacheline aligned alloc, and check the structure layout to verify
these two do in fact share a cacheline.
