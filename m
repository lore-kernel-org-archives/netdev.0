From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/9] rxrpc: Send pings to get RTT data
Date: Thu, 22 Sep 2016 01:39:36 +0100
Message-ID: <147450477672.14691.5320228451378851318.stgit@warthog.procyon.org.uk>
References: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Send a PING ACK packet to the peer when we get a new incoming call from a
peer we don't have a record for.  The PING RESPONSE ACK packet will tell us
the following about the peer:

 (1) its receive window size

 (2) its MTU sizes

 (3) its support for jumbo DATA packets

 (4) if it supports slow start (similar to RFC 5681)

 (5) an estimate of the RTT

This is necessary because the peer won't normally send us an ACK until it
gets to the Rx phase and we send it a packet, but we would like to know
some of this information before we start sending packets.

A pair of tracepoints are added so that RTT determination can be observed.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    7 +++++--
 net/rxrpc/input.c       |   48 ++++++++++++++++++++++++++++++++++++++++++++++-
 net/rxrpc/misc.c        |   11 ++++++-----
 net/rxrpc/output.c      |   22 ++++++++++++++++++++++
 4 files changed, 80 insertions(+), 8 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 79c671e552c3..8b47f468eb9d 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -403,6 +403,7 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_EXPOSED,		/* The call was exposed to the world */
 	RXRPC_CALL_RX_LAST,		/* Received the last packet (at rxtx_top) */
 	RXRPC_CALL_TX_LAST,		/* Last packet in Tx buffer (at rxtx_top) */
+	RXRPC_CALL_PINGING,		/* Ping in process */
 };
 
 /*
@@ -487,6 +488,8 @@ struct rxrpc_call {
 	u32			call_id;	/* call ID on connection  */
 	u32			cid;		/* connection ID plus channel index */
 	int			debug_id;	/* debug ID for printks */
+	unsigned short		rx_pkt_offset;	/* Current recvmsg packet offset */
+	unsigned short		rx_pkt_len;	/* Current recvmsg packet len */
 
 	/* Rx/Tx circular buffer, depending on phase.
 	 *
@@ -530,8 +533,8 @@ struct rxrpc_call {
 	u16			ackr_skew;	/* skew on packet being ACK'd */
 	rxrpc_serial_t		ackr_serial;	/* serial of packet being ACK'd */
 	rxrpc_seq_t		ackr_prev_seq;	/* previous sequence number received */
-	unsigned short		rx_pkt_offset;	/* Current recvmsg packet offset */
-	unsigned short		rx_pkt_len;	/* Current recvmsg packet len */
+	rxrpc_serial_t		ackr_ping;	/* Last ping sent */
+	ktime_t			ackr_ping_time;	/* Time last ping sent */
 
 	/* transmission-phase ACK management */
 	rxrpc_serial_t		acks_latest;	/* serial number of latest ACK received */
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index aa261df9fc9e..a0a5bd108c9e 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -37,6 +37,19 @@ static void rxrpc_proto_abort(const char *why,
 }
 
 /*
+ * Ping the other end to fill our RTT cache and to retrieve the rwind
+ * and MTU parameters.
+ */
+static void rxrpc_send_ping(struct rxrpc_call *call, struct sk_buff *skb,
+			    int skew)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	rxrpc_propose_ACK(call, RXRPC_ACK_PING, skew, sp->hdr.serial,
+			  true, true);
+}
+
+/*
  * Apply a hard ACK by advancing the Tx window.
  */
 static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
@@ -343,6 +356,32 @@ ack:
 }
 
 /*
+ * Process a ping response.
+ */
+static void rxrpc_input_ping_response(struct rxrpc_call *call,
+				      ktime_t resp_time,
+				      rxrpc_serial_t orig_serial,
+				      rxrpc_serial_t ack_serial)
+{
+	rxrpc_serial_t ping_serial;
+	ktime_t ping_time;
+
+	ping_time = call->ackr_ping_time;
+	smp_rmb();
+	ping_serial = call->ackr_ping;
+
+	if (!test_bit(RXRPC_CALL_PINGING, &call->flags) ||
+	    before(orig_serial, ping_serial))
+		return;
+	clear_bit(RXRPC_CALL_PINGING, &call->flags);
+	if (after(orig_serial, ping_serial))
+		return;
+
+	rxrpc_peer_add_rtt(call, rxrpc_rtt_rx_ping_response,
+			   orig_serial, ack_serial, ping_time, resp_time);
+}
+
+/*
  * Process the extra information that may be appended to an ACK packet
  */
 static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
@@ -438,6 +477,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 		struct rxrpc_ackinfo info;
 		u8 acks[RXRPC_MAXACKS];
 	} buf;
+	rxrpc_serial_t acked_serial;
 	rxrpc_seq_t first_soft_ack, hard_ack;
 	int nr_acks, offset;
 
@@ -449,6 +489,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	}
 	sp->offset += sizeof(buf.ack);
 
+	acked_serial = ntohl(buf.ack.serial);
 	first_soft_ack = ntohl(buf.ack.firstPacket);
 	hard_ack = first_soft_ack - 1;
 	nr_acks = buf.ack.nAcks;
@@ -460,10 +501,14 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	       ntohs(buf.ack.maxSkew),
 	       first_soft_ack,
 	       ntohl(buf.ack.previousPacket),
-	       ntohl(buf.ack.serial),
+	       acked_serial,
 	       rxrpc_acks(buf.ack.reason),
 	       buf.ack.nAcks);
 
+	if (buf.ack.reason == RXRPC_ACK_PING_RESPONSE)
+		rxrpc_input_ping_response(call, skb->tstamp, acked_serial,
+					  sp->hdr.serial);
+
 	if (buf.ack.reason == RXRPC_ACK_PING) {
 		_proto("Rx ACK %%%u PING Request", sp->hdr.serial);
 		rxrpc_propose_ACK(call, RXRPC_ACK_PING_RESPONSE,
@@ -830,6 +875,7 @@ void rxrpc_data_ready(struct sock *udp_sk)
 			rcu_read_unlock();
 			goto reject_packet;
 		}
+		rxrpc_send_ping(call, skb, skew);
 	}
 
 	rxrpc_input_call_packet(call, skb, skew);
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 6321c23f9a6e..56e668352fc7 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -83,11 +83,12 @@ const s8 rxrpc_ack_priority[] = {
 	[RXRPC_ACK_DELAY]		= 1,
 	[RXRPC_ACK_REQUESTED]		= 2,
 	[RXRPC_ACK_IDLE]		= 3,
-	[RXRPC_ACK_PING_RESPONSE]	= 4,
-	[RXRPC_ACK_DUPLICATE]		= 5,
-	[RXRPC_ACK_OUT_OF_SEQUENCE]	= 6,
-	[RXRPC_ACK_EXCEEDS_WINDOW]	= 7,
-	[RXRPC_ACK_NOSPACE]		= 8,
+	[RXRPC_ACK_DUPLICATE]		= 4,
+	[RXRPC_ACK_OUT_OF_SEQUENCE]	= 5,
+	[RXRPC_ACK_EXCEEDS_WINDOW]	= 6,
+	[RXRPC_ACK_NOSPACE]		= 7,
+	[RXRPC_ACK_PING_RESPONSE]	= 8,
+	[RXRPC_ACK_PING]		= 9,
 };
 
 const char *rxrpc_acks(u8 reason)
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 817fb0e82d6a..0d89cd3f2c01 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -57,6 +57,9 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	pkt->ack.reason		= call->ackr_reason;
 	pkt->ack.nAcks		= top - hard_ack;
 
+	if (pkt->ack.reason == RXRPC_ACK_PING)
+		pkt->whdr.flags |= RXRPC_REQUEST_ACK;
+
 	if (after(top, hard_ack)) {
 		seq = hard_ack + 1;
 		do {
@@ -97,6 +100,7 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	struct kvec iov[2];
 	rxrpc_serial_t serial;
 	size_t len, n;
+	bool ping = false;
 	int ioc, ret;
 	u32 abort_code;
 
@@ -147,6 +151,7 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 			ret = 0;
 			goto out;
 		}
+		ping = (call->ackr_reason == RXRPC_ACK_PING);
 		n = rxrpc_fill_out_ack(call, pkt);
 		call->ackr_reason = 0;
 
@@ -183,12 +188,29 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 		goto out;
 	}
 
+	if (ping) {
+		call->ackr_ping = serial;
+		smp_wmb();
+		/* We need to stick a time in before we send the packet in case
+		 * the reply gets back before kernel_sendmsg() completes - but
+		 * asking UDP to send the packet can take a relatively long
+		 * time, so we update the time after, on the assumption that
+		 * the packet transmission is more likely to happen towards the
+		 * end of the kernel_sendmsg() call.
+		 */
+		call->ackr_ping_time = ktime_get_real();
+		set_bit(RXRPC_CALL_PINGING, &call->flags);
+		trace_rxrpc_rtt_tx(call, rxrpc_rtt_tx_ping, serial);
+	}
 	ret = kernel_sendmsg(conn->params.local->socket,
 			     &msg, iov, ioc, len);
+	if (ping)
+		call->ackr_ping_time = ktime_get_real();
 
 	if (ret < 0 && call->state < RXRPC_CALL_COMPLETE) {
 		switch (type) {
 		case RXRPC_PACKET_TYPE_ACK:
+			clear_bit(RXRPC_CALL_PINGING, &call->flags);
 			rxrpc_propose_ACK(call, pkt->ack.reason,
 					  ntohs(pkt->ack.maxSkew),
 					  ntohl(pkt->ack.serial),
