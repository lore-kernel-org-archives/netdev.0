From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 1/2] perf: Add the flag sample_disable not to output
 data on samples
Date: Mon, 12 Oct 2015 14:12:13 +0200
Message-ID: <20151012121213.GL17308@twins.programming.kicks-ass.net>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
 <20151012120257.GO3816@twins.programming.kicks-ass.net>
 <561BA200.20108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kaixu Xia <xiakaixu@huawei.com>, ast@plumgrid.com,
	davem@davemloft.net, acme@kernel.org, mingo@redhat.com,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <561BA200.20108@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 08:05:20PM +0800, Wangnan (F) wrote:
> 
> 
> On 2015/10/12 20:02, Peter Zijlstra wrote:
> >On Mon, Oct 12, 2015 at 09:02:42AM +0000, Kaixu Xia wrote:
> >>--- a/include/linux/perf_event.h
> >>+++ b/include/linux/perf_event.h
> >>@@ -483,6 +483,8 @@ struct perf_event {
> >>  	perf_overflow_handler_t		overflow_handler;
> >>  	void				*overflow_handler_context;
> >>+	atomic_t			*sample_disable;
> >>+
> >>  #ifdef CONFIG_EVENT_TRACING
> >>  	struct trace_event_call		*tp_event;
> >>  	struct event_filter		*filter;
> >>diff --git a/kernel/events/core.c b/kernel/events/core.c
> >>index b11756f..f6ef45c 100644
> >>--- a/kernel/events/core.c
> >>+++ b/kernel/events/core.c
> >>@@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
> >>  		irq_work_queue(&event->pending);
> >>  	}
> >>+	if ((event->sample_disable) && atomic_read(event->sample_disable))
> >>+		return ret;
> >>+
> >>  	if (event->overflow_handler)
> >>  		event->overflow_handler(event, data, regs);
> >>  	else
> >Try and guarantee sample_disable lives in the same cacheline as
> >overflow_handler.
> 
> Could you please explain why we need them to be in a same cacheline?

Because otherwise you've just added a cacheline miss to this relatively
hot path.
