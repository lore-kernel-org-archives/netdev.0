From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v7 1/2] net: sched: tbf: fix the calculation of max_size
Date: Tue, 10 Dec 2013 14:59:27 +0800
Message-ID: <1386658768-29584-2-git-send-email-yangyingliang@huawei.com>
References: <1386658768-29584-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:39198 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595Ab3LJG7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 01:59:39 -0500
In-Reply-To: <1386658768-29584-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current max_size is caluated from rate table. Now, the rate table
has been replaced and it's wrong to caculate max_size based on this
rate table. It can lead wrong calculation of max_size.

The burst in kernel may be lower than user asked, because burst may gets
some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
and it seems we cannot avoid this loss. Burst's value(max_size) based on
rate table may be equal user asked. If a packet's length is max_size, this
packet will be stalled in tbf_dequeue() because its length is above the
burst in kernel so that it cannot get enough tokens. The max_size guards
against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().

To make consistent with the calculation of tokens, this patch add a helper
psched_ns_t2l() to calculate burst(max_size) directly to fix this problem.

After this fix, we can support to using 64bit rates to calculate burst as well.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_tbf.c | 115 ++++++++++++++++++++++++++++++++--------------------
 1 file changed, 70 insertions(+), 45 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a609005..a44928c 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -118,6 +118,30 @@ struct tbf_sched_data {
 };
 
 
+/* Time to Length, convert time in ns to length in bytes
+ * to determinate how many bytes can be sent in given time.
+ */
+static u64 psched_ns_t2l(const struct psched_ratecfg *r,
+			 u64 time_in_ns)
+{
+	/* The formula is :
+	 * len = (time_in_ns * r->rate_bytes_ps) / NSEC_PER_SEC
+	 */
+	u64 len = time_in_ns * r->rate_bytes_ps;
+
+	do_div(len, NSEC_PER_SEC);
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
 /*
  * Return length of individual segments of a gso packet,
  * including all headers (MAC, IP, TCP/UDP)
@@ -289,10 +313,11 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_TBF_MAX + 1];
 	struct tc_tbf_qopt *qopt;
-	struct qdisc_rate_table *rtab = NULL;
-	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
-	int max_size, n;
+	struct psched_ratecfg rate;
+	struct psched_ratecfg peak;
+	u64 max_size;
+	s64 buffer, mtu;
 	u64 rate64 = 0, prate64 = 0;
 
 	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
@@ -304,38 +329,13 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
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
-	}
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
-	}
-	if (max_size < 0)
-		goto done;
+	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE)
+		qdisc_put_rtab(qdisc_get_rtab(&qopt->rate,
+					      tb[TCA_TBF_RTAB]));
 
-	if (max_size < psched_mtu(qdisc_dev(sch)))
-		pr_warn_ratelimited("sch_tbf: burst %u is lower than device %s mtu (%u) !\n",
-				    max_size, qdisc_dev(sch)->name,
-				    psched_mtu(qdisc_dev(sch)));
+	if (qopt->peakrate.linklayer == TC_LINKLAYER_UNAWARE)
+			qdisc_put_rtab(qdisc_get_rtab(&qopt->peakrate,
+						      tb[TCA_TBF_PTAB]));
 
 	if (q->qdisc != &noop_qdisc) {
 		err = fifo_set_limit(q->qdisc, qopt->limit);
@@ -349,6 +349,39 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 		}
 	}
 
+	buffer = min_t(u64, PSCHED_TICKS2NS(qopt->buffer), ~0U);
+	mtu = min_t(u64, PSCHED_TICKS2NS(qopt->mtu), ~0U);
+
+	if (tb[TCA_TBF_RATE64])
+		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
+	psched_ratecfg_precompute(&rate, &qopt->rate, rate64);
+
+	max_size = min_t(u64, psched_ns_t2l(&rate, buffer), ~0U);
+
+	if (qopt->peakrate.rate) {
+		if (tb[TCA_TBF_PRATE64])
+			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
+		psched_ratecfg_precompute(&peak, &qopt->peakrate, prate64);
+		if (peak.rate_bytes_ps <= rate.rate_bytes_ps) {
+			pr_warn_ratelimited("sch_tbf: peakrate %llu is lower than or equals to rate %llu !\n",
+					    peak.rate_bytes_ps, rate.rate_bytes_ps);
+			err = -EINVAL;
+			goto done;
+		}
+
+		max_size = min_t(u64, max_size, psched_ns_t2l(&peak, mtu));
+	}
+
+	if (max_size < psched_mtu(qdisc_dev(sch)))
+		pr_warn_ratelimited("sch_tbf: burst %llu is lower than device %s mtu (%u) !\n",
+				    max_size, qdisc_dev(sch)->name,
+				    psched_mtu(qdisc_dev(sch)));
+
+	if (!max_size) {
+		err = -EINVAL;
+		goto done;
+	}
+
 	sch_tree_lock(sch);
 	if (child) {
 		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
@@ -362,13 +395,9 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
-	if (tb[TCA_TBF_RATE64])
-		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
-	psched_ratecfg_precompute(&q->rate, &rtab->rate, rate64);
-	if (ptab) {
-		if (tb[TCA_TBF_PRATE64])
-			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
-		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
+	memcpy(&q->rate, &rate, sizeof(struct psched_ratecfg));
+	if (qopt->peakrate.rate) {
+		memcpy(&q->peak, &peak, sizeof(struct psched_ratecfg));
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
@@ -377,10 +406,6 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	sch_tree_unlock(sch);
 	err = 0;
 done:
-	if (rtab)
-		qdisc_put_rtab(rtab);
-	if (ptab)
-		qdisc_put_rtab(ptab);
 	return err;
 }
 
-- 
1.8.0
