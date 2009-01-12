From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 7/6 resend] pkt_sched: sch_htb: Consider used jiffies in
	htb_do_events()
Date: Mon, 12 Jan 2009 10:16:13 +0000
Message-ID: <20090112101613.GA5781@ff.dom.local>
References: <20081209144534.GC15353@ff.dom.local> <20081209.223545.196224587.davem@davemloft.net> <20081210091126.GA4707@ff.dom.local> <20081210.011431.203551043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:65367 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbZALKQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:16:19 -0500
Received: by ewy10 with SMTP id 10so11410357ewy.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 02:16:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081210.011431.203551043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend)

pkt_sched: sch_htb: Consider used jiffies in htb_do_events()

Next event time should consider jiffies used for recounting. Otherwise
qdisc_watchdog_schedule() triggers hrtimer immediately with the event
in the past, and may cause very high ksoftirqd cpu usage (if highres
is on).

There is also removed checking "event" for zero in htb_dequeue(): it's
always true in this place.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_htb.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 5070643..9ca8a26 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -685,8 +685,8 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level)
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
 	}
-	/* too much load - let's continue on next jiffie */
-	return q->now + PSCHED_TICKS_PER_SEC / HZ;
+	/* too much load - let's continue on next jiffie (including above) */
+	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
@@ -873,7 +873,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		} else
 			event = q->near_ev_cache[level];
 
-		if (event && next_event > event)
+		if (next_event > event)
 			next_event = event;
 
 		m = ~q->row_mask[level];
