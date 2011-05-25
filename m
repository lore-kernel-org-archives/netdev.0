From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_sfq: fix peek() implementation
Date: Wed, 25 May 2011 16:40:11 +0200
Message-ID: <1306334411.2820.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53978 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757866Ab1EYOkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 10:40:16 -0400
Received: by wya21 with SMTP id 21so5824915wya.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 07:40:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit eeaeb068f139 (sch_sfq: allow big packets and be fair),
sfq_peek() can return a different skb that would be normally dequeued by
sfq_dequeue() [ if current slot->allot is negative ]

Use generic qdisc_peek_dequeued() instead of custom implementation, to
get consistent result.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jesper Dangaard Brouer <hawk@diku.dk>
---
 net/sched/sch_sfq.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b1d00f8..b6ea6af 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -414,18 +414,6 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 }
 
 static struct sk_buff *
-sfq_peek(struct Qdisc *sch)
-{
-	struct sfq_sched_data *q = qdisc_priv(sch);
-
-	/* No active slots */
-	if (q->tail == NULL)
-		return NULL;
-
-	return q->slots[q->tail->next].skblist_next;
-}
-
-static struct sk_buff *
 sfq_dequeue(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
@@ -706,7 +694,7 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
-	.peek		=	sfq_peek,
+	.peek		=	qdisc_peek_dequeued,
 	.drop		=	sfq_drop,
 	.init		=	sfq_init,
 	.reset		=	sfq_reset,


