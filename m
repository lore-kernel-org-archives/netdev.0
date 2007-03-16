From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/10]: sch_tbf: use hrtimer based watchdog
Date: Fri, 16 Mar 2007 06:30:54 +0100 (MET)
Message-ID: <20070316053024.22744.58031.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45258 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbXCPFaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:55 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_tbf: use hrtimer based watchdog

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7acf6ee9c08fdbf5cb24b15d95432eef07506a38
tree b47d381f5c9560099cb954a186a0ee3fc7a34d60
parent 76728bda8872d54abd39cdc47d703384f735f7ea
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:28 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:28 +0100

 net/sched/sch_tbf.c |   31 +++++++------------------------
 1 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 85da8da..f14692f 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -127,8 +127,8 @@ struct tbf_sched_data
 	long	tokens;			/* Current number of B tokens */
 	long	ptokens;		/* Current number of P tokens */
 	psched_time_t	t_c;		/* Time check-point */
-	struct timer_list wd_timer;	/* Watchdog timer */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
+	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
 #define L2T(q,L)   ((q)->R_tab->data[(L)>>(q)->R_tab->rate.cell_log])
@@ -185,14 +185,6 @@ static unsigned int tbf_drop(struct Qdis
 	return len;
 }
 
-static void tbf_watchdog(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc*)arg;
-
-	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule(sch->dev);
-}
-
 static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -202,7 +194,7 @@ static struct sk_buff *tbf_dequeue(struc
 
 	if (skb) {
 		psched_time_t now;
-		long toks, delay;
+		long toks;
 		long ptoks = 0;
 		unsigned int len = skb->len;
 
@@ -230,12 +222,8 @@ static struct sk_buff *tbf_dequeue(struc
 			return skb;
 		}
 
-		delay = PSCHED_US2JIFFIE(max_t(long, -toks, -ptoks));
-
-		if (delay == 0)
-			delay = 1;
-
-		mod_timer(&q->wd_timer, jiffies+delay);
+		qdisc_watchdog_schedule(&q->watchdog,
+					now + max_t(long, -toks, -ptoks));
 
 		/* Maybe we have a shorter packet in the queue,
 		   which can be sent now. It sounds cool,
@@ -254,7 +242,6 @@ static struct sk_buff *tbf_dequeue(struc
 			sch->qstats.drops++;
 		}
 
-		sch->flags |= TCQ_F_THROTTLED;
 		sch->qstats.overlimits++;
 	}
 	return NULL;
@@ -269,8 +256,7 @@ static void tbf_reset(struct Qdisc* sch)
 	PSCHED_GET_TIME(q->t_c);
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
-	sch->flags &= ~TCQ_F_THROTTLED;
-	del_timer(&q->wd_timer);
+	qdisc_watchdog_cancel(&q->watchdog);
 }
 
 static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
@@ -378,10 +364,7 @@ static int tbf_init(struct Qdisc* sch, s
 		return -EINVAL;
 
 	PSCHED_GET_TIME(q->t_c);
-	init_timer(&q->wd_timer);
-	q->wd_timer.function = tbf_watchdog;
-	q->wd_timer.data = (unsigned long)sch;
-
+	qdisc_watchdog_init(&q->watchdog, sch);
 	q->qdisc = &noop_qdisc;
 
 	return tbf_change(sch, opt);
@@ -391,7 +374,7 @@ static void tbf_destroy(struct Qdisc *sc
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
-	del_timer(&q->wd_timer);
+	qdisc_watchdog_cancel(&q->watchdog);
 
 	if (q->P_tab)
 		qdisc_put_rtab(q->P_tab);
