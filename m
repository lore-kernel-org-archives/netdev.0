From: gfree.wind@vip.163.com
Subject: [PATCH net-next RESEND] sched: sfq: drop packets after root qdisc lock is released
Date: Fri, 25 Aug 2017 15:43:17 +0800
Message-ID: <1503646997-94678-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m181-177.vip.163.com ([123.58.177.181]:42167 "EHLO
        m181-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754521AbdHYHrI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 03:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

The commit 520ac30f4551 ("net_sched: drop packets after root qdisc lock
is released) made a big change of tc for performance. But there are
some points which are not changed in SFQ enqueue operation.
1. Fail to find the SFQ hash slot;
2. When the queue is full;

Now use qdisc_drop instead free skb directly.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 net/sched/sch_sfq.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 82469ef..8841f4d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -292,7 +292,7 @@ static inline void slot_queue_add(struct sfq_slot *slot, struct sk_buff *skb)
 	slot->skblist_prev = skb;
 }
 
-static unsigned int sfq_drop(struct Qdisc *sch)
+static unsigned int sfq_drop(struct Qdisc *sch, struct sk_buff **to_free)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	sfq_index x, d = q->cur_depth;
@@ -310,9 +310,13 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		slot->backlog -= len;
 		sfq_dec(q, x);
 		sch->q.qlen--;
-		qdisc_qstats_drop(sch);
 		qdisc_qstats_backlog_dec(sch, skb);
-		kfree_skb(skb);
+		if (likely(to_free)) {
+			qdisc_drop(skb, sch, to_free);
+		} else {
+			qdisc_qstats_drop(sch);
+			kfree_skb(skb);
+		}
 		return len;
 	}
 
@@ -360,7 +364,7 @@ static int sfq_headdrop(const struct sfq_sched_data *q)
 	if (hash == 0) {
 		if (ret & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return ret;
 	}
 	hash--;
@@ -465,7 +469,7 @@ static int sfq_headdrop(const struct sfq_sched_data *q)
 		return NET_XMIT_SUCCESS;
 
 	qlen = slot->qlen;
-	dropped = sfq_drop(sch);
+	dropped = sfq_drop(sch, to_free);
 	/* Return Congestion Notification only if we dropped a packet
 	 * from this flow.
 	 */
@@ -675,7 +679,7 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > q->limit)
-		dropped += sfq_drop(sch);
+		dropped += sfq_drop(sch, NULL);
 	qdisc_tree_reduce_backlog(sch, qlen - sch->q.qlen, dropped);
 
 	del_timer(&q->perturb_timer);
-- 
1.9.1
