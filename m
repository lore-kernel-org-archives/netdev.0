From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 08/14] rxrpc: Call rxrpc_release_call() on error in
 rxrpc_new_client_call()
Date: Sun, 18 Sep 2016 00:18:40 +0100
Message-ID: <147415432013.17897.16732372804879346856.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Call rxrpc_release_call() on getting an error in rxrpc_new_client_call()
rather than trying to do the cleanup ourselves.  This isn't a problem,
provided we set RXRPC_CALL_HAS_USERID only if we actually add the call to
the calls tree as cleanup code fragments that would otherwise cause
problems are conditional.

Without this, we miss some of the cleanup.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |   36 ++++++++++++------------------------
 1 file changed, 12 insertions(+), 24 deletions(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index b0ffbd9664e6..23f5a5f58282 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -226,9 +226,6 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 			 (const void *)user_call_ID);
 
 	/* Publish the call, even though it is incompletely set up as yet */
-	call->user_call_ID = user_call_ID;
-	__set_bit(RXRPC_CALL_HAS_USERID, &call->flags);
-
 	write_lock(&rx->call_lock);
 
 	pp = &rx->calls.rb_node;
@@ -242,10 +239,12 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 		else if (user_call_ID > xcall->user_call_ID)
 			pp = &(*pp)->rb_right;
 		else
-			goto found_user_ID_now_present;
+			goto error_dup_user_ID;
 	}
 
 	rcu_assign_pointer(call->socket, rx);
+	call->user_call_ID = user_call_ID;
+	__set_bit(RXRPC_CALL_HAS_USERID, &call->flags);
 	rxrpc_get_call(call, rxrpc_call_got_userid);
 	rb_link_node(&call->sock_node, parent, pp);
 	rb_insert_color(&call->sock_node, &rx->calls);
@@ -276,33 +275,22 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	_leave(" = %p [new]", call);
 	return call;
 
-error:
-	write_lock(&rx->call_lock);
-	rb_erase(&call->sock_node, &rx->calls);
-	write_unlock(&rx->call_lock);
-	rxrpc_put_call(call, rxrpc_call_put_userid);
-
-	write_lock(&rxrpc_call_lock);
-	list_del_init(&call->link);
-	write_unlock(&rxrpc_call_lock);
-
-error_out:
-	__rxrpc_set_call_completion(call, RXRPC_CALL_LOCAL_ERROR,
-				    RX_CALL_DEAD, ret);
-	set_bit(RXRPC_CALL_RELEASED, &call->flags);
-	rxrpc_put_call(call, rxrpc_call_put);
-	_leave(" = %d", ret);
-	return ERR_PTR(ret);
-
 	/* We unexpectedly found the user ID in the list after taking
 	 * the call_lock.  This shouldn't happen unless the user races
 	 * with itself and tries to add the same user ID twice at the
 	 * same time in different threads.
 	 */
-found_user_ID_now_present:
+error_dup_user_ID:
 	write_unlock(&rx->call_lock);
 	ret = -EEXIST;
-	goto error_out;
+
+error:
+	__rxrpc_set_call_completion(call, RXRPC_CALL_LOCAL_ERROR,
+				    RX_CALL_DEAD, ret);
+	rxrpc_release_call(rx, call);
+	rxrpc_put_call(call, rxrpc_call_put);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
 }
 
 /*
