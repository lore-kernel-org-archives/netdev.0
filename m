From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/3] sch_netem: return errcode before setting params
Date: Thu, 23 Jan 2014 17:31:37 +0800
Message-ID: <1390469499-31952-2-git-send-email-yangyingliang@huawei.com>
References: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:4234 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbaAWJca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 04:32:30 -0500
In-Reply-To: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_dist_table() and get_loss_clg() may be failed. These
two functions should be called after setting the members
of qdisc_priv(sch), or it will break the old settings while
either of them is failed.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 38 ++++++++++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a2bfc37..c90de21 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -819,6 +819,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_NETEM_MAX + 1];
 	struct tc_netem_qopt *qopt;
+	struct clgstate old_clg;
+	int old_loss_model = CLG_RANDOM;
 	int ret;
 
 	if (opt == NULL)
@@ -829,6 +831,32 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
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
+			 * in get_loss_clg() */
+			q->clg = old_clg;
+			q->loss_model = old_loss_model;
+			return ret;
+		}
+	}
+
 	sch->limit = qopt->limit;
 
 	q->latency = qopt->latency;
@@ -848,12 +876,6 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
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
 
@@ -870,10 +892,6 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
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
