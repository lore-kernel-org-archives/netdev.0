From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 10/15] rxrpc: Don't call the tx_ack tracepoint if
 don't generate an ACK
Date: Fri, 23 Sep 2016 16:16:26 +0100
Message-ID: <147464378666.5090.4944064082431252846.stgit@warthog.procyon.org.uk>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1035300AbcIWPQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 11:16:28 -0400
In-Reply-To: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rxrpc_send_call_packet() is invoking the tx_ack tracepoint before it checks
whether there's an ACK to transmit (another thread may jump in and transmit
it).

Fix this by only invoking the tracepoint if we get a valid ACK to transmit.

Further, only allocate a serial number if we're going to actually transmit
something.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/output.c |   26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 282cb1e36d06..5c1e008a5323 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -80,9 +80,6 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	pkt->ackinfo.rwind	= htonl(call->rx_winsize);
 	pkt->ackinfo.jumbo_max	= htonl(jmax);
 
-	trace_rxrpc_tx_ack(call, hard_ack + 1, serial, call->ackr_reason,
-			   top - hard_ack);
-
 	*ackp++ = 0;
 	*ackp++ = 0;
 	*ackp++ = 0;
@@ -119,8 +116,6 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 		return -ENOMEM;
 	}
 
-	serial = atomic_inc_return(&conn->serial);
-
 	msg.msg_name	= &call->peer->srx.transport;
 	msg.msg_namelen	= call->peer->srx.transport_len;
 	msg.msg_control	= NULL;
@@ -131,7 +126,6 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	pkt->whdr.cid		= htonl(call->cid);
 	pkt->whdr.callNumber	= htonl(call->call_id);
 	pkt->whdr.seq		= 0;
-	pkt->whdr.serial	= htonl(serial);
 	pkt->whdr.type		= type;
 	pkt->whdr.flags		= conn->out_clientflag;
 	pkt->whdr.userStatus	= 0;
@@ -157,14 +151,6 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 
 		spin_unlock_bh(&call->lock);
 
-		_proto("Tx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
-		       serial,
-		       ntohs(pkt->ack.maxSkew),
-		       ntohl(pkt->ack.firstPacket),
-		       ntohl(pkt->ack.previousPacket),
-		       ntohl(pkt->ack.serial),
-		       rxrpc_acks(pkt->ack.reason),
-		       pkt->ack.nAcks);
 
 		iov[0].iov_len += sizeof(pkt->ack) + n;
 		iov[1].iov_base = &pkt->ackinfo;
@@ -176,7 +162,6 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	case RXRPC_PACKET_TYPE_ABORT:
 		abort_code = call->abort_code;
 		pkt->abort_code = htonl(abort_code);
-		_proto("Tx ABORT %%%u { %d }", serial, abort_code);
 		iov[0].iov_len += sizeof(pkt->abort_code);
 		len += sizeof(pkt->abort_code);
 		ioc = 1;
@@ -188,6 +173,17 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 		goto out;
 	}
 
+	serial = atomic_inc_return(&conn->serial);
+	pkt->whdr.serial = htonl(serial);
+	switch (type) {
+	case RXRPC_PACKET_TYPE_ACK:
+		trace_rxrpc_tx_ack(call,
+				   ntohl(pkt->ack.firstPacket),
+				   ntohl(pkt->ack.serial),
+				   pkt->ack.reason, pkt->ack.nAcks);
+		break;
+	}
+
 	if (ping) {
 		call->ackr_ping = serial;
 		smp_wmb();
