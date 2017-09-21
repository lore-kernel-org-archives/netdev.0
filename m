From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net] bpf: one perf event close won't free bpf program
 attached by another perf event
Date: Wed, 20 Sep 2017 22:20:13 -0700
Message-ID: <9e968490-87ae-7a79-9e59-0dcc840a93f5@fb.com>
References: <20170918233836.1817062-1-yhs@fb.com>
 <20170920214109.11002b7c@vmware.local.home>
 <94f5a61e-1a88-f285-224b-66c92dc3da7b@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <peterz@infradead.org>, <ast@fb.com>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49027 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750912AbdIUFVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 01:21:01 -0400
In-Reply-To: <94f5a61e-1a88-f285-224b-66c92dc3da7b@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/20/17 10:17 PM, Yonghong Song wrote:
> 
> 
> On 9/20/17 6:41 PM, Steven Rostedt wrote:
>> On Mon, 18 Sep 2017 16:38:36 -0700
>> Yonghong Song <yhs@fb.com> wrote:
>>
>>> This patch fixes a bug exhibited by the following scenario:
>>>    1. fd1 = perf_event_open with attr.config = ID1
>>>    2. attach bpf program prog1 to fd1
>>>    3. fd2 = perf_event_open with attr.config = ID1
>>>       <this will be successful>
>>>    4. user program closes fd2 and prog1 is detached from the tracepoint.
>>>    5. user program with fd1 does not work properly as tracepoint
>>>       no output any more.
>>>
>>> The issue happens at step 4. Multiple perf_event_open can be called
>>> successfully, but only one bpf prog pointer in the tp_event. In the
>>> current logic, any fd release for the same tp_event will free
>>> the tp_event->prog.
>>>
>>> The fix is to free tp_event->prog only when the closing fd
>>> corresponds to the one which registered the program.
>>>
>>> Signed-off-by: Yonghong Song <yhs@fb.com>
>>> ---
>>>   Additional context: discussed with Alexei internally but did not find
>>>   a solution which can avoid introducing the additional field in
>>>   trace_event_call structure.
>>>
>>>   Peter, could you take a look as well and maybe you could have better
>>>   alternative? Thanks!
>>>
>>>   include/linux/trace_events.h | 1 +
>>>   kernel/events/core.c         | 3 ++-
>>>   2 files changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
>>> index 7f11050..2e0f222 100644
>>> --- a/include/linux/trace_events.h
>>> +++ b/include/linux/trace_events.h
>>> @@ -272,6 +272,7 @@ struct trace_event_call {
>>>       int                perf_refcount;
>>>       struct hlist_head __percpu    *perf_events;
>>>       struct bpf_prog            *prog;
>>> +    struct perf_event        *bpf_prog_owner;
>>
>> Does this have to be in the trace_event_call structure? Hmm, I'm
>> wondering if the prog needs to be there (I should look to see if we can
>> move it from it). The trace_event_call is created for *every* event,
>> and there's thousands of them now. Every byte to this structure adds
>> 1000s of bytes to the kernel. Would it be possible to attach the prog
>> and the owner to the perf_event?
> 
> Regarding whether we could move the prog and the owner to the 
> perf_event. It is possible. There is already a "prog" field in the
> perf_event structure for overflow handler. We could reuse the "prog"
> field and we do not need bpf_prog_owner any more. We can iterate
> through trace_event_call->perf_events to find the event which has the
> prog and executes it. This will support multiple prog's attaching to
> the same trace_event_call as well.
> 
> This approach may need careful evaluation though.
> (1). It adds runtime overhead although the overhead should be small
> since perf_event attaching to the same trace_event_call should be small.
> (2). trace_event_call->perf_events are per cpu data structure, that 
> means, some filtering logic is needed to avoid the same perf_event prog 
> is executing twice.

What I mean here is that the trace_event_call->perf_events need to be
checked on ALL cpus since bpf prog should be executed regardless of
cpu affiliation. It is possible that the same perf_event in different
per_cpu bucket and hence filtering is needed to avoid the same
perf_event bpf_prog is executed twice.

> (3). since the list is traversed, the locking (rcu?) may be required to
> pretect the list. Not sure whether additional locking is needed or not.
> 
> Alternative to using trace_event_call->perf_events, we may replace
> "struct bpf_prog *prog" to a list (or some other list like data 
> structure) to just record perf events which have bpf progs attached.
> But this will add memory overhead to trace_event_call data structure.
> 
>>
>> -- Steve
>>
>>
>>>       int    (*perf_perm)(struct trace_event_call *,
>>>                    struct perf_event *);
>>> diff --git a/kernel/events/core.c b/kernel/events/core.c
>>> index 3e691b7..6bc21e2 100644
>>> --- a/kernel/events/core.c
>>> +++ b/kernel/events/core.c
>>> @@ -8171,6 +8171,7 @@ static int perf_event_set_bpf_prog(struct 
>>> perf_event *event, u32 prog_fd)
>>>           }
>>>       }
>>>       event->tp_event->prog = prog;
>>> +    event->tp_event->bpf_prog_owner = event;
>>>       return 0;
>>>   }
>>> @@ -8185,7 +8186,7 @@ static void perf_event_free_bpf_prog(struct 
>>> perf_event *event)
>>>           return;
>>>       prog = event->tp_event->prog;
>>> -    if (prog) {
>>> +    if (prog && event->tp_event->bpf_prog_owner == event) {
>>>           event->tp_event->prog = NULL;
>>>           bpf_prog_put(prog);
>>>       }
>>
