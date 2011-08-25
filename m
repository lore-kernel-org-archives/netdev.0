From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: sfb: optimize enqueue on full queue
Date: Thu, 25 Aug 2011 18:21:32 +0200
Message-ID: <1314289292.2387.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52769 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab1HYQVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 12:21:31 -0400
Received: by wwf5 with SMTP id 5so2567985wwf.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 09:21:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case SFB queue is full (hard limit reached), there is no point
spending time to compute hash and maximum qlen/p_mark.

We instead just early drop packet.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfb.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 0a833d0..e83c272 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -287,6 +287,12 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	u32 r, slot, salt, sfbhash;
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 
+	if (unlikely(sch->q.qlen >= q->limit)) {
+		sch->qstats.overlimits++;
+		q->stats.queuedrop++;
+		goto drop;
+	}
+
 	if (q->rehash_interval > 0) {
 		unsigned long limit = q->rehash_time + q->rehash_interval;
 
@@ -332,12 +338,9 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	slot ^= 1;
 	sfb_skb_cb(skb)->hashes[slot] = 0;
 
-	if (unlikely(minqlen >= q->max || sch->q.qlen >= q->limit)) {
+	if (unlikely(minqlen >= q->max)) {
 		sch->qstats.overlimits++;
-		if (minqlen >= q->max)
-			q->stats.bucketdrop++;
-		else
-			q->stats.queuedrop++;
+		q->stats.bucketdrop++;
 		goto drop;
 	}
 
