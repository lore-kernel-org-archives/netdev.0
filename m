From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: skb recycling
Date: Wed, 22 Oct 2008 22:28:07 -0700 (PDT)
Message-ID: <20081022.222807.205044577.davem@davemloft.net>
References: <48FD6E8A.6060304@cosmosbay.com>
	<18685.37380.34636.316536@robur.slu.se>
	<48FDA6B6.70905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@robur.slu.se, shemminger@vyatta.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33568
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751254AbYJWF2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 01:28:30 -0400
In-Reply-To: <48FDA6B6.70905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 21 Oct 2008 11:53:58 +0200

> One CPU does the allocations, (interrupts handled by a given CPU)
> Another CPU(s) do(es) the freeing
> 
> Such scenario is hard for slab/slub because it needs inter-CPU communication, while
> slub/slab are optimized to deal with per CPU queues/structures (fast path)
> 
> skb recycling is an interesting technique because typical NIC handles RX & TX completion
> in one CPU at the same time, thus we can reduce this slab/slub inter-CPU handling.

This matches my feeling on the situation.  And that's basically why I
applied the recycling infrastructure patches from Lennert :-)

> skb recycling has a (nice ?) side effect on NUMA platforms, not for forwarding workloads,
> (which are IMHO not the majority of linux machines workloads) but typical servers.
> 
> Current NIC drivers actually allocate their RX rings using the memory node
> close to the device.
> 
> With RX recycling, we are re-using skb that were allocated by the process itself,
> and this process is likely the one that will process received frames.

I am not so sure about this, however.

It's just trading one NUMA penalty for another.

Also, the device is going to interrupt on a particular cpu within the NUMA
node normally.  The scheduler will notice that socket wakeups happen there
and likely migrate the task there.
