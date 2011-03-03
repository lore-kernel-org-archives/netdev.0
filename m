From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched: reduce fifo qdisc size
Date: Thu, 03 Mar 2011 14:27:45 +0100
Message-ID: <1299158865.2983.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47578 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab1CCN1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 08:27:50 -0500
Received: by fxm17 with SMTP id 17so1078171fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 05:27:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because of various alignements [SLUB / qdisc], we use 512 bytes of
memory for one {p|b}fifo qdisc, instead of 256 bytes on 64bit arches and
192 bytes on 32bit ones.

Move the "u32 limit" inside "struct Qdisc" (no impact on other qdiscs)

Change qdisc_alloc(), first trying a regular allocation before an
oversized one.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sch_generic.h |    1 +
 net/sched/sch_fifo.c      |   34 +++++++++++-----------------------
 net/sched/sch_generic.c   |   18 +++++++++++-------
 3 files changed, 23 insertions(+), 30 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 16626a0..1934634 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -83,6 +83,7 @@ struct Qdisc {
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
 	spinlock_t		busylock;
+	u32			limit;
 };
 
 static inline bool qdisc_is_running(const struct Qdisc *qdisc)
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index be33f9d..66effe2 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -19,15 +19,9 @@
 
 /* 1 band FIFO pseudo-"scheduler" */
 
-struct fifo_sched_data {
-	u32 limit;
-};
-
 static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct fifo_sched_data *q = qdisc_priv(sch);
-
-	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= q->limit))
+	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
@@ -35,9 +29,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct fifo_sched_data *q = qdisc_priv(sch);
-
-	if (likely(skb_queue_len(&sch->q) < q->limit))
+	if (likely(skb_queue_len(&sch->q) < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
@@ -45,9 +37,7 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct fifo_sched_data *q = qdisc_priv(sch);
-
-	if (likely(skb_queue_len(&sch->q) < q->limit))
+	if (likely(skb_queue_len(&sch->q) < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	/* queue full, remove one skb to fulfill the limit */
@@ -60,7 +50,6 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
-	struct fifo_sched_data *q = qdisc_priv(sch);
 	bool bypass;
 	bool is_bfifo = sch->ops == &bfifo_qdisc_ops;
 
@@ -70,20 +59,20 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 		if (is_bfifo)
 			limit *= psched_mtu(qdisc_dev(sch));
 
-		q->limit = limit;
+		sch->limit = limit;
 	} else {
 		struct tc_fifo_qopt *ctl = nla_data(opt);
 
 		if (nla_len(opt) < sizeof(*ctl))
 			return -EINVAL;
 
-		q->limit = ctl->limit;
+		sch->limit = ctl->limit;
 	}
 
 	if (is_bfifo)
-		bypass = q->limit >= psched_mtu(qdisc_dev(sch));
+		bypass = sch->limit >= psched_mtu(qdisc_dev(sch));
 	else
-		bypass = q->limit >= 1;
+		bypass = sch->limit >= 1;
 
 	if (bypass)
 		sch->flags |= TCQ_F_CAN_BYPASS;
@@ -94,8 +83,7 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 
 static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct fifo_sched_data *q = qdisc_priv(sch);
-	struct tc_fifo_qopt opt = { .limit = q->limit };
+	struct tc_fifo_qopt opt = { .limit = sch->limit };
 
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	return skb->len;
@@ -106,7 +94,7 @@ nla_put_failure:
 
 struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.id		=	"pfifo",
-	.priv_size	=	sizeof(struct fifo_sched_data),
+	.priv_size	=	0,
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -121,7 +109,7 @@ EXPORT_SYMBOL(pfifo_qdisc_ops);
 
 struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.id		=	"bfifo",
-	.priv_size	=	sizeof(struct fifo_sched_data),
+	.priv_size	=	0,
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -136,7 +124,7 @@ EXPORT_SYMBOL(bfifo_qdisc_ops);
 
 struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
 	.id		=	"pfifo_head_drop",
-	.priv_size	=	sizeof(struct fifo_sched_data),
+	.priv_size	=	0,
 	.enqueue	=	pfifo_tail_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0da09d5..a854cab 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -550,21 +550,25 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 {
 	void *p;
 	struct Qdisc *sch;
-	unsigned int size;
+	unsigned int size = QDISC_ALIGN(sizeof(*sch)) + ops->priv_size;
 	int err = -ENOBUFS;
 
-	/* ensure that the Qdisc and the private data are 64-byte aligned */
-	size = QDISC_ALIGN(sizeof(*sch));
-	size += ops->priv_size + (QDISC_ALIGNTO - 1);
-
 	p = kzalloc_node(size, GFP_KERNEL,
 			 netdev_queue_numa_node_read(dev_queue));
 
 	if (!p)
 		goto errout;
 	sch = (struct Qdisc *) QDISC_ALIGN((unsigned long) p);
-	sch->padded = (char *) sch - (char *) p;
-
+	/* if we got non aligned memory, ask more and do alignment ourself */
+	if (sch != p) {
+		kfree(p);
+		p = kzalloc_node(size + QDISC_ALIGNTO - 1, GFP_KERNEL,
+				 netdev_queue_numa_node_read(dev_queue));
+		if (!p)
+			goto errout;
+		sch = (struct Qdisc *) QDISC_ALIGN((unsigned long) p);
+		sch->padded = (char *) sch - (char *) p;
+	}
 	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 	spin_lock_init(&sch->busylock);


