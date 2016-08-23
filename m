From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/3] rxrpc: Perform terminal call ACK/ABORT
 retransmission from conn processor
Date: Tue, 23 Aug 2016 16:29:15 +0100
Message-ID: <147196615495.28436.11361561249625178448.stgit@warthog.procyon.org.uk>
References: <147196613431.28436.14522158196410989643.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147196613431.28436.14522158196410989643.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Perform terminal call ACK/ABORT retransmission in the connection processor
rather than in the call processor.  With this change, once last_call is
set, no more incoming packets will be routed to the corresponding call or
any earlier calls on that channel (call IDs must only increase on a channel
on a connection).

Further, if a packet's callNumber is before the last_call ID or a packet is
aimed at successfully completed service call then that packet is discarded
and ignored.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    7 ++-
 net/rxrpc/conn_event.c  |  113 +++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/conn_object.c |   10 ++++
 net/rxrpc/input.c       |   31 ++++++++++++-
 4 files changed, 157 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index c779b50135f6..7296039c537a 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -295,7 +295,12 @@ struct rxrpc_connection {
 		u32			call_id;	/* ID of current call */
 		u32			call_counter;	/* Call ID counter */
 		u32			last_call;	/* ID of last call */
-		u32			last_result;	/* Result of last call (0/abort) */
+		u8			last_type;	/* Type of last packet */
+		u16			last_service_id;
+		union {
+			u32		last_seq;
+			u32		last_abort;
+		};
 	} channels[RXRPC_MAXCALLS];
 	wait_queue_head_t	channel_wq;	/* queue to wait for channel to become available */
 
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index c631d926f4db..c1c6b7f305d1 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -25,6 +25,113 @@
 #include "ar-internal.h"
 
 /*
+ * Retransmit terminal ACK or ABORT of the previous call.
+ */
+static void rxrpc_conn_retransmit(struct rxrpc_connection *conn,
+				  struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rxrpc_channel *chan;
+	struct msghdr msg;
+	struct kvec iov;
+	struct {
+		struct rxrpc_wire_header whdr;
+		union {
+			struct {
+				__be32 code;
+			} abort;
+			struct {
+				struct rxrpc_ackpacket ack;
+				struct rxrpc_ackinfo info;
+			};
+		};
+	} __attribute__((packed)) pkt;
+	size_t len;
+	u32 serial, mtu, call_id;
+
+	_enter("%d", conn->debug_id);
+
+	chan = &conn->channels[sp->hdr.cid & RXRPC_CHANNELMASK];
+
+	/* If the last call got moved on whilst we were waiting to run, just
+	 * ignore this packet.
+	 */
+	call_id = READ_ONCE(chan->last_call);
+	/* Sync with __rxrpc_disconnect_call() */
+	smp_rmb();
+	if (call_id != sp->hdr.callNumber)
+		return;
+
+	msg.msg_name	= &conn->params.peer->srx.transport;
+	msg.msg_namelen	= conn->params.peer->srx.transport_len;
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	pkt.whdr.epoch		= htonl(sp->hdr.epoch);
+	pkt.whdr.cid		= htonl(sp->hdr.cid);
+	pkt.whdr.callNumber	= htonl(sp->hdr.callNumber);
+	pkt.whdr.seq		= 0;
+	pkt.whdr.type		= chan->last_type;
+	pkt.whdr.flags		= conn->out_clientflag;
+	pkt.whdr.userStatus	= 0;
+	pkt.whdr.securityIndex	= conn->security_ix;
+	pkt.whdr._rsvd		= 0;
+	pkt.whdr.serviceId	= htons(chan->last_service_id);
+
+	len = sizeof(pkt.whdr);
+	switch (chan->last_type) {
+	case RXRPC_PACKET_TYPE_ABORT:
+		pkt.abort.code	= htonl(chan->last_abort);
+		len += sizeof(pkt.abort);
+		break;
+
+	case RXRPC_PACKET_TYPE_ACK:
+		mtu = conn->params.peer->if_mtu;
+		mtu -= conn->params.peer->hdrsize;
+		pkt.ack.bufferSpace	= 0;
+		pkt.ack.maxSkew		= htons(skb->priority);
+		pkt.ack.firstPacket	= htonl(chan->last_seq);
+		pkt.ack.previousPacket	= htonl(chan->last_seq - 1);
+		pkt.ack.serial		= htonl(sp->hdr.serial);
+		pkt.ack.reason		= RXRPC_ACK_DUPLICATE;
+		pkt.ack.nAcks		= 0;
+		pkt.info.rxMTU		= htonl(rxrpc_rx_mtu);
+		pkt.info.maxMTU		= htonl(mtu);
+		pkt.info.rwind		= htonl(rxrpc_rx_window_size);
+		pkt.info.jumbo_max	= htonl(rxrpc_rx_jumbo_max);
+		len += sizeof(pkt.ack) + sizeof(pkt.info);
+		break;
+	}
+
+	/* Resync with __rxrpc_disconnect_call() and check that the last call
+	 * didn't get advanced whilst we were filling out the packets.
+	 */
+	smp_rmb();
+	if (READ_ONCE(chan->last_call) != call_id)
+		return;
+
+	iov.iov_base	= &pkt;
+	iov.iov_len	= len;
+
+	serial = atomic_inc_return(&conn->serial);
+	pkt.whdr.serial = htonl(serial);
+
+	switch (chan->last_type) {
+	case RXRPC_PACKET_TYPE_ABORT:
+		_proto("Tx ABORT %%%u { %d } [re]", serial, conn->local_abort);
+		break;
+	case RXRPC_PACKET_TYPE_ACK:
+		_proto("Tx ACK %%%u [re]", serial);
+		break;
+	}
+
+	kernel_sendmsg(conn->params.local->socket, &msg, &iov, 1, len);
+	_leave("");
+	return;
+}
+
+/*
  * pass a connection-level abort onto all calls on that connection
  */
 static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
@@ -166,6 +273,12 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 	_enter("{%d},{%u,%%%u},", conn->debug_id, sp->hdr.type, sp->hdr.serial);
 
 	switch (sp->hdr.type) {
+	case RXRPC_PACKET_TYPE_DATA:
+	case RXRPC_PACKET_TYPE_ACK:
+		rxrpc_conn_retransmit(conn, skb);
+		rxrpc_free_skb(skb);
+		return 0;
+
 	case RXRPC_PACKET_TYPE_ABORT:
 		if (skb_copy_bits(skb, 0, &wtmp, sizeof(wtmp)) < 0)
 			return -EPROTO;
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 743f0bb4aaa8..b4af37ebb112 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -166,7 +166,15 @@ void __rxrpc_disconnect_call(struct rxrpc_call *call)
 		/* Save the result of the call so that we can repeat it if necessary
 		 * through the channel, whilst disposing of the actual call record.
 		 */
-		chan->last_result = call->local_abort;
+		chan->last_service_id = call->service_id;
+		if (call->local_abort) {
+			chan->last_abort = call->local_abort;
+			chan->last_type = RXRPC_PACKET_TYPE_ABORT;
+		} else {
+			chan->last_seq = call->rx_data_eaten;
+			chan->last_type = RXRPC_PACKET_TYPE_ACK;
+		}
+		/* Sync with rxrpc_conn_retransmit(). */
 		smp_wmb();
 		chan->last_call = chan->call_id;
 		chan->call_id = chan->call_counter;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 34f7431bf494..66cdeb56f44f 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -566,7 +566,8 @@ done:
 
 /*
  * post connection-level events to the connection
- * - this includes challenges, responses and some aborts
+ * - this includes challenges, responses, some aborts and call terminal packet
+ *   retransmission.
  */
 static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 				      struct sk_buff *skb)
@@ -716,18 +717,44 @@ void rxrpc_data_ready(struct sock *sk)
 		/* Connection-level packet */
 		_debug("CONN %p {%d}", conn, conn->debug_id);
 		rxrpc_post_packet_to_conn(conn, skb);
+		goto out_unlock;
 	} else {
 		/* Call-bound packets are routed by connection channel. */
 		unsigned int channel = sp->hdr.cid & RXRPC_CHANNELMASK;
 		struct rxrpc_channel *chan = &conn->channels[channel];
-		struct rxrpc_call *call = rcu_dereference(chan->call);
+		struct rxrpc_call *call;
+
+		/* Ignore really old calls */
+		if (sp->hdr.callNumber < chan->last_call)
+			goto discard_unlock;
+
+		if (sp->hdr.callNumber == chan->last_call) {
+			/* For the previous service call, if completed
+			 * successfully, we discard all further packets.
+			 */
+			if (rxrpc_conn_is_service(call->conn) &&
+			    (chan->last_type == RXRPC_PACKET_TYPE_ACK ||
+			     sp->hdr.type == RXRPC_PACKET_TYPE_ABORT))
+				goto discard_unlock;
+
+			/* But otherwise we need to retransmit the final packet
+			 * from data cached in the connection record.
+			 */
+			rxrpc_post_packet_to_conn(conn, skb);
+			goto out_unlock;
+		}
 
+		call = rcu_dereference(chan->call);
 		if (!call || atomic_read(&call->usage) == 0)
 			goto cant_route_call;
 
 		rxrpc_post_packet_to_call(call, skb);
+		goto out_unlock;
 	}
 
+discard_unlock:
+	rxrpc_free_skb(skb);
+out_unlock:
 	rcu_read_unlock();
 out:
 	return;
