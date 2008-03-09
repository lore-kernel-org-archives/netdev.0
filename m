From: Martin Devera <devik@cdi.cz>
Subject: [PATCH 2.6.24 ver2 1/1] sch_htb: fix "too many events" situation
Date: Sun, 09 Mar 2008 14:52:53 +0100
Message-ID: <E1JYLxN-00024M-HI@luxik.cdi.cz>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:60235 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbYCINyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Mar 2008 09:54:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Devera <devik@cdi.cz>

HTB is event driven algorithm and part of its work is to apply
scheduled events at proper times. It tried to defend itself from
livelock by processing only limited number of events per dequeue.
Because of faster computers some users already hit this hardcoded
limit.
This patch limits processing up to 2 jiffies (why not 1 jiffie ?
because it might stop prematurely when only fraction of jiffie
remains).

Signed-off-by: Martin Devera <devik@cdi.cz>

--- a/net/sched/sch_htb.c	2008-02-14 22:56:48.000000000 +0100
+++ b/net/sched/sch_htb.c	2008-03-09 14:43:30.000000000 +0100
@@ -708,9 +708,11 @@
  */
 static psched_time_t htb_do_events(struct htb_sched *q, int level)
 {
-	int i;
-
-	for (i = 0; i < 500; i++) {
+	/* don't run for longer than 2 jiffies; 2 is used instead of
+	   1 to simplify things when jiffy is going to be incremented
+	   too soon */
+	unsigned long stop_at = jiffies + 2;
+	while (time_before(jiffies, stop_at)) {
 		struct htb_class *cl;
 		long diff;
 		struct rb_node *p = rb_first(&q->wait_pq[level]);
@@ -728,9 +730,8 @@
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
 	}
-	if (net_ratelimit())
-		printk(KERN_WARNING "htb: too many events !\n");
-	return q->now + PSCHED_TICKS_PER_SEC / 10;
+	/* too much load - let's continue on next jiffie */
+	return q->now + PSCHED_TICKS_PER_SEC / HZ;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
