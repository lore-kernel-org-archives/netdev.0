From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 -next 3/5] sched: remove qdisc_rehape_fail
Date: Thu,  9 Jun 2016 00:27:41 +0200
Message-ID: <1465424863-18456-4-git-send-email-fw@strlen.de>
References: <1465424863-18456-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60738 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753406AbcFHW1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 18:27:36 -0400
In-Reply-To: <1465424863-18456-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the removal of TCA_CBQ_POLICE in cbq scheduler qdisc->reshape_fail
is always NULL, i.e. qdisc_rehape_fail is now the same as qdisc_drop.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sch_generic.h | 19 -------------------
 net/sched/sch_fifo.c      |  4 ++--
 net/sched/sch_netem.c     |  4 ++--
 net/sched/sch_plug.c      |  2 +-
 net/sched/sch_tbf.c       |  4 ++--
 5 files changed, 7 insertions(+), 26 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c069ac1..a9aec63 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -63,9 +63,6 @@ struct Qdisc {
 	struct list_head	list;
 	u32			handle;
 	u32			parent;
-	int			(*reshape_fail)(struct sk_buff *skb,
-					struct Qdisc *q);
-
 	void			*u32_node;
 
 	struct netdev_queue	*dev_queue;
@@ -771,22 +768,6 @@ static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_DROP;
 }
 
-static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
-{
-	qdisc_qstats_drop(sch);
-
-#ifdef CONFIG_NET_CLS_ACT
-	if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
-		goto drop;
-
-	return NET_XMIT_SUCCESS;
-
-drop:
-#endif
-	kfree_skb(skb);
-	return NET_XMIT_DROP;
-}
-
 /* Length to Time (L2T) lookup in a qdisc_rate_table, to determine how
    long it will take to send a packet given its size.
  */
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 2177eac..7857f74 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -24,7 +24,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
-	return qdisc_reshape_fail(skb, sch);
+	return qdisc_drop(skb, sch);
 }
 
 static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
@@ -32,7 +32,7 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (likely(skb_queue_len(&sch->q) < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
-	return qdisc_reshape_fail(skb, sch);
+	return qdisc_drop(skb, sch);
 }
 
 static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 205bed0..31984c7 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -407,7 +407,7 @@ static struct sk_buff *netem_segment(struct sk_buff *skb, struct Qdisc *sch)
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
 
 	if (IS_ERR_OR_NULL(segs)) {
-		qdisc_reshape_fail(skb, sch);
+		qdisc_drop(skb, sch);
 		return NULL;
 	}
 	consume_skb(skb);
@@ -499,7 +499,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
-		return qdisc_reshape_fail(skb, sch);
+		return qdisc_drop(skb, sch);
 
 	qdisc_qstats_backlog_inc(sch, skb);
 
diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index 5abfe44..ff0d968 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -96,7 +96,7 @@ static int plug_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return qdisc_enqueue_tail(skb, sch);
 	}
 
-	return qdisc_reshape_fail(skb, sch);
+	return qdisc_drop(skb, sch);
 }
 
 static struct sk_buff *plug_dequeue(struct Qdisc *sch)
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 83b90b5..801148c 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -166,7 +166,7 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
 
 	if (IS_ERR_OR_NULL(segs))
-		return qdisc_reshape_fail(skb, sch);
+		return qdisc_drop(skb, sch);
 
 	nb = 0;
 	while (segs) {
@@ -198,7 +198,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (qdisc_pkt_len(skb) > q->max_size) {
 		if (skb_is_gso(skb) && skb_gso_mac_seglen(skb) <= q->max_size)
 			return tbf_segment(skb, sch);
-		return qdisc_reshape_fail(skb, sch);
+		return qdisc_drop(skb, sch);
 	}
 	ret = qdisc_enqueue(skb, q->qdisc);
 	if (ret != NET_XMIT_SUCCESS) {
-- 
2.7.3
