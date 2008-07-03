From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/39]: pkt_sched: Kill stats_lock member of struct Qdisc.
Date: Thu, 03 Jul 2008 00:03:21 -0700 (PDT)
Message-ID: <20080703.000321.262930039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47493
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756857AbYGCHDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is always equal to qdisc->dev_queue->lock

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    1 -
 net/sched/sch_api.c       |    9 ++++-----
 net/sched/sch_generic.c   |    1 -
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1dce549..6bf63d9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -43,7 +43,6 @@ struct Qdisc
 	struct gnet_stats_basic	bstats;
 	struct gnet_stats_queue	qstats;
 	struct gnet_stats_rate_est	rate_est;
-	spinlock_t		*stats_lock;
 	struct rcu_head 	q_rcu;
 	int			(*reshape_fail)(struct sk_buff *skb,
 					struct Qdisc *q);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a2e62b3..da3e1c8 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -500,7 +500,6 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 
 	sch->parent = parent;
 
-	sch->stats_lock = &dev_queue->lock;
 	if (handle == TC_H_INGRESS) {
 		sch->flags |= TCQ_F_INGRESS;
 		handle = TC_H_MAKE(TC_H_INGRESS, 0);
@@ -518,7 +517,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
 		if (tca[TCA_RATE]) {
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
-						sch->stats_lock,
+						&sch->dev_queue->lock,
 						tca[TCA_RATE]);
 			if (err) {
 				/*
@@ -560,7 +559,7 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 	}
 	if (tca[TCA_RATE])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-			sch->stats_lock, tca[TCA_RATE]);
+				      &sch->dev_queue->lock, tca[TCA_RATE]);
 	return 0;
 }
 
@@ -850,7 +849,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	q->qstats.qlen = q->q.qlen;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-			TCA_XSTATS, q->stats_lock, &d) < 0)
+					 TCA_XSTATS, &q->dev_queue->lock, &d) < 0)
 		goto nla_put_failure;
 
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
@@ -1099,7 +1098,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-			TCA_XSTATS, q->stats_lock, &d) < 0)
+					 TCA_XSTATS, &q->dev_queue->lock, &d) < 0)
 		goto nla_put_failure;
 
 	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index da709d1..6e7068c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -484,7 +484,6 @@ struct Qdisc * qdisc_create_dflt(struct net_device *dev,
 	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch))
 		goto errout;
-	sch->stats_lock = &dev_queue->lock;
 	sch->parent = parentid;
 
 	if (!ops->init || ops->init(sch, NULL) == 0)
-- 
1.5.6

