From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] qfq: don't leak skb if kzalloc fails
Date: Wed,  8 Jun 2016 14:31:33 +0200
Message-ID: <1465389093-29674-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59233 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1425119AbcFHMbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 08:31:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we need to create a new aggregate to enqueue the skb we need
to kzalloc the new struct.

If that fails we returned ENOBUFS without freeing the skb.

Spotted during code review.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_qfq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 8d2d8d9..435b970 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1236,7 +1236,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		err = qfq_change_agg(sch, cl, cl->agg->class_weight,
 				     qdisc_pkt_len(skb));
 		if (err)
-			return err;
+			return qdisc_drop(skb, sch);
 	}
 
 	err = qdisc_enqueue(skb, cl->qdisc);
-- 
2.7.3
