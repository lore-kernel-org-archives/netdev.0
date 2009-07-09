From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 2/3] net: sanitize hrtimer usage in sched_cbq
Date: Thu, 09 Jul 2009 21:59:30 -0000
Message-ID: <20090709215606.626294588@linutronix.de>
References: <20090709215455.703939259@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:37946 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756995AbZGIV7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 17:59:47 -0400
Content-Disposition: inline;
	filename=net-sched-cbq-sanitize-hrtimer-usage.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usage of hrtimer in cbq_ovl_delay() is less than obvious and in
two aspects wrong.

The intention of the code is to arm an hrtimer with the expiry time
X. If the timer is already armed the code needs to check whether the
expiry time X is earlier than the expiry time of the armed timer and
either keep the active timer or rearm it to X. If the timer is not
armed it needs to schedule it to X. That's not what the code does.

It calls hrtimer_try_to_cancel() unconditionally and checks the return
value. If the return value is non zero then it compares the expiry
time of the timer with the new expiry time and picks the earlier
one. The return value check does not take into account that the timer
might run its callback (expressed by a return value of -1). In that
case the expiry time of the timer is probably earlier than the new
expiry time so it rearms the already expired timer with the expiry
value in the past.

If the timer is not active (hrtimer_try_to_cancel() returns 0) it does
not set the new expiry time X but instead restarts the timer with the
expiry time which was active when the timer fired last. That's in the
past as well.

Change the code to check whether the timer is enqueued. If it is
enqueued then the expiry time of the timer is checked against the new
expiry time and it only calls hrtimer_start when the new expiry time
is earlier than the already armed timer. If the timer is not active
then arm it unconditionally with the new expiry time.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/sched/sch_cbq.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

Index: linux-2.6/net/sched/sch_cbq.c
===================================================================
--- linux-2.6.orig/net/sched/sch_cbq.c
+++ linux-2.6/net/sched/sch_cbq.c
@@ -494,7 +494,6 @@ static void cbq_ovl_delay(struct cbq_cla
 
 	if (!cl->delayed) {
 		psched_time_t sched = q->now;
-		ktime_t expires;
 
 		delay += cl->offtime;
 		if (cl->avgidle < 0)
@@ -504,6 +503,7 @@ static void cbq_ovl_delay(struct cbq_cla
 		cl->undertime = q->now + delay;
 
 		if (delay > 0) {
+			ktime_t expires, actexp;
 			unsigned long flags;
 
 			spin_lock_irqsave(&q->lock, flags);
@@ -514,12 +514,19 @@ static void cbq_ovl_delay(struct cbq_cla
 
 			expires = ktime_set(0, 0);
 			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
-			if (hrtimer_try_to_cancel(&q->delay_timer) &&
-			    ktime_to_ns(ktime_sub(
-					hrtimer_get_expires(&q->delay_timer),
-					expires)) > 0)
-				hrtimer_set_expires(&q->delay_timer, expires);
-			hrtimer_restart(&q->delay_timer);
+			/*
+			 * If the timer is queued check whether the
+			 * new expiry time is earlier than the current
+			 * one.
+			 */
+			if (hrtimer_is_queued(&q->delay_timer)) {
+				actexp = hrtimer_get_expires(&q->delay_timer);
+				if (expires.tv64 >= actexp.tv64)
+					expires.tv64 = 0;
+			}
+			if (expires.tv64)
+				hrtimer_start(&q->delay_timer, expires,
+					      HRTIMER_MODE_ABS);
 			cl->delayed = 1;
 			cl->xstats.overactions++;
 			spin_unlock_irqrestore(&q->lock, flags);


