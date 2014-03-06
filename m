From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 5/5] sch_netem: add netem_replace for #tc qdisc replace ...
Date: Thu, 6 Mar 2014 21:08:41 +0800
Message-ID: <1394111321-11192-6-git-send-email-yangyingliang@huawei.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:13568 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbaCFNIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:08:52 -0500
In-Reply-To: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Command "#tc qdisc replace ..." cannot really replace the old qdisc.
The old options are still there after replacing the old qdisc.

E.g.
  # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
  # tc qdisc show
    qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit

  # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
  # tc qdisc show
    qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit

The rate option is still there.

This patch adds netem_replace() function which will clear old options for
command "#tc qdisc replace ...".

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 127 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 127 insertions(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index f1669a00f571..af8dc71065e6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -703,6 +703,13 @@ static void get_correlation(struct netem_sched_data *q, const struct nlattr *att
 	init_crandom(&q->dup_cor, c->dup_corr);
 }
 
+static void correlation_reset(struct netem_sched_data *q)
+{
+	memset(&q->delay_cor, 0, sizeof(struct crndstate));
+	memset(&q->loss_cor, 0, sizeof(struct crndstate));
+	memset(&q->dup_cor, 0, sizeof(struct crndstate));
+}
+
 static void get_reorder(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct tc_netem_reorder *r = nla_data(attr);
@@ -711,6 +718,12 @@ static void get_reorder(struct netem_sched_data *q, const struct nlattr *attr)
 	init_crandom(&q->reorder_cor, r->correlation);
 }
 
+static void reorder_reset(struct netem_sched_data *q)
+{
+	q->reorder = 0;
+	memset(&q->reorder_cor, 0, sizeof(struct crndstate));
+}
+
 static void get_corrupt(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct tc_netem_corrupt *r = nla_data(attr);
@@ -719,6 +732,12 @@ static void get_corrupt(struct netem_sched_data *q, const struct nlattr *attr)
 	init_crandom(&q->corrupt_cor, r->correlation);
 }
 
+static void corrupt_reset(struct netem_sched_data *q)
+{
+	q->corrupt = 0;
+	memset(&q->corrupt_cor, 0, sizeof(struct crndstate));
+}
+
 static void get_rate(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct tc_netem_rate *r = nla_data(attr);
@@ -733,6 +752,15 @@ static void get_rate(struct netem_sched_data *q, const struct nlattr *attr)
 		q->cell_size_reciprocal = (struct reciprocal_value) { 0 };
 }
 
+static void rate_reset(struct netem_sched_data *q)
+{
+	q->rate = 0;
+	q->packet_overhead = 0;
+	q->cell_size = 0;
+	q->cell_size_reciprocal = (struct reciprocal_value) { 0 };
+	q->cell_overhead = 0;
+}
+
 static int get_loss_clg(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct nlattr *la;
@@ -898,6 +926,104 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	return ret;
 }
 
+static int netem_replace(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_NETEM_MAX + 1];
+	struct tc_netem_qopt *qopt;
+	struct clgstate old_clg;
+	int old_loss_model = CLG_RANDOM;
+	int ret;
+
+	if (opt == NULL)
+		return -EINVAL;
+
+	qopt = nla_data(opt);
+	ret = parse_attr(tb, TCA_NETEM_MAX, opt, netem_policy, sizeof(*qopt));
+	if (ret < 0)
+		return ret;
+
+	/* backup q->clg and q->loss_model */
+	old_clg = q->clg;
+	old_loss_model = q->loss_model;
+
+	if (tb[TCA_NETEM_LOSS]) {
+		ret = get_loss_clg(q, tb[TCA_NETEM_LOSS]);
+		if (ret) {
+			q->loss_model = old_loss_model;
+			return ret;
+		}
+	} else {
+		q->loss_model = CLG_RANDOM;
+		memset(&q->clg, 0, sizeof(q->clg));
+	}
+
+	if (tb[TCA_NETEM_DELAY_DIST]) {
+		ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
+		if (ret) {
+			/* recover clg and loss_model, in case of
+			 * q->clg and q->loss_model were modified
+			 * in get_loss_clg()
+			 */
+			q->clg = old_clg;
+			q->loss_model = old_loss_model;
+			return ret;
+		}
+	} else {
+		dist_free(q->delay_dist);
+		q->delay_dist = NULL;
+	}
+
+	sch->limit = qopt->limit;
+
+	q->latency = qopt->latency;
+	q->jitter = qopt->jitter;
+	q->limit = qopt->limit;
+	q->gap = qopt->gap;
+	q->counter = 0;
+	q->loss = qopt->loss;
+	q->duplicate = qopt->duplicate;
+
+	/* for compatibility with earlier versions.
+	 * if gap is set, need to assume 100% probability
+	 */
+	if (q->gap)
+		q->reorder = ~0;
+	else
+		q->reorder = 0;
+
+	if (tb[TCA_NETEM_CORR])
+		get_correlation(q, tb[TCA_NETEM_CORR]);
+	else
+		correlation_reset(q);
+
+	if (tb[TCA_NETEM_REORDER])
+		get_reorder(q, tb[TCA_NETEM_REORDER]);
+	else
+		reorder_reset(q);
+
+	if (tb[TCA_NETEM_CORRUPT])
+		get_corrupt(q, tb[TCA_NETEM_CORRUPT]);
+	else
+		corrupt_reset(q);
+
+	if (tb[TCA_NETEM_RATE])
+		get_rate(q, tb[TCA_NETEM_RATE]);
+	else
+		rate_reset(q);
+
+	if (tb[TCA_NETEM_RATE64])
+		q->rate = max_t(u64, q->rate,
+				nla_get_u64(tb[TCA_NETEM_RATE64]));
+
+	if (tb[TCA_NETEM_ECN])
+		q->ecn = nla_get_u32(tb[TCA_NETEM_ECN]);
+	else
+		q->ecn = 0;
+
+	return ret;
+}
+
 static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -1115,6 +1241,7 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.reset		=	netem_reset,
 	.destroy	=	netem_destroy,
 	.change		=	netem_change,
+	.replace	=	netem_replace,
 	.dump		=	netem_dump,
 	.owner		=	THIS_MODULE,
 };
-- 
1.8.0
