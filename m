From: David Miller <davem@davemloft.net>
Subject: Re: Kernel oops in 2.6.27-rc1 qdisc.
Date: Wed, 30 Jul 2008 02:44:07 -0700 (PDT)
Message-ID: <20080730.024407.193695281.davem@davemloft.net>
References: <200807291923.22803.steven@springl.ukfsn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: steven@springl.ukfsn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34339
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759506AbYG3JoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 05:44:08 -0400
In-Reply-To: <200807291923.22803.steven@springl.ukfsn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Jan Springl <steven@springl.ukfsn.org>
Date: Tue, 29 Jul 2008 19:23:22 +0100

> Issuing the following command causes a kernel oops:
> 	tc qdisc add dev eth0 handle ffff: ingress
> 
> The problem is recreatable.
> The kernel is 2.6.27-rc1.
> I am using Debian etch.
> 
> The oops is attached.

This will fix it, thanks for your report:

pkt_sched: Fix OOPS on ingress qdisc add.

Bug report from Steven Jan Springl:

	Issuing the following command causes a kernel oops:
		tc qdisc add dev eth0 handle ffff: ingress

The problem mostly stems from all of the special case handling of
ingress qdiscs.

So, to fix this, do the grafting operation the same way we do for TX
qdiscs.  Which means that dev_activate() and dev_deactivate() now do
the "qdisc_sleeping <--> qdisc" transitions on dev->rx_queue too.

Future simplifications are possible now, mainly because it is
impossible for dev_queue->{qdisc,qdisc_sleeping} to be NULL.  There
are NULL checks all over to handle the ingress qdisc special case
that used to exist before this commit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c          |    4 +-
 net/sched/sch_api.c     |   57 +++++++++++++---------------------------------
 net/sched/sch_generic.c |    8 ++++--
 3 files changed, 23 insertions(+), 46 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8d13a9b..63d6bcd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2100,7 +2100,7 @@ static int ing_filter(struct sk_buff *skb)
 	rxq = &dev->rx_queue;
 
 	q = rxq->qdisc;
-	if (q) {
+	if (q != &noop_qdisc) {
 		spin_lock(qdisc_lock(q));
 		result = qdisc_enqueue_root(skb, q);
 		spin_unlock(qdisc_lock(q));
@@ -2113,7 +2113,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	if (!skb->dev->rx_queue.qdisc)
+	if (skb->dev->rx_queue.qdisc == &noop_qdisc)
 		goto out;
 
 	if (*pt_prev) {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b060164..4840aff 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -572,44 +572,21 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 static struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 				     struct Qdisc *qdisc)
 {
+	struct Qdisc *oqdisc = dev_queue->qdisc_sleeping;
 	spinlock_t *root_lock;
-	struct Qdisc *oqdisc;
-	int ingress;
-
-	ingress = 0;
-	if (qdisc && qdisc->flags&TCQ_F_INGRESS)
-		ingress = 1;
-
-	if (ingress) {
-		oqdisc = dev_queue->qdisc;
-	} else {
-		oqdisc = dev_queue->qdisc_sleeping;
-	}
 
 	root_lock = qdisc_root_lock(oqdisc);
 	spin_lock_bh(root_lock);
 
-	if (ingress) {
-		/* Prune old scheduler */
-		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1) {
-			/* delete */
-			qdisc_reset(oqdisc);
-			dev_queue->qdisc = NULL;
-		} else {  /* new */
-			dev_queue->qdisc = qdisc;
-		}
+	/* Prune old scheduler */
+	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
+		qdisc_reset(oqdisc);
 
-	} else {
-		/* Prune old scheduler */
-		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
-			qdisc_reset(oqdisc);
-
-		/* ... and graft new one */
-		if (qdisc == NULL)
-			qdisc = &noop_qdisc;
-		dev_queue->qdisc_sleeping = qdisc;
-		dev_queue->qdisc = &noop_qdisc;
-	}
+	/* ... and graft new one */
+	if (qdisc == NULL)
+		qdisc = &noop_qdisc;
+	dev_queue->qdisc_sleeping = qdisc;
+	dev_queue->qdisc = &noop_qdisc;
 
 	spin_unlock_bh(root_lock);
 
@@ -678,7 +655,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 
 		ingress = 0;
 		num_q = dev->num_tx_queues;
-		if (q && q->flags & TCQ_F_INGRESS) {
+		if ((q && q->flags & TCQ_F_INGRESS) ||
+		    (new && new->flags & TCQ_F_INGRESS)) {
 			num_q = 1;
 			ingress = 1;
 		}
@@ -692,13 +670,10 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 			if (!ingress)
 				dev_queue = netdev_get_tx_queue(dev, i);
 
-			if (ingress) {
-				old = dev_graft_qdisc(dev_queue, q);
-			} else {
-				old = dev_graft_qdisc(dev_queue, new);
-				if (new && i > 0)
-					atomic_inc(&new->refcnt);
-			}
+			old = dev_graft_qdisc(dev_queue, new);
+			if (new && i > 0)
+				atomic_inc(&new->refcnt);
+
 			notify_and_destroy(skb, n, classid, old, new);
 		}
 
@@ -817,7 +792,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out3;
 			}
 		}
-		if (parent)
+		if (parent && !(sch->flags & TCQ_F_INGRESS))
 			list_add_tail(&sch->list, &dev_queue->qdisc->list);
 
 		return sch;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index fd2a6ca..345838a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -596,7 +596,7 @@ static void transition_one_qdisc(struct net_device *dev,
 	int *need_watchdog_p = _need_watchdog;
 
 	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
-	if (new_qdisc != &noqueue_qdisc)
+	if (need_watchdog_p && new_qdisc != &noqueue_qdisc)
 		*need_watchdog_p = 1;
 }
 
@@ -619,6 +619,7 @@ void dev_activate(struct net_device *dev)
 
 	need_watchdog = 0;
 	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog);
+	transition_one_qdisc(dev, &dev->rx_queue, NULL);
 
 	if (need_watchdog) {
 		dev->trans_start = jiffies;
@@ -677,6 +678,7 @@ void dev_deactivate(struct net_device *dev)
 	bool running;
 
 	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
+	dev_deactivate_queue(dev, &dev->rx_queue, &noop_qdisc);
 
 	dev_watchdog_down(dev);
 
@@ -718,7 +720,7 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 void dev_init_scheduler(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
-	dev_init_scheduler_queue(dev, &dev->rx_queue, NULL);
+	dev_init_scheduler_queue(dev, &dev->rx_queue, &noop_qdisc);
 
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
@@ -745,6 +747,6 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 void dev_shutdown(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
-	shutdown_scheduler_queue(dev, &dev->rx_queue, NULL);
+	shutdown_scheduler_queue(dev, &dev->rx_queue, &noop_qdisc);
 	WARN_ON(timer_pending(&dev->watchdog_timer));
 }
-- 
1.5.6.GIT

