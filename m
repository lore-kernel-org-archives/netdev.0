From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/3] sch_fq: add skb_is_too_big() helper
Date: Tue, 25 Nov 2014 21:24:50 +0800
Message-ID: <1416921892-4756-2-git-send-email-yangyingliang@huawei.com>
References: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:54740 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbaKYNZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 08:25:10 -0500
In-Reply-To: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_is_too_big() helper to get the cost time of sending packets
and check if it is more than 125ms.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_fq.c | 57 +++++++++++++++++++++++++++++++++---------------------
 1 file changed, 35 insertions(+), 22 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index cbd7e1f..36a22e0 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -304,6 +304,37 @@ static bool skb_is_retransmit(struct sk_buff *skb)
 	return false;
 }
 
+static bool skb_is_too_big(struct sk_buff *skb, struct fq_sched_data *q, u64 *cost_time)
+{
+	u32 rate = q->flow_max_rate;
+
+	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT)
+		rate = min(skb->sk->sk_pacing_rate, q->flow_max_rate);
+
+	if (cost_time)
+		*cost_time = 0;
+
+	if (rate != ~0U) {
+		u32 plen = max(qdisc_pkt_len(skb), q->quantum);
+		u64 len = (u64)plen * NSEC_PER_SEC;
+
+		if (likely(rate))
+			do_div(len, rate);
+		if (cost_time)
+			*cost_time = len;
+		/* Since socket rate can change later,
+		 * clamp the delay to 125 ms.
+		 */
+		if (unlikely(len > 125 * NSEC_PER_MSEC)) {
+			if (cost_time)
+				*cost_time = 125 * NSEC_PER_MSEC;
+			return true;
+		}
+	}
+
+	return false;
+}
+
 /* add skb to flow queue
  * flow queue is a linked list, kind of FIFO, except for TCP retransmits
  * We special case tcp retransmits to be transmitted before other packets.
@@ -418,7 +449,7 @@ static struct sk_buff *fq_dequeue(struct Qdisc *sch)
 	struct fq_flow_head *head;
 	struct sk_buff *skb;
 	struct fq_flow *f;
-	u32 rate;
+	u64 cost_time;
 
 	skb = fq_dequeue_head(sch, &q->internal);
 	if (skb)
@@ -470,28 +501,10 @@ begin:
 	if (f->credit > 0 || !q->rate_enable)
 		goto out;
 
-	rate = q->flow_max_rate;
-	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT)
-		rate = min(skb->sk->sk_pacing_rate, rate);
+	if (skb_is_too_big(skb, q, &cost_time))
+		q->stat_pkts_too_long++;
+	f->time_next_packet = now + cost_time;
 
-	if (rate != ~0U) {
-		u32 plen = max(qdisc_pkt_len(skb), q->quantum);
-		u64 len = (u64)plen * NSEC_PER_SEC;
-
-		if (likely(rate))
-			do_div(len, rate);
-		/* Since socket rate can change later,
-		 * clamp the delay to 125 ms.
-		 * TODO: maybe segment the too big skb, as in commit
-		 * e43ac79a4bc ("sch_tbf: segment too big GSO packets")
-		 */
-		if (unlikely(len > 125 * NSEC_PER_MSEC)) {
-			len = 125 * NSEC_PER_MSEC;
-			q->stat_pkts_too_long++;
-		}
-
-		f->time_next_packet = now + len;
-	}
 out:
 	qdisc_bstats_update(sch, skb);
 	return skb;
-- 
1.8.0
