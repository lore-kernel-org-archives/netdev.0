From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: keep backlog updated with qlen
Date: Fri,  3 Jun 2016 15:05:57 -0700
Message-ID: <1464991557-5135-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stasn77@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35882 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932641AbcFCWGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 18:06:08 -0400
Received: by mail-pf0-f194.google.com with SMTP id 62so12432009pfd.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 15:06:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For gso_skb we only update qlen, backlog should be updated too.

Note, it is correct to just update these stats at one layer,
because the gso_skb is cached there.

Reported-by: Stas Nichiporovich <stasn77@gmail.com>
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h | 5 ++++-
 net/sched/sch_generic.c   | 2 ++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a1fd76c..6803af1 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -691,9 +691,11 @@ static inline struct sk_buff *qdisc_peek_dequeued(struct Qdisc *sch)
 	/* we can reuse ->gso_skb because peek isn't called for root qdiscs */
 	if (!sch->gso_skb) {
 		sch->gso_skb = sch->dequeue(sch);
-		if (sch->gso_skb)
+		if (sch->gso_skb) {
 			/* it's still part of the queue */
+			qdisc_qstats_backlog_inc(sch, sch->gso_skb);
 			sch->q.qlen++;
+		}
 	}
 
 	return sch->gso_skb;
@@ -706,6 +708,7 @@ static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 
 	if (skb) {
 		sch->gso_skb = NULL;
+		qdisc_qstats_backlog_dec(sch, skb);
 		sch->q.qlen--;
 	} else {
 		skb = sch->dequeue(sch);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 269dd71..f9e0e9c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -49,6 +49,7 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	q->gso_skb = skb;
 	q->qstats.requeues++;
+	qdisc_qstats_backlog_inc(q, skb);
 	q->q.qlen++;	/* it's still part of the queue */
 	__netif_schedule(q);
 
@@ -92,6 +93,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
 			q->gso_skb = NULL;
+			qdisc_qstats_backlog_dec(q, skb);
 			q->q.qlen--;
 		} else
 			skb = NULL;
-- 
2.1.0
