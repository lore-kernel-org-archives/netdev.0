From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] sch_sfq: fix queue limiting while enqueuing
Date: Sun, 27 Apr 2008 16:22:16 +0200
Message-ID: <20080427142216.GB7480@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:44852 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754609AbYD0OY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 10:24:28 -0400
Received: by ug-out-1314.google.com with SMTP id z38so551983ugc.16
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 07:24:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NET_SCHED] sch_sfq: fix queue limiting while enqueuing

Current way to use q->limit both as per flow and total queue limit
doesn't make much sense. There would be no reason for sfq's limit
parameter if the same could be done with ifconfig's txqueuelen, and
it's too small for this anyway: with a number of flow queues around
maximum (SFQ_DEPTH) each queue would be ~1 packet long, which means
no queuing...

There is also changed a place for checking the total limit: let's do
it at the beginning (like in pfifo_fast_enqueue()). IMHO current way
is especially wrong during congestion: cpu & time costly classifying
and enqueuing is done under queue_lock, to end with dropping of
enqueued packets while adding newer ones. This means reordering and
usually more resending. (I think, similar changes should be done in
a few more qdiscs.)


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_sfq.c |   29 +++++++++++++----------------
 1 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index a20e2ef..b4fd592 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -283,6 +283,9 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	sfq_index x;
 	int ret;
 
+	if (unlikely(sch->q.qlen >= max_t(__u32, sch->dev->tx_queue_len, 1)))
+		return qdisc_drop(skb, sch);
+
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
 		if (ret == NET_XMIT_BYPASS)
@@ -319,14 +322,11 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			q->tail = x;
 		}
 	}
-	if (++sch->q.qlen <= q->limit) {
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
-		return 0;
-	}
 
-	sfq_drop(sch);
-	return NET_XMIT_CN;
+	sch->q.qlen++;
+	sch->bstats.bytes += skb->len;
+	sch->bstats.packets++;
+	return 0;
 }
 
 static int
@@ -337,6 +337,9 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	sfq_index x;
 	int ret;
 
+	if (unlikely(sch->q.qlen >= max_t(__u32, sch->dev->tx_queue_len, 1)))
+		return qdisc_drop(skb, sch);
+
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
 		if (ret == NET_XMIT_BYPASS)
@@ -381,14 +384,8 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	if (++sch->q.qlen <= q->limit) {
-		sch->qstats.requeues++;
-		return 0;
-	}
-
-	sch->qstats.drops++;
-	sfq_drop(sch);
-	return NET_XMIT_CN;
+	sch->qstats.requeues++;
+	return 0;
 }
 
 
@@ -467,7 +464,7 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
 
 	qlen = sch->q.qlen;
-	while (sch->q.qlen > q->limit)
+	while (q->max_depth > q->limit)
 		sfq_drop(sch);
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
