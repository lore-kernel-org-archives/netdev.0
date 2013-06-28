From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netem: use rb tree to implement the time queue
Date: Fri, 28 Jun 2013 07:40:57 -0700
Message-ID: <1372430457.3301.272.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:59002 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab3F1Okw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 10:40:52 -0400
Received: by mail-ea0-f180.google.com with SMTP id k10so1093640eaj.25
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 07:40:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Following typical setup to implement a ~100 ms RTT and big
amount of reorders has very poor performance because netem
implements the time queue using a linked list.
-----------------------------------------------------------
ETH=eth0
IFB=ifb0
modprobe ifb
ip link set dev $IFB up
tc qdisc add dev $ETH ingress 2>/dev/null
tc filter add dev $ETH parent ffff: \
   protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress \
   redirect dev $IFB
ethtool -K $ETH gro off tso off gso off
tc qdisc add dev $IFB root netem delay 50ms 10ms limit 100000
tc qd add dev $ETH root netem delay 50ms limit 100000
---------------------------------------------------------

Switch netem time queue to a rb tree, so this kind of setup can work at
high speed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sched/sch_netem.c |  109 +++++++++++++++++++++++++++++++---------
 1 file changed, 85 insertions(+), 24 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3d2acc7..ed0082c 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -23,6 +23,7 @@
 #include <linux/vmalloc.h>
 #include <linux/rtnetlink.h>
 #include <linux/reciprocal_div.h>
+#include <linux/rbtree.h>
 
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
@@ -68,7 +69,8 @@
 */
 
 struct netem_sched_data {
-	/* internal t(ime)fifo qdisc uses sch->q and sch->limit */
+	/* internal t(ime)fifo qdisc uses t_root and sch->limit */
+	struct rb_root t_root;
 
 	/* optional qdisc for classful handling (NULL at netem init) */
 	struct Qdisc	*qdisc;
@@ -128,10 +130,35 @@ struct netem_sched_data {
  */
 struct netem_skb_cb {
 	psched_time_t	time_to_send;
+	ktime_t		tstamp_save;
 };
 
+/* Because space in skb->cb[] is tight, netem overloads skb->next/prev/tstamp
+ * to hold a rb_node structure.
+ *
+ * If struct sk_buff layout is changed, the following checks will complain.
+ */
+static struct rb_node *netem_rb_node(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(offsetof(struct sk_buff, next) != 0);
+	BUILD_BUG_ON(offsetof(struct sk_buff, prev) !=
+		     offsetof(struct sk_buff, next) + sizeof(skb->next));
+	BUILD_BUG_ON(offsetof(struct sk_buff, tstamp) !=
+		     offsetof(struct sk_buff, prev) + sizeof(skb->prev));
+	BUILD_BUG_ON(sizeof(struct rb_node) > sizeof(skb->next) +
+					      sizeof(skb->prev) +
+					      sizeof(skb->tstamp));
+	return (struct rb_node *)&skb->next;
+}
+
+static struct sk_buff *netem_rb_to_skb(struct rb_node *rb)
+{
+	return (struct sk_buff *)rb;
+}
+
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
+	/* we assume we can use skb next/prev/tstamp as storage for rb_node */
 	qdisc_cb_private_validate(skb, sizeof(struct netem_skb_cb));
 	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 }
@@ -333,20 +360,23 @@ static psched_time_t packet_len_2_sched_time(unsigned int len, struct netem_sche
 
 static void tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 {
-	struct sk_buff_head *list = &sch->q;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
-	struct sk_buff *skb = skb_peek_tail(list);
+	struct rb_node **p = &q->t_root.rb_node, *parent = NULL;
 
-	/* Optimize for add at tail */
-	if (likely(!skb || tnext >= netem_skb_cb(skb)->time_to_send))
-		return __skb_queue_tail(list, nskb);
+	while (*p) {
+		struct sk_buff *skb;
 
-	skb_queue_reverse_walk(list, skb) {
+		parent = *p;
+		skb = netem_rb_to_skb(parent);
 		if (tnext >= netem_skb_cb(skb)->time_to_send)
-			break;
+			p = &parent->rb_right;
+		else
+			p = &parent->rb_left;
 	}
-
-	__skb_queue_after(list, skb, nskb);
+	rb_link_node(netem_rb_node(nskb), parent, p);
+	rb_insert_color(netem_rb_node(nskb), &q->t_root);
+	sch->q.qlen++;
 }
 
 /*
@@ -436,23 +466,28 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		now = psched_get_time();
 
 		if (q->rate) {
-			struct sk_buff_head *list = &sch->q;
+			struct sk_buff *last;
 
-			if (!skb_queue_empty(list)) {
+			if (!skb_queue_empty(&sch->q))
+				last = skb_peek_tail(&sch->q);
+			else
+				last = netem_rb_to_skb(rb_last(&q->t_root));
+			if (last) {
 				/*
 				 * Last packet in queue is reference point (now),
 				 * calculate this time bonus and subtract
 				 * from delay.
 				 */
-				delay -= netem_skb_cb(skb_peek_tail(list))->time_to_send - now;
+				delay -= netem_skb_cb(last)->time_to_send - now;
 				delay = max_t(psched_tdiff_t, 0, delay);
-				now = netem_skb_cb(skb_peek_tail(list))->time_to_send;
+				now = netem_skb_cb(last)->time_to_send;
 			}
 
 			delay += packet_len_2_sched_time(skb->len, q);
 		}
 
 		cb->time_to_send = now + delay;
+		cb->tstamp_save = skb->tstamp;
 		++q->counter;
 		tfifo_enqueue(skb, sch);
 	} else {
@@ -476,6 +511,21 @@ static unsigned int netem_drop(struct Qdisc *sch)
 	unsigned int len;
 
 	len = qdisc_queue_drop(sch);
+
+	if (!len) {
+		struct rb_node *p = rb_first(&q->t_root);
+
+		if (p) {
+			struct sk_buff *skb = netem_rb_to_skb(p);
+
+			rb_erase(p, &q->t_root);
+			sch->q.qlen--;
+			skb->next = NULL;
+			skb->prev = NULL;
+			len = qdisc_pkt_len(skb);
+			kfree_skb(skb);
+		}
+	}
 	if (!len && q->qdisc && q->qdisc->ops->drop)
 	    len = q->qdisc->ops->drop(q->qdisc);
 	if (len)
@@ -488,19 +538,32 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
+	struct rb_node *p;
 
 	if (qdisc_is_throttled(sch))
 		return NULL;
 
 tfifo_dequeue:
-	skb = qdisc_peek_head(sch);
+	skb = __skb_dequeue(&sch->q);
 	if (skb) {
-		const struct netem_skb_cb *cb = netem_skb_cb(skb);
+deliver:
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_unthrottled(sch);
+		qdisc_bstats_update(sch, skb);
+		return skb;
+	}
+	p = rb_first(&q->t_root);
+	if (p) {
+		skb = netem_rb_to_skb(p);
 
 		/* if more time remaining? */
-		if (cb->time_to_send <= psched_get_time()) {
-			__skb_unlink(skb, &sch->q);
-			sch->qstats.backlog -= qdisc_pkt_len(skb);
+		if (netem_skb_cb(skb)->time_to_send <= psched_get_time()) {
+			rb_erase(p, &q->t_root);
+
+			sch->q.qlen--;
+			skb->next = NULL;
+			skb->prev = NULL;
+			skb->tstamp = netem_skb_cb(skb)->tstamp_save;
 
 #ifdef CONFIG_NET_CLS_ACT
 			/*
@@ -522,10 +585,7 @@ tfifo_dequeue:
 				}
 				goto tfifo_dequeue;
 			}
-deliver:
-			qdisc_unthrottled(sch);
-			qdisc_bstats_update(sch, skb);
-			return skb;
+			goto deliver;
 		}
 
 		if (q->qdisc) {
@@ -533,7 +593,8 @@ deliver:
 			if (skb)
 				goto deliver;
 		}
-		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
+		qdisc_watchdog_schedule(&q->watchdog,
+					netem_skb_cb(skb)->time_to_send);
 	}
 
 	if (q->qdisc) {
