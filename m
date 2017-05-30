From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Tue, 30 May 2017 10:37:46 -0700
Message-ID: <132719d0-a18c-d4a0-8e72-56658c0c344f@fb.com>
References: <20170526055549.557818-1-ast@fb.com>
 <20170526055549.557818-2-ast@fb.com>
 <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
 <20170529093918.xmbijgozjrfi22ru@hirez.programming.kicks-ass.net>
 <a6bf362c-9df9-f387-bac3-ab5516e4cb68@fb.com>
 <20170530165102.kvcutyfp6i2in2zx@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44693 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750898AbdE3Rih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 13:38:37 -0400
In-Reply-To: <20170530165102.kvcutyfp6i2in2zx@hirez.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/30/17 9:51 AM, Peter Zijlstra wrote:
> On Tue, May 30, 2017 at 08:52:14AM -0700, Alexei Starovoitov wrote:
>
>>> +	if (!(event->attach_state & PERF_ATTACH_TASK) &&
>>> +	    event->cpu != cpu)
>>> +		return false;
>>
>> we do if (unlikely(event->oncpu != cpu))
>> as dynamic check inside bpf_perf_event_read(), since we cannot do it
>> statically at perf_event_array update time.
>
> Right, that's what I thought.
>
>> If we drop the above 'if' and keep 'task==null' trick,
>> then indeed we can use this function as static check.
>
> Right, or otherwise have a special value to disable it.
>
>> Right now we're trying to keep as many checks as possible as
>> static checks to make bpf_perf_event_read() faster.
>> I guess we can drop that approach and do perf_event_valid_local()
>> check for every read since perf_event_read_local() does all the
>> same checks anyway.
>> So how about converting all WARN_ON in perf_event_read_local()
>> into 'return -EINVAL' and change func proto into:
>> int perf_event_read_local(struct perf_event *even, u64 *counter_val)
>
> I'm confused on how that is better. My recent patches to WARN should
> have greatly improved performance of WARN_ON_ONCE(). And looking at that
> code, I suspect its dominated by the POPF for inactive events.
>
>>> I cannot find reason for this comment. That is, why would
>>> perf_event_read_local() not support those two types?
>>
>> I don't know. What is the meaning of
>> reading tracepoint/breakpoint counter?
>
> They count like all other software events. +1 for each occurrence.
>
> So for instance, if you use irq_vectors:local_timer_entry you get how
> many cpu local timer instances happened during your measurement window.
>
> Same with a breakpoint, it counts how many times it got hit. Typically
> you'd want to install a custom handler on breakpoints to do something
> 'interesting', but even without that its acts like a normal software
> event.
>
>> Because of 'event->oncpu != cpu' dynamic check all counters are
>> expected to be per-cpu. I'm not sure how uncore counters work.
>
> Uncore thingies are assigned to any online CPU in their 'domain'.
>
>> What do they have in event->oncpu? -1? I guess they have pmu->count?
>> So we cannot read them from bpf program anyway?
>
> They have the CPU number of the CPU that's assigned to them. So you
> _could_ make use of them, but its a bit tricky to get them to work
> reliably because you'd have to get that CPU 'right' and it can change.
>
> Typically they would end up on the first CPU in their domain, but with
> CPU hotplug you can move them about and get confusion.
>
> I'd have to think on how to do that nicely.
>
>> If we change warn_ons in perf_event_read_local() to returns
>> them we can make per-task counters working.
>
> I'm not entirely sure I see how that is required. Should per task not
> already work? The WARN that's there will only trigger if you call them
> on the wrong task, which is something you shouldn't do anyway.

The kernel WARN is considered to be a bug of bpf infra. That's the
reason we do all these checks at map update time and at run-time.
The bpf program authors should be able to do all possible experiments
until their scripts work. Dealing with kernel warns and reboots is not
something user space folks like to do.
Today bpf_perf_event_read() for per-task events isn't really
working due to event->oncpu != cpu runtime check in there.
If we convert warns to returns the existing scripts will continue
to work as-is and per-task will be possible.
