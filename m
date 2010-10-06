From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 4/4] ppp: Use SKB queue abstraction interfaces in
 fragment processing.
Date: Tue, 05 Oct 2010 19:52:37 -0700 (PDT)
Message-ID: <20101005.195237.112612472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758465Ab0JFCwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 22:52:15 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3E0CD24C087
	for <netdev@vger.kernel.org>; Tue,  5 Oct 2010 19:52:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No more direct references to SKB queue and list implementation
details.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ppp_generic.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index cd21a2c..d619293 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1997,7 +1997,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 	u32 seq = ppp->nextseq;
 	u32 minseq = ppp->minseq;
 	struct sk_buff_head *list = &ppp->mrq;
-	struct sk_buff *p, *next;
+	struct sk_buff *p, *tmp;
 	struct sk_buff *head, *tail;
 	struct sk_buff *skb = NULL;
 	int lost = 0, len = 0;
@@ -2006,14 +2006,15 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		return NULL;
 	head = list->next;
 	tail = NULL;
-	for (p = head; p != (struct sk_buff *) list; p = next) {
-		next = p->next;
+	skb_queue_walk_safe(list, p, tmp) {
+	again:
 		if (seq_before(PPP_MP_CB(p)->sequence, seq)) {
 			/* this can't happen, anyway ignore the skb */
 			netdev_err(ppp->dev, "ppp_mp_reconstruct bad "
 				   "seq %u < %u\n",
 				   PPP_MP_CB(p)->sequence, seq);
-			head = next;
+			__skb_unlink(p, list);
+			kfree_skb(p);
 			continue;
 		}
 		if (PPP_MP_CB(p)->sequence != seq) {
@@ -2025,8 +2026,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 			lost = 1;
 			seq = seq_before(minseq, PPP_MP_CB(p)->sequence)?
 				minseq + 1: PPP_MP_CB(p)->sequence;
-			next = p;
-			continue;
+			goto again;
 		}
 
 		/*
@@ -2066,9 +2066,17 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		 * and we haven't found a complete valid packet yet,
 		 * we can discard up to and including this fragment.
 		 */
-		if (PPP_MP_CB(p)->BEbits & E)
-			head = next;
+		if (PPP_MP_CB(p)->BEbits & E) {
+			struct sk_buff *tmp2;
 
+			skb_queue_reverse_walk_from_safe(list, p, tmp2) {
+				__skb_unlink(p, list);
+				kfree_skb(p);
+			}
+			head = skb_peek(list);
+			if (!head)
+				break;
+		}
 		++seq;
 	}
 
@@ -2107,13 +2115,6 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		}
 
 		ppp->nextseq = PPP_MP_CB(tail)->sequence + 1;
-		head = tail->next;
-	}
-
-	/* Discard all the skbuffs that we that we can't use. */
-	while ((p = list->next) != head) {
-		__skb_unlink(p, list);
-		kfree_skb(p);
 	}
 
 	return skb;
-- 
1.7.2.3

