From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 08:24:29 +0200
Message-ID: <1460355869-13539-1-git-send-email-larper@axis.com>
Cc: jhs@mojatatu.com, linux-kernel@vger.kernel.org,
	xiyou.wangcong@gmail.com, Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:51094 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862AbcDKGYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 02:24:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A failure in validate_xmit_skb_list() triggered an unconditional call
to dev_requeue_skb with skb=NULL. This slowly grows the queue
discipline's qlen count until all traffic through the queue stops.

By introducing a NULL check in dev_requeue_skb it was also necessary
to make the __netif_schedule call conditional to avoid scheduling an
empty queue.

Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
Signed-off-by: Lars Persson <larper@axis.com>
---
 net/sched/sch_generic.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f18c350..4e6a79c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -47,10 +47,13 @@ EXPORT_SYMBOL(default_qdisc_ops);
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	q->gso_skb = skb;
-	q->qstats.requeues++;
-	q->q.qlen++;	/* it's still part of the queue */
-	__netif_schedule(q);
+	if (skb) {
+		q->gso_skb = skb;
+		q->qstats.requeues++;
+		q->q.qlen++;	/* it's still part of the queue */
+	}
+	if (qdisc_qlen(q))
+		__netif_schedule(q);
 
 	return 0;
 }
-- 
2.1.4
