From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 21:42:12 +0800
Message-ID: <56279634.5000606@huawei.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com> <1445325735-121694-2-git-send-email-xiakaixu@huawei.com> <5626C5CE.8080809@plumgrid.com> <20151021091254.GF2881@worktop.programming.kicks-ass.net> <56276968.6070604@huawei.com> <20151021113316.GM17308@twins.programming.kicks-ass.net> <56277BCE.6030400@huawei.com> <20151021121713.GC3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiakaixu <xiakaixu@huawei.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<pi3orama@163.com>, <hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021121713.GC3604@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/21 20:17, Peter Zijlstra wrote:
> On Wed, Oct 21, 2015 at 07:49:34PM +0800, Wangnan (F) wrote:
>> If our task is sampling cycle events during a function is running,
>> and if two cores start that function overlap:
>>
>> Time:   ...................A
>> Core 0: sys_write----\
>>                        \
>>                         \
>> Core 1:             sys_write%return
>> Core 2: ................sys_write
>>
>> Then without counter at time A it is highly possible that
>> BPF program on core 1 and core 2 get conflict with each other.
>> The final result is we make some of those events be turned on
>> and others turned off. Using atomic counter can avoid this
>> problem.
> But but, how and why can an eBPF program access a !local event? I
> thought we had hard restrictions on that.

How can an eBPF program access a !local event:

when creating perf event array we don't care which perf event
is for which CPU, so perf program can access any perf event in
that array. Which is straightforward. And in soft
disabling/enabling, what need to be done is an atomic
operation on something in 'perf_event' structure, which is safe
enough.

Why we need an eBPF program access a !local event:

I think I have explained why we need an eBPF program to access
a !local event. In summary, without this ability we can't
speak in user's language because they are focus on higher level
principles (display refreshing, application booting, http
processing...) and 'on which CPU' is not in their dictionaries most
of the time. Without cross-core soft-enabling/disabling it is hard
to translate requirements like "start sampling when display refreshing
begin" and "stop sampling when application booted" into eBPF programs
and perf cmdline. Don't you think it is useful for reducing sampling
data and needs to be considered?

One alternative solution I can image is to attach a BPF program
at sampling like kprobe, and return 0 if we don't want sampling
take action. Thought? Actually speaking I don't like it very much
because the principle of soft-disable is much simpler and safe, but
if you really like it I think we can try.

Do you think soft-disable/enable perf events on other cores makes
any real problem?

Thank you.
