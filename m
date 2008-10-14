From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 11/14] pkt_sched: Use qdisc_requeue() wrapper instead of
	open-coding.
Date: Tue, 14 Oct 2008 09:55:13 +0000
Message-ID: <20081014095513.GL10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168AbYJNJzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:55:18 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:55:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace __skb_queue_head() and __skb_queue_tail() to sch->requeue list
with qdisc_requeue(). This change adds btw. updates of sch->q.qlen and
other stats, and uses __skb_queue_head() everywhere, which is proper
replacement for qdisc->ops->requeue() previously used here.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_atm.c   |    2 +-
 net/sched/sch_hfsc.c  |    2 +-
 net/sched/sch_netem.c |    4 ++--
 net/sched/sch_tbf.c   |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 7a34e3e..7f9e884 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -482,7 +482,7 @@ static void sch_atm_dequeue(unsigned long data)
 		 */
 		while ((skb = qdisc_dequeue(flow->q))) {
 			if (!atm_may_send(flow->vcc, skb->truesize)) {
-				__skb_queue_tail(&flow->q->requeue, skb);
+				qdisc_requeue(flow->q, skb);
 				break;
 			}
 			pr_debug("atm_tc_dequeue: sending on class %p\n", flow);
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 5598e73..53153ba 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -896,7 +896,7 @@ qdisc_peek_len(struct Qdisc *sch)
 		return 0;
 	}
 	len = qdisc_pkt_len(skb);
-	__skb_queue_head(&sch->requeue, skb);
+	qdisc_requeue(sch, skb);
 	return len;
 }
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 17d161b..0fc86b7 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -233,7 +233,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 */
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
-		__skb_queue_tail(&q->qdisc->requeue, skb);
+		qdisc_requeue(q->qdisc, skb);
 		ret = NET_XMIT_SUCCESS;
 	}
 
@@ -282,7 +282,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			return skb;
 		}
 
-		__skb_queue_tail(&q->qdisc->requeue, skb);
+		qdisc_requeue(q->qdisc, skb);
 		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 	}
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 708e1eb..9f1a9ce 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -201,7 +201,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		   (cf. CSZ, HPFQ, HFSC)
 		 */
 
-		__skb_queue_tail(&q->qdisc->requeue, skb);
+		qdisc_requeue(q->qdisc, skb);
 		sch->qstats.overlimits++;
 	}
 	return NULL;
-- 
1.5.6.5

