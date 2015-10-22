From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Thu, 22 Oct 2015 18:28:22 +0800
Message-ID: <5628BA46.8060307@huawei.com>
References: <20151021113316.GM17308@twins.programming.kicks-ass.net> <56277BCE.6030400@huawei.com> <20151021121713.GC3604@twins.programming.kicks-ass.net> <56279634.5000606@huawei.com> <20151021134951.GH3604@twins.programming.kicks-ass.net> <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com> <20151021140921.GI3604@twins.programming.kicks-ass.net> <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com> <20151021165758.GK3604@twins.programming.kicks-ass.net> <56280175.8060404@plumgrid.com> <20151022090632.GK2508@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pi3orama <pi3orama@163.com>, xiakaixu <xiakaixu@huawei.com>,
	<davem@davemloft.net>, <acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151022090632.GK2508@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/22 17:06, Peter Zijlstra wrote:
> On Wed, Oct 21, 2015 at 02:19:49PM -0700, Alexei Starovoitov wrote:
>
>>> Urgh, that's still horridly inconsistent. Can we please come up with a
>>> consistent interface to perf?
>> My suggestion was to do ioctl(enable/disable) of events from userspace
>> after receiving notification from kernel via my bpf_perf_event_output()
>> helper.
>> Wangnan's argument was that display refresh happens often and it's fast,
>> so the time taken by user space to enable events on all cpus is too
>> slow and ioctl does ipi and disturbs other cpus even more.
>> So soft_disable done by the program to enable/disable particular events
>> on all cpus kinda makes sense.
> And this all makes me think I still have no clue what you're all trying
> to do here.
>
> Who cares about display updates and why. And why should there be an
> active userspace part to eBPF programs?

So you want the background story? OK, let me describe it. This mail is not
short so please be patient.

On a smartphone, if time between two frames is longer than 16ms, user
can aware it. This is a display glitch. We want to check those glitches
with perf to find what cause them. The basic idea is: use 'perf record'
to collect enough information, find those samples generated just before
the glitch form perf.data then analysis them offline.

There are many works need to be done before perf can support such
analysis. One improtant thing is to reduce the overhead from perf to
avoid perf itself become the reason of glitches. We can do this by reduce
the number of events perf collects, but then we won't have enough
information to analysis when glitch happen. Another way we are trying to 
implement
now is to dynamically turn events on and off, or at least enable/disable
sampling dynamically because the overhead of copying those samples
is a big part of perf's total overhead. After that we can trace as many
event as possible, but only fetch data from them when we detect a glitch.

BPF program is the best choice to describe our relative complex glitch
detection model. For simplicity, you can think our glitch detection model
contain 3 points at user programs: point A means display refreshing begin,
point B means display refreshing has last for 16ms, point C means
display refreshing finished. They can be found in user programs and
probed through uprobe, on which we can attach BPF programs on.

Then we want to use perf this way:

Sample 'cycles' event to collect callgraph so we know what all CPUs are
doing during the refreshing, but only start sampling when we detect a
frame refreshing last for 16ms.

We can translate the above logic into BPF programs: at point B, enable
'cycles' event to generate samples; at point C, disable 'cycles' event
to avoid useless samples to be generated.

Then, make 'perf record -e cycles' to collect call graph and other
information through cycles event. From perf.data, we can use 'perf script'
and other tools to analysis resuling data.

We have consider some potential solution and find them inapproate or need
too much work to do:

  1. As you may prefer, create BPF functions to call pmu->stop() /
     pmu->start() for perf event on the CPU on which BPF programs get
     triggered.

     The shortcoming of this method is we can only turn on the perf event on
     the CPU execute point B. We are unable to know what other CPU are doing
     during glitching. But what we want is system-wide information. In 
addition,
     point C and point B are not necessarily be executed at one core, so 
we may
     shut down wrong event if scheduler decide to run point C on another 
core.

  2. As Alexei's suggestion, output something through his 
bpf_perf_event_output(),
     let perf disable and enable those events using ioctl in userspace.

     This is a good idea, but introduces asynchronization problem.
     bpf_perf_event_output() output something to perf's ring buffer, but 
perf
     get noticed about this message when epoll_wait() return. We tested 
a tracepoint
     event and found that an event may awared by perf sereval seconds after
     it generated. One solution is to use --no-buffer, but it still need 
perf to be
     scheduled on time and parse its ringbuffer quickly. Also, please 
note that point
     C is possible to appear very shortly after point B because some 
APPs are optimized
     to make their refreshing time very near to 16ms.

This is the background story. Looks like whether we implement some 
corss-CPU controling
or we satisified with coarse grained controlling. The best method we can 
think is to
use atomic operation to soft enable/disable perf events. We believe it 
is simple enough
and won't cause problem.

Thank you.
