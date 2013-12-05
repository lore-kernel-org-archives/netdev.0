From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v5 1/2] net: sched: tbf: fix calculation of max_size
Date: Thu, 5 Dec 2013 15:10:56 +0800
Message-ID: <1386227457-86900-2-git-send-email-yangyingliang@huawei.com>
References: <1386227457-86900-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:9007 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab3LEHLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 02:11:11 -0500
In-Reply-To: <1386227457-86900-1-git-send-email-yangyingliang@huawei.com>
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

Suggested-by: Jesper Dangaard Brouer <jbrouer@redhat.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 include/net/sch_generic.h | 46 ++++++++++++++++++++++++++++
 net/sched/sch_tbf.c       | 76 ++++++++++++++++++++---------------------------
 2 files changed, 79 insertions(+), 43 deletions(-)

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
index a609005..2dd7cea 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -289,10 +289,8 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_TBF_MAX + 1];
 	struct tc_tbf_qopt *qopt;
-	struct qdisc_rate_table *rtab = NULL;
-	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
-	int max_size, n;
+	u64 max_size;
 	u64 rate64 = 0, prate64 = 0;
 
 	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
@@ -304,38 +302,13 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
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
@@ -357,30 +330,47 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
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
+	max_size = min_t(u64, psched_ns_t2l(&q->rate, q->buffer), ~0U); 
+
+	if (qopt->peakrate.rate) {
 		if (tb[TCA_TBF_PRATE64])
 			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
-		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
+		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
+		if (q->peak.rate_bytes_ps <= q->rate.rate_bytes_ps) {
+			pr_err("Peakrate must be higher than rate!\n");
+			goto unlock_done;
+		}
+
+		max_size = min_t(u64, max_size, psched_ns_t2l(&q->peak, q->mtu));
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
 	}
 
+	if (max_size < psched_mtu(qdisc_dev(sch)))
+		pr_warn_ratelimited("sch_tbf: burst %llu is lower than device %s mtu (%u) !\n",
+				    max_size, qdisc_dev(sch)->name,
+				    psched_mtu(qdisc_dev(sch)));
+
+	q->max_size = max_size;
+
+	sch_tree_unlock(sch);
+	return 0;
+
+unlock_done:
 	sch_tree_unlock(sch);
-	err = 0;
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
