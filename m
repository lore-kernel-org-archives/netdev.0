From: subashab@codeaurora.org
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Wed, 25 Mar 2015 18:54:07 -0000
Message-ID: <49d5ac3130df29059f167a0401754c67.squirrel@www.codeaurora.org>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
    <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
    <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
    <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
    <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
    <1427149742.25985.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60928 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbbCYSyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:54:08 -0400
In-Reply-To: <1427149742.25985.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 2015-03-23 at 22:16 +0000, subashab@codeaurora.org wrote:
>> >> On Thu, 2015-03-19 at 14:50 -0700, Eric Dumazet wrote:
>> >>
>> >>> Are you seeing this race on x86 ?
>> >>>
>> >>> If IPI are not reliable on your arch, I am guessing you should fix
>> >>> them.
>> >>>
>> >>> Otherwise, even without hotplug you'll have hangs.
>> >>
>> >> Please try instead this patch :
>> >>
>> >> diff --git a/net/core/dev.c b/net/core/dev.c
>> >> index
>> >> 5d43e010ef870a6ab92895297fe18d6e6a03593a..baa4bff9a6fbe0d77d7921865c038060cb5efffd
>> >> 100644
>> >> --- a/net/core/dev.c
>> >> +++ b/net/core/dev.c
>> >> @@ -4320,9 +4320,8 @@ static void
>> net_rps_action_and_irq_enable(struct
>> >> softnet_data *sd)
>> >>  		while (remsd) {
>> >>  			struct softnet_data *next = remsd->rps_ipi_next;
>> >>
>> >> -			if (cpu_online(remsd->cpu))
>> >> -				smp_call_function_single_async(remsd->cpu,
>> >> -							   &remsd->csd);
>> >> +			smp_call_function_single_async(remsd->cpu,
>> >> +						       &remsd->csd);
>> >>  			remsd = next;
>> >>  		}
>> >>  	} else
>> >>
>> >>
>> > Thanks for the patch Eric. We are seeing this race on ARM.
>> > I will try this and update.
>> >
>>
>> Unfortunately, I am not able to reproduce data stall now with or without
>> the patch. Could you tell me more about the patch and what issue you
>> were
>> suspecting?
>>
>> Based on the code, it looks like we BUG out on our arch if we try to
>> call
>> an IPI on an offline CPU. Since this condition is never hit, I feel that
>> the IPI might not have failed.
>>
>> void smp_send_reschedule(int cpu)
>> {
>>         BUG_ON(cpu_is_offline(cpu));
>>         smp_cross_call_common(cpumask_of(cpu), IPI_RESCHEDULE);
>> }
>
>
>
> The bug I am fixing is the following :
>
>
> if (cpu_is_online(x))
>     target = x
>
> ...
>
> queue packet on queue of cpu x
>
>
> net_rps_action_and_irq_enable()
>
>
> if (cpu_is_online(x))  [2]
>     smp_call_function_single_async(x, ...)
>
>
> Problem is that first test in [1] can succeed, but second in [2] can
> fail.
>
> But we should still send this IPI.
>
> We run in a softirq, so it is OK to deliver the IPI to the _about to be
> offlined_ cpu.
>
> We should test the cpu_is_online(x) once.
>
> Doing this a second time is the bug.

Thanks for the explanation. It looks like the issue is related to the way
our driver is designed.

We have a legacy driver which does not use the NAPI framework (and cannot
be modified for reasons beyond my control). They rely on an interrupt
mitigation system which disables hardware interrupts after receiving the
interrupt for the first packet and then enters a polling mode for a
duration and queues packets up to the network stack using netif_rx().
We have observed that the the time between softirq raised in the worker
thread context and softirq entry in softirq context is around 1-3
milliseconds (local pending softirq's might be triggered after exit of a
hardware irq).
When we used netif_rx_ni() instead, the delay between softirq raise and
entry is around microseconds since the local pending irq's are services
immediately. We have modified the driver to use netif_rx_ni() now.

With netif_rx() I was able to reproduce the data stall consistently. Upon
hotplug, I was able to see that the cpu_is_online(x) check in [1 -
get_rps_cpus] returned the cpu as mentioned in the rps mask but
the check in [2 - net_rps_action_and_irq_enable] returned that the cpu was
offline. After I applied your patch, I was crashing since my arch
explicitly BUGs out on sending IPI's on offline CPU's.

With netif_rx_ni(), I have not run into any issue as of now both with and
without your patch since both [1] and [2] might have been returning the
same the value for cpu_is_online(x). However, it is possible that this
race occurs with a much lesser chance. I would still see the data stall
if [1] returns online while [2] returns the cpu as offline. Would it be
acceptable to reset NAPI state in [2] in this case?

--
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
