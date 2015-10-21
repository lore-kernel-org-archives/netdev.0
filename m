From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 19:49:34 +0800
Message-ID: <56277BCE.6030400@huawei.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com> <1445325735-121694-2-git-send-email-xiakaixu@huawei.com> <5626C5CE.8080809@plumgrid.com> <20151021091254.GF2881@worktop.programming.kicks-ass.net> <56276968.6070604@huawei.com> <20151021113316.GM17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<pi3orama@163.com>, <hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>,
	xiakaixu <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021113316.GM17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/21 19:33, Peter Zijlstra wrote:
> On Wed, Oct 21, 2015 at 06:31:04PM +0800, xiakaixu wrote:
>
>> The RFC patch set contains the necessary commit log [1].
> That's of course the wrong place, this should be in the patch's
> Changelog. It doesn't become less relevant.
>
>> In some scenarios we don't want to output trace data when perf sampling
>> in order to reduce overhead. For example, perf can be run as daemon to
>> dump trace data when necessary, such as the system performance goes down.
>> Just like the example given in the cover letter, we only receive the
>> samples within sys_write() syscall.
>>
>> The helper bpf_perf_event_control() in this patch set can control the
>> data output process and get the samples we are most interested in.
>> The cpu_function_call is probably too much to do from bpf program, so
>> I choose current design that like 'soft_disable'.
> So, IIRC, we already require eBPF perf events to be CPU-local, which
> obviates the entire need for IPIs.

But soft-disable/enable don't require IPI because it is only
a memory store operation.

> So calling pmu->stop() seems entirely possible (its even NMI safe).

But we need to turn off sampling across CPUs. Please have a look
at my another email.

> This, however, does not explain if you need nesting, your patch seemed
> to have a counter, which suggest you do.
To avoid reacing.

If our task is sampling cycle events during a function is running,
and if two cores start that function overlap:

Time:   ...................A
Core 0: sys_write----\
                       \
                        \
Core 1:             sys_write%return
Core 2: ................sys_write

Then without counter at time A it is highly possible that
BPF program on core 1 and core 2 get conflict with each other.
The final result is we make some of those events be turned on
and others turned off. Using atomic counter can avoid this
problem.

Thank you.

>
> In any case, you could add perf_event_{stop,start}_local() to mirror the
> existing perf_event_read_local(), no? That would stop the entire thing
> and reduce even more overhead than simply skipping the overflow handler.
>
