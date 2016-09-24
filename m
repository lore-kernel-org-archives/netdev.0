From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/8] rxrpc: Send an immediate ACK if we fill in a
 hole
Date: Sun, 25 Sep 2016 00:25:10 +0100
Message-ID: <147475951066.15231.12528785531688251510.stgit@warthog.procyon.org.uk>
References: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Send an immediate ACK if we fill in a hole in the buffer left by an
out-of-sequence packet.  This may allow the congestion management in the peer
to avoid a retransmission if packets got reordered on the wire.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 349698d87ad1..757c16f033a0 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -331,8 +331,16 @@ next_subpacket:
 	call->rxtx_annotations[ix] = annotation;
 	smp_wmb();
 	call->rxtx_buffer[ix] = skb;
-	if (after(seq, call->rx_top))
+	if (after(seq, call->rx_top)) {
 		smp_store_release(&call->rx_top, seq);
+	} else if (before(seq, call->rx_top)) {
+		/* Send an immediate ACK if we fill in a hole */
+		if (!ack) {
+			ack = RXRPC_ACK_DELAY;
+			ack_serial = serial;
+		}
+		immediate_ack = true;
+	}
 	if (flags & RXRPC_LAST_PACKET) {
 		set_bit(RXRPC_CALL_RX_LAST, &call->flags);
 		trace_rxrpc_receive(call, rxrpc_receive_queue_last, serial, seq);
