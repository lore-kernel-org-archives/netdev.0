From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 5/6 RESEND] pkt_sched: Use qdisc->ops->peek() instead of
	->dequeue() & ->requeue()
Date: Thu, 30 Oct 2008 13:06:21 +0000
Message-ID: <20081030130621.GF22853@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:42755 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbYJ3NG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 09:06:28 -0400
Received: by nf-out-0910.google.com with SMTP id d3so256454nfc.21
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 06:06:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use qdisc->ops->peek() instead of ->dequeue() & ->requeue() pair.
After this patch the only remaining user of qdisc->ops->requeue() is
netem_enqueue(). Based on ideas of Herbert Xu, Patrick McHardy and
David S. Miller.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_atm.c   |   11 +++++++----
 net/sched/sch_hfsc.c  |   12 ++----------
 net/sched/sch_netem.c |   13 +++++--------
 net/sched/sch_tbf.c   |   12 +++++-------
 4 files changed, 19 insertions(+), 29 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index f9eac08..2ee0c1a 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -480,11 +480,14 @@ static void sch_atm_dequeue(unsigned long data)
 		 * If traffic is properly shaped, this won't generate nasty
 		 * little bursts. Otherwise, it may ... (but that's okay)
 		 */
-		while ((skb = flow->q->dequeue(flow->q))) {
-			if (!atm_may_send(flow->vcc, skb->truesize)) {
-				(void)flow->q->ops->requeue(skb, flow->q);
+		while ((skb = flow->q->ops->peek(flow->q))) {
+			if (!atm_may_send(flow->vcc, skb->truesize))
 				break;
-			}
+
+			skb = flow->q->dequeue(flow->q);
+			if (unlikely(!skb))
+				break;
+
 			pr_debug("atm_tc_dequeue: sending on class %p\n", flow);
 			/* remove any LL header somebody else has attached */
 			skb_pull(skb, skb_network_offset(skb));
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c1e77da..ddfc408 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -880,28 +880,20 @@ set_passive(struct hfsc_class *cl)
 	 */
 }
 
-/*
- * hack to get length of first packet in queue.
- */
 static unsigned int
 qdisc_peek_len(struct Qdisc *sch)
 {
 	struct sk_buff *skb;
 	unsigned int len;
 
-	skb = sch->dequeue(sch);
+	skb = sch->ops->peek(sch);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
 		return 0;
 	}
 	len = qdisc_pkt_len(skb);
-	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
-		if (net_ratelimit())
-			printk("qdisc_peek_len: failed to requeue\n");
-		qdisc_tree_decrease_qlen(sch, 1);
-		return 0;
-	}
+
 	return len;
 }
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2898d9d..74fbdb5 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -283,25 +283,22 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	if (sch->flags & TCQ_F_THROTTLED)
 		return NULL;
 
-	skb = q->qdisc->dequeue(q->qdisc);
+	skb = q->qdisc->ops->peek(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb = netem_skb_cb(skb);
 		psched_time_t now = psched_get_time();
 
 		/* if more time remaining? */
 		if (cb->time_to_send <= now) {
+			skb = q->qdisc->dequeue(q->qdisc);
+			if (!skb)
+				return NULL;
+
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
 			return skb;
 		}
 
-		if (unlikely(q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
-			qdisc_tree_decrease_qlen(q->qdisc, 1);
-			sch->qstats.drops++;
-			printk(KERN_ERR "netem: %s could not requeue\n",
-			       q->qdisc->ops->id);
-		}
-
 		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 	}
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 94c6159..61fdc77 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -169,7 +169,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	skb = q->qdisc->dequeue(q->qdisc);
+	skb = q->qdisc->ops->peek(q->qdisc);
 
 	if (skb) {
 		psched_time_t now;
@@ -192,6 +192,10 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		toks -= L2T(q, len);
 
 		if ((toks|ptoks) >= 0) {
+			skb = q->qdisc->dequeue(q->qdisc);
+			if (unlikely(!skb))
+				return NULL;
+
 			q->t_c = now;
 			q->tokens = toks;
 			q->ptokens = ptoks;
@@ -214,12 +218,6 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		   (cf. CSZ, HPFQ, HFSC)
 		 */
 
-		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
-			/* When requeue fails skb is dropped */
-			qdisc_tree_decrease_qlen(q->qdisc, 1);
-			sch->qstats.drops++;
-		}
-
 		sch->qstats.overlimits++;
 	}
 	return NULL;
-- 
1.5.6.5

