From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 1/2] perf: Add the flag sample_disable not to output
 data on samples
Date: Mon, 12 Oct 2015 20:10:44 -0700
Message-ID: <561C7634.5010703@plumgrid.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
 <561C07E0.6070203@plumgrid.com> <561C6CAE.7080503@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, acme@kernel.org, mingo@redhat.com,
	a.p.zijlstra@chello.nl, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: xiakaixu <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561C6CAE.7080503@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/15 7:30 PM, xiakaixu wrote:
>> The proper perf_event_enable/disable are so heavy that another
>> >mechanism needed? cpu_function_call is probably too much to do
>> >from bpf program, but that can be simplified?
>> >Based on the use case from cover letter, sounds like you want
>> >something like soft_disable?
>> >Then extending event->state would make the most sense.
>> >Also consider the case of re-entrant event enable/disable.
>> >So inc/dec of a flag may be needed?
> Thanks for your comments!
> I've tried perf_event_enable/disable, but there is a warning caused
> by cpu_function_call. The main reason as follows,
>   int smp_call_function_single(...)
>   {
> 	...
> 	WARN_ON_ONCE(cpu_online(this_cpu) && irqs_disabled()
> 		     && !oops_in_progress);

of course, that's what I meant by 'cpu_function_call is too much
to do from bpf program'. In this case it's running out of kprobe
with disabled irq, so you hit the warning, but even if it was regular
tracepoint, doing ipi from bpf is too much. All bpf helpers must be
deterministic without such side effects.

> So I added the extra atomic flag filed in order to avoid this problem.

that's a hammer approach. There are other ways to do it, like:
- extend event->state with this soft_disable-like functionality
  (Also consider the case of re-entrant event enable/disable.
   inc/dec may be needed)
- or tap into event->attr.sample_period
   may be it can be temporarily set to zero to indicate soft_disabled.
