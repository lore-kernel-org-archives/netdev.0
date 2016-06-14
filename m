From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/10] net_sched: fq_codel: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:54 -0700
Message-ID: <1465874519-25494-6-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32920 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423239AbcFNDXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:23:30 -0400
Received: by mail-pa0-f46.google.com with SMTP id b13so29420034pat.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:23:29 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both fq_codel_change() and fq_codel_reset() can use rtnl_kfree_skbs()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq_codel.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index a302e8ef5498..2dc0a849515a 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -336,6 +336,12 @@ begin:
 	return skb;
 }
 
+static void fq_codel_flow_purge(struct fq_codel_flow *flow)
+{
+	rtnl_kfree_skbs(flow->head, flow->tail);
+	flow->head = NULL;
+}
+
 static void fq_codel_reset(struct Qdisc *sch)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
@@ -346,18 +352,13 @@ static void fq_codel_reset(struct Qdisc *sch)
 	for (i = 0; i < q->flows_cnt; i++) {
 		struct fq_codel_flow *flow = q->flows + i;
 
-		while (flow->head) {
-			struct sk_buff *skb = dequeue_head(flow);
-
-			qdisc_qstats_backlog_dec(sch, skb);
-			kfree_skb(skb);
-		}
-
+		fq_codel_flow_purge(flow);
 		INIT_LIST_HEAD(&flow->flowchain);
 		codel_vars_init(&flow->cvars);
 	}
 	memset(q->backlogs, 0, q->flows_cnt * sizeof(u32));
 	sch->q.qlen = 0;
+	sch->qstats.backlog = 0;
 	q->memory_usage = 0;
 }
 
@@ -433,7 +434,7 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
 		struct sk_buff *skb = fq_codel_dequeue(sch);
 
 		q->cstats.drop_len += qdisc_pkt_len(skb);
-		kfree_skb(skb);
+		rtnl_kfree_skbs(skb, skb);
 		q->cstats.drop_count++;
 	}
 	qdisc_tree_reduce_backlog(sch, q->cstats.drop_count, q->cstats.drop_len);
-- 
2.8.0.rc3.226.g39d4020
