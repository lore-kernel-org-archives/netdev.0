From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
	jiffies in htb_dequeue()
Date: Wed, 10 Dec 2008 09:35:32 +0000
Message-ID: <20081210093532.GA7926@ff.dom.local>
References: <20081209144534.GC15353@ff.dom.local> <20081209.223545.196224587.davem@davemloft.net> <20081210091126.GA4707@ff.dom.local> <20081210.011431.203551043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:58994 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbYLJJfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 04:35:39 -0500
Received: by ewy10 with SMTP id 10so530394ewy.13
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 01:35:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081210.011431.203551043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2008 at 01:14:31AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 10 Dec 2008 09:11:26 +0000
> 
> > On Tue, Dec 09, 2008 at 10:35:45PM -0800, David Miller wrote:
> > > So once you work this stuff out please resubmit the rest.
> > 
> > Of course, I can resubmit 1 and 4 if you think it's really needed.
> 
> Please do, there were dependencies.  In fact patch 2 changes
> the very change you made in patch 1.

But patch 2 is nonexistent. (I've withdrawn this...)

> 
> I understand it's logical steps, but you could just do 1 and
> 2 in the same patch and it'd be OK.

OK, so I withdraw 1 and 4 too, and let's say this is No 7 (2in1).

Sorry for this mess,
Jarek P.

------------->
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
