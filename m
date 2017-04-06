From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/7] rxrpc: Trace protocol errors in received
 packets
Date: Thu, 06 Apr 2017 11:22:43 +0100
Message-ID: <149147416337.21583.6843393427004606193.stgit@warthog.procyon.org.uk>
References: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9271 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934382AbdDFKWp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 06:22:45 -0400
In-Reply-To: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a tracepoint (rxrpc_rx_proto) to record protocol errors in received
packets.  The following changes are made:

 (1) Add a function, __rxrpc_abort_eproto(), to note a protocol error on a
     call and mark the call aborted.  This is wrapped by
     rxrpc_abort_eproto() that makes the why string usable in trace.

 (2) Add trace_rxrpc_rx_proto() or rxrpc_abort_eproto() to protocol error
     generation points, replacing rxrpc_abort_call() with the latter.

 (3) Only send an abort packet in rxkad_verify_packet*() if we actually
     managed to abort the call.

Note that a trace event is also emitted if a kernel user (e.g. afs) tries
to send data through a call when it's not in the transmission phase, though
it's not technically a receive event.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   24 ++++++++++
 net/rxrpc/ar-internal.h      |   19 ++++++++
 net/rxrpc/conn_event.c       |    9 ++--
 net/rxrpc/input.c            |    5 ++
 net/rxrpc/insecure.c         |   10 +++-
 net/rxrpc/recvmsg.c          |    2 +
 net/rxrpc/rxkad.c            |  106 +++++++++++++++++++++++++++++-------------
 net/rxrpc/sendmsg.c          |    3 +
 8 files changed, 138 insertions(+), 40 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 39123c06a566..626af97863e8 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -1087,6 +1087,30 @@ TRACE_EVENT(rxrpc_improper_term,
 		      __entry->abort_code)
 	    );
 
+TRACE_EVENT(rxrpc_rx_eproto,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_serial_t serial,
+		     const char *why),
+
+	    TP_ARGS(call, serial, why),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(const char *,		why		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->serial = serial;
+		    __entry->why = why;
+			   ),
+
+	    TP_printk("c=%p EPROTO %08x %s",
+		      __entry->call,
+		      __entry->serial,
+		      __entry->why)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 26a7b1db1361..7486926e60a8 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -740,6 +740,25 @@ static inline bool rxrpc_abort_call(const char *why, struct rxrpc_call *call,
 }
 
 /*
+ * Abort a call due to a protocol error.
+ */
+static inline bool __rxrpc_abort_eproto(struct rxrpc_call *call,
+					struct sk_buff *skb,
+					const char *eproto_why,
+					const char *why,
+					u32 abort_code)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	trace_rxrpc_rx_eproto(call, sp->hdr.serial, eproto_why);
+	return rxrpc_abort_call(why, call, sp->hdr.seq, abort_code, -EPROTO);
+}
+
+#define rxrpc_abort_eproto(call, skb, eproto_why, abort_why, abort_code) \
+	__rxrpc_abort_eproto((call), (skb), tracepoint_string(eproto_why), \
+			     (abort_why), (abort_code))
+
+/*
  * conn_client.c
  */
 extern unsigned int rxrpc_max_client_connections;
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index f9d1d9cc86d8..46babcf82ce8 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -281,8 +281,11 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 
 	case RXRPC_PACKET_TYPE_ABORT:
 		if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
-				  &wtmp, sizeof(wtmp)) < 0)
+				  &wtmp, sizeof(wtmp)) < 0) {
+			trace_rxrpc_rx_eproto(NULL, sp->hdr.serial,
+					      tracepoint_string("bad_abort"));
 			return -EPROTO;
+		}
 		abort_code = ntohl(wtmp);
 		_proto("Rx ABORT %%%u { ac=%d }", sp->hdr.serial, abort_code);
 
@@ -327,7 +330,8 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		return 0;
 
 	default:
-		_leave(" = -EPROTO [%u]", sp->hdr.type);
+		trace_rxrpc_rx_eproto(NULL, sp->hdr.serial,
+				      tracepoint_string("bad_conn_pkt"));
 		return -EPROTO;
 	}
 }
@@ -422,6 +426,5 @@ void rxrpc_process_connection(struct work_struct *work)
 	if (rxrpc_abort_connection(conn, ret, abort_code) < 0)
 		goto requeue_and_leave;
 	rxrpc_free_skb(skb, rxrpc_skb_rx_freed);
-	_leave(" [EPROTO]");
 	goto out;
 }
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 3a7754c87aef..3685dbe05a8f 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -1017,8 +1017,11 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
 	struct rxrpc_wire_header whdr;
 
 	/* dig out the RxRPC connection details */
-	if (skb_copy_bits(skb, 0, &whdr, sizeof(whdr)) < 0)
+	if (skb_copy_bits(skb, 0, &whdr, sizeof(whdr)) < 0) {
+		trace_rxrpc_rx_eproto(NULL, sp->hdr.serial,
+				      tracepoint_string("bad_hdr"));
 		return -EBADMSG;
+	}
 
 	memset(sp, 0, sizeof(*sp));
 	sp->hdr.epoch		= ntohl(whdr.epoch);
diff --git a/net/rxrpc/insecure.c b/net/rxrpc/insecure.c
index 7d4375e557e6..af276f173b10 100644
--- a/net/rxrpc/insecure.c
+++ b/net/rxrpc/insecure.c
@@ -46,7 +46,10 @@ static int none_respond_to_challenge(struct rxrpc_connection *conn,
 				     struct sk_buff *skb,
 				     u32 *_abort_code)
 {
-	*_abort_code = RX_PROTOCOL_ERROR;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	trace_rxrpc_rx_eproto(NULL, sp->hdr.serial,
+			      tracepoint_string("chall_none"));
 	return -EPROTO;
 }
 
@@ -54,7 +57,10 @@ static int none_verify_response(struct rxrpc_connection *conn,
 				struct sk_buff *skb,
 				u32 *_abort_code)
 {
-	*_abort_code = RX_PROTOCOL_ERROR;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	trace_rxrpc_rx_eproto(NULL, sp->hdr.serial,
+			      tracepoint_string("resp_none"));
 	return -EPROTO;
 }
 
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index ad1a815b9706..f9caf3b77509 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -682,9 +682,11 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 	return ret;
 
 short_data:
+	trace_rxrpc_rx_eproto(call, 0, tracepoint_string("short_data"));
 	ret = -EBADMSG;
 	goto out;
 excess_data:
+	trace_rxrpc_rx_eproto(call, 0, tracepoint_string("excess_data"));
 	ret = -EMSGSIZE;
 	goto out;
 call_complete:
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 988903f1dc80..1bb9b2ccc267 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -148,15 +148,13 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 				    u32 data_size,
 				    void *sechdr)
 {
-	struct rxrpc_skb_priv *sp;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxkad_level1_hdr hdr;
 	struct rxrpc_crypt iv;
 	struct scatterlist sg;
 	u16 check;
 
-	sp = rxrpc_skb(skb);
-
 	_enter("");
 
 	check = sp->hdr.seq ^ call->call_id;
@@ -323,6 +321,7 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[16];
 	struct sk_buff *trailer;
+	bool aborted;
 	u32 data_size, buf;
 	u16 check;
 	int nsg;
@@ -330,7 +329,8 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	_enter("");
 
 	if (len < 8) {
-		rxrpc_abort_call("V1H", call, seq, RXKADSEALEDINCON, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_1_hdr", "V1H",
+					   RXKADSEALEDINCON);
 		goto protocol_error;
 	}
 
@@ -355,7 +355,8 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 
 	/* Extract the decrypted packet length */
 	if (skb_copy_bits(skb, offset, &sechdr, sizeof(sechdr)) < 0) {
-		rxrpc_abort_call("XV1", call, seq, RXKADDATALEN, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_1_len", "XV1",
+					     RXKADDATALEN);
 		goto protocol_error;
 	}
 	offset += sizeof(sechdr);
@@ -368,12 +369,14 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	check ^= seq ^ call->call_id;
 	check &= 0xffff;
 	if (check != 0) {
-		rxrpc_abort_call("V1C", call, seq, RXKADSEALEDINCON, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_1_check", "V1C",
+					     RXKADSEALEDINCON);
 		goto protocol_error;
 	}
 
 	if (data_size > len) {
-		rxrpc_abort_call("V1L", call, seq, RXKADDATALEN, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_1_datalen", "V1L",
+					     RXKADDATALEN);
 		goto protocol_error;
 	}
 
@@ -381,8 +384,8 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	return 0;
 
 protocol_error:
-	rxrpc_send_abort_packet(call);
-	_leave(" = -EPROTO");
+	if (aborted)
+		rxrpc_send_abort_packet(call);
 	return -EPROTO;
 
 nomem:
@@ -403,6 +406,7 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	struct rxrpc_crypt iv;
 	struct scatterlist _sg[4], *sg;
 	struct sk_buff *trailer;
+	bool aborted;
 	u32 data_size, buf;
 	u16 check;
 	int nsg;
@@ -410,7 +414,8 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	_enter(",{%d}", skb->len);
 
 	if (len < 8) {
-		rxrpc_abort_call("V2H", call, seq, RXKADSEALEDINCON, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_2_hdr", "V2H",
+					     RXKADSEALEDINCON);
 		goto protocol_error;
 	}
 
@@ -445,7 +450,8 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 
 	/* Extract the decrypted packet length */
 	if (skb_copy_bits(skb, offset, &sechdr, sizeof(sechdr)) < 0) {
-		rxrpc_abort_call("XV2", call, seq, RXKADDATALEN, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_2_len", "XV2",
+					     RXKADDATALEN);
 		goto protocol_error;
 	}
 	offset += sizeof(sechdr);
@@ -458,12 +464,14 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	check ^= seq ^ call->call_id;
 	check &= 0xffff;
 	if (check != 0) {
-		rxrpc_abort_call("V2C", call, seq, RXKADSEALEDINCON, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_2_check", "V2C",
+					     RXKADSEALEDINCON);
 		goto protocol_error;
 	}
 
 	if (data_size > len) {
-		rxrpc_abort_call("V2L", call, seq, RXKADDATALEN, -EPROTO);
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_2_datalen", "V2L",
+					     RXKADDATALEN);
 		goto protocol_error;
 	}
 
@@ -471,8 +479,8 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	return 0;
 
 protocol_error:
-	rxrpc_send_abort_packet(call);
-	_leave(" = -EPROTO");
+	if (aborted)
+		rxrpc_send_abort_packet(call);
 	return -EPROTO;
 
 nomem:
@@ -491,6 +499,7 @@ static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist sg;
+	bool aborted;
 	u16 cksum;
 	u32 x, y;
 
@@ -522,10 +531,9 @@ static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 		cksum = 1; /* zero checksums are not permitted */
 
 	if (cksum != expected_cksum) {
-		rxrpc_abort_call("VCK", call, seq, RXKADSEALEDINCON, -EPROTO);
-		rxrpc_send_abort_packet(call);
-		_leave(" = -EPROTO [csum failed]");
-		return -EPROTO;
+		aborted = rxrpc_abort_eproto(call, skb, "rxkad_csum", "VCK",
+					     RXKADSEALEDINCON);
+		goto protocol_error;
 	}
 
 	switch (call->conn->params.security_level) {
@@ -538,6 +546,11 @@ static int rxkad_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	default:
 		return -ENOANO;
 	}
+
+protocol_error:
+	if (aborted)
+		rxrpc_send_abort_packet(call);
+	return -EPROTO;
 }
 
 /*
@@ -754,11 +767,13 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	struct rxkad_response resp
 		__attribute__((aligned(8))); /* must be aligned for crypto */
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	const char *eproto;
 	u32 version, nonce, min_level, abort_code;
 	int ret;
 
 	_enter("{%d,%x}", conn->debug_id, key_serial(conn->params.key));
 
+	eproto = tracepoint_string("chall_no_key");
 	abort_code = RX_PROTOCOL_ERROR;
 	if (!conn->params.key)
 		goto protocol_error;
@@ -768,6 +783,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	if (ret < 0)
 		goto other_error;
 
+	eproto = tracepoint_string("chall_short");
 	abort_code = RXKADPACKETSHORT;
 	if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
 			  &challenge, sizeof(challenge)) < 0)
@@ -780,6 +796,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	_proto("Rx CHALLENGE %%%u { v=%u n=%u ml=%u }",
 	       sp->hdr.serial, version, nonce, min_level);
 
+	eproto = tracepoint_string("chall_ver");
 	abort_code = RXKADINCONSISTENCY;
 	if (version != RXKAD_VERSION)
 		goto protocol_error;
@@ -814,6 +831,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	return rxkad_send_response(conn, &sp->hdr, &resp, token->kad);
 
 protocol_error:
+	trace_rxrpc_rx_eproto(NULL, sp->hdr.serial, eproto);
 	ret = -EPROTO;
 other_error:
 	*_abort_code = abort_code;
@@ -824,19 +842,23 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
  * decrypt the kerberos IV ticket in the response
  */
 static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
+				struct sk_buff *skb,
 				void *ticket, size_t ticket_len,
 				struct rxrpc_crypt *_session_key,
 				time_t *_expiry,
 				u32 *_abort_code)
 {
 	struct skcipher_request *req;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_crypt iv, key;
 	struct scatterlist sg[1];
 	struct in_addr addr;
 	unsigned int life;
+	const char *eproto;
 	time_t issue, now;
 	bool little_endian;
 	int ret;
+	u32 abort_code;
 	u8 *p, *q, *name, *end;
 
 	_enter("{%d},{%x}", conn->debug_id, key_serial(conn->server_key));
@@ -847,10 +869,10 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	if (ret < 0) {
 		switch (ret) {
 		case -EKEYEXPIRED:
-			*_abort_code = RXKADEXPIRED;
+			abort_code = RXKADEXPIRED;
 			goto other_error;
 		default:
-			*_abort_code = RXKADNOAUTH;
+			abort_code = RXKADNOAUTH;
 			goto other_error;
 		}
 	}
@@ -875,11 +897,12 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	p = ticket;
 	end = p + ticket_len;
 
-#define Z(size)						\
+#define Z(field)					\
 	({						\
 		u8 *__str = p;				\
+		eproto = tracepoint_string("rxkad_bad_"#field); \
 		q = memchr(p, 0, end - p);		\
-		if (!q || q - p > (size))		\
+		if (!q || q - p > (field##_SZ))		\
 			goto bad_ticket;		\
 		for (; p < q; p++)			\
 			if (!isprint(*p))		\
@@ -894,17 +917,18 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	p++;
 
 	/* extract the authentication name */
-	name = Z(ANAME_SZ);
+	name = Z(ANAME);
 	_debug("KIV ANAME: %s", name);
 
 	/* extract the principal's instance */
-	name = Z(INST_SZ);
+	name = Z(INST);
 	_debug("KIV INST : %s", name);
 
 	/* extract the principal's authentication domain */
-	name = Z(REALM_SZ);
+	name = Z(REALM);
 	_debug("KIV REALM: %s", name);
 
+	eproto = tracepoint_string("rxkad_bad_len");
 	if (end - p < 4 + 8 + 4 + 2)
 		goto bad_ticket;
 
@@ -939,13 +963,13 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 
 	/* check the ticket is in date */
 	if (issue > now) {
-		*_abort_code = RXKADNOAUTH;
+		abort_code = RXKADNOAUTH;
 		ret = -EKEYREJECTED;
 		goto other_error;
 	}
 
 	if (issue < now - life) {
-		*_abort_code = RXKADEXPIRED;
+		abort_code = RXKADEXPIRED;
 		ret = -EKEYEXPIRED;
 		goto other_error;
 	}
@@ -953,18 +977,20 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	*_expiry = issue + life;
 
 	/* get the service name */
-	name = Z(SNAME_SZ);
+	name = Z(SNAME);
 	_debug("KIV SNAME: %s", name);
 
 	/* get the service instance name */
-	name = Z(INST_SZ);
+	name = Z(INST);
 	_debug("KIV SINST: %s", name);
 	return 0;
 
 bad_ticket:
-	*_abort_code = RXKADBADTICKET;
+	trace_rxrpc_rx_eproto(NULL, sp->hdr.serial, eproto);
+	abort_code = RXKADBADTICKET;
 	ret = -EPROTO;
 other_error:
+	*_abort_code = abort_code;
 	return ret;
 temporary_error:
 	return ret;
@@ -1017,6 +1043,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 		__attribute__((aligned(8))); /* must be aligned for crypto */
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_crypt session_key;
+	const char *eproto;
 	time_t expiry;
 	void *ticket;
 	u32 abort_code, version, kvno, ticket_len, level;
@@ -1025,6 +1052,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 
 	_enter("{%d,%x}", conn->debug_id, key_serial(conn->server_key));
 
+	eproto = tracepoint_string("rxkad_rsp_short");
 	abort_code = RXKADPACKETSHORT;
 	if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
 			  &response, sizeof(response)) < 0)
@@ -1038,14 +1066,17 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	_proto("Rx RESPONSE %%%u { v=%u kv=%u tl=%u }",
 	       sp->hdr.serial, version, kvno, ticket_len);
 
+	eproto = tracepoint_string("rxkad_rsp_ver");
 	abort_code = RXKADINCONSISTENCY;
 	if (version != RXKAD_VERSION)
 		goto protocol_error;
 
+	eproto = tracepoint_string("rxkad_rsp_tktlen");
 	abort_code = RXKADTICKETLEN;
 	if (ticket_len < 4 || ticket_len > MAXKRB5TICKETLEN)
 		goto protocol_error;
 
+	eproto = tracepoint_string("rxkad_rsp_unkkey");
 	abort_code = RXKADUNKNOWNKEY;
 	if (kvno >= RXKAD_TKT_TYPE_KERBEROS_V5)
 		goto protocol_error;
@@ -1056,12 +1087,13 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	if (!ticket)
 		goto temporary_error;
 
+	eproto = tracepoint_string("rxkad_tkt_short");
 	abort_code = RXKADPACKETSHORT;
 	if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
 			  ticket, ticket_len) < 0)
 		goto protocol_error_free;
 
-	ret = rxkad_decrypt_ticket(conn, ticket, ticket_len, &session_key,
+	ret = rxkad_decrypt_ticket(conn, skb, ticket, ticket_len, &session_key,
 				   &expiry, _abort_code);
 	if (ret < 0)
 		goto temporary_error_free;
@@ -1070,6 +1102,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	 * response */
 	rxkad_decrypt_response(conn, &response, &session_key);
 
+	eproto = tracepoint_string("rxkad_rsp_param");
 	abort_code = RXKADSEALEDINCON;
 	if (ntohl(response.encrypted.epoch) != conn->proto.epoch)
 		goto protocol_error_free;
@@ -1080,6 +1113,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	csum = response.encrypted.checksum;
 	response.encrypted.checksum = 0;
 	rxkad_calc_response_checksum(&response);
+	eproto = tracepoint_string("rxkad_rsp_csum");
 	if (response.encrypted.checksum != csum)
 		goto protocol_error_free;
 
@@ -1088,11 +1122,15 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 		struct rxrpc_call *call;
 		u32 call_id = ntohl(response.encrypted.call_id[i]);
 
+		eproto = tracepoint_string("rxkad_rsp_callid");
 		if (call_id > INT_MAX)
 			goto protocol_error_unlock;
 
+		eproto = tracepoint_string("rxkad_rsp_callctr");
 		if (call_id < conn->channels[i].call_counter)
 			goto protocol_error_unlock;
+
+		eproto = tracepoint_string("rxkad_rsp_callst");
 		if (call_id > conn->channels[i].call_counter) {
 			call = rcu_dereference_protected(
 				conn->channels[i].call,
@@ -1104,10 +1142,12 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	}
 	spin_unlock(&conn->channel_lock);
 
+	eproto = tracepoint_string("rxkad_rsp_seq");
 	abort_code = RXKADOUTOFSEQUENCE;
 	if (ntohl(response.encrypted.inc_nonce) != conn->security_nonce + 1)
 		goto protocol_error_free;
 
+	eproto = tracepoint_string("rxkad_rsp_level");
 	abort_code = RXKADLEVELFAIL;
 	level = ntohl(response.encrypted.level);
 	if (level > RXRPC_SECURITY_ENCRYPT)
@@ -1130,8 +1170,8 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 protocol_error_free:
 	kfree(ticket);
 protocol_error:
+	trace_rxrpc_rx_eproto(NULL, sp->hdr.serial, eproto);
 	*_abort_code = abort_code;
-	_leave(" = -EPROTO [%d]", abort_code);
 	return -EPROTO;
 
 temporary_error_free:
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index e836fa00dc5a..96ffa5d5733b 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -623,7 +623,8 @@ int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
 		read_unlock_bh(&call->state_lock);
 		break;
 	default:
-		 /* Request phase complete for this client call */
+		/* Request phase complete for this client call */
+		trace_rxrpc_rx_eproto(call, 0, tracepoint_string("late_send"));
 		ret = -EPROTO;
 		break;
 	}
