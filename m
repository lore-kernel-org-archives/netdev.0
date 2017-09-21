From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: one perf event close won't free bpf program
 attached by another perf event
Date: Thu, 21 Sep 2017 14:53:48 -0700
Message-ID: <222d5d19-a843-348f-8cf4-bf0669ae6c91@fb.com>
References: <20170918233836.1817062-1-yhs@fb.com>
 <20170920214109.11002b7c@vmware.local.home>
 <94f5a61e-1a88-f285-224b-66c92dc3da7b@fb.com>
 <9e968490-87ae-7a79-9e59-0dcc840a93f5@fb.com>
 <20170921111706.343om7252gcagco6@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Peter Zijlstra <peterz@infradead.org>, Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43640 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751763AbdIUVyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 17:54:37 -0400
In-Reply-To: <20170921111706.343om7252gcagco6@hirez.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/17 4:17 AM, Peter Zijlstra wrote:
> On Wed, Sep 20, 2017 at 10:20:13PM -0700, Yonghong Song wrote:
>>> (2). trace_event_call->perf_events are per cpu data structure, that
>>> means, some filtering logic is needed to avoid the same perf_event prog
>>> is executing twice.
>>
>> What I mean here is that the trace_event_call->perf_events need to be
>> checked on ALL cpus since bpf prog should be executed regardless of
>> cpu affiliation. It is possible that the same perf_event in different
>> per_cpu bucket and hence filtering is needed to avoid the same
>> perf_event bpf_prog is executed twice.
>
> An event will only ever be on a single CPU's list at any one time IIRC.

yes, but doing for_each_cpu there is not an option. too slow.
struct trace_event_call is the only stable argument in
perf_trace_##call(), so we gotta have a pointer there for stuff
we need to run.
This patch added another annoying pointer, since it's the simplest
bugfix for stable. For net-next we're going to remove it, since
we're working on multi-prog support for kprobes/tracepoints.
(right now there is only one prog allowed and that's very limiting)
With multi-prog that bpf_prog_owner pointer will be removed and
existing 'struct bpf_prog *prog' pointer will be replaced with
something else.

> Now, hysterically perf_event_set_bpf_prog used the tracepoint crud
> because that already had bpf bits in. But it might make sense to look at
> unifying the bpf stuff across all the different event types. Have them
> all use event->prog.

it sounds good in theory, but in practice we need a separate
'stuff to run' pointer in both perf_event and trace_even_call,
since that's what being passed to overflow_handle and perf_trace_##call.

> I suspect that would break a fair bunch of bpf proglets, since the data
> access to the trace data would be completely different, but it would be
> much nicer to not have this distinction based on event type.

such things are certainly an abi.
kprobe+bpf has to see struct pt_regs
perf_event+bpf has to see struct bpf_perf_event_data and
tracepoint+bpf has to see struct foo { fields }
The fields will change every time tracepoint is changed.
That's fine.
But we cannot unify kprobe with tracepoints with perf_event prog types.
And frankly I don't see the need.
Note that in pt_regs we don't need to populate everything.
The 'optimized fprobe' we were talking about at plumbers we
would populate di,si,dx,cx,sp since most of the kprobe+bpf progs
don't care about the other regs and especially cpu flags.
So plenty of room for tweaks and optimizations.
