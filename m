From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Prevent transmission after dev_deactivate
Date: Thu, 22 Jun 2006 18:08:56 +1000
Message-ID: <20060622080856.GA21723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:7428 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932337AbWFVIJD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:09:03 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

I found a bug in my GSO patches with the shutdown handling in
dev_deactivate.  It provided enough impetus for me to finally
clean up this function :)

This patch is against Linus's tree.

[NET]: Prevent transmission after dev_deactivate

The dev_deactivate function has bit-rotted since the introduction of
lockless drivers.  In particular, the spin_unlock_wait call at the end
has no effect on the xmit routine of lockless drivers.

With a little bit of work, we can make it much more useful by providing
the guarantee that when it returns, no more calls to the xmit routine
of the underlying driver will be made.

The idea is simple.  There are two entry points in to the xmit routine.
The first comes from dev_queue_xmit.  That one is easily stopped by
using synchronize_rcu.  This works because we set the qdisc to noop_qdisc
before the synchronize_rcu call.  That in turn causes all subsequent
packets sent to dev_queue_xmit to be dropped.  The synchronize_rcu call
also ensures all outstanding calls leave their critical section.

The other entry point is from qdisc_run.  Since we now have a bit that
indicates whether it's running, all we have to do is to wait until the
bit is off.

I've removed the loop to wait for __LINK_STATE_SCHED to clear.  This is
useless because netif_wake_queue can cause it to be set again.  It is
also harmless because we've disarmed qdisc_run.

I've also removed the spin_unlock_wait on xmit_lock because its only
purpose of making sure that all outstanding xmit_lock holders have
exited is also given by dev_watchdog_down.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
1201ce3ea54baa35bcecf9925bf9d788e084d895
diff --git a/net/core/dev.c b/net/core/dev.c
index ab39fe1..29e3888 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1295,7 +1295,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	/* Disable soft irqs for various locks below. Also 
 	 * stops preemption for RCU. 
 	 */
-	local_bh_disable(); 
+	rcu_read_lock_bh(); 
 
 	/* Updates of qdisc are serialized by queue_lock. 
 	 * The struct Qdisc which is pointed to by qdisc is now a 
@@ -1369,13 +1369,13 @@ #endif
 	}
 
 	rc = -ENETDOWN;
-	local_bh_enable();
+	rcu_read_unlock_bh();
 
 out_kfree_skb:
 	kfree_skb(skb);
 	return rc;
 out:
-	local_bh_enable();
+	rcu_read_unlock_bh();
 	return rc;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d7aca8e..7aad012 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -181,9 +181,13 @@ requeue:
 
 void __qdisc_run(struct net_device *dev)
 {
+	if (unlikely(dev->qdisc == &noop_qdisc))
+		goto out;
+
 	while (qdisc_restart(dev) < 0 && !netif_queue_stopped(dev))
 		/* NOTHING */;
 
+out:
 	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
 }
 
@@ -583,10 +587,12 @@ void dev_deactivate(struct net_device *d
 
 	dev_watchdog_down(dev);
 
-	while (test_bit(__LINK_STATE_SCHED, &dev->state))
-		yield();
+	/* Wait for outstanding dev_queue_xmit calls. */
+	synchronize_rcu();
 
-	spin_unlock_wait(&dev->_xmit_lock);
+	/* Wait for outstanding qdisc_run calls. */
+	while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
+		yield();
 }
 
 void dev_init_scheduler(struct net_device *dev)
