From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/8] rxrpc: Send an ACK after every few DATA
 packets we receive
Date: Sun, 25 Sep 2016 00:25:03 +0100
Message-ID: <147475950367.15231.16561667444841385772.stgit@warthog.procyon.org.uk>
References: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52964 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934946AbcIXXZG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Sep 2016 19:25:06 -0400
In-Reply-To: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send an ACK if we haven't sent one for the last two packets we've received.
This keeps the other end apprised of where we've got to - which is
important if they're doing slow-start.

We do this in recvmsg so that we can dispatch a packet directly without the
need to wake up the background thread.

This should possibly be made configurable in future.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    3 +++
 net/rxrpc/misc.c        |    1 +
 net/rxrpc/output.c      |   25 +++++++++++++++++--------
 net/rxrpc/recvmsg.c     |   13 ++++++++++++-
 4 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 042dbcc52654..e3bf9c0e3ad1 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -533,6 +533,8 @@ struct rxrpc_call {
 	u16			ackr_skew;	/* skew on packet being ACK'd */
 	rxrpc_serial_t		ackr_serial;	/* serial of packet being ACK'd */
 	rxrpc_seq_t		ackr_prev_seq;	/* previous sequence number received */
+	rxrpc_seq_t		ackr_consumed;	/* Highest packet shown consumed */
+	rxrpc_seq_t		ackr_seen;	/* Highest packet shown seen */
 	rxrpc_serial_t		ackr_ping;	/* Last ping sent */
 	ktime_t			ackr_ping_time;	/* Time last ping sent */
 
@@ -695,6 +697,7 @@ enum rxrpc_propose_ack_trace {
 	rxrpc_propose_ack_respond_to_ack,
 	rxrpc_propose_ack_respond_to_ping,
 	rxrpc_propose_ack_retry_tx,
+	rxrpc_propose_ack_rotate_rx,
 	rxrpc_propose_ack_terminal_ack,
 	rxrpc_propose_ack__nr_trace
 };
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 1ca14835d87f..a473fd7dabaa 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -202,6 +202,7 @@ const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8] = {
 	[rxrpc_propose_ack_respond_to_ack]	= "Rsp2Ack",
 	[rxrpc_propose_ack_respond_to_ping]	= "Rsp2Png",
 	[rxrpc_propose_ack_retry_tx]		= "RetryTx",
+	[rxrpc_propose_ack_rotate_rx]		= "RxAck  ",
 	[rxrpc_propose_ack_terminal_ack]	= "ClTerm ",
 };
 
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 0c563e325c9d..3eb01445e814 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -36,7 +36,9 @@ struct rxrpc_pkt_buffer {
  * Fill out an ACK packet.
  */
 static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
-				 struct rxrpc_pkt_buffer *pkt)
+				 struct rxrpc_pkt_buffer *pkt,
+				 rxrpc_seq_t *_hard_ack,
+				 rxrpc_seq_t *_top)
 {
 	rxrpc_serial_t serial;
 	rxrpc_seq_t hard_ack, top, seq;
@@ -48,6 +50,8 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	serial = call->ackr_serial;
 	hard_ack = READ_ONCE(call->rx_hard_ack);
 	top = smp_load_acquire(&call->rx_top);
+	*_hard_ack = hard_ack;
+	*_top = top;
 
 	pkt->ack.bufferSpace	= htons(8);
 	pkt->ack.maxSkew	= htons(call->ackr_skew);
@@ -96,6 +100,7 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	struct msghdr msg;
 	struct kvec iov[2];
 	rxrpc_serial_t serial;
+	rxrpc_seq_t hard_ack, top;
 	size_t len, n;
 	bool ping = false;
 	int ioc, ret;
@@ -146,7 +151,7 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 			goto out;
 		}
 		ping = (call->ackr_reason == RXRPC_ACK_PING);
-		n = rxrpc_fill_out_ack(call, pkt);
+		n = rxrpc_fill_out_ack(call, pkt, &hard_ack, &top);
 		call->ackr_reason = 0;
 
 		spin_unlock_bh(&call->lock);
@@ -203,18 +208,22 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	if (ping)
 		call->ackr_ping_time = ktime_get_real();
 
-	if (ret < 0 && call->state < RXRPC_CALL_COMPLETE) {
-		switch (type) {
-		case RXRPC_PACKET_TYPE_ACK:
+	if (type == RXRPC_PACKET_TYPE_ACK &&
+	    call->state < RXRPC_CALL_COMPLETE) {
+		if (ret < 0) {
 			clear_bit(RXRPC_CALL_PINGING, &call->flags);
 			rxrpc_propose_ACK(call, pkt->ack.reason,
 					  ntohs(pkt->ack.maxSkew),
 					  ntohl(pkt->ack.serial),
 					  true, true,
 					  rxrpc_propose_ack_retry_tx);
-			break;
-		case RXRPC_PACKET_TYPE_ABORT:
-			break;
+		} else {
+			spin_lock_bh(&call->lock);
+			if (after(hard_ack, call->ackr_consumed))
+				call->ackr_consumed = hard_ack;
+			if (after(top, call->ackr_seen))
+				call->ackr_seen = top;
+			spin_unlock_bh(&call->lock);
 		}
 	}
 
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 8c7f3de45bac..a7458c398b9e 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -201,8 +201,19 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 
 	_debug("%u,%u,%02x", hard_ack, top, flags);
 	trace_rxrpc_receive(call, rxrpc_receive_rotate, serial, hard_ack);
-	if (flags & RXRPC_LAST_PACKET)
+	if (flags & RXRPC_LAST_PACKET) {
 		rxrpc_end_rx_phase(call);
+	} else {
+		/* Check to see if there's an ACK that needs sending. */
+		if (after_eq(hard_ack, call->ackr_consumed + 2) ||
+		    after_eq(top, call->ackr_seen + 2) ||
+		    (hard_ack == top && after(hard_ack, call->ackr_consumed)))
+			rxrpc_propose_ACK(call, RXRPC_ACK_DELAY, 0, serial,
+					  true, false,
+					  rxrpc_propose_ack_rotate_rx);
+		if (call->ackr_reason)
+			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+	}
 }
 
 /*
