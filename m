From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 21:50:39 +1000
Message-ID: <20070510115039.GA24439@gondor.apana.org.au>
References: <1178725965.4058.75.camel@localhost> <OFF9085DDC.F5960247-ON652572D7.001B794E-652572D7.001CA7E2@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2722 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757228AbXEJLvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 07:51:07 -0400
Content-Disposition: inline
In-Reply-To: <OFF9085DDC.F5960247-ON652572D7.001B794E-652572D7.001CA7E2@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 10:42:59AM +0530, Krishna Kumar2 wrote:
> 
> But RUNNING is never relinquished till all the way back out to
> __qdisc_run. Only the lock is dropped before calling xmit and
> re-got after xmit is finished (all the while holding RUNNING).
> After xmit both queue_lock and RUNNING are held. If some other
> cpu enqueue'd during this release window (and they would have
> returned after dropping the lock as they are pure enqueuer's),
> qdisc_restart will find those skbs. Similarly if no skbs were
> added, qdisc_restart will return 0.

Yes I agree with Krishna completely.  In fact this whole section
is so 20th-century :) Let's fix up the comments too while we're
at it.

[NET_SCHED]: Rationalise return value of qdisc_restart

The current return value scheme and associated comment was invented
back in the 20th century when we still had that tbusy flag.  Things
have changed quite a bit since then (even Tony Blair is moving on
now, not to mention the new French president).

All we need to indicate now is whether the caller should continue
processing the queue.  Therefore it's sufficient if we return 0 if
we want to stop and non-zero otherwise.

This is based on a patch by Krishna Kumar.

Signed-off-by: <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 3385ee5..3480e81 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -71,12 +71,9 @@ void qdisc_unlock_tree(struct net_device *dev)
 
 
 /* Kick device.
-   Note, that this procedure can be called by a watchdog timer, so that
-   we do not check dev->tbusy flag here.
 
-   Returns:  0  - queue is empty.
-	    >0  - queue is not empty, but throttled.
-	    <0  - queue is not empty. Device is throttled, if dev->tbusy != 0.
+   Returns:  0  - queue is empty or throttled.
+	    >0  - queue is not empty.
 
    NOTE: Called under dev->queue_lock with locally disabled BH.
 */
@@ -115,7 +112,7 @@ static inline int qdisc_restart(struct net_device *dev)
 					kfree_skb(skb);
 					if (net_ratelimit())
 						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
-					return -1;
+					goto out;
 				}
 				__get_cpu_var(netdev_rx_stat).cpu_collision++;
 				goto requeue;
@@ -135,7 +132,7 @@ static inline int qdisc_restart(struct net_device *dev)
 						netif_tx_unlock(dev);
 					}
 					spin_lock(&dev->queue_lock);
-					return -1;
+					goto out;
 				}
 				if (ret == NETDEV_TX_LOCKED && nolock) {
 					spin_lock(&dev->queue_lock);
@@ -168,8 +165,10 @@ requeue:
 		else
 			q->ops->requeue(skb, q);
 		netif_schedule(dev);
-		return 1;
+		return 0;
 	}
+
+out:
 	BUG_ON((int) q->q.qlen < 0);
 	return q->q.qlen;
 }
@@ -179,8 +178,10 @@ void __qdisc_run(struct net_device *dev)
 	if (unlikely(dev->qdisc == &noop_qdisc))
 		goto out;
 
-	while (qdisc_restart(dev) < 0 && !netif_queue_stopped(dev))
-		/* NOTHING */;
+	do {
+		if (!qdisc_restart(dev))
+			break;
+	} while (!netif_queue_stopped(dev));
 
 out:
 	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
