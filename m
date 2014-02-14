From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 1/3] sch_netem: return errcode before setting params
Date: Fri, 14 Feb 2014 10:30:41 +0800
Message-ID: <1392345043-12208-2-git-send-email-yangyingliang@huawei.com>
References: <1392345043-12208-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:31027 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaBNCaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 21:30:52 -0500
In-Reply-To: <1392345043-12208-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_dist_table() and get_loss_clg() may be failed. These
two functions should be called after setting the members
of qdisc_priv(sch), or it will break the old settings while
either of them is failed.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index de1059a..b341943 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -821,6 +821,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_NETEM_MAX + 1];
 	struct tc_netem_qopt *qopt;
+	struct clgstate old_clg;
+	int old_loss_model = CLG_RANDOM;
 	int ret;
 
 	if (opt == NULL)
@@ -831,6 +833,33 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (ret < 0)
 		return ret;
 
+	/* backup q->clg and q->loss_model */
+	old_clg = q->clg;
+	old_loss_model = q->loss_model;
+
+	if (tb[TCA_NETEM_LOSS]) {
+		ret = get_loss_clg(sch, tb[TCA_NETEM_LOSS]);
+		if (ret) {
+			q->loss_model = old_loss_model;
+			return ret;
+		}
+	} else {
+		q->loss_model = CLG_RANDOM;
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
+	}
+
 	sch->limit = qopt->limit;
 
 	q->latency = qopt->latency;
@@ -850,12 +879,6 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_NETEM_CORR])
 		get_correlation(sch, tb[TCA_NETEM_CORR]);
 
-	if (tb[TCA_NETEM_DELAY_DIST]) {
-		ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
-		if (ret)
-			return ret;
-	}
-
 	if (tb[TCA_NETEM_REORDER])
 		get_reorder(sch, tb[TCA_NETEM_REORDER]);
 
@@ -872,10 +895,6 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_NETEM_ECN])
 		q->ecn = nla_get_u32(tb[TCA_NETEM_ECN]);
 
-	q->loss_model = CLG_RANDOM;
-	if (tb[TCA_NETEM_LOSS])
-		ret = get_loss_clg(sch, tb[TCA_NETEM_LOSS]);
-
 	return ret;
 }
 
-- 
1.8.0
