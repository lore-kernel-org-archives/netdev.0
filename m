From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/9] rxrpc: Don't store the rxrpc header in the Tx
 queue sk_buffs [ver #2]
Date: Thu, 22 Sep 2016 09:22:07 +0100
Message-ID: <147453252695.14579.3467624230234073677.stgit@warthog.procyon.org.uk>
References: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't store the rxrpc protocol header in sk_buffs on the transmit queue,
but rather generate it on the fly and pass it to kernel_sendmsg() as a
separate iov.  This reduces the amount of storage required.

Note that the security header is still stored in the sk_buff as it may get
encrypted along with the data (and doesn't change with each transmission).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    5 +--
 net/rxrpc/call_event.c  |   11 +-----
 net/rxrpc/conn_object.c |    1 -
 net/rxrpc/output.c      |   83 ++++++++++++++++++++++++++++++++---------------
 net/rxrpc/rxkad.c       |    8 ++---
 net/rxrpc/sendmsg.c     |   51 +++++------------------------
 6 files changed, 71 insertions(+), 88 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 034f525f2235..f021df4a6a22 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -385,10 +385,9 @@ struct rxrpc_connection {
 	int			debug_id;	/* debug ID for printks */
 	atomic_t		serial;		/* packet serial number counter */
 	unsigned int		hi_serial;	/* highest serial number received */
+	u32			security_nonce;	/* response re-use preventer */
 	u8			size_align;	/* data size alignment (for security) */
-	u8			header_size;	/* rxrpc + security header size */
 	u8			security_size;	/* security header size */
-	u32			security_nonce;	/* response re-use preventer */
 	u8			security_ix;	/* security type */
 	u8			out_clientflag;	/* RXRPC_CLIENT_INITIATED if we are client */
 };
@@ -946,7 +945,7 @@ extern const s8 rxrpc_ack_priority[];
  * output.c
  */
 int rxrpc_send_call_packet(struct rxrpc_call *, u8);
-int rxrpc_send_data_packet(struct rxrpc_connection *, struct sk_buff *);
+int rxrpc_send_data_packet(struct rxrpc_call *, struct sk_buff *);
 void rxrpc_reject_packets(struct rxrpc_local *);
 
 /*
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 7d1b99824ed9..6247ce25eb21 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -139,7 +139,6 @@ void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
  */
 static void rxrpc_resend(struct rxrpc_call *call)
 {
-	struct rxrpc_wire_header *whdr;
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
 	rxrpc_seq_t cursor, seq, top;
@@ -201,15 +200,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		skb = call->rxtx_buffer[ix];
 		rxrpc_get_skb(skb, rxrpc_skb_tx_got);
 		spin_unlock_bh(&call->lock);
-		sp = rxrpc_skb(skb);
-
-		/* Each Tx packet needs a new serial number */
-		sp->hdr.serial = atomic_inc_return(&call->conn->serial);
 
-		whdr = (struct rxrpc_wire_header *)skb->head;
-		whdr->serial = htonl(sp->hdr.serial);
-
-		if (rxrpc_send_data_packet(call->conn, skb) < 0) {
+		if (rxrpc_send_data_packet(call, skb) < 0) {
 			call->resend_at = now + 2;
 			rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
 			return;
@@ -217,6 +209,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 
 		if (rxrpc_is_client_call(call))
 			rxrpc_expose_client_call(call);
+		sp = rxrpc_skb(skb);
 		sp->resend_at = now + rxrpc_resend_timeout;
 
 		rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 3b55aee0c436..e1e83af47866 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -53,7 +53,6 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		spin_lock_init(&conn->state_lock);
 		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
 		conn->size_align = 4;
-		conn->header_size = sizeof(struct rxrpc_wire_header);
 		conn->idle_timestamp = jiffies;
 	}
 
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 16e18a94ffa6..817fb0e82d6a 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -208,19 +208,42 @@ out:
 /*
  * send a packet through the transport endpoint
  */
-int rxrpc_send_data_packet(struct rxrpc_connection *conn, struct sk_buff *skb)
+int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 {
-	struct kvec iov[1];
+	struct rxrpc_connection *conn = call->conn;
+	struct rxrpc_wire_header whdr;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct msghdr msg;
+	struct kvec iov[2];
+	rxrpc_serial_t serial;
+	size_t len;
 	int ret, opt;
 
 	_enter(",{%d}", skb->len);
 
-	iov[0].iov_base = skb->head;
-	iov[0].iov_len = skb->len;
+	/* Each transmission of a Tx packet needs a new serial number */
+	serial = atomic_inc_return(&conn->serial);
+
+	whdr.epoch	= htonl(conn->proto.epoch);
+	whdr.cid	= htonl(call->cid);
+	whdr.callNumber	= htonl(call->call_id);
+	whdr.seq	= htonl(sp->hdr.seq);
+	whdr.serial	= htonl(serial);
+	whdr.type	= RXRPC_PACKET_TYPE_DATA;
+	whdr.flags	= sp->hdr.flags;
+	whdr.userStatus	= 0;
+	whdr.securityIndex = call->security_ix;
+	whdr._rsvd	= htons(sp->hdr._rsvd);
+	whdr.serviceId	= htons(call->service_id);
+
+	iov[0].iov_base = &whdr;
+	iov[0].iov_len = sizeof(whdr);
+	iov[1].iov_base = skb->head;
+	iov[1].iov_len = skb->len;
+	len = iov[0].iov_len + iov[1].iov_len;
 
-	msg.msg_name = &conn->params.peer->srx.transport;
-	msg.msg_namelen = conn->params.peer->srx.transport_len;
+	msg.msg_name = &call->peer->srx.transport;
+	msg.msg_namelen = call->peer->srx.transport_len;
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags = 0;
@@ -234,26 +257,33 @@ int rxrpc_send_data_packet(struct rxrpc_connection *conn, struct sk_buff *skb)
 		}
 	}
 
+	_proto("Tx DATA %%%u { #%u }", serial, sp->hdr.seq);
+
 	/* send the packet with the don't fragment bit set if we currently
 	 * think it's small enough */
-	if (skb->len - sizeof(struct rxrpc_wire_header) < conn->params.peer->maxdata) {
-		down_read(&conn->params.local->defrag_sem);
-		/* send the packet by UDP
-		 * - returns -EMSGSIZE if UDP would have to fragment the packet
-		 *   to go out of the interface
-		 *   - in which case, we'll have processed the ICMP error
-		 *     message and update the peer record
-		 */
-		ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 1,
-				     iov[0].iov_len);
-
-		up_read(&conn->params.local->defrag_sem);
-		if (ret == -EMSGSIZE)
-			goto send_fragmentable;
-
-		_leave(" = %d [%u]", ret, conn->params.peer->maxdata);
-		return ret;
+	if (iov[1].iov_len >= call->peer->maxdata)
+		goto send_fragmentable;
+
+	down_read(&conn->params.local->defrag_sem);
+	/* send the packet by UDP
+	 * - returns -EMSGSIZE if UDP would have to fragment the packet
+	 *   to go out of the interface
+	 *   - in which case, we'll have processed the ICMP error
+	 *     message and update the peer record
+	 */
+	ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 2, len);
+
+	up_read(&conn->params.local->defrag_sem);
+	if (ret == -EMSGSIZE)
+		goto send_fragmentable;
+
+done:
+	if (ret == 0) {
+		sp->resend_at = jiffies + rxrpc_resend_timeout;
+		sp->hdr.serial = serial;
 	}
+	_leave(" = %d [%u]", ret, call->peer->maxdata);
+	return ret;
 
 send_fragmentable:
 	/* attempt to send this message with fragmentation enabled */
@@ -268,8 +298,8 @@ send_fragmentable:
 					SOL_IP, IP_MTU_DISCOVER,
 					(char *)&opt, sizeof(opt));
 		if (ret == 0) {
-			ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 1,
-					     iov[0].iov_len);
+			ret = kernel_sendmsg(conn->params.local->socket, &msg,
+					     iov, 2, len);
 
 			opt = IP_PMTUDISC_DO;
 			kernel_setsockopt(conn->params.local->socket, SOL_IP,
@@ -298,8 +328,7 @@ send_fragmentable:
 	}
 
 	up_write(&conn->params.local->defrag_sem);
-	_leave(" = %d [frag %u]", ret, conn->params.peer->maxdata);
-	return ret;
+	goto done;
 }
 
 /*
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index ae392558829d..88d080a1a3de 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -80,12 +80,10 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 	case RXRPC_SECURITY_AUTH:
 		conn->size_align = 8;
 		conn->security_size = sizeof(struct rxkad_level1_hdr);
-		conn->header_size += sizeof(struct rxkad_level1_hdr);
 		break;
 	case RXRPC_SECURITY_ENCRYPT:
 		conn->size_align = 8;
 		conn->security_size = sizeof(struct rxkad_level2_hdr);
-		conn->header_size += sizeof(struct rxkad_level2_hdr);
 		break;
 	default:
 		ret = -EKEYREJECTED;
@@ -161,7 +159,7 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 
 	_enter("");
 
-	check = sp->hdr.seq ^ sp->hdr.callNumber;
+	check = sp->hdr.seq ^ call->call_id;
 	data_size |= (u32)check << 16;
 
 	hdr.data_size = htonl(data_size);
@@ -205,7 +203,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 
 	_enter("");
 
-	check = sp->hdr.seq ^ sp->hdr.callNumber;
+	check = sp->hdr.seq ^ call->call_id;
 
 	rxkhdr.data_size = htonl(data_size | (u32)check << 16);
 	rxkhdr.checksum = 0;
@@ -277,7 +275,7 @@ static int rxkad_secure_packet(struct rxrpc_call *call,
 	/* calculate the security checksum */
 	x = (call->cid & RXRPC_CHANNELMASK) << (32 - RXRPC_CIDSHIFT);
 	x |= sp->hdr.seq & 0x3fffffff;
-	call->crypto_buf[0] = htonl(sp->hdr.callNumber);
+	call->crypto_buf[0] = htonl(call->call_id);
 	call->crypto_buf[1] = htonl(x);
 
 	sg_init_one(&sg, call->crypto_buf, 8);
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 6a39ee97a0b7..814b17f23971 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -134,13 +134,11 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 		write_unlock_bh(&call->state_lock);
 	}
 
-	_proto("Tx DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
-
 	if (seq == 1 && rxrpc_is_client_call(call))
 		rxrpc_expose_client_call(call);
 
 	sp->resend_at = jiffies + rxrpc_resend_timeout;
-	ret = rxrpc_send_data_packet(call->conn, skb);
+	ret = rxrpc_send_data_packet(call, skb);
 	if (ret < 0) {
 		_debug("need instant resend %d", ret);
 		rxrpc_instant_resend(call, ix);
@@ -151,29 +149,6 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 }
 
 /*
- * Convert a host-endian header into a network-endian header.
- */
-static void rxrpc_insert_header(struct sk_buff *skb)
-{
-	struct rxrpc_wire_header whdr;
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-
-	whdr.epoch	= htonl(sp->hdr.epoch);
-	whdr.cid	= htonl(sp->hdr.cid);
-	whdr.callNumber	= htonl(sp->hdr.callNumber);
-	whdr.seq	= htonl(sp->hdr.seq);
-	whdr.serial	= htonl(sp->hdr.serial);
-	whdr.type	= sp->hdr.type;
-	whdr.flags	= sp->hdr.flags;
-	whdr.userStatus	= sp->hdr.userStatus;
-	whdr.securityIndex = sp->hdr.securityIndex;
-	whdr._rsvd	= htons(sp->hdr._rsvd);
-	whdr.serviceId	= htons(sp->hdr.serviceId);
-
-	memcpy(skb->head, &whdr, sizeof(whdr));
-}
-
-/*
  * send data through a socket
  * - must be called in process context
  * - caller holds the socket locked
@@ -232,7 +207,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			space = chunk + call->conn->size_align;
 			space &= ~(call->conn->size_align - 1UL);
 
-			size = space + call->conn->header_size;
+			size = space + call->conn->security_size;
 
 			_debug("SIZE: %zu/%zu/%zu", chunk, space, size);
 
@@ -248,9 +223,9 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			ASSERTCMP(skb->mark, ==, 0);
 
-			_debug("HS: %u", call->conn->header_size);
-			skb_reserve(skb, call->conn->header_size);
-			skb->len += call->conn->header_size;
+			_debug("HS: %u", call->conn->security_size);
+			skb_reserve(skb, call->conn->security_size);
+			skb->len += call->conn->security_size;
 
 			sp = rxrpc_skb(skb);
 			sp->remain = chunk;
@@ -312,33 +287,23 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			seq = call->tx_top + 1;
 
-			sp->hdr.epoch	= conn->proto.epoch;
-			sp->hdr.cid	= call->cid;
-			sp->hdr.callNumber = call->call_id;
 			sp->hdr.seq	= seq;
-			sp->hdr.serial	= atomic_inc_return(&conn->serial);
-			sp->hdr.type	= RXRPC_PACKET_TYPE_DATA;
-			sp->hdr.userStatus = 0;
-			sp->hdr.securityIndex = call->security_ix;
 			sp->hdr._rsvd	= 0;
-			sp->hdr.serviceId = call->service_id;
+			sp->hdr.flags	= conn->out_clientflag;
 
-			sp->hdr.flags = conn->out_clientflag;
 			if (msg_data_left(msg) == 0 && !more)
 				sp->hdr.flags |= RXRPC_LAST_PACKET;
 			else if (call->tx_top - call->tx_hard_ack <
 				 call->tx_winsize)
 				sp->hdr.flags |= RXRPC_MORE_PACKETS;
-			if (more && seq & 1)
+			if (seq & 1)
 				sp->hdr.flags |= RXRPC_REQUEST_ACK;
 
 			ret = conn->security->secure_packet(
-				call, skb, skb->mark,
-				skb->head + sizeof(struct rxrpc_wire_header));
+				call, skb, skb->mark, skb->head);
 			if (ret < 0)
 				goto out;
 
-			rxrpc_insert_header(skb);
 			rxrpc_queue_packet(call, skb, !msg_data_left(msg) && !more);
 			skb = NULL;
 		}
