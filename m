From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 18:31:04 +0800
Message-ID: <56276968.6070604@huawei.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com> <1445325735-121694-2-git-send-email-xiakaixu@huawei.com> <5626C5CE.8080809@plumgrid.com> <20151021091254.GF2881@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:29634 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbbJUKds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 06:33:48 -0400
In-Reply-To: <20151021091254.GF2881@worktop.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015/10/21 17:12, Peter Zijlstra =E5=86=99=E9=81=93:
> On Tue, Oct 20, 2015 at 03:53:02PM -0700, Alexei Starovoitov wrote:
>> On 10/20/15 12:22 AM, Kaixu Xia wrote:
>>> diff --git a/kernel/events/core.c b/kernel/events/core.c
>>> index b11756f..5219635 100644
>>> --- a/kernel/events/core.c
>>> +++ b/kernel/events/core.c
>>> @@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_=
event *event,
>>>  		irq_work_queue(&event->pending);
>>>  	}
>>>
>>> +	if (unlikely(!atomic_read(&event->soft_enable)))
>>> +		return 0;
>>> +
>>>  	if (event->overflow_handler)
>>>  		event->overflow_handler(event, data, regs);
>>>  	else
>>
>> Peter,
>> does this part look right or it should be moved right after
>> if (unlikely(!is_sampling_event(event)))
>>                 return 0;
>> or even to other function?
>>
>> It feels to me that it should be moved, since we probably don't
>> want to active throttling, period adjust and event_limit for events
>> that are in soft_disabled state.
>=20
> Depends on what its meant to do. As long as you let the interrupt
> happen, I think we should in fact do those things (maybe not the
> event_limit), but period adjustment and esp. throttling are important
> when the event is enabled.
>=20
> If you want to actually disable the event: pmu->stop() will make it
> stop, and you can restart using pmu->start().
>=20
> And I suppose you can wrap that with a counter if you need nesting.
>=20
> I'm not sure if any of that is a viable solution, because the patch
> description is somewhat short on the problem statement.
>=20
> As is, I'm not too charmed with the patch, but lacking a better
> understanding of what exactly we're trying to achieve I'm struggling
> with proposing alternatives.

Thanks for your comments!
The RFC patch set contains the necessary commit log [1].

In some scenarios we don't want to output trace data when perf sampling
in order to reduce overhead. For example, perf can be run as daemon to
dump trace data when necessary, such as the system performance goes dow=
n.
Just like the example given in the cover letter, we only receive the
samples within sys_write() syscall.

The helper bpf_perf_event_control() in this patch set can control the
data output process and get the samples we are most interested in.
The cpu_function_call is probably too much to do from bpf program, so
I choose current design that like 'soft_disable'.

[1] https://lkml.org/lkml/2015/10/12/135
>=20
> .
>=20
