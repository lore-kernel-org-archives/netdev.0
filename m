From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rxrpc: split up rxrpc_send_call_packet()
Date: Fri, 30 Sep 2016 18:11:59 +0200
Message-ID: <20160930161218.4178124-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A number of reworks went into rxrpc_send_call_packet() recently, which
introduced another warning when built with -Wmaybe-uninitialized:

In file included from ../net/rxrpc/output.c:20:0:
net/rxrpc/output.c: In function 'rxrpc_send_call_packet':
net/rxrpc/ar-internal.h:1187:27: error: 'top' may be used uninitialized in this function [-Werror=maybe-uninitialized]
net/rxrpc/output.c:103:24: note: 'top' was declared here
net/rxrpc/output.c:225:25: error: 'hard_ack' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This is a false positive, but it's also an indication that the function is
getting complex enough that the compiler cannot figure out what it does.

This splits out a rxrpc_send_ack_packet() function for one part of
it, making it more understandable by both humans and the compiler
and avoiding the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Unfortunately, this is a larger rework that I was hoping for, and
I have only build tested it, so please review carefully, or just
discard it and treat it as feedback to the original patch.
---
 net/rxrpc/output.c | 164 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 88 insertions(+), 76 deletions(-)

diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index cf43a715685e..821af21c7159 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -90,6 +90,86 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	return top - hard_ack + 3;
 }
 
+static int rxrpc_send_ack_packet(struct rxrpc_call *call,
+				 struct rxrpc_connection *conn,
+				 struct msghdr *msg,
+				 struct rxrpc_pkt_buffer *pkt,
+				 struct kvec iov[2])
+{
+	bool ping;
+	size_t len, n;
+	rxrpc_serial_t serial;
+	rxrpc_seq_t hard_ack, top;
+	int ioc, ret;
+
+	spin_lock_bh(&call->lock);
+	if (!call->ackr_reason) {
+		spin_unlock_bh(&call->lock);
+		ret = 0;
+		goto out;
+	}
+	ping = (call->ackr_reason == RXRPC_ACK_PING);
+	n = rxrpc_fill_out_ack(call, pkt, &hard_ack, &top);
+	call->ackr_reason = 0;
+
+	spin_unlock_bh(&call->lock);
+
+	pkt->whdr.flags |= RXRPC_SLOW_START_OK;
+
+	iov[0].iov_len += sizeof(pkt->ack) + n;
+	iov[1].iov_base = &pkt->ackinfo;
+	iov[1].iov_len	= sizeof(pkt->ackinfo);
+	len = sizeof(pkt->whdr) + sizeof(pkt->ack) + n + sizeof(pkt->ackinfo);
+	ioc = 2;
+	serial = atomic_inc_return(&conn->serial);
+	pkt->whdr.serial = htonl(serial);
+
+	trace_rxrpc_tx_ack(call, serial,
+			   ntohl(pkt->ack.firstPacket),
+			   ntohl(pkt->ack.serial),
+			   pkt->ack.reason, pkt->ack.nAcks);
+
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
+	ret = kernel_sendmsg(conn->params.local->socket,
+			     msg, iov, ioc, len);
+	if (ping)
+		call->ackr_ping_time = ktime_get_real();
+
+	if (call->state < RXRPC_CALL_COMPLETE) {
+		if (ret < 0) {
+			clear_bit(RXRPC_CALL_PINGING, &call->flags);
+			rxrpc_propose_ACK(call, pkt->ack.reason,
+					  ntohs(pkt->ack.maxSkew),
+					  ntohl(pkt->ack.serial),
+					  true, true,
+					  rxrpc_propose_ack_retry_tx);
+		} else {
+			spin_lock_bh(&call->lock);
+			if (after(hard_ack, call->ackr_consumed))
+				call->ackr_consumed = hard_ack;
+			if (after(top, call->ackr_seen))
+				call->ackr_seen = top;
+			spin_unlock_bh(&call->lock);
+		}
+	}
+out:
+	return ret;
+}
+
+
 /*
  * Send an ACK or ABORT call packet.
  */
@@ -99,11 +179,9 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	struct rxrpc_pkt_buffer *pkt;
 	struct msghdr msg;
 	struct kvec iov[2];
-	rxrpc_serial_t serial;
-	rxrpc_seq_t hard_ack, top;
-	size_t len, n;
-	bool ping = false;
+	size_t len;
 	int ioc, ret;
+	rxrpc_serial_t serial;
 	u32 abort_code;
 
 	_enter("%u,%s", call->debug_id, rxrpc_pkts[type]);
@@ -140,96 +218,30 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 
 	iov[0].iov_base	= pkt;
 	iov[0].iov_len	= sizeof(pkt->whdr);
-	len = sizeof(pkt->whdr);
 
 	switch (type) {
 	case RXRPC_PACKET_TYPE_ACK:
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
-		spin_unlock_bh(&call->lock);
-
-
-		pkt->whdr.flags |= RXRPC_SLOW_START_OK;
-
-		iov[0].iov_len += sizeof(pkt->ack) + n;
-		iov[1].iov_base = &pkt->ackinfo;
-		iov[1].iov_len	= sizeof(pkt->ackinfo);
-		len += sizeof(pkt->ack) + n + sizeof(pkt->ackinfo);
-		ioc = 2;
+		ret = rxrpc_send_ack_packet(call, conn, &msg, pkt, iov);
 		break;
 
 	case RXRPC_PACKET_TYPE_ABORT:
 		abort_code = call->abort_code;
 		pkt->abort_code = htonl(abort_code);
 		iov[0].iov_len += sizeof(pkt->abort_code);
-		len += sizeof(pkt->abort_code);
+		len = sizeof(pkt->whdr) + sizeof(pkt->abort_code);
 		ioc = 1;
+		serial = atomic_inc_return(&conn->serial);
+		pkt->whdr.serial = htonl(serial);
+		ret = kernel_sendmsg(conn->params.local->socket,
+				     &msg, iov, ioc, len);
 		break;
 
 	default:
 		BUG();
 		ret = -ENOANO;
-		goto out;
-	}
-
-	serial = atomic_inc_return(&conn->serial);
-	pkt->whdr.serial = htonl(serial);
-	switch (type) {
-	case RXRPC_PACKET_TYPE_ACK:
-		trace_rxrpc_tx_ack(call, serial,
-				   ntohl(pkt->ack.firstPacket),
-				   ntohl(pkt->ack.serial),
-				   pkt->ack.reason, pkt->ack.nAcks);
 		break;
 	}
 
-	if (ping) {
-		call->ackr_ping = serial;
-		smp_wmb();
-		/* We need to stick a time in before we send the packet in case
-		 * the reply gets back before kernel_sendmsg() completes - but
-		 * asking UDP to send the packet can take a relatively long
-		 * time, so we update the time after, on the assumption that
-		 * the packet transmission is more likely to happen towards the
-		 * end of the kernel_sendmsg() call.
-		 */
-		call->ackr_ping_time = ktime_get_real();
-		set_bit(RXRPC_CALL_PINGING, &call->flags);
-		trace_rxrpc_rtt_tx(call, rxrpc_rtt_tx_ping, serial);
-	}
-	ret = kernel_sendmsg(conn->params.local->socket,
-			     &msg, iov, ioc, len);
-	if (ping)
-		call->ackr_ping_time = ktime_get_real();
-
-	if (type == RXRPC_PACKET_TYPE_ACK &&
-	    call->state < RXRPC_CALL_COMPLETE) {
-		if (ret < 0) {
-			clear_bit(RXRPC_CALL_PINGING, &call->flags);
-			rxrpc_propose_ACK(call, pkt->ack.reason,
-					  ntohs(pkt->ack.maxSkew),
-					  ntohl(pkt->ack.serial),
-					  true, true,
-					  rxrpc_propose_ack_retry_tx);
-		} else {
-			spin_lock_bh(&call->lock);
-			if (after(hard_ack, call->ackr_consumed))
-				call->ackr_consumed = hard_ack;
-			if (after(top, call->ackr_seen))
-				call->ackr_seen = top;
-			spin_unlock_bh(&call->lock);
-		}
-	}
-
-out:
 	rxrpc_put_connection(conn);
 	kfree(pkt);
 	return ret;
-- 
2.9.0
