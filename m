From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 8/6 resend] pkt_sched: sch_htb: Break all htb_do_events()
	after 2 jiffies
Date: Mon, 12 Jan 2009 10:17:46 +0000
Message-ID: <20090112101745.GB5781@ff.dom.local>
References: <20081209102118.GB14862@ff.dom.local> <493E485C.9090706@trash.net> <20081209113205.GA15353@ff.dom.local> <493E63AB.80400@trash.net> <20081209130803.GB15353@ff.dom.local> <493E7080.5060308@trash.net> <20081209144534.GC15353@ff.dom.local> <493E8709.5070601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Martin Devera <devik@cdi.cz>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:51339 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbZALKRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:17:52 -0500
Received: by ewy10 with SMTP id 10so11410982ewy.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 02:17:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <493E8709.5070601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend)

pkt_sched: sch_htb: Break all htb_do_events() after 2 jiffies

Currently htb_do_events() breaks events recounting for a level after 2
jiffies, but there is no reason to repeat this for next levels and
increase delays even more (with softirqs disabled). htb_dequeue_tree()
can add to this too, btw. In such a case q->now time is invalid anyway.

Thanks to Patrick McHardy for spotting an error around earlier version
of this patch.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_htb.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 9ca8a26..2f0f0b0 100644
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
@@ -845,6 +846,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	struct htb_sched *q = qdisc_priv(sch);
 	int level;
 	psched_time_t next_event;
+	unsigned long start_at;
 
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	skb = __skb_dequeue(&q->direct_queue);
@@ -857,6 +859,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	if (!sch->q.qlen)
 		goto fin;
 	q->now = psched_get_time();
+	start_at = jiffies;
 
 	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
 
@@ -866,7 +869,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		psched_time_t event;
 
 		if (q->now >= q->near_ev_cache[level]) {
-			event = htb_do_events(q, level);
+			event = htb_do_events(q, level, start_at);
 			if (!event)
 				event = q->now + PSCHED_TICKS_PER_SEC;
 			q->near_ev_cache[level] = event;
