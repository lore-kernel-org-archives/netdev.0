From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/15]: sch_netem: use nla_parse_nested_compat
Date: Wed, 23 Jan 2008 17:36:38 +0100 (MET)
Message-ID: <20080123163557.6459.94761.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49714 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250AbYAWQgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:39 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: sch_netem: use nla_parse_nested_compat

Replace open coded equivalent of nla_parse_nested_compat().

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 1af28b79f4f0a67db344938ef6739ad2af1a72a7
tree 52294414fad2e6cd11aa719113f160a47bbe5bd5
parent 3bab4166cf0350552419d7871b4df463c5aed2ea
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 16:48:46 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 16:48:46 +0100

 net/sched/sch_netem.c |   58 ++++++++++++++++++++++---------------------------
 1 files changed, 26 insertions(+), 32 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a7b58df..1a75579 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -407,13 +407,18 @@ static int get_corrupt(struct Qdisc *sch, const struct nlattr *attr)
 static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_NETEM_MAX + 1];
 	struct tc_netem_qopt *qopt;
 	int ret;
 
-	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
+	if (opt == NULL)
 		return -EINVAL;
 
-	qopt = nla_data(opt);
+	ret = nla_parse_nested_compat(tb, TCA_NETEM_MAX, opt, NULL, qopt,
+				      sizeof(*qopt));
+	if (ret < 0)
+		return ret;
+
 	ret = set_fifo_limit(q->qdisc, qopt->limit);
 	if (ret) {
 		pr_debug("netem: can't set fifo limit\n");
@@ -434,39 +439,28 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (q->gap)
 		q->reorder = ~0;
 
-	/* Handle nested options after initial queue options.
-	 * Should have put all options in nested format but too late now.
-	 */
-	if (nla_len(opt) > sizeof(*qopt)) {
-		struct nlattr *tb[TCA_NETEM_MAX + 1];
-		if (nla_parse(tb, TCA_NETEM_MAX,
-			      nla_data(opt) + sizeof(*qopt),
-			      nla_len(opt) - sizeof(*qopt), NULL))
-			return -EINVAL;
-
-		if (tb[TCA_NETEM_CORR]) {
-			ret = get_correlation(sch, tb[TCA_NETEM_CORR]);
-			if (ret)
-				return ret;
-		}
+	if (tb[TCA_NETEM_CORR]) {
+		ret = get_correlation(sch, tb[TCA_NETEM_CORR]);
+		if (ret)
+			return ret;
+	}
 
-		if (tb[TCA_NETEM_DELAY_DIST]) {
-			ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
-			if (ret)
-				return ret;
-		}
+	if (tb[TCA_NETEM_DELAY_DIST]) {
+		ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
+		if (ret)
+			return ret;
+	}
 
-		if (tb[TCA_NETEM_REORDER]) {
-			ret = get_reorder(sch, tb[TCA_NETEM_REORDER]);
-			if (ret)
-				return ret;
-		}
+	if (tb[TCA_NETEM_REORDER]) {
+		ret = get_reorder(sch, tb[TCA_NETEM_REORDER]);
+		if (ret)
+			return ret;
+	}
 
-		if (tb[TCA_NETEM_CORRUPT]) {
-			ret = get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
-			if (ret)
-				return ret;
-		}
+	if (tb[TCA_NETEM_CORRUPT]) {
+		ret = get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
+		if (ret)
+			return ret;
 	}
 
 	return 0;
