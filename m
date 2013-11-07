From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 1/3] net_sched: tbf: support of 64bit rates
Date: Thu, 7 Nov 2013 10:13:30 +0800
Message-ID: <1383790412-41944-2-git-send-email-yangyingliang@huawei.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <jhs@mojatatu.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:31928 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab3KGCNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:13:53 -0500
In-Reply-To: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With psched_ratecfg_precompute(), tbf can deal with 64bit rates.
Add two new attributes so that tc can use them to break the 32bit
limit.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 include/uapi/linux/pkt_sched.h |  2 ++
 net/sched/sch_tbf.c            | 22 ++++++++++++++++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index f2624b5..307f293 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -171,6 +171,8 @@ enum {
 	TCA_TBF_PARMS,
 	TCA_TBF_RTAB,
 	TCA_TBF_PTAB,
+	TCA_TBF_RATE64,
+	TCA_TBF_PRATE64,
 	__TCA_TBF_MAX,
 };
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index b057122..b736517 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -266,20 +266,23 @@ static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
 	[TCA_TBF_PARMS]	= { .len = sizeof(struct tc_tbf_qopt) },
 	[TCA_TBF_RTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 	[TCA_TBF_PTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
+	[TCA_TBF_RATE64]	= { .type = NLA_U64 },
+	[TCA_TBF_PRATE64]	= { .type = NLA_U64 },
 };
 
 static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	int err;
 	struct tbf_sched_data *q = qdisc_priv(sch);
-	struct nlattr *tb[TCA_TBF_PTAB + 1];
+	struct nlattr *tb[TCA_TBF_MAX + 1];
 	struct tc_tbf_qopt *qopt;
 	struct qdisc_rate_table *rtab = NULL;
 	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
 	int max_size, n;
+	u64 rate64 = 0, prate64 = 0;
 
-	err = nla_parse_nested(tb, TCA_TBF_PTAB, opt, tbf_policy);
+	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
 	if (err < 0)
 		return err;
 
@@ -341,9 +344,13 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
-	psched_ratecfg_precompute(&q->rate, &rtab->rate, 0);
+	if (tb[TCA_TBF_RATE64])
+		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
+	psched_ratecfg_precompute(&q->rate, &rtab->rate, rate64);
 	if (ptab) {
-		psched_ratecfg_precompute(&q->peak, &ptab->rate, 0);
+		if (tb[TCA_TBF_PRATE64])
+			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
+		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
@@ -402,6 +409,13 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.buffer = PSCHED_NS2TICKS(q->buffer);
 	if (nla_put(skb, TCA_TBF_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
+	if ((q->rate.rate_bytes_ps >= (1ULL << 32)) &&
+			nla_put_u64(skb, TCA_TBF_RATE64, q->rate.rate_bytes_ps))
+		goto nla_put_failure;
+	if (q->peak_present &&
+			(q->peak.rate_bytes_ps >= (1ULL << 32)) &&
+			nla_put_u64(skb, TCA_TBF_PRATE64, q->peak.rate_bytes_ps))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 	return skb->len;
-- 
1.7.12
