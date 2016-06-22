From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 04/14] rxrpc: Replace conn->trans->{local,
 peer} with conn->params.{local, peer} [ver #2]
Date: Wed, 22 Jun 2016 17:03:20 +0100
Message-ID: <146661140074.15011.8302548936173194065.stgit@warthog.procyon.org.uk>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace accesses of conn->trans->{local,peer} with
conn->params.{local,peer} thus making it easier for a future commit to
remove the rxrpc_transport struct.

This also reduces the number of memory accesses involved.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c  |   12 ++++++------
 net/rxrpc/call_object.c |   28 ++++++++++++++--------------
 net/rxrpc/conn_event.c  |    6 +++---
 net/rxrpc/input.c       |    2 +-
 net/rxrpc/output.c      |    2 +-
 net/rxrpc/proc.c        |   22 ++++++++++------------
 net/rxrpc/recvmsg.c     |    4 ++--
 net/rxrpc/rxkad.c       |   12 ++++++------
 net/rxrpc/security.c    |    2 +-
 9 files changed, 44 insertions(+), 46 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 1571dfb95aa3..b43faf573ed3 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -545,7 +545,7 @@ static void rxrpc_extract_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 
 	mtu = min(ntohl(ackinfo.rxMTU), ntohl(ackinfo.maxMTU));
 
-	peer = call->conn->trans->peer;
+	peer = call->conn->params.peer;
 	if (mtu < peer->maxdata) {
 		spin_lock_bh(&peer->lock);
 		peer->maxdata = mtu;
@@ -836,8 +836,8 @@ void rxrpc_process_call(struct work_struct *work)
 
 	/* there's a good chance we're going to have to send a message, so set
 	 * one up in advance */
-	msg.msg_name	= &call->conn->trans->peer->srx.transport;
-	msg.msg_namelen	= call->conn->trans->peer->srx.transport_len;
+	msg.msg_name	= &call->conn->params.peer->srx.transport;
+	msg.msg_namelen	= call->conn->params.peer->srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
@@ -1151,8 +1151,8 @@ send_ACK_with_skew:
 	ack.maxSkew = htons(atomic_read(&call->conn->hi_serial) -
 			    ntohl(ack.serial));
 send_ACK:
-	mtu = call->conn->trans->peer->if_mtu;
-	mtu -= call->conn->trans->peer->hdrsize;
+	mtu = call->conn->params.peer->if_mtu;
+	mtu -= call->conn->params.peer->hdrsize;
 	ackinfo.maxMTU	= htonl(mtu);
 	ackinfo.rwind	= htonl(rxrpc_rx_window_size);
 
@@ -1206,7 +1206,7 @@ send_message_2:
 		len += iov[1].iov_len;
 	}
 
-	ret = kernel_sendmsg(call->conn->trans->local->socket,
+	ret = kernel_sendmsg(call->conn->params.local->socket,
 			     &msg, iov, ioc, len);
 	if (ret < 0) {
 		_debug("sendmsg failed: %d", ret);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index b7c6011c71bb..5c2dceaf6a9c 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -122,7 +122,7 @@ static void rxrpc_call_hash_add(struct rxrpc_call *call)
 	key = rxrpc_call_hashfunc(call->in_clientflag, call->cid,
 				  call->call_id, call->epoch,
 				  call->service_id, call->family,
-				  call->conn->trans->local, addr_size,
+				  call->conn->params.local, addr_size,
 				  call->peer_ip.ipv6_addr);
 	/* Store the full key in the call */
 	call->hash_key = key;
@@ -320,11 +320,11 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 	switch (call->family) {
 	case AF_INET:
 		call->peer_ip.ipv4_addr =
-			trans->peer->srx.transport.sin.sin_addr.s_addr;
+			call->conn->params.peer->srx.transport.sin.sin_addr.s_addr;
 		break;
 	case AF_INET6:
 		memcpy(call->peer_ip.ipv6_addr,
-		       trans->peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
+		       call->conn->params.peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
 		       sizeof(call->peer_ip.ipv6_addr));
 		break;
 	}
@@ -334,9 +334,9 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 	/* Add the new call to the hashtable */
 	rxrpc_call_hash_add(call);
 
-	spin_lock(&call->conn->trans->peer->lock);
-	hlist_add_head(&call->error_link, &call->conn->trans->peer->error_targets);
-	spin_unlock(&call->conn->trans->peer->lock);
+	spin_lock(&call->conn->params.peer->lock);
+	hlist_add_head(&call->error_link, &call->conn->params.peer->error_targets);
+	spin_unlock(&call->conn->params.peer->lock);
 
 	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
 	add_timer(&call->lifetimer);
@@ -517,9 +517,9 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	atomic_inc(&conn->usage);
 	write_unlock_bh(&conn->lock);
 
-	spin_lock(&conn->trans->peer->lock);
-	hlist_add_head(&call->error_link, &conn->trans->peer->error_targets);
-	spin_unlock(&conn->trans->peer->lock);
+	spin_lock(&conn->params.peer->lock);
+	hlist_add_head(&call->error_link, &conn->params.peer->error_targets);
+	spin_unlock(&conn->params.peer->lock);
 
 	write_lock_bh(&rxrpc_call_lock);
 	list_add_tail(&call->link, &rxrpc_calls);
@@ -527,15 +527,15 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 
 	/* Record copies of information for hashtable lookup */
 	call->family = rx->family;
-	call->local = conn->trans->local;
+	call->local = conn->params.local;
 	switch (call->family) {
 	case AF_INET:
 		call->peer_ip.ipv4_addr =
-			conn->trans->peer->srx.transport.sin.sin_addr.s_addr;
+			conn->params.peer->srx.transport.sin.sin_addr.s_addr;
 		break;
 	case AF_INET6:
 		memcpy(call->peer_ip.ipv6_addr,
-		       conn->trans->peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
+		       conn->params.peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
 		       sizeof(call->peer_ip.ipv6_addr));
 		break;
 	default:
@@ -813,9 +813,9 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 	}
 
 	if (call->conn) {
-		spin_lock(&call->conn->trans->peer->lock);
+		spin_lock(&call->conn->params.peer->lock);
 		hlist_del_init(&call->error_link);
-		spin_unlock(&call->conn->trans->peer->lock);
+		spin_unlock(&call->conn->params.peer->lock);
 
 		write_lock_bh(&call->conn->lock);
 		rb_erase(&call->conn_node, &call->conn->calls);
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 51e280c662e0..a022439f6f5a 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -88,8 +88,8 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 
 	rxrpc_abort_calls(conn, RXRPC_CALL_LOCALLY_ABORTED, abort_code);
 
-	msg.msg_name	= &conn->trans->peer->srx.transport;
-	msg.msg_namelen	= conn->trans->peer->srx.transport_len;
+	msg.msg_name	= &conn->params.peer->srx.transport;
+	msg.msg_namelen	= conn->params.peer->srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
@@ -118,7 +118,7 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 	whdr.serial = htonl(serial);
 	_proto("Tx CONN ABORT %%%u { %d }", serial, conn->local_abort);
 
-	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 2, len);
+	ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 2, len);
 	if (ret < 0) {
 		_debug("sendmsg failed: %d", ret);
 		return -EAGAIN;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index c030abd4d2d8..6af7f40c5030 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -560,7 +560,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 dead_call:
 	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
 		skb->priority = RX_CALL_DEAD;
-		rxrpc_reject_packet(call->conn->trans->local, skb);
+		rxrpc_reject_packet(call->conn->params.local, skb);
 		goto unlock;
 	}
 free_unlock:
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 8c51745cccea..becbaa7c0a7c 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -583,7 +583,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 					goto maybe_error;
 			}
 
-			max = call->conn->trans->peer->maxdata;
+			max = call->conn->params.peer->maxdata;
 			max -= call->conn->security_size;
 			max &= ~(call->conn->size_align - 1UL);
 
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index bbee05850801..9863270691d7 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -46,7 +46,7 @@ static void rxrpc_call_seq_stop(struct seq_file *seq, void *v)
 
 static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 {
-	struct rxrpc_transport *trans;
+	struct rxrpc_connection *conn;
 	struct rxrpc_call *call;
 	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
 
@@ -59,15 +59,15 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	}
 
 	call = list_entry(v, struct rxrpc_call, link);
-	trans = call->conn->trans;
+	conn = call->conn;
 
 	sprintf(lbuff, "%pI4:%u",
-		&trans->local->srx.transport.sin.sin_addr,
-		ntohs(trans->local->srx.transport.sin.sin_port));
+		&conn->params.local->srx.transport.sin.sin_addr,
+		ntohs(conn->params.local->srx.transport.sin.sin_port));
 
 	sprintf(rbuff, "%pI4:%u",
-		&trans->peer->srx.transport.sin.sin_addr,
-		ntohs(trans->peer->srx.transport.sin.sin_port));
+		&conn->params.peer->srx.transport.sin.sin_addr,
+		ntohs(conn->params.peer->srx.transport.sin.sin_port));
 
 	seq_printf(seq,
 		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
@@ -129,7 +129,6 @@ static void rxrpc_connection_seq_stop(struct seq_file *seq, void *v)
 static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 {
 	struct rxrpc_connection *conn;
-	struct rxrpc_transport *trans;
 	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
 
 	if (v == &rxrpc_connections) {
@@ -142,15 +141,14 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 	}
 
 	conn = list_entry(v, struct rxrpc_connection, link);
-	trans = conn->trans;
 
 	sprintf(lbuff, "%pI4:%u",
-		&trans->local->srx.transport.sin.sin_addr,
-		ntohs(trans->local->srx.transport.sin.sin_port));
+		&conn->params.local->srx.transport.sin.sin_addr,
+		ntohs(conn->params.local->srx.transport.sin.sin_port));
 
 	sprintf(rbuff, "%pI4:%u",
-		&trans->peer->srx.transport.sin.sin_addr,
-		ntohs(trans->peer->srx.transport.sin.sin_port));
+		&conn->params.peer->srx.transport.sin.sin_addr,
+		ntohs(conn->params.peer->srx.transport.sin.sin_port));
 
 	seq_printf(seq,
 		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index c5bac4e0db71..a3fa2ed85d63 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -147,9 +147,9 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		if (!continue_call) {
 			if (msg->msg_name) {
 				size_t len =
-					sizeof(call->conn->trans->peer->srx);
+					sizeof(call->conn->params.peer->srx);
 				memcpy(msg->msg_name,
-				       &call->conn->trans->peer->srx, len);
+				       &call->conn->params.peer->srx, len);
 				msg->msg_namelen = len;
 			}
 			sock_recv_timestamp(msg, &rx->sk, skb);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 134c2713ae23..23c05ec6fa28 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -602,8 +602,8 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	challenge.min_level	= htonl(0);
 	challenge.__padding	= 0;
 
-	msg.msg_name	= &conn->trans->peer->srx.transport.sin;
-	msg.msg_namelen	= sizeof(conn->trans->peer->srx.transport.sin);
+	msg.msg_name	= &conn->params.peer->srx.transport.sin;
+	msg.msg_namelen	= sizeof(conn->params.peer->srx.transport.sin);
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
@@ -630,7 +630,7 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	whdr.serial = htonl(serial);
 	_proto("Tx CHALLENGE %%%u", serial);
 
-	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 2, len);
+	ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 2, len);
 	if (ret < 0) {
 		_debug("sendmsg failed: %d", ret);
 		return -EAGAIN;
@@ -657,8 +657,8 @@ static int rxkad_send_response(struct rxrpc_connection *conn,
 
 	_enter("");
 
-	msg.msg_name	= &conn->trans->peer->srx.transport.sin;
-	msg.msg_namelen	= sizeof(conn->trans->peer->srx.transport.sin);
+	msg.msg_name	= &conn->params.peer->srx.transport.sin;
+	msg.msg_namelen	= sizeof(conn->params.peer->srx.transport.sin);
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
@@ -684,7 +684,7 @@ static int rxkad_send_response(struct rxrpc_connection *conn,
 	whdr.serial = htonl(serial);
 	_proto("Tx RESPONSE %%%u", serial);
 
-	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 3, len);
+	ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 3, len);
 	if (ret < 0) {
 		_debug("sendmsg failed: %d", ret);
 		return -EAGAIN;
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index 40955d0f2693..814d285ff802 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -113,7 +113,7 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 {
 	const struct rxrpc_security *sec;
-	struct rxrpc_local *local = conn->trans->local;
+	struct rxrpc_local *local = conn->params.local;
 	struct rxrpc_sock *rx;
 	struct key *key;
 	key_ref_t kref;
