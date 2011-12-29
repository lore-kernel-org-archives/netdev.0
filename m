From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 05:26:00 +0100
Message-ID: <1325132760.2607.15.camel@edumazet-laptop>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	 <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	 <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	 <1324664907.2915.5.camel@edumazet-laptop>
	 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
	 <1324668083.2915.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46186 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583Ab1L2E0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 23:26:06 -0500
Received: by wibhm6 with SMTP id hm6so6035750wib.19
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 20:26:04 -0800 (PST)
In-Reply-To: <1324668083.2915.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 10f6dfcfde (Revert "sch_netem: Remove classful functionality")
reintroduced classful functionality to netem, but broke basic netem
behavior :

netem uses an t(ime)fifo queue, and store timestamps in skb->cb[]

If qdisc is changed, time constraints are not respected and other qdisc
can destroy skb->cb[] and block netem at dequeue time.

Fix this by always using internal tfifo, and optionally attach a child
qdisc to netem.

Example of use :

DEV=eth3
tc qdisc del dev $DEV root
tc qdisc add dev $DEV root handle 30: est 1sec 8sec netem delay 20ms 10ms
tc qdisc add dev $DEV parent 30:0 sfq

# tc -s -d qdisc show dev eth3
qdisc netem 30: root refcnt 18 limit 1000 delay 20.0ms  10.0ms
 Sent 893810 bytes 891 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 690192bit 61pps backlog 5972b 2p requeues 0 
qdisc sfq 800b: parent 30: limit 127p quantum 1514b flows 127/1024 divisor 1024 
 Sent 893810 bytes 891 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 net/sched/sch_netem.c |  204 +++++++++++++++-------------------------
 1 file changed, 81 insertions(+), 123 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index ffcaa59..641bee5 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -67,7 +67,11 @@
 */
 
 struct netem_sched_data {
+	/* internal t(ime)fifo qdisc uses sch->q and sch->limit */
+
+	/* optional qdisc for classful handling (NULL at netem init) */
 	struct Qdisc	*qdisc;
+
 	struct qdisc_watchdog watchdog;
 
 	psched_tdiff_t latency;
@@ -117,7 +121,9 @@ struct netem_sched_data {
 
 };
 
-/* Time stamp put into socket buffer control block */
+/* Time stamp put into socket buffer control block
+ * Only valid when skbs are in our internal t(ime)fifo queue.
+ */
 struct netem_skb_cb {
 	psched_time_t	time_to_send;
 };
@@ -324,6 +330,31 @@ static psched_time_t packet_len_2_sched_time(unsigned int len, struct netem_sche
 	return PSCHED_NS2TICKS(ticks);
 }
 
+static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
+{
+	struct sk_buff_head *list = &sch->q;
+	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
+	struct sk_buff *skb;
+
+	if (likely(skb_queue_len(list) < sch->limit)) {
+		skb = skb_peek_tail(list);
+		/* Optimize for add at tail */
+		if (likely(!skb || tnext >= netem_skb_cb(skb)->time_to_send))
+			return qdisc_enqueue_tail(nskb, sch);
+
+		skb_queue_reverse_walk(list, skb) {
+			if (tnext >= netem_skb_cb(skb)->time_to_send)
+				break;
+		}
+
+		__skb_queue_after(list, skb, nskb);
+		sch->qstats.backlog += qdisc_pkt_len(nskb);
+		return NET_XMIT_SUCCESS;
+	}
+
+	return qdisc_reshape_fail(nskb, sch);
+}
+
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -399,7 +430,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		now = psched_get_time();
 
 		if (q->rate) {
-			struct sk_buff_head *list = &q->qdisc->q;
+			struct sk_buff_head *list = &sch->q;
 
 			delay += packet_len_2_sched_time(skb->len, q);
 
@@ -417,7 +448,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = qdisc_enqueue(skb, q->qdisc);
+		ret = tfifo_enqueue(skb, sch);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
@@ -426,9 +457,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
 
-		__skb_queue_head(&q->qdisc->q, skb);
-		q->qdisc->qstats.backlog += qdisc_pkt_len(skb);
-		q->qdisc->qstats.requeues++;
+		__skb_queue_head(&sch->q, skb);
 		ret = NET_XMIT_SUCCESS;
 	}
 
@@ -439,19 +468,20 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	sch->q.qlen++;
 	return NET_XMIT_SUCCESS;
 }
 
 static unsigned int netem_drop(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned int len = 0;
+	unsigned int len;
 
-	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
-		sch->q.qlen--;
+	len = qdisc_queue_drop(sch);
+	if (!len && q->qdisc && q->qdisc->ops->drop)
+	    len = q->qdisc->ops->drop(q->qdisc);
+	if (len)
 		sch->qstats.drops++;
-	}
+
 	return len;
 }
 
@@ -463,16 +493,16 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	if (qdisc_is_throttled(sch))
 		return NULL;
 
-	skb = q->qdisc->ops->peek(q->qdisc);
+tfifo_dequeue:
+	skb = qdisc_peek_head(sch);
 	if (skb) {
 		const struct netem_skb_cb *cb = netem_skb_cb(skb);
-		psched_time_t now = psched_get_time();
 
 		/* if more time remaining? */
-		if (cb->time_to_send <= now) {
-			skb = qdisc_dequeue_peeked(q->qdisc);
+		if (cb->time_to_send <= psched_get_time()) {
+			skb = qdisc_dequeue_tail(sch);
 			if (unlikely(!skb))
-				return NULL;
+				goto qdisc_dequeue;
 
 #ifdef CONFIG_NET_CLS_ACT
 			/*
@@ -483,15 +513,37 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 				skb->tstamp.tv64 = 0;
 #endif
 
-			sch->q.qlen--;
+			if (q->qdisc) {
+				int err = qdisc_enqueue(skb, q->qdisc);
+
+				if (unlikely(err != NET_XMIT_SUCCESS)) {
+					if (net_xmit_drop_count(err)) {
+						sch->qstats.drops++;
+						qdisc_tree_decrease_qlen(sch, 1);
+					}
+				}
+				goto tfifo_dequeue;
+			}
+deliver:
 			qdisc_unthrottled(sch);
 			qdisc_bstats_update(sch, skb);
 			return skb;
 		}
 
+		if (q->qdisc) {
+			skb = q->qdisc->ops->dequeue(q->qdisc);
+			if (skb)
+				goto deliver;
+		}
 		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 	}
 
+qdisc_dequeue:
+	if (q->qdisc) {
+		skb = q->qdisc->ops->dequeue(q->qdisc);
+		if (skb)
+			goto deliver;
+	}
 	return NULL;
 }
 
@@ -499,8 +551,9 @@ static void netem_reset(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
-	qdisc_reset(q->qdisc);
-	sch->q.qlen = 0;
+	qdisc_reset_queue(sch);
+	if (q->qdisc)
+		qdisc_reset(q->qdisc);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
@@ -689,11 +742,7 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (ret < 0)
 		return ret;
 
-	ret = fifo_set_limit(q->qdisc, qopt->limit);
-	if (ret) {
-		pr_info("netem: can't set fifo limit\n");
-		return ret;
-	}
+	sch->limit = qopt->limit;
 
 	q->latency = qopt->latency;
 	q->jitter = qopt->jitter;
@@ -734,88 +783,6 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	return ret;
 }
 
-/*
- * Special case version of FIFO queue for use by netem.
- * It queues in order based on timestamps in skb's
- */
-struct fifo_sched_data {
-	u32 limit;
-	psched_time_t oldest;
-};
-
-static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
-{
-	struct fifo_sched_data *q = qdisc_priv(sch);
-	struct sk_buff_head *list = &sch->q;
-	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
-	struct sk_buff *skb;
-
-	if (likely(skb_queue_len(list) < q->limit)) {
-		/* Optimize for add at tail */
-		if (likely(skb_queue_empty(list) || tnext >= q->oldest)) {
-			q->oldest = tnext;
-			return qdisc_enqueue_tail(nskb, sch);
-		}
-
-		skb_queue_reverse_walk(list, skb) {
-			const struct netem_skb_cb *cb = netem_skb_cb(skb);
-
-			if (tnext >= cb->time_to_send)
-				break;
-		}
-
-		__skb_queue_after(list, skb, nskb);
-
-		sch->qstats.backlog += qdisc_pkt_len(nskb);
-
-		return NET_XMIT_SUCCESS;
-	}
-
-	return qdisc_reshape_fail(nskb, sch);
-}
-
-static int tfifo_init(struct Qdisc *sch, struct nlattr *opt)
-{
-	struct fifo_sched_data *q = qdisc_priv(sch);
-
-	if (opt) {
-		struct tc_fifo_qopt *ctl = nla_data(opt);
-		if (nla_len(opt) < sizeof(*ctl))
-			return -EINVAL;
-
-		q->limit = ctl->limit;
-	} else
-		q->limit = max_t(u32, qdisc_dev(sch)->tx_queue_len, 1);
-
-	q->oldest = PSCHED_PASTPERFECT;
-	return 0;
-}
-
-static int tfifo_dump(struct Qdisc *sch, struct sk_buff *skb)
-{
-	struct fifo_sched_data *q = qdisc_priv(sch);
-	struct tc_fifo_qopt opt = { .limit = q->limit };
-
-	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
-	return skb->len;
-
-nla_put_failure:
-	return -1;
-}
-
-static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
-	.id		=	"tfifo",
-	.priv_size	=	sizeof(struct fifo_sched_data),
-	.enqueue	=	tfifo_enqueue,
-	.dequeue	=	qdisc_dequeue_head,
-	.peek		=	qdisc_peek_head,
-	.drop		=	qdisc_queue_drop,
-	.init		=	tfifo_init,
-	.reset		=	qdisc_reset_queue,
-	.change		=	tfifo_init,
-	.dump		=	tfifo_dump,
-};
-
 static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -827,18 +794,9 @@ static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 	qdisc_watchdog_init(&q->watchdog, sch);
 
 	q->loss_model = CLG_RANDOM;
-	q->qdisc = qdisc_create_dflt(sch->dev_queue, &tfifo_qdisc_ops,
-				     TC_H_MAKE(sch->handle, 1));
-	if (!q->qdisc) {
-		pr_notice("netem: qdisc create tfifo qdisc failed\n");
-		return -ENOMEM;
-	}
-
 	ret = netem_change(sch, opt);
-	if (ret) {
+	if (ret)
 		pr_info("netem: change failed\n");
-		qdisc_destroy(q->qdisc);
-	}
 	return ret;
 }
 
@@ -847,7 +805,8 @@ static void netem_destroy(struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
-	qdisc_destroy(q->qdisc);
+	if (q->qdisc)
+		qdisc_destroy(q->qdisc);
 	dist_free(q->delay_dist);
 }
 
@@ -951,7 +910,7 @@ static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
-	if (cl != 1) 	/* only one class */
+	if (cl != 1 || !q->qdisc) 	/* only one class */
 		return -ENOENT;
 
 	tcm->tcm_handle |= TC_H_MIN(1);
@@ -965,14 +924,13 @@ static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
-	if (new == NULL)
-		new = &noop_qdisc;
-
 	sch_tree_lock(sch);
 	*old = q->qdisc;
 	q->qdisc = new;
-	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-	qdisc_reset(*old);
+	if (*old) {
+		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+		qdisc_reset(*old);
+	}
 	sch_tree_unlock(sch);
 
 	return 0;
