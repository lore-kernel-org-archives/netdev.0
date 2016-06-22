From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 08/14] rxrpc: Use IDR to allocate client conn IDs
 on a machine-wide basis [ver #2]
Date: Wed, 22 Jun 2016 17:03:49 +0100
Message-ID: <146661142946.15011.10573323953528498262.stgit@warthog.procyon.org.uk>
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

Use the IDR facility to allocate client connection IDs on a machine-wide
basis so that each client connection has a unique identifier.  When the
connection ID space wraps, we advance the epoch by 1, thereby effectively
having a 62-bit ID space.  The IDR facility is then used to look up client
connections during incoming packet routing instead of using an rbtree
rooted on the transport.

This change allows for the removal of the transport in the future and also
means that client connections can be looked up directly in the data-ready
handler by connection ID.

The ID management code is placed in a new file, conn-client.c, to which all
the client connection-specific code will eventually move.

Note that the IDR tree gets very expensive on memory if the connection IDs
are widely scattered throughout the number space, so we shall need to
retire connections that have, say, an ID more than four times the maximum
number of client conns away from the current allocation point to try and
keep the IDs concentrated.  We will also need to retire connections from an
old epoch.

Also note that, for the moment, a pointer to the transport has to be passed
through into the ID allocation function so that we can take a BH lock to
prevent a locking issue against in-BH lookup of client connections.  This
will go away later when RCU is used for server connections also.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile      |    1 
 net/rxrpc/af_rxrpc.c    |    2 
 net/rxrpc/ar-internal.h |   13 ++-
 net/rxrpc/conn_client.c |   99 ++++++++++++++++++++
 net/rxrpc/conn_object.c |  231 +++++++++++++++++------------------------------
 net/rxrpc/transport.c   |    2 
 6 files changed, 196 insertions(+), 152 deletions(-)
 create mode 100644 net/rxrpc/conn_client.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index b005027f80cf..cfa221536f33 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -7,6 +7,7 @@ af-rxrpc-y := \
 	call_accept.o \
 	call_event.o \
 	call_object.o \
+	conn_client.o \
 	conn_event.o \
 	conn_object.o \
 	input.o \
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 73f5c553eef4..408bd024125b 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -858,6 +858,8 @@ static void __exit af_rxrpc_exit(void)
 	_debug("synchronise RCU");
 	rcu_barrier();
 	_debug("destroy locals");
+	ASSERT(idr_is_empty(&rxrpc_client_conn_ids));
+	idr_destroy(&rxrpc_client_conn_ids);
 	rxrpc_destroy_all_locals();
 
 	remove_proc_entry("rxrpc_conns", init_net.proc_net);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 60ba22f56957..89966508b26c 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -233,7 +233,6 @@ struct rxrpc_transport {
 	struct rxrpc_local	*local;		/* local transport endpoint */
 	struct rxrpc_peer	*peer;		/* remote transport endpoint */
 	struct rb_root		bundles;	/* client connection bundles on this transport */
-	struct rb_root		client_conns;	/* client connections on this transport */
 	struct rb_root		server_conns;	/* server connections on this transport */
 	struct list_head	link;		/* link in master session list */
 	unsigned long		put_time;	/* time at which to reap */
@@ -241,7 +240,6 @@ struct rxrpc_transport {
 	rwlock_t		conn_lock;	/* lock for active/dead connections */
 	atomic_t		usage;
 	int			debug_id;	/* debug ID for printks */
-	unsigned int		conn_idcounter;	/* connection ID counter (client) */
 };
 
 /*
@@ -312,6 +310,8 @@ struct rxrpc_connection {
 	struct key		*server_key;	/* security for this service */
 	struct crypto_skcipher	*cipher;	/* encryption handle */
 	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
+	unsigned long		flags;
+#define RXRPC_CONN_HAS_IDR	0		/* - Has a client conn ID assigned */
 	unsigned long		events;
 #define RXRPC_CONN_CHALLENGE	0		/* send challenge packet */
 	unsigned long		put_time;	/* time at which to reap */
@@ -551,6 +551,15 @@ void __rxrpc_put_call(struct rxrpc_call *);
 void __exit rxrpc_destroy_all_calls(void);
 
 /*
+ * conn_client.c
+ */
+extern struct idr rxrpc_client_conn_ids;
+
+int rxrpc_get_client_connection_id(struct rxrpc_connection *,
+				   struct rxrpc_transport *, gfp_t);
+void rxrpc_put_client_connection_id(struct rxrpc_connection *);
+
+/*
  * conn_event.c
  */
 void rxrpc_process_connection(struct work_struct *);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
new file mode 100644
index 000000000000..2cccb4be289d
--- /dev/null
+++ b/net/rxrpc/conn_client.c
@@ -0,0 +1,99 @@
+/* Client connection-specific management code.
+ *
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/slab.h>
+#include <linux/idr.h>
+#include <linux/timer.h>
+#include "ar-internal.h"
+
+/*
+ * We use machine-unique IDs for our client connections.
+ */
+DEFINE_IDR(rxrpc_client_conn_ids);
+static DEFINE_SPINLOCK(rxrpc_conn_id_lock);
+
+/*
+ * Get a connection ID and epoch for a client connection from the global pool.
+ * The connection struct pointer is then recorded in the idr radix tree.  The
+ * epoch is changed if this wraps.
+ *
+ * TODO: The IDR tree gets very expensive on memory if the connection IDs are
+ * widely scattered throughout the number space, so we shall need to retire
+ * connections that have, say, an ID more than four times the maximum number of
+ * client conns away from the current allocation point to try and keep the IDs
+ * concentrated.  We will also need to retire connections from an old epoch.
+ */
+int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
+				   struct rxrpc_transport *trans,
+				   gfp_t gfp)
+{
+	u32 epoch;
+	int id;
+
+	_enter("");
+
+	idr_preload(gfp);
+	write_lock_bh(&trans->conn_lock);
+	spin_lock(&rxrpc_conn_id_lock);
+
+	epoch = rxrpc_epoch;
+
+	/* We could use idr_alloc_cyclic() here, but we really need to know
+	 * when the thing wraps so that we can advance the epoch.
+	 */
+	if (rxrpc_client_conn_ids.cur == 0)
+		rxrpc_client_conn_ids.cur = 1;
+	id = idr_alloc(&rxrpc_client_conn_ids, conn,
+		       rxrpc_client_conn_ids.cur, 0x40000000, GFP_NOWAIT);
+	if (id < 0) {
+		if (id != -ENOSPC)
+			goto error;
+		id = idr_alloc(&rxrpc_client_conn_ids, conn,
+			       1, 0x40000000, GFP_NOWAIT);
+		if (id < 0)
+			goto error;
+		epoch++;
+		rxrpc_epoch = epoch;
+	}
+	rxrpc_client_conn_ids.cur = id + 1;
+
+	spin_unlock(&rxrpc_conn_id_lock);
+	write_unlock_bh(&trans->conn_lock);
+	idr_preload_end();
+
+	conn->proto.epoch = epoch;
+	conn->proto.cid = id << RXRPC_CIDSHIFT;
+	set_bit(RXRPC_CONN_HAS_IDR, &conn->flags);
+	_leave(" [CID %x:%x]", epoch, conn->proto.cid);
+	return 0;
+
+error:
+	spin_unlock(&rxrpc_conn_id_lock);
+	write_unlock_bh(&trans->conn_lock);
+	idr_preload_end();
+	_leave(" = %d", id);
+	return id;
+}
+
+/*
+ * Release a connection ID for a client connection from the global pool.
+ */
+void rxrpc_put_client_connection_id(struct rxrpc_connection *conn)
+{
+	if (test_bit(RXRPC_CONN_HAS_IDR, &conn->flags)) {
+		spin_lock(&rxrpc_conn_id_lock);
+		idr_remove(&rxrpc_client_conn_ids,
+			   conn->proto.cid >> RXRPC_CIDSHIFT);
+		spin_unlock(&rxrpc_conn_id_lock);
+	}
+}
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index cab2f6dbc5a1..312b75091d29 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -207,81 +207,6 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 }
 
 /*
- * assign a connection ID to a connection and add it to the transport's
- * connection lookup tree
- * - called with transport client lock held
- */
-static void rxrpc_assign_connection_id(struct rxrpc_connection *conn)
-{
-	struct rxrpc_connection *xconn;
-	struct rb_node *parent, **p;
-	__be32 epoch;
-	u32 cid;
-
-	_enter("");
-
-	epoch = conn->proto.epoch;
-
-	write_lock_bh(&conn->trans->conn_lock);
-
-	conn->trans->conn_idcounter += RXRPC_CID_INC;
-	if (conn->trans->conn_idcounter < RXRPC_CID_INC)
-		conn->trans->conn_idcounter = RXRPC_CID_INC;
-	cid = conn->trans->conn_idcounter;
-
-attempt_insertion:
-	parent = NULL;
-	p = &conn->trans->client_conns.rb_node;
-
-	while (*p) {
-		parent = *p;
-		xconn = rb_entry(parent, struct rxrpc_connection, node);
-
-		if (epoch < xconn->proto.epoch)
-			p = &(*p)->rb_left;
-		else if (epoch > xconn->proto.epoch)
-			p = &(*p)->rb_right;
-		else if (cid < xconn->proto.cid)
-			p = &(*p)->rb_left;
-		else if (cid > xconn->proto.cid)
-			p = &(*p)->rb_right;
-		else
-			goto id_exists;
-	}
-
-	/* we've found a suitable hole - arrange for this connection to occupy
-	 * it */
-	rb_link_node(&conn->node, parent, p);
-	rb_insert_color(&conn->node, &conn->trans->client_conns);
-
-	conn->proto.cid = cid;
-	write_unlock_bh(&conn->trans->conn_lock);
-	_leave(" [CID %x]", cid);
-	return;
-
-	/* we found a connection with the proposed ID - walk the tree from that
-	 * point looking for the next unused ID */
-id_exists:
-	for (;;) {
-		cid += RXRPC_CID_INC;
-		if (cid < RXRPC_CID_INC) {
-			cid = RXRPC_CID_INC;
-			conn->trans->conn_idcounter = cid;
-			goto attempt_insertion;
-		}
-
-		parent = rb_next(parent);
-		if (!parent)
-			goto attempt_insertion;
-
-		xconn = rb_entry(parent, struct rxrpc_connection, node);
-		if (epoch < xconn->proto.epoch ||
-		    cid < xconn->proto.cid)
-			goto attempt_insertion;
-	}
-}
-
-/*
  * add a call to a connection's call-by-ID tree
  */
 static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
@@ -315,27 +240,24 @@ static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
 }
 
 /*
- * connect a call on an exclusive connection
+ * Allocate a client connection.
  */
-static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
-				   struct rxrpc_conn_parameters *cp,
-				   struct rxrpc_transport *trans,
-				   struct rxrpc_call *call,
-				   gfp_t gfp)
+static struct rxrpc_connection *
+rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp,
+			      struct rxrpc_transport *trans,
+			      gfp_t gfp)
 {
 	struct rxrpc_connection *conn;
-	int chan, ret;
+	int ret;
 
 	_enter("");
 
 	conn = rxrpc_alloc_connection(gfp);
 	if (!conn) {
 		_leave(" = -ENOMEM");
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
 
-	conn->trans		= trans;
-	conn->bundle		= NULL;
 	conn->params		= *cp;
 	conn->proto.local	= cp->local;
 	conn->proto.epoch	= rxrpc_epoch;
@@ -344,35 +266,75 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 	conn->proto.family	= cp->peer->srx.transport.family;
 	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
 	conn->state		= RXRPC_CONN_CLIENT;
-	conn->avail_calls	= RXRPC_MAXCALLS - 1;
 
-	key_get(conn->params.key);
+	switch (conn->proto.family) {
+	case AF_INET:
+		conn->proto.addr_size = sizeof(conn->proto.ipv4_addr);
+		conn->proto.ipv4_addr = cp->peer->srx.transport.sin.sin_addr;
+		conn->proto.port = cp->peer->srx.transport.sin.sin_port;
+		break;
+	}
+
+	ret = rxrpc_get_client_connection_id(conn, trans, gfp);
+	if (ret < 0)
+		goto error_0;
 
 	ret = rxrpc_init_client_conn_security(conn);
-	if (ret < 0) {
-		key_put(conn->params.key);
-		kfree(conn);
-		_leave(" = %d [key]", ret);
-		return ret;
-	}
+	if (ret < 0)
+		goto error_1;
+
+	conn->security->prime_packet_security(conn);
 
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
 	write_unlock(&rxrpc_connection_lock);
 
-	spin_lock(&trans->client_lock);
+	key_get(conn->params.key);
+
+	_leave(" = %p", conn);
+	return conn;
+
+error_1:
+	rxrpc_put_client_connection_id(conn);
+error_0:
+	kfree(conn);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
+}
+
+/*
+ * connect a call on an exclusive connection
+ */
+static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
+				   struct rxrpc_conn_parameters *cp,
+				   struct rxrpc_transport *trans,
+				   struct rxrpc_call *call,
+				   gfp_t gfp)
+{
+	struct rxrpc_connection *conn;
+	int chan;
+
+	_enter("");
+
+	conn = rxrpc_alloc_client_connection(cp, trans, gfp);
+	if (IS_ERR(conn)) {
+		_leave(" = %ld", PTR_ERR(conn));
+		return PTR_ERR(conn);
+	}
+
 	atomic_inc(&trans->usage);
+	conn->trans = trans;
+	conn->bundle = NULL;
 
 	_net("CONNECT EXCL new %d on TRANS %d",
 	     conn->debug_id, conn->trans->debug_id);
 
-	rxrpc_assign_connection_id(conn);
-
 	/* Since no one else can use the connection, we just use the first
 	 * channel.
 	 */
 	chan = 0;
 	atomic_inc(&conn->usage);
+	conn->avail_calls = RXRPC_MAXCALLS - 1;
 	conn->channels[chan] = call;
 	conn->call_counter = 1;
 	call->conn = conn;
@@ -383,8 +345,6 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 	_net("CONNECT client on conn %d chan %d as call %x",
 	     conn->debug_id, chan, call->call_id);
 
-	spin_unlock(&trans->client_lock);
-
 	rxrpc_add_call_ID_to_conn(conn, call);
 	_leave(" = 0");
 	return 0;
@@ -402,7 +362,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 		       gfp_t gfp)
 {
 	struct rxrpc_connection *conn, *candidate;
-	int chan, ret;
+	int chan;
 
 	DECLARE_WAITQUEUE(myself, current);
 
@@ -492,51 +452,25 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 
 		/* not yet present - create a candidate for a new connection and then
 		 * redo the check */
-		candidate = rxrpc_alloc_connection(gfp);
+		candidate = rxrpc_alloc_client_connection(cp, trans, gfp);
 		if (!candidate) {
 			_leave(" = -ENOMEM");
 			return -ENOMEM;
 		}
 
+		atomic_inc(&bundle->usage);
+		atomic_inc(&trans->usage);
 		candidate->trans = trans;
 		candidate->bundle = bundle;
-		candidate->params = *cp;
-		candidate->proto.local = cp->local;
-		candidate->proto.epoch = rxrpc_epoch;
-		candidate->proto.cid = 0;
-		candidate->proto.in_clientflag = 0;
-		candidate->proto.family = cp->peer->srx.transport.family;
-		candidate->out_clientflag = RXRPC_CLIENT_INITIATED;
-		candidate->state = RXRPC_CONN_CLIENT;
-		candidate->avail_calls = RXRPC_MAXCALLS;
-
-		key_get(candidate->params.key);
-
-		ret = rxrpc_init_client_conn_security(candidate);
-		if (ret < 0) {
-			key_put(candidate->params.key);
-			kfree(candidate);
-			_leave(" = %d [key]", ret);
-			return ret;
-		}
-
-		write_lock_bh(&rxrpc_connection_lock);
-		list_add_tail(&candidate->link, &rxrpc_connections);
-		write_unlock_bh(&rxrpc_connection_lock);
 
 		spin_lock(&trans->client_lock);
 
 		list_add(&candidate->bundle_link, &bundle->unused_conns);
 		bundle->num_conns++;
-		atomic_inc(&bundle->usage);
-		atomic_inc(&trans->usage);
 
 		_net("CONNECT new %d on TRANS %d",
 		     candidate->debug_id, candidate->trans->debug_id);
 
-		rxrpc_assign_connection_id(candidate);
-		candidate->security->prime_packet_security(candidate);
-
 		/* leave the candidate lurking in zombie mode attached to the
 		 * bundle until we're ready for it */
 		rxrpc_put_connection(candidate);
@@ -735,25 +669,27 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
 	cid	= sp->hdr.cid & RXRPC_CIDMASK;
 	epoch	= sp->hdr.epoch;
 
-	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED)
+	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED) {
 		p = trans->server_conns.rb_node;
-	else
-		p = trans->client_conns.rb_node;
-
-	while (p) {
-		conn = rb_entry(p, struct rxrpc_connection, node);
-
-		_debug("maybe %x", conn->proto.cid);
-
-		if (epoch < conn->proto.epoch)
-			p = p->rb_left;
-		else if (epoch > conn->proto.epoch)
-			p = p->rb_right;
-		else if (cid < conn->proto.cid)
-			p = p->rb_left;
-		else if (cid > conn->proto.cid)
-			p = p->rb_right;
-		else
+		while (p) {
+			conn = rb_entry(p, struct rxrpc_connection, node);
+
+			_debug("maybe %x", conn->proto.cid);
+
+			if (epoch < conn->proto.epoch)
+				p = p->rb_left;
+			else if (epoch > conn->proto.epoch)
+				p = p->rb_right;
+			else if (cid < conn->proto.cid)
+				p = p->rb_left;
+			else if (cid > conn->proto.cid)
+				p = p->rb_right;
+			else
+				goto found;
+		}
+	} else {
+		conn = idr_find(&rxrpc_client_conn_ids, cid >> RXRPC_CIDSHIFT);
+		if (conn && conn->proto.epoch == epoch)
 			goto found;
 	}
 
@@ -846,8 +782,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 		} else if (reap_time <= now) {
 			list_move_tail(&conn->link, &graveyard);
 			if (conn->out_clientflag)
-				rb_erase(&conn->node,
-					 &conn->trans->client_conns);
+				rxrpc_put_client_connection_id(conn);
 			else
 				rb_erase(&conn->node,
 					 &conn->trans->server_conns);
diff --git a/net/rxrpc/transport.c b/net/rxrpc/transport.c
index 24c71218a6f8..140628d94bb0 100644
--- a/net/rxrpc/transport.c
+++ b/net/rxrpc/transport.c
@@ -47,12 +47,10 @@ static struct rxrpc_transport *rxrpc_alloc_transport(struct rxrpc_local *local,
 		trans->peer = peer;
 		INIT_LIST_HEAD(&trans->link);
 		trans->bundles = RB_ROOT;
-		trans->client_conns = RB_ROOT;
 		trans->server_conns = RB_ROOT;
 		spin_lock_init(&trans->client_lock);
 		rwlock_init(&trans->conn_lock);
 		atomic_set(&trans->usage, 1);
-		trans->conn_idcounter = peer->srx.srx_service << 16;
 		trans->debug_id = atomic_inc_return(&rxrpc_debug_id);
 	}
 
