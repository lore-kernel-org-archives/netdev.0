From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/7] rxrpc: The offset field in struct
 rxrpc_skb_priv is unnecessary
Date: Fri, 30 Sep 2016 22:40:39 +0100
Message-ID: <147527163936.28826.1502641310741683648.stgit@warthog.procyon.org.uk>
References: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The offset field in struct rxrpc_skb_priv is unnecessary as the value can
always be calculated.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 -
 net/rxrpc/conn_event.c  |    3 ++-
 net/rxrpc/input.c       |   23 ++++++++++++-----------
 net/rxrpc/local_event.c |    3 ++-
 net/rxrpc/recvmsg.c     |    6 ++----
 net/rxrpc/rxkad.c       |    9 ++++++---
 6 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 539db54697f9..fd64a2bd1072 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -144,7 +144,6 @@ struct rxrpc_skb_priv {
 		u8		nr_jumbo;	/* Number of jumbo subpackets */
 	};
 	union {
-		unsigned int	offset;		/* offset into buffer of next read */
 		int		remain;		/* amount of space remaining for next write */
 		u32		error;		/* network error code */
 	};
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 37609ce89f52..3f9d8d7ec632 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -276,7 +276,8 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		return 0;
 
 	case RXRPC_PACKET_TYPE_ABORT:
-		if (skb_copy_bits(skb, sp->offset, &wtmp, sizeof(wtmp)) < 0)
+		if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
+				  &wtmp, sizeof(wtmp)) < 0)
 			return -EPROTO;
 		abort_code = ntohl(wtmp);
 		_proto("Rx ABORT %%%u { ac=%d }", sp->hdr.serial, abort_code);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 7993473e56bb..5ba35b4a907b 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -358,7 +358,7 @@ static bool rxrpc_receiving_reply(struct rxrpc_call *call)
 static bool rxrpc_validate_jumbo(struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	unsigned int offset = sp->offset;
+	unsigned int offset = sizeof(struct rxrpc_wire_header);
 	unsigned int len = skb->len;
 	int nr_jumbo = 1;
 	u8 flags = sp->hdr.flags;
@@ -419,7 +419,7 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 			     u16 skew)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	unsigned int offset = sp->offset;
+	unsigned int offset = sizeof(struct rxrpc_wire_header);
 	unsigned int ix;
 	rxrpc_serial_t serial = sp->hdr.serial, ack_serial = 0;
 	rxrpc_seq_t seq = sp->hdr.seq, hard_ack;
@@ -746,15 +746,16 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	} buf;
 	rxrpc_serial_t acked_serial;
 	rxrpc_seq_t first_soft_ack, hard_ack;
-	int nr_acks, offset;
+	int nr_acks, offset, ioffset;
 
 	_enter("");
 
-	if (skb_copy_bits(skb, sp->offset, &buf.ack, sizeof(buf.ack)) < 0) {
+	offset = sizeof(struct rxrpc_wire_header);
+	if (skb_copy_bits(skb, offset, &buf.ack, sizeof(buf.ack)) < 0) {
 		_debug("extraction failure");
 		return rxrpc_proto_abort("XAK", call, 0);
 	}
-	sp->offset += sizeof(buf.ack);
+	offset += sizeof(buf.ack);
 
 	acked_serial = ntohl(buf.ack.serial);
 	first_soft_ack = ntohl(buf.ack.firstPacket);
@@ -792,9 +793,9 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 				  rxrpc_propose_ack_respond_to_ack);
 	}
 
-	offset = sp->offset + nr_acks + 3;
-	if (skb->len >= offset + sizeof(buf.info)) {
-		if (skb_copy_bits(skb, offset, &buf.info, sizeof(buf.info)) < 0)
+	ioffset = offset + nr_acks + 3;
+	if (skb->len >= ioffset + sizeof(buf.info)) {
+		if (skb_copy_bits(skb, ioffset, &buf.info, sizeof(buf.info)) < 0)
 			return rxrpc_proto_abort("XAI", call, 0);
 		rxrpc_input_ackinfo(call, skb, &buf.info);
 	}
@@ -832,7 +833,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 		rxrpc_rotate_tx_window(call, hard_ack, &summary);
 
 	if (nr_acks > 0) {
-		if (skb_copy_bits(skb, sp->offset, buf.acks, nr_acks) < 0)
+		if (skb_copy_bits(skb, offset, buf.acks, nr_acks) < 0)
 			return rxrpc_proto_abort("XSA", call, 0);
 		rxrpc_input_soft_acks(call, buf.acks, first_soft_ack, nr_acks,
 				      &summary);
@@ -880,7 +881,8 @@ static void rxrpc_input_abort(struct rxrpc_call *call, struct sk_buff *skb)
 	_enter("");
 
 	if (skb->len >= 4 &&
-	    skb_copy_bits(skb, sp->offset, &wtmp, sizeof(wtmp)) >= 0)
+	    skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
+			  &wtmp, sizeof(wtmp)) >= 0)
 		abort_code = ntohl(wtmp);
 
 	_proto("Rx ABORT %%%u { %x }", sp->hdr.serial, abort_code);
@@ -996,7 +998,6 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
 	sp->hdr.securityIndex	= whdr.securityIndex;
 	sp->hdr._rsvd		= ntohs(whdr._rsvd);
 	sp->hdr.serviceId	= ntohs(whdr.serviceId);
-	sp->offset = sizeof(whdr);
 	return 0;
 }
 
diff --git a/net/rxrpc/local_event.c b/net/rxrpc/local_event.c
index 190f68bd9e27..540d3955c1bc 100644
--- a/net/rxrpc/local_event.c
+++ b/net/rxrpc/local_event.c
@@ -95,7 +95,8 @@ void rxrpc_process_local_events(struct rxrpc_local *local)
 
 		switch (sp->hdr.type) {
 		case RXRPC_PACKET_TYPE_VERSION:
-			if (skb_copy_bits(skb, sp->offset, &v, 1) < 0)
+			if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
+					  &v, 1) < 0)
 				return;
 			_proto("Rx VERSION { %02x }", v);
 			if (v == 0)
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 038ae62ddb4d..f05ea0a88076 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -261,15 +261,13 @@ static int rxrpc_locate_data(struct rxrpc_call *call, struct sk_buff *skb,
 			     u8 *_annotation,
 			     unsigned int *_offset, unsigned int *_len)
 {
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	unsigned int offset = *_offset;
+	unsigned int offset = sizeof(struct rxrpc_wire_header);
 	unsigned int len = *_len;
 	int ret;
 	u8 annotation = *_annotation;
 
 	/* Locate the subpacket */
-	offset = sp->offset;
-	len = skb->len - sp->offset;
+	len = skb->len - offset;
 	if ((annotation & RXRPC_RX_ANNO_JUMBO) > 0) {
 		offset += (((annotation & RXRPC_RX_ANNO_JUMBO) - 1) *
 			   RXRPC_JUMBO_SUBPKTLEN);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 88d080a1a3de..627abed5f999 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -771,7 +771,8 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	}
 
 	abort_code = RXKADPACKETSHORT;
-	if (skb_copy_bits(skb, sp->offset, &challenge, sizeof(challenge)) < 0)
+	if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
+			  &challenge, sizeof(challenge)) < 0)
 		goto protocol_error;
 
 	version = ntohl(challenge.version);
@@ -1028,7 +1029,8 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	_enter("{%d,%x}", conn->debug_id, key_serial(conn->server_key));
 
 	abort_code = RXKADPACKETSHORT;
-	if (skb_copy_bits(skb, sp->offset, &response, sizeof(response)) < 0)
+	if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
+			  &response, sizeof(response)) < 0)
 		goto protocol_error;
 	if (!pskb_pull(skb, sizeof(response)))
 		BUG();
@@ -1057,7 +1059,8 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 		return -ENOMEM;
 
 	abort_code = RXKADPACKETSHORT;
-	if (skb_copy_bits(skb, sp->offset, ticket, ticket_len) < 0)
+	if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
+			  ticket, ticket_len) < 0)
 		goto protocol_error_free;
 
 	ret = rxkad_decrypt_ticket(conn, ticket, ticket_len, &session_key,
