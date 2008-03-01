From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Sat, 01 Mar 2008 11:26:17 +0100
Message-ID: <47C92F49.4070100@cosmosbay.com>
References: <47BDC848.50607@cosmosbay.com> <20080226.182120.183405235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050806050101050604050707"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:57887
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754762AbYCAK03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 05:26:29 -0500
In-Reply-To: <20080226.182120.183405235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050806050101050604050707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a écrit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 21 Feb 2008 19:51:52 +0100
> 
>> Following patch directly calls netif_receive_skb() and avoids lot of 
>> atomic operations.
>> (atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED, &n->state), ...
>>   atomic_dec(&dev->refcnt)...), cache line ping-pongs on device refcnt, 
>> but also softirq overhead.
>>
>> This gives a nice boost on tbench for example (5 % on my machine)
> 
> My only concern is stack usage.
> 
> Note that packet reception can elicit a response and go all the way
> back into this driver and all the way down into netif_receive_skb()
> again.  And so on and so forth.
> 
> If there is some bug in the stack (ACK'ing ACKs, stuff like that) we
> could get into a loop and overrun the kernel stack in no time at all.
> 
> So, if anything, this change could make inconvenient errors become
> catastrophic and hard to diagnose.

You are absolutly right. We should guard against recursion, using a new field 
in "pcpu_lstats" (cheap access in a hot cache line as we have to update stats 
anyway)

Thank you

[PATCH] loopback: calls netif_receive_skb() instead of netif_rx()

Loopback transmit function loopback_xmit() actually calls netif_rx() to queue 
a skb to the softnet queue, and arms a softirq so that this skb can be handled 
later.

This has a cost on SMP, because we need to hold a reference on the device, and 
free this reference when softirq dequeues packet.

Following patch directly calls netif_receive_skb() and avoids lot of atomic 
operations.

(atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED, &n->state), ...
atomic_dec(&dev->refcnt)...), cache line ping-pongs on device refcnt, but also 
softirq overhead.

This gives a nice boost on tbench for example (5 % on my machine)

We want to limit recursion, in case network stack wants to re-enter 
loopback_xmit(). We use a depth field (per cpu), so that we avoid stack 
overflow, queueing the packet instead of trying to directly handle it.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------050806050101050604050707
Content-Type: text/plain;
 name="loopback.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="loopback.patch"

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index f2a6e71..c1d0956 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -62,6 +62,7 @@
 struct pcpu_lstats {
 	unsigned long packets;
 	unsigned long bytes;
+	int	      depth;
 };
 
 /* KISS: just allocate small chunks and copy bits.
@@ -158,8 +159,16 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 	lb_stats->bytes += skb->len;
 	lb_stats->packets++;
 
-	netif_rx(skb);
-
+	/*
+	 * We can call netif_receive_skb() instead of netif_rx()
+	 * to speedup processing, but not in case of recursion,
+	 * or we risk stack overflow.
+	 */
+	if (lb_stats->depth++ == 0)
+		netif_receive_skb(skb);
+	else
+		netif_rx(skb);
+	lb_stats->depth--;
 	return 0;
 }
 

--------------050806050101050604050707--
