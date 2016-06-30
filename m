From: Michal Soltys <soltys@ziu.info>
Subject: [net-next PATCH 1/5] net/sched/sch_hfsc.c: handle corner cases where head may change invalidating calculated deadline
Date: Thu, 30 Jun 2016 02:26:44 +0200
Message-ID: <1467246408-913-2-git-send-email-soltys@ziu.info>
References: <1467246408-913-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:50062 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbcF3A1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 20:27:33 -0400
In-Reply-To: <1467246408-913-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Realtime scheduling implemented in HFSC uses head of the queue to make
the decision about which packet to schedule next. But in case of any
head drop, the deadline calculated for the previous head is not
necessarily correct for the next head (unless both packets have the same
length).

Thanks to peek() function used during dequeue - which internally is a
dequeue operation - hfsc is almost safe from this issue, as peek()
dequeues and isolates the head storing it temporarily until the real
dequeue happens.

But there is one exception: if after the class activation a drop happens
before the first dequeue operation, there's never a chance to do the
peek().

Adding peek() call in enqueue - if this is the first packet in a new
backlog period AND the scheduler has realtime curve defined - fixes that
one corner case. The 1st hfsc_dequeue() will use that peeked packet,
similarly as every subsequent hfsc_dequeue() call uses packet peeked by
the previous call.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 8cb5eff..6d6df6b 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1594,8 +1594,17 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 		return err;
 	}
 
-	if (cl->qdisc->q.qlen == 1)
+	if (cl->qdisc->q.qlen == 1) {
 		set_active(cl, qdisc_pkt_len(skb));
+		/*
+		 * If this is the first packet, isolate the head so an eventual
+		 * head drop before the first dequeue operation has no chance
+		 * to invalidate the deadline.
+		 */
+		if (cl->cl_flags & HFSC_RSC)
+			cl->qdisc->ops->peek(cl->qdisc);
+
+	}
 
 	qdisc_qstats_backlog_inc(sch, skb);
 	sch->q.qlen++;
-- 
2.1.3
