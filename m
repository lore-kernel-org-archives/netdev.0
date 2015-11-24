From: David Howells <dhowells@redhat.com>
Subject: [PATCH] rxrpc: Correctly handle ack at end of client call transmit
 phase
Date: Tue, 24 Nov 2015 14:41:59 +0000
Message-ID: <20151124144159.18105.50840.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Normally, the transmit phase of a client call is implicitly ack'd by the
reception of the first data packet of the response being received.
However, if a security negotiation happens, the transmit phase, if it is
entirely contained in a single packet, may get an ack packet in response
and then may get aborted due to security negotiation failure.

Because the client has shifted state to RXRPC_CALL_CLIENT_AWAIT_REPLY due
to having transmitted all the data, the code that handles processing of the
received ack packet doesn't note the hard ack the data packet.

The following abort packet in the case of security negotiation failure then
incurs an assertion failure when it tries to drain the Tx queue because the
hard ack state is out of sync (hard ack means the packets have been
processed and can be discarded by the sender; a soft ack means that the
packets are received but could still be discarded and rerequested by the
receiver).

To fix this, we should record the hard ack we received for the ack packet.

The assertion failure looks like:

	RxRPC: Assertion failed
	1 <= 0 is false
	0x1 <= 0x0 is false
	------------[ cut here ]------------
	kernel BUG at ../net/rxrpc/ar-ack.c:431!
	...
	RIP: 0010:[<ffffffffa006857b>]  [<ffffffffa006857b>] rxrpc_rotate_tx_window+0xbc/0x131 [af_rxrpc]
	...

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-ack.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index e0547f521f20..adc555e0323d 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -723,8 +723,10 @@ process_further:
 
 			if ((call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY ||
 			     call->state == RXRPC_CALL_SERVER_AWAIT_ACK) &&
-			    hard > tx)
+			    hard > tx) {
+				call->acks_hard = tx;
 				goto all_acked;
+			}
 
 			smp_rmb();
 			rxrpc_rotate_tx_window(call, hard - 1);
