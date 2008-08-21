From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 21 Aug 2008 05:49:11 +0000
Message-ID: <20080821054911.GA4178@ff.dom.local>
References: <20080819.040200.155911269.davem@davemloft.net> <20080819164830.GA2533@ami.dom.local> <20080819222329.GA10297@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:13309 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbYHUFtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 01:49:19 -0400
Received: by nf-out-0910.google.com with SMTP id d3so393385nfc.21
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 22:49:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819222329.GA10297@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---------------> (take 2)

pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race

dev_deactivate() can skip rescheduling of a qdisc by qdisc_watchdog()
or other timer calling netif_schedule() after dev_queue_deactivate().
We prevent this checking aliveness before scheduling the timer. Since
during deactivation the root qdisc is available only as qdisc_sleeping
additional accessor qdisc_root_sleeping() is created.

With feedback from Herbert Xu <herbert@gondor.apana.org.au>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/sch_generic.h |    5 +++++
 net/sched/sch_api.c       |    4 ++++
 net/sched/sch_cbq.c       |    4 ++++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 84d25f2..b1d2cfe 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -193,6 +193,11 @@ static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
 	return qdisc->dev_queue->qdisc;
 }
 
+static inline struct Qdisc *qdisc_root_sleeping(struct Qdisc *qdisc)
+{
+	return qdisc->dev_queue->qdisc_sleeping;
+}
+
 /* The qdisc root lock is a mechanism by which to top level
  * of a qdisc tree can be locked from any qdisc node in the
  * forest.  This allows changing the configuration of some
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ef0efec..45f442d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -444,6 +444,10 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 {
 	ktime_t time;
 
+	if (test_bit(__QDISC_STATE_DEACTIVATED,
+		     &qdisc_root_sleeping(wd->qdisc)->state))
+		return;
+
 	wd->qdisc->flags |= TCQ_F_THROTTLED;
 	time = ktime_set(0, 0);
 	time = ktime_add_ns(time, PSCHED_US2NS(expires));
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 47ef492..8fa90d6 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -521,6 +521,10 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	psched_tdiff_t delay = cl->undertime - q->now;
 
+	if (test_bit(__QDISC_STATE_DEACTIVATED,
+		     &qdisc_root_sleeping(cl->qdisc)->state))
+		return;
+
 	if (!cl->delayed) {
 		psched_time_t sched = q->now;
 		ktime_t expires;
