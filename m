From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Sun, 23 Mar 2008 19:48:29 +0100
Message-ID: <47E6A5FD.6060407@cosmosbay.com>
References: <47BDC848.50607@cosmosbay.com>	<20080226.182120.183405235.davem@davemloft.net>	<47C92F49.4070100@cosmosbay.com> <20080323.032949.194309002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010000080409050408030405"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:43525
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754933AbYCWSsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 14:48:46 -0400
In-Reply-To: <20080323.032949.194309002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010000080409050408030405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a écrit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 01 Mar 2008 11:26:17 +0100
> 
>> [PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
> 
> Eric, did you get a chance to kernel stack usage stress this
> thing out like I asked?
> 

I noticed some paths in kernel are very stack aggressive, and on i386 with 
CONFIG_4KSTACKS we were really in a dangerous land, even without my patch.

What we call 4K stacks is in fact 4K - sizeof(struct task_struct), so a litle 
bit more than 2K. (not counting some insane configuration were struct 
task_struct take 3.5 KB, see CONFIG_LATENCYTOP for an example)

So I cooked a different patch that explicitly test available stack space 
instead of counting a depth value.

The problem is that this patch depends on CONFIG_STACK_GROWSUP and I had an 
issue with it
(see http://kerneltrap.org/mailarchive/linux-kernel/2008/3/5/1079774)
and I had no answer from Kyle or others on this subject.

So I had to disable the optimisation for HPPA arch (it seems the only arch 
that has CONFIG_STACK_GROWSUP)

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

We check available free stack space to take the decision of directly call 
netif_receive_skb() or queue the packet for further softirq handling, when 
stack space will be back to an acceptable level.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010000080409050408030405
Content-Type: text/plain;
 name="loopback.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="loopback.patch"

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index f2a6e71..656e29c 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -126,6 +126,17 @@ static void emulate_large_send_offload(struct sk_buff *skb)
 }
 #endif /* LOOPBACK_TSO */
 
+static int enough_stack_space(void)
+{
+#ifdef CONFIG_STACK_GROWSUP
+	return 0;
+#else
+	unsigned long free = (unsigned long)&free -
+			     (unsigned long)end_of_stack(current);
+	return free >= THREAD_SIZE/3 ;
+#endif
+}
+
 /*
  * The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
@@ -158,7 +169,14 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 	lb_stats->bytes += skb->len;
 	lb_stats->packets++;
 
-	netif_rx(skb);
+	/*
+	 * We can call netif_receive_skb() instead of netif_rx()
+	 * to speedup processing, but only if we have enough stack space.
+	 */
+	if (enough_stack_space())
+		netif_receive_skb(skb);
+	else
+		netif_rx(skb);
 
 	return 0;
 }

--------------010000080409050408030405--
