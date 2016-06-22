From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 06/14] rxrpc: Pass sk_buff * rather than
 rxrpc_host_header * to functions [ver #2]
Date: Wed, 22 Jun 2016 17:03:35 +0100
Message-ID: <146661141539.15011.1341051886880487259.stgit@warthog.procyon.org.uk>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pass a pointer to struct sk_buff rather than struct rxrpc_host_header to
functions so that they can in the future get at transport protocol parameters
rather than just RxRPC parameters.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    6 +++---
 net/rxrpc/call_accept.c |    4 ++--
 net/rxrpc/call_object.c |   21 +++++++++++---------
 net/rxrpc/conn_object.c |   49 ++++++++++++++++++++++++-----------------------
 net/rxrpc/input.c       |    7 +++----
 5 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 4ca99445e0b7..60ba22f56957 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -544,7 +544,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 unsigned long, gfp_t);
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 				       struct rxrpc_connection *,
-				       struct rxrpc_host_header *);
+				       struct sk_buff *);
 void rxrpc_release_call(struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
 void __rxrpc_put_call(struct rxrpc_call *);
@@ -574,9 +574,9 @@ int rxrpc_connect_call(struct rxrpc_sock *, struct rxrpc_conn_parameters *,
 void rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
-					       struct rxrpc_host_header *);
+					       struct sk_buff *);
 extern struct rxrpc_connection *
-rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_host_header *);
+rxrpc_incoming_connection(struct rxrpc_transport *, struct sk_buff *);
 
 static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
 {
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 553b67c144e5..5a70dc4e28c6 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -110,7 +110,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 		goto error;
 	}
 
-	conn = rxrpc_incoming_connection(trans, &sp->hdr);
+	conn = rxrpc_incoming_connection(trans, skb);
 	rxrpc_put_transport(trans);
 	if (IS_ERR(conn)) {
 		_debug("no conn");
@@ -118,7 +118,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 		goto error;
 	}
 
-	call = rxrpc_incoming_call(rx, conn, &sp->hdr);
+	call = rxrpc_incoming_call(rx, conn, skb);
 	rxrpc_put_connection(conn);
 	if (IS_ERR(call)) {
 		_debug("no call");
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 5c2dceaf6a9c..d83f2cbb80a9 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -421,8 +421,9 @@ found_user_ID_now_present:
  */
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 				       struct rxrpc_connection *conn,
-				       struct rxrpc_host_header *hdr)
+				       struct sk_buff *skb)
 {
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_call *call, *candidate;
 	struct rb_node **p, *parent;
 	u32 call_id;
@@ -435,13 +436,13 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	if (!candidate)
 		return ERR_PTR(-EBUSY);
 
-	candidate->socket = rx;
-	candidate->conn = conn;
-	candidate->cid = hdr->cid;
-	candidate->call_id = hdr->callNumber;
-	candidate->channel = hdr->cid & RXRPC_CHANNELMASK;
-	candidate->rx_data_post = 0;
-	candidate->state = RXRPC_CALL_SERVER_ACCEPTING;
+	candidate->socket	= rx;
+	candidate->conn		= conn;
+	candidate->cid		= sp->hdr.cid;
+	candidate->call_id	= sp->hdr.callNumber;
+	candidate->channel	= sp->hdr.cid & RXRPC_CHANNELMASK;
+	candidate->rx_data_post	= 0;
+	candidate->state	= RXRPC_CALL_SERVER_ACCEPTING;
 	if (conn->security_ix > 0)
 		candidate->state = RXRPC_CALL_SERVER_SECURING;
 
@@ -450,7 +451,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	/* set the channel for this call */
 	call = conn->channels[candidate->channel];
 	_debug("channel[%u] is %p", candidate->channel, call);
-	if (call && call->call_id == hdr->callNumber) {
+	if (call && call->call_id == sp->hdr.callNumber) {
 		/* already set; must've been a duplicate packet */
 		_debug("extant call [%d]", call->state);
 		ASSERTCMP(call->conn, ==, conn);
@@ -488,7 +489,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 
 	/* check the call number isn't duplicate */
 	_debug("check dup");
-	call_id = hdr->callNumber;
+	call_id = sp->hdr.callNumber;
 	p = &conn->calls.rb_node;
 	parent = NULL;
 	while (*p) {
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 6164373d6ce3..3b42fc4f4fe3 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -588,10 +588,10 @@ interrupted:
  * get a record of an incoming connection
  */
 struct rxrpc_connection *
-rxrpc_incoming_connection(struct rxrpc_transport *trans,
-			  struct rxrpc_host_header *hdr)
+rxrpc_incoming_connection(struct rxrpc_transport *trans, struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn, *candidate = NULL;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rb_node *p, **pp;
 	const char *new = "old";
 	__be32 epoch;
@@ -599,10 +599,10 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 
 	_enter("");
 
-	ASSERT(hdr->flags & RXRPC_CLIENT_INITIATED);
+	ASSERT(sp->hdr.flags & RXRPC_CLIENT_INITIATED);
 
-	epoch = hdr->epoch;
-	cid = hdr->cid & RXRPC_CIDMASK;
+	epoch = sp->hdr.epoch;
+	cid = sp->hdr.cid & RXRPC_CIDMASK;
 
 	/* search the connection list first */
 	read_lock_bh(&trans->conn_lock);
@@ -634,19 +634,19 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	candidate->trans = trans;
-	candidate->proto.local = trans->local;
-	candidate->proto.epoch = hdr->epoch;
-	candidate->proto.cid = hdr->cid & RXRPC_CIDMASK;
-	candidate->proto.in_clientflag = RXRPC_CLIENT_INITIATED;
-	candidate->params.local = trans->local;
-	candidate->params.peer = trans->peer;
-	candidate->params.service_id = hdr->serviceId;
-	candidate->security_ix = hdr->securityIndex;
-	candidate->out_clientflag = 0;
-	candidate->state = RXRPC_CONN_SERVER;
+	candidate->trans		= trans;
+	candidate->proto.local		= trans->local;
+	candidate->proto.epoch		= sp->hdr.epoch;
+	candidate->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
+	candidate->proto.in_clientflag	= RXRPC_CLIENT_INITIATED;
+	candidate->params.local		= trans->local;
+	candidate->params.peer		= trans->peer;
+	candidate->params.service_id	= sp->hdr.serviceId;
+	candidate->security_ix		= sp->hdr.securityIndex;
+	candidate->out_clientflag	= 0;
+	candidate->state		= RXRPC_CONN_SERVER;
 	if (candidate->params.service_id)
-		candidate->state = RXRPC_CONN_SERVER_UNSECURED;
+		candidate->state	= RXRPC_CONN_SERVER_UNSECURED;
 
 	write_lock_bh(&trans->conn_lock);
 
@@ -691,7 +691,7 @@ success:
 
 	/* we found the connection in the list immediately */
 found_extant_connection:
-	if (hdr->securityIndex != conn->security_ix) {
+	if (sp->hdr.securityIndex != conn->security_ix) {
 		read_unlock_bh(&trans->conn_lock);
 		goto security_mismatch;
 	}
@@ -701,7 +701,7 @@ found_extant_connection:
 
 	/* we found the connection on the second time through the list */
 found_extant_second:
-	if (hdr->securityIndex != conn->security_ix) {
+	if (sp->hdr.securityIndex != conn->security_ix) {
 		write_unlock_bh(&trans->conn_lock);
 		goto security_mismatch;
 	}
@@ -721,20 +721,21 @@ security_mismatch:
  * packet
  */
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
-					       struct rxrpc_host_header *hdr)
+					       struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rb_node *p;
 	u32 epoch, cid;
 
-	_enter(",{%x,%x}", hdr->cid, hdr->flags);
+	_enter(",{%x,%x}", sp->hdr.cid, sp->hdr.flags);
 
 	read_lock_bh(&trans->conn_lock);
 
-	cid = hdr->cid & RXRPC_CIDMASK;
-	epoch = hdr->epoch;
+	cid	= sp->hdr.cid & RXRPC_CIDMASK;
+	epoch	= sp->hdr.epoch;
 
-	if (hdr->flags & RXRPC_CLIENT_INITIATED)
+	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED)
 		p = trans->server_conns.rb_node;
 	else
 		p = trans->client_conns.rb_node;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 6af7f40c5030..cf540efa9c17 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -628,8 +628,7 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
 }
 
 static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
-					       struct sk_buff *skb,
-					       struct rxrpc_skb_priv *sp)
+						      struct sk_buff *skb)
 {
 	struct rxrpc_peer *peer;
 	struct rxrpc_transport *trans;
@@ -647,7 +646,7 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 	if (!trans)
 		goto cant_find_conn;
 
-	conn = rxrpc_find_connection(trans, &sp->hdr);
+	conn = rxrpc_find_connection(trans, skb);
 	rxrpc_put_transport(trans);
 	if (!conn)
 		goto cant_find_conn;
@@ -739,7 +738,7 @@ void rxrpc_data_ready(struct sock *sk)
 		 * old-fashioned way doesn't really hurt */
 		struct rxrpc_connection *conn;
 
-		conn = rxrpc_conn_from_local(local, skb, sp);
+		conn = rxrpc_conn_from_local(local, skb);
 		if (!conn)
 			goto cant_route_call;
 
