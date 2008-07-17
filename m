From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH RFC 1/3] net_sched: Add qdisc_enqueue wrapper
Date: Thu, 17 Jul 2008 13:09:27 +0300
Message-ID: <20080717100927.3327.4197.stgit@fate.lan>
References: <20080717100921.3327.3324.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:62789 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249AbYGQKJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:09:30 -0400
In-Reply-To: <20080717100921.3327.3324.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/net/sch_generic.h |    5 +++++
 net/core/dev.c            |    2 +-
 net/mac80211/wme.c        |    2 +-
 net/sched/sch_atm.c       |    2 +-
 net/sched/sch_cbq.c       |    5 +++--
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_hfsc.c      |    2 +-
 net/sched/sch_htb.c       |    3 +--
 net/sched/sch_netem.c     |   19 +++++++++++--------
 net/sched/sch_prio.c      |    3 ++-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_tbf.c       |    3 ++-
 12 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 5ba66b5..e3b0d71 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -258,6 +258,11 @@ static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 	return (txq->qdisc == &noop_qdisc);
 }
 
+static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	return sch->enqueue(skb, sch);
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 9b49f74..ee2df34 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1733,7 +1733,7 @@ gso:
 		if (q->enqueue) {
 			/* reset queue_mapping to zero */
 			skb_set_queue_mapping(skb, 0);
-			rc = q->enqueue(skb, q);
+			rc = qdisc_enqueue(skb, q);
 			qdisc_run(txq);
 			spin_unlock(&txq->lock);
 
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 6ae43a3..e263917 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -212,7 +212,7 @@ static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 	} else {
 		skb_set_queue_mapping(skb, queue);
 		qdisc = q->queues[queue];
-		err = qdisc->enqueue(skb, qdisc);
+		err = qdisc_enqueue(skb, qdisc);
 		if (err == NET_XMIT_SUCCESS) {
 			qd->q.qlen++;
 			qd->bstats.bytes += skb->len;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 0de757e..68ed35e 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -429,7 +429,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #endif
 	}
 
-	ret = flow->q->enqueue(skb, flow->q);
+	ret = qdisc_enqueue(skb, flow->q);
 	if (ret != 0) {
 drop: __maybe_unused
 		sch->qstats.drops++;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 4efc836..1bcb3e8 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -387,7 +387,8 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 	cl->q->__parent = sch;
 #endif
-	if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
+	ret = qdisc_enqueue(skb, cl->q);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->bstats.packets++;
 		sch->bstats.bytes+=len;
@@ -671,7 +672,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 		q->rx_class = cl;
 		cl->q->__parent = sch;
 
-		if (cl->q->enqueue(skb, cl->q) == 0) {
+		if (qdisc_enqueue(skb, cl->q) == 0) {
 			sch->q.qlen++;
 			sch->bstats.packets++;
 			sch->bstats.bytes+=len;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 3aafbd1..44d347e 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -252,7 +252,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	err = p->q->enqueue(skb, p->q);
+	err = qdisc_enqueue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		return err;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 997d520..0ded6d0 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1586,7 +1586,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	len = skb->len;
-	err = cl->qdisc->enqueue(skb, cl->qdisc);
+	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->qstats.drops++;
 		sch->qstats.drops++;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c8ca54c..5fc0325 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -572,8 +572,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
-		   NET_XMIT_SUCCESS) {
+	} else if (qdisc_enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		cl->qstats.drops++;
 		return NET_XMIT_DROP;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bc585f2..cbdbc6a 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -82,6 +82,11 @@ struct netem_skb_cb {
 	psched_time_t	time_to_send;
 };
 
+static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
+{
+	return (struct netem_skb_cb *)skb->cb;
+}
+
 /* init_crandom - initialize correlated random number generator
  * Use entropy source for initial seed.
  */
@@ -184,7 +189,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
-		rootq->enqueue(skb2, rootq);
+		qdisc_enqueue(skb2, rootq);
 		q->duplicate = dupsave;
 	}
 
@@ -205,7 +210,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
 	}
 
-	cb = (struct netem_skb_cb *)skb->cb;
+	cb = netem_skb_cb(skb);
 	if (q->gap == 0 		/* not doing reordering */
 	    || q->counter < q->gap 	/* inside last reordering gap */
 	    || q->reorder < get_crandom(&q->reorder_cor)) {
@@ -218,7 +223,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		now = psched_get_time();
 		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = q->qdisc->enqueue(skb, q->qdisc);
+		ret = qdisc_enqueue(skb, q->qdisc);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
@@ -277,8 +282,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
-		const struct netem_skb_cb *cb
-			= (const struct netem_skb_cb *)skb->cb;
+		const struct netem_skb_cb *cb = netem_skb_cb(skb);
 		psched_time_t now = psched_get_time();
 
 		/* if more time remaining? */
@@ -454,7 +458,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 	struct sk_buff_head *list = &sch->q;
-	psched_time_t tnext = ((struct netem_skb_cb *)nskb->cb)->time_to_send;
+	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
 	struct sk_buff *skb;
 
 	if (likely(skb_queue_len(list) < q->limit)) {
@@ -465,8 +469,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 		}
 
 		skb_queue_reverse_walk(list, skb) {
-			const struct netem_skb_cb *cb
-				= (const struct netem_skb_cb *)skb->cb;
+			const struct netem_skb_cb *cb = netem_skb_cb(skb);
 
 			if (tnext >= cb->time_to_send)
 				break;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 39157f7..918d090 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -86,7 +86,8 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 #endif
 
-	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
+	ret = qdisc_enqueue(skb, qdisc);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
 		sch->q.qlen++;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 77098ac..b48a391 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -92,7 +92,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			break;
 	}
 
-	ret = child->enqueue(skb, child);
+	ret = qdisc_enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 444c227..7d705b8 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -133,7 +133,8 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		return NET_XMIT_DROP;
 	}
 
-	if ((ret = q->qdisc->enqueue(skb, q->qdisc)) != 0) {
+	ret = qdisc_enqueue(skb, q->qdisc);
+	if (ret != 0) {
 		sch->qstats.drops++;
 		return ret;
 	}

