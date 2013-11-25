From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH] net: sched: tbf: fix calculation of max_size
Date: Mon, 25 Nov 2013 20:04:23 +0800
Message-ID: <52933CC7.9070805@huawei.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>		 <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>	 <1385233579.10637.95.camel@edumazet-glaptop2.roam.corp.google.com>	 <5291AA8D.6060108@gmail.com> <1385318452.10637.116.camel@edumazet-glaptop2.roam.corp.google.com> <5292C76E.1070701@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3614 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744Ab3KYMEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 07:04:30 -0500
In-Reply-To: <5292C76E.1070701@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>

Current max_size is caluated from rate table. Now, the rate table
has been replaced and it's wrong to caculate max_size based on this
rate table. It can lead wrong calculation of max_size.

The burst in kernel may be lower than user asked, because burst may gets
some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
and it seems we cannot avoid this loss. And burst's value(max_size) based
on rate table may be equal user asked. If a packet's length is max_size,
this packet will be stalled in tbf_dequeue() because its length is above
the burst in kernel so that it cannot get enough tokens. The max_size guards
against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().

This patch fixes the calculation of max_size by using psched_l2t_ns() and
q->buffer to recalculate burst(max_size).

Also, add support to get burst from userland directly. We can avoid loss
in byte-to-time transform by using burst directly. Iproute2 will need a
patch to send burst to kernel.

Suggested-by: Jesper Dangaard Brouer <jbrouer@redhat.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 include/uapi/linux/pkt_sched.h |   2 +
 net/sched/sch_tbf.c            | 110 ++++++++++++++++++++++++++---------------
 2 files changed, 72 insertions(+), 40 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 307f293..b5a0976 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -173,6 +173,8 @@ enum {
 	TCA_TBF_PTAB,
 	TCA_TBF_RATE64,
 	TCA_TBF_PRATE64,
+	TCA_TBF_BURST,
+	TCA_TBF_PBURST,
 	__TCA_TBF_MAX,
 };
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a609005..3d01bf0 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -281,8 +281,12 @@ static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
 	[TCA_TBF_PTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 	[TCA_TBF_RATE64]	= { .type = NLA_U64 },
 	[TCA_TBF_PRATE64]	= { .type = NLA_U64 },
+	[TCA_TBF_BURST]		= { .type = NLA_U32 },
+	[TCA_TBF_PBURST]	= { .type = NLA_U32 },
 };
 
+#define MAX_PKT_LEN 65535
+
 static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	int err;
@@ -292,7 +296,7 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	struct qdisc_rate_table *rtab = NULL;
 	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
-	int max_size, n;
+	int max_size;
 	u64 rate64 = 0, prate64 = 0;
 
 	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
@@ -304,38 +308,20 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
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
-
-	if (max_size < psched_mtu(qdisc_dev(sch)))
-		pr_warn_ratelimited("sch_tbf: burst %u is lower than device %s mtu (%u) !\n",
-				    max_size, qdisc_dev(sch)->name,
-				    psched_mtu(qdisc_dev(sch)));
 
 	if (q->qdisc != &noop_qdisc) {
 		err = fifo_set_limit(q->qdisc, qopt->limit);
@@ -357,30 +343,74 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
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
+
+	if (tb[TCA_TBF_BURST]) {
+		u32 burst = nla_get_u32(tb[TCA_TBF_BURST]);
+		q->buffer = psched_l2t_ns(&q->rate, burst);
+		max_size = min_t(u32, burst, MAX_PKT_LEN);
+	} else {
+		for (max_size = 0; max_size < MAX_PKT_LEN; max_size++)
+			if (psched_l2t_ns(&q->rate, max_size) > q->buffer)
+				break;
+		max_size--;
+		if (max_size < 0)
+			goto unlock_done;
+	}
+
+	if (qopt->peakrate.rate) {
+		int size = 0;
 		if (tb[TCA_TBF_PRATE64])
 			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
-		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
+		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
+		if (q->peak.rate_bytes_ps <= q->rate.rate_bytes_ps) {
+			pr_err("Rate must be lower than peakrate!\n");
+			goto unlock_done;
+		}
+
+		if (tb[TCA_TBF_PBURST]) {
+			u32 pburst = nla_get_u32(tb[TCA_TBF_PBURST]);
+			q->mtu = psched_l2t_ns(&q->peak, pburst);
+			size = min_t(u32, pburst, MAX_PKT_LEN);
+		} else {
+			for (size = 0; size < MAX_PKT_LEN; size++)
+				if (psched_l2t_ns(&q->peak, size) > q->mtu)
+					break;
+			size--;
+			if (size < 0)
+				goto unlock_done;
+		}
+		max_size = min_t(u32, max_size, size);
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
 	}
 
+	if (!max_size)
+		goto unlock_done;
+
+	if (max_size < psched_mtu(qdisc_dev(sch)))
+		pr_warn_ratelimited("sch_tbf: burst %u is lower than device %s mtu (%u) !\n",
+				    max_size, qdisc_dev(sch)->name,
+				    psched_mtu(qdisc_dev(sch)));
+
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
 
-- 1.8.0
