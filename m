From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/5] netem: avoid excessive requeues
Date: Wed, 21 Mar 2007 10:42:35 -0700
Message-ID: <20070321174422.767901837@linux-foundation.org>
References: <20070321174231.890361963@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46930 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933304AbXCUR7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 13:59:03 -0400
Content-Disposition: inline; filename=netem-throttle-opt.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netem code would call getnstimeofday() and dequeue/requeue after
every packet, even if it was waiting. Avoid this overhead by using
the throttled flag.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/sched/sch_api.c   |    3 +++
 net/sched/sch_netem.c |   21 ++++++++++++---------
 2 files changed, 15 insertions(+), 9 deletions(-)

--- net-2.6.22.orig/net/sched/sch_api.c
+++ net-2.6.22/net/sched/sch_api.c
@@ -298,6 +298,7 @@ static enum hrtimer_restart qdisc_watchd
 						 timer);
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
+	smp_wmb();
 	netif_schedule(wd->qdisc->dev);
 	return HRTIMER_NORESTART;
 }
@@ -315,6 +316,7 @@ void qdisc_watchdog_schedule(struct qdis
 	ktime_t time;
 
 	wd->qdisc->flags |= TCQ_F_THROTTLED;
+	smp_wmb();
 	time = ktime_set(0, 0);
 	time = ktime_add_ns(time, PSCHED_US2NS(expires));
 	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
@@ -325,6 +327,7 @@ void qdisc_watchdog_cancel(struct qdisc_
 {
 	hrtimer_cancel(&wd->timer);
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
+	smp_wmb();
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
 
--- net-2.6.22.orig/net/sched/sch_netem.c
+++ net-2.6.22/net/sched/sch_netem.c
@@ -272,6 +272,10 @@ static struct sk_buff *netem_dequeue(str
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
+	smp_mb();
+	if (sch->flags & TCQ_F_THROTTLED)
+		return NULL;
+
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb
@@ -284,18 +288,17 @@ static struct sk_buff *netem_dequeue(str
 		if (PSCHED_TLESS(cb->time_to_send, now)) {
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
-			sch->flags &= ~TCQ_F_THROTTLED;
 			return skb;
-		} else {
-			qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
+		}
 
-			if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
-				qdisc_tree_decrease_qlen(q->qdisc, 1);
-				sch->qstats.drops++;
-				printk(KERN_ERR "netem: queue discpline %s could not requeue\n",
-				       q->qdisc->ops->id);
-			}
+		if (unlikely(q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
+			qdisc_tree_decrease_qlen(q->qdisc, 1);
+			sch->qstats.drops++;
+			printk(KERN_ERR "netem: %s could not requeue\n",
+			       q->qdisc->ops->id);
 		}
+
+		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 	}
 
 	return NULL;

-- 

