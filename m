From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v3 1/2] net: sched: tbf: fix calculation of max_size
Date: Tue, 19 Nov 2013 15:25:38 +0800
Message-ID: <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:11813 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823Ab3KSHZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 02:25:54 -0500
In-Reply-To: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>
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

Suggested-by: Jesper Dangaard Brouer <jbrouer@redhat.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_tbf.c | 71 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 37 insertions(+), 34 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 68f9859..c194129 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
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
@@ -339,30 +326,46 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
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
+	for (n = 0; n < 65536; n++)
+		if (psched_l2t_ns(&q->rate, n) > q->buffer)
+			break;
+	max_size = min_t(u32, n, (256ULL << qopt->rate.cell_log) - 1);
+
+	if (qopt->peakrate.rate) {
+		int size = 0;
 		if (tb[TCA_TBF_PRATE64])
 			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
-		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
+		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
+		for (n = 0; n < 65536; n++)
+			if (psched_l2t_ns(&q->peak, n) > q->mtu)
+				break;
+		size = min_t(u32, n, (256ULL << qopt->rate.cell_log) - 1);
+		max_size = min_t(u32, max_size, size);
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
 	}
 
+	if (!max_size)
+		goto unlock_done;
+	q->max_size = max_size;
+
 	sch_tree_unlock(sch);
-	err = 0;
+	return 0;
+
+unlock_done:
+	sch_tree_unlock(sch);
+	err = -EINVAL;
 done:
-	if (rtab)
-		qdisc_put_rtab(rtab);
-	if (ptab)
-		qdisc_put_rtab(ptab);
 	return err;
 }
 
-- 
1.8.0
