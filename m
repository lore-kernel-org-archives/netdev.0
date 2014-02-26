From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net] sch_tbf: Fix potential memory leak in tbf_change().
Date: Wed, 26 Feb 2014 21:43:42 +0900
Message-ID: <20140226214342.585acf597a84276fc152fc7e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yangyingliang@huawei.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:37078 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaBZMnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 07:43:46 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so938421pbc.24
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 04:43:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The allocated child qdisc is not freed in error conditions.
Defer the allocation after user configuration turns out to be
valid and acceptable.

Fixes: cc106e4 ("net: sched: tbf: fix the calculation of max_size")
Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Cc: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_tbf.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1cb413f..4f505a0 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -334,18 +334,6 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 			qdisc_put_rtab(qdisc_get_rtab(&qopt->peakrate,
 						      tb[TCA_TBF_PTAB]));
 
-	if (q->qdisc != &noop_qdisc) {
-		err = fifo_set_limit(q->qdisc, qopt->limit);
-		if (err)
-			goto done;
-	} else if (qopt->limit > 0) {
-		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
-		if (IS_ERR(child)) {
-			err = PTR_ERR(child);
-			goto done;
-		}
-	}
-
 	buffer = min_t(u64, PSCHED_TICKS2NS(qopt->buffer), ~0U);
 	mtu = min_t(u64, PSCHED_TICKS2NS(qopt->mtu), ~0U);
 
@@ -390,6 +378,18 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 		goto done;
 	}
 
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
 	sch_tree_lock(sch);
 	if (child) {
 		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
-- 
1.8.3.2
