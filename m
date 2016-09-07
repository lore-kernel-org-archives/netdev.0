From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/2] rxrpc: Add tracepoint for working out where
 aborts happen
Date: Wed, 07 Sep 2016 16:40:09 +0100
Message-ID: <147326280149.9308.5228512306863985275.stgit@warthog.procyon.org.uk>
References: <147326277574.9308.4656891674085539944.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147326277574.9308.4656891674085539944.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a tracepoint for working out where local aborts happen.  Each
tracepoint call is labelled with a 3-letter code so that they can be
distinguished - and the DATA sequence number is added too where available.

rxrpc_kernel_abort_call() also takes a 3-letter code so that AFS can
indicate the circumstances when it aborts a call.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c               |   17 ++++---
 include/net/af_rxrpc.h       |    3 +
 include/trace/events/rxrpc.h |   29 +++++++++++
 net/rxrpc/ar-internal.h      |   14 ++++-
 net/rxrpc/call_event.c       |    7 ++-
 net/rxrpc/call_object.c      |    2 -
 net/rxrpc/conn_event.c       |    6 ++
 net/rxrpc/input.c            |    7 ++-
 net/rxrpc/insecure.c         |   19 ++++---
 net/rxrpc/rxkad.c            |  108 +++++++++++++++++++-----------------------
 net/rxrpc/sendmsg.c          |   18 ++++---
 11 files changed, 132 insertions(+), 98 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 37608be52abd..53750dece80e 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -377,7 +377,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	return wait_mode->wait(call);
 
 error_do_abort:
-	rxrpc_kernel_abort_call(afs_socket, rxcall, RX_USER_ABORT);
+	rxrpc_kernel_abort_call(afs_socket, rxcall, RX_USER_ABORT, -ret, "KSD");
 error_kill_call:
 	afs_end_call(call);
 	_leave(" = %d", ret);
@@ -425,12 +425,12 @@ static void afs_deliver_to_call(struct afs_call *call)
 		case -ENOTCONN:
 			abort_code = RX_CALL_DEAD;
 			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-						abort_code);
+						abort_code, -ret, "KNC");
 			goto do_abort;
 		case -ENOTSUPP:
 			abort_code = RX_INVALID_OPERATION;
 			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-						abort_code);
+						abort_code, -ret, "KIV");
 			goto do_abort;
 		case -ENODATA:
 		case -EBADMSG:
@@ -440,7 +440,7 @@ static void afs_deliver_to_call(struct afs_call *call)
 			if (call->state != AFS_CALL_AWAIT_REPLY)
 				abort_code = RXGEN_SS_UNMARSHAL;
 			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-						abort_code);
+						abort_code, EBADMSG, "KUM");
 			goto do_abort;
 		}
 	}
@@ -463,6 +463,7 @@ do_abort:
  */
 static int afs_wait_for_call_to_complete(struct afs_call *call)
 {
+	const char *abort_why;
 	int ret;
 
 	DECLARE_WAITQUEUE(myself, current);
@@ -481,9 +482,11 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 			continue;
 		}
 
+		abort_why = "KWC";
 		ret = call->error;
 		if (call->state == AFS_CALL_COMPLETE)
 			break;
+		abort_why = "KWI";
 		ret = -EINTR;
 		if (signal_pending(current))
 			break;
@@ -497,7 +500,7 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 	if (call->state < AFS_CALL_COMPLETE) {
 		_debug("call incomplete");
 		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-					RX_CALL_DEAD);
+					RX_CALL_DEAD, -ret, abort_why);
 	}
 
 	_debug("call complete");
@@ -695,7 +698,7 @@ void afs_send_empty_reply(struct afs_call *call)
 	case -ENOMEM:
 		_debug("oom");
 		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-					RX_USER_ABORT);
+					RX_USER_ABORT, ENOMEM, "KOO");
 	default:
 		afs_end_call(call);
 		_leave(" [error]");
@@ -734,7 +737,7 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 	if (n == -ENOMEM) {
 		_debug("oom");
 		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
-					RX_USER_ABORT);
+					RX_USER_ABORT, ENOMEM, "KOO");
 	}
 	afs_end_call(call);
 	_leave(" [error]");
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index b4b6a3664dda..08ed8729126c 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -35,7 +35,8 @@ int rxrpc_kernel_send_data(struct socket *, struct rxrpc_call *,
 			   struct msghdr *, size_t);
 int rxrpc_kernel_recv_data(struct socket *, struct rxrpc_call *,
 			   void *, size_t, size_t *, bool, u32 *);
-void rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *, u32);
+void rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *,
+			     u32, int, const char *);
 void rxrpc_kernel_end_call(struct socket *, struct rxrpc_call *);
 struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long,
 					    rxrpc_notify_rx_t);
diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 30164896f1f6..85ee035774ae 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -84,6 +84,35 @@ TRACE_EVENT(rxrpc_skb,
 		      __entry->where)
 	    );
 
+TRACE_EVENT(rxrpc_abort,
+	    TP_PROTO(const char *why, u32 cid, u32 call_id, rxrpc_seq_t seq,
+		     int abort_code, int error),
+
+	    TP_ARGS(why, cid, call_id, seq, abort_code, error),
+
+	    TP_STRUCT__entry(
+		    __array(char,			why, 4		)
+		    __field(u32,			cid		)
+		    __field(u32,			call_id		)
+		    __field(rxrpc_seq_t,		seq		)
+		    __field(int,			abort_code	)
+		    __field(int,			error		)
+			     ),
+
+	    TP_fast_assign(
+		    memcpy(__entry->why, why, 4);
+		    __entry->cid = cid;
+		    __entry->call_id = call_id;
+		    __entry->abort_code = abort_code;
+		    __entry->error = error;
+		    __entry->seq = seq;
+			   ),
+
+	    TP_printk("%08x:%08x s=%u a=%d e=%d %s",
+		      __entry->cid, __entry->call_id, __entry->seq,
+		      __entry->abort_code, __entry->error, __entry->why)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 0353399792b6..dbfb9ed17483 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -155,7 +155,8 @@ struct rxrpc_security {
 			     void *);
 
 	/* verify the security on a received packet */
-	int (*verify_packet)(struct rxrpc_call *, struct sk_buff *, u32 *);
+	int (*verify_packet)(struct rxrpc_call *, struct sk_buff *,
+			     rxrpc_seq_t, u16);
 
 	/* issue a challenge */
 	int (*issue_challenge)(struct rxrpc_connection *);
@@ -637,9 +638,12 @@ static inline bool rxrpc_call_completed(struct rxrpc_call *call)
 /*
  * Record that a call is locally aborted.
  */
-static inline bool __rxrpc_abort_call(struct rxrpc_call *call,
+static inline bool __rxrpc_abort_call(const char *why, struct rxrpc_call *call,
+				      rxrpc_seq_t seq,
 				      u32 abort_code, int error)
 {
+	trace_rxrpc_abort(why, call->cid, call->call_id, seq,
+			  abort_code, error);
 	if (__rxrpc_set_call_completion(call,
 					RXRPC_CALL_LOCALLY_ABORTED,
 					abort_code, error)) {
@@ -649,13 +653,13 @@ static inline bool __rxrpc_abort_call(struct rxrpc_call *call,
 	return false;
 }
 
-static inline bool rxrpc_abort_call(struct rxrpc_call *call,
-				    u32 abort_code, int error)
+static inline bool rxrpc_abort_call(const char *why, struct rxrpc_call *call,
+				    rxrpc_seq_t seq, u32 abort_code, int error)
 {
 	bool ret;
 
 	write_lock_bh(&call->state_lock);
-	ret = __rxrpc_abort_call(call, abort_code, error);
+	ret = __rxrpc_abort_call(why, call, seq, abort_code, error);
 	write_unlock_bh(&call->state_lock);
 	return ret;
 }
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 8365d3366114..af88ad7d2cf9 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -598,7 +598,8 @@ process_further:
 
 		/* secured packets must be verified and possibly decrypted */
 		if (call->conn->security->verify_packet(call, skb,
-							_abort_code) < 0)
+							sp->hdr.seq,
+							sp->hdr.cksum) < 0)
 			goto protocol_error;
 
 		rxrpc_insert_oos_packet(call, skb);
@@ -982,7 +983,7 @@ skip_msg_init:
 	}
 
 	if (test_bit(RXRPC_CALL_EV_LIFE_TIMER, &call->events)) {
-		rxrpc_abort_call(call, RX_CALL_TIMEOUT, ETIME);
+		rxrpc_abort_call("EXP", call, 0, RX_CALL_TIMEOUT, ETIME);
 
 		_debug("post timeout");
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
@@ -1005,7 +1006,7 @@ skip_msg_init:
 		case -EKEYEXPIRED:
 		case -EKEYREJECTED:
 		case -EPROTO:
-			rxrpc_abort_call(call, abort_code, -ret);
+			rxrpc_abort_call("PRO", call, 0, abort_code, -ret);
 			goto kill_ACKs;
 		}
 	}
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index be5733d55794..9efd9b0b0bdf 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -563,7 +563,7 @@ void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 
 		if (call->state < RXRPC_CALL_COMPLETE) {
 			_debug("+++ ABORTING STATE %d +++\n", call->state);
-			__rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
+			__rxrpc_abort_call("SKT", call, 0, RX_CALL_DEAD, ECONNRESET);
 			clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
 			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
 		}
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 9db90f4f768d..8c7938ba6a84 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -158,6 +158,11 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn,
 			lockdep_is_held(&conn->channel_lock));
 		if (call) {
 			rxrpc_see_call(call);
+			if (compl == RXRPC_CALL_LOCALLY_ABORTED)
+				trace_rxrpc_abort("CON", call->cid,
+						  call->call_id, 0,
+						  abort_code, error);
+
 			write_lock_bh(&call->state_lock);
 			if (rxrpc_set_call_completion(call, compl, abort_code,
 						      error)) {
@@ -167,6 +172,7 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn,
 			write_unlock_bh(&call->state_lock);
 			if (queue)
 				rxrpc_queue_call(call);
+
 		}
 	}
 
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 79f3f585cdc3..8e624109750a 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -429,7 +429,7 @@ protocol_error:
 	_debug("protocol error");
 	write_lock_bh(&call->state_lock);
 protocol_error_locked:
-	if (__rxrpc_abort_call(call, RX_PROTOCOL_ERROR, EPROTO))
+	if (__rxrpc_abort_call("FPR", call, 0, RX_PROTOCOL_ERROR, EPROTO))
 		rxrpc_queue_call(call);
 free_packet_unlock:
 	write_unlock_bh(&call->state_lock);
@@ -495,9 +495,10 @@ static void rxrpc_process_jumbo_packet(struct rxrpc_call *call,
 protocol_error:
 	_debug("protocol error");
 	rxrpc_free_skb(part);
-	rxrpc_free_skb(jumbo);
-	if (rxrpc_abort_call(call, RX_PROTOCOL_ERROR, EPROTO))
+	if (rxrpc_abort_call("PJP", call, sp->hdr.seq,
+			     RX_PROTOCOL_ERROR, EPROTO))
 		rxrpc_queue_call(call);
+	rxrpc_free_skb(jumbo);
 	_leave("");
 }
 
diff --git a/net/rxrpc/insecure.c b/net/rxrpc/insecure.c
index c21ad213b337..a4aba0246731 100644
--- a/net/rxrpc/insecure.c
+++ b/net/rxrpc/insecure.c
@@ -23,31 +23,32 @@ static int none_prime_packet_security(struct rxrpc_connection *conn)
 }
 
 static int none_secure_packet(struct rxrpc_call *call,
-			       struct sk_buff *skb,
-			       size_t data_size,
-			       void *sechdr)
+			      struct sk_buff *skb,
+			      size_t data_size,
+			      void *sechdr)
 {
 	return 0;
 }
 
 static int none_verify_packet(struct rxrpc_call *call,
-			       struct sk_buff *skb,
-			       u32 *_abort_code)
+			      struct sk_buff *skb,
+			      rxrpc_seq_t seq,
+			      u16 expected_cksum)
 {
 	return 0;
 }
 
 static int none_respond_to_challenge(struct rxrpc_connection *conn,
-				      struct sk_buff *skb,
-				      u32 *_abort_code)
+				     struct sk_buff *skb,
+				     u32 *_abort_code)
 {
 	*_abort_code = RX_PROTOCOL_ERROR;
 	return -EPROTO;
 }
 
 static int none_verify_response(struct rxrpc_connection *conn,
-				 struct sk_buff *skb,
-				 u32 *_abort_code)
+				struct sk_buff *skb,
+				u32 *_abort_code)
 {
 	*_abort_code = RX_PROTOCOL_ERROR;
 	return -EPROTO;
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 89f475febfd7..3777432df10b 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -316,12 +316,10 @@ static int rxkad_secure_packet(struct rxrpc_call *call,
 /*
  * decrypt partial encryption on a packet (level 1 security)
  */
-static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
-				    struct sk_buff *skb,
-				    u32 *_abort_code)
+static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
+				 rxrpc_seq_t seq)
 {
 	struct rxkad_level1_hdr sechdr;
-	struct rxrpc_skb_priv *sp;
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[16];
@@ -332,7 +330,10 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 
 	_enter("");
 
-	sp = rxrpc_skb(skb);
+	if (skb->len < 8) {
+		rxrpc_abort_call("V1H", call, seq, RXKADSEALEDINCON, EPROTO);
+		goto protocol_error;
+	}
 
 	/* we want to decrypt the skbuff in-place */
 	nsg = skb_cow_data(skb, 0, &trailer);
@@ -351,9 +352,11 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 	crypto_skcipher_decrypt(req);
 	skcipher_request_zero(req);
 
-	/* remove the decrypted packet length */
-	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0)
-		goto datalen_error;
+	/* Extract the decrypted packet length */
+	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0) {
+		rxrpc_abort_call("XV1", call, seq, RXKADDATALEN, EPROTO);
+		goto protocol_error;
+	}
 	if (!skb_pull(skb, sizeof(sechdr)))
 		BUG();
 
@@ -361,24 +364,24 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 	data_size = buf & 0xffff;
 
 	check = buf >> 16;
-	check ^= sp->hdr.seq ^ sp->hdr.callNumber;
+	check ^= seq ^ call->call_id;
 	check &= 0xffff;
 	if (check != 0) {
-		*_abort_code = RXKADSEALEDINCON;
+		rxrpc_abort_call("V1C", call, seq, RXKADSEALEDINCON, EPROTO);
 		goto protocol_error;
 	}
 
 	/* shorten the packet to remove the padding */
-	if (data_size > skb->len)
-		goto datalen_error;
-	else if (data_size < skb->len)
+	if (data_size > skb->len) {
+		rxrpc_abort_call("V1L", call, seq, RXKADDATALEN, EPROTO);
+		goto protocol_error;
+	}
+	if (data_size < skb->len)
 		skb->len = data_size;
 
 	_leave(" = 0 [dlen=%x]", data_size);
 	return 0;
 
-datalen_error:
-	*_abort_code = RXKADDATALEN;
 protocol_error:
 	_leave(" = -EPROTO");
 	return -EPROTO;
@@ -391,13 +394,11 @@ nomem:
 /*
  * wholly decrypt a packet (level 2 security)
  */
-static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
-				       struct sk_buff *skb,
-				       u32 *_abort_code)
+static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
+				 rxrpc_seq_t seq)
 {
 	const struct rxrpc_key_token *token;
 	struct rxkad_level2_hdr sechdr;
-	struct rxrpc_skb_priv *sp;
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist _sg[4], *sg;
@@ -408,7 +409,10 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 
 	_enter(",{%d}", skb->len);
 
-	sp = rxrpc_skb(skb);
+	if (skb->len < 8) {
+		rxrpc_abort_call("V2H", call, seq, RXKADSEALEDINCON, EPROTO);
+		goto protocol_error;
+	}
 
 	/* we want to decrypt the skbuff in-place */
 	nsg = skb_cow_data(skb, 0, &trailer);
@@ -437,9 +441,11 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	if (sg != _sg)
 		kfree(sg);
 
-	/* remove the decrypted packet length */
-	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0)
-		goto datalen_error;
+	/* Extract the decrypted packet length */
+	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0) {
+		rxrpc_abort_call("XV2", call, seq, RXKADDATALEN, EPROTO);
+		goto protocol_error;
+	}
 	if (!skb_pull(skb, sizeof(sechdr)))
 		BUG();
 
@@ -447,24 +453,23 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	data_size = buf & 0xffff;
 
 	check = buf >> 16;
-	check ^= sp->hdr.seq ^ sp->hdr.callNumber;
+	check ^= seq ^ call->call_id;
 	check &= 0xffff;
 	if (check != 0) {
-		*_abort_code = RXKADSEALEDINCON;
+		rxrpc_abort_call("V2C", call, seq, RXKADSEALEDINCON, EPROTO);
 		goto protocol_error;
 	}
 
-	/* shorten the packet to remove the padding */
-	if (data_size > skb->len)
-		goto datalen_error;
-	else if (data_size < skb->len)
+	if (data_size > skb->len) {
+		rxrpc_abort_call("V2L", call, seq, RXKADDATALEN, EPROTO);
+		goto protocol_error;
+	}
+	if (data_size < skb->len)
 		skb->len = data_size;
 
 	_leave(" = 0 [dlen=%x]", data_size);
 	return 0;
 
-datalen_error:
-	*_abort_code = RXKADDATALEN;
 protocol_error:
 	_leave(" = -EPROTO");
 	return -EPROTO;
@@ -475,40 +480,30 @@ nomem:
 }
 
 /*
- * verify the security on a received packet
+ * Verify the security on a received packet or subpacket (if part of a
+ * jumbo packet).
  */
-static int rxkad_verify_packet(struct rxrpc_call *call,
-			       struct sk_buff *skb,
-			       u32 *_abort_code)
+static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
+			       rxrpc_seq_t seq, u16 expected_cksum)
 {
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
-	struct rxrpc_skb_priv *sp;
 	struct rxrpc_crypt iv;
 	struct scatterlist sg;
 	u16 cksum;
 	u32 x, y;
-	int ret;
-
-	sp = rxrpc_skb(skb);
 
 	_enter("{%d{%x}},{#%u}",
-	       call->debug_id, key_serial(call->conn->params.key), sp->hdr.seq);
+	       call->debug_id, key_serial(call->conn->params.key), seq);
 
 	if (!call->conn->cipher)
 		return 0;
 
-	if (sp->hdr.securityIndex != RXRPC_SECURITY_RXKAD) {
-		*_abort_code = RXKADINCONSISTENCY;
-		_leave(" = -EPROTO [not rxkad]");
-		return -EPROTO;
-	}
-
 	/* continue encrypting from where we left off */
 	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
 
 	/* validate the security checksum */
 	x = (call->cid & RXRPC_CHANNELMASK) << (32 - RXRPC_CIDSHIFT);
-	x |= sp->hdr.seq & 0x3fffffff;
+	x |= seq & 0x3fffffff;
 	call->crypto_buf[0] = htonl(call->call_id);
 	call->crypto_buf[1] = htonl(x);
 
@@ -524,29 +519,22 @@ static int rxkad_verify_packet(struct rxrpc_call *call,
 	if (cksum == 0)
 		cksum = 1; /* zero checksums are not permitted */
 
-	if (sp->hdr.cksum != cksum) {
-		*_abort_code = RXKADSEALEDINCON;
+	if (cksum != expected_cksum) {
+		rxrpc_abort_call("VCK", call, seq, RXKADSEALEDINCON, EPROTO);
 		_leave(" = -EPROTO [csum failed]");
 		return -EPROTO;
 	}
 
 	switch (call->conn->params.security_level) {
 	case RXRPC_SECURITY_PLAIN:
-		ret = 0;
-		break;
+		return 0;
 	case RXRPC_SECURITY_AUTH:
-		ret = rxkad_verify_packet_auth(call, skb, _abort_code);
-		break;
+		return rxkad_verify_packet_1(call, skb, seq);
 	case RXRPC_SECURITY_ENCRYPT:
-		ret = rxkad_verify_packet_encrypt(call, skb, _abort_code);
-		break;
+		return rxkad_verify_packet_2(call, skb, seq);
 	default:
-		ret = -ENOANO;
-		break;
+		return -ENOANO;
 	}
-
-	_leave(" = %d", ret);
-	return ret;
 }
 
 /*
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 2439aff131c7..9a4af992fcdf 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -454,14 +454,15 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 /*
  * abort a call, sending an ABORT packet to the peer
  */
-static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
+static void rxrpc_send_abort(struct rxrpc_call *call, const char *why,
+			     u32 abort_code, int error)
 {
 	if (call->state >= RXRPC_CALL_COMPLETE)
 		return;
 
 	write_lock_bh(&call->state_lock);
 
-	if (__rxrpc_abort_call(call, abort_code, ECONNABORTED)) {
+	if (__rxrpc_abort_call(why, call, 0, abort_code, error)) {
 		del_timer_sync(&call->resend_timer);
 		del_timer_sync(&call->ack_timer);
 		clear_bit(RXRPC_CALL_EV_RESEND_TIMER, &call->events);
@@ -556,7 +557,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		/* it's too late for this call */
 		ret = -ESHUTDOWN;
 	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
-		rxrpc_send_abort(call, abort_code);
+		rxrpc_send_abort(call, "CMD", abort_code, ECONNABORTED);
 		ret = 0;
 	} else if (cmd != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
@@ -626,20 +627,19 @@ EXPORT_SYMBOL(rxrpc_kernel_send_data);
  * @sock: The socket the call is on
  * @call: The call to be aborted
  * @abort_code: The abort code to stick into the ABORT packet
+ * @error: Local error value
+ * @why: 3-char string indicating why.
  *
  * Allow a kernel service to abort a call, if it's still in an abortable state.
  */
 void rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
-			     u32 abort_code)
+			     u32 abort_code, int error, const char *why)
 {
-	_enter("{%d},%d", call->debug_id, abort_code);
+	_enter("{%d},%d,%d,%s", call->debug_id, abort_code, error, why);
 
 	lock_sock(sock->sk);
 
-	_debug("CALL %d USR %lx ST %d on CONN %p",
-	       call->debug_id, call->user_call_ID, call->state, call->conn);
-
-	rxrpc_send_abort(call, abort_code);
+	rxrpc_send_abort(call, why, abort_code, error);
 
 	release_sock(sock->sk);
 	_leave("");
