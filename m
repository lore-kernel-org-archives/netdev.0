From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 4/5] sch_tbf: add tbf_change for #tc qdisc change ...
Date: Thu, 6 Mar 2014 21:08:40 +0800
Message-ID: <1394111321-11192-5-git-send-email-yangyingliang@huawei.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:50341 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbaCFNIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:08:54 -0500
In-Reply-To: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tbf_change() function which is called by command #tc qdisc change...
It's different from tbf_replace. In tbf_change(), it will only change
the options that specified in command.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_tbf.c | 118 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 118 insertions(+)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e9f373effd5f..ef39d284d06a 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -308,6 +308,123 @@ static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
 	[TCA_TBF_PBURST] = { .type = NLA_U32 },
 };
 
+static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	int err;
+	struct tbf_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_TBF_MAX + 1];
+	struct tc_tbf_qopt *qopt;
+	struct Qdisc *child = NULL;
+	struct psched_ratecfg rate;
+	struct psched_ratecfg peak;
+	u64 max_size;
+	s64 buffer, mtu;
+	u64 rate64 = 0, prate64 = 0;
+
+	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
+	if (err < 0)
+		return err;
+
+	err = -EINVAL;
+	if (tb[TCA_TBF_PARMS] == NULL)
+		goto done;
+
+	qopt = nla_data(tb[TCA_TBF_PARMS]);
+	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE)
+		qdisc_put_rtab(qdisc_get_rtab(&qopt->rate,
+					      tb[TCA_TBF_RTAB]));
+
+	if (qopt->peakrate.linklayer == TC_LINKLAYER_UNAWARE)
+			qdisc_put_rtab(qdisc_get_rtab(&qopt->peakrate,
+						      tb[TCA_TBF_PTAB]));
+
+	buffer = min_t(u64, PSCHED_TICKS2NS(qopt->buffer), ~0U);
+	mtu = min_t(u64, PSCHED_TICKS2NS(qopt->mtu), ~0U);
+
+	if (tb[TCA_TBF_RATE64])
+		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
+	psched_ratecfg_precompute(&rate, &qopt->rate, rate64);
+
+	if (tb[TCA_TBF_BURST]) {
+		max_size = nla_get_u32(tb[TCA_TBF_BURST]);
+		buffer = psched_l2t_ns(&rate, max_size);
+	} else {
+		max_size = min_t(u64, psched_ns_t2l(&rate, buffer), ~0U);
+	}
+
+	if (qopt->peakrate.rate) {
+		if (tb[TCA_TBF_PRATE64])
+			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
+		psched_ratecfg_precompute(&peak, &qopt->peakrate, prate64);
+		if (peak.rate_bytes_ps <= rate.rate_bytes_ps) {
+			pr_warn_ratelimited("sch_tbf: peakrate %llu is lower than or equals to rate %llu !\n",
+					peak.rate_bytes_ps, rate.rate_bytes_ps);
+			err = -EINVAL;
+			goto done;
+		}
+
+		if (tb[TCA_TBF_PBURST]) {
+			u32 pburst = nla_get_u32(tb[TCA_TBF_PBURST]);
+			max_size = min_t(u32, max_size, pburst);
+			mtu = psched_l2t_ns(&peak, pburst);
+		} else {
+			max_size = min_t(u64, max_size, psched_ns_t2l(&peak, mtu));
+		}
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
+	if (q->qdisc != &noop_qdisc) {
+		err = fifo_set_limit(q->qdisc, qopt->limit);
+		if (err)
+			goto done;
+	} else if (qopt->limit > 0) {
+		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
+		if (IS_ERR(child)) {
+			err = PTR_ERR(child);
+			goto done;
+		}
+	}
+
+	sch_tree_lock(sch);
+	if (child) {
+		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
+		qdisc_destroy(q->qdisc);
+		q->qdisc = child;
+	}
+	if (qopt->limit)
+		q->limit = qopt->limit;
+	if (tb[TCA_TBF_PBURST])
+		q->mtu = mtu;
+	else if (qopt->mtu)
+		q->mtu = PSCHED_TICKS2NS(qopt->mtu);
+	q->max_size = max_size;
+	if (tb[TCA_TBF_BURST])
+		q->buffer = buffer;
+	else if (qopt->buffer)
+		q->buffer = PSCHED_TICKS2NS(qopt->buffer);
+	q->tokens = q->buffer;
+	q->ptokens = q->mtu;
+
+	if (qopt->rate.rate)
+		memcpy(&q->rate, &rate, sizeof(struct psched_ratecfg));
+	if (qopt->peakrate.rate)
+		memcpy(&q->peak, &peak, sizeof(struct psched_ratecfg));
+
+	sch_tree_unlock(sch);
+	err = 0;
+done:
+	return err;
+}
+
 static int tbf_replace(struct Qdisc *sch, struct nlattr *opt)
 {
 	int err;
@@ -560,6 +677,7 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.init		=	tbf_init,
 	.reset		=	tbf_reset,
 	.destroy	=	tbf_destroy,
+	.change		=	tbf_change,
 	.replace	=	tbf_replace,
 	.dump		=	tbf_dump,
 	.owner		=	THIS_MODULE,
-- 
1.8.0
