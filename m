From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH RFC] net_sched/codel: do not defer queue length update
Date: Mon, 21 Aug 2017 11:14:14 +0300
Message-ID: <150330325401.155105.30496752582836861.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1o.cmail.yandex.net ([37.9.109.47]:55701 "EHLO
        forwardcorp1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751750AbdHUIOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 04:14:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When codel wants to drop last packet in ->dequeue() it cannot call
qdisc_tree_reduce_backlog() right away - it will notify parent qdisc
about zero qlen and HTB/HFSC will deactivate class. The same class will
be deactivated second time by caller of ->dequeue(). Currently codel and
fq_codel defer update. This triggers warning in HFSC when it's qlen != 0
but there is no active classes.

This patch update parent queue length immediately: just temporary increase
qlen around qdisc_tree_reduce_backlog() to prevent first class deactivation
if we have skb to return.

This might open another problem in HFSC - now operation peek could fail and
deactivate parent class.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Link: https://bugzilla.kernel.org/show_bug.cgi?id=109581
---
 net/sched/sch_codel.c    |   14 ++++++++++----
 net/sched/sch_fq_codel.c |   24 +++++++++++++++---------
 2 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index c518a1efcb9d..e8194e455efe 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -95,11 +95,17 @@ static struct sk_buff *codel_qdisc_dequeue(struct Qdisc *sch)
 			    &q->stats, qdisc_pkt_len, codel_get_enqueue_time,
 			    drop_func, dequeue_func);
 
-	/* We cant call qdisc_tree_reduce_backlog() if our qlen is 0,
-	 * or HTB crashes. Defer it for next round.
+	/* If our qlen is 0 qdisc_tree_reduce_backlog() will deactivate
+	 * parent class, dequeue in parent qdisc will do the same if we
+	 * return skb. Temporary increment qlen if we have skb.
 	 */
-	if (q->stats.drop_count && sch->q.qlen) {
-		qdisc_tree_reduce_backlog(sch, q->stats.drop_count, q->stats.drop_len);
+	if (q->stats.drop_count) {
+		if (skb)
+			sch->q.qlen++;
+		qdisc_tree_reduce_backlog(sch, q->stats.drop_count,
+					  q->stats.drop_len);
+		if (skb)
+			sch->q.qlen--;
 		q->stats.drop_count = 0;
 		q->stats.drop_len = 0;
 	}
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 337f2d6d81e4..4048790a8c99 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -316,6 +316,21 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 	flow->dropped += q->cstats.drop_count - prev_drop_count;
 	flow->dropped += q->cstats.ecn_mark - prev_ecn_mark;
 
+	/* If our qlen is 0 qdisc_tree_reduce_backlog() will deactivate
+	 * parent class, dequeue in parent qdisc will do the same if we
+	 * return skb. Temporary increment qlen if we have skb.
+	 */
+	if (q->cstats.drop_count) {
+		if (skb)
+			sch->q.qlen++;
+		qdisc_tree_reduce_backlog(sch, q->cstats.drop_count,
+					  q->cstats.drop_len);
+		if (skb)
+			sch->q.qlen--;
+		q->cstats.drop_count = 0;
+		q->cstats.drop_len = 0;
+	}
+
 	if (!skb) {
 		/* force a pass through old_flows to prevent starvation */
 		if ((head == &q->new_flows) && !list_empty(&q->old_flows))
@@ -326,15 +341,6 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 	}
 	qdisc_bstats_update(sch, skb);
 	flow->deficit -= qdisc_pkt_len(skb);
-	/* We cant call qdisc_tree_reduce_backlog() if our qlen is 0,
-	 * or HTB crashes. Defer it for next round.
-	 */
-	if (q->cstats.drop_count && sch->q.qlen) {
-		qdisc_tree_reduce_backlog(sch, q->cstats.drop_count,
-					  q->cstats.drop_len);
-		q->cstats.drop_count = 0;
-		q->cstats.drop_len = 0;
-	}
 	return skb;
 }
 
