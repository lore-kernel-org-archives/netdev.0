From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] net_sched: increase drop count when packets are dropped
Date: Tue, 13 May 2014 17:42:43 +0800
Message-ID: <1399974163-8788-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <vtlam@google.com>,
	<nanditad@google.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:28139 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759744AbaEMJmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 05:42:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When packets are dropped because of overlimit, the drop count
should be increased. Replace kfree_skb() with qdisc_drop() for
increasing drop count.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_fq.c       | 2 +-
 net/sched/sch_fq_codel.c | 3 ++-
 net/sched/sch_hhf.c      | 3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

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
index 0bf432c782c1..bcfe4594470f 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = fq_codel_dequeue(sch);
 
-		kfree_skb(skb);
+		qdisc_drop(skb, sch);
+		q->drop_overlimit++;
 		q->cstats.drop_count++;
 	}
 	qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 6aab8619bbb0..71542d2cecac 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -593,7 +593,8 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = hhf_dequeue(sch);
 
-		kfree_skb(skb);
+		qdisc_drop(skb, sch);
+		q->drop_overlimit++;
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
-- 
1.8.0
