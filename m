From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 5/5] net_sched: move ingress flag into qdisc ops
Date: Wed, 26 Aug 2015 15:41:27 -0700
Message-ID: <1440628887-3504-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33439 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757224AbbHZWli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:41:38 -0400
Received: by pacti10 with SMTP id ti10so2003069pac.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 15:41:38 -0700 (PDT)
In-Reply-To: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  2 +-
 net/sched/sch_api.c       | 11 +++++------
 net/sched/sch_ingress.c   |  1 +
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2e6748e..a02bf04 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -48,7 +48,6 @@ struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
 	unsigned int		flags;
-#define TCQ_F_INGRESS		2
 #define TCQ_F_CAN_BYPASS	4
 #define TCQ_F_ONETXQUEUE	0x10 /* dequeue_skb() can assume all skbs are for
 				      * q->dev_queue : It can test
@@ -183,6 +182,7 @@ struct Qdisc_ops {
 #define QDISC_F_MQ		2
 #define QDISC_F_FIFO		4
 #define QDISC_F_DEFAULTABLE	8
+#define QDISC_F_INGRESS		16
 	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e501e9d..7f285fa8 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -281,7 +281,7 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 
 void qdisc_list_add(struct Qdisc *q)
 {
-	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
+	if ((q->parent != TC_H_ROOT) && !(q->ops->flags & QDISC_F_INGRESS)) {
 		struct Qdisc *root = qdisc_dev(q)->qdisc;
 
 		WARN_ON_ONCE(root == &noop_qdisc);
@@ -292,7 +292,7 @@ EXPORT_SYMBOL(qdisc_list_add);
 
 void qdisc_list_del(struct Qdisc *q)
 {
-	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
+	if ((q->parent != TC_H_ROOT) && !(q->ops->flags & QDISC_F_INGRESS))
 		list_del(&q->list);
 }
 EXPORT_SYMBOL(qdisc_list_del);
@@ -812,8 +812,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 
 		ingress = 0;
 		num_q = dev->num_tx_queues;
-		if ((q && q->flags & TCQ_F_INGRESS) ||
-		    (new && new->flags & TCQ_F_INGRESS)) {
+		if ((q && q->ops->flags & QDISC_F_INGRESS) ||
+		    (new && new->ops->flags & QDISC_F_INGRESS)) {
 			num_q = 1;
 			ingress = 1;
 			if (!dev_ingress_queue(dev))
@@ -937,7 +937,6 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	sch->parent = parent;
 
 	if (handle == TC_H_INGRESS) {
-		sch->flags |= TCQ_F_INGRESS;
 		handle = TC_H_MAKE(TC_H_INGRESS, 0);
 		lockdep_set_class(qdisc_lock(sch), &qdisc_rx_lock);
 	} else {
@@ -982,7 +981,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out4;
 
 			if ((sch->parent != TC_H_ROOT) &&
-			    !(sch->flags & TCQ_F_INGRESS) &&
+			    !(sch->ops->flags & QDISC_F_INGRESS) &&
 			    (!p || !(p->ops->flags & QDISC_F_MQ)))
 				root_lock = qdisc_root_sleeping_lock(sch);
 			else
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index e7c648f..2e30b39 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -92,6 +92,7 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
+	.flags		=	QDISC_F_INGRESS,
 	.init		=	ingress_init,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
-- 
1.8.3.1
