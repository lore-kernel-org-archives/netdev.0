From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 15:57:23 -0700 (PDT)
Message-ID: <20080817.155723.214209606.davem@davemloft.net>
References: <20080814083336.GA452@gondor.apana.org.au>
	<20080814084429.GB12217@ff.dom.local>
	<20080814085250.GC12217@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58412
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752452AbYHQW5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 18:57:24 -0400
In-Reply-To: <20080814085250.GC12217@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 14 Aug 2008 08:52:50 +0000

> On the other hand... such a flag would be probably for one thing only.
> And if we would have a "netif_scheduled_without_xmitting" counter this
> could probably make 2 in 1?

Here is how I propose to plug this hole.  The issue is that there is
this potential gap where both bits are clear while there is a context
that can reschedule the qdisc.

And I'm pretty sure the most desirable fix is to get rid of that gap
if it can easily be done.

It seems like it can be.  What we do in the patch below is something
like this:

1) The one code path that can leave both bits clear then reschedule
   is changed to only leave that state visible while holding the
   root qdisc's lock.

   All other code paths will not reschedule once they clear the bits.

2) dev_deactivate() unconditionally takes the root qdisc spinlock
   and just waits for both bits to clear.  This is now entirely
   sufficient to ensure that no pending runs of the qdisc remain.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 600bb23..896393d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1338,20 +1338,27 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 	rcu_read_unlock();
 }
 
+/* We own the __QDISC_STATE_SCHED state bit, and know that
+ * we are the only entity which can schedule this qdisc on
+ * the output queue.
+ */
+static void __qdisc_schedule(struct Qdisc *q)
+{
+	struct softnet_data *sd;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	sd = &__get_cpu_var(softnet_data);
+	q->next_sched = sd->output_queue;
+	sd->output_queue = q;
+	raise_softirq_irqoff(NET_TX_SOFTIRQ);
+	local_irq_restore(flags);
+}
 
 void __netif_schedule(struct Qdisc *q)
 {
-	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
-		struct softnet_data *sd;
-		unsigned long flags;
-
-		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
-		q->next_sched = sd->output_queue;
-		sd->output_queue = q;
-		raise_softirq_irqoff(NET_TX_SOFTIRQ);
-		local_irq_restore(flags);
-	}
+	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state))
+		__qdisc_schedule(q);
 }
 EXPORT_SYMBOL(__netif_schedule);
 
@@ -1974,15 +1981,13 @@ static void net_tx_action(struct softirq_action *h)
 
 			head = head->next_sched;
 
-			smp_mb__before_clear_bit();
-			clear_bit(__QDISC_STATE_SCHED, &q->state);
-
 			root_lock = qdisc_lock(q);
 			if (spin_trylock(root_lock)) {
+				clear_bit(__QDISC_STATE_SCHED, &q->state);
 				qdisc_run(q);
 				spin_unlock(root_lock);
 			} else {
-				__netif_schedule(q);
+				__qdisc_schedule(q);
 			}
 		}
 	}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4685746..d6ac170 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -647,7 +647,7 @@ static void dev_deactivate_queue(struct net_device *dev,
 	}
 }
 
-static bool some_qdisc_is_busy(struct net_device *dev, int lock)
+static bool some_qdisc_is_busy(struct net_device *dev)
 {
 	unsigned int i;
 
@@ -661,14 +661,12 @@ static bool some_qdisc_is_busy(struct net_device *dev, int lock)
 		q = dev_queue->qdisc_sleeping;
 		root_lock = qdisc_lock(q);
 
-		if (lock)
-			spin_lock_bh(root_lock);
+		spin_lock_bh(root_lock);
 
 		val = (test_bit(__QDISC_STATE_RUNNING, &q->state) ||
 		       test_bit(__QDISC_STATE_SCHED, &q->state));
 
-		if (lock)
-			spin_unlock_bh(root_lock);
+		spin_unlock_bh(root_lock);
 
 		if (val)
 			return true;
@@ -689,25 +687,8 @@ void dev_deactivate(struct net_device *dev)
 	synchronize_rcu();
 
 	/* Wait for outstanding qdisc_run calls. */
-	do {
-		while (some_qdisc_is_busy(dev, 0))
-			yield();
-
-		/*
-		 * Double-check inside queue lock to ensure that all effects
-		 * of the queue run are visible when we return.
-		 */
-		running = some_qdisc_is_busy(dev, 1);
-
-		/*
-		 * The running flag should never be set at this point because
-		 * we've already set dev->qdisc to noop_qdisc *inside* the same
-		 * pair of spin locks.  That is, if any qdisc_run starts after
-		 * our initial test it should see the noop_qdisc and then
-		 * clear the RUNNING bit before dropping the queue lock.  So
-		 * if it is set here then we've found a bug.
-		 */
-	} while (WARN_ON_ONCE(running));
+	while (some_qdisc_is_busy(dev))
+		yield();
 }
 
 static void dev_init_scheduler_queue(struct net_device *dev,
