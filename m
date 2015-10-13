From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [RFC PATCH 2/2] bpf: Implement bpf_perf_event_sample_enable/disable()
 helpers
Date: Tue, 13 Oct 2015 19:07:25 +0800
Message-ID: <561CE5ED.70404@huawei.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com> <1444640563-159175-3-git-send-email-xiakaixu@huawei.com> <561C0A1E.2080500@plumgrid.com> <561C7A1F.6040702@huawei.com> <561C7CDA.8050004@plumgrid.com> <561C7FBE.4000104@huawei.com> <561C85BB.3000505@plumgrid.com> <561C89EC.8030303@huawei.com> <561C9361.6090104@plumgrid.com> <561CE2DB.2030409@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	<davem@davemloft.net>, <acme@kernel.org>, <mingo@redhat.com>,
	<a.p.zijlstra@chello.nl>, <masami.hiramatsu.pt@hitachi.com>,
	<jolsa@kernel.org>, <daniel@iogearbox.net>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561CE2DB.2030409@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/13 18:54, He Kuang wrote:
> hi, Alexei
>
>>> What about using similar
>>> implementation
>>> like PERF_EVENT_IOC_SET_OUTPUT, creating a new ioctl like
>>> PERF_EVENT_IOC_SET_ENABLER,
>>> then let perf to select an event as 'enabler', then BPF can still
>>> control one atomic
>>> variable to enable/disable a set of events.
>>
>> you lost me on that last sentence. How this 'enabler' will work?
>> Also I'm still missing what's wrong with perf doing ioctl() on
>> events on all cpus manually when bpf program tells it to do so.
>> Is it speed you concerned about or extra work in perf ?
>>
>>
>
> For not having too much wakeups, perf ringbuffer has a watermark
> limit to cache events and reduce the wakeups, which causes perf
> userspace tool can not receive perf events immediately.
>
> Here's a simple demo expamle to prove it, 'sleep_exec' does some
> writes and prints a timestamp every second, and an lable is
> printed when perf poll gets events.
>
>   $ perf record -m 2 -e syscalls:sys_enter_write sleep_exec 1000
>   userspace sleep time: 0 seconds
>   userspace sleep time: 1 seconds
>   userspace sleep time: 2 seconds
>   userspace sleep time: 3 seconds
>   perf record wakeup onetime 0
>   userspace sleep time: 4 seconds
>   userspace sleep time: 5 seconds
>   userspace sleep time: 6 seconds
>   userspace sleep time: 7 seconds
>   perf record wakeup onetime 1
>   userspace sleep time: 8 seconds
>   perf record wakeup onetime 2
>   ..
>
>   $ perf record -m 1 -e syscalls:sys_enter_write sleep_exec 1000
>   userspace sleep time: 0 seconds
>   userspace sleep time: 1 seconds
>   perf record wakeup onetime 0
>   userspace sleep time: 2 seconds
>   userspace sleep time: 3 seconds
>   perf record wakeup onetime 1
>   userspace sleep time: 4 seconds
>   userspace sleep time: 5 seconds
>   ..
>
> By default, if no mmap_pages is specified, perf tools wakeup only
> when the target executalbe finished:
>
>   $ perf record -e syscalls:sys_enter_write sleep_exec 5
>   userspace sleep time: 0 seconds
>   userspace sleep time: 1 seconds
>   userspace sleep time: 2 seconds
>   userspace sleep time: 3 seconds
>   userspace sleep time: 4 seconds
>   perf record wakeup onetime 0
>   [ perf record: Woken up 1 times to write data ]
>   [ perf record: Captured and wrote 0.006 MB perf.data (54 samples) ]
>
> If we want perf to reflect as soon as our sample event be generated,
> --no-buffering should be used, but this option has a greater
> impact on performance.
>
>   $ perf record --no-buffering -e syscalls:sys_enter_write sleep_exec 
> 1000
>   userspace sleep time: 0 seconds
>   perf record wakeup onetime 0
>   perf record wakeup onetime 1
>   perf record wakeup onetime 2
>   perf record wakeup onetime 3
>   perf record wakeup onetime 4
>   perf record wakeup onetime 5
>   perf record wakeup onetime 6
>   ..
>

Hi Alexei,

Based on He Kuang's test result, if we choose to use perf to control 
perf event
and output trigger event through bof_output_data, with default setting we
have to wait for sereval seconds until perf can get first trigger event 
if the
trigger event's frequency is low. In my display refreshing example, it 
causes
losting of event triggering. From user's view, random frames would miss.

With --no-buffering, things can become faster, but --no-buffering causes 
perf
to be scheduled in faster than normal, which is conflict to the goal of 
event
disabling that we want to reduce recording overhead as much as possible.

Thank you.

> Thank you
>
