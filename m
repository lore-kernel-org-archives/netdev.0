From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 2/2] bpf: Implement
 bpf_perf_event_sample_enable/disable() helpers
Date: Mon, 12 Oct 2015 22:15:13 -0700
Message-ID: <561C9361.6090104@plumgrid.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-3-git-send-email-xiakaixu@huawei.com>
 <561C0A1E.2080500@plumgrid.com> <561C7A1F.6040702@huawei.com>
 <561C7CDA.8050004@plumgrid.com> <561C7FBE.4000104@huawei.com>
 <561C85BB.3000505@plumgrid.com> <561C89EC.8030303@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561C89EC.8030303@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/15 9:34 PM, Wangnan (F) wrote:
>
>
> On 2015/10/13 12:16, Alexei Starovoitov wrote:
>> On 10/12/15 8:51 PM, Wangnan (F) wrote:
>>>> why 'set disable' is needed ?
>>>> the example given in cover letter shows the use case where you want
>>>> to receive samples only within sys_write() syscall.
>>>> The example makes sense, but sys_write() is running on this cpu, so
>>>> just
>>>> disabling it on the current one is enough.
>>>>
>>>
>>> Our real use case is control of the system-wide sampling. For example,
>>> we need sampling all CPUs when smartphone start refershing its display.
>>> We need all CPUs because in Android system there are plenty of threads
>>> get involed into this behavior. We can't achieve this by controling
>>> sampling on only one CPU. This is the reason we need 'set enable'
>>> and 'set disable'.
>>
>> ok, but that use case may have different enable/disable pattern.
>> In sys_write example ultra-fast enable/disable is must have, since
>> the whole syscall is fast and overhead should be minimal.
>> but for display refresh? we're talking milliseconds, no?
>> Can you just ioctl() it from user space?
>> If cost of enable/disable is high or the time range between toggling is
>> long, then doing it from the bpf program doesn't make sense. Instead
>> the program can do bpf_perf_event_output() to send a notification to
>> user space that condition is met and the user space can ioctl() events.
>>
>
> OK. I think I understand your design principle that, everything inside BPF
> should be as fast as possible.
>
> Make userspace control events using ioctl make things harder. You know that
> 'perf record' itself doesn't care too much about events it reveived. It
> only
> copies data to perf.data, but what we want is to use perf record simply
> like
> this:
>
>   # perf record -e evt=cycles -e control.o/pmu=evt/ -a sleep 100
>
> And in control.o we create uprobe point to mark the start and finish of
> a frame:
>
>   SEC("target=/a/b/c.o\nstartFrame=0x123456")
>   int startFrame(void *) {
>     bpf_pmu_enable(pmu);
>     return 1;
>   }
>
>   SEC("target=/a/b/c.o\nfinishFrame=0x234568")
>   int finishFrame(void *) {
>     bpf_pmu_disable(pmu);
>     return 1;
>   }
>
> I think it is make sence also.

yes. that looks quite useful,
but did you consider re-entrant startFrame() ?
start << here sampling starts
   start
   finish << here all samples disabled?!
finish
and startFrame()/finishFrame() running on all cpus of that user app ?
One cpu entering into startFrame() while another cpu doing finishFrame
what behavior should be? sampling is still enabled on all cpus? or off?
Either case doesn't seem to work with simple enable/disable.
Few emails in this thread back, I mentioned inc/dec of a flag
to solve that.

> What about using similar
> implementation
> like PERF_EVENT_IOC_SET_OUTPUT, creating a new ioctl like
> PERF_EVENT_IOC_SET_ENABLER,
> then let perf to select an event as 'enabler', then BPF can still
> control one atomic
> variable to enable/disable a set of events.

you lost me on that last sentence. How this 'enabler' will work?
Also I'm still missing what's wrong with perf doing ioctl() on
events on all cpus manually when bpf program tells it to do so.
Is it speed you concerned about or extra work in perf ?
