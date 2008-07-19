From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v2 1/3] net_sched: Add qdisc_enqueue wrapper
Date: Sun, 20 Jul 2008 02:35:01 +0300
Message-ID: <20080719233500.12596.16970.stgit@fate.lan>
References: <20080719233441.12596.91242.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:54105 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250AbYGSXfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 19:35:04 -0400
In-Reply-To: <20080719233441.12596.91242.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/net/sch_generic.h |   10 ++++++++++
 net/core/dev.c            |    4 ++--
 net/mac80211/wme.c        |    2 +-
 net/sched/sch_atm.c       |    2 +-
 net/sched/sch_cbq.c       |    5 +++--
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_hfsc.c      |    2 +-
 net/sched/sch_htb.c       |    3 +--
 net/sched/sch_netem.c     |   20 ++++++++++++--------
 net/sched/sch_prio.c      |    3 ++-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_tbf.c       |    3 ++-
 12 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 8a44386..f396dff 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -306,6 +306,16 @@ static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 	return true;
 }
 
+static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	return sch->enqueue(skb, sch);
+}
+
+static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
+{
+	return qdisc_enqueue(skb, sch);
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 065b981..2eed17b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1781,7 +1781,7 @@ gso:
 
 		spin_lock(root_lock);
 
-		rc = q->enqueue(skb, q);
+		rc = qdisc_enqueue_root(skb, q);
 		qdisc_run(q);
 
 		spin_unlock(root_lock);
@@ -2083,7 +2083,7 @@ static int ing_filter(struct sk_buff *skb)
 	q = rxq->qdisc;
 	if (q) {
 		spin_lock(qdisc_lock(q));
-		result = q->enqueue(skb, q);
+		result = qdisc_enqueue_root(skb, q);
 		spin_unlock(qdisc_lock(q));
 	}
 
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 6e8099e..07edda0 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -289,7 +289,7 @@ void ieee80211_requeue(struct ieee80211_local *local, int queue)
 		root_lock = qdisc_root_lock(qdisc);
 
 		spin_lock(root_lock);
-		qdisc->enqueue(skb, qdisc);
+		qdisc_enqueue_root(skb, qdisc);
 		spin_unlock(root_lock);
 	}
 
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
index a3953bb..1afe3ee 100644
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
index 5090708..fd61ed6 100644
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
index ee48457..72b5a94 100644
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
index c5ea40c..13c4821 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -82,6 +82,12 @@ struct netem_skb_cb {
 	psched_time_t	time_to_send;
 };
 
+static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct netem_skb_cb));
+	return (struct netem_skb_cb *)skb->cb;
+}
+
 /* init_crandom - initialize correlated random number generator
  * Use entropy source for initial seed.
  */
@@ -184,7 +190,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
-		rootq->enqueue(skb2, rootq);
+		qdisc_enqueue_root(skb2, rootq);
 		q->duplicate = dupsave;
 	}
 
@@ -205,7 +211,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
 	}
 
-	cb = (struct netem_skb_cb *)skb->cb;
+	cb = netem_skb_cb(skb);
 	if (q->gap == 0 		/* not doing reordering */
 	    || q->counter < q->gap 	/* inside last reordering gap */
 	    || q->reorder < get_crandom(&q->reorder_cor)) {
@@ -218,7 +224,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		now = psched_get_time();
 		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = q->qdisc->enqueue(skb, q->qdisc);
+		ret = qdisc_enqueue(skb, q->qdisc);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
@@ -277,8 +283,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
-		const struct netem_skb_cb *cb
-			= (const struct netem_skb_cb *)skb->cb;
+		const struct netem_skb_cb *cb = netem_skb_cb(skb);
 		psched_time_t now = psched_get_time();
 
 		/* if more time remaining? */
@@ -457,7 +462,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 	struct sk_buff_head *list = &sch->q;
-	psched_time_t tnext = ((struct netem_skb_cb *)nskb->cb)->time_to_send;
+	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
 	struct sk_buff *skb;
 
 	if (likely(skb_queue_len(list) < q->limit)) {
@@ -468,8 +473,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 		}
 
 		skb_queue_reverse_walk(list, skb) {
-			const struct netem_skb_cb *cb
-				= (const struct netem_skb_cb *)skb->cb;
+			const struct netem_skb_cb *cb = netem_skb_cb(skb);
 
 			if (tnext >= cb->time_to_send)
 				break;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 536ca47..d29c2f8 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -81,7 +81,8 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
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

