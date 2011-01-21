From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4] ppp: Reconstruct fragmented packets using frag lists
 instead of copying.
Date: Thu, 20 Jan 2011 23:56:03 -0800 (PST)
Message-ID: <20110120.235603.141252552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750786Ab1AUHz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:55:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[paulus@samba.org: fixed a couple of bugs]

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Paul Mackerras <paulus@samba.org>
---
 drivers/net/ppp_generic.c |   39 +++++++++++++++++++++++----------------
 1 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 3d7a38e..1d4fb34 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -2055,16 +2055,6 @@ ppp_mp_reconstruct(struct ppp *ppp)
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
@@ -2097,16 +2087,33 @@ ppp_mp_reconstruct(struct ppp *ppp)
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
+			skb_queue_walk_from_safe(list, p, tmp) {
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
+		} else {
+			__skb_unlink(skb, list);
+		}
+
 		ppp->nextseq = PPP_MP_CB(tail)->sequence + 1;
 		head = tail->next;
 	}
 
-	/* Discard all the skbuffs that we have copied the data out of
-	   or that we can't use. */
+	/* Discard all the skbuffs that we can't use. */
 	while ((p = list->next) != head) {
 		__skb_unlink(p, list);
 		kfree_skb(p);
-- 
1.7.3.4

