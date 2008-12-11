From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 11 Dec 2008 08:46:06 +0000
Message-ID: <20081211084606.GA4129@ff.dom.local>
References: <20081010075640.GA5204@ff.dom.local> <48EF17EA.5020306@bigtelecom.ru> <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local> <48F6FB3E.7060903@bigtelecom.ru> <20081016084027.GA17632@ff.dom.local> <48FEC302.5090707@bigtelecom.ru> <20081022070200.GB4178@ff.dom.local> <493FDCD4.5020108@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:51323 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115AbYLKIqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 03:46:14 -0500
Received: by ewy10 with SMTP id 10so1255029ewy.13
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 00:46:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <493FDCD4.5020108@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2008 at 06:14:28PM +0300, Badalian Vyacheslav wrote:
> Hello again! Sorry for long away.

Hi!

> I was go away from this work for long time.
> 
> May we return to this bug?
> Servers at last stable kernel 2.6.27.8
> HZ=1000, HR=off, DynamicTicks=off, hysteresis=1
> Sorry - no patched, update do not i. Do you have fresh patches or ideas
> for tests?

Not much, but I can have if you only are willing to test them...
I attach below a patch which combines 2 patches I sent yesterday to
netdev (PATCH 7/6 and 8/6) vs. 2.6.27.7 (named testing patch #3 here).

You can still try the testing patch #2 I sent previously (quoted below)
with or without this new #3 patch.

Thanks,
Jarek P.

> Also debug "Debug object operations" and "Debug timer objects" is on but
> i not see additional information at dump.
> 
> Thanks!
> 
> That dump:
> [ 1500.932813] BUG: NMI Watchdog detected LOCKUP on CPU3, ip c0208ed9,
> registers:
> [ 1500.932813] Modules linked in: cls_u32 sch_sfq sch_htb netconsole
> e1000e e1000 i2c_i801
> [ 1500.932813]
> [ 1500.932813] Pid: 0, comm: swapper Not tainted (2.6.27-gentoo-r5-fw #1)
> [ 1500.932813] EIP: 0060:[<c0208ed9>] EFLAGS: 00000082 CPU: 3
> [ 1500.932813] EIP is at rb_insert_color+0x29/0xf0
...
> > --- (testing patch #2)
> >
> >  net/sched/sch_htb.c |    8 +++++++-
> >  1 files changed, 7 insertions(+), 1 deletions(-)
> >
> > diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> > index 30c999c..ff9e965 100644


-----------> (testing patch #3)

diff -Nurp a2.6.27.7/net/sched/sch_htb.c b2.6.27.7/net/sched/sch_htb.c
--- a2.6.27.7/net/sched/sch_htb.c	2008-12-11 08:16:16.000000000 +0000
+++ b2.6.27.7/net/sched/sch_htb.c	2008-12-11 08:20:27.000000000 +0000
@@ -696,12 +696,13 @@ static void htb_charge_class(struct htb_
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
@@ -720,8 +721,8 @@ static psched_time_t htb_do_events(struc
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
 	}
-	/* too much load - let's continue on next jiffie */
-	return q->now + PSCHED_TICKS_PER_SEC / HZ;
+	/* too much load - let's continue on next jiffie (including above) */
+	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
@@ -880,6 +881,7 @@ static struct sk_buff *htb_dequeue(struc
 	struct htb_sched *q = qdisc_priv(sch);
 	int level;
 	psched_time_t next_event;
+	unsigned long start_at;
 
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	skb = __skb_dequeue(&q->direct_queue);
@@ -892,6 +894,7 @@ static struct sk_buff *htb_dequeue(struc
 	if (!sch->q.qlen)
 		goto fin;
 	q->now = psched_get_time();
+	start_at = jiffies;
 
 	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
 	q->nwc_hit = 0;
@@ -901,14 +904,14 @@ static struct sk_buff *htb_dequeue(struc
 		psched_time_t event;
 
 		if (q->now >= q->near_ev_cache[level]) {
-			event = htb_do_events(q, level);
+			event = htb_do_events(q, level, start_at);
 			if (!event)
 				event = q->now + PSCHED_TICKS_PER_SEC;
 			q->near_ev_cache[level] = event;
 		} else
 			event = q->near_ev_cache[level];
 
-		if (event && next_event > event)
+		if (next_event > event)
 			next_event = event;
 
 		m = ~q->row_mask[level];
