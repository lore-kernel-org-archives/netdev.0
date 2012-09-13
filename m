From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 3/4] net_sched: gred: fix qave reporting via netlink
Date: Thu, 13 Sep 2012 11:22:34 -0400
Message-ID: <1347549755-19438-3-git-send-email-david.ward@ll.mit.edu>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bruce Osler <brosler@cisco.com>, Cyril Chemparathy <cyril@ti.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:50760 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754463Ab2IMPsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 11:48:25 -0400
In-Reply-To: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

q->vars.qavg is a Wlog scaled value, but q->backlog is not. In order
to pass q->vars.qavg as the backlog value, we need to un-scale it.
Additionally, the qave value returned via netlink should not be Wlog
scaled, so we need to un-scale the result of red_calc_qavg().

This caused artificially high values for "Average Queue" to be shown
by 'tc -s -d qdisc', but did not affect the actual operation of GRED.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/sched/sch_gred.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index e19d4eb..b2570b5 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -534,6 +534,7 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 	for (i = 0; i < MAX_DPs; i++) {
 		struct gred_sched_data *q = table->tab[i];
 		struct tc_gred_qopt opt;
+		unsigned long qavg;
 
 		memset(&opt, 0, sizeof(opt));
 
@@ -565,7 +566,9 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 		if (gred_wred_mode(table))
 			gred_load_wred_set(table, q);
 
-		opt.qave = red_calc_qavg(&q->parms, &q->vars, q->vars.qavg);
+		qavg = red_calc_qavg(&q->parms, &q->vars,
+				     q->vars.qavg >> q->parms.Wlog);
+		opt.qave = qavg >> q->parms.Wlog;
 
 append_opt:
 		if (nla_append(skb, sizeof(opt), &opt) < 0)
-- 
1.7.4.1
