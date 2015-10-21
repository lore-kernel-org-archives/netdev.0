From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 11:12:54 +0200
Message-ID: <20151021091254.GF2881@worktop.programming.kicks-ass.net>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
 <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
 <5626C5CE.8080809@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5626C5CE.8080809@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 20, 2015 at 03:53:02PM -0700, Alexei Starovoitov wrote:
> On 10/20/15 12:22 AM, Kaixu Xia wrote:
> >diff --git a/kernel/events/core.c b/kernel/events/core.c
> >index b11756f..5219635 100644
> >--- a/kernel/events/core.c
> >+++ b/kernel/events/core.c
> >@@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
> >  		irq_work_queue(&event->pending);
> >  	}
> >
> >+	if (unlikely(!atomic_read(&event->soft_enable)))
> >+		return 0;
> >+
> >  	if (event->overflow_handler)
> >  		event->overflow_handler(event, data, regs);
> >  	else
> 
> Peter,
> does this part look right or it should be moved right after
> if (unlikely(!is_sampling_event(event)))
>                 return 0;
> or even to other function?
> 
> It feels to me that it should be moved, since we probably don't
> want to active throttling, period adjust and event_limit for events
> that are in soft_disabled state.

Depends on what its meant to do. As long as you let the interrupt
happen, I think we should in fact do those things (maybe not the
event_limit), but period adjustment and esp. throttling are important
when the event is enabled.

If you want to actually disable the event: pmu->stop() will make it
stop, and you can restart using pmu->start().

And I suppose you can wrap that with a counter if you need nesting.

I'm not sure if any of that is a viable solution, because the patch
description is somewhat short on the problem statement.

As is, I'm not too charmed with the patch, but lacking a better
understanding of what exactly we're trying to achieve I'm struggling
with proposing alternatives.
