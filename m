From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI quota synchronization issue
Date: Wed, 19 Sep 2007 10:35:08 -0700 (PDT)
Message-ID: <20070919.103508.59469052.davem@davemloft.net>
References: <20070919.095825.39465358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762283AbXISRfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 13:35:09 -0400
In-Reply-To: <20070919.095825.39465358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 19 Sep 2007 09:58:25 -0700 (PDT)

> Probably a good way to deal with this is to simply make the quota
> handling stateless.
> 
> The only reason we handle partial quota usage is to handle the
> global netdev_budget.  But we can simply "round up" and let
> netdev_budget get oversubscribed by one napi->quota's worth
> if necessary.
> 
> At that point, n->quota only holds two states when used, full
> and empty.  And at that point there is no reason to maintain
> it's value at all.  Only the weight is necessary.
> 
> I'll try to post a patch which implements this later today.

Ok, here is the patch and I've checked it into net-2.6.24 as well.

There really shouldn't be any fundamental synchronization issues
in the new NAPI stuff any longer.  I'm pretty sure any problems
remaining can only be caused by drivers bugs but we'll see :-)

I went over the list handling several times and it looks bulletproof.
Only the thread of control that sets the NAPI_STATE_SCHED bit
atomically will do list modifications, until the thread of control
that decides unconditionally to clear the bit, which will do a
list_del() immediately before clearing that bit.

commit d97459caa5dc97b5da0b9be1ec3f107f3c58d7f9
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Sep 19 10:31:58 2007 -0700

    [NAPI]: Make quota management stateless.
    
    Because we update the napi->quota after returning from
    napi->poll() we have races which can, among other things,
    allow napi->quota to go negative.
    
    For example, if the driver uses the NAPI resched mechanism
    it typically does a completion like this:
    
    	netif_rx_complete(dev, napi);
    	if (unlikely(more_work_showed_up(priv))) {
    		if (netif_rx_reschedule(dev, napi))
    			goto poll_more;
    	}
    	return work_done;
    
    Between the netif_rx_complete() and the netif_rx_reschedule()
    an interrupt on another cpu can schedule the NAPI.  Which is
    fine and handled by the checking of the netif_rx_reschedule()
    return value, but when it happens:
    
    1) The other cpu can do a rull ->poll() run, and update the
       napi->quota
    2) The current thread of execution returns and updates
       napi->quota too
    
    So #1 uses a not-updated napi->quota value, and #2 over
    subtracts from napi->quota.
    
    In short napi->quota access is not synchronized enough.
    
    The good news it that we don't really need it in the first
    place.  The only time we can have partial napi->quota
    updates is when we are trying to adhere to netdev_budget
    in the polling loop of net_rx_action().
    
    We can allow a slight oversubscription of netdev_budget,
    but at most one napi->weight, and that is harmless.
    
    Given that, napi->quota takes on only two values when used,
    the full napi->weight and zero.  Therefore it is entirely
    superfluous and we can always pass napi->weight down to
    the ->poll() routine, and kill off napi->quota and all the
    synchronization problems.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bc88e4c..cf89ce6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -294,7 +294,6 @@ struct napi_struct {
 
 	unsigned long		state;
 	int			weight;
-	int			quota;
 	int			(*poll)(struct napi_struct *, int);
 #ifdef CONFIG_NETPOLL
 	spinlock_t		poll_lock;
diff --git a/net/core/dev.c b/net/core/dev.c
index 471e59d..0b9f82e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2107,13 +2107,6 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	return work;
 }
 
-static void napi_check_quota_bug(struct napi_struct *n)
-{
-	/* It is illegal to consume more than the given quota.  */
-	if (WARN_ON_ONCE(n->quota < 0))
-		n->quota = 0;
-}
-
 /**
  * __napi_schedule - schedule for receive
  * @napi: entry to schedule
@@ -2124,9 +2117,6 @@ void fastcall __napi_schedule(struct napi_struct *n)
 {
 	unsigned long flags;
 
-	napi_check_quota_bug(n);
-	n->quota = n->weight;
-
 	local_irq_save(flags);
 	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
 	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
@@ -2146,6 +2136,7 @@ static void net_rx_action(struct softirq_action *h)
 
 	while (!list_empty(list)) {
 		struct napi_struct *n;
+		int work;
 
 		/* If softirq window is exhuasted then punt.
 		 *
@@ -2168,27 +2159,21 @@ static void net_rx_action(struct softirq_action *h)
 
 		have = netpoll_poll_lock(n);
 
-		/* if quota not exhausted process work */
-		if (likely(n->quota > 0)) {
-			int work = n->poll(n, min(budget, n->quota));
+		work = n->poll(n, n->weight);
 
-			budget -= work;
-			n->quota -= work;
-		}
+		WARN_ON_ONCE(work > n->weight);
 
-		local_irq_disable();
+		budget -= work;
 
-		napi_check_quota_bug(n);
+		local_irq_disable();
 
 		/* Drivers must not modify the NAPI state if they
-		 * consume the entire quota.  In such cases this code
+		 * consume the entire weight.  In such cases this code
 		 * still "owns" the NAPI instance and therefore can
 		 * move the instance around on the list at-will.
 		 */
-		if (unlikely(!n->quota)) {
-			n->quota = n->weight;
+		if (unlikely(work == n->weight))
 			list_move_tail(&n->poll_list, list);
-		}
 
 		netpoll_poll_unlock(have);
 	}
