From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RPS: Sparse connection optimizations
Date: Sat, 28 Apr 2012 13:55:56 +0200
Message-ID: <1335614156.2900.66.camel@edumazet-glaptop>
References: <1335607805-735-1-git-send-email-dczhu@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42184 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335Ab2D1L4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:56:02 -0400
Received: by bkuw12 with SMTP id w12so1078440bku.19
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 04:56:00 -0700 (PDT)
In-Reply-To: <1335607805-735-1-git-send-email-dczhu@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-04-28 at 18:10 +0800, Deng-Cheng Zhu wrote:
> From: Deng-Cheng Zhu <dczhu@mips.com>
> 
> Currently, choosing target CPU to process the incoming packet is based on
> skb->rxhash. In the case of sparse connections, this could lead to
> relatively low and inconsistent bandwidth while doing network throughput
> tests -- CPU selection in the RPS map is imbalanced. Even with the same
> hash value, 2 packets could come from different devices. Besides, on
> architectures like MIPS with multi-threaded cores, siblings of CPU0 should
> not be selected when others are not saturated.

What CPU0 is doing so special you have to mention it in this changelog ?

> 
> This patch introduces a feature that allows some flows to select their CPUs
> by looping the RPS CPU maps. Some tests were performed on the MIPS Malta
> 1004K platform (2 cores, each with 2 VPEs) at 25Mhz with 2 Intel Pro/1000
> NICs. The Malta board works as a router between 2 PCs. Using iperf, here
> are results:


RPS on a router ? Thats not very good, unless you perform a crazy amount
of work in iptables rules maybe ?

One packet comes, its better to handle it right now and send it right
now on the same cpu. No IPI cost, no cache line misses...


RPS is something more suitable to TCP handling in local host because
stack has big memory footprint and latencies, not for forwarding
workload.

I suspect you can reach more throughput using appropriate tunings
(correct interrupt affinities). This sounds like a bad config from the
very beginning.


> +};
> +
> +static struct cpu_flow flow[CONFIG_NR_RPS_MAP_LOOPS][NR_CPUS];

Thats absolutely not allowed to add a [NR_CPUS] array anywhere in linux
kernel in 2012.


> +/*
> + * We've got CONFIG_SMP to do RPS, so only arch define is needed here to access
> + * sibling specific information.
> + */
> +#if defined(CONFIG_MIPS)

Thats not allowed to add a CONFIG_somearch in net/core/dev.c
