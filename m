From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 10/10] rxrpc: Correctly initialise,
 limit and transmit call->rx_winsize
Date: Tue, 13 Sep 2016 23:22:04 +0100
Message-ID: <147380532484.23135.8759966582762396495.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932669AbcIMWWH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 18:22:07 -0400
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

call->rx_winsize should be initialised to the sysctl setting and the sysctl
setting should be limited to the maximum we want to permit.  Further, we
need to place this in the ACK info instead of the sysctl setting.

Furthermore, discard the idea of accepting the subpackets of a jumbo packet
that lie beyond the receive window when the first packet of the jumbo is
within the window.  Just discard the excess subpackets instead.  This
allows the receive window to be opened up right to the buffer size less one
for the dead slot.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    3 ++-
 net/rxrpc/call_object.c |    2 +-
 net/rxrpc/input.c       |   23 ++++++++++++++++-------
 net/rxrpc/misc.c        |    5 ++++-
 net/rxrpc/output.c      |    4 ++--
 net/rxrpc/sysctl.c      |    2 +-
 6 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 47c74a581a0f..e78c40b37db5 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -498,6 +498,7 @@ struct rxrpc_call {
 	 */
 #define RXRPC_RXTX_BUFF_SIZE	64
 #define RXRPC_RXTX_BUFF_MASK	(RXRPC_RXTX_BUFF_SIZE - 1)
+#define RXRPC_INIT_RX_WINDOW_SIZE 32
 	struct sk_buff		**rxtx_buffer;
 	u8			*rxtx_annotations;
 #define RXRPC_TX_ANNO_ACK	0
@@ -518,7 +519,7 @@ struct rxrpc_call {
 	rxrpc_seq_t		rx_expect_next;	/* Expected next packet sequence number */
 	u8			rx_winsize;	/* Size of Rx window */
 	u8			tx_winsize;	/* Maximum size of Tx window */
-	u8			nr_jumbo_dup;	/* Number of jumbo duplicates */
+	u8			nr_jumbo_bad;	/* Number of jumbo dups/exceeds-windows */
 
 	/* receive-phase ACK management */
 	u8			ackr_reason;	/* reason to ACK */
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 9aa1c4b53563..22f9b0d1a138 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -152,7 +152,7 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	memset(&call->sock_node, 0xed, sizeof(call->sock_node));
 
 	/* Leave space in the ring to handle a maxed-out jumbo packet */
-	call->rx_winsize = RXRPC_RXTX_BUFF_SIZE - 1 - 46;
+	call->rx_winsize = rxrpc_rx_window_size;
 	call->tx_winsize = 16;
 	call->rx_expect_next = 1;
 	return call;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 8e529afcd6c1..75af0bd316c7 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -164,7 +164,7 @@ protocol_error:
  * (that information is encoded in the ACK packet).
  */
 static void rxrpc_input_dup_data(struct rxrpc_call *call, rxrpc_seq_t seq,
-				 u8 annotation, bool *_jumbo_dup)
+				 u8 annotation, bool *_jumbo_bad)
 {
 	/* Discard normal packets that are duplicates. */
 	if (annotation == 0)
@@ -174,9 +174,9 @@ static void rxrpc_input_dup_data(struct rxrpc_call *call, rxrpc_seq_t seq,
 	 * more partially duplicate jumbo packets, we refuse to take any more
 	 * jumbos for this call.
 	 */
-	if (!*_jumbo_dup) {
-		call->nr_jumbo_dup++;
-		*_jumbo_dup = true;
+	if (!*_jumbo_bad) {
+		call->nr_jumbo_bad++;
+		*_jumbo_bad = true;
 	}
 }
 
@@ -191,7 +191,7 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 	unsigned int ix;
 	rxrpc_serial_t serial = sp->hdr.serial, ack_serial = 0;
 	rxrpc_seq_t seq = sp->hdr.seq, hard_ack;
-	bool immediate_ack = false, jumbo_dup = false, queued;
+	bool immediate_ack = false, jumbo_bad = false, queued;
 	u16 len;
 	u8 ack = 0, flags, annotation = 0;
 
@@ -222,7 +222,7 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 
 	flags = sp->hdr.flags;
 	if (flags & RXRPC_JUMBO_PACKET) {
-		if (call->nr_jumbo_dup > 3) {
+		if (call->nr_jumbo_bad > 3) {
 			ack = RXRPC_ACK_NOSPACE;
 			ack_serial = serial;
 			goto ack;
@@ -259,7 +259,7 @@ next_subpacket:
 	}
 
 	if (call->rxtx_buffer[ix]) {
-		rxrpc_input_dup_data(call, seq, annotation, &jumbo_dup);
+		rxrpc_input_dup_data(call, seq, annotation, &jumbo_bad);
 		if (ack != RXRPC_ACK_DUPLICATE) {
 			ack = RXRPC_ACK_DUPLICATE;
 			ack_serial = serial;
@@ -304,6 +304,15 @@ skip:
 		annotation++;
 		if (flags & RXRPC_JUMBO_PACKET)
 			annotation |= RXRPC_RX_ANNO_JLAST;
+		if (after(seq, hard_ack + call->rx_winsize)) {
+			ack = RXRPC_ACK_EXCEEDS_WINDOW;
+			ack_serial = serial;
+			if (!jumbo_bad) {
+				call->nr_jumbo_bad++;
+				jumbo_bad = true;
+			}
+			goto ack;
+		}
 
 		_proto("Rx DATA Jumbo %%%u", serial);
 		goto next_subpacket;
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index fd096f742e4b..8b910780f1ac 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -50,7 +50,10 @@ unsigned int rxrpc_idle_ack_delay = 0.5 * HZ;
  * limit is hit, we should generate an EXCEEDS_WINDOW ACK and discard further
  * packets.
  */
-unsigned int rxrpc_rx_window_size = RXRPC_RXTX_BUFF_SIZE - 46;
+unsigned int rxrpc_rx_window_size = RXRPC_INIT_RX_WINDOW_SIZE;
+#if (RXRPC_RXTX_BUFF_SIZE - 1) < RXRPC_INIT_RX_WINDOW_SIZE
+#error Need to reduce RXRPC_INIT_RX_WINDOW_SIZE
+#endif
 
 /*
  * Maximum Rx MTU size.  This indicates to the sender the size of jumbo packet
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 719a4c23f09d..90c7722d5779 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -71,10 +71,10 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 
 	mtu = call->conn->params.peer->if_mtu;
 	mtu -= call->conn->params.peer->hdrsize;
-	jmax = (call->nr_jumbo_dup > 3) ? 1 : rxrpc_rx_jumbo_max;
+	jmax = (call->nr_jumbo_bad > 3) ? 1 : rxrpc_rx_jumbo_max;
 	pkt->ackinfo.rxMTU	= htonl(rxrpc_rx_mtu);
 	pkt->ackinfo.maxMTU	= htonl(mtu);
-	pkt->ackinfo.rwind	= htonl(rxrpc_rx_window_size);
+	pkt->ackinfo.rwind	= htonl(call->rx_winsize);
 	pkt->ackinfo.jumbo_max	= htonl(jmax);
 
 	*ackp++ = 0;
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index b7ca8cf13c84..a03c61c672f5 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -20,7 +20,7 @@ static const unsigned int one = 1;
 static const unsigned int four = 4;
 static const unsigned int thirtytwo = 32;
 static const unsigned int n_65535 = 65535;
-static const unsigned int n_max_acks = RXRPC_MAXACKS;
+static const unsigned int n_max_acks = RXRPC_RXTX_BUFF_SIZE - 1;
 
 /*
  * RxRPC operating parameters.
