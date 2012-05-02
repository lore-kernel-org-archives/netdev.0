From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH] RPS: Sparse connection optimizations
Date: Wed, 2 May 2012 12:08:23 +0800
Message-ID: <4FA0B337.1070401@mips.com>
References: <1335607805-735-1-git-send-email-dczhu@mips.com> <1335614156.2900.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <therbert@google.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:41038 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab2EBEId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 00:08:33 -0400
In-Reply-To: <1335614156.2900.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2012 07:55 PM, Eric Dumazet wrote:
> On Sat, 2012-04-28 at 18:10 +0800, Deng-Cheng Zhu wrote:
>> From: Deng-Cheng Zhu<dczhu@mips.com>
>>
>> Currently, choosing target CPU to process the incoming packet is based on
>> skb->rxhash. In the case of sparse connections, this could lead to
>> relatively low and inconsistent bandwidth while doing network throughput
>> tests -- CPU selection in the RPS map is imbalanced. Even with the same
>> hash value, 2 packets could come from different devices. Besides, on
>> architectures like MIPS with multi-threaded cores, siblings of CPU0 should
>> not be selected when others are not saturated.
>
> What CPU0 is doing so special you have to mention it in this changelog ?

Serve the NIC hardware irq and do the 1st part of softirq in RPS.
Changes relating to this will be made in v2. Thanks.

>>
>> This patch introduces a feature that allows some flows to select their CPUs
>> by looping the RPS CPU maps. Some tests were performed on the MIPS Malta
>> 1004K platform (2 cores, each with 2 VPEs) at 25Mhz with 2 Intel Pro/1000
>> NICs. The Malta board works as a router between 2 PCs. Using iperf, here
>> are results:
>
>
> RPS on a router ? Thats not very good, unless you perform a crazy amount
> of work in iptables rules maybe ?
>
> One packet comes, its better to handle it right now and send it right
> now on the same cpu. No IPI cost, no cache line misses...

Theoretically, you are right. But RPS works early -- when the hot CPU
gets really hot, RPS takes effect even with forwarding workload. Earlier
experiments on the mentioned Malta platform proved it as well
(typically 45% ~ more than doubled, amazingly).

>
> RPS is something more suitable to TCP handling in local host because
> stack has big memory footprint and latencies, not for forwarding
> workload.

See above.

> I suspect you can reach more throughput using appropriate tunings
> (correct interrupt affinities). This sounds like a bad config from the
> very beginning.

Unfortunately, on the Malta platform, NIC irqs are not suitable for SMP
IRQ affinity -- they are based on XT-PIC. However, I did do some RPS
tests where different CPU masks were assigned to the 2 NICs. And the
throughput *WAS* better than that of assigning the same mask to NICs.
But the problem addressed in this patch *STILL* exists -- hash indexing
causes imbalance across CPUs in the case of sparse connections.

>
>> +};
>> +
>> +static struct cpu_flow flow[CONFIG_NR_RPS_MAP_LOOPS][NR_CPUS];
>
> Thats absolutely not allowed to add a [NR_CPUS] array anywhere in linux
> kernel in 2012.

Good advice. Will be different in V2.

>
>> +/*
>> + * We've got CONFIG_SMP to do RPS, so only arch define is needed here to access
>> + * sibling specific information.
>> + */
>> +#if defined(CONFIG_MIPS)
>
> Thats not allowed to add a CONFIG_somearch in net/core/dev.c

Good advice too.


Thanks!

Deng-Cheng
