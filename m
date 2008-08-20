From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
Date: Wed, 20 Aug 2008 11:56:56 +0000
Message-ID: <20080820115656.GA7078@ff.dom.local>
References: <20080819.040200.155911269.davem@davemloft.net> <20080819164830.GA2533@ami.dom.local> <20080819222329.GA10297@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:49767 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbYHTL5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 07:57:03 -0400
Received: by ik-out-1112.google.com with SMTP id c28so353038ika.5
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 04:57:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819222329.GA10297@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2008 at 08:23:29AM +1000, Herbert Xu wrote:
> On Tue, Aug 19, 2008 at 06:48:31PM +0200, Jarek Poplawski wrote:
> > 
> > I can miss something, but probably it's needed in __netif_reschedule()
> 
> No this is a genuine bug.  However, it's also an old bug :) Even
> with the locking and RCU barrier it could have occured.
> 
> > yet. Here is a scenario:
> > 
> > cpu1				cpu2
> > dev_deactivate()
> > dev_deactivate_queue()
> > qdisc_reset()
> > 				qdisc_run()
> > 				qdisc_watchdog_schedule()
> > 				(or hrtimer_restart in cbq)
> 
> We should add an aliveness check before scheduling the timer.  This
> is the slow path so adding a check shouldn't hurt.

Thanks,
Jarek P.

--------------->

pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race

dev_deactivate() can skip rescheduling of a qdisc by qdisc_watchdog()
or other timer calling netif_schedule() after dev_queue_deactivate().
We prevent this checking aliveness before scheduling the timer.

With feedback from Herbert Xu <herbert@gondor.apana.org.au>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_api.c |    3 +++
 net/sched/sch_cbq.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ef0efec..6f2bc7f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -444,6 +444,9 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 {
 	ktime_t time;
 
+	if (test_bit(__QDISC_STATE_DEACTIVATED, &qdisc_root(wd->qdisc)->state))
+		return;
+
 	wd->qdisc->flags |= TCQ_F_THROTTLED;
 	time = ktime_set(0, 0);
 	time = ktime_add_ns(time, PSCHED_US2NS(expires));
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 47ef492..c04d335 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -521,6 +521,9 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	psched_tdiff_t delay = cl->undertime - q->now;
 
+	if (test_bit(__QDISC_STATE_DEACTIVATED, &qdisc_root(cl->qdisc)->state))
+		return;
+
 	if (!cl->delayed) {
 		psched_time_t sched = q->now;
 		ktime_t expires;
