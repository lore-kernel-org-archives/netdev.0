From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 05/10]: sch_netem: use hrtimer based watchdog
Date: Fri, 16 Mar 2007 06:30:55 +0100 (MET)
Message-ID: <20070316053025.22744.84861.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45263 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319AbXCPFa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:56 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_netem: use hrtimer based watchdog

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b0b8ce02c1564f86f09a0ccb728327d02cf202f0
tree 54ac4c91460fa9b34542dfc5dcbd9a796b037950
parent 7acf6ee9c08fdbf5cb24b15d95432eef07506a38
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:28 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:28 +0100

 net/sched/sch_netem.c |   25 +++++--------------------
 1 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 1ccbfb5..915f82a 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -54,7 +54,7 @@ #define VERSION "1.2"
 
 struct netem_sched_data {
 	struct Qdisc	*qdisc;
-	struct timer_list timer;
+	struct qdisc_watchdog watchdog;
 
 	u32 latency;
 	u32 loss;
@@ -284,7 +284,7 @@ static struct sk_buff *netem_dequeue(str
 			sch->flags &= ~TCQ_F_THROTTLED;
 			return skb;
 		} else {
-			psched_tdiff_t delay = PSCHED_TDIFF(cb->time_to_send, now);
+			qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 
 			if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
 				qdisc_tree_decrease_qlen(q->qdisc, 1);
@@ -292,32 +292,19 @@ static struct sk_buff *netem_dequeue(str
 				printk(KERN_ERR "netem: queue discpline %s could not requeue\n",
 				       q->qdisc->ops->id);
 			}
-
-			mod_timer(&q->timer, jiffies + PSCHED_US2JIFFIE(delay));
-			sch->flags |= TCQ_F_THROTTLED;
 		}
 	}
 
 	return NULL;
 }
 
-static void netem_watchdog(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc *)arg;
-
-	pr_debug("netem_watchdog qlen=%d\n", sch->q.qlen);
-	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule(sch->dev);
-}
-
 static void netem_reset(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
-	sch->flags &= ~TCQ_F_THROTTLED;
-	del_timer_sync(&q->timer);
+	qdisc_watchdog_cancel(&q->watchdog);
 }
 
 /* Pass size change message down to embedded FIFO */
@@ -567,9 +554,7 @@ static int netem_init(struct Qdisc *sch,
 	if (!opt)
 		return -EINVAL;
 
-	init_timer(&q->timer);
-	q->timer.function = netem_watchdog;
-	q->timer.data = (unsigned long) sch;
+	qdisc_watchdog_init(&q->watchdog, sch);
 
 	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
 				     TC_H_MAKE(sch->handle, 1));
@@ -590,7 +575,7 @@ static void netem_destroy(struct Qdisc *
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
-	del_timer_sync(&q->timer);
+	qdisc_watchdog_cancel(&q->watchdog);
 	qdisc_destroy(q->qdisc);
 	kfree(q->delay_dist);
 }
