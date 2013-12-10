From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v7 2/2] net: sched: htb: fix the calculation of quantum
Date: Tue, 10 Dec 2013 11:49:18 +0800
Message-ID: <1386647358-47944-3-git-send-email-yangyingliang@huawei.com>
References: <1386647358-47944-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5881 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab3LJDt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:49:28 -0500
In-Reply-To: <1386647358-47944-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, 32bit rates may be not the true rate.
So use rate_bytes_ps which is from
max(rate32, rate64) to calcualte quantum.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0e1e38b..717b210 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1477,11 +1477,22 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		sch_tree_lock(sch);
 	}
 
+	rate64 = tb[TCA_HTB_RATE64] ? nla_get_u64(tb[TCA_HTB_RATE64]) : 0;
+
+	ceil64 = tb[TCA_HTB_CEIL64] ? nla_get_u64(tb[TCA_HTB_CEIL64]) : 0;
+
+	psched_ratecfg_precompute(&cl->rate, &hopt->rate, rate64);
+	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil, ceil64);
+
 	/* it used to be a nasty bug here, we have to check that node
 	 * is really leaf before changing cl->un.leaf !
 	 */
 	if (!cl->level) {
-		cl->quantum = hopt->rate.rate / q->rate2quantum;
+		u64 quantum = cl->rate.rate_bytes_ps;
+
+		do_div(quantum, q->rate2quantum);
+		cl->quantum = min_t(u64, quantum, INT_MAX);
+
 		if (!hopt->quantum && cl->quantum < 1000) {
 			pr_warning(
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
@@ -1500,13 +1511,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			cl->prio = TC_HTB_NUMPRIO - 1;
 	}
 
-	rate64 = tb[TCA_HTB_RATE64] ? nla_get_u64(tb[TCA_HTB_RATE64]) : 0;
-
-	ceil64 = tb[TCA_HTB_CEIL64] ? nla_get_u64(tb[TCA_HTB_CEIL64]) : 0;
-
-	psched_ratecfg_precompute(&cl->rate, &hopt->rate, rate64);
-	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil, ceil64);
-
 	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
 	cl->cbuffer = PSCHED_TICKS2NS(hopt->cbuffer);
 
-- 
1.8.0
