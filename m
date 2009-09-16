From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix qstats.qlen updating in dump_stats
Date: Wed, 16 Sep 2009 10:38:38 +0000
Message-ID: <20090916103838.GA9719@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:51092 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbZIPKik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 06:38:40 -0400
Received: by fxm17 with SMTP id 17so2172115fxm.37
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 03:38:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some classful qdiscs miss qstats.qlen updating with q.qlen of their
child qdiscs in dump_stats methods.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_drr.c    |    4 +++-
 net/sched/sch_mq.c     |    1 +
 net/sched/sch_multiq.c |    1 +
 net/sched/sch_prio.c   |    1 +
 4 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 12b2fb0..5a888af 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -274,8 +274,10 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct tc_drr_stats xstats;
 
 	memset(&xstats, 0, sizeof(xstats));
-	if (cl->qdisc->q.qlen)
+	if (cl->qdisc->q.qlen) {
 		xstats.deficit = cl->deficit;
+		cl->qdisc->qstats.qlen = cl->qdisc->q.qlen;
+	}
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index dd5ee02..d44eddd 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -188,6 +188,7 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
 
 	sch = dev_queue->qdisc_sleeping;
+	sch->qstats.qlen = sch->q.qlen;
 	if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
 		return -1;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 069f81c..7db2c88 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -359,6 +359,7 @@ static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
+	cl_q->qstats.qlen = cl_q->q.qlen;
 	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
 		return -1;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 0f73c41..93285ce 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -322,6 +322,7 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
+	cl_q->qstats.qlen = cl_q->q.qlen;
 	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
 		return -1;
