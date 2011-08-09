From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] net_sched: prio: use qdisc_dequeue_peeked
Date: Tue,  9 Aug 2011 14:04:43 +0200
Message-ID: <1312891483-30034-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41241 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753310Ab1HIMCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 08:02:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 07bd8df5df4369487812bf85a237322ff3569b77
(sch_sfq: fix peek() implementation) changed sfq to use generic
peek helper.

This makes HFSC complain about a non-work-conserving child qdisc, if
prio with sfq child is used within hfsc:

hfsc peeks into prio qdisc, which will then peek into sfq.
returned skb is stashed in sch->gso_skb.

Next, hfsc tries to dequeue from prio, but prio will call sfq dequeue
directly, which may return NULL instead of previously peeked-at skb.

Have prio call qdisc_dequeue_peeked, so sfq->dequeue() is
not called in this case.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Eric, does this look correct to you?
 I am not sure if sfq needs fixing instead of this patch here.

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2a318f2..b5d56a2 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -112,7 +112,7 @@ static struct sk_buff *prio_dequeue(struct Qdisc *sch)
 
 	for (prio = 0; prio < q->bands; prio++) {
 		struct Qdisc *qdisc = q->queues[prio];
-		struct sk_buff *skb = qdisc->dequeue(qdisc);
+		struct sk_buff *skb = qdisc_dequeue_peeked(qdisc);
 		if (skb) {
 			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
-- 
1.7.3.4

