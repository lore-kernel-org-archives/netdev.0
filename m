From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] net_sched: generalize bulk dequeue
Date: Tue, 21 Jun 2016 23:16:52 -0700
Message-ID: <1466576212-15012-5-git-send-email-edumazet@google.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33125 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbcFVGZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 02:25:00 -0400
Received: by mail-pf0-f180.google.com with SMTP id i123so14481750pfg.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 23:23:48 -0700 (PDT)
In-Reply-To: <1466576212-15012-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When qdisc bulk dequeue was added in linux-3.18 (commit
5772e9a3463b "qdisc: bulk dequeue support for qdiscs
with TCQ_F_ONETXQUEUE"), it was constrained to some
specific qdiscs.

With some extra care, we can extend this to all qdiscs,
so that typical traffic shaping solutions can benefit from
small batches (8 packets in this patch).

For example, HTB is often used on some multi queue device.
And bonding/team are multi queue devices...

Idea is to bulk-dequeue packets mapping to the same transmit queue.

This brings between 35 and 80 % performance increase in HTB setup
under pressure on a bonding setup :

1) NUMA node contention :   610,000 pps -> 1,110,000 pps
2) No node contention   : 1,380,000 pps -> 1,930,000 pps

Now we should work to add batches on the enqueue() side ;)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Florian Westphal <fw@strlen.de>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/sch_generic.h |  7 ++---
 net/sched/sch_generic.c   | 68 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 62 insertions(+), 13 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 04e84c07c94f..909aff2db2b3 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -75,13 +75,14 @@ struct Qdisc {
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
-	struct Qdisc		*next_sched ____cacheline_aligned_in_smp;
-	struct sk_buff		*gso_skb;
-	unsigned long		state;
+	struct sk_buff		*gso_skb ____cacheline_aligned_in_smp;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
 	seqcount_t		running;
 	struct gnet_stats_queue	qstats;
+	unsigned long		state;
+	struct Qdisc            *next_sched;
+	struct sk_buff		*skb_bad_txq;
 	struct rcu_head		rcu_head;
 	int			padded;
 	atomic_t		refcnt;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ff86606954f2..e95b67cd5718 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -77,6 +77,34 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
 	skb->next = NULL;
 }
 
+/* This variant of try_bulk_dequeue_skb() makes sure
+ * all skbs in the chain are for the same txq
+ */
+static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
+				      struct sk_buff *skb,
+				      int *packets)
+{
+	int mapping = skb_get_queue_mapping(skb);
+	struct sk_buff *nskb;
+	int cnt = 0;
+
+	do {
+		nskb = q->dequeue(q);
+		if (!nskb)
+			break;
+		if (unlikely(skb_get_queue_mapping(nskb) != mapping)) {
+			q->skb_bad_txq = nskb;
+			qdisc_qstats_backlog_inc(q, nskb);
+			q->q.qlen++;
+			break;
+		}
+		skb->next = nskb;
+		skb = nskb;
+	} while (++cnt < 8);
+	(*packets) += cnt;
+	skb->next = NULL;
+}
+
 /* Note that dequeue_skb can possibly return a SKB list (via skb->next).
  * A requeued skb (via q->gso_skb) can also be a SKB list.
  */
@@ -87,8 +115,9 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 	const struct netdev_queue *txq = q->dev_queue;
 
 	*packets = 1;
-	*validate = true;
 	if (unlikely(skb)) {
+		/* skb in gso_skb were already validated */
+		*validate = false;
 		/* check the reason of requeuing without tx lock first */
 		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
@@ -97,15 +126,30 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 			q->q.qlen--;
 		} else
 			skb = NULL;
-		/* skb in gso_skb were already validated */
-		*validate = false;
-	} else {
-		if (!(q->flags & TCQ_F_ONETXQUEUE) ||
-		    !netif_xmit_frozen_or_stopped(txq)) {
-			skb = q->dequeue(q);
-			if (skb && qdisc_may_bulk(q))
-				try_bulk_dequeue_skb(q, skb, txq, packets);
+		return skb;
+	}
+	*validate = true;
+	skb = q->skb_bad_txq;
+	if (unlikely(skb)) {
+		/* check the reason of requeuing without tx lock first */
+		txq = skb_get_tx_queue(txq->dev, skb);
+		if (!netif_xmit_frozen_or_stopped(txq)) {
+			q->skb_bad_txq = NULL;
+			qdisc_qstats_backlog_dec(q, skb);
+			q->q.qlen--;
+			goto bulk;
 		}
+		return NULL;
+	}
+	if (!(q->flags & TCQ_F_ONETXQUEUE) ||
+	    !netif_xmit_frozen_or_stopped(txq))
+		skb = q->dequeue(q);
+	if (skb) {
+bulk:
+		if (qdisc_may_bulk(q))
+			try_bulk_dequeue_skb(q, skb, txq, packets);
+		else
+			try_bulk_dequeue_skb_slow(q, skb, packets);
 	}
 	return skb;
 }
@@ -624,11 +668,14 @@ void qdisc_reset(struct Qdisc *qdisc)
 	if (ops->reset)
 		ops->reset(qdisc);
 
+	kfree_skb(qdisc->skb_bad_txq);
+	qdisc->skb_bad_txq = NULL;
+
 	if (qdisc->gso_skb) {
 		kfree_skb_list(qdisc->gso_skb);
 		qdisc->gso_skb = NULL;
-		qdisc->q.qlen = 0;
 	}
+	qdisc->q.qlen = 0;
 }
 EXPORT_SYMBOL(qdisc_reset);
 
@@ -667,6 +714,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	dev_put(qdisc_dev(qdisc));
 
 	kfree_skb_list(qdisc->gso_skb);
+	kfree_skb(qdisc->skb_bad_txq);
 	/*
 	 * gen_estimator est_timer() might access qdisc->q.lock,
 	 * wait a RCU grace period before freeing qdisc.
-- 
2.8.0.rc3.226.g39d4020
