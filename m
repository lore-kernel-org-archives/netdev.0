From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_qfq: accurate wsum handling
Date: Mon, 02 Jan 2012 22:47:50 +0100
Message-ID: <1325540870.2874.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60413 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab2ABVry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 16:47:54 -0500
Received: by wgbds13 with SMTP id ds13so21900669wgb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 13:47:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can underestimate q->wsum in case of "tc class replace ... qfq"
and/or qdisc_create_dflt() error.

wsum is not really used in fast path, only at qfq qdisc/class setup,
to catch user error.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 net/sched/sch_qfq.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 1033434..2c5ff61 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -211,6 +211,7 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	struct nlattr *tb[TCA_QFQ_MAX + 1];
 	u32 weight, lmax, inv_w;
 	int i, err;
+	int delta_w;
 
 	if (tca[TCA_OPTIONS] == NULL) {
 		pr_notice("qfq: no options\n");
@@ -232,9 +233,10 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	inv_w = ONE_FP / weight;
 	weight = ONE_FP / inv_w;
-	if (q->wsum + weight > QFQ_MAX_WSUM) {
+	delta_w = weight - (cl ? ONE_FP / cl->inv_w : 0);
+	if (q->wsum + delta_w > QFQ_MAX_WSUM) {
 		pr_notice("qfq: total weight out of range (%u + %u)\n",
-			  weight, q->wsum);
+			  delta_w, q->wsum);
 		return -EINVAL;
 	}
 
@@ -256,13 +258,12 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 				return err;
 		}
 
-		sch_tree_lock(sch);
-		if (tb[TCA_QFQ_WEIGHT]) {
-			q->wsum = weight - ONE_FP / cl->inv_w;
+		if (inv_w != cl->inv_w) {
+			sch_tree_lock(sch);
+			q->wsum += delta_w;
 			cl->inv_w = inv_w;
+			sch_tree_unlock(sch);
 		}
-		sch_tree_unlock(sch);
-
 		return 0;
 	}
 
@@ -277,7 +278,6 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	i = qfq_calc_index(cl->inv_w, cl->lmax);
 
 	cl->grp = &q->groups[i];
-	q->wsum += weight;
 
 	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
 				      &pfifo_qdisc_ops, classid);
@@ -294,6 +294,7 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			return err;
 		}
 	}
+	q->wsum += weight;
 
 	sch_tree_lock(sch);
 	qdisc_class_hash_insert(&q->clhash, &cl->common);
