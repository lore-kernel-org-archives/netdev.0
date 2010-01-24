From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] sched: add head drop fifo queue
Date: Sun, 24 Jan 2010 23:30:59 +0100
Message-ID: <1264372259-31357-1-git-send-email-hagen@jauu.net>
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42913 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752497Ab0AXWbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 17:31:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds an additional queuing strategy, called pfifo_head_drop,
to remove the oldest skb in the case of an overflow within the queue -
the head element - instead of the last skb (tail). To remove the oldest
skb in congested situations is useful for sensor network environments
where newer packets reflect the superior information.

Reviewed-by: Florian Westphal <fw@strlen.de>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/net/pkt_sched.h   |    1 +
 include/net/sch_generic.h |   19 +++++++++++++++++++
 net/sched/sch_api.c       |    1 +
 net/sched/sch_fifo.c      |   34 ++++++++++++++++++++++++++++++++++
 4 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2d56726..b6cdc33 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -71,6 +71,7 @@ extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
 
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
+extern struct Qdisc_ops pfifo_head_drop_qdisc_ops;
 
 extern int fifo_set_limit(struct Qdisc *q, unsigned int limit);
 extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index dad558b..67dc08e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -427,6 +427,25 @@ static inline struct sk_buff *qdisc_dequeue_head(struct Qdisc *sch)
 	return __qdisc_dequeue_head(sch, &sch->q);
 }
 
+static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
+					      struct sk_buff_head *list)
+{
+	struct sk_buff *skb = __qdisc_dequeue_head(sch, list);
+
+	if (likely(skb != NULL)) {
+		unsigned int len = qdisc_pkt_len(skb);
+		kfree_skb(skb);
+		return len;
+	}
+
+	return 0;
+}
+
+static inline unsigned int qdisc_queue_drop_head(struct Qdisc *sch)
+{
+	return __qdisc_queue_drop_head(sch, &sch->q);
+}
+
 static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
 						   struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 75fd1c6..6cd4910 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1707,6 +1707,7 @@ static int __init pktsched_init(void)
 {
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
+	register_qdisc(&pfifo_head_drop_qdisc_ops);
 	register_qdisc(&mq_qdisc_ops);
 	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 69188e8..4b0a6cc 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -43,6 +43,26 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return qdisc_reshape_fail(skb, sch);
 }
 
+static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct sk_buff *skb_head;
+	struct fifo_sched_data *q = qdisc_priv(sch);
+
+	if (likely(skb_queue_len(&sch->q) < q->limit))
+		return qdisc_enqueue_tail(skb, sch);
+
+	/* queue full, remove one skb to fulfill the limit */
+	skb_head = qdisc_dequeue_head(sch);
+	sch->bstats.bytes -= qdisc_pkt_len(skb_head);
+	sch->bstats.packets--;
+	sch->qstats.drops++;
+	kfree_skb(skb_head);
+
+	qdisc_enqueue_tail(skb, sch);
+
+	return NET_XMIT_CN;
+}
+
 static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
@@ -108,6 +128,20 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 };
 EXPORT_SYMBOL(bfifo_qdisc_ops);
 
+struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
+	.id		=	"pfifo_head_drop",
+	.priv_size	=	sizeof(struct fifo_sched_data),
+	.enqueue	=	pfifo_tail_enqueue,
+	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
+	.drop		=	qdisc_queue_drop_head,
+	.init		=	fifo_init,
+	.reset		=	qdisc_reset_queue,
+	.change		=	fifo_init,
+	.dump		=	fifo_dump,
+	.owner		=	THIS_MODULE,
+};
+
 /* Pass size change message down to embedded FIFO */
 int fifo_set_limit(struct Qdisc *q, unsigned int limit)
 {
-- 
1.6.6.196.g1f735.dirty

