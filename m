From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched:  TCQ_F_CAN_BYPASS generalization
Date: Fri, 21 Jan 2011 12:04:41 +0100
Message-ID: <1295607881.2601.31.camel@edumazet-laptop>
References: <1295517052.2733.14.camel@edumazet-laptop>
	 <1295518636.2825.4.camel@edumazet-laptop>
	 <1295531299.2825.175.camel@edumazet-laptop>
	 <1295537236.2825.286.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49570 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab1AULEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 06:04:47 -0500
Received: by wyb28 with SMTP id 28so1667088wyb.19
        for <netdev@vger.kernel.org>; Fri, 21 Jan 2011 03:04:45 -0800 (PST)
In-Reply-To: <1295537236.2825.286.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now qdisc stab is handled before TCQ_F_CAN_BYPASS test in
__dev_xmit_skb(), we can generalize TCQ_F_CAN_BYPASS to other qdiscs
than pfifo_fast : pfifo, bfifo, pfifo_head_drop and sfq

SFQ is special because it can have external classifiers, and in these
cases, we cannot bypass queue discipline (packet could be dropped by
classifier) without admin asking it, or further changes.

Its worth doing this, especially for SFQ, avoiding dirtying memory in
case no packets are already waiting in queue.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jesper Dangaard Brouer <hawk@diku.dk>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Jamal Hadi Salim <hadi@cyberus.ca>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
I am not sure RED can use bypass too, feel free to comment on this ;)

 net/sched/sch_fifo.c    |   13 ++++++++++++-
 net/sched/sch_generic.c |    5 ++---
 net/sched/sch_mq.c      |    1 -
 net/sched/sch_mqprio.c  |    1 -
 net/sched/sch_sfq.c     |    6 ++++++
 5 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index b3075f8..f7290d2 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -64,11 +64,13 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
+	bool bypass;
+	bool is_bfifo = sch->ops == &bfifo_qdisc_ops;
 
 	if (opt == NULL) {
 		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
 
-		if (sch->ops == &bfifo_qdisc_ops)
+		if (is_bfifo)
 			limit *= psched_mtu(qdisc_dev(sch));
 
 		q->limit = limit;
@@ -81,6 +83,15 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 		q->limit = ctl->limit;
 	}
 
+	if (is_bfifo)
+		bypass = q->limit >= psched_mtu(qdisc_dev(sch));
+	else
+		bypass = q->limit >= 1;
+
+	if (bypass)
+		sch->flags |= TCQ_F_CAN_BYPASS;
+	else
+		sch->flags &= ~TCQ_F_CAN_BYPASS;
 	return 0;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cc17e79..0da09d5 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -527,6 +527,8 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
 		skb_queue_head_init(band2list(priv, prio));
 
+	/* Can by-pass the queue discipline */
+	qdisc->flags |= TCQ_F_CAN_BYPASS;
 	return 0;
 }
 
@@ -691,9 +693,6 @@ static void attach_one_default_qdisc(struct net_device *dev,
 			netdev_info(dev, "activation failed\n");
 			return;
 		}
-
-		/* Can by-pass the queue discipline for default qdisc */
-		qdisc->flags |= TCQ_F_CAN_BYPASS;
 	}
 	dev_queue->qdisc_sleeping = qdisc;
 }
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index ecc302f..ec5cbc8 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -61,7 +61,6 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 						    TC_H_MIN(ntx + 1)));
 		if (qdisc == NULL)
 			goto err;
-		qdisc->flags |= TCQ_F_CAN_BYPASS;
 		priv->qdiscs[ntx] = qdisc;
 	}
 
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 8620c65..fbc6f53 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -130,7 +130,6 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 			err = -ENOMEM;
 			goto err;
 		}
-		qdisc->flags |= TCQ_F_CAN_BYPASS;
 		priv->qdiscs[i] = qdisc;
 	}
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 156ad30..fdba52a 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -560,6 +560,10 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 		slot_queue_init(&q->slots[i]);
 		sfq_link(q, i);
 	}
+	if (q->limit >= 1)
+		sch->flags |= TCQ_F_CAN_BYPASS;
+	else
+		sch->flags &= ~TCQ_F_CAN_BYPASS;
 	return 0;
 }
 
@@ -611,6 +615,8 @@ static unsigned long sfq_get(struct Qdisc *sch, u32 classid)
 static unsigned long sfq_bind(struct Qdisc *sch, unsigned long parent,
 			      u32 classid)
 {
+	/* we cannot bypass queue discipline anymore */
+	sch->flags &= ~TCQ_F_CAN_BYPASS;
 	return 0;
 }
 


