From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 06/10]: sch_cbq: use hrtimer based watchdog
Date: Fri, 16 Mar 2007 06:30:56 +0100 (MET)
Message-ID: <20070316053026.22744.28895.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45267 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbXCPFa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:57 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_cbq: use hrtimer based watchdog

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit dc1a944b36eeddc06e7288a2eec9344252d4ccb7
tree c0bd33b0ada4fbda631c246f7fe5881cf830e932
parent b0b8ce02c1564f86f09a0ccb728327d02cf202f0
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:29 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:29 +0100

 net/sched/sch_cbq.c |   28 +++++++---------------------
 1 files changed, 7 insertions(+), 21 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 76c92e7..d29d121 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -181,11 +181,11 @@ #endif
 	unsigned		pmask;
 
 	struct timer_list	delay_timer;
-	struct timer_list	wd_timer;	/* Watchdog timer,
+	struct qdisc_watchdog	watchdog;	/* Watchdog timer,
 						   started when CBQ has
 						   backlog, but cannot
 						   transmit just now */
-	long			wd_expires;
+	psched_tdiff_t		wd_expires;
 	int			toplevel;
 	u32			hgenerator;
 };
@@ -604,14 +604,6 @@ static void cbq_ovl_drop(struct cbq_clas
 	cbq_ovl_classic(cl);
 }
 
-static void cbq_watchdog(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc*)arg;
-
-	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule(sch->dev);
-}
-
 static unsigned long cbq_undelay_prio(struct cbq_sched_data *q, int prio)
 {
 	struct cbq_class *cl;
@@ -1063,13 +1055,9 @@ cbq_dequeue(struct Qdisc *sch)
 
 	if (sch->q.qlen) {
 		sch->qstats.overlimits++;
-		if (q->wd_expires) {
-			long delay = PSCHED_US2JIFFIE(q->wd_expires);
-			if (delay <= 0)
-				delay = 1;
-			mod_timer(&q->wd_timer, jiffies + delay);
-			sch->flags |= TCQ_F_THROTTLED;
-		}
+		if (q->wd_expires)
+			qdisc_watchdog_schedule(&q->watchdog,
+						q->now + q->wd_expires);
 	}
 	return NULL;
 }
@@ -1276,7 +1264,7 @@ cbq_reset(struct Qdisc* sch)
 	q->pmask = 0;
 	q->tx_class = NULL;
 	q->tx_borrowed = NULL;
-	del_timer(&q->wd_timer);
+	qdisc_watchdog_cancel(&q->watchdog);
 	del_timer(&q->delay_timer);
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	PSCHED_GET_TIME(q->now);
@@ -1446,9 +1434,7 @@ static int cbq_init(struct Qdisc *sch, s
 	q->link.minidle = -0x7FFFFFFF;
 	q->link.stats_lock = &sch->dev->queue_lock;
 
-	init_timer(&q->wd_timer);
-	q->wd_timer.data = (unsigned long)sch;
-	q->wd_timer.function = cbq_watchdog;
+	qdisc_watchdog_init(&q->watchdog, sch);
 	init_timer(&q->delay_timer);
 	q->delay_timer.data = (unsigned long)sch;
 	q->delay_timer.function = cbq_undelay;
