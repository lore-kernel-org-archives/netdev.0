From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 09/10] rxrpc: Fix prealloc refcounting
Date: Tue, 13 Sep 2016 23:21:57 +0100
Message-ID: <147380531789.23135.12013112169814398323.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The preallocated call buffer holds a ref on the calls within that buffer.
The ref was being released in the wrong place - it worked okay for incoming
calls to the AFS cache manager service, but doesn't work right for incoming
calls to a userspace service.

Instead of releasing an extra ref service calls in rxrpc_release_call(),
the ref needs to be released during the acceptance/rejectance process.  To
this end:

 (1) The prealloc ref is now normally released during
     rxrpc_new_incoming_call().

 (2) For preallocated kernel API calls, the kernel API's ref needs to be
     released when the call is discarded on socket close.

 (3) We shouldn't take a second ref in rxrpc_accept_call().

 (4) rxrpc_recvmsg_new_call() needs to get a ref of its own when it adds
     the call to the to_be_accepted socket queue.

In doing (4) above, we would prefer not to put the call's refcount down to
0 as that entails doing cleanup in softirq context, but it's unlikely as
there are several refs held elsewhere, at least one of which must be put by
someone in process context calling rxrpc_release_call().  However, it's not
a problem if we do have to do that.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_accept.c |    9 ++++++++-
 net/rxrpc/call_object.c |    3 ---
 net/rxrpc/recvmsg.c     |    1 +
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 5fd9d2c89b7f..26c293ef98eb 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -221,6 +221,7 @@ void rxrpc_discard_prealloc(struct rxrpc_sock *rx)
 		if (rx->discard_new_call) {
 			_debug("discard %lx", call->user_call_ID);
 			rx->discard_new_call(call, call->user_call_ID);
+			rxrpc_put_call(call, rxrpc_call_put_kernel);
 		}
 		rxrpc_call_completed(call);
 		rxrpc_release_call(rx, call);
@@ -402,6 +403,13 @@ found_service:
 	if (call->state == RXRPC_CALL_SERVER_ACCEPTING)
 		rxrpc_notify_socket(call);
 
+	/* We have to discard the prealloc queue's ref here and rely on a
+	 * combination of the RCU read lock and refs held either by the socket
+	 * (recvmsg queue, to-be-accepted queue or user ID tree) or the kernel
+	 * service to prevent the call from being deallocated too early.
+	 */
+	rxrpc_put_call(call, rxrpc_call_put);
+
 	_leave(" = %p{%d}", call, call->debug_id);
 out:
 	spin_unlock(&rx->incoming_lock);
@@ -469,7 +477,6 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	}
 
 	/* formalise the acceptance */
-	rxrpc_get_call(call, rxrpc_call_got);
 	call->notify_rx = notify_rx;
 	call->user_call_ID = user_call_ID;
 	rxrpc_get_call(call, rxrpc_call_got_userid);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 3f9476508204..9aa1c4b53563 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -464,9 +464,6 @@ void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 		call->rxtx_buffer[i] = NULL;
 	}
 
-	/* We have to release the prealloc backlog ref */
-	if (rxrpc_is_service_call(call))
-		rxrpc_put_call(call, rxrpc_call_put);
 	_leave("");
 }
 
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 16ff56f69256..a284205b8ecf 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -118,6 +118,7 @@ static int rxrpc_recvmsg_new_call(struct rxrpc_sock *rx,
 		list_del_init(&call->recvmsg_link);
 		write_unlock_bh(&rx->recvmsg_lock);
 
+		rxrpc_get_call(call, rxrpc_call_got);
 		write_lock(&rx->call_lock);
 		list_add_tail(&call->accept_link, &rx->to_be_accepted);
 		write_unlock(&rx->call_lock);
