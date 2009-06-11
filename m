From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] neigh: fix state transition INCOMPLETE->FAILED via Netlink request
Date: Thu, 11 Jun 2009 13:32:25 +0300
Message-ID: <1244716345-9407-1-git-send-email-timo.teras@iki.fi>
References: <20090611.031215.17106793.davem@davemloft.net>
Cc: Timo Teras <timo.teras@iki.fi>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:42295 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509AbZFKKc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 06:32:27 -0400
Received: by ewy6 with SMTP id 6so1875840ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 03:32:28 -0700 (PDT)
In-Reply-To: <20090611.031215.17106793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code errors out the INCOMPLETE neigh entry skb queue only from
the timer if maximum probes have been attempted and there has been no reply.
This also causes the transtion to FAILED state.

However, the neigh entry can be also updated via Netlink to inform that the
address is unavailable.  Currently, neigh_update() just stops the timers and
leaves the pending skb's unreleased. This results that the clean up code in
the timer callback is never called, preventing also proper garbage collection.

This fixes neigh_update() to process the pending skb queue immediately if
INCOMPLETE -> FAILED state transtion occurs due to a Netlink request.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/core/neighbour.c |   46 ++++++++++++++++++++++++++++------------------
 1 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a1cbce7..a17cb9d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -771,6 +771,28 @@ static __inline__ int neigh_max_probes(struct neighbour *n)
 		p->ucast_probes + p->app_probes + p->mcast_probes);
 }
 
+static void neigh_invalidate(struct neighbour *neigh)
+{
+	struct sk_buff *skb;
+
+	NEIGH_CACHE_STAT_INC(neigh->tbl, res_failed);
+	NEIGH_PRINTK2("neigh %p is failed.\n", neigh);
+	neigh->updated = jiffies;
+
+	/* It is very thin place. report_unreachable is very complicated
+	   routine. Particularly, it can hit the same neighbour entry!
+
+	   So that, we try to be accurate and avoid dead loop. --ANK
+	 */
+	while (neigh->nud_state == NUD_FAILED &&
+	       (skb = __skb_dequeue(&neigh->arp_queue)) != NULL) {
+		write_unlock(&neigh->lock);
+		neigh->ops->error_report(neigh, skb);
+		write_lock(&neigh->lock);
+	}
+	skb_queue_purge(&neigh->arp_queue);
+}
+
 /* Called when a timer expires for a neighbour entry. */
 
 static void neigh_timer_handler(unsigned long arg)
@@ -835,26 +857,9 @@ static void neigh_timer_handler(unsigned long arg)
 
 	if ((neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) &&
 	    atomic_read(&neigh->probes) >= neigh_max_probes(neigh)) {
-		struct sk_buff *skb;
-
 		neigh->nud_state = NUD_FAILED;
-		neigh->updated = jiffies;
 		notify = 1;
-		NEIGH_CACHE_STAT_INC(neigh->tbl, res_failed);
-		NEIGH_PRINTK2("neigh %p is failed.\n", neigh);
-
-		/* It is very thin place. report_unreachable is very complicated
-		   routine. Particularly, it can hit the same neighbour entry!
-
-		   So that, we try to be accurate and avoid dead loop. --ANK
-		 */
-		while (neigh->nud_state == NUD_FAILED &&
-		       (skb = __skb_dequeue(&neigh->arp_queue)) != NULL) {
-			write_unlock(&neigh->lock);
-			neigh->ops->error_report(neigh, skb);
-			write_lock(&neigh->lock);
-		}
-		skb_queue_purge(&neigh->arp_queue);
+		neigh_invalidate(neigh);
 	}
 
 	if (neigh->nud_state & NUD_IN_TIMER) {
@@ -1001,6 +1006,11 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 		neigh->nud_state = new;
 		err = 0;
 		notify = old & NUD_VALID;
+		if ((old & (NUD_INCOMPLETE | NUD_PROBE)) &&
+		    (new & NUD_FAILED)) {
+			neigh_invalidate(neigh);
+			notify = 1;
+		}
 		goto out;
 	}
 
-- 
1.6.0.4

