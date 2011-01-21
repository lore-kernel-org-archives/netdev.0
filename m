From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4] ppp: Use SKB queue abstraction interfaces in fragment
 processing.
Date: Thu, 20 Jan 2011 23:56:09 -0800 (PST)
Message-ID: <20110120.235609.37588454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751387Ab1AUHze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:55:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No more direct references to SKB queue and list implementation
details.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ppp_generic.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 1d4fb34..9f6d670 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1998,7 +1998,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 	u32 seq = ppp->nextseq;
 	u32 minseq = ppp->minseq;
 	struct sk_buff_head *list = &ppp->mrq;
-	struct sk_buff *p, *next;
+	struct sk_buff *p, *tmp;
 	struct sk_buff *head, *tail;
 	struct sk_buff *skb = NULL;
 	int lost = 0, len = 0;
@@ -2007,14 +2007,15 @@ ppp_mp_reconstruct(struct ppp *ppp)
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
@@ -2026,8 +2027,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 			lost = 1;
 			seq = seq_before(minseq, PPP_MP_CB(p)->sequence)?
 				minseq + 1: PPP_MP_CB(p)->sequence;
-			next = p;
-			continue;
+			goto again;
 		}
 
 		/*
@@ -2067,9 +2067,17 @@ ppp_mp_reconstruct(struct ppp *ppp)
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
 
@@ -2110,13 +2118,6 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		}
 
 		ppp->nextseq = PPP_MP_CB(tail)->sequence + 1;
-		head = tail->next;
-	}
-
-	/* Discard all the skbuffs that we can't use. */
-	while ((p = list->next) != head) {
-		__skb_unlink(p, list);
-		kfree_skb(p);
 	}
 
 	return skb;
-- 
1.7.3.4

