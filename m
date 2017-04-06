From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/7] rxrpc: Use negative error codes in rxrpc_call
 struct
Date: Thu, 06 Apr 2017 11:22:20 +0100
Message-ID: <149147414094.21583.15881490078907762421.stgit@warthog.procyon.org.uk>
References: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use negative error codes in struct rxrpc_call::error because that's what
the kernel normally deals with and to make the code consistent.  We only
turn them positive when transcribing into a cmsg for userspace recvmsg.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c          |   12 ++++++------
 net/rxrpc/call_accept.c |    6 +++---
 net/rxrpc/call_event.c  |    2 +-
 net/rxrpc/call_object.c |    4 ++--
 net/rxrpc/conn_event.c  |    8 ++++----
 net/rxrpc/input.c       |    6 +++---
 net/rxrpc/peer_event.c  |    2 +-
 net/rxrpc/recvmsg.c     |    6 +++---
 net/rxrpc/rxkad.c       |   18 +++++++++---------
 net/rxrpc/sendmsg.c     |    2 +-
 10 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 8f76b13d5549..d5990eb160bd 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -419,7 +419,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	call->state = AFS_CALL_COMPLETE;
 	if (ret != -ECONNABORTED) {
 		rxrpc_kernel_abort_call(afs_socket, rxcall, RX_USER_ABORT,
-					-ret, "KSD");
+					ret, "KSD");
 	} else {
 		abort_code = 0;
 		offset = 0;
@@ -478,12 +478,12 @@ static void afs_deliver_to_call(struct afs_call *call)
 		case -ENOTCONN:
 			abort_code = RX_CALL_DEAD;
 			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-						abort_code, -ret, "KNC");
+						abort_code, ret, "KNC");
 			goto save_error;
 		case -ENOTSUPP:
 			abort_code = RXGEN_OPCODE;
 			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-						abort_code, -ret, "KIV");
+						abort_code, ret, "KIV");
 			goto save_error;
 		case -ENODATA:
 		case -EBADMSG:
@@ -493,7 +493,7 @@ static void afs_deliver_to_call(struct afs_call *call)
 			if (call->state != AFS_CALL_AWAIT_REPLY)
 				abort_code = RXGEN_SS_UNMARSHAL;
 			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-						abort_code, EBADMSG, "KUM");
+						abort_code, -EBADMSG, "KUM");
 			goto save_error;
 		}
 	}
@@ -754,7 +754,7 @@ void afs_send_empty_reply(struct afs_call *call)
 	case -ENOMEM:
 		_debug("oom");
 		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-					RX_USER_ABORT, ENOMEM, "KOO");
+					RX_USER_ABORT, -ENOMEM, "KOO");
 	default:
 		_leave(" [error]");
 		return;
@@ -792,7 +792,7 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 	if (n == -ENOMEM) {
 		_debug("oom");
 		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-					RX_USER_ABORT, ENOMEM, "KOO");
+					RX_USER_ABORT, -ENOMEM, "KOO");
 	}
 	_leave(" [error]");
 }
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 0ed181f53f32..1752fcf8e8f1 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -413,11 +413,11 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 
 	case RXRPC_CONN_REMOTELY_ABORTED:
 		rxrpc_set_call_completion(call, RXRPC_CALL_REMOTELY_ABORTED,
-					  conn->remote_abort, ECONNABORTED);
+					  conn->remote_abort, -ECONNABORTED);
 		break;
 	case RXRPC_CONN_LOCALLY_ABORTED:
 		rxrpc_abort_call("CON", call, sp->hdr.seq,
-				 conn->local_abort, ECONNABORTED);
+				 conn->local_abort, -ECONNABORTED);
 		break;
 	default:
 		BUG();
@@ -600,7 +600,7 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 	write_lock_bh(&call->state_lock);
 	switch (call->state) {
 	case RXRPC_CALL_SERVER_ACCEPTING:
-		__rxrpc_abort_call("REJ", call, 1, RX_USER_ABORT, ECONNABORTED);
+		__rxrpc_abort_call("REJ", call, 1, RX_USER_ABORT, -ECONNABORTED);
 		abort = true;
 		/* fall through */
 	case RXRPC_CALL_COMPLETE:
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 97a17ada4431..7a77844aab16 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -386,7 +386,7 @@ void rxrpc_process_call(struct work_struct *work)
 
 	now = ktime_get_real();
 	if (ktime_before(call->expire_at, now)) {
-		rxrpc_abort_call("EXP", call, 0, RX_CALL_TIMEOUT, ETIME);
+		rxrpc_abort_call("EXP", call, 0, RX_CALL_TIMEOUT, -ETIME);
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		goto recheck_state;
 	}
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index d79cd36987a9..47f7f4205653 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -486,7 +486,7 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 		call = list_entry(rx->to_be_accepted.next,
 				  struct rxrpc_call, accept_link);
 		list_del(&call->accept_link);
-		rxrpc_abort_call("SKR", call, 0, RX_CALL_DEAD, ECONNRESET);
+		rxrpc_abort_call("SKR", call, 0, RX_CALL_DEAD, -ECONNRESET);
 		rxrpc_put_call(call, rxrpc_call_put);
 	}
 
@@ -494,7 +494,7 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 		call = list_entry(rx->sock_calls.next,
 				  struct rxrpc_call, sock_link);
 		rxrpc_get_call(call, rxrpc_call_got);
-		rxrpc_abort_call("SKT", call, 0, RX_CALL_DEAD, ECONNRESET);
+		rxrpc_abort_call("SKT", call, 0, RX_CALL_DEAD, -ECONNRESET);
 		rxrpc_send_abort_packet(call);
 		rxrpc_release_call(rx, call);
 		rxrpc_put_call(call, rxrpc_call_put);
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index b099b64366f3..f9d1d9cc86d8 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -168,7 +168,7 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn,
  * generate a connection-level abort
  */
 static int rxrpc_abort_connection(struct rxrpc_connection *conn,
-				  u32 error, u32 abort_code)
+				  int error, u32 abort_code)
 {
 	struct rxrpc_wire_header whdr;
 	struct msghdr msg;
@@ -288,7 +288,7 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 
 		conn->state = RXRPC_CONN_REMOTELY_ABORTED;
 		rxrpc_abort_calls(conn, RXRPC_CALL_REMOTELY_ABORTED,
-				  abort_code, ECONNABORTED);
+				  abort_code, -ECONNABORTED);
 		return -ECONNABORTED;
 
 	case RXRPC_PACKET_TYPE_CHALLENGE:
@@ -370,7 +370,7 @@ static void rxrpc_secure_connection(struct rxrpc_connection *conn)
 
 abort:
 	_debug("abort %d, %d", ret, abort_code);
-	rxrpc_abort_connection(conn, -ret, abort_code);
+	rxrpc_abort_connection(conn, ret, abort_code);
 	_leave(" [aborted]");
 }
 
@@ -419,7 +419,7 @@ void rxrpc_process_connection(struct work_struct *work)
 	goto out;
 
 protocol_error:
-	if (rxrpc_abort_connection(conn, -ret, abort_code) < 0)
+	if (rxrpc_abort_connection(conn, ret, abort_code) < 0)
 		goto requeue_and_leave;
 	rxrpc_free_skb(skb, rxrpc_skb_rx_freed);
 	_leave(" [EPROTO]");
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 18b2ad8be8e2..3a7754c87aef 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -30,7 +30,7 @@
 static void rxrpc_proto_abort(const char *why,
 			      struct rxrpc_call *call, rxrpc_seq_t seq)
 {
-	if (rxrpc_abort_call(why, call, seq, RX_PROTOCOL_ERROR, EBADMSG)) {
+	if (rxrpc_abort_call(why, call, seq, RX_PROTOCOL_ERROR, -EBADMSG)) {
 		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 		rxrpc_queue_call(call);
 	}
@@ -895,7 +895,7 @@ static void rxrpc_input_abort(struct rxrpc_call *call, struct sk_buff *skb)
 	_proto("Rx ABORT %%%u { %x }", sp->hdr.serial, abort_code);
 
 	if (rxrpc_set_call_completion(call, RXRPC_CALL_REMOTELY_ABORTED,
-				      abort_code, ECONNABORTED))
+				      abort_code, -ECONNABORTED))
 		rxrpc_notify_socket(call);
 }
 
@@ -958,7 +958,7 @@ static void rxrpc_input_implicit_end_call(struct rxrpc_connection *conn,
 	case RXRPC_CALL_COMPLETE:
 		break;
 	default:
-		if (rxrpc_abort_call("IMP", call, 0, RX_CALL_DEAD, ESHUTDOWN)) {
+		if (rxrpc_abort_call("IMP", call, 0, RX_CALL_DEAD, -ESHUTDOWN)) {
 			set_bit(RXRPC_CALL_EV_ABORT, &call->events);
 			rxrpc_queue_call(call);
 		}
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index bf13b8470c9a..1ed9c0c2e94f 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -296,7 +296,7 @@ void rxrpc_peer_error_distributor(struct work_struct *work)
 		hlist_del_init(&call->error_link);
 		rxrpc_see_call(call);
 
-		if (rxrpc_set_call_completion(call, compl, 0, error))
+		if (rxrpc_set_call_completion(call, compl, 0, -error))
 			rxrpc_notify_socket(call);
 	}
 
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 3e2f1a8e9c5b..ad1a815b9706 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -83,11 +83,11 @@ static int rxrpc_recvmsg_term(struct rxrpc_call *call, struct msghdr *msg)
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &tmp);
 		break;
 	case RXRPC_CALL_NETWORK_ERROR:
-		tmp = call->error;
+		tmp = -call->error;
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NET_ERROR, 4, &tmp);
 		break;
 	case RXRPC_CALL_LOCAL_ERROR:
-		tmp = call->error;
+		tmp = -call->error;
 		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4, &tmp);
 		break;
 	default:
@@ -689,7 +689,7 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 	goto out;
 call_complete:
 	*_abort = call->abort_code;
-	ret = -call->error;
+	ret = call->error;
 	if (call->completion == RXRPC_CALL_SUCCEEDED) {
 		ret = 1;
 		if (size > 0)
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 4374e7b9c7bf..2d5838a3dc24 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -330,7 +330,7 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	_enter("");
 
 	if (len < 8) {
-		rxrpc_abort_call("V1H", call, seq, RXKADSEALEDINCON, EPROTO);
+		rxrpc_abort_call("V1H", call, seq, RXKADSEALEDINCON, -EPROTO);
 		goto protocol_error;
 	}
 
@@ -355,7 +355,7 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 
 	/* Extract the decrypted packet length */
 	if (skb_copy_bits(skb, offset, &sechdr, sizeof(sechdr)) < 0) {
-		rxrpc_abort_call("XV1", call, seq, RXKADDATALEN, EPROTO);
+		rxrpc_abort_call("XV1", call, seq, RXKADDATALEN, -EPROTO);
 		goto protocol_error;
 	}
 	offset += sizeof(sechdr);
@@ -368,12 +368,12 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	check ^= seq ^ call->call_id;
 	check &= 0xffff;
 	if (check != 0) {
-		rxrpc_abort_call("V1C", call, seq, RXKADSEALEDINCON, EPROTO);
+		rxrpc_abort_call("V1C", call, seq, RXKADSEALEDINCON, -EPROTO);
 		goto protocol_error;
 	}
 
 	if (data_size > len) {
-		rxrpc_abort_call("V1L", call, seq, RXKADDATALEN, EPROTO);
+		rxrpc_abort_call("V1L", call, seq, RXKADDATALEN, -EPROTO);
 		goto protocol_error;
 	}
 
@@ -410,7 +410,7 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	_enter(",{%d}", skb->len);
 
 	if (len < 8) {
-		rxrpc_abort_call("V2H", call, seq, RXKADSEALEDINCON, EPROTO);
+		rxrpc_abort_call("V2H", call, seq, RXKADSEALEDINCON, -EPROTO);
 		goto protocol_error;
 	}
 
@@ -445,7 +445,7 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 
 	/* Extract the decrypted packet length */
 	if (skb_copy_bits(skb, offset, &sechdr, sizeof(sechdr)) < 0) {
-		rxrpc_abort_call("XV2", call, seq, RXKADDATALEN, EPROTO);
+		rxrpc_abort_call("XV2", call, seq, RXKADDATALEN, -EPROTO);
 		goto protocol_error;
 	}
 	offset += sizeof(sechdr);
@@ -458,12 +458,12 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	check ^= seq ^ call->call_id;
 	check &= 0xffff;
 	if (check != 0) {
-		rxrpc_abort_call("V2C", call, seq, RXKADSEALEDINCON, EPROTO);
+		rxrpc_abort_call("V2C", call, seq, RXKADSEALEDINCON, -EPROTO);
 		goto protocol_error;
 	}
 
 	if (data_size > len) {
-		rxrpc_abort_call("V2L", call, seq, RXKADDATALEN, EPROTO);
+		rxrpc_abort_call("V2L", call, seq, RXKADDATALEN, -EPROTO);
 		goto protocol_error;
 	}
 
@@ -522,7 +522,7 @@ static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 		cksum = 1; /* zero checksums are not permitted */
 
 	if (cksum != expected_cksum) {
-		rxrpc_abort_call("VCK", call, seq, RXKADSEALEDINCON, EPROTO);
+		rxrpc_abort_call("VCK", call, seq, RXKADSEALEDINCON, -EPROTO);
 		rxrpc_send_abort_packet(call);
 		_leave(" = -EPROTO [csum failed]");
 		return -EPROTO;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 97ab214ca411..601c0a3e31a2 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -556,7 +556,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		ret = -ESHUTDOWN;
 	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
 		ret = 0;
-		if (rxrpc_abort_call("CMD", call, 0, abort_code, ECONNABORTED))
+		if (rxrpc_abort_call("CMD", call, 0, abort_code, -ECONNABORTED))
 			ret = rxrpc_send_abort_packet(call);
 	} else if (cmd != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
