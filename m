From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Thu, 21 Feb 2008 21:14:45 +0100
Message-ID: <47BDDBB5.1050603@fr.ibm.com>
References: <47BDC848.50607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:23236 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756343AbYBUUXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 15:23:44 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m1LKNhWg271212
	for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 20:23:43 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1LKNhLr1396780
	for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 21:23:43 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1LKNgAi015113
	for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 21:23:43 +0100
In-Reply-To: <47BDC848.50607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Hi David
> 
> This is an RFC, based on net-2.6 for convenience only.
> 
> Thank you
> 
> [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
> 
> Loopback transmit function loopback_xmit() actually calls netif_rx() to 
> queue
> a skb to the softnet queue, and arms a softirq so that this skb can be 
> handled later.
> 
> This has a cost on SMP, because we need to hold a reference on the 
> device, and free this
> reference when softirq dequeues packet.
> 
> Following patch directly calls netif_receive_skb() and avoids lot of 
> atomic operations.
> (atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED, &n->state), 
> ...
>  atomic_dec(&dev->refcnt)...), cache line ping-pongs on device refcnt, 
> but also softirq overhead.
> 
> This gives a nice boost on tbench for example (5 % on my machine)

I understand this is interesting for the loopback when there is no 
multiple instances of it and it can't be unregistered. But now with the 
network namespaces, we can have multiple instances of the loopback and 
it can to be unregistered. Shouldn't we still use netif_rx ?
Perhaps we can do something like:

	if (dev->nd_net == &init_net)
		netif_receive_skb(skb);
	else
		netif_rx(skb);

Or we create:
	init_loopback_xmit() calling netif_receive_skb(skb);
	and setup this function when creating the loopback for init_net,
	otherwise we setup the usual loopback_xmit.

We are still safe for multiple network namespaces and we have the 
improvement for init_net loopback.




