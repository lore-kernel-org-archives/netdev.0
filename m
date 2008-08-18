From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/9]: pkt_sched: Replace all explitic ->dequeue() calls
 with qdisc_dequeue().
Date: Mon, 18 Aug 2008 01:36:58 -0700 (PDT)
Message-ID: <20080818.013658.112643192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33171
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751700AbYHRIg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:36:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pkt_sched: Replace all explitic ->dequeue() calls with qdisc_dequeue().

This spotted a bug in sch_dsmark, it was using qdisc->ops->dequeue()
instead of qdisc->dequeue().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_atm.c    |    4 ++--
 net/sched/sch_cbq.c    |    2 +-
 net/sched/sch_dsmark.c |    2 +-
 net/sched/sch_hfsc.c   |    4 ++--
 net/sched/sch_htb.c    |    2 +-
 net/sched/sch_netem.c  |    2 +-
 net/sched/sch_prio.c   |    2 +-
 net/sched/sch_red.c    |    2 +-
 net/sched/sch_tbf.c    |    2 +-
 9 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 43d3725..ca3467b 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -480,7 +480,7 @@ static void sch_atm_dequeue(unsigned long data)
 		 * If traffic is properly shaped, this won't generate nasty
 		 * little bursts. Otherwise, it may ... (but that's okay)
 		 */
-		while ((skb = flow->q->dequeue(flow->q))) {
+		while ((skb = qdisc_dequeue(flow->q))) {
 			if (!atm_may_send(flow->vcc, skb->truesize)) {
 				(void)flow->q->ops->requeue(skb, flow->q);
 				break;
@@ -516,7 +516,7 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 
 	pr_debug("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	tasklet_schedule(&p->task);
-	skb = p->link.q->dequeue(p->link.q);
+	skb = qdisc_dequeue(p->link.q);
 	if (skb)
 		sch->q.qlen--;
 	return skb;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 4e261ce..6d47aad 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -877,7 +877,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 				goto next_class;
 			}
 
-			skb = cl->q->dequeue(cl->q);
+			skb = qdisc_dequeue(cl->q);
 
 			/* Class did not give us any skb :-(
 			   It could occur even if cl->q->q.qlen != 0
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index edd1298..58a762a 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -279,7 +279,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 
 	pr_debug("dsmark_dequeue(sch %p,[qdisc %p])\n", sch, p);
 
-	skb = p->q->ops->dequeue(p->q);
+	skb = qdisc_dequeue(p->q);
 	if (skb == NULL)
 		return NULL;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c2b8d9c..ea46760 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -889,7 +889,7 @@ qdisc_peek_len(struct Qdisc *sch)
 	struct sk_buff *skb;
 	unsigned int len;
 
-	skb = sch->dequeue(sch);
+	skb = qdisc_dequeue(sch);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
@@ -1642,7 +1642,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		}
 	}
 
-	skb = cl->qdisc->dequeue(cl->qdisc);
+	skb = qdisc_dequeue(cl->qdisc);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("HFSC: Non-work-conserving qdisc ?\n");
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0df0df2..021149f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -840,7 +840,7 @@ next:
 			goto next;
 		}
 
-		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
+		skb = qdisc_dequeue(cl->un.leaf.q);
 		if (likely(skb != NULL))
 			break;
 		if (!cl->warned) {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index fb0294d..dbd567f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -283,7 +283,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	if (sch->flags & TCQ_F_THROTTLED)
 		return NULL;
 
-	skb = q->qdisc->dequeue(q->qdisc);
+	skb = qdisc_dequeue(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb = netem_skb_cb(skb);
 		psched_time_t now = psched_get_time();
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index a6697c6..5128625 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -128,7 +128,7 @@ static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 
 	for (prio = 0; prio < q->bands; prio++) {
 		struct Qdisc *qdisc = q->queues[prio];
-		struct sk_buff *skb = qdisc->dequeue(qdisc);
+		struct sk_buff *skb = qdisc_dequeue(qdisc);
 		if (skb) {
 			sch->q.qlen--;
 			return skb;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5da0583..3709720 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -131,7 +131,7 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
 
-	skb = child->dequeue(child);
+	skb = qdisc_dequeue(child);
 	if (skb)
 		sch->q.qlen--;
 	else if (!red_is_idling(&q->parms))
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 94c6159..a99529d 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -169,7 +169,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	skb = q->qdisc->dequeue(q->qdisc);
+	skb = qdisc_dequeue(q->qdisc);
 
 	if (skb) {
 		psched_time_t now;
-- 
1.5.6.5.GIT

