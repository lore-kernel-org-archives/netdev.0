From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/8] rxrpc: Include the last reply DATA serial
 number in the final ACK
Date: Sun, 25 Sep 2016 00:25:17 +0100
Message-ID: <147475951744.15231.7228531942049010094.stgit@warthog.procyon.org.uk>
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

In a client call, include the serial number of the last DATA packet of the
reply in the final ACK.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/recvmsg.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index a7458c398b9e..038ae62ddb4d 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -133,7 +133,7 @@ static int rxrpc_recvmsg_new_call(struct rxrpc_sock *rx,
 /*
  * End the packet reception phase.
  */
-static void rxrpc_end_rx_phase(struct rxrpc_call *call)
+static void rxrpc_end_rx_phase(struct rxrpc_call *call, rxrpc_serial_t serial)
 {
 	_enter("%d,%s", call->debug_id, rxrpc_call_states[call->state]);
 
@@ -141,7 +141,7 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call)
 	ASSERTCMP(call->rx_hard_ack, ==, call->rx_top);
 
 	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
-		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, true, false,
+		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, serial, true, false,
 				  rxrpc_propose_ack_terminal_ack);
 		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
 	}
@@ -202,7 +202,7 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 	_debug("%u,%u,%02x", hard_ack, top, flags);
 	trace_rxrpc_receive(call, rxrpc_receive_rotate, serial, hard_ack);
 	if (flags & RXRPC_LAST_PACKET) {
-		rxrpc_end_rx_phase(call);
+		rxrpc_end_rx_phase(call, serial);
 	} else {
 		/* Check to see if there's an ACK that needs sending. */
 		if (after_eq(hard_ack, call->ackr_consumed + 2) ||
