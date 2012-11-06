From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] htb: fix two bugs
Date: Mon, 05 Nov 2012 18:40:49 -0800
Message-ID: <1352169649.3140.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Vimalkumar <j.vimal@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62254 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933560Ab2KFCkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 21:40:51 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so35694pbb.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 18:40:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 56b765b79e9 (htb: improved accuracy at high rates)
introduced two bugs :

1) one bstats_update() was inadvertently removed from
   htb_dequeue_tree(), breaking statistics/rate estimation.

2) Missing qdisc_put_rtab() calls in htb_change_class(),
   leaking kernel memory, now struct htb_class no longer
   retains pointers to qdisc_rate_table structs.

   Since only rate is used, dont use qdisc_get_rtab() calls
   copying data we ignore anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Vimalkumar <j.vimal@gmail.com>
---
v2: check rates are not nul, as done in qdisc_get_rtab()

 net/sched/sch_htb.c |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 32a8097..d2922c0 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -879,6 +879,7 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
+		bstats_update(&cl->bstats, skb);
 		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
 		if (cl->un.leaf.deficit[level] < 0) {
 			cl->un.leaf.deficit[level] += cl->quantum;
@@ -1355,7 +1356,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)*arg, *parent;
 	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
 	struct nlattr *tb[__TCA_HTB_MAX];
 	struct tc_htb_opt *hopt;
 
@@ -1374,10 +1374,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	parent = parentid == TC_H_ROOT ? NULL : htb_find(parentid, sch);
 
 	hopt = nla_data(tb[TCA_HTB_PARMS]);
-
-	rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB]);
-	ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB]);
-	if (!rtab || !ctab)
+	if (!hopt->rate.rate || !hopt->ceil.rate)
 		goto failure;
 
 	if (!cl) {		/* new class */
@@ -1487,7 +1484,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	 * is really leaf before changing cl->un.leaf !
 	 */
 	if (!cl->level) {
-		cl->quantum = rtab->rate.rate / q->rate2quantum;
+		cl->quantum = hopt->rate.rate / q->rate2quantum;
 		if (!hopt->quantum && cl->quantum < 1000) {
 			pr_warning(
 			       "HTB: quantum of class %X is small. Consider r2q change.\n",
@@ -1509,8 +1506,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	cl->buffer = hopt->buffer;
 	cl->cbuffer = hopt->cbuffer;
 
-	cl->rate.rate_bps = (u64)rtab->rate.rate << 3;
-	cl->ceil.rate_bps = (u64)ctab->rate.rate << 3;
+	cl->rate.rate_bps = (u64)hopt->rate.rate << 3;
+	cl->ceil.rate_bps = (u64)hopt->ceil.rate << 3;
 
 	htb_precompute_ratedata(&cl->rate);
 	htb_precompute_ratedata(&cl->ceil);
@@ -1526,10 +1523,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	return 0;
 
 failure:
-	if (rtab)
-		qdisc_put_rtab(rtab);
-	if (ctab)
-		qdisc_put_rtab(ctab);
 	return err;
 }
 
