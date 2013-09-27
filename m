From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: qdisc dismantle fixes
Date: Fri, 27 Sep 2013 14:20:01 -0700
Message-ID: <1380316801.30872.37.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:49516 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab3I0VUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:20:03 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so3077369pde.23
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 14:20:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

fq_reset() should drops all packets in queue, including
throttled flows.

This patch moves code from fq_destroy() to fq_reset()
to do the cleaning.

fq_change() must stop calling fq_dequeue() if all remaining
packets are from throttled flows.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c |   57 +++++++++++++++++++++++++++----------------
 1 file changed, 37 insertions(+), 20 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 32ad015..fc6de56 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -285,7 +285,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 
 
 /* remove one skb from head of flow queue */
-static struct sk_buff *fq_dequeue_head(struct fq_flow *flow)
+static struct sk_buff *fq_dequeue_head(struct Qdisc *sch, struct fq_flow *flow)
 {
 	struct sk_buff *skb = flow->head;
 
@@ -293,6 +293,8 @@ static struct sk_buff *fq_dequeue_head(struct fq_flow *flow)
 		flow->head = skb->next;
 		skb->next = NULL;
 		flow->qlen--;
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->q.qlen--;
 	}
 	return skb;
 }
@@ -419,7 +421,7 @@ static struct sk_buff *fq_dequeue(struct Qdisc *sch)
 	struct sk_buff *skb;
 	struct fq_flow *f;
 
-	skb = fq_dequeue_head(&q->internal);
+	skb = fq_dequeue_head(sch, &q->internal);
 	if (skb)
 		goto out;
 	fq_check_throttled(q, now);
@@ -449,7 +451,7 @@ begin:
 		goto begin;
 	}
 
-	skb = fq_dequeue_head(f);
+	skb = fq_dequeue_head(sch, f);
 	if (!skb) {
 		head->first = f->next;
 		/* force a pass through old_flows to prevent starvation */
@@ -490,19 +492,44 @@ begin:
 		}
 	}
 out:
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
 	qdisc_bstats_update(sch, skb);
-	sch->q.qlen--;
 	qdisc_unthrottled(sch);
 	return skb;
 }
 
 static void fq_reset(struct Qdisc *sch)
 {
+	struct fq_sched_data *q = qdisc_priv(sch);
+	struct rb_root *root;
 	struct sk_buff *skb;
+	struct rb_node *p;
+	struct fq_flow *f;
+	unsigned int idx;
 
-	while ((skb = fq_dequeue(sch)) != NULL)
+	while ((skb = fq_dequeue_head(sch, &q->internal)) != NULL)
 		kfree_skb(skb);
+
+	if (!q->fq_root)
+		return;
+
+	for (idx = 0; idx < (1U << q->fq_trees_log); idx++) {
+		root = &q->fq_root[idx];
+		while ((p = rb_first(root)) != NULL) {
+			f = container_of(p, struct fq_flow, fq_node);
+			rb_erase(p, root);
+
+			while ((skb = fq_dequeue_head(sch, f)) != NULL)
+				kfree_skb(skb);
+
+			kmem_cache_free(fq_flow_cachep, f);
+		}
+	}
+	q->new_flows.first	= NULL;
+	q->old_flows.first	= NULL;
+	q->delayed		= RB_ROOT;
+	q->flows		= 0;
+	q->inactive_flows	= 0;
+	q->throttled_flows	= 0;
 }
 
 static void fq_rehash(struct fq_sched_data *q,
@@ -645,6 +672,8 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = fq_dequeue(sch);
 
+		if (!skb)
+			break;
 		kfree_skb(skb);
 		drop_count++;
 	}
@@ -657,21 +686,9 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 static void fq_destroy(struct Qdisc *sch)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
-	struct rb_root *root;
-	struct rb_node *p;
-	unsigned int idx;
 
-	if (q->fq_root) {
-		for (idx = 0; idx < (1U << q->fq_trees_log); idx++) {
-			root = &q->fq_root[idx];
-			while ((p = rb_first(root)) != NULL) {
-				rb_erase(p, root);
-				kmem_cache_free(fq_flow_cachep,
-						container_of(p, struct fq_flow, fq_node));
-			}
-		}
-		kfree(q->fq_root);
-	}
+	fq_reset(sch);
+	kfree(q->fq_root);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
