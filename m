From: David Miller <davem@davemloft.net>
Subject: [PATCH] ppp: Use a real SKB control block in fragmentation engine.
Date: Tue, 05 Oct 2010 01:37:28 -0700 (PDT)
Message-ID: <20101005.013728.108772953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43227
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752673Ab0JEIhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 04:37:07 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E99D124C087
	for <netdev@vger.kernel.org>; Tue,  5 Oct 2010 01:37:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Do this instead of subverting fields in skb proper.

The macros that could very easily match variable or function
names were also just asking for trouble.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next-2.6

 drivers/net/ppp_generic.c |   46 ++++++++++++++++++++++++--------------------
 1 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 736b917..866e221 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1547,9 +1547,11 @@ ppp_channel_push(struct channel *pch)
  * Receive-side routines.
  */
 
-/* misuse a few fields of the skb for MP reconstruction */
-#define sequence	priority
-#define BEbits		cb[0]
+struct ppp_mp_skb_parm {
+	u32		sequence;
+	u8		BEbits;
+};
+#define PPP_MP_CB(skb)	((struct ppp_mp_skb_parm *)((skb)->cb))
 
 static inline void
 ppp_do_recv(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
@@ -1878,13 +1880,13 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 		seq = (skb->data[3] << 16) | (skb->data[4] << 8)| skb->data[5];
 		mask = 0xffffff;
 	}
-	skb->BEbits = skb->data[2];
+	PPP_MP_CB(skb)->BEbits = skb->data[2];
 	skb_pull(skb, mphdrlen);	/* pull off PPP and MP headers */
 
 	/*
 	 * Do protocol ID decompression on the first fragment of each packet.
 	 */
-	if ((skb->BEbits & B) && (skb->data[0] & 1))
+	if ((PPP_MP_CB(skb)->BEbits & B) && (skb->data[0] & 1))
 		*skb_push(skb, 1) = 0;
 
 	/*
@@ -1896,7 +1898,7 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 		seq += mask + 1;
 	else if ((int)(seq - ppp->minseq) > (int)(mask >> 1))
 		seq -= mask + 1;	/* should never happen */
-	skb->sequence = seq;
+	PPP_MP_CB(skb)->sequence = seq;
 	pch->lastseq = seq;
 
 	/*
@@ -1932,8 +1934,8 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 	   before the start of the queue. */
 	if (skb_queue_len(&ppp->mrq) >= PPP_MP_MAX_QLEN) {
 		struct sk_buff *mskb = skb_peek(&ppp->mrq);
-		if (seq_before(ppp->minseq, mskb->sequence))
-			ppp->minseq = mskb->sequence;
+		if (seq_before(ppp->minseq, PPP_MP_CB(mskb)->sequence))
+			ppp->minseq = PPP_MP_CB(mskb)->sequence;
 	}
 
 	/* Pull completed packets off the queue and receive them. */
@@ -1963,12 +1965,12 @@ ppp_mp_insert(struct ppp *ppp, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 	struct sk_buff_head *list = &ppp->mrq;
-	u32 seq = skb->sequence;
+	u32 seq = PPP_MP_CB(skb)->sequence;
 
 	/* N.B. we don't need to lock the list lock because we have the
 	   ppp unit receive-side lock. */
 	skb_queue_walk(list, p) {
-		if (seq_before(seq, p->sequence))
+		if (seq_before(seq, PPP_MP_CB(p)->sequence))
 			break;
 	}
 	__skb_queue_before(list, p, skb);
@@ -1997,22 +1999,22 @@ ppp_mp_reconstruct(struct ppp *ppp)
 	tail = NULL;
 	for (p = head; p != (struct sk_buff *) list; p = next) {
 		next = p->next;
-		if (seq_before(p->sequence, seq)) {
+		if (seq_before(PPP_MP_CB(p)->sequence, seq)) {
 			/* this can't happen, anyway ignore the skb */
 			printk(KERN_ERR "ppp_mp_reconstruct bad seq %u < %u\n",
-			       p->sequence, seq);
+			       PPP_MP_CB(p)->sequence, seq);
 			head = next;
 			continue;
 		}
-		if (p->sequence != seq) {
+		if (PPP_MP_CB(p)->sequence != seq) {
 			/* Fragment `seq' is missing.  If it is after
 			   minseq, it might arrive later, so stop here. */
 			if (seq_after(seq, minseq))
 				break;
 			/* Fragment `seq' is lost, keep going. */
 			lost = 1;
-			seq = seq_before(minseq, p->sequence)?
-				minseq + 1: p->sequence;
+			seq = seq_before(minseq, PPP_MP_CB(p)->sequence)?
+				minseq + 1: PPP_MP_CB(p)->sequence;
 			next = p;
 			continue;
 		}
@@ -2026,7 +2028,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		 */
 
 		/* B bit set indicates this fragment starts a packet */
-		if (p->BEbits & B) {
+		if (PPP_MP_CB(p)->BEbits & B) {
 			head = p;
 			lost = 0;
 			len = 0;
@@ -2035,7 +2037,8 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		len += p->len;
 
 		/* Got a complete packet yet? */
-		if (lost == 0 && (p->BEbits & E) && (head->BEbits & B)) {
+		if (lost == 0 && (PPP_MP_CB(p)->BEbits & E) &&
+		    (PPP_MP_CB(head)->BEbits & B)) {
 			if (len > ppp->mrru + 2) {
 				++ppp->dev->stats.rx_length_errors;
 				printk(KERN_DEBUG "PPP: reconstructed packet"
@@ -2061,7 +2064,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		 * and we haven't found a complete valid packet yet,
 		 * we can discard up to and including this fragment.
 		 */
-		if (p->BEbits & E)
+		if (PPP_MP_CB(p)->BEbits & E)
 			head = next;
 
 		++seq;
@@ -2071,10 +2074,11 @@ ppp_mp_reconstruct(struct ppp *ppp)
 	if (tail != NULL) {
 		/* If we have discarded any fragments,
 		   signal a receive error. */
-		if (head->sequence != ppp->nextseq) {
+		if (PPP_MP_CB(head)->sequence != ppp->nextseq) {
 			if (ppp->debug & 1)
 				printk(KERN_DEBUG "  missed pkts %u..%u\n",
-				       ppp->nextseq, head->sequence-1);
+				       ppp->nextseq,
+				       PPP_MP_CB(head)->sequence-1);
 			++ppp->dev->stats.rx_dropped;
 			ppp_receive_error(ppp);
 		}
@@ -2083,7 +2087,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 			/* copy to a single skb */
 			for (p = head; p != tail->next; p = p->next)
 				skb_copy_bits(p, 0, skb_put(skb, p->len), p->len);
-		ppp->nextseq = tail->sequence + 1;
+		ppp->nextseq = PPP_MP_CB(tail)->sequence + 1;
 		head = tail->next;
 	}
 
-- 
1.7.3.1

