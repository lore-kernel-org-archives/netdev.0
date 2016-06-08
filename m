From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 net] qfq: don't leak skb if kzalloc fails
Date: Wed,  8 Jun 2016 23:23:01 +0200
Message-ID: <1465420981-13638-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60659 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758588AbcFHVWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 17:22:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we need to create a new aggregate to enqueue the skb we call kzalloc.
If that fails we returned ENOBUFS without freeing the skb.

Spotted during code review.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 V2: also increment cl->qstats.drops

 net/sched/sch_qfq.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 8d2d8d9..f18857f 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1235,8 +1235,10 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			 cl->agg->lmax, qdisc_pkt_len(skb), cl->common.classid);
 		err = qfq_change_agg(sch, cl, cl->agg->class_weight,
 				     qdisc_pkt_len(skb));
-		if (err)
-			return err;
+		if (err) {
+			cl->qstats.drops++;
+			return qdisc_drop(skb, sch);
+		}
 	}
 
 	err = qdisc_enqueue(skb, cl->qdisc);
-- 
2.7.3
