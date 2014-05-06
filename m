From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] net_sched: increase drops and decrease backlog when packets are dropped
Date: Tue, 6 May 2014 17:37:36 +0800
Message-ID: <1399369056-1632-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <vtlam@google.com>,
	<nanditad@google.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:29111 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934526AbaEFJij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 05:38:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When packets are dropped, backlog and drops statistic of qdisc
need be changed. Replace kfree_skb() with qdisc_drop() for
increasing drops.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_fq.c       | 2 +-
 net/sched/sch_fq_codel.c | 3 ++-
 net/sched/sch_hhf.c      | 2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 23c682b42f99..958ef7d4b825 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -714,7 +714,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 
 		if (!skb)
 			break;
-		kfree_skb(skb);
+		qdisc_drop(skb, sch);
 		drop_count++;
 	}
 	qdisc_tree_decrease_qlen(sch, drop_count);
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 0bf432c782c1..83abd4cd10cd 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = fq_codel_dequeue(sch);
 
-		kfree_skb(skb);
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		qdisc_drop(skb, sch);
 		q->cstats.drop_count++;
 	}
 	qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index edee03d922e2..a9051d0fff52 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -592,7 +592,7 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = hhf_dequeue(sch);
 
-		kfree_skb(skb);
+		qdisc_drop(skb, sch);
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
-- 
1.8.0
