From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netem: add limitation to reordered packets
Date: Wed, 04 Jul 2012 08:55:21 +0200
Message-ID: <1341384921.2583.1462.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Mark Gordon <msg@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64029 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2GDGz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 02:55:27 -0400
Received: by wibhr14 with SMTP id hr14so5161019wib.1
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2012 23:55:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fix two netem bugs :

1) When a frame was dropped by tfifo_enqueue(), drop counter
   was incremented twice.

2) When reordering is triggered, we enqueue a packet without
   checking queue limit. This can OOM pretty fast when this
   is repeated enough, since skbs are orphaned, no socket limit
   can help in this situation.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Mark Gordon <msg@google.com>
Cc: Andreas Terzis <aterzis@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/sched/sch_netem.c |   42 ++++++++++++++--------------------------
 1 file changed, 15 insertions(+), 27 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a2a95aa..c412ad0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -331,29 +331,22 @@ static psched_time_t packet_len_2_sched_time(unsigned int len, struct netem_sche
 	return PSCHED_NS2TICKS(ticks);
 }
 
-static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
+static void tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 {
 	struct sk_buff_head *list = &sch->q;
 	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
-	struct sk_buff *skb;
-
-	if (likely(skb_queue_len(list) < sch->limit)) {
-		skb = skb_peek_tail(list);
-		/* Optimize for add at tail */
-		if (likely(!skb || tnext >= netem_skb_cb(skb)->time_to_send))
-			return qdisc_enqueue_tail(nskb, sch);
+	struct sk_buff *skb = skb_peek_tail(list);
 
-		skb_queue_reverse_walk(list, skb) {
-			if (tnext >= netem_skb_cb(skb)->time_to_send)
-				break;
-		}
+	/* Optimize for add at tail */
+	if (likely(!skb || tnext >= netem_skb_cb(skb)->time_to_send))
+		return __skb_queue_tail(list, nskb);
 
-		__skb_queue_after(list, skb, nskb);
-		sch->qstats.backlog += qdisc_pkt_len(nskb);
-		return NET_XMIT_SUCCESS;
+	skb_queue_reverse_walk(list, skb) {
+		if (tnext >= netem_skb_cb(skb)->time_to_send)
+			break;
 	}
 
-	return qdisc_reshape_fail(nskb, sch);
+	__skb_queue_after(list, skb, nskb);
 }
 
 /*
@@ -368,7 +361,6 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	/* We don't fill cb now as skb_unshare() may invalidate it */
 	struct netem_skb_cb *cb;
 	struct sk_buff *skb2;
-	int ret;
 	int count = 1;
 
 	/* Random duplication */
@@ -419,6 +411,11 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
 	}
 
+	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
+		return qdisc_reshape_fail(skb, sch);
+
+	sch->qstats.backlog += qdisc_pkt_len(skb);
+
 	cb = netem_skb_cb(skb);
 	if (q->gap == 0 ||		/* not doing reordering */
 	    q->counter < q->gap - 1 ||	/* inside last reordering gap */
@@ -450,7 +447,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = tfifo_enqueue(skb, sch);
+		tfifo_enqueue(skb, sch);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
@@ -460,16 +457,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->counter = 0;
 
 		__skb_queue_head(&sch->q, skb);
-		sch->qstats.backlog += qdisc_pkt_len(skb);
 		sch->qstats.requeues++;
-		ret = NET_XMIT_SUCCESS;
-	}
-
-	if (ret != NET_XMIT_SUCCESS) {
-		if (net_xmit_drop_count(ret)) {
-			sch->qstats.drops++;
-			return ret;
-		}
 	}
 
 	return NET_XMIT_SUCCESS;
