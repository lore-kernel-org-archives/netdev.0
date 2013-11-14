From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH 3/3] net: sched: htb: fix calculation of quantum
Date: Thu, 14 Nov 2013 17:01:54 +0800
Message-ID: <1384419714-24364-4-git-send-email-yangyingliang@huawei.com>
References: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25696 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab3KNJCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:02:04 -0500
In-Reply-To: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, 32bit rates may be not the true rate.
So use rate_bytes_ps which is from
max(rate32, rate64) to calcualte quantum.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_htb.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f983803..9474294 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1478,11 +1478,20 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
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
+		u64 quantum = div64_u64(cl->rate.rate_bytes_ps,
+					q->rate2quantum);
+		cl->quantum = min_t(u64, quantum, INT_MAX);
 		if (!hopt->quantum && cl->quantum < 1000) {
 			pr_warning(
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
@@ -1501,13 +1510,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
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
1.7.12
