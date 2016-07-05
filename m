From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 11/24] rxrpc: Release a call's connection ref on
 call disconnection
Date: Tue, 05 Jul 2016 14:13:29 +0100
Message-ID: <146772440976.21657.10583100542600642704.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a call is disconnected, clear the call's pointer to the connection and
release the associated ref on that connection.  This means that the call no
longer pins the connection and the connection can be discarded even before
the call is.

As the code currently stands, the call struct is effectively pinned by
userspace until userspace has enacted a recvmsg() to retrieve the final
call state as sk_buffs on the receive queue pin the call to which they're
related because:

 (1) The rxrpc_call struct contains the userspace ID that recvmsg() has to
     include in the control message buffer to indicate which call is being
     referred to.  This ID must remain valid until the terminal packet is
     completely read and must be invalidated immediately at that point as
     userspace is entitled to immediately reuse it.

 (2) The final ACK to the reply to a client call isn't sent until the last
     data packet is entirely read (it's probably worth altering this in
     future to be send the ACK as soon as all the data has been received).


This change requires a bit of rearrangement to make sure that the call
isn't going to try and access the connection again after protocol
completion:

 (1) Delete the error link earlier when we're releasing the call.  Possibly
     network errors should be distributed via connections at the cost of
     adding in an access to the rxrpc_connection struct.

 (2) Remove the call from the connection's call tree before disconnecting
     the call.  The call tree needs to be removed anyway and incoming
     packets delivered by channel pointer instead.

 (3) The release call event should be considered last after all other
     events have been processed so that we don't need access to the
     connection again.

 (4) Move the channel_lock taking from rxrpc_release_call() to
     rxrpc_disconnect_call() where it will be required in future.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c  |   10 +++++-----
 net/rxrpc/call_object.c |   26 +++++++++-----------------
 net/rxrpc/conn_object.c |    8 ++++++++
 3 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 0ba84295f913..638d66df284a 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -858,11 +858,6 @@ void rxrpc_process_call(struct work_struct *work)
 	iov[0].iov_len	= sizeof(whdr);
 
 	/* deal with events of a final nature */
-	if (test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
-		rxrpc_release_call(call);
-		clear_bit(RXRPC_CALL_EV_RELEASE, &call->events);
-	}
-
 	if (test_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events)) {
 		enum rxrpc_skb_mark mark;
 		int error;
@@ -1144,6 +1139,11 @@ void rxrpc_process_call(struct work_struct *work)
 		goto maybe_reschedule;
 	}
 
+	if (test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
+		rxrpc_release_call(call);
+		clear_bit(RXRPC_CALL_EV_RELEASE, &call->events);
+	}
+
 	/* other events may have been raised since we started checking */
 	goto maybe_reschedule;
 
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 6223a7ed831f..b43d89c89744 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -628,6 +628,10 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	 */
 	_debug("RELEASE CALL %p (%d CONN %p)", call, call->debug_id, conn);
 
+	spin_lock(&conn->params.peer->lock);
+	hlist_del_init(&call->error_link);
+	spin_unlock(&conn->params.peer->lock);
+
 	write_lock_bh(&rx->call_lock);
 	if (!list_empty(&call->accept_link)) {
 		_debug("unlinking once-pending call %p { e=%lx f=%lx }",
@@ -643,25 +647,22 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	write_unlock_bh(&rx->call_lock);
 
 	/* free up the channel for reuse */
-	spin_lock(&conn->channel_lock);
 	write_lock_bh(&conn->lock);
 	write_lock(&call->state_lock);
 
-	rxrpc_disconnect_call(call);
-
-	spin_unlock(&conn->channel_lock);
-
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
 		_debug("+++ ABORTING STATE %d +++\n", call->state);
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->local_abort = RX_CALL_DEAD;
-		set_bit(RXRPC_CALL_EV_ABORT, &call->events);
-		rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
+
+	rb_erase(&call->conn_node, &conn->calls);
 	write_unlock_bh(&conn->lock);
 
+	rxrpc_disconnect_call(call);
+
 	/* clean up the Rx queue */
 	if (!skb_queue_empty(&call->rx_queue) ||
 	    !skb_queue_empty(&call->rx_oos_queue)) {
@@ -817,16 +818,7 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 		return;
 	}
 
-	if (call->conn) {
-		spin_lock(&call->conn->params.peer->lock);
-		hlist_del_init(&call->error_link);
-		spin_unlock(&call->conn->params.peer->lock);
-
-		write_lock_bh(&call->conn->lock);
-		rb_erase(&call->conn_node, &call->conn->calls);
-		write_unlock_bh(&call->conn->lock);
-		rxrpc_put_connection(call->conn);
-	}
+	ASSERTCMP(call->conn, ==, NULL);
 
 	/* Remove the call from the hash */
 	rxrpc_call_hash_del(call);
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index f28578b31281..0c84ce4ecc1d 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -543,11 +543,19 @@ void rxrpc_disconnect_call(struct rxrpc_call *call)
 
 	_enter("%d,%d", conn->debug_id, call->channel);
 
+	spin_lock(&conn->channel_lock);
+
 	if (conn->channels[chan] == call) {
 		rcu_assign_pointer(conn->channels[chan], NULL);
 		atomic_inc(&conn->avail_chans);
 		wake_up(&conn->channel_wq);
 	}
+
+	spin_unlock(&conn->channel_lock);
+
+	call->conn = NULL;
+	rxrpc_put_connection(conn);
+	_leave("");
 }
 
 /*
