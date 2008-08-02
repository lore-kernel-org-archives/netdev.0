From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Fri, 01 Aug 2008 18:20:28 -0700 (PDT)
Message-ID: <20080801.182028.74132050.davem@davemloft.net>
References: <9929d2390808011640o58453023s623faa8930064505@mail.gmail.com>
	<20080801.180337.233358413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56777
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751496AbYHBBU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 21:20:29 -0400
In-Reply-To: <20080801.180337.233358413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 01 Aug 2008 18:03:37 -0700 (PDT)

> Looks like two threads are accessing the qdisc SKB lists but one of
> them isn't taking the proper qdisc locks.
> 
> I can't see how this can happen currently but I'll try to figure it
> out.

I see what's going on.

Once we decide on a root qdisc to process, we shouldn't use
qdisc_root_lock() since that will resample qdisc->dev_queue->qdisc
which might be different.

This points out a core problem, and I might need to add a
root_qdisc backpointer to struct Qdisc to make this all work
out sanely for all cases.

Anyways, please try this patch:

pkt_sched: Use qdisc_lock() on already sampled root qdisc.

Don't use qdisc_root_lock() in these cases as the root
qdisc could have been changed, and we'd thus lock the
wrong object.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9c9cd4d..113b6b0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -29,7 +29,7 @@
 /* Main transmission queue. */
 
 /* Modifications to data participating in scheduling must be protected with
- * qdisc_root_lock(qdisc) spinlock.
+ * qdisc_lock(qdisc) spinlock.
  *
  * The idea is the following:
  * - enqueue, dequeue are serialized via qdisc root lock
@@ -126,7 +126,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	if (unlikely((skb = dequeue_skb(q)) == NULL))
 		return 0;
 
-	root_lock = qdisc_root_lock(q);
+	root_lock = qdisc_lock(q);
 
 	/* And release qdisc */
 	spin_unlock(root_lock);
@@ -659,7 +659,7 @@ static bool some_qdisc_is_running(struct net_device *dev, int lock)
 
 		dev_queue = netdev_get_tx_queue(dev, i);
 		q = dev_queue->qdisc;
-		root_lock = qdisc_root_lock(q);
+		root_lock = qdisc_lock(q);
 
 		if (lock)
 			spin_lock_bh(root_lock);
