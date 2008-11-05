From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] pkt_sched: Fix qdisc len in qdisc_peek_dequeued()
Date: Wed, 5 Nov 2008 13:44:54 +0000
Message-ID: <20081105134454.GA9376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:11771 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbYKENpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 08:45:00 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1271649eyi.37
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 05:44:59 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: Fix qdisc len in qdisc_peek_dequeued()

A packet dequeued and stored as gso_skb in qdisc_peek_dequeued() should
be seen as part of the queue for sch->q.qlen queries until it's really
dequeued with qdisc_dequeue_peeked(), so qlen needs additional updating
in these functions. (Updating qstats.backlog shouldn't matter here.)

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/sch_generic.h |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9dcb5bf..64ae1ba 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -442,8 +442,12 @@ static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
 static inline struct sk_buff *qdisc_peek_dequeued(struct Qdisc *sch)
 {
 	/* we can reuse ->gso_skb because peek isn't called for root qdiscs */
-	if (!sch->gso_skb)
+	if (!sch->gso_skb) {
 		sch->gso_skb = sch->dequeue(sch);
+		if (sch->gso_skb)
+			/* it's still part of the queue */
+			sch->q.qlen++;
+	}
 
 	return sch->gso_skb;
 }
@@ -453,10 +457,12 @@ static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 {
 	struct sk_buff *skb = sch->gso_skb;
 
-	if (skb)
+	if (skb) {
 		sch->gso_skb = NULL;
-	else
+		sch->q.qlen--;
+	} else {
 		skb = sch->dequeue(sch);
+	}
 
 	return skb;
 }
