From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 07/13] net_sched: move TCQ_F_MQROOT into qdisc ops
Date: Tue,  4 Nov 2014 09:56:30 -0800
Message-ID: <1415123796-8093-8-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57034 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbaKDR4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:54 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so14984595pab.0
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:53 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is just another static flag.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h | 2 +-
 net/sched/sch_api.c       | 6 +++---
 net/sched/sch_mq.c        | 2 +-
 net/sched/sch_mqprio.c    | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f552c4c..852f0c5 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -50,7 +50,6 @@ struct Qdisc {
 	unsigned int		flags;
 #define TCQ_F_INGRESS		2
 #define TCQ_F_CAN_BYPASS	4
-#define TCQ_F_MQROOT		8
 #define TCQ_F_ONETXQUEUE	0x10 /* dequeue_skb() can assume all skbs are for
 				      * q->dev_queue : It can test
 				      * netif_xmit_frozen_or_stopped() before
@@ -184,6 +183,7 @@ struct Qdisc_ops {
 	char			id[IFNAMSIZ];
 	int			priv_size;
 #define QDISC_F_BUILTIN		1
+#define QDISC_F_MQ		2
 	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b6cad91..98b315f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -958,12 +958,12 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			spinlock_t *root_lock;
 
 			err = -EOPNOTSUPP;
-			if (sch->flags & TCQ_F_MQROOT)
+			if (sch->ops->flags & QDISC_F_MQ)
 				goto err_out4;
 
 			if ((sch->parent != TC_H_ROOT) &&
 			    !(sch->flags & TCQ_F_INGRESS) &&
-			    (!p || !(p->flags & TCQ_F_MQROOT)))
+			    (!p || !(p->ops->flags & QDISC_F_MQ)))
 				root_lock = qdisc_root_sleeping_lock(sch);
 			else
 				root_lock = qdisc_lock(sch);
@@ -1029,7 +1029,7 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 	if (tca[TCA_RATE]) {
 		/* NB: ignores errors from replace_estimator
 		   because change can't be undone. */
-		if (sch->flags & TCQ_F_MQROOT)
+		if (sch->ops->flags & QDISC_F_MQ)
 			goto out;
 		gen_replace_estimator(&sch->bstats,
 				      sch->cpu_bstats,
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index f3cbaec..cab9fc2 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -66,7 +66,6 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 		qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
 
-	sch->flags |= TCQ_F_MQROOT;
 	return 0;
 
 err:
@@ -237,6 +236,7 @@ static const struct Qdisc_class_ops mq_class_ops = {
 struct Qdisc_ops mq_qdisc_ops __read_mostly = {
 	.cl_ops		= &mq_class_ops,
 	.id		= "mq",
+	.flags		= QDISC_F_MQ,
 	.priv_size	= sizeof(struct mq_sched),
 	.init		= mq_init,
 	.destroy	= mq_destroy,
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 3811a74..dc208c2 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -155,7 +155,6 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	for (i = 0; i < TC_BITMASK + 1; i++)
 		netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i]);
 
-	sch->flags |= TCQ_F_MQROOT;
 	return 0;
 
 err:
@@ -404,6 +403,7 @@ static const struct Qdisc_class_ops mqprio_class_ops = {
 static struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
 	.cl_ops		= &mqprio_class_ops,
 	.id		= "mqprio",
+	.flags		= QDISC_F_MQ,
 	.priv_size	= sizeof(struct mqprio_sched),
 	.init		= mqprio_init,
 	.destroy	= mqprio_destroy,
-- 
1.8.3.1
