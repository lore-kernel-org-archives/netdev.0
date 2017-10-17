From: David Howells <dhowells@redhat.com>
Subject: [RFC] Can I use MSG_WAITALL with sendmsg() for AF_RXRPC?
Date: Tue, 17 Oct 2017 15:55:07 +0100
Message-ID: <14816.1508252107@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58904 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753794AbdJQOzI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 10:55:08 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 971334E334
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 14:55:08 +0000 (UTC)
Content-ID: <14815.1508252107.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can I MSG_WAITALL with sendmsg() when sending data through an AF_RXRPC socket
to say:

	Ignore signals until all the given data is queued, provided that
	progress is reasonably made.

where "progress" is defined as:

	Within a 2*RTT timeout since the last time we checked, at least one
	DATA packet has been consumed on the other side.

Note that consumption by the other side doesn't guarantee space in the Tx
queue on this side if the other side shrinks its Rx window on us.

Or should I use a sockopt or sendmsg cmsg for this?

(Example change attached)

Thanks,
David
---
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 9ea6f972767e..2d9edc656ca3 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -38,12 +38,86 @@ struct rxrpc_send_params {
 };
 
 /*
+ * Wait for space to appear in the Tx queue or a signal to occur.
+ */
+static int rxrpc_wait_for_tx_window_intr(struct rxrpc_sock *rx,
+					 struct rxrpc_call *call,
+					 long *timeo)
+{
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (call->tx_top - call->tx_hard_ack <
+		    min_t(unsigned int, call->tx_winsize,
+			  call->cong_cwnd + call->cong_extra))
+			return 0;
+
+		if (call->state >= RXRPC_CALL_COMPLETE)
+			return call->error;
+
+		if (signal_pending(current))
+			return sock_intr_errno(*timeo);
+
+		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
+		mutex_unlock(&call->user_mutex);
+		*timeo = schedule_timeout(*timeo);
+		if (mutex_lock_interruptible(&call->user_mutex) < 0)
+			return sock_intr_errno(*timeo);
+	}
+}
+
+/*
+ * Wait for space to appear in the Tx queue uninterruptibly, but with
+ * a timeout of 2*RTT if no progress was made and a signal occurred.
+ */
+static int rxrpc_wait_for_tx_window_nonintr(struct rxrpc_sock *rx,
+					    struct rxrpc_call *call)
+{
+	rxrpc_seq_t tx_start, tx_win;
+	signed long rtt2, timeout;
+	u64 rtt;
+
+	rtt = READ_ONCE(call->peer->rtt);
+	rtt2 = nsecs_to_jiffies64(rtt) * 2;
+	if (rtt2 < 1)
+		rtt2 = 1;
+
+	timeout = rtt2;
+	tx_start = READ_ONCE(call->tx_hard_ack);
+
+	for (;;) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+
+		tx_win = READ_ONCE(call->tx_hard_ack);
+		if (call->tx_top - tx_win <
+		    min_t(unsigned int, call->tx_winsize,
+			  call->cong_cwnd + call->cong_extra))
+			return 0;
+
+		if (call->state >= RXRPC_CALL_COMPLETE)
+			return call->error;
+
+		if (timeout == 0 &&
+		    tx_win == tx_start && signal_pending(current))
+			return -EINTR;
+
+		if (tx_win != tx_start) {
+			timeout = rtt2;
+			tx_start = tx_win;
+		}
+
+		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
+		timeout = schedule_timeout(timeout);
+	}
+}
+
+/*
  * wait for space to appear in the transmit/ACK window
  * - caller holds the socket locked
  */
 static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 				    struct rxrpc_call *call,
-				    long *timeo)
+				    long *timeo,
+				    bool waitall)
 {
 	DECLARE_WAITQUEUE(myself, current);
 	int ret;
@@ -53,30 +127,10 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 
 	add_wait_queue(&call->waitq, &myself);
 
-	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		ret = 0;
-		if (call->tx_top - call->tx_hard_ack <
-		    min_t(unsigned int, call->tx_winsize,
-			  call->cong_cwnd + call->cong_extra))
-			break;
-		if (call->state >= RXRPC_CALL_COMPLETE) {
-			ret = call->error;
-			break;
-		}
-		if (signal_pending(current)) {
-			ret = sock_intr_errno(*timeo);
-			break;
-		}
-
-		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
-		mutex_unlock(&call->user_mutex);
-		*timeo = schedule_timeout(*timeo);
-		if (mutex_lock_interruptible(&call->user_mutex) < 0) {
-			ret = sock_intr_errno(*timeo);
-			break;
-		}
-	}
+	if (waitall)
+		ret = rxrpc_wait_for_tx_window_nonintr(rx, call);
+	else
+		ret = rxrpc_wait_for_tx_window_intr(rx, call, timeo);
 
 	remove_wait_queue(&call->waitq, &myself);
 	set_current_state(TASK_RUNNING);
@@ -254,7 +308,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 				if (msg->msg_flags & MSG_DONTWAIT)
 					goto maybe_error;
 				ret = rxrpc_wait_for_tx_window(rx, call,
-							       &timeo);
+							       &timeo,
+							       msg->msg_flags & MSG_WAITALL);
 				if (ret < 0)
 					goto maybe_error;
 			}
