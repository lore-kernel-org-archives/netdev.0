From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 09/14] pkt_sched: Kill qdisc->ops->requeue() in sch_atm and
	sch_multiq.
Date: Tue, 14 Oct 2008 09:54:52 +0000
Message-ID: <20081014095452.GJ10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450AbYJNJy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:54:57 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:54:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is only used by the qdisc->ops->requeue implementations themselves.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_atm.c    |   18 ------------------
 net/sched/sch_multiq.c |   36 +-----------------------------------
 2 files changed, 1 insertions(+), 53 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index c8bc5fc..7a34e3e 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -522,23 +522,6 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
-static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct atm_qdisc_data *p = qdisc_priv(sch);
-	int ret;
-
-	pr_debug("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
-	ret = p->link.q->ops->requeue(skb, p->link.q);
-	if (!ret) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-	} else if (net_xmit_drop_count(ret)) {
-		sch->qstats.drops++;
-		p->link.qstats.drops++;
-	}
-	return ret;
-}
-
 static unsigned int atm_tc_drop(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
@@ -694,7 +677,6 @@ static struct Qdisc_ops atm_qdisc_ops __read_mostly = {
 	.priv_size	= sizeof(struct atm_qdisc_data),
 	.enqueue	= atm_tc_enqueue,
 	.dequeue	= atm_tc_dequeue,
-	.requeue	= atm_tc_requeue,
 	.drop		= atm_tc_drop,
 	.init		= atm_tc_init,
 	.reset		= atm_tc_reset,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index df1857a..cf34f67 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -93,39 +93,6 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 }
 
 
-static int
-multiq_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct Qdisc *qdisc;
-	struct multiq_sched_data *q = qdisc_priv(sch);
-	int ret;
-
-	qdisc = multiq_classify(skb, sch, &ret);
-#ifdef CONFIG_NET_CLS_ACT
-	if (qdisc == NULL) {
-		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
-	}
-#endif
-
-	ret = qdisc->ops->requeue(skb, qdisc);
-	if (ret == NET_XMIT_SUCCESS) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-		if (q->curband)
-			q->curband--;
-		else
-			q->curband = q->bands - 1;
-		return NET_XMIT_SUCCESS;
-	}
-	if (net_xmit_drop_count(ret))
-		sch->qstats.drops++;
-	return ret;
-}
-
-
 static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
@@ -140,7 +107,7 @@ static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 			q->curband = 0;
 
 		/* Check that target subqueue is available before
-		 * pulling an skb to avoid excessive requeues
+		 * pulling an skb to avoid head-of-line blocking.
 		 */
 		if (!__netif_subqueue_stopped(qdisc_dev(sch), q->curband)) {
 			qdisc = q->queues[q->curband];
@@ -451,7 +418,6 @@ static struct Qdisc_ops multiq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct multiq_sched_data),
 	.enqueue	=	multiq_enqueue,
 	.dequeue	=	multiq_dequeue,
-	.requeue	=	multiq_requeue,
 	.drop		=	multiq_drop,
 	.init		=	multiq_init,
 	.reset		=	multiq_reset,
-- 
1.5.6.5

