From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: split up rxrpc_send_call_packet()
Date: Sat, 01 Oct 2016 00:52:40 +0100
Message-ID: <16139.1475279560@warthog.procyon.org.uk>
References: <12692.1475278509@warthog.procyon.org.uk> <20160930161218.4178124-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12692.1475278509@warthog.procyon.org.uk>
Content-ID: <16138.1475279560.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Something like the attached.

David
---
commit 35510eefc29e2757c1ac46218cded2e505093fc2
Author: David Howells <dhowells@redhat.com>
Date:   Sat Oct 1 00:35:15 2016 +0100

    rxrpc: Split rxrpc_send_call_packet()
    
    Split rxrpc_send_data_packet() to separate ACK generation (which is more
    complicated) from ABORT generation.  This simplifies the code a bit and
    avoids the following warning:
    
    In file included from ../net/rxrpc/output.c:20:0:
    net/rxrpc/output.c: In function 'rxrpc_send_call_packet':
    net/rxrpc/ar-internal.h:1187:27: error: 'top' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    net/rxrpc/output.c:103:24: note: 'top' was declared here
    net/rxrpc/output.c:225:25: error: 'hard_ack' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    
    Reported-by: Arnd Bergmann <arnd@arndb.de>
    Signed-off-by: David Howells <dhowells@redhat.com>

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index d38dffd78085..100748cb1f00 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -1068,7 +1068,8 @@ extern const s8 rxrpc_ack_priority[];
 /*
  * output.c
  */
-int rxrpc_send_call_packet(struct rxrpc_call *, u8);
+int rxrpc_send_ack_packet(struct rxrpc_call *);
+int rxrpc_send_abort_packet(struct rxrpc_call *);
 int rxrpc_send_data_packet(struct rxrpc_call *, struct sk_buff *, bool);
 void rxrpc_reject_packets(struct rxrpc_local *);
 
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 3cac231d8405..53981b8f8eb3 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -565,7 +565,7 @@ out_discard:
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
 	if (abort) {
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		rxrpc_send_abort_packet(call);
 		rxrpc_release_call(rx, call);
 		rxrpc_put_call(call, rxrpc_call_put);
 	}
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 4f00476630b9..e313099860d5 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -253,7 +253,7 @@ static void rxrpc_resend(struct rxrpc_call *call, ktime_t now)
 			goto out;
 		rxrpc_propose_ACK(call, RXRPC_ACK_PING, 0, 0, true, false,
 				  rxrpc_propose_ack_ping_for_lost_ack);
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+		rxrpc_send_ack_packet(call);
 		goto out;
 	}
 
@@ -328,7 +328,7 @@ void rxrpc_process_call(struct work_struct *work)
 
 recheck_state:
 	if (test_and_clear_bit(RXRPC_CALL_EV_ABORT, &call->events)) {
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		rxrpc_send_abort_packet(call);
 		goto recheck_state;
 	}
 
@@ -347,7 +347,7 @@ recheck_state:
 	if (test_and_clear_bit(RXRPC_CALL_EV_ACK, &call->events)) {
 		call->ack_at = call->expire_at;
 		if (call->ackr_reason) {
-			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+			rxrpc_send_ack_packet(call);
 			goto recheck_state;
 		}
 	}
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 364b42dc3dce..07094012ac15 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -498,7 +498,7 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 				  struct rxrpc_call, sock_link);
 		rxrpc_get_call(call, rxrpc_call_got);
 		rxrpc_abort_call("SKT", call, 0, RX_CALL_DEAD, ECONNRESET);
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		rxrpc_send_abort_packet(call);
 		rxrpc_release_call(rx, call);
 		rxrpc_put_call(call, rxrpc_call_put);
 	}
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 0d47db886f6e..2dae877c0876 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -19,24 +19,24 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-struct rxrpc_pkt_buffer {
+struct rxrpc_ack_buffer {
 	struct rxrpc_wire_header whdr;
-	union {
-		struct {
-			struct rxrpc_ackpacket ack;
-			u8 acks[255];
-			u8 pad[3];
-		};
-		__be32 abort_code;
-	};
+	struct rxrpc_ackpacket ack;
+	u8 acks[255];
+	u8 pad[3];
 	struct rxrpc_ackinfo ackinfo;
 };
 
+struct rxrpc_abort_buffer {
+	struct rxrpc_wire_header whdr;
+	__be32 abort_code;
+};
+
 /*
  * Fill out an ACK packet.
  */
 static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
-				 struct rxrpc_pkt_buffer *pkt,
+				 struct rxrpc_ack_buffer *pkt,
 				 rxrpc_seq_t *_hard_ack,
 				 rxrpc_seq_t *_top)
 {
@@ -91,22 +91,19 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 }
 
 /*
- * Send an ACK or ABORT call packet.
+ * Send an ACK call packet.
  */
-int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
+int rxrpc_send_ack_packet(struct rxrpc_call *call)
 {
 	struct rxrpc_connection *conn = NULL;
-	struct rxrpc_pkt_buffer *pkt;
+	struct rxrpc_ack_buffer *pkt;
 	struct msghdr msg;
 	struct kvec iov[2];
 	rxrpc_serial_t serial;
 	rxrpc_seq_t hard_ack, top;
 	size_t len, n;
 	bool ping = false;
-	int ioc, ret;
-	u32 abort_code;
-
-	_enter("%u,%s", call->debug_id, rxrpc_pkts[type]);
+	int ret;
 
 	spin_lock_bh(&call->lock);
 	if (call->conn)
@@ -131,65 +128,37 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	pkt->whdr.cid		= htonl(call->cid);
 	pkt->whdr.callNumber	= htonl(call->call_id);
 	pkt->whdr.seq		= 0;
-	pkt->whdr.type		= type;
-	pkt->whdr.flags		= conn->out_clientflag;
+	pkt->whdr.type		= RXRPC_PACKET_TYPE_ACK;
+	pkt->whdr.flags		= RXRPC_SLOW_START_OK | conn->out_clientflag;
 	pkt->whdr.userStatus	= 0;
 	pkt->whdr.securityIndex	= call->security_ix;
 	pkt->whdr._rsvd		= 0;
 	pkt->whdr.serviceId	= htons(call->service_id);
 
-	iov[0].iov_base	= pkt;
-	iov[0].iov_len	= sizeof(pkt->whdr);
-	len = sizeof(pkt->whdr);
-
-	switch (type) {
-	case RXRPC_PACKET_TYPE_ACK:
-		spin_lock_bh(&call->lock);
-		if (!call->ackr_reason) {
-			spin_unlock_bh(&call->lock);
-			ret = 0;
-			goto out;
-		}
-		ping = (call->ackr_reason == RXRPC_ACK_PING);
-		n = rxrpc_fill_out_ack(call, pkt, &hard_ack, &top);
-		call->ackr_reason = 0;
-
+	spin_lock_bh(&call->lock);
+	if (!call->ackr_reason) {
 		spin_unlock_bh(&call->lock);
-
-
-		pkt->whdr.flags |= RXRPC_SLOW_START_OK;
-
-		iov[0].iov_len += sizeof(pkt->ack) + n;
-		iov[1].iov_base = &pkt->ackinfo;
-		iov[1].iov_len	= sizeof(pkt->ackinfo);
-		len += sizeof(pkt->ack) + n + sizeof(pkt->ackinfo);
-		ioc = 2;
-		break;
-
-	case RXRPC_PACKET_TYPE_ABORT:
-		abort_code = call->abort_code;
-		pkt->abort_code = htonl(abort_code);
-		iov[0].iov_len += sizeof(pkt->abort_code);
-		len += sizeof(pkt->abort_code);
-		ioc = 1;
-		break;
-
-	default:
-		BUG();
-		ret = -ENOANO;
+		ret = 0;
 		goto out;
 	}
+	ping = (call->ackr_reason == RXRPC_ACK_PING);
+	n = rxrpc_fill_out_ack(call, pkt, &hard_ack, &top);
+	call->ackr_reason = 0;
+
+	spin_unlock_bh(&call->lock);
+
+	iov[0].iov_base	= pkt;
+	iov[0].iov_len	= sizeof(pkt->whdr) + sizeof(pkt->ack) + n;
+	iov[1].iov_base = &pkt->ackinfo;
+	iov[1].iov_len	= sizeof(pkt->ackinfo);
+	len = iov[0].iov_len + iov[1].iov_len;
 
 	serial = atomic_inc_return(&conn->serial);
 	pkt->whdr.serial = htonl(serial);
-	switch (type) {
-	case RXRPC_PACKET_TYPE_ACK:
-		trace_rxrpc_tx_ack(call, serial,
-				   ntohl(pkt->ack.firstPacket),
-				   ntohl(pkt->ack.serial),
-				   pkt->ack.reason, pkt->ack.nAcks);
-		break;
-	}
+	trace_rxrpc_tx_ack(call, serial,
+			   ntohl(pkt->ack.firstPacket),
+			   ntohl(pkt->ack.serial),
+			   pkt->ack.reason, pkt->ack.nAcks);
 
 	if (ping) {
 		call->ackr_ping = serial;
@@ -205,13 +174,12 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 		set_bit(RXRPC_CALL_PINGING, &call->flags);
 		trace_rxrpc_rtt_tx(call, rxrpc_rtt_tx_ping, serial);
 	}
-	ret = kernel_sendmsg(conn->params.local->socket,
-			     &msg, iov, ioc, len);
+
+	ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 2, len);
 	if (ping)
 		call->ackr_ping_time = ktime_get_real();
 
-	if (type == RXRPC_PACKET_TYPE_ACK &&
-	    call->state < RXRPC_CALL_COMPLETE) {
+	if (call->state < RXRPC_CALL_COMPLETE) {
 		if (ret < 0) {
 			clear_bit(RXRPC_CALL_PINGING, &call->flags);
 			rxrpc_propose_ACK(call, pkt->ack.reason,
@@ -236,6 +204,56 @@ out:
 }
 
 /*
+ * Send an ABORT call packet.
+ */
+int rxrpc_send_abort_packet(struct rxrpc_call *call)
+{
+	struct rxrpc_connection *conn = NULL;
+	struct rxrpc_abort_buffer pkt;
+	struct msghdr msg;
+	struct kvec iov[1];
+	rxrpc_serial_t serial;
+	int ret;
+
+	spin_lock_bh(&call->lock);
+	if (call->conn)
+		conn = rxrpc_get_connection_maybe(call->conn);
+	spin_unlock_bh(&call->lock);
+	if (!conn)
+		return -ECONNRESET;
+
+	msg.msg_name	= &call->peer->srx.transport;
+	msg.msg_namelen	= call->peer->srx.transport_len;
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	pkt.whdr.epoch		= htonl(conn->proto.epoch);
+	pkt.whdr.cid		= htonl(call->cid);
+	pkt.whdr.callNumber	= htonl(call->call_id);
+	pkt.whdr.seq		= 0;
+	pkt.whdr.type		= RXRPC_PACKET_TYPE_ABORT;
+	pkt.whdr.flags		= conn->out_clientflag;
+	pkt.whdr.userStatus	= 0;
+	pkt.whdr.securityIndex	= call->security_ix;
+	pkt.whdr._rsvd		= 0;
+	pkt.whdr.serviceId	= htons(call->service_id);
+	pkt.abort_code		= htonl(call->abort_code);
+
+	iov[0].iov_base	= &pkt;
+	iov[0].iov_len	= sizeof(pkt);
+
+	serial = atomic_inc_return(&conn->serial);
+	pkt.whdr.serial = htonl(serial);
+
+	ret = kernel_sendmsg(conn->params.local->socket,
+			     &msg, iov, 1, sizeof(pkt));
+
+	rxrpc_put_connection(conn);
+	return ret;
+}
+
+/*
  * send a packet through the transport endpoint
  */
 int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb,
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index f05ea0a88076..11723bc1c783 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -143,7 +143,7 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call, rxrpc_serial_t serial)
 	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
 		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, serial, true, false,
 				  rxrpc_propose_ack_terminal_ack);
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+		rxrpc_send_ack_packet(call);
 	}
 
 	write_lock_bh(&call->state_lock);
@@ -212,7 +212,7 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 					  true, false,
 					  rxrpc_propose_ack_rotate_rx);
 		if (call->ackr_reason)
-			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+			rxrpc_send_ack_packet(call);
 	}
 }
 
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 627abed5f999..4374e7b9c7bf 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -381,7 +381,7 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	return 0;
 
 protocol_error:
-	rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+	rxrpc_send_abort_packet(call);
 	_leave(" = -EPROTO");
 	return -EPROTO;
 
@@ -471,7 +471,7 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	return 0;
 
 protocol_error:
-	rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+	rxrpc_send_abort_packet(call);
 	_leave(" = -EPROTO");
 	return -EPROTO;
 
@@ -523,7 +523,7 @@ static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 
 	if (cksum != expected_cksum) {
 		rxrpc_abort_call("VCK", call, seq, RXKADSEALEDINCON, EPROTO);
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		rxrpc_send_abort_packet(call);
 		_leave(" = -EPROTO [csum failed]");
 		return -EPROTO;
 	}
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 3322543d460a..901b28ceeff4 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -197,7 +197,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 	do {
 		/* Check to see if there's a ping ACK to reply to. */
 		if (call->ackr_reason == RXRPC_ACK_PING_RESPONSE)
-			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+			rxrpc_send_ack_packet(call);
 
 		if (!skb) {
 			size_t size, chunk, max, space;
@@ -514,8 +514,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
 		ret = 0;
 		if (rxrpc_abort_call("CMD", call, 0, abort_code, ECONNABORTED))
-			ret = rxrpc_send_call_packet(call,
-						     RXRPC_PACKET_TYPE_ABORT);
+			ret = rxrpc_send_abort_packet(call);
 	} else if (cmd != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
 	} else if (rxrpc_is_client_call(call) &&
@@ -597,7 +596,7 @@ void rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
 	lock_sock(sock->sk);
 
 	if (rxrpc_abort_call(why, call, 0, abort_code, error))
-		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		rxrpc_send_abort_packet(call);
 
 	release_sock(sock->sk);
 	_leave("");
