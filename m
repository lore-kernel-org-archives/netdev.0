From: David Miller <davem@davemloft.net>
Subject: Re: IrDA woes..
Date: Thu, 02 Jan 2014 17:41:36 -0500 (EST)
Message-ID: <20140102.174136.1587468571877727139.davem@davemloft.net>
References: <20140102.034653.1968429090467668489.davem@davemloft.net>
	<CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
	<CA+55aFyFAaHgoTe_ZVs3F0Giy4qDndKsE6GbB4DgcaK7QkXOkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaABWli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:41:38 -0500
In-Reply-To: <CA+55aFyFAaHgoTe_ZVs3F0Giy4qDndKsE6GbB4DgcaK7QkXOkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 2 Jan 2014 13:07:05 -0800

> So I'd be inclined to take the queue lock (self->wx_list.lock) around
> that skb_queue_walk(). Or am I just dazed and confused?

Yes, something like the following untested patch.

I used irq blocking locking to be consistent with what the helpers
like skb_dequeue() use.  And you have to be careful to adjust code
to __skb_dequeue() that you put behind explicit taking of the lock.
skb_dequeue() is just a wrapper that take the lock around a call
to __skb_dequeue().

diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 005b424..1334625 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -698,19 +698,22 @@ int irlap_generate_rand_time_slot(int S, int s)
 void irlap_update_nr_received(struct irlap_cb *self, int nr)
 {
 	struct sk_buff *skb = NULL;
+	unsigned long flags;
 	int count = 0;
 
 	/*
 	 * Remove all the ack-ed frames from the window queue.
 	 */
 
+	spin_lock_irqsave(&self->wx_list.lock, flags);
+
 	/*
 	 *  Optimize for the common case. It is most likely that the receiver
 	 *  will acknowledge all the frames we have sent! So in that case we
 	 *  delete all frames stored in window.
 	 */
 	if (nr == self->vs) {
-		while ((skb = skb_dequeue(&self->wx_list)) != NULL) {
+		while ((skb = __skb_dequeue(&self->wx_list)) != NULL) {
 			dev_kfree_skb(skb);
 		}
 		/* The last acked frame is the next to send minus one */
@@ -720,7 +723,7 @@ void irlap_update_nr_received(struct irlap_cb *self, int nr)
 		while ((skb_peek(&self->wx_list) != NULL) &&
 		       (((self->va+1) % 8) != nr))
 		{
-			skb = skb_dequeue(&self->wx_list);
+			skb = __skb_dequeue(&self->wx_list);
 			dev_kfree_skb(skb);
 
 			self->va = (self->va + 1) % 8;
@@ -730,6 +733,8 @@ void irlap_update_nr_received(struct irlap_cb *self, int nr)
 
 	/* Advance window */
 	self->window = self->window_size - skb_queue_len(&self->wx_list);
+
+	spin_unlock_irqrestore(&self->wx_list.lock, flags);
 }
 
 /*
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 9ea0c93..45fd93f 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -983,10 +983,13 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 {
 	struct sk_buff *tx_skb;
 	struct sk_buff *skb;
+	unsigned long flags;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
+	spin_lock_irqsave(&self->wx_list.lock, flags);
+
 	/*  Resend unacknowledged frame(s) */
 	skb_queue_walk(&self->wx_list, skb) {
 		irlap_wait_min_turn_around(self, &self->qos_tx);
@@ -1039,16 +1042,20 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 		}
 	}
 #endif
+	spin_unlock_irqrestore(&self->wx_list.lock, flags);
 }
 
 void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 {
 	struct sk_buff *tx_skb;
+	unsigned long flags;
 	struct sk_buff *skb;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
+	spin_lock_irqsave(&self->wx_list.lock, flags);
+
 	/*  Resend unacknowledged frame(s) */
 	skb = skb_peek(&self->wx_list);
 	if (skb != NULL) {
@@ -1072,6 +1079,8 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 
 		irlap_send_i_frame(self, tx_skb, command);
 	}
+
+	spin_unlock_irqrestore(&self->wx_list.lock, flags);
 }
 
 /*
