From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Tue, 26 Feb 2008 18:21:20 -0800 (PST)
Message-ID: <20080226.182120.183405235.davem@davemloft.net>
References: <47BDC848.50607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753567AbYB0CUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 21:20:35 -0500
In-Reply-To: <47BDC848.50607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 21 Feb 2008 19:51:52 +0100

> Following patch directly calls netif_receive_skb() and avoids lot of 
> atomic operations.
> (atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED, &n->state), ...
>   atomic_dec(&dev->refcnt)...), cache line ping-pongs on device refcnt, 
> but also softirq overhead.
> 
> This gives a nice boost on tbench for example (5 % on my machine)

My only concern is stack usage.

Note that packet reception can elicit a response and go all the way
back into this driver and all the way down into netif_receive_skb()
again.  And so on and so forth.

If there is some bug in the stack (ACK'ing ACKs, stuff like that) we
could get into a loop and overrun the kernel stack in no time at all.

So, if anything, this change could make inconvenient errors become
catastrophic and hard to diagnose.
