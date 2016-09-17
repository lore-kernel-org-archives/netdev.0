From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 02/11] rxrpc: Add some additional call tracing
Date: Sun, 18 Sep 2016 00:21:43 +0100
Message-ID: <147415450364.18436.17940735469820302509.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756031AbcIQXVq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:21:46 -0400
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add additional call tracepoint points for noting call-connected,
call-released and connection-failed events.

Also fix one tracepoint that was using an integer instead of the
corresponding enum value as the point type.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    3 +++
 net/rxrpc/call_object.c |   18 ++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 0f6fafa2c271..4a73c20d9436 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -539,6 +539,8 @@ enum rxrpc_call_trace {
 	rxrpc_call_queued,
 	rxrpc_call_queued_ref,
 	rxrpc_call_seen,
+	rxrpc_call_connected,
+	rxrpc_call_release,
 	rxrpc_call_got,
 	rxrpc_call_got_userid,
 	rxrpc_call_got_kernel,
@@ -546,6 +548,7 @@ enum rxrpc_call_trace {
 	rxrpc_call_put_userid,
 	rxrpc_call_put_kernel,
 	rxrpc_call_put_noqueue,
+	rxrpc_call_error,
 	rxrpc_call__nr_trace
 };
 
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 23f5a5f58282..0df9d1af8edb 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -53,6 +53,8 @@ const char rxrpc_call_traces[rxrpc_call__nr_trace][4] = {
 	[rxrpc_call_new_service]	= "NWs",
 	[rxrpc_call_queued]		= "QUE",
 	[rxrpc_call_queued_ref]		= "QUR",
+	[rxrpc_call_connected]		= "CON",
+	[rxrpc_call_release]		= "RLS",
 	[rxrpc_call_seen]		= "SEE",
 	[rxrpc_call_got]		= "GOT",
 	[rxrpc_call_got_userid]		= "Gus",
@@ -61,6 +63,7 @@ const char rxrpc_call_traces[rxrpc_call__nr_trace][4] = {
 	[rxrpc_call_put_userid]		= "Pus",
 	[rxrpc_call_put_kernel]		= "Pke",
 	[rxrpc_call_put_noqueue]	= "PNQ",
+	[rxrpc_call_error]		= "*E*",
 };
 
 struct kmem_cache *rxrpc_call_jar;
@@ -222,8 +225,8 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 		return call;
 	}
 
-	trace_rxrpc_call(call, 0, atomic_read(&call->usage), here,
-			 (const void *)user_call_ID);
+	trace_rxrpc_call(call, rxrpc_call_new_client, atomic_read(&call->usage),
+			 here, (const void *)user_call_ID);
 
 	/* Publish the call, even though it is incompletely set up as yet */
 	write_lock(&rx->call_lock);
@@ -263,6 +266,9 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	if (ret < 0)
 		goto error;
 
+	trace_rxrpc_call(call, rxrpc_call_connected, atomic_read(&call->usage),
+			 here, ERR_PTR(ret));
+
 	spin_lock_bh(&call->conn->params.peer->lock);
 	hlist_add_head(&call->error_link,
 		       &call->conn->params.peer->error_targets);
@@ -287,6 +293,8 @@ error_dup_user_ID:
 error:
 	__rxrpc_set_call_completion(call, RXRPC_CALL_LOCAL_ERROR,
 				    RX_CALL_DEAD, ret);
+	trace_rxrpc_call(call, rxrpc_call_error, atomic_read(&call->usage),
+			 here, ERR_PTR(ret));
 	rxrpc_release_call(rx, call);
 	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = %d", ret);
@@ -396,15 +404,17 @@ void rxrpc_get_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
  */
 void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 {
+	const void *here = __builtin_return_address(0);
 	struct rxrpc_connection *conn = call->conn;
 	bool put = false;
 	int i;
 
 	_enter("{%d,%d}", call->debug_id, atomic_read(&call->usage));
 
-	ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
+	trace_rxrpc_call(call, rxrpc_call_release, atomic_read(&call->usage),
+			 here, (const void *)call->flags);
 
-	rxrpc_see_call(call);
+	ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 
 	spin_lock_bh(&call->lock);
 	if (test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags))
