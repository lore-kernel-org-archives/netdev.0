From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v2 1/2] net: sched: tbf: fix calculation of max_size
Date: Mon, 18 Nov 2013 16:39:23 +0800
Message-ID: <1384763964-5000-2-git-send-email-yangyingliang@huawei.com>
References: <1384763964-5000-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:65232 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab3KRIjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 03:39:35 -0500
In-Reply-To: <1384763964-5000-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b757c9336d63f94c6b57532(tbf: improved accuracy at high rates)
introduce a regression.

With the follow command:
tc qdisc add dev eth1 root handle 1: tbf latency 50ms burst 10KB rate 30gbit mtu 64k

Without this patch, the max_size value is 10751(bytes).
But, in fact, the real max_size value should be smaller than 7440(bytes).
Or a packet whose length is bigger than 7440 will cause network congestion.
Because the packet is so big that can't get enough tokens. Even all the tokens
in the buffer is given to the packet.

With this patch, the max_size value is 7440(bytes).
The packets whose length is bigger than 7440(bytes) will be dropped or reshape
in tbf_enqueue().

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 include/net/sch_generic.h | 46 ++++++++++++++++++++++++++++++++
 net/sched/sch_tbf.c       | 67 ++++++++++++++++++++++++++---------------------
 2 files changed, 83 insertions(+), 30 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index d0a6321..8da64f3 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -701,6 +701,52 @@ static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
 	return ((u64)len * r->mult) >> r->shift;
 }
 
+/* Time to Length, convert time in ns to length in bytes
+ * to determinate how many bytes can be sent in given time.
+ */
+static inline u64 psched_ns_t2l(const struct psched_ratecfg *r,
+				u64 time_in_ns)
+{
+	u64 len = time_in_ns;
+	u8 shift = r->shift;
+	bool is_div = false;
+
+	/* The formula is :
+	 * len = (time_in_ns << shift) / mult
+	 * when time_in_ns does shift, it would overflow.
+	 * If overflow happens first time, do division.
+	 * Then do shift. If it happens again,
+	 * set lenth to ~0ULL.
+	 */
+	while (shift) {
+		if (len & (1ULL << 63)) {
+			if (!is_div) {
+				len = div64_u64(len, r->mult);
+				is_div = true;
+			} else {
+				/* overflow happens */
+				len = ~0ULL;
+				is_div = true;
+				break;
+			}
+		}
+		len <<= 1;
+		shift--;
+	}
+	if (!is_div)
+		len = div64_u64(len, r->mult);
+
+	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
+		len = (len / 53) * 48;
+
+	if (len > r->overhead)
+		len -= r->overhead;
+	else
+		len = 0;
+
+	return len;
+}
+
 void psched_ratecfg_precompute(struct psched_ratecfg *r,
 			       const struct tc_ratespec *conf,
 			       u64 rate64);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 68f9859..eb9ce7b 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -279,7 +279,7 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	struct qdisc_rate_table *rtab = NULL;
 	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
-	int max_size, n;
+	u32 max_size = 0;
 	u64 rate64 = 0, prate64 = 0;
 
 	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
@@ -291,33 +291,20 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 		goto done;
 
 	qopt = nla_data(tb[TCA_TBF_PARMS]);
-	rtab = qdisc_get_rtab(&qopt->rate, tb[TCA_TBF_RTAB]);
-	if (rtab == NULL)
-		goto done;
-
-	if (qopt->peakrate.rate) {
-		if (qopt->peakrate.rate > qopt->rate.rate)
-			ptab = qdisc_get_rtab(&qopt->peakrate, tb[TCA_TBF_PTAB]);
-		if (ptab == NULL)
-			goto done;
+	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE) {
+		rtab = qdisc_get_rtab(&qopt->rate, tb[TCA_TBF_RTAB]);
+		if (rtab) {
+			qdisc_put_rtab(rtab);
+			rtab = NULL;
+		}
 	}
-
-	for (n = 0; n < 256; n++)
-		if (rtab->data[n] > qopt->buffer)
-			break;
-	max_size = (n << qopt->rate.cell_log) - 1;
-	if (ptab) {
-		int size;
-
-		for (n = 0; n < 256; n++)
-			if (ptab->data[n] > qopt->mtu)
-				break;
-		size = (n << qopt->peakrate.cell_log) - 1;
-		if (size < max_size)
-			max_size = size;
+	if (qopt->peakrate.linklayer == TC_LINKLAYER_UNAWARE) {
+		ptab = qdisc_get_rtab(&qopt->peakrate, tb[TCA_TBF_PTAB]);
+		if (ptab) {
+			qdisc_put_rtab(ptab);
+			ptab = NULL;
+		}
 	}
-	if (max_size < 0)
-		goto done;
 
 	if (q->qdisc != &noop_qdisc) {
 		err = fifo_set_limit(q->qdisc, qopt->limit);
@@ -339,25 +326,45 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	}
 	q->limit = qopt->limit;
 	q->mtu = PSCHED_TICKS2NS(qopt->mtu);
-	q->max_size = max_size;
 	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
 	if (tb[TCA_TBF_RATE64])
 		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
-	psched_ratecfg_precompute(&q->rate, &rtab->rate, rate64);
-	if (ptab) {
+	psched_ratecfg_precompute(&q->rate, &qopt->rate, rate64);
+	if (!q->rate.rate_bytes_ps)
+		goto unlock_done;
+	max_size = min_t(u64, psched_ns_t2l(&q->rate, q->buffer), ~0);
+	max_size = min_t(u32, max_size, (256 << qopt->rate.cell_log) - 1);
+
+	if (qopt->peakrate.rate) {
+		u64 size = 0;
 		if (tb[TCA_TBF_PRATE64])
 			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
-		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
+		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
+		size = psched_ns_t2l(&q->peak, q->mtu);
+		max_size = min_t(u64, max_size, size);
+		max_size = min_t(u32,
+				 max_size,
+				 (256 << qopt->peakrate.cell_log) - 1);
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
 	}
 
+	if (!max_size)
+		goto unlock_done;
+	q->max_size = max_size;
+
 	sch_tree_unlock(sch);
 	err = 0;
+
+	if (0) {
+unlock_done:
+		sch_tree_unlock(sch);
+		err = -EINVAL;
+	}
 done:
 	if (rtab)
 		qdisc_put_rtab(rtab);
-- 
1.8.0
