From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Mon, 23 Mar 2015 15:29:02 -0700
Message-ID: <1427149742.25985.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
	 <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
	 <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37939 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbbCWW3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:29:04 -0400
Received: by igbqf9 with SMTP id qf9so51888352igb.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:29:04 -0700 (PDT)
In-Reply-To: <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-23 at 22:16 +0000, subashab@codeaurora.org wrote:
> >> On Thu, 2015-03-19 at 14:50 -0700, Eric Dumazet wrote:
> >>
> >>> Are you seeing this race on x86 ?
> >>>
> >>> If IPI are not reliable on your arch, I am guessing you should fix
> >>> them.
> >>>
> >>> Otherwise, even without hotplug you'll have hangs.
> >>
> >> Please try instead this patch :
> >>
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index
> >> 5d43e010ef870a6ab92895297fe18d6e6a03593a..baa4bff9a6fbe0d77d7921865c038060cb5efffd
> >> 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -4320,9 +4320,8 @@ static void net_rps_action_and_irq_enable(struct
> >> softnet_data *sd)
> >>  		while (remsd) {
> >>  			struct softnet_data *next = remsd->rps_ipi_next;
> >>
> >> -			if (cpu_online(remsd->cpu))
> >> -				smp_call_function_single_async(remsd->cpu,
> >> -							   &remsd->csd);
> >> +			smp_call_function_single_async(remsd->cpu,
> >> +						       &remsd->csd);
> >>  			remsd = next;
> >>  		}
> >>  	} else
> >>
> >>
> > Thanks for the patch Eric. We are seeing this race on ARM.
> > I will try this and update.
> >
> 
> Unfortunately, I am not able to reproduce data stall now with or without
> the patch. Could you tell me more about the patch and what issue you were
> suspecting?
> 
> Based on the code, it looks like we BUG out on our arch if we try to call
> an IPI on an offline CPU. Since this condition is never hit, I feel that
> the IPI might not have failed.
> 
> void smp_send_reschedule(int cpu)
> {
>         BUG_ON(cpu_is_offline(cpu));
>         smp_cross_call_common(cpumask_of(cpu), IPI_RESCHEDULE);
> }



The bug I am fixing is the following :


if (cpu_is_online(x))
    target = x

...

queue packet on queue of cpu x


net_rps_action_and_irq_enable()


if (cpu_is_online(x))  [2]
    smp_call_function_single_async(x, ...)


Problem is that first test in [1] can succeed, but second in [2] can
fail.

But we should still send this IPI.

We run in a softirq, so it is OK to deliver the IPI to the _about to be
offlined_ cpu.

We should test the cpu_is_online(x) once.

Doing this a second time is the bug.
