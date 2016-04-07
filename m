From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/9] rxrpc: Don't pass gfp around in incoming call handling
 functions
Date: Thu, 07 Apr 2016 17:23:37 +0100
Message-ID: <20160407162337.21283.88216.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't pass gfp around in incoming call handling functions, but rather hard
code it at the points where we actually need it since the value comes from
within the rxrpc driver and is always the same.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-accept.c     |    4 ++--
 net/rxrpc/ar-call.c       |    7 +++----
 net/rxrpc/ar-connection.c |    5 ++---
 net/rxrpc/ar-internal.h   |    5 ++---
 4 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 277731a5e67a..e7a7f05f13e2 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -108,7 +108,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 		goto error;
 	}
 
-	conn = rxrpc_incoming_connection(trans, &sp->hdr, GFP_NOIO);
+	conn = rxrpc_incoming_connection(trans, &sp->hdr);
 	rxrpc_put_transport(trans);
 	if (IS_ERR(conn)) {
 		_debug("no conn");
@@ -116,7 +116,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 		goto error;
 	}
 
-	call = rxrpc_incoming_call(rx, conn, &sp->hdr, GFP_NOIO);
+	call = rxrpc_incoming_call(rx, conn, &sp->hdr);
 	rxrpc_put_connection(conn);
 	if (IS_ERR(call)) {
 		_debug("no call");
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 67a211f0ebba..571a41fd5a32 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -411,18 +411,17 @@ found_extant_second:
  */
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 				       struct rxrpc_connection *conn,
-				       struct rxrpc_host_header *hdr,
-				       gfp_t gfp)
+				       struct rxrpc_host_header *hdr)
 {
 	struct rxrpc_call *call, *candidate;
 	struct rb_node **p, *parent;
 	u32 call_id;
 
-	_enter(",%d,,%x", conn->debug_id, gfp);
+	_enter(",%d", conn->debug_id);
 
 	ASSERT(rx != NULL);
 
-	candidate = rxrpc_alloc_call(gfp);
+	candidate = rxrpc_alloc_call(GFP_NOIO);
 	if (!candidate)
 		return ERR_PTR(-EBUSY);
 
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 9942da1edbf6..9b6966777633 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -619,8 +619,7 @@ interrupted:
  */
 struct rxrpc_connection *
 rxrpc_incoming_connection(struct rxrpc_transport *trans,
-			  struct rxrpc_host_header *hdr,
-			  gfp_t gfp)
+			  struct rxrpc_host_header *hdr)
 {
 	struct rxrpc_connection *conn, *candidate = NULL;
 	struct rb_node *p, **pp;
@@ -659,7 +658,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 
 	/* not yet present - create a candidate for a new record and then
 	 * redo the search */
-	candidate = rxrpc_alloc_connection(gfp);
+	candidate = rxrpc_alloc_connection(GFP_NOIO);
 	if (!candidate) {
 		_leave(" = -ENOMEM");
 		return ERR_PTR(-ENOMEM);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 258b74a2a23f..d38071b09f72 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -503,7 +503,7 @@ struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *,
 					 unsigned long, int, gfp_t);
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 				       struct rxrpc_connection *,
-				       struct rxrpc_host_header *, gfp_t);
+				       struct rxrpc_host_header *);
 struct rxrpc_call *rxrpc_find_server_call(struct rxrpc_sock *, unsigned long);
 void rxrpc_release_call(struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
@@ -528,8 +528,7 @@ void __exit rxrpc_destroy_all_connections(void);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
 					       struct rxrpc_host_header *);
 extern struct rxrpc_connection *
-rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_host_header *,
-			  gfp_t);
+rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_host_header *);
 
 /*
  * ar-connevent.c
