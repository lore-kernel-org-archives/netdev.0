From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/9] rxrpc: Obtain RTT data by requesting ACKs on
 DATA packets [ver #2]
Date: Thu, 22 Sep 2016 09:22:49 +0100
Message-ID: <147453256904.14579.18082219393930883088.stgit@warthog.procyon.org.uk>
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

In addition to sending a PING ACK to gain RTT data, we can set the
RXRPC_REQUEST_ACK flag on a DATA packet and get a REQUESTED-ACK ACK.  The
ACK packet contains the serial number of the packet it is in response to,
so we can look through the Tx buffer for a matching DATA packet.

This requires that the data packets be stamped with the time of
transmission as a ktime rather than having the resend_at time in jiffies.

This further requires the resend code to do the resend determination in
ktimes and convert to jiffies to set the timer.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    7 +++----
 net/rxrpc/call_event.c  |   19 +++++++++----------
 net/rxrpc/input.c       |   35 +++++++++++++++++++++++++++++++++++
 net/rxrpc/misc.c        |    6 ++++--
 net/rxrpc/output.c      |    7 +++++--
 net/rxrpc/sendmsg.c     |    1 -
 net/rxrpc/sysctl.c      |    2 +-
 7 files changed, 57 insertions(+), 20 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 8b47f468eb9d..1c4597b2c6cd 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -142,10 +142,7 @@ struct rxrpc_host_header {
  */
 struct rxrpc_skb_priv {
 	union {
-		unsigned long	resend_at;	/* time in jiffies at which to resend */
-		struct {
-			u8	nr_jumbo;	/* Number of jumbo subpackets */
-		};
+		u8		nr_jumbo;	/* Number of jumbo subpackets */
 	};
 	union {
 		unsigned int	offset;		/* offset into buffer of next read */
@@ -663,6 +660,7 @@ extern const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5];
 
 enum rxrpc_rtt_tx_trace {
 	rxrpc_rtt_tx_ping,
+	rxrpc_rtt_tx_data,
 	rxrpc_rtt_tx__nr_trace
 };
 
@@ -670,6 +668,7 @@ extern const char rxrpc_rtt_tx_traces[rxrpc_rtt_tx__nr_trace][5];
 
 enum rxrpc_rtt_rx_trace {
 	rxrpc_rtt_rx_ping_response,
+	rxrpc_rtt_rx_requested_ack,
 	rxrpc_rtt_rx__nr_trace
 };
 
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 34ad967f2d81..adb2ec61e21f 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -142,12 +142,14 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
 	rxrpc_seq_t cursor, seq, top;
-	unsigned long resend_at, now;
+	ktime_t now = ktime_get_real(), max_age, oldest, resend_at;
 	int ix;
 	u8 annotation, anno_type;
 
 	_enter("{%d,%d}", call->tx_hard_ack, call->tx_top);
 
+	max_age = ktime_sub_ms(now, rxrpc_resend_timeout);
+
 	spin_lock_bh(&call->lock);
 
 	cursor = call->tx_hard_ack;
@@ -160,8 +162,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	 * the packets in the Tx buffer we're going to resend and what the new
 	 * resend timeout will be.
 	 */
-	now = jiffies;
-	resend_at = now + rxrpc_resend_timeout;
+	oldest = now;
 	for (seq = cursor + 1; before_eq(seq, top); seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
 		annotation = call->rxtx_annotations[ix];
@@ -175,9 +176,9 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		sp = rxrpc_skb(skb);
 
 		if (anno_type == RXRPC_TX_ANNO_UNACK) {
-			if (time_after(sp->resend_at, now)) {
-				if (time_before(sp->resend_at, resend_at))
-					resend_at = sp->resend_at;
+			if (ktime_after(skb->tstamp, max_age)) {
+				if (ktime_before(skb->tstamp, oldest))
+					oldest = skb->tstamp;
 				continue;
 			}
 		}
@@ -186,7 +187,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS | annotation;
 	}
 
-	call->resend_at = resend_at;
+	resend_at = ktime_sub(ktime_add_ns(oldest, rxrpc_resend_timeout), now);
+	call->resend_at = jiffies + nsecs_to_jiffies(ktime_to_ns(resend_at));
 
 	/* Now go through the Tx window and perform the retransmissions.  We
 	 * have to drop the lock for each send.  If an ACK comes in whilst the
@@ -205,15 +207,12 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		spin_unlock_bh(&call->lock);
 
 		if (rxrpc_send_data_packet(call, skb) < 0) {
-			call->resend_at = now + 2;
 			rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
 			return;
 		}
 
 		if (rxrpc_is_client_call(call))
 			rxrpc_expose_client_call(call);
-		sp = rxrpc_skb(skb);
-		sp->resend_at = now + rxrpc_resend_timeout;
 
 		rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
 		spin_lock_bh(&call->lock);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index a0a5bd108c9e..c121949de3c8 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -356,6 +356,38 @@ ack:
 }
 
 /*
+ * Process a requested ACK.
+ */
+static void rxrpc_input_requested_ack(struct rxrpc_call *call,
+				      ktime_t resp_time,
+				      rxrpc_serial_t orig_serial,
+				      rxrpc_serial_t ack_serial)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	ktime_t sent_at;
+	int ix;
+
+	for (ix = 0; ix < RXRPC_RXTX_BUFF_SIZE; ix++) {
+		skb = call->rxtx_buffer[ix];
+		if (!skb)
+			continue;
+
+		sp = rxrpc_skb(skb);
+		if (sp->hdr.serial != orig_serial)
+			continue;
+		smp_rmb();
+		sent_at = skb->tstamp;
+		goto found;
+	}
+	return;
+
+found:
+	rxrpc_peer_add_rtt(call, rxrpc_rtt_rx_requested_ack,
+			   orig_serial, ack_serial, sent_at, resp_time);
+}
+
+/*
  * Process a ping response.
  */
 static void rxrpc_input_ping_response(struct rxrpc_call *call,
@@ -508,6 +540,9 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	if (buf.ack.reason == RXRPC_ACK_PING_RESPONSE)
 		rxrpc_input_ping_response(call, skb->tstamp, acked_serial,
 					  sp->hdr.serial);
+	if (buf.ack.reason == RXRPC_ACK_REQUESTED)
+		rxrpc_input_requested_ack(call, skb->tstamp, acked_serial,
+					  sp->hdr.serial);
 
 	if (buf.ack.reason == RXRPC_ACK_PING) {
 		_proto("Rx ACK %%%u PING Request", sp->hdr.serial);
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 56e668352fc7..0d425e707f22 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -68,9 +68,9 @@ unsigned int rxrpc_rx_mtu = 5692;
 unsigned int rxrpc_rx_jumbo_max = 4;
 
 /*
- * Time till packet resend (in jiffies).
+ * Time till packet resend (in milliseconds).
  */
-unsigned int rxrpc_resend_timeout = 4 * HZ;
+unsigned int rxrpc_resend_timeout = 4 * 1000;
 
 const char *const rxrpc_pkts[] = {
 	"?00",
@@ -186,8 +186,10 @@ const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5] = {
 
 const char rxrpc_rtt_tx_traces[rxrpc_rtt_tx__nr_trace][5] = {
 	[rxrpc_rtt_tx_ping]		= "PING",
+	[rxrpc_rtt_tx_data]		= "DATA",
 };
 
 const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5] = {
 	[rxrpc_rtt_rx_ping_response]	= "PONG",
+	[rxrpc_rtt_rx_requested_ack]	= "RACK",
 };
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 0d89cd3f2c01..db01fbb70d23 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -300,9 +300,12 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		goto send_fragmentable;
 
 done:
-	if (ret == 0) {
-		sp->resend_at = jiffies + rxrpc_resend_timeout;
+	if (ret >= 0) {
+		skb->tstamp = ktime_get_real();
+		smp_wmb();
 		sp->hdr.serial = serial;
+		if (whdr.flags & RXRPC_REQUEST_ACK)
+			trace_rxrpc_rtt_tx(call, rxrpc_rtt_tx_data, serial);
 	}
 	_leave(" = %d [%u]", ret, call->peer->maxdata);
 	return ret;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 3c969de3ef05..607223f4f871 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -137,7 +137,6 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	if (seq == 1 && rxrpc_is_client_call(call))
 		rxrpc_expose_client_call(call);
 
-	sp->resend_at = jiffies + rxrpc_resend_timeout;
 	ret = rxrpc_send_data_packet(call, skb);
 	if (ret < 0) {
 		_debug("need instant resend %d", ret);
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index a03c61c672f5..13d1df03ebac 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -59,7 +59,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 		.data		= &rxrpc_resend_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_ms_jiffies,
+		.proc_handler	= proc_dointvec,
 		.extra1		= (void *)&one,
 	},
 	{
