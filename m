From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/3] rxrpc: Calculate serial skew on packet
 reception
Date: Tue, 23 Aug 2016 16:29:08 +0100
Message-ID: <147196614802.28436.3597398428806376695.stgit@warthog.procyon.org.uk>
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

Calculate the serial number skew in the data_ready handler when a packet
has been received and a connection looked up.  The skew is cached in the
sk_buff's priority field.

The connection highest received serial number is updated at this time also.
This can be done without locks or atomic instructions because, at this
point, the code is serialised by the socket.

This generates more accurate skew data because if the packet is offloaded
to a work queue before this is determined, more packets may come in,
bumping the highest serial number and thereby increasing the apparent skew.

This also removes some unnecessary atomic ops.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    7 ++++---
 net/rxrpc/call_event.c  |   18 ++++++++++--------
 net/rxrpc/input.c       |   37 +++++++++++++++++++++++--------------
 net/rxrpc/proc.c        |    2 +-
 net/rxrpc/skbuff.c      |   10 +++++-----
 5 files changed, 43 insertions(+), 31 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 66c917077880..c779b50135f6 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -322,7 +322,7 @@ struct rxrpc_connection {
 	int			error;		/* local error incurred */
 	int			debug_id;	/* debug ID for printks */
 	atomic_t		serial;		/* packet serial number counter */
-	atomic_t		hi_serial;	/* highest serial number received */
+	unsigned int		hi_serial;	/* highest serial number received */
 	atomic_t		avail_chans;	/* number of channels available */
 	u8			size_align;	/* data size alignment (for security) */
 	u8			header_size;	/* rxrpc + security header size */
@@ -457,6 +457,7 @@ struct rxrpc_call {
 	rxrpc_seq_t		ackr_win_top;	/* top of ACK window (rx_data_eaten is bottom) */
 	rxrpc_seq_t		ackr_prev_seq;	/* previous sequence number received */
 	u8			ackr_reason;	/* reason to ACK */
+	u16			ackr_skew;	/* skew on packet being ACK'd */
 	rxrpc_serial_t		ackr_serial;	/* serial of packet being ACK'd */
 	atomic_t		ackr_not_idle;	/* number of packets in Rx queue */
 
@@ -499,8 +500,8 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * call_event.c
  */
-void __rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
-void rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
+void __rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool);
+void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool);
 void rxrpc_process_call(struct work_struct *);
 
 /*
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 3d1267cea9ea..3d1961d82325 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -25,7 +25,7 @@
  * propose an ACK be sent
  */
 void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
-			 u32 serial, bool immediate)
+			 u16 skew, u32 serial, bool immediate)
 {
 	unsigned long expiry;
 	s8 prior = rxrpc_ack_priority[ack_reason];
@@ -44,8 +44,10 @@ void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 	/* update DELAY, IDLE, REQUESTED and PING_RESPONSE ACK serial
 	 * numbers */
 	if (prior == rxrpc_ack_priority[call->ackr_reason]) {
-		if (prior <= 4)
+		if (prior <= 4) {
+			call->ackr_skew = skew;
 			call->ackr_serial = serial;
+		}
 		if (immediate)
 			goto cancel_timer;
 		return;
@@ -103,13 +105,13 @@ cancel_timer:
  * propose an ACK be sent, locking the call structure
  */
 void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
-		       u32 serial, bool immediate)
+		       u16 skew, u32 serial, bool immediate)
 {
 	s8 prior = rxrpc_ack_priority[ack_reason];
 
 	if (prior > rxrpc_ack_priority[call->ackr_reason]) {
 		spin_lock_bh(&call->lock);
-		__rxrpc_propose_ACK(call, ack_reason, serial, immediate);
+		__rxrpc_propose_ACK(call, ack_reason, skew, serial, immediate);
 		spin_unlock_bh(&call->lock);
 	}
 }
@@ -628,7 +630,7 @@ process_further:
 		if (ack.reason == RXRPC_ACK_PING) {
 			_proto("Rx ACK %%%u PING Request", latest);
 			rxrpc_propose_ACK(call, RXRPC_ACK_PING_RESPONSE,
-					  sp->hdr.serial, true);
+					  skb->priority, sp->hdr.serial, true);
 		}
 
 		/* discard any out-of-order or duplicate ACKs */
@@ -1153,8 +1155,7 @@ skip_msg_init:
 	goto maybe_reschedule;
 
 send_ACK_with_skew:
-	ack.maxSkew = htons(atomic_read(&call->conn->hi_serial) -
-			    ntohl(ack.serial));
+	ack.maxSkew = htons(call->ackr_skew);
 send_ACK:
 	mtu = call->conn->params.peer->if_mtu;
 	mtu -= call->conn->params.peer->hdrsize;
@@ -1244,7 +1245,8 @@ send_message_2:
 		case RXRPC_CALL_SERVER_ACK_REQUEST:
 			_debug("start ACK timer");
 			rxrpc_propose_ACK(call, RXRPC_ACK_DELAY,
-					  call->ackr_serial, false);
+					  call->ackr_skew, call->ackr_serial,
+					  false);
 		default:
 			break;
 		}
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 70bb77818dea..34f7431bf494 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -125,6 +125,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 	bool terminal;
 	int ret, ackbit, ack;
 	u32 serial;
+	u16 skew;
 	u8 flags;
 
 	_enter("{%u,%u},,{%u}", call->rx_data_post, call->rx_first_oos, seq);
@@ -133,6 +134,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 	ASSERTCMP(sp->call, ==, NULL);
 	flags = sp->hdr.flags;
 	serial = sp->hdr.serial;
+	skew = skb->priority;
 
 	spin_lock(&call->lock);
 
@@ -231,7 +233,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 
 	spin_unlock(&call->lock);
 	atomic_inc(&call->ackr_not_idle);
-	rxrpc_propose_ACK(call, RXRPC_ACK_DELAY, serial, false);
+	rxrpc_propose_ACK(call, RXRPC_ACK_DELAY, skew, serial, false);
 	_leave(" = 0 [posted]");
 	return 0;
 
@@ -244,7 +246,7 @@ out:
 
 discard_and_ack:
 	_debug("discard and ACK packet %p", skb);
-	__rxrpc_propose_ACK(call, ack, serial, true);
+	__rxrpc_propose_ACK(call, ack, skew, serial, true);
 discard:
 	spin_unlock(&call->lock);
 	rxrpc_free_skb(skb);
@@ -252,7 +254,7 @@ discard:
 	return 0;
 
 enqueue_and_ack:
-	__rxrpc_propose_ACK(call, ack, serial, true);
+	__rxrpc_propose_ACK(call, ack, skew, serial, true);
 enqueue_packet:
 	_net("defer skb %p", skb);
 	spin_unlock(&call->lock);
@@ -304,7 +306,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	__be32 wtmp;
-	u32 hi_serial, abort_code;
+	u32 abort_code;
 
 	_enter("%p,%p", call, skb);
 
@@ -321,18 +323,12 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	}
 #endif
 
-	/* track the latest serial number on this connection for ACK packet
-	 * information */
-	hi_serial = atomic_read(&call->conn->hi_serial);
-	while (sp->hdr.serial > hi_serial)
-		hi_serial = atomic_cmpxchg(&call->conn->hi_serial, hi_serial,
-					   sp->hdr.serial);
-
 	/* request ACK generation for any ACK or DATA packet that requests
 	 * it */
 	if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
 		_proto("ACK Requested on %%%u", sp->hdr.serial);
-		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED, sp->hdr.serial, false);
+		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED,
+				  skb->priority, sp->hdr.serial, false);
 	}
 
 	switch (sp->hdr.type) {
@@ -637,7 +633,7 @@ void rxrpc_data_ready(struct sock *sk)
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_local *local = sk->sk_user_data;
 	struct sk_buff *skb;
-	int ret;
+	int ret, skew;
 
 	_enter("%p", sk);
 
@@ -700,8 +696,21 @@ void rxrpc_data_ready(struct sock *sk)
 	rcu_read_lock();
 
 	conn = rxrpc_find_connection_rcu(local, skb);
-	if (!conn)
+	if (!conn) {
+		skb->priority = 0;
 		goto cant_route_call;
+	}
+
+	/* Note the serial number skew here */
+	skew = (int)sp->hdr.serial - (int)conn->hi_serial;
+	if (skew >= 0) {
+		if (skew > 0)
+			conn->hi_serial = sp->hdr.serial;
+		skb->priority = 0;
+	} else {
+		skew = -skew;
+		skb->priority = min(skew, 65535);
+	}
 
 	if (sp->hdr.callNumber == 0) {
 		/* Connection-level packet */
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index f92de18b5893..31b7f36a39cb 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -165,7 +165,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		   rxrpc_conn_states[conn->state],
 		   key_serial(conn->params.key),
 		   atomic_read(&conn->serial),
-		   atomic_read(&conn->hi_serial));
+		   conn->hi_serial);
 
 	return 0;
 }
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index d28058a97bc1..fbd8c74d9505 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -53,9 +53,9 @@ static void rxrpc_request_final_ACK(struct rxrpc_call *call)
 /*
  * drop the bottom ACK off of the call ACK window and advance the window
  */
-static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
-				struct rxrpc_skb_priv *sp)
+static void rxrpc_hard_ACK_data(struct rxrpc_call *call, struct sk_buff *skb)
 {
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	int loop;
 	u32 seq;
 
@@ -91,8 +91,8 @@ static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
 		 * its Tx bufferage.
 		 */
 		_debug("send Rx idle ACK");
-		__rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, sp->hdr.serial,
-				    false);
+		__rxrpc_propose_ACK(call, RXRPC_ACK_IDLE,
+				    skb->priority, sp->hdr.serial, false);
 	}
 
 	spin_unlock_bh(&call->lock);
@@ -125,7 +125,7 @@ void rxrpc_kernel_data_consumed(struct rxrpc_call *call, struct sk_buff *skb)
 	ASSERTCMP(sp->hdr.seq, >, call->rx_data_eaten);
 
 	call->rx_data_recv = sp->hdr.seq;
-	rxrpc_hard_ACK_data(call, sp);
+	rxrpc_hard_ACK_data(call, skb);
 }
 EXPORT_SYMBOL(rxrpc_kernel_data_consumed);
 
