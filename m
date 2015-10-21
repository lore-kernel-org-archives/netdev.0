From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 19:34:28 +0800
Message-ID: <56277844.9090201@huawei.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com> <1445325735-121694-2-git-send-email-xiakaixu@huawei.com> <5626C5CE.8080809@plumgrid.com> <20151021091254.GF2881@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kaixu Xia <xiakaixu@huawei.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<pi3orama@163.com>, <hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021091254.GF2881@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/21 17:12, Peter Zijlstra wrote:
> On Tue, Oct 20, 2015 at 03:53:02PM -0700, Alexei Starovoitov wrote:
>> On 10/20/15 12:22 AM, Kaixu Xia wrote:
>>> diff --git a/kernel/events/core.c b/kernel/events/core.c
>>> index b11756f..5219635 100644
>>> --- a/kernel/events/core.c
>>> +++ b/kernel/events/core.c
>>> @@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
>>>   		irq_work_queue(&event->pending);
>>>   	}
>>>
>>> +	if (unlikely(!atomic_read(&event->soft_enable)))
>>> +		return 0;
>>> +
>>>   	if (event->overflow_handler)
>>>   		event->overflow_handler(event, data, regs);
>>>   	else
>> Peter,
>> does this part look right or it should be moved right after
>> if (unlikely(!is_sampling_event(event)))
>>                  return 0;
>> or even to other function?
>>
>> It feels to me that it should be moved, since we probably don't
>> want to active throttling, period adjust and event_limit for events
>> that are in soft_disabled state.
> Depends on what its meant to do. As long as you let the interrupt
> happen, I think we should in fact do those things (maybe not the
> event_limit), but period adjustment and esp. throttling are important
> when the event is enabled.
>
> If you want to actually disable the event: pmu->stop() will make it
> stop, and you can restart using pmu->start().xiezuo

I also prefer totally disabling event because our goal is to reduce
sampling overhead as mush as possible. However, events in perf is
CPU bounded, one event in perf cmdline becomes multiple 'perf_event'
in kernel in multi-core system. Disabling/enabling events on all CPUs
by a BPF program a hard task due to racing, NMI, ...

Think about an example scenario: we want to sample cycles in a system
width way to see what the whole system does during a smart phone
refreshing its display, and don't want other samples when display
freezing. We probe at the entry and exit points of Display.refresh() (a
fictional user function), then let two BPF programs to enable 'cycle'
sampling PMU at the entry point and disable it at the exit point.

In this task, we need to start all 'cycles' perf_events when display
start refreshing, and disable all of those events when refreshing is
finished. Only enable the event on the core which executes the entry
point of Display.refresh() is not enough because real workers are
running on other cores, we need them to do the computation cooperativly.
Also, scheduler is possible to schedule the exit point of Display.refresh()
on another core, so we can't simply disable the perf_event on that core and
let other core keel sampling after refreshing finishes.

I have thought a method which can disable sampling in a safe way:
we can call pmu->stop() inside the PMU IRQ handler, so we can ensure
that pmu->stop() always be called by core its event resides.
However, I don't know how to reenable them when safely. Maybe need
something in scheduler?

Thank you.

> And I suppose you can wrap that with a counter if you need nesting.
>
> I'm not sure if any of that is a viable solution, because the patch
> description is somewhat short on the problem statement.
>
> As is, I'm not too charmed with the patch, but lacking a better
> understanding of what exactly we're trying to achieve I'm struggling
> with proposing alternatives.
