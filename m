From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 07/19] rxrpc: Move usage count getting into
 rxrpc_queue_conn()
Date: Thu, 30 Jun 2016 15:11:32 +0100
Message-ID: <146729589235.26306.15114701415404719693.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than calling rxrpc_get_connection() manually before calling
rxrpc_queue_conn(), do it inside the queue wrapper.

This allows us to do some important fixes:

 (1) If the usage count is 0, do nothing.  This prevents connections from
     being reanimated once they're dead.

 (2) If rxrpc_queue_work() fails because the work item is already queued,
     retract the usage count increment which would otherwise be lost.

 (3) Don't take a ref on the connection in the work function.  By passing
     the ref through the work item, this is unnecessary.  Doing it in the
     work function is too late anyway.  Previously, connection-directed
     packets held a ref on the connection, but that's not really the best
     idea.

And another useful changes:

 (*) Don't need to take a refcount on the connection in the data_ready
     handler unless we invoke the connection's work item.  We're using RCU
     there so that's otherwise redundant.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    9 ++++++++-
 net/rxrpc/call_accept.c |    1 -
 net/rxrpc/conn_event.c  |    8 +-------
 net/rxrpc/input.c       |    1 -
 4 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 2a8710dac3c5..d43cb7831693 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -585,10 +585,17 @@ static inline void rxrpc_get_connection(struct rxrpc_connection *conn)
 	atomic_inc(&conn->usage);
 }
 
+static inline
+struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *conn)
+{
+	return atomic_inc_not_zero(&conn->usage) ? conn : NULL;
+}
 
 static inline void rxrpc_queue_conn(struct rxrpc_connection *conn)
 {
-	rxrpc_queue_work(&conn->processor);
+	if (rxrpc_get_connection_maybe(conn) &&
+	    !rxrpc_queue_work(&conn->processor))
+		rxrpc_put_connection(conn);
 }
 
 /*
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 1c0860df150e..5367dbe9b96f 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -132,7 +132,6 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 			_debug("await conn sec");
 			list_add_tail(&call->accept_link, &rx->secureq);
 			call->conn->state = RXRPC_CONN_SERVICE_CHALLENGING;
-			rxrpc_get_connection(call->conn);
 			set_bit(RXRPC_CONN_EV_CHALLENGE, &call->conn->events);
 			rxrpc_queue_conn(call->conn);
 		} else {
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index b9c39b83eddb..9ceddd3fd5db 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -266,12 +266,8 @@ void rxrpc_process_connection(struct work_struct *work)
 
 	_enter("{%d}", conn->debug_id);
 
-	rxrpc_get_connection(conn);
-
-	if (test_and_clear_bit(RXRPC_CONN_EV_CHALLENGE, &conn->events)) {
+	if (test_and_clear_bit(RXRPC_CONN_EV_CHALLENGE, &conn->events))
 		rxrpc_secure_connection(conn);
-		rxrpc_put_connection(conn);
-	}
 
 	/* go through the conn-level event packets, releasing the ref on this
 	 * connection that each one has when we've finished with it */
@@ -286,7 +282,6 @@ void rxrpc_process_connection(struct work_struct *work)
 			goto requeue_and_leave;
 		case -ECONNABORTED:
 		default:
-			rxrpc_put_connection(conn);
 			rxrpc_free_skb(skb);
 			break;
 		}
@@ -304,7 +299,6 @@ requeue_and_leave:
 protocol_error:
 	if (rxrpc_abort_connection(conn, -ret, abort_code) < 0)
 		goto requeue_and_leave;
-	rxrpc_put_connection(conn);
 	rxrpc_free_skb(skb);
 	_leave(" [EPROTO]");
 	goto out;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 8a68cc387a8c..710e55a5f569 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -580,7 +580,6 @@ static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 {
 	_enter("%p,%p", conn, skb);
 
-	rxrpc_get_connection(conn);
 	skb_queue_tail(&conn->rx_queue, skb);
 	rxrpc_queue_conn(conn);
 }
