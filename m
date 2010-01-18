From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 14:21:15 +0100
Message-ID: <1263820875-7240-1-git-send-email-hagen@jauu.net>
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:36155 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750911Ab0ARN3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 08:29:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This add an additional queuing strategy, called {p,b}fifo_head_drop,
to remove the oldest skb in the case of an overflow within the queue -
the head element - instead of the last skb (tail). To remove the oldest
skb in a congested situations is useful for sensor network environments
where newer packets reflects the superior information.

Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/net/pkt_sched.h |    2 +
 net/sched/sch_api.c     |    2 +
 net/sched/sch_fifo.c    |   78 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 81 insertions(+), 1 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2d56726..42dc85a 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -71,6 +71,8 @@ extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
 
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
+extern struct Qdisc_ops pfifo_head_drop_qdisc_ops;
+extern struct Qdisc_ops bfifo_head_drop_qdisc_ops;
 
 extern int fifo_set_limit(struct Qdisc *q, unsigned int limit);
 extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 75fd1c6..6eaa35d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1707,6 +1707,8 @@ static int __init pktsched_init(void)
 {
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
+	register_qdisc(&pfifo_head_drop_qdisc_ops);
+	register_qdisc(&bfifo_head_drop_qdisc_ops);
 	register_qdisc(&mq_qdisc_ops);
 	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 69188e8..8286882 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -43,6 +43,50 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return qdisc_reshape_fail(skb, sch);
 }
 
+static int bfifo_front_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct fifo_sched_data *q = qdisc_priv(sch);
+	const unsigned int skb_len = qdisc_pkt_len(skb);
+
+	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= q->limit))
+		return qdisc_enqueue_tail(skb, sch);
+
+	/* queue full -> remove skb's from the queue head until we
+	 * undershoot the queue limit in bytes */
+	do {
+		struct sk_buff *skb_head = qdisc_dequeue_head(sch);
+		if (skb_head == NULL)
+			return qdisc_reshape_fail(skb, sch);
+		sch->bstats.bytes -= qdisc_pkt_len(skb_head);
+		sch->bstats.packets--;
+		sch->q.qlen--;
+		sch->qstats.drops++;
+		kfree_skb(skb_head);
+	} while (sch->qstats.backlog + skb_len > q->limit);
+
+	return qdisc_enqueue_tail(skb, sch);
+}
+
+static int pfifo_front_enqueue(struct sk_buff *skb, struct Qdisc* sch)
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
+	sch->q.qlen--;
+	sch->qstats.drops++;
+	kfree_skb(skb_head);
+
+	return qdisc_enqueue_tail(skb, sch);
+}
+
+
 static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
@@ -50,7 +94,8 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL) {
 		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
 
-		if (sch->ops == &bfifo_qdisc_ops)
+		if ((sch->ops == &bfifo_qdisc_ops) ||
+			(sch->ops == &bfifo_head_drop_qdisc_ops))
 			limit *= psched_mtu(qdisc_dev(sch));
 
 		q->limit = limit;
@@ -108,6 +153,37 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 };
 EXPORT_SYMBOL(bfifo_qdisc_ops);
 
+struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
+	.id		=	"pfifo_head_drop",
+	.priv_size	=	sizeof(struct fifo_sched_data),
+	.enqueue	=	pfifo_front_enqueue,
+	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
+	.drop		=	qdisc_queue_drop,
+	.init		=	fifo_init,
+	.reset		=	qdisc_reset_queue,
+	.change		=	fifo_init,
+	.dump		=	fifo_dump,
+	.owner		=	THIS_MODULE,
+};
+EXPORT_SYMBOL(pfifo_head_drop_qdisc_ops);
+
+struct Qdisc_ops bfifo_head_drop_qdisc_ops __read_mostly = {
+	.id		=	"bfifo_head_drop",
+	.priv_size	=	sizeof(struct fifo_sched_data),
+	.enqueue	=	bfifo_front_enqueue,
+	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
+	.drop		=	qdisc_queue_drop,
+	.init		=	fifo_init,
+	.reset		=	qdisc_reset_queue,
+	.change		=	fifo_init,
+	.dump		=	fifo_dump,
+	.owner		=	THIS_MODULE,
+};
+EXPORT_SYMBOL(bfifo_head_drop_qdisc_ops);
+
+
 /* Pass size change message down to embedded FIFO */
 int fifo_set_limit(struct Qdisc *q, unsigned int limit)
 {
-- 
1.6.5

