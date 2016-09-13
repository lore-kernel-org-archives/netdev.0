From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 08/10] rxrpc: Adjust the call ref tracepoint to
 show kernel API refs
Date: Tue, 13 Sep 2016 23:21:51 +0100
Message-ID: <147380531112.23135.6820176162408555121.stgit@warthog.procyon.org.uk>
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

Adjust the call ref tracepoint to show references held on a call by the
kernel API separately as much as possible and add an additional trace to at
the allocation point from the preallocation buffer for an incoming call.

Note that this doesn't show the allocation of a client call for the kernel
separately at the moment.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |    2 +-
 net/rxrpc/ar-internal.h |    2 ++
 net/rxrpc/call_accept.c |    3 ++-
 net/rxrpc/call_object.c |    2 ++
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index caa226dd436e..25d00ded24bc 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -299,7 +299,7 @@ void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 {
 	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
 	rxrpc_release_call(rxrpc_sk(sock->sk), call);
-	rxrpc_put_call(call, rxrpc_call_put);
+	rxrpc_put_call(call, rxrpc_call_put_kernel);
 }
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index b1cb79ec4e96..47c74a581a0f 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -540,8 +540,10 @@ enum rxrpc_call_trace {
 	rxrpc_call_seen,
 	rxrpc_call_got,
 	rxrpc_call_got_userid,
+	rxrpc_call_got_kernel,
 	rxrpc_call_put,
 	rxrpc_call_put_userid,
+	rxrpc_call_put_kernel,
 	rxrpc_call_put_noqueue,
 	rxrpc_call__nr_trace
 };
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 06e328f6b0f0..5fd9d2c89b7f 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -121,7 +121,7 @@ static int rxrpc_service_prealloc_one(struct rxrpc_sock *rx,
 
 		call->user_call_ID = user_call_ID;
 		call->notify_rx = notify_rx;
-		rxrpc_get_call(call, rxrpc_call_got);
+		rxrpc_get_call(call, rxrpc_call_got_kernel);
 		user_attach_call(call, user_call_ID);
 		rxrpc_get_call(call, rxrpc_call_got_userid);
 		rb_link_node(&call->sock_node, parent, pp);
@@ -300,6 +300,7 @@ static struct rxrpc_call *rxrpc_alloc_incoming_call(struct rxrpc_sock *rx,
 	smp_store_release(&b->call_backlog_tail,
 			  (call_tail + 1) & (RXRPC_BACKLOG_MAX - 1));
 
+	rxrpc_see_call(call);
 	call->conn = conn;
 	call->peer = rxrpc_get_peer(conn->params.peer);
 	return call;
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 18ab13f82f6e..3f9476508204 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -56,8 +56,10 @@ const char rxrpc_call_traces[rxrpc_call__nr_trace][4] = {
 	[rxrpc_call_seen]		= "SEE",
 	[rxrpc_call_got]		= "GOT",
 	[rxrpc_call_got_userid]		= "Gus",
+	[rxrpc_call_got_kernel]		= "Gke",
 	[rxrpc_call_put]		= "PUT",
 	[rxrpc_call_put_userid]		= "Pus",
+	[rxrpc_call_put_kernel]		= "Pke",
 	[rxrpc_call_put_noqueue]	= "PNQ",
 };
 
