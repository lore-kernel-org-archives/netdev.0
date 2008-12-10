From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 8/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
	jiffies in htb_dequeue()
Date: Wed, 10 Dec 2008 10:52:53 +0000
Message-ID: <20081210105253.GA9344@ff.dom.local>
References: <20081209102118.GB14862@ff.dom.local> <493E485C.9090706@trash.net> <20081209113205.GA15353@ff.dom.local> <493E63AB.80400@trash.net> <20081209130803.GB15353@ff.dom.local> <493E7080.5060308@trash.net> <20081209144534.GC15353@ff.dom.local> <493E8709.5070601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Martin Devera <devik@cdi.cz>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:55645 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbYLJKxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 05:53:01 -0500
Received: by ewy10 with SMTP id 10so568941ewy.13
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 02:52:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <493E8709.5070601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2008 at 03:56:09PM +0100, Patrick McHardy wrote:
...
> I meant "at all" for the wakeup after we've decided HTB has too much
> work to do at once. A work queue seems better suited since that makes
> sure we allow other processes to run, but don't wait unnecessarily
> long when there is no other work.

Maybe I miss your point, but IMHO the too much work case isn't a
problem here: there is a lot of time wasted in this case, so e.g.
additional psched_get_time() and "safe" rescheduling is possible -
no need to complicate it with workqueues etc. (but current patch 7
should be enough). I'm concerned with e.g. a config doing often
htb_do_events() and htb_dequeue_tree() in ~1 jiffie and
rescheduling for 1/2 jiffie (or 1/2 vs. 1/4 etc.), so mainly in
the past. hrtimers beahave with this really different from timers.

>>> Jiffies might wrap even if it only took only a few nanoseconds.
>>> And its not fine, in the case of throttled classes there's no
>>> reason to add extra delay *at all*.
>>
>> Yes, you are right with this. I can try too fix this tomorrow, unless
>> you prefer to send your version of this patch.
>
> I don't have a version of my own, so please go ahead :)

Alas I haven't found how we can fix it generally without any such costs,
so I think I've to leave this problem for now. Then only this "over 2
jiffies" case should be fixed here (current patch 7), plus I propose the
patch below to additionally skip doing events generally after 2 jiffies.

Thanks,
Jarek P.

-------------> (redone old patch 3 - to apply on top of patch 7)

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
