From: Martin Devera <devik@cdi.cz>
Subject: [PATCH 2.6.24 1/1] sch_htb: fix "too many events" situation
Date: Fri, 15 Feb 2008 00:02:56 +0100
Message-ID: <E1JPn6W-0002J2-5x@luxik.cdi.cz>
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:47923 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758127AbYBNXaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 18:30:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Devera <devik@cdi.cz>

HTB is event driven algorithm and part of its work is to apply
scheduled events at proper times. It tried to defend itself from
livelock by processing only limited number of events per dequeue.
Because of faster computers some users already hit this hardcoded
limit.
This patch uses loops_per_jiffy variable to limit event processing
up to single jiffy interval and then delay remainder to other
jiffy.

Signed-off-by: Martin Devera <devik@cdi.cz>
---
BTW, from my measurement is seems that value 500 was good one
for my first 600MHz machine :-)
Maybe I can make something self-converging (using tasklets probably)
but I'm not sure if it is worth of the complexity.

--- a/net/sched/sch_htb.c	2008-02-14 22:56:48.000000000 +0100
+++ b/net/sched/sch_htb.c	2008-02-14 23:37:02.000000000 +0100
@@ -704,13 +704,17 @@ static void htb_charge_class(struct htb_
  *
  * Scans event queue for pending events and applies them. Returns time of
  * next pending event (0 for no event in pq).
+ * One event costs about 1300 cycles on x86_64, let's be conservative
+ * and round it to 4096. We will allow only loops_per_jiffy/4096 events
+ * in one call to prevent us from livelock.
  * Note: Applied are events whose have cl->pq_key <= q->now.
  */
+#define HTB_EVENT_COST_SHIFTS 12
 static psched_time_t htb_do_events(struct htb_sched *q, int level)
 {
-	int i;
-
-	for (i = 0; i < 500; i++) {
+	int i, max_events = loops_per_jiffy >> HTB_EVENT_COST_SHIFTS;
+	/* <= below is just for case where max_events==0 (unlikely) */
+	for (i = 0; i <= max_events; i++) {
 		struct htb_class *cl;
 		long diff;
 		struct rb_node *p = rb_first(&q->wait_pq[level]);
@@ -728,9 +732,8 @@ static psched_time_t htb_do_events(struc
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
 	}
-	if (net_ratelimit())
-		printk(KERN_WARNING "htb: too many events !\n");
-	return q->now + PSCHED_TICKS_PER_SEC / 10;
+	/* too much load - let's continue on next tick */
+	return q->now + PSCHED_TICKS_PER_SEC / HZ;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
