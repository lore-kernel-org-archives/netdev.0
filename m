From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 15/24] rxrpc: Split client connection code out into
 its own file
Date: Tue, 05 Jul 2016 14:13:58 +0100
Message-ID: <146772443838.21657.4012935929664330820.stgit@warthog.procyon.org.uk>
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

Split the client-specific connection code out into its own file.  It will
behave somewhat differently from the service-specific connection code, so
it makes sense to separate them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    7 +
 net/rxrpc/conn_client.c |  249 +++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/conn_object.c |  250 -----------------------------------------------
 3 files changed, 254 insertions(+), 252 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 3685d99f2671..b95380dd0f37 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -545,9 +545,10 @@ void __exit rxrpc_destroy_all_calls(void);
  */
 extern struct idr rxrpc_client_conn_ids;
 
-int rxrpc_get_client_connection_id(struct rxrpc_connection *, gfp_t);
 void rxrpc_put_client_connection_id(struct rxrpc_connection *);
 void rxrpc_destroy_client_conn_ids(void);
+int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
+		       struct sockaddr_rxrpc *, gfp_t);
 
 /*
  * conn_event.c
@@ -560,11 +561,11 @@ void rxrpc_reject_packets(struct rxrpc_local *);
  * conn_object.c
  */
 extern unsigned int rxrpc_connection_expiry;
+extern struct list_head rxrpc_connections;
 extern struct list_head rxrpc_connection_proc_list;
 extern rwlock_t rxrpc_connection_lock;
 
-int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
-		       struct sockaddr_rxrpc *, gfp_t);
+struct rxrpc_connection *rxrpc_alloc_connection(gfp_t);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *,
 					       struct rxrpc_peer *,
 					       struct sk_buff *);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index be437d5e90ce..ce2fd4508bb5 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -33,7 +33,8 @@ static DEFINE_SPINLOCK(rxrpc_conn_id_lock);
  * client conns away from the current allocation point to try and keep the IDs
  * concentrated.  We will also need to retire connections from an old epoch.
  */
-int rxrpc_get_client_connection_id(struct rxrpc_connection *conn, gfp_t gfp)
+static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
+					  gfp_t gfp)
 {
 	u32 epoch;
 	int id;
@@ -111,3 +112,249 @@ void rxrpc_destroy_client_conn_ids(void)
 
 	idr_destroy(&rxrpc_client_conn_ids);
 }
+
+/*
+ * Allocate a client connection.  The caller must take care to clear any
+ * padding bytes in *cp.
+ */
+static struct rxrpc_connection *
+rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
+{
+	struct rxrpc_connection *conn;
+	int ret;
+
+	_enter("");
+
+	conn = rxrpc_alloc_connection(gfp);
+	if (!conn) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	conn->params		= *cp;
+	conn->proto.local	= cp->local;
+	conn->proto.epoch	= rxrpc_epoch;
+	conn->proto.cid		= 0;
+	conn->proto.in_clientflag = 0;
+	conn->proto.family	= cp->peer->srx.transport.family;
+	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
+	conn->state		= RXRPC_CONN_CLIENT;
+
+	switch (conn->proto.family) {
+	case AF_INET:
+		conn->proto.addr_size = sizeof(conn->proto.ipv4_addr);
+		conn->proto.ipv4_addr = cp->peer->srx.transport.sin.sin_addr;
+		conn->proto.port = cp->peer->srx.transport.sin.sin_port;
+		break;
+	}
+
+	ret = rxrpc_get_client_connection_id(conn, gfp);
+	if (ret < 0)
+		goto error_0;
+
+	ret = rxrpc_init_client_conn_security(conn);
+	if (ret < 0)
+		goto error_1;
+
+	ret = conn->security->prime_packet_security(conn);
+	if (ret < 0)
+		goto error_2;
+
+	write_lock(&rxrpc_connection_lock);
+	list_add_tail(&conn->link, &rxrpc_connections);
+	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
+	write_unlock(&rxrpc_connection_lock);
+
+	/* We steal the caller's peer ref. */
+	cp->peer = NULL;
+	rxrpc_get_local(conn->params.local);
+	key_get(conn->params.key);
+
+	_leave(" = %p", conn);
+	return conn;
+
+error_2:
+	conn->security->clear(conn);
+error_1:
+	rxrpc_put_client_connection_id(conn);
+error_0:
+	kfree(conn);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
+}
+
+/*
+ * find a connection for a call
+ * - called in process context with IRQs enabled
+ */
+int rxrpc_connect_call(struct rxrpc_call *call,
+		       struct rxrpc_conn_parameters *cp,
+		       struct sockaddr_rxrpc *srx,
+		       gfp_t gfp)
+{
+	struct rxrpc_connection *conn, *candidate = NULL;
+	struct rxrpc_local *local = cp->local;
+	struct rb_node *p, **pp, *parent;
+	long diff;
+	int chan;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	_enter("{%d,%lx},", call->debug_id, call->user_call_ID);
+
+	cp->peer = rxrpc_lookup_peer(cp->local, srx, gfp);
+	if (!cp->peer)
+		return -ENOMEM;
+
+	if (!cp->exclusive) {
+		/* Search for a existing client connection unless this is going
+		 * to be a connection that's used exclusively for a single call.
+		 */
+		_debug("search 1");
+		spin_lock(&local->client_conns_lock);
+		p = local->client_conns.rb_node;
+		while (p) {
+			conn = rb_entry(p, struct rxrpc_connection, client_node);
+
+#define cmp(X) ((long)conn->params.X - (long)cp->X)
+			diff = (cmp(peer) ?:
+				cmp(key) ?:
+				cmp(security_level));
+			if (diff < 0)
+				p = p->rb_left;
+			else if (diff > 0)
+				p = p->rb_right;
+			else
+				goto found_extant_conn;
+		}
+		spin_unlock(&local->client_conns_lock);
+	}
+
+	/* We didn't find a connection or we want an exclusive one. */
+	_debug("get new conn");
+	candidate = rxrpc_alloc_client_connection(cp, gfp);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return -ENOMEM;
+	}
+
+	if (cp->exclusive) {
+		/* Assign the call on an exclusive connection to channel 0 and
+		 * don't add the connection to the endpoint's shareable conn
+		 * lookup tree.
+		 */
+		_debug("exclusive chan 0");
+		conn = candidate;
+		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
+		spin_lock(&conn->channel_lock);
+		chan = 0;
+		goto found_channel;
+	}
+
+	/* We need to redo the search before attempting to add a new connection
+	 * lest we race with someone else adding a conflicting instance.
+	 */
+	_debug("search 2");
+	spin_lock(&local->client_conns_lock);
+
+	pp = &local->client_conns.rb_node;
+	parent = NULL;
+	while (*pp) {
+		parent = *pp;
+		conn = rb_entry(parent, struct rxrpc_connection, client_node);
+
+		diff = (cmp(peer) ?:
+			cmp(key) ?:
+			cmp(security_level));
+		if (diff < 0)
+			pp = &(*pp)->rb_left;
+		else if (diff > 0)
+			pp = &(*pp)->rb_right;
+		else
+			goto found_extant_conn;
+	}
+
+	/* The second search also failed; simply add the new connection with
+	 * the new call in channel 0.  Note that we need to take the channel
+	 * lock before dropping the client conn lock.
+	 */
+	_debug("new conn");
+	conn = candidate;
+	candidate = NULL;
+
+	rb_link_node(&conn->client_node, parent, pp);
+	rb_insert_color(&conn->client_node, &local->client_conns);
+
+	atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
+	spin_lock(&conn->channel_lock);
+	spin_unlock(&local->client_conns_lock);
+	chan = 0;
+
+found_channel:
+	_debug("found chan");
+	call->conn	= conn;
+	call->channel	= chan;
+	call->epoch	= conn->proto.epoch;
+	call->cid	= conn->proto.cid | chan;
+	call->call_id	= ++conn->channels[chan].call_counter;
+	conn->channels[chan].call_id = call->call_id;
+	rcu_assign_pointer(conn->channels[chan].call, call);
+
+	_net("CONNECT call %d on conn %d", call->debug_id, conn->debug_id);
+
+	spin_unlock(&conn->channel_lock);
+	rxrpc_put_peer(cp->peer);
+	cp->peer = NULL;
+	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
+	return 0;
+
+	/* We found a suitable connection already in existence.  Discard any
+	 * candidate we may have allocated, and try to get a channel on this
+	 * one.
+	 */
+found_extant_conn:
+	_debug("found conn");
+	rxrpc_get_connection(conn);
+	spin_unlock(&local->client_conns_lock);
+
+	rxrpc_put_connection(candidate);
+
+	if (!atomic_add_unless(&conn->avail_chans, -1, 0)) {
+		if (!gfpflags_allow_blocking(gfp)) {
+			rxrpc_put_connection(conn);
+			_leave(" = -EAGAIN");
+			return -EAGAIN;
+		}
+
+		add_wait_queue(&conn->channel_wq, &myself);
+		for (;;) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			if (atomic_add_unless(&conn->avail_chans, -1, 0))
+				break;
+			if (signal_pending(current))
+				goto interrupted;
+			schedule();
+		}
+		remove_wait_queue(&conn->channel_wq, &myself);
+		__set_current_state(TASK_RUNNING);
+	}
+
+	/* The connection allegedly now has a free channel and we can now
+	 * attach the call to it.
+	 */
+	spin_lock(&conn->channel_lock);
+
+	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
+		if (!conn->channels[chan].call)
+			goto found_channel;
+	BUG();
+
+interrupted:
+	remove_wait_queue(&conn->channel_wq, &myself);
+	__set_current_state(TASK_RUNNING);
+	rxrpc_put_connection(conn);
+	rxrpc_put_peer(cp->peer);
+	cp->peer = NULL;
+	_leave(" = -ERESTARTSYS");
+	return -ERESTARTSYS;
+}
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index fcc6d2421a37..a43b3a731e6b 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -27,7 +27,7 @@ unsigned int rxrpc_connection_expiry = 10 * 60;
 
 static void rxrpc_connection_reaper(struct work_struct *work);
 
-static LIST_HEAD(rxrpc_connections);
+LIST_HEAD(rxrpc_connections);
 LIST_HEAD(rxrpc_connection_proc_list);
 DEFINE_RWLOCK(rxrpc_connection_lock);
 static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
@@ -35,7 +35,7 @@ static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
 /*
  * allocate a new connection
  */
-static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
+struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 {
 	struct rxrpc_connection *conn;
 
@@ -63,252 +63,6 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 }
 
 /*
- * Allocate a client connection.  The caller must take care to clear any
- * padding bytes in *cp.
- */
-static struct rxrpc_connection *
-rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
-{
-	struct rxrpc_connection *conn;
-	int ret;
-
-	_enter("");
-
-	conn = rxrpc_alloc_connection(gfp);
-	if (!conn) {
-		_leave(" = -ENOMEM");
-		return ERR_PTR(-ENOMEM);
-	}
-
-	conn->params		= *cp;
-	conn->proto.local	= cp->local;
-	conn->proto.epoch	= rxrpc_epoch;
-	conn->proto.cid		= 0;
-	conn->proto.in_clientflag = 0;
-	conn->proto.family	= cp->peer->srx.transport.family;
-	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
-	conn->state		= RXRPC_CONN_CLIENT;
-
-	switch (conn->proto.family) {
-	case AF_INET:
-		conn->proto.addr_size = sizeof(conn->proto.ipv4_addr);
-		conn->proto.ipv4_addr = cp->peer->srx.transport.sin.sin_addr;
-		conn->proto.port = cp->peer->srx.transport.sin.sin_port;
-		break;
-	}
-
-	ret = rxrpc_get_client_connection_id(conn, gfp);
-	if (ret < 0)
-		goto error_0;
-
-	ret = rxrpc_init_client_conn_security(conn);
-	if (ret < 0)
-		goto error_1;
-
-	ret = conn->security->prime_packet_security(conn);
-	if (ret < 0)
-		goto error_2;
-
-	write_lock(&rxrpc_connection_lock);
-	list_add_tail(&conn->link, &rxrpc_connections);
-	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
-	write_unlock(&rxrpc_connection_lock);
-
-	/* We steal the caller's peer ref. */
-	cp->peer = NULL;
-	rxrpc_get_local(conn->params.local);
-	key_get(conn->params.key);
-
-	_leave(" = %p", conn);
-	return conn;
-
-error_2:
-	conn->security->clear(conn);
-error_1:
-	rxrpc_put_client_connection_id(conn);
-error_0:
-	kfree(conn);
-	_leave(" = %d", ret);
-	return ERR_PTR(ret);
-}
-
-/*
- * find a connection for a call
- * - called in process context with IRQs enabled
- */
-int rxrpc_connect_call(struct rxrpc_call *call,
-		       struct rxrpc_conn_parameters *cp,
-		       struct sockaddr_rxrpc *srx,
-		       gfp_t gfp)
-{
-	struct rxrpc_connection *conn, *candidate = NULL;
-	struct rxrpc_local *local = cp->local;
-	struct rb_node *p, **pp, *parent;
-	long diff;
-	int chan;
-
-	DECLARE_WAITQUEUE(myself, current);
-
-	_enter("{%d,%lx},", call->debug_id, call->user_call_ID);
-
-	cp->peer = rxrpc_lookup_peer(cp->local, srx, gfp);
-	if (!cp->peer)
-		return -ENOMEM;
-
-	if (!cp->exclusive) {
-		/* Search for a existing client connection unless this is going
-		 * to be a connection that's used exclusively for a single call.
-		 */
-		_debug("search 1");
-		spin_lock(&local->client_conns_lock);
-		p = local->client_conns.rb_node;
-		while (p) {
-			conn = rb_entry(p, struct rxrpc_connection, client_node);
-
-#define cmp(X) ((long)conn->params.X - (long)cp->X)
-			diff = (cmp(peer) ?:
-				cmp(key) ?:
-				cmp(security_level));
-			if (diff < 0)
-				p = p->rb_left;
-			else if (diff > 0)
-				p = p->rb_right;
-			else
-				goto found_extant_conn;
-		}
-		spin_unlock(&local->client_conns_lock);
-	}
-
-	/* We didn't find a connection or we want an exclusive one. */
-	_debug("get new conn");
-	candidate = rxrpc_alloc_client_connection(cp, gfp);
-	if (!candidate) {
-		_leave(" = -ENOMEM");
-		return -ENOMEM;
-	}
-
-	if (cp->exclusive) {
-		/* Assign the call on an exclusive connection to channel 0 and
-		 * don't add the connection to the endpoint's shareable conn
-		 * lookup tree.
-		 */
-		_debug("exclusive chan 0");
-		conn = candidate;
-		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
-		spin_lock(&conn->channel_lock);
-		chan = 0;
-		goto found_channel;
-	}
-
-	/* We need to redo the search before attempting to add a new connection
-	 * lest we race with someone else adding a conflicting instance.
-	 */
-	_debug("search 2");
-	spin_lock(&local->client_conns_lock);
-
-	pp = &local->client_conns.rb_node;
-	parent = NULL;
-	while (*pp) {
-		parent = *pp;
-		conn = rb_entry(parent, struct rxrpc_connection, client_node);
-
-		diff = (cmp(peer) ?:
-			cmp(key) ?:
-			cmp(security_level));
-		if (diff < 0)
-			pp = &(*pp)->rb_left;
-		else if (diff > 0)
-			pp = &(*pp)->rb_right;
-		else
-			goto found_extant_conn;
-	}
-
-	/* The second search also failed; simply add the new connection with
-	 * the new call in channel 0.  Note that we need to take the channel
-	 * lock before dropping the client conn lock.
-	 */
-	_debug("new conn");
-	conn = candidate;
-	candidate = NULL;
-
-	rb_link_node(&conn->client_node, parent, pp);
-	rb_insert_color(&conn->client_node, &local->client_conns);
-
-	atomic_set(&conn->avail_chans, RXRPC_MAXCALLS - 1);
-	spin_lock(&conn->channel_lock);
-	spin_unlock(&local->client_conns_lock);
-	chan = 0;
-
-found_channel:
-	_debug("found chan");
-	call->conn	= conn;
-	call->channel	= chan;
-	call->epoch	= conn->proto.epoch;
-	call->cid	= conn->proto.cid | chan;
-	call->call_id	= ++conn->channels[chan].call_counter;
-	conn->channels[chan].call_id = call->call_id;
-	rcu_assign_pointer(conn->channels[chan].call, call);
-
-	_net("CONNECT call %d on conn %d", call->debug_id, conn->debug_id);
-
-	spin_unlock(&conn->channel_lock);
-	rxrpc_put_peer(cp->peer);
-	cp->peer = NULL;
-	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
-	return 0;
-
-	/* We found a suitable connection already in existence.  Discard any
-	 * candidate we may have allocated, and try to get a channel on this
-	 * one.
-	 */
-found_extant_conn:
-	_debug("found conn");
-	rxrpc_get_connection(conn);
-	spin_unlock(&local->client_conns_lock);
-
-	rxrpc_put_connection(candidate);
-
-	if (!atomic_add_unless(&conn->avail_chans, -1, 0)) {
-		if (!gfpflags_allow_blocking(gfp)) {
-			rxrpc_put_connection(conn);
-			_leave(" = -EAGAIN");
-			return -EAGAIN;
-		}
-
-		add_wait_queue(&conn->channel_wq, &myself);
-		for (;;) {
-			set_current_state(TASK_INTERRUPTIBLE);
-			if (atomic_add_unless(&conn->avail_chans, -1, 0))
-				break;
-			if (signal_pending(current))
-				goto interrupted;
-			schedule();
-		}
-		remove_wait_queue(&conn->channel_wq, &myself);
-		__set_current_state(TASK_RUNNING);
-	}
-
-	/* The connection allegedly now has a free channel and we can now
-	 * attach the call to it.
-	 */
-	spin_lock(&conn->channel_lock);
-
-	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
-		if (!conn->channels[chan].call)
-			goto found_channel;
-	BUG();
-
-interrupted:
-	remove_wait_queue(&conn->channel_wq, &myself);
-	__set_current_state(TASK_RUNNING);
-	rxrpc_put_connection(conn);
-	rxrpc_put_peer(cp->peer);
-	cp->peer = NULL;
-	_leave(" = -ERESTARTSYS");
-	return -ERESTARTSYS;
-}
-
-/*
  * get a record of an incoming connection
  */
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
