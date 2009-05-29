From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/10]: irda: Use SKB queue and list helpers instead of
 doing it by-hand.
Date: Fri, 29 May 2009 01:40:25 -0700 (PDT)
Message-ID: <20090529.014025.223389403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56930
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757350AbZE2Ik0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/irlap_frame.c |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 2562ebc..7af2e74 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -982,17 +982,12 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 {
 	struct sk_buff *tx_skb;
 	struct sk_buff *skb;
-	int count;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	/* Initialize variables */
-	count = skb_queue_len(&self->wx_list);
-
 	/*  Resend unacknowledged frame(s) */
-	skb = skb_peek(&self->wx_list);
-	while (skb != NULL) {
+	skb_queue_walk(&self->wx_list, skb) {
 		irlap_wait_min_turn_around(self, &self->qos_tx);
 
 		/* We copy the skb to be retransmitted since we will have to
@@ -1011,21 +1006,12 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 		/*
 		 *  Set poll bit on the last frame retransmitted
 		 */
-		if (count-- == 1)
+		if (skb_queue_is_last(&self->wx_list, skb))
 			tx_skb->data[1] |= PF_BIT; /* Set p/f bit */
 		else
 			tx_skb->data[1] &= ~PF_BIT; /* Clear p/f bit */
 
 		irlap_send_i_frame(self, tx_skb, command);
-
-		/*
-		 *  If our skb is the last buffer in the list, then
-		 *  we are finished, if not, move to the next sk-buffer
-		 */
-		if (skb == skb_peek_tail(&self->wx_list))
-			skb = NULL;
-		else
-			skb = skb->next;
 	}
 #if 0 /* Not yet */
 	/*
-- 
1.6.3

