From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 11/14] rxrpc: Make rxrpc_send_packet() take a
 connection not a transport [ver #2]
Date: Wed, 22 Jun 2016 17:04:10 +0100
Message-ID: <146661145065.15011.7115489407328614610.stgit@warthog.procyon.org.uk>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbcFVQN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 12:13:27 -0400
In-Reply-To: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make rxrpc_send_packet() take a connection not a transport as part of the
phasing out of the rxrpc_transport struct.

Whilst we're at it, rename the function to rxrpc_send_data_packet() to
differentiate it from the other packet sending functions.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    2 +-
 net/rxrpc/call_event.c  |    2 +-
 net/rxrpc/output.c      |   51 +++++++++++++++++++++++++++--------------------
 3 files changed, 31 insertions(+), 24 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 89966508b26c..cfbd028aa551 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -670,7 +670,7 @@ extern const char *rxrpc_acks(u8 reason);
  */
 extern unsigned int rxrpc_resend_timeout;
 
-int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
+int rxrpc_send_data_packet(struct rxrpc_connection *, struct sk_buff *);
 int rxrpc_do_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
 
 /*
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index b43faf573ed3..0ba84295f913 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -187,7 +187,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 
 			_proto("Tx DATA %%%u { #%d }",
 			       sp->hdr.serial, sp->hdr.seq);
-			if (rxrpc_send_packet(call->conn->trans, txb) < 0) {
+			if (rxrpc_send_data_packet(call->conn, txb) < 0) {
 				stop = true;
 				sp->resend_at = jiffies + 3;
 			} else {
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 6f8ab0ef839f..db3933cf6b97 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -338,7 +338,7 @@ EXPORT_SYMBOL(rxrpc_kernel_abort_call);
 /*
  * send a packet through the transport endpoint
  */
-int rxrpc_send_packet(struct rxrpc_transport *trans, struct sk_buff *skb)
+int rxrpc_send_data_packet(struct rxrpc_connection *conn, struct sk_buff *skb)
 {
 	struct kvec iov[1];
 	struct msghdr msg;
@@ -349,30 +349,30 @@ int rxrpc_send_packet(struct rxrpc_transport *trans, struct sk_buff *skb)
 	iov[0].iov_base = skb->head;
 	iov[0].iov_len = skb->len;
 
-	msg.msg_name = &trans->peer->srx.transport.sin;
-	msg.msg_namelen = sizeof(trans->peer->srx.transport.sin);
+	msg.msg_name = &conn->params.peer->srx.transport;
+	msg.msg_namelen = conn->params.peer->srx.transport_len;
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags = 0;
 
 	/* send the packet with the don't fragment bit set if we currently
 	 * think it's small enough */
-	if (skb->len - sizeof(struct rxrpc_wire_header) < trans->peer->maxdata) {
-		down_read(&trans->local->defrag_sem);
+	if (skb->len - sizeof(struct rxrpc_wire_header) < conn->params.peer->maxdata) {
+		down_read(&conn->params.local->defrag_sem);
 		/* send the packet by UDP
 		 * - returns -EMSGSIZE if UDP would have to fragment the packet
 		 *   to go out of the interface
 		 *   - in which case, we'll have processed the ICMP error
 		 *     message and update the peer record
 		 */
-		ret = kernel_sendmsg(trans->local->socket, &msg, iov, 1,
+		ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 1,
 				     iov[0].iov_len);
 
-		up_read(&trans->local->defrag_sem);
+		up_read(&conn->params.local->defrag_sem);
 		if (ret == -EMSGSIZE)
 			goto send_fragmentable;
 
-		_leave(" = %d [%u]", ret, trans->peer->maxdata);
+		_leave(" = %d [%u]", ret, conn->params.peer->maxdata);
 		return ret;
 	}
 
@@ -380,21 +380,28 @@ send_fragmentable:
 	/* attempt to send this message with fragmentation enabled */
 	_debug("send fragment");
 
-	down_write(&trans->local->defrag_sem);
-	opt = IP_PMTUDISC_DONT;
-	ret = kernel_setsockopt(trans->local->socket, SOL_IP, IP_MTU_DISCOVER,
-				(char *) &opt, sizeof(opt));
-	if (ret == 0) {
-		ret = kernel_sendmsg(trans->local->socket, &msg, iov, 1,
-				     iov[0].iov_len);
-
-		opt = IP_PMTUDISC_DO;
-		kernel_setsockopt(trans->local->socket, SOL_IP,
-				  IP_MTU_DISCOVER, (char *) &opt, sizeof(opt));
+	down_write(&conn->params.local->defrag_sem);
+
+	switch (conn->params.local->srx.transport.family) {
+	case AF_INET:
+		opt = IP_PMTUDISC_DONT;
+		ret = kernel_setsockopt(conn->params.local->socket,
+					SOL_IP, IP_MTU_DISCOVER,
+					(char *)&opt, sizeof(opt));
+		if (ret == 0) {
+			ret = kernel_sendmsg(conn->params.local->socket, &msg, iov, 1,
+					     iov[0].iov_len);
+
+			opt = IP_PMTUDISC_DO;
+			kernel_setsockopt(conn->params.local->socket, SOL_IP,
+					  IP_MTU_DISCOVER,
+					  (char *)&opt, sizeof(opt));
+		}
+		break;
 	}
 
-	up_write(&trans->local->defrag_sem);
-	_leave(" = %d [frag %u]", ret, trans->peer->maxdata);
+	up_write(&conn->params.local->defrag_sem);
+	_leave(" = %d [frag %u]", ret, conn->params.peer->maxdata);
 	return ret;
 }
 
@@ -506,7 +513,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	if (try_to_del_timer_sync(&call->ack_timer) >= 0) {
 		/* the packet may be freed by rxrpc_process_call() before this
 		 * returns */
-		ret = rxrpc_send_packet(call->conn->trans, skb);
+		ret = rxrpc_send_data_packet(call->conn, skb);
 		_net("sent skb %p", skb);
 	} else {
 		_debug("failed to delete ACK timer");
