From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/10] net_sched: sch_fq: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:53 -0700
Message-ID: <1465874519-25494-5-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33140 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423239AbcFNDX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:23:27 -0400
Received: by mail-pf0-f180.google.com with SMTP id y124so52568557pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:23:27 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both fq_change() and fq_reset() can use rtnl_kfree_skbs()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index f49c81e91acd..6eb06674f778 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -514,17 +514,25 @@ out:
 	return skb;
 }
 
+static void fq_flow_purge(struct fq_flow *flow)
+{
+	rtnl_kfree_skbs(flow->head, flow->tail);
+	flow->head = NULL;
+	flow->qlen = 0;
+}
+
 static void fq_reset(struct Qdisc *sch)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
 	struct rb_root *root;
-	struct sk_buff *skb;
 	struct rb_node *p;
 	struct fq_flow *f;
 	unsigned int idx;
 
-	while ((skb = fq_dequeue_head(sch, &q->internal)) != NULL)
-		kfree_skb(skb);
+	sch->q.qlen = 0;
+	sch->qstats.backlog = 0;
+
+	fq_flow_purge(&q->internal);
 
 	if (!q->fq_root)
 		return;
@@ -535,8 +543,7 @@ static void fq_reset(struct Qdisc *sch)
 			f = container_of(p, struct fq_flow, fq_node);
 			rb_erase(p, root);
 
-			while ((skb = fq_dequeue_head(sch, f)) != NULL)
-				kfree_skb(skb);
+			fq_flow_purge(f);
 
 			kmem_cache_free(fq_flow_cachep, f);
 		}
@@ -737,7 +744,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 		if (!skb)
 			break;
 		drop_len += qdisc_pkt_len(skb);
-		kfree_skb(skb);
+		rtnl_kfree_skbs(skb, skb);
 		drop_count++;
 	}
 	qdisc_tree_reduce_backlog(sch, drop_count, drop_len);
-- 
2.8.0.rc3.226.g39d4020
