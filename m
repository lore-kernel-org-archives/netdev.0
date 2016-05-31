From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] hfsc: ensure class is added to eltree exactly once
Date: Tue, 31 May 2016 12:12:19 +0200
Message-ID: <1464689539-15162-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Miroslav Kratochvil <exa.exa@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40101 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750813AbcEaKME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 06:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Intent is to insert the class into the eligible tree when first packet
is enqueued (its removed from list when class becomes empty again).

Checking for a size of 1 is problematic:

1. child qdisc might have segmented the skb, in which backlog can transition
from 0 to a value > 1.

In this case we can't dequeue anymore as this class is not in the tree.

2. some qdiscs like fq_codel can purge their backlogs when internal
limits are hit and update the parent qlen via qdisc_tree_reduce_backlog(),
so its possible that we end up with a length of 1 after enqueue for a class
that was already on the active list.

If this happens, we add the same class twice (which then results
in qdisc dequeue soft lockup).

Fix it by testing the length before we attempt to enqueue to child qdisc,
if enqueue operation is successful and old qlen was 0, then the
class was not yet inserted into eltree.

Cc: Miroslav Kratochvil <exa.exa@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 This was found while looking at Miroslav Kratochvil bug report
 but I don't think this fixes his case (I could trigger the 2nd case
 above w. fq_codel+really_stupid_config_knobs but I got softlockup
 which did not match his report).

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index d783d7c..0854be3 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1583,6 +1583,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hfsc_class *cl;
 	int uninitialized_var(err);
+	unsigned int qlen;
 
 	cl = hfsc_classify(skb, sch, &err);
 	if (cl == NULL) {
@@ -1592,6 +1593,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
+	qlen = cl->qdisc->q.qlen;
 	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		if (net_xmit_drop_count(err)) {
@@ -1601,7 +1603,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	if (cl->qdisc->q.qlen == 1)
+	if (qlen == 0)
 		set_active(cl, qdisc_pkt_len(skb));
 
 	sch->q.qlen++;
-- 
2.7.3
