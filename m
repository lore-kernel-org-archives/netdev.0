From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 8/9 net-next] rxrpc: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:16 +0200
Message-ID: <1427749998-28464-8-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay107.isp.belgacom.be ([195.238.20.134]:48291 "EHLO
	mailrelay107.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932087AbbC3VNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 17:13:51 -0400
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/rxrpc/ar-accept.c   |  6 ++----
 net/rxrpc/ar-ack.c      |  6 ++----
 net/rxrpc/ar-call.c     |  3 +--
 net/rxrpc/ar-input.c    |  6 ++----
 net/rxrpc/ar-internal.h |  3 +--
 net/rxrpc/ar-key.c      |  3 +--
 net/rxrpc/ar-recvmsg.c  | 16 +++++-----------
 net/rxrpc/rxkad.c       | 19 +++++++------------
 8 files changed, 21 insertions(+), 41 deletions(-)

diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 6d79310..8f4cb91 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -377,10 +377,8 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	call->user_call_ID = user_call_ID;
 	rb_link_node(&call->sock_node, parent, pp);
 	rb_insert_color(&call->sock_node, &rx->calls);
-	if (test_and_set_bit(RXRPC_CALL_HAS_USERID, &call->flags))
-		BUG();
-	if (test_and_set_bit(RXRPC_CALL_ACCEPTED, &call->events))
-		BUG();
+	BUG_ON(test_and_set_bit(RXRPC_CALL_HAS_USERID, &call->flags));
+	BUG_ON(test_and_set_bit(RXRPC_CALL_ACCEPTED, &call->events));
 	rxrpc_queue_call(call);
 
 	rxrpc_get_call(call);
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index e0547f5..e648ac9 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -673,8 +673,7 @@ process_further:
 			_debug("extraction failure");
 			goto protocol_error;
 		}
-		if (!skb_pull(skb, sizeof(ack)))
-			BUG();
+		BUG_ON(!skb_pull(skb, sizeof(ack)));
 
 		latest = ntohl(sp->hdr.serial);
 		hard = ntohl(ack.firstPacket);
@@ -803,8 +802,7 @@ all_acked:
 		sp->call = call;
 		rxrpc_get_call(call);
 		spin_lock_bh(&call->lock);
-		if (rxrpc_queue_rcv_skb(call, skb, true, true) < 0)
-			BUG();
+		BUG_ON(rxrpc_queue_rcv_skb(call, skb, true, true) < 0);
 		spin_unlock_bh(&call->lock);
 		goto process_further;
 	}
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index a9e05db..2e2c37f 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -621,8 +621,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	       call->rx_first_oos);
 
 	spin_lock_bh(&call->lock);
-	if (test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags))
-		BUG();
+	BUG_ON(test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags));
 	spin_unlock_bh(&call->lock);
 
 	/* dissociate from the socket
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 481f89f..185ad34 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -478,8 +478,7 @@ static void rxrpc_process_jumbo_packet(struct rxrpc_call *call,
 
 		if (skb_copy_bits(jumbo, 0, &jhdr, sizeof(jhdr)) < 0)
 			goto protocol_error;
-		if (!pskb_pull(jumbo, sizeof(jhdr)))
-			BUG();
+		BUG_ON(!pskb_pull(jumbo, sizeof(jhdr)));
 
 		sp->hdr.seq	= htonl(ntohl(sp->hdr.seq) + 1);
 		sp->hdr.serial	= htonl(ntohl(sp->hdr.serial) + 1);
@@ -685,8 +684,7 @@ void rxrpc_data_ready(struct sock *sk)
 	if (skb_copy_bits(skb, sizeof(struct udphdr), &sp->hdr,
 			  sizeof(sp->hdr)) < 0)
 		goto bad_message;
-	if (!pskb_pull(skb, sizeof(struct udphdr) + sizeof(sp->hdr)))
-		BUG();
+	BUG_ON(!pskb_pull(skb, sizeof(struct udphdr) + sizeof(sp->hdr)));
 
 	_net("Rx RxRPC %s ep=%x call=%x:%x",
 	     sp->hdr.flags & RXRPC_CLIENT_INITIATED ? "ToServer" : "ToClient",
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 2fc1e65..3c30274 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -800,8 +800,7 @@ static inline void __rxrpc_get_local(struct rxrpc_local *local, const char *f)
 #define rxrpc_get_call(CALL)				\
 do {							\
 	CHECK_SLAB_OKAY(&(CALL)->usage);		\
-	if (atomic_inc_return(&(CALL)->usage) == 1)	\
-		BUG();					\
+	BUG_ON(atomic_inc_return(&(CALL)->usage) == 1); \
 } while(0)
 
 #define rxrpc_put_call(CALL)				\
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index db0f39f..8982d76 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -839,8 +839,7 @@ static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 		return PTR_ERR(ci);
 	}
 
-	if (crypto_blkcipher_setkey(ci, prep->data, 8) < 0)
-		BUG();
+	BUG_ON(crypto_blkcipher_setkey(ci, prep->data, 8) < 0);
 
 	prep->payload[0] = ci;
 	_leave(" = 0");
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index b92bede..341a1b8 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -121,8 +121,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 		if (test_bit(RXRPC_CALL_RELEASED, &call->flags)) {
 			_debug("packet from released call");
-			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-				BUG();
+			BUG_ON(skb_dequeue(&rx->sk.sk_receive_queue) != skb);
 			rxrpc_free_skb(skb);
 			continue;
 		}
@@ -212,9 +211,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			/* last bit of request received */
 			if (!(flags & MSG_PEEK)) {
 				_debug("eat packet");
-				if (skb_dequeue(&rx->sk.sk_receive_queue) !=
-				    skb)
-					BUG();
+				BUG_ON(skb_dequeue(&rx->sk.sk_receive_queue) != skb);
 				rxrpc_free_skb(skb);
 			}
 			msg->msg_flags &= ~MSG_MORE;
@@ -238,8 +235,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		}
 
 		_debug("eat packet");
-		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-			BUG();
+		BUG_ON(skb_dequeue(&rx->sk.sk_receive_queue) != skb);
 		rxrpc_free_skb(skb);
 	}
 
@@ -265,8 +261,7 @@ receive_non_data_message:
 		if (ret < 0)
 			goto copy_error;
 		if (!(flags & MSG_PEEK)) {
-			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-				BUG();
+			BUG_ON(skb_dequeue(&rx->sk.sk_receive_queue) != skb);
 			rxrpc_free_skb(skb);
 		}
 		goto out;
@@ -317,8 +312,7 @@ terminal_message:
 
 	if (!(flags & MSG_PEEK)) {
 		_net("free terminal skb %p", skb);
-		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
-			BUG();
+		BUG_ON(skb_dequeue(&rx->sk.sk_receive_queue) != skb);
 		rxrpc_free_skb(skb);
 		rxrpc_remove_user_ID(rx, call);
 	}
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index f226709..6793d57 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -77,9 +77,8 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 		goto error;
 	}
 
-	if (crypto_blkcipher_setkey(ci, token->kad->session_key,
-				    sizeof(token->kad->session_key)) < 0)
-		BUG();
+	BUG_ON(crypto_blkcipher_setkey(ci, token->kad->session_key,
+				       sizeof(token->kad->session_key)) < 0);
 
 	switch (conn->security_level) {
 	case RXRPC_SECURITY_PLAIN:
@@ -361,8 +360,7 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 	/* remove the decrypted packet length */
 	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0)
 		goto datalen_error;
-	if (!skb_pull(skb, sizeof(sechdr)))
-		BUG();
+	BUG_ON(!skb_pull(skb, sizeof(sechdr)));
 
 	buf = ntohl(sechdr.data_size);
 	data_size = buf & 0xffff;
@@ -446,8 +444,7 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	/* remove the decrypted packet length */
 	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0)
 		goto datalen_error;
-	if (!skb_pull(skb, sizeof(sechdr)))
-		BUG();
+	BUG_ON(!skb_pull(skb, sizeof(sechdr)));
 
 	buf = ntohl(sechdr.data_size);
 	data_size = buf & 0xffff;
@@ -976,9 +973,8 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 	ASSERT(rxkad_ci != NULL);
 
 	mutex_lock(&rxkad_ci_mutex);
-	if (crypto_blkcipher_setkey(rxkad_ci, session_key->x,
-				    sizeof(*session_key)) < 0)
-		BUG();
+	BUG_ON(crypto_blkcipher_setkey(rxkad_ci, session_key->x,
+				       sizeof(*session_key)) < 0);
 
 	memcpy(&iv, session_key, sizeof(iv));
 	desc.tfm = rxkad_ci;
@@ -1014,8 +1010,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	abort_code = RXKADPACKETSHORT;
 	if (skb_copy_bits(skb, 0, &response, sizeof(response)) < 0)
 		goto protocol_error;
-	if (!pskb_pull(skb, sizeof(response)))
-		BUG();
+	BUG_ON(!pskb_pull(skb, sizeof(response)));
 
 	version = ntohl(response.version);
 	ticket_len = ntohl(response.ticket_len);
-- 
1.9.1
