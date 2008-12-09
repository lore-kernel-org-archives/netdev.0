From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/6] pkt_sched: sch_htb: Break all htb_do_events() after 2
	jiifies
Date: Tue, 9 Dec 2008 10:21:28 +0000
Message-ID: <20081209102127.GC14862@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:44025 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbYLIKVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 05:21:33 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1033647ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 02:21:32 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently htb_do_events() breaks events recounting for a level after 2
jiffies, but there is no reason to repeat this for next levels and
increase delays even more (with softirqs disabled). htb_dequeue_tree()
can add to this too, btw. In such a case q->now time is invalid anyway.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 102866d..b241ac6 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -661,12 +661,13 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
  * next pending event (0 for no event in pq).
  * Note: Applied are events whose have cl->pq_key <= q->now.
  */
-static psched_time_t htb_do_events(struct htb_sched *q, int level)
+static psched_time_t htb_do_events(struct htb_sched *q, int level,
+				   unsigned long start)
 {
 	/* don't run for longer than 2 jiffies; 2 is used instead of
 	   1 to simplify things when jiffy is going to be incremented
 	   too soon */
-	unsigned long stop_at = jiffies + 2;
+	unsigned long stop_at = start + 2;
 	while (time_before(jiffies, stop_at)) {
 		struct htb_class *cl;
 		long diff;
@@ -871,7 +872,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		psched_time_t event;
 
 		if (q->now >= q->near_ev_cache[level]) {
-			event = htb_do_events(q, level);
+			event = htb_do_events(q, level, start_at);
 			if (!event)
 				event = q->now + PSCHED_TICKS_PER_SEC;
 			q->near_ev_cache[level] = event;
-- 
1.5.6.5

