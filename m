From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/4] rxrpc: Allow listen(sock,
 0) to be used to disable listening
Date: Mon, 09 Jan 2017 14:53:11 +0000
Message-ID: <148397359105.20445.7637040511773278204.stgit@warthog.procyon.org.uk>
References: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow listen() with a backlog of 0 to be used to disable listening on an
AF_RXRPC socket.  This also releases any preallocation, thereby making it
easier for a kernel service to account for all allocated call structures
when shutting down the service.

The socket cannot thereafter have listening reenabled, but must rather be
closed and reopened.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |    8 ++++++++
 net/rxrpc/ar-internal.h |    1 +
 net/rxrpc/call_accept.c |    3 ++-
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 5f63f6dcaabb..199b46e93e64 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -224,6 +224,14 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 		else
 			sk->sk_max_ack_backlog = old;
 		break;
+	case RXRPC_SERVER_LISTENING:
+		if (backlog == 0) {
+			rx->sk.sk_state = RXRPC_SERVER_LISTEN_DISABLED;
+			sk->sk_max_ack_backlog = 0;
+			rxrpc_discard_prealloc(rx);
+			ret = 0;
+			break;
+		}
 	default:
 		ret = -EBUSY;
 		break;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 84927c7b5fdf..12be432be9b2 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -60,6 +60,7 @@ enum {
 	RXRPC_CLIENT_BOUND,		/* client local address bound */
 	RXRPC_SERVER_BOUND,		/* server local address bound */
 	RXRPC_SERVER_LISTENING,		/* server listening for connections */
+	RXRPC_SERVER_LISTEN_DISABLED,	/* server listening disabled */
 	RXRPC_CLOSE,			/* socket is being closed */
 };
 
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 832d854c2d5c..7c4c64ab8da2 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -349,7 +349,8 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 
 found_service:
 	spin_lock(&rx->incoming_lock);
-	if (rx->sk.sk_state == RXRPC_CLOSE) {
+	if (rx->sk.sk_state == RXRPC_SERVER_LISTEN_DISABLED ||
+	    rx->sk.sk_state == RXRPC_CLOSE) {
 		trace_rxrpc_abort("CLS", sp->hdr.cid, sp->hdr.callNumber,
 				  sp->hdr.seq, RX_INVALID_OPERATION, ESHUTDOWN);
 		skb->mark = RXRPC_SKB_MARK_LOCAL_ABORT;
