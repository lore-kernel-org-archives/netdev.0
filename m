From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/8] rxrpc: Fix a potential NULL-pointer deref in
 rxrpc_abort_calls
Date: Tue, 30 Aug 2016 16:41:44 +0100
Message-ID: <147257170401.6391.16219091111450190401.stgit@warthog.procyon.org.uk>
References: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The call pointer in a channel on a connection will be NULL if there's no
active call on that channel.  rxrpc_abort_calls() needs to check for this
before trying to take the call's state_lock.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_event.c |   26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 6296374df840..bb81801fb805 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -149,19 +149,23 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 		call = rcu_dereference_protected(
 			conn->channels[i].call,
 			lockdep_is_held(&conn->channel_lock));
-		write_lock_bh(&call->state_lock);
-		if (call->state <= RXRPC_CALL_COMPLETE) {
-			call->state = state;
-			if (state == RXRPC_CALL_LOCALLY_ABORTED) {
-				call->local_abort = conn->local_abort;
-				set_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
-			} else {
-				call->remote_abort = conn->remote_abort;
-				set_bit(RXRPC_CALL_EV_RCVD_ABORT, &call->events);
+		if (call) {
+			write_lock_bh(&call->state_lock);
+			if (call->state <= RXRPC_CALL_COMPLETE) {
+				call->state = state;
+				if (state == RXRPC_CALL_LOCALLY_ABORTED) {
+					call->local_abort = conn->local_abort;
+					set_bit(RXRPC_CALL_EV_CONN_ABORT,
+						&call->events);
+				} else {
+					call->remote_abort = conn->remote_abort;
+					set_bit(RXRPC_CALL_EV_RCVD_ABORT,
+						&call->events);
+				}
+				rxrpc_queue_call(call);
 			}
-			rxrpc_queue_call(call);
+			write_unlock_bh(&call->state_lock);
 		}
-		write_unlock_bh(&call->state_lock);
 	}
 
 	spin_unlock(&conn->channel_lock);
