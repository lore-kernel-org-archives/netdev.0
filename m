From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 12/14] rxrpc: use 32bit jiffies on 64bit platforms, too
Date: Mon,  2 Mar 2015 18:40:26 +0100
Message-ID: <1425318028-26531-13-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54120 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754708AbbCBRku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:50 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its enough for resend decision and reduces rxrpc private cb structure
by 8 bytes.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/rxrpc/ar-ack.c      | 72 +++++++++++++++++++++++++++++++------------------
 net/rxrpc/ar-internal.h |  4 +--
 net/rxrpc/ar-output.c   |  6 ++---
 3 files changed, 51 insertions(+), 31 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index e0547f5..f0602bc 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -63,6 +63,9 @@ unsigned rxrpc_rx_mtu = 5692;
  */
 unsigned rxrpc_rx_jumbo_max = 4;
 
+/* we use 32bit jiffies even on 64bit machines to save space in skb->cb */
+#define rxrpc_resend_time_stamp ((u32) jiffies)
+
 static const char *rxrpc_acks(u8 reason)
 {
 	static const char *const str[] = {
@@ -185,7 +188,7 @@ void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
  * set the resend timer
  */
 static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
-			     unsigned long resend_at)
+			     s32 resend_delta)
 {
 	read_lock_bh(&call->state_lock);
 	if (call->state >= RXRPC_CALL_COMPLETE)
@@ -199,7 +202,7 @@ static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
 	if (resend & 2) {
 		_debug("MODIFY RESEND TIMER");
 		set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-		mod_timer(&call->resend_timer, resend_at);
+		mod_timer(&call->resend_timer, jiffies + resend_delta);
 	} else {
 		_debug("KILL RESEND TIMER");
 		del_timer_sync(&call->resend_timer);
@@ -209,6 +212,11 @@ static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
 	read_unlock_bh(&call->state_lock);
 }
 
+static bool rxrpc_resend_needed(const struct rxrpc_skb_priv *sp)
+{
+	return ((s32)((rxrpc_resend_time_stamp) - (sp->resend_at)) >= 0);
+}
+
 /*
  * resend packets
  */
@@ -217,7 +225,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_header *hdr;
 	struct sk_buff *txb;
-	unsigned long *p_txb, resend_at;
+	unsigned long *p_txb;
+	s32 resend_at_delta;
 	bool stop;
 	int loop;
 	u8 resend;
@@ -229,12 +238,14 @@ static void rxrpc_resend(struct rxrpc_call *call)
 
 	stop = false;
 	resend = 0;
-	resend_at = 0;
+	resend_at_delta = 0;
 
 	for (loop = call->acks_tail;
 	     loop != call->acks_head || stop;
 	     loop = (loop + 1) &  (call->acks_winsz - 1)
 	     ) {
+		s32 resend_delta;
+
 		p_txb = call->acks_window + loop;
 		smp_read_barrier_depends();
 		if (*p_txb & 1)
@@ -243,6 +254,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		txb = (struct sk_buff *) *p_txb;
 		sp = rxrpc_skb(txb);
 
+		resend_delta = sp->resend_at - rxrpc_resend_time_stamp;
+
 		if (sp->need_resend) {
 			sp->need_resend = false;
 
@@ -257,26 +270,27 @@ static void rxrpc_resend(struct rxrpc_call *call)
 			       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
 			if (rxrpc_send_packet(call->conn->trans, txb) < 0) {
 				stop = true;
-				sp->resend_at = jiffies + 3;
+				resend_delta = 3;
 			} else {
-				sp->resend_at =
-					jiffies + rxrpc_resend_timeout;
+				resend_delta = rxrpc_resend_timeout;
+				sp->resend_at = rxrpc_resend_time_stamp +
+						  resend_delta;
 			}
 		}
 
-		if (time_after_eq(jiffies + 1, sp->resend_at)) {
+		if (rxrpc_resend_needed(sp)) {
 			sp->need_resend = true;
 			resend |= 1;
 		} else if (resend & 2) {
-			if (time_before(sp->resend_at, resend_at))
-				resend_at = sp->resend_at;
+			if (resend_delta < resend_at_delta)
+				resend_at_delta = resend_delta;
 		} else {
-			resend_at = sp->resend_at;
+			resend_at_delta = resend_delta;
 			resend |= 2;
 		}
 	}
 
-	rxrpc_set_resend(call, resend, resend_at);
+	rxrpc_set_resend(call, resend, resend_at_delta);
 	_leave("");
 }
 
@@ -287,7 +301,8 @@ static void rxrpc_resend_timer(struct rxrpc_call *call)
 {
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *txb;
-	unsigned long *p_txb, resend_at;
+	unsigned long *p_txb;
+	s32 resend_at_delta;
 	int loop;
 	u8 resend;
 
@@ -298,7 +313,7 @@ static void rxrpc_resend_timer(struct rxrpc_call *call)
 		return;
 
 	resend = 0;
-	resend_at = 0;
+	resend_at_delta = 0;
 
 	for (loop = call->acks_unacked;
 	     loop != call->acks_head;
@@ -313,19 +328,21 @@ static void rxrpc_resend_timer(struct rxrpc_call *call)
 
 		if (sp->need_resend) {
 			;
-		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
+		} else if (rxrpc_resend_needed(sp)) {
 			sp->need_resend = true;
 			resend |= 1;
 		} else if (resend & 2) {
-			if (time_before(sp->resend_at, resend_at))
-				resend_at = sp->resend_at;
+			s32 resend_delta = sp->resend_at - rxrpc_resend_time_stamp;
+
+			if (resend_delta < resend_at_delta)
+				resend_at_delta = resend_delta;
 		} else {
-			resend_at = sp->resend_at;
+			resend_at_delta = sp->resend_at - rxrpc_resend_time_stamp;
 			resend |= 2;
 		}
 	}
 
-	rxrpc_set_resend(call, resend, resend_at);
+	rxrpc_set_resend(call, resend, resend_at_delta);
 	_leave("");
 }
 
@@ -340,9 +357,10 @@ static int rxrpc_process_soft_ACKs(struct rxrpc_call *call,
 {
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *txb;
-	unsigned long *p_txb, resend_at;
+	unsigned long *p_txb;
 	int loop;
 	u8 sacks[RXRPC_MAXACKS], resend;
+	s32 resend_at_delta;
 
 	_enter("{%d,%d},{%d},",
 	       call->acks_hard,
@@ -353,7 +371,7 @@ static int rxrpc_process_soft_ACKs(struct rxrpc_call *call,
 		goto protocol_error;
 
 	resend = 0;
-	resend_at = 0;
+	resend_at_delta = 0;
 	for (loop = 0; loop < ack->nAcks; loop++) {
 		p_txb = call->acks_window;
 		p_txb += (call->acks_tail + loop) & (call->acks_winsz - 1);
@@ -398,19 +416,21 @@ static int rxrpc_process_soft_ACKs(struct rxrpc_call *call,
 			resend |= 1;
 		} else if (sp->need_resend) {
 			;
-		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
+		} else if (rxrpc_resend_needed(sp)) {
 			sp->need_resend = true;
 			resend |= 1;
 		} else if (resend & 2) {
-			if (time_before(sp->resend_at, resend_at))
-				resend_at = sp->resend_at;
+			s32 resend_delta = sp->resend_at - rxrpc_resend_time_stamp;
+
+			if (resend_delta < resend_at_delta)
+				resend_at_delta = resend_delta;
 		} else {
-			resend_at = sp->resend_at;
+			resend_at_delta = sp->resend_at - rxrpc_resend_time_stamp;
 			resend |= 2;
 		}
 	}
 
-	rxrpc_set_resend(call, resend, resend_at);
+	rxrpc_set_resend(call, resend, resend_at_delta);
 	_leave(" = 0");
 	return 0;
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ba9fd36..81d1949 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -81,7 +81,7 @@ struct rxrpc_sock {
  */
 struct rxrpc_skb_priv {
 	struct rxrpc_call	*call;		/* call with which associated */
-	unsigned long		resend_at;	/* time in jiffies at which to resend */
+	u32			resend_at;	/* time at which to resend (32 bit jiffies) */
 	union {
 		unsigned int	offset;		/* offset into buffer of next read */
 		int		remain;		/* amount of space remaining for next write */
@@ -90,7 +90,7 @@ struct rxrpc_skb_priv {
 	};
 
 	struct rxrpc_header	hdr;		/* RxRPC packet header from this packet */
-};
+} __packed;
 
 #define rxrpc_skb(__skb) ((struct rxrpc_skb_priv *) &(__skb)->cb)
 
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 8331c95..f04e89a 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -486,11 +486,11 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	_proto("Tx DATA %%%u { #%u }",
 	       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
 
-	sp->need_resend = false;
-	sp->resend_at = jiffies + rxrpc_resend_timeout;
+	sp->resend_at = (u32) jiffies;
+	sp->resend_at += rxrpc_resend_timeout;
 	if (!test_and_set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags)) {
 		_debug("run timer");
-		call->resend_timer.expires = sp->resend_at;
+		call->resend_timer.expires = jiffies + rxrpc_resend_timeout;
 		add_timer(&call->resend_timer);
 	}
 
-- 
2.0.5
