From: subashab@codeaurora.org
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Mon, 23 Mar 2015 22:16:12 -0000
Message-ID: <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
    <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
    <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
    <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46765 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbbCWWQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:16:13 -0400
In-Reply-To: <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> On Thu, 2015-03-19 at 14:50 -0700, Eric Dumazet wrote:
>>
>>> Are you seeing this race on x86 ?
>>>
>>> If IPI are not reliable on your arch, I am guessing you should fix
>>> them.
>>>
>>> Otherwise, even without hotplug you'll have hangs.
>>
>> Please try instead this patch :
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index
>> 5d43e010ef870a6ab92895297fe18d6e6a03593a..baa4bff9a6fbe0d77d7921865c=
038060cb5efffd
>> 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4320,9 +4320,8 @@ static void net_rps_action_and_irq_enable(stru=
ct
>> softnet_data *sd)
>>  		while (remsd) {
>>  			struct softnet_data *next =3D remsd->rps_ipi_next;
>>
>> -			if (cpu_online(remsd->cpu))
>> -				smp_call_function_single_async(remsd->cpu,
>> -							   &remsd->csd);
>> +			smp_call_function_single_async(remsd->cpu,
>> +						       &remsd->csd);
>>  			remsd =3D next;
>>  		}
>>  	} else
>>
>>
> Thanks for the patch Eric. We are seeing this race on ARM.
> I will try this and update.
>

Unfortunately, I am not able to reproduce data stall now with or withou=
t
the patch. Could you tell me more about the patch and what issue you we=
re
suspecting?

Based on the code, it looks like we BUG out on our arch if we try to ca=
ll
an IPI on an offline CPU. Since this condition is never hit, I feel tha=
t
the IPI might not have failed.

void smp_send_reschedule(int cpu)
{
=A0=A0=A0=A0=A0=A0=A0=A0BUG_ON(cpu_is_offline(cpu));
=A0=A0=A0=A0=A0=A0=A0=A0smp_cross_call_common(cpumask_of(cpu), IPI_RESC=
HEDULE);
}

--
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
