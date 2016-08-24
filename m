From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/2] rxrpc: Fix conn-based retransmit
Date: Wed, 24 Aug 2016 15:59:53 +0100
Message-ID: <147205079336.13418.18430907628836449088.stgit@warthog.procyon.org.uk>
References: <147205078637.13418.9976056129378485689.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147205078637.13418.9976056129378485689.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a duplicate packet comes in for a call that has just completed on a
connection's channel then there will be an oops in the data_ready handler
because it tries to examine the connection struct via a call struct (which
we don't have - the pointer is unset).

Since the connection struct pointer is available to us, go direct instead.

Also, the ACK packet to be retransmitted needs three octets of padding
between the soft ack list and the ackinfo.

Fixes: 18bfeba50dfd0c8ee420396f2570f16a0bdbd7de ("rxrpc: Perform terminal call ACK/ABORT retransmission from conn processor")
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_event.c |    1 +
 net/rxrpc/input.c      |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index c1c6b7f305d1..6296374df840 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -42,6 +42,7 @@ static void rxrpc_conn_retransmit(struct rxrpc_connection *conn,
 			} abort;
 			struct {
 				struct rxrpc_ackpacket ack;
+				u8 padding[3];
 				struct rxrpc_ackinfo info;
 			};
 		};
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 66cdeb56f44f..5e683dd21ab9 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -732,7 +732,7 @@ void rxrpc_data_ready(struct sock *sk)
 			/* For the previous service call, if completed
 			 * successfully, we discard all further packets.
 			 */
-			if (rxrpc_conn_is_service(call->conn) &&
+			if (rxrpc_conn_is_service(conn) &&
 			    (chan->last_type == RXRPC_PACKET_TYPE_ACK ||
 			     sp->hdr.type == RXRPC_PACKET_TYPE_ABORT))
 				goto discard_unlock;
