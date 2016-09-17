From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/5] sched: don't use skb queue helpers
Date: Sun, 18 Sep 2016 00:57:31 +0200
Message-ID: <1474153054-9059-3-git-send-email-fw@strlen.de>
References: <1474153054-9059-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51386 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755014AbcIQW5c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:57:32 -0400
In-Reply-To: <1474153054-9059-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A followup change will replace the sk_buff_head in the qdisc
struct with a slightly different list.

Use of the sk_buff_head helpers will thus cause compiler
warnings.

Open-code these accesses in an extra change to ease review.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_fifo.c    | 4 ++--
 net/sched/sch_generic.c | 2 +-
 net/sched/sch_netem.c   | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index baeed6a..1e37247 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -31,7 +31,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 			 struct sk_buff **to_free)
 {
-	if (likely(skb_queue_len(&sch->q) < sch->limit))
+	if (likely(sch->q.qlen < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	return qdisc_drop(skb, sch, to_free);
@@ -42,7 +42,7 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 {
 	unsigned int prev_backlog;
 
-	if (likely(skb_queue_len(&sch->q) < sch->limit))
+	if (likely(sch->q.qlen < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	prev_backlog = sch->qstats.backlog;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0d21b56..5e63bf6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -486,7 +486,7 @@ static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
 static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
 			      struct sk_buff **to_free)
 {
-	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
+	if (qdisc->q.qlen < qdisc_dev(qdisc)->tx_queue_len) {
 		int band = prio2band[skb->priority & TC_PRIO_MAX];
 		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 		struct sk_buff_head *list = band2list(priv, band);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index aaaf021..1832d77 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -502,7 +502,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 			1<<(prandom_u32() % 8);
 	}
 
-	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
+	if (unlikely(sch->q.qlen >= sch->limit))
 		return qdisc_drop(skb, sch, to_free);
 
 	qdisc_qstats_backlog_inc(sch, skb);
@@ -522,7 +522,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		if (q->rate) {
 			struct sk_buff *last;
 
-			if (!skb_queue_empty(&sch->q))
+			if (sch->q.qlen)
 				last = skb_peek_tail(&sch->q);
 			else
 				last = netem_rb_to_skb(rb_last(&q->t_root));
-- 
2.7.3
