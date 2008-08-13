From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 02:25:49 -0700 (PDT)
Message-ID: <20080813.022549.203848195.davem@davemloft.net>
References: <20080813061317.GA4251@ff.dom.local>
	<20080812.231633.193696650.davem@davemloft.net>
	<20080813065302.GB4251@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750943AbYHMJZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:25:48 -0400
In-Reply-To: <20080813065302.GB4251@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 13 Aug 2008 06:53:03 +0000

> Otherwise, I think you would better send some code example with these
> flags, so we could be sure there is no misunderstanding around this.

Here it my concrete proposal for a fix.

pkt_sched: Fix queue quiescence testing in dev_deactivate().

Based upon discussions with Jarek P. and Herbert Xu.

First, we're testing the wrong qdisc.  We just reset the device
queue qdiscs to &noop_qdisc and checking it's state is completely
pointless here.

We want to wait until the previous qdisc that was sitting at
the ->qdisc pointer is not busy any more.  And that would be
->qdisc_sleeping.

Because of how we propagate the samples qdisc pointer down into
qdisc_run and friends via per-cpu ->output_queue and netif_schedule,
we have to wait also for the __QDISC_STATE_SCHED bit to clear as
well.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7cf83b3..4685746 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -647,7 +647,7 @@ static void dev_deactivate_queue(struct net_device *dev,
 	}
 }
 
-static bool some_qdisc_is_running(struct net_device *dev, int lock)
+static bool some_qdisc_is_busy(struct net_device *dev, int lock)
 {
 	unsigned int i;
 
@@ -658,13 +658,14 @@ static bool some_qdisc_is_running(struct net_device *dev, int lock)
 		int val;
 
 		dev_queue = netdev_get_tx_queue(dev, i);
-		q = dev_queue->qdisc;
+		q = dev_queue->qdisc_sleeping;
 		root_lock = qdisc_lock(q);
 
 		if (lock)
 			spin_lock_bh(root_lock);
 
-		val = test_bit(__QDISC_STATE_RUNNING, &q->state);
+		val = (test_bit(__QDISC_STATE_RUNNING, &q->state) ||
+		       test_bit(__QDISC_STATE_SCHED, &q->state));
 
 		if (lock)
 			spin_unlock_bh(root_lock);
@@ -689,14 +690,14 @@ void dev_deactivate(struct net_device *dev)
 
 	/* Wait for outstanding qdisc_run calls. */
 	do {
-		while (some_qdisc_is_running(dev, 0))
+		while (some_qdisc_is_busy(dev, 0))
 			yield();
 
 		/*
 		 * Double-check inside queue lock to ensure that all effects
 		 * of the queue run are visible when we return.
 		 */
-		running = some_qdisc_is_running(dev, 1);
+		running = some_qdisc_is_busy(dev, 1);
 
 		/*
 		 * The running flag should never be set at this point because
