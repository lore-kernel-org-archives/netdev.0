From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 2/3] sch_fq: add __fq_enqueue() helper
Date: Tue, 25 Nov 2014 21:24:51 +0800
Message-ID: <1416921892-4756-3-git-send-email-yangyingliang@huawei.com>
References: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3227 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbaKYNZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 08:25:28 -0500
In-Reply-To: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the original enqueue code to __fq_enqueue() helper.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_fq.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 36a22e0..ec6eff8 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -384,21 +384,9 @@ static void flow_queue_add(struct fq_flow *flow, struct sk_buff *skb)
 		prev->next = skb;
 	}
 }
-
-static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int __fq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct fq_flow *f)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
-	struct fq_flow *f;
-
-	if (unlikely(sch->q.qlen >= sch->limit))
-		return qdisc_drop(skb, sch);
-
-	f = fq_classify(skb, q);
-	if (unlikely(f->qlen >= q->flow_plimit && f != &q->internal)) {
-		q->stat_flows_plimit++;
-		return qdisc_drop(skb, sch);
-	}
-
 	f->qlen++;
 	if (skb_is_retransmit(skb))
 		q->stat_tcp_retrans++;
@@ -421,6 +409,23 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
+static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct fq_sched_data *q = qdisc_priv(sch);
+	struct fq_flow *f;
+
+	if (unlikely(sch->q.qlen >= sch->limit))
+		return qdisc_drop(skb, sch);
+
+	f = fq_classify(skb, q);
+	if (unlikely(f->qlen >= q->flow_plimit && f != &q->internal)) {
+		q->stat_flows_plimit++;
+		return qdisc_drop(skb, sch);
+	}
+
+	return __fq_enqueue(skb, sch, f);
+}
+
 static void fq_check_throttled(struct fq_sched_data *q, u64 now)
 {
 	struct rb_node *p;
-- 
1.8.0
