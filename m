From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in
	htb_dequeue()
Date: Tue, 9 Dec 2008 10:21:18 +0000
Message-ID: <20081209102118.GB14862@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:44025 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbYLIKVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 05:21:23 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1033647ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 02:21:22 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next event time should consider jiffies used for recounting. Otherwise
qdisc_watchdog_schedule() triggers hrtimer immediately with the event
in the past, and may cause very high ksoftirqd cpu usage (if highres
is on). This patch charges jiffies globally, so we can skip this in
htb_do_events().

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d6eb4a7..102866d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -685,8 +685,11 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level)
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
 	}
-	/* too much load - let's continue on next jiffie (including above) */
-	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
+	/*
+	 * Too much load - let's continue on next jiffie.
+	 * (Used jiffies are charged later.)
+	 */
+	return q->now + 1;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
@@ -845,6 +848,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	struct htb_sched *q = qdisc_priv(sch);
 	int level;
 	psched_time_t next_event;
+	unsigned long start_at;
 
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	skb = __skb_dequeue(&q->direct_queue);
@@ -857,6 +861,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	if (!sch->q.qlen)
 		goto fin;
 	q->now = psched_get_time();
+	start_at = jiffies;
 
 	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
 
@@ -889,6 +894,11 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		}
 	}
 	sch->qstats.overlimits++;
+	/* charge used jiffies */
+	start_at = jiffies - start_at;
+	if (start_at > 0)
+		next_event += start_at * PSCHED_TICKS_PER_SEC / HZ;
+
 	qdisc_watchdog_schedule(&q->watchdog, next_event);
 fin:
 	return skb;
-- 
1.5.6.5

