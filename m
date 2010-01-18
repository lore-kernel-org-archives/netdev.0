From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 17:27:05 +0100
Message-ID: <1263832025-28937-1-git-send-email-hagen@jauu.net>
References: <4B546F24.6070404@trash.net>
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:38027 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754602Ab0ARQ1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 11:27:08 -0500
In-Reply-To: <4B546F24.6070404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This add an additional queuing strategy, called pfifo_head_drop,
to remove the oldest skb in the case of an overflow within the queue -
the head element - instead of the last skb (tail). To remove the oldest
skb in a congested situations is useful for sensor network environments
where newer packets reflects the superior information.

Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/net/pkt_sched.h |    2 ++
 net/sched/sch_api.c     |    2 ++
 net/sched/sch_fifo.c    |   37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 0 deletions(-)

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
index 69188e8..44f80ca 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -43,6 +43,28 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return qdisc_reshape_fail(skb, sch);
 }
 
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
+	qdisc_enqueue_tail(skb, sch);
+
+	return NET_XMIT_CN;
+}
+
+
 static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
@@ -108,6 +130,21 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
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
 /* Pass size change message down to embedded FIFO */
 int fifo_set_limit(struct Qdisc *q, unsigned int limit)
 {
-- 
1.6.6.196.g1f735.dirty

