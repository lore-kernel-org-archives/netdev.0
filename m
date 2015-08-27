From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 4/4] net: sched: simplify attach_one_default_qdisc()
Date: Thu, 27 Aug 2015 21:21:39 +0200
Message-ID: <1440703299-21243-5-git-send-email-phil@nwl.cc>
References: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com,
	geert@linux-m68k.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38014 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752252AbbH0TVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 15:21:41 -0400
In-Reply-To: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that noqueue qdisc can be attached just like any other qdisc, no
special treatment is necessary anymore when attaching it as default
qdisc.

This change has the added benefit that 'tc qdisc show' prints noqueue
instead of nothing for devices defaulting to noqueue.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sched/sch_generic.c | 41 ++++++++++++-----------------------------
 1 file changed, 12 insertions(+), 29 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d5c7c0d..cb5d4ad 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -435,24 +435,6 @@ struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
-static struct Qdisc noqueue_qdisc;
-static struct netdev_queue noqueue_netdev_queue = {
-	.qdisc		=	&noqueue_qdisc,
-	.qdisc_sleeping	=	&noqueue_qdisc,
-};
-
-static struct Qdisc noqueue_qdisc = {
-	.enqueue	=	NULL,
-	.dequeue	=	noop_dequeue,
-	.flags		=	TCQ_F_BUILTIN,
-	.ops		=	&noqueue_qdisc_ops,
-	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
-	.q.lock		=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
-	.dev_queue	=	&noqueue_netdev_queue,
-	.busylock	=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.busylock),
-};
-
-
 static const u8 prio2band[TC_PRIO_MAX + 1] = {
 	1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
 };
@@ -743,18 +725,19 @@ static void attach_one_default_qdisc(struct net_device *dev,
 				     struct netdev_queue *dev_queue,
 				     void *_unused)
 {
-	struct Qdisc *qdisc = &noqueue_qdisc;
+	struct Qdisc *qdisc;
+	const struct Qdisc_ops *ops = default_qdisc_ops;
 
-	if (!(dev->priv_flags & IFF_NO_QUEUE)) {
-		qdisc = qdisc_create_dflt(dev_queue,
-					  default_qdisc_ops, TC_H_ROOT);
-		if (!qdisc) {
-			netdev_info(dev, "activation failed\n");
-			return;
-		}
-		if (!netif_is_multiqueue(dev))
-			qdisc->flags |= TCQ_F_ONETXQUEUE;
+	if (dev->priv_flags & IFF_NO_QUEUE)
+		ops = &noqueue_qdisc_ops;
+
+	qdisc = qdisc_create_dflt(dev_queue, ops, TC_H_ROOT);
+	if (!qdisc) {
+		netdev_info(dev, "activation failed\n");
+		return;
 	}
+	if (!netif_is_multiqueue(dev))
+		qdisc->flags |= TCQ_F_ONETXQUEUE;
 	dev_queue->qdisc_sleeping = qdisc;
 }
 
@@ -790,7 +773,7 @@ static void transition_one_qdisc(struct net_device *dev,
 		clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
 
 	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
-	if (need_watchdog_p && new_qdisc != &noqueue_qdisc) {
+	if (need_watchdog_p) {
 		dev_queue->trans_start = 0;
 		*need_watchdog_p = 1;
 	}
-- 
2.1.2
