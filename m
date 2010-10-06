From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 2/4] ppp: Reconstruct fragmented packets using frag
 lists instead of copying.
Date: Tue, 05 Oct 2010 19:52:27 -0700 (PDT)
Message-ID: <20101005.195227.104043991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758455Ab0JFCwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 22:52:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DF63024C087
	for <netdev@vger.kernel.org>; Tue,  5 Oct 2010 19:52:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ppp_generic.c |   37 +++++++++++++++++++++----------------
 1 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index ccfb297..cd21a2c 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -2054,16 +2054,6 @@ ppp_mp_reconstruct(struct ppp *ppp)
 				netdev_printk(KERN_DEBUG, ppp->dev,
 					      "PPP: reconstructed packet"
 					      " is too long (%d)\n", len);
-			} else if (p == head) {
-				/* fragment is complete packet - reuse skb */
-				tail = p;
-				skb = skb_get(p);
-				break;
-			} else if ((skb = dev_alloc_skb(len)) == NULL) {
-				++ppp->dev->stats.rx_missed_errors;
-				netdev_printk(KERN_DEBUG, ppp->dev,
-					      "PPP: no memory for "
-					      "reconstructed packet");
 			} else {
 				tail = p;
 				break;
@@ -2096,16 +2086,31 @@ ppp_mp_reconstruct(struct ppp *ppp)
 			ppp_receive_error(ppp);
 		}
 
-		if (head != tail)
-			/* copy to a single skb */
-			for (p = head; p != tail->next; p = p->next)
-				skb_copy_bits(p, 0, skb_put(skb, p->len), p->len);
+		skb = head;
+		if (head != tail) {
+			struct sk_buff **fragpp = &skb_shinfo(skb)->frag_list;
+			p = skb_queue_next(list, head);
+			__skb_unlink(skb, list);
+			skb_queue_walk_from(list, p) {
+				__skb_unlink(p, list);
+				*fragpp = p;
+				p->next = NULL;
+				fragpp = &p->next;
+
+				skb->len += p->len;
+				skb->data_len += p->len;
+				skb->truesize += p->len;
+
+				if (p == tail)
+					break;
+			}
+		}
+
 		ppp->nextseq = PPP_MP_CB(tail)->sequence + 1;
 		head = tail->next;
 	}
 
-	/* Discard all the skbuffs that we have copied the data out of
-	   or that we can't use. */
+	/* Discard all the skbuffs that we that we can't use. */
 	while ((p = list->next) != head) {
 		__skb_unlink(p, list);
 		kfree_skb(p);
-- 
1.7.2.3

