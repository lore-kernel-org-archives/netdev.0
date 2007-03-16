From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 03/10]: sch_hfsc: use hrtimer based watchdog
Date: Fri, 16 Mar 2007 06:30:52 +0100 (MET)
Message-ID: <20070316053022.22744.21185.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45249 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281AbXCPFax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:53 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_hfsc: use hrtimer based watchdog

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 76728bda8872d54abd39cdc47d703384f735f7ea
tree 3563cceb7028b40160616835ef29bcef2523a0fb
parent 4d0baa5c06cb04a53d8c68ecc10f38a295f08d14
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:28 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:28 +0100

 net/sched/sch_hfsc.c |   32 +++++++-------------------------
 1 files changed, 7 insertions(+), 25 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 09cf6e4..49cae7d 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -59,7 +59,6 @@ #include <linux/spinlock.h>
 #include <linux/skbuff.h>
 #include <linux/string.h>
 #include <linux/slab.h>
-#include <linux/timer.h>
 #include <linux/list.h>
 #include <linux/rbtree.h>
 #include <linux/init.h>
@@ -192,7 +191,7 @@ struct hfsc_sched
 	struct list_head droplist;		/* active leaf class list (for
 						   dropping) */
 	struct sk_buff_head requeue;		/* requeued packet */
-	struct timer_list wd_timer;		/* watchdog timer */
+	struct qdisc_watchdog watchdog;		/* watchdog timer */
 };
 
 #define	HT_INFINITY	0xffffffffffffffffULL	/* infinite time value */
@@ -1432,21 +1431,11 @@ hfsc_walk(struct Qdisc *sch, struct qdis
 }
 
 static void
-hfsc_watchdog(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc *)arg;
-
-	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule(sch->dev);
-}
-
-static void
-hfsc_schedule_watchdog(struct Qdisc *sch, u64 cur_time)
+hfsc_schedule_watchdog(struct Qdisc *sch)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 	u64 next_time = 0;
-	long delay;
 
 	if ((cl = eltree_get_minel(q)) != NULL)
 		next_time = cl->cl_e;
@@ -1455,11 +1444,7 @@ hfsc_schedule_watchdog(struct Qdisc *sch
 			next_time = q->root.cl_cfmin;
 	}
 	WARN_ON(next_time == 0);
-	delay = next_time - cur_time;
-	delay = PSCHED_US2JIFFIE(delay);
-
-	sch->flags |= TCQ_F_THROTTLED;
-	mod_timer(&q->wd_timer, jiffies + delay);
+	qdisc_watchdog_schedule(&q->watchdog, next_time);
 }
 
 static int
@@ -1496,9 +1481,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struc
 
 	list_add(&q->root.hlist, &q->clhash[hfsc_hash(q->root.classid)]);
 
-	init_timer(&q->wd_timer);
-	q->wd_timer.function = hfsc_watchdog;
-	q->wd_timer.data = (unsigned long)sch;
+	qdisc_watchdog_init(&q->watchdog, sch);
 
 	return 0;
 }
@@ -1568,8 +1551,7 @@ hfsc_reset_qdisc(struct Qdisc *sch)
 	__skb_queue_purge(&q->requeue);
 	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
-	del_timer(&q->wd_timer);
-	sch->flags &= ~TCQ_F_THROTTLED;
+	qdisc_watchdog_cancel(&q->watchdog);
 	sch->q.qlen = 0;
 }
 
@@ -1585,7 +1567,7 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 			hfsc_destroy_class(sch, cl);
 	}
 	__skb_queue_purge(&q->requeue);
-	del_timer(&q->wd_timer);
+	qdisc_watchdog_cancel(&q->watchdog);
 }
 
 static int
@@ -1671,7 +1653,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		cl = vttree_get_minvt(&q->root, cur_time);
 		if (cl == NULL) {
 			sch->qstats.overlimits++;
-			hfsc_schedule_watchdog(sch, cur_time);
+			hfsc_schedule_watchdog(sch);
 			return NULL;
 		}
 	}
