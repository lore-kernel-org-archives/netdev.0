From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH RFC ] net: sched: tbf: fix the calculation of max_size
Date: Mon, 9 Dec 2013 21:10:05 +0800
Message-ID: <52A5C12D.8080008@huawei.com>
References: <1386313205-87660-1-git-send-email-yangyingliang@huawei.com> <1386313205-87660-2-git-send-email-yangyingliang@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com> <52A5384A.8050106@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7471@saturn3.aculab.com> <52A5B5D9.7000204@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:42416 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932627Ab3LINKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 08:10:15 -0500
In-Reply-To: <52A5B5D9.7000204@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>

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
 net/sched/sch_tbf.c | 203 +++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 155 insertions(+), 48 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a609005..b692d02 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -117,6 +117,115 @@ struct tbf_sched_data {
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
+/* do (u64 + u64) with checking if overflows */
+static u64 do_plus64(u64 a, u64 b)
+{
+
+	short shift = 0;
+
+	if (a == ULLONG_MAX || b == ULLONG_MAX)
+		return ULLONG_MAX;
+
+	while (shift <= 63) {
+		u64 _a = a << shift;
+		u64 _b = b << shift;
+		if (_a & _b & (1ULL << 63)) {
+			/* overflow happens */
+			return ULLONG_MAX;
+		} else if (!((_a | _b) & (1ULL << 63))) {
+			/* won't overflow*/
+			return a + b;
+		}
+		shift++;
+	}
+
+	return a + b;
+}
+
+
+/* Time to Length, convert time in ns to length in bytes
+ * to determinate how many bytes can be sent in given time.
+ */
+static u64 psched_ns_t2l(const struct psched_ratecfg *r,
+			 u64 time_in_ns)
+{
+	/* The original formula is :
+	 * len = (time_in_ns * rate_bytes_ps) / NSEC_PER_SEC =>
+	 *
+	 * len = time_in_ns * (rate_bytes_ps / NSEC_PER_SEC) +
+	 *	 time_in_ns * ((rate_bytes_ps % NSEC_PER_SEC) / NSEC_PER_SEC)
+	 *
+	 * time_in_ns * ((rate_bytes_ps % NSEC_PER_SEC) / NSEC_PER_SEC) =>
+	 * (rate_bytes_ps % NSEC_PER_SEC) * (time_in_ns / NSEC_PER_SEC +
+	 * 				     (time_in_ns % NSEC_PER_SEC) / NSEC_PER_SEC)
+	 *
+	 * The final formula is:
+	 * len = time_in_ns * (rate_bytes_ps / NSEC_PER_SEC) +
+	 *	 time_in_ns * ((rate_bytes_ps % NSEC_PER_SEC) / NSEC_PER_SEC) +
+	 *	 (time_in_ns % NSEC_PER_SEC) * (rate_bytes_ps % NSEC_PER_SEC) / NSEC_PER_SEC
+	 */
+	u64 r_integer = r->rate_bytes_ps / NSEC_PER_SEC;
+	u64 multi64 = 0;
+	u32 multi32 = 0;
+	u64 len = 0;
+
+	/* step1. calulate: time_in_ns * (rate_bytes_ps / NSEC_PER_SEC)
+	 *
+	 * u64 * u64, if both of them bigger than UINT_MAX, it will overflows,
+	 * so equals to u64 * u32 => (High1+Low1) * (0+Low2) =>
+	 * (H1*L2)<<32 + (L1*L2)
+	 */
+	if (time_in_ns >> 32 && r_integer >> 32) {
+		/* overflow happens */
+		len = ULLONG_MAX;
+	} else if (time_in_ns >> 32) {
+		multi64 = time_in_ns;
+		multi32 = r_integer;
+	} else if (r_integer >> 32) {
+		multi64 = r_integer;
+		multi32 = time_in_ns;
+	} else
+		len = r_integer * time_in_ns;
+
+	if (!len) {
+		/* len = H1 * L2 */
+		len = (multi64 >> 32) * multi32;
+		if (len > UINT_MAX) {
+			/* overflow happens */
+			len = ULLONG_MAX;
+		} else {
+			/* len = (H1 * L2) << 32 */
+			len <<= 32;
+
+			/* len = (H1 * L2) << 32 + (L1 * L2) */
+			len = do_plus64(len, (multi64 & ~0U) * multi32);
+		}
+	}
+
+	/* step2. calulate: len +
+	 * time_in_ns * ((rate_bytes_ps % NSEC_PER_SEC) / NSEC_PER_SEC)
+	 */
+	len = do_plus64(len,
+			time_in_ns *
+			((r->rate_bytes_ps % NSEC_PER_SEC) / NSEC_PER_SEC));
+
+	/* step3. calulate: len +
+	 * (time_in_ns % NSEC_PER_SEC) * (rate_bytes_ps % NSEC_PER_SEC) / NSEC_PER_SEC */
+	len = do_plus64(len,
+			(time_in_ns % NSEC_PER_SEC) *
+			(r->rate_bytes_ps % NSEC_PER_SEC) /
+			NSEC_PER_SEC);
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
 
 /*
  * Return length of individual segments of a gso packet,
@@ -289,10 +398,9 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_TBF_MAX + 1];
 	struct tc_tbf_qopt *qopt;
-	struct qdisc_rate_table *rtab = NULL;
-	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
-	int max_size, n;
+	u64 max_size;
+	s64 buffer, mtu;
 	u64 rate64 = 0, prate64 = 0;
 
 	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
@@ -304,38 +412,13 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
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
@@ -349,38 +432,62 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 		}
 	}
 
+	buffer = PSCHED_TICKS2NS(qopt->buffer);
+	mtu = PSCHED_TICKS2NS(qopt->mtu);
+
 	sch_tree_lock(sch);
 	if (child) {
 		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
 		qdisc_destroy(q->qdisc);
 		q->qdisc = child;
 	}
-	q->limit = qopt->limit;
-	q->mtu = PSCHED_TICKS2NS(qopt->mtu);
-	q->max_size = max_size;
-	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
-	q->tokens = q->buffer;
-	q->ptokens = q->mtu;
 
 	if (tb[TCA_TBF_RATE64])
 		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
-	psched_ratecfg_precompute(&q->rate, &rtab->rate, rate64);
-	if (ptab) {
+	psched_ratecfg_precompute(&q->rate, &qopt->rate, rate64);
+	if (!q->rate.rate_bytes_ps)
+		goto unlock_done;
+
+	max_size = min_t(u64, psched_ns_t2l(&q->rate, buffer), ~0U);
+
+	if (qopt->peakrate.rate) {
 		if (tb[TCA_TBF_PRATE64])
 			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
-		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
+		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
+		if (q->peak.rate_bytes_ps <= q->rate.rate_bytes_ps) {
+			pr_warn_ratelimited("sch_tbf: peakrate %llu is lower than or equals to rate %llu !\n",
+					    q->peak.rate_bytes_ps, q->rate.rate_bytes_ps);
+			goto unlock_done;
+		}
+
+		max_size = min_t(u64, max_size, psched_ns_t2l(&q->peak, mtu));
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
 	}
 
+	if (!max_size)
+		goto unlock_done;
+
+	if (max_size < psched_mtu(qdisc_dev(sch)))
+		pr_warn_ratelimited("sch_tbf: burst %llu is lower than device %s mtu (%u) !\n",
+				    max_size, qdisc_dev(sch)->name,
+				    psched_mtu(qdisc_dev(sch)));
+
+	q->limit = qopt->limit;
+	q->mtu = mtu;
+	q->max_size = max_size;
+	q->buffer = buffer;
+	q->tokens = q->buffer;
+	q->ptokens = q->mtu;
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
