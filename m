From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 14/19] rxrpc: Split service connection code out
 into its own file
Date: Thu, 30 Jun 2016 15:12:22 +0100
Message-ID: <146729594270.26306.6317475466933409703.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100AbcF3ONB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:13:01 -0400
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the service-specific connection code out into into its own file.  The
client-specific code has already been split out.  This will leave just the
common code in the original file.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile       |    1 
 net/rxrpc/ar-internal.h  |   13 +++-
 net/rxrpc/conn_object.c  |  133 ------------------------------------------
 net/rxrpc/conn_service.c |  146 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 157 insertions(+), 136 deletions(-)
 create mode 100644 net/rxrpc/conn_service.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 6522e50fb750..10f3f48a16a8 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -10,6 +10,7 @@ af-rxrpc-y := \
 	conn_client.o \
 	conn_event.o \
 	conn_object.o \
+	conn_service.o \
 	input.o \
 	insecure.o \
 	key.o \
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index b95380dd0f37..2495c4facf51 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -565,6 +565,9 @@ extern struct list_head rxrpc_connections;
 extern struct list_head rxrpc_connection_proc_list;
 extern rwlock_t rxrpc_connection_lock;
 
+void rxrpc_conn_hash_proto_key(struct rxrpc_conn_proto *);
+void rxrpc_extract_conn_params(struct rxrpc_conn_proto *,
+			       struct rxrpc_local *, struct sk_buff *);
 struct rxrpc_connection *rxrpc_alloc_connection(gfp_t);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *,
 					       struct rxrpc_peer *,
@@ -573,9 +576,6 @@ void __rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
-struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
-						   struct rxrpc_peer *,
-						   struct sk_buff *);
 
 static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
 {
@@ -606,6 +606,13 @@ static inline void rxrpc_queue_conn(struct rxrpc_connection *conn)
 }
 
 /*
+ * conn_service.c
+ */
+struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
+						   struct rxrpc_peer *,
+						   struct sk_buff *);
+
+/*
  * input.c
  */
 void rxrpc_data_ready(struct sock *);
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 4a2876b9904b..12d7c7850aed 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -63,139 +63,6 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 }
 
 /*
- * get a record of an incoming connection
- */
-struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
-						   struct rxrpc_peer *peer,
-						   struct sk_buff *skb)
-{
-	struct rxrpc_connection *conn, *candidate = NULL;
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	struct rb_node *p, **pp;
-	const char *new = "old";
-	__be32 epoch;
-	u32 cid;
-
-	_enter("");
-
-	ASSERT(sp->hdr.flags & RXRPC_CLIENT_INITIATED);
-
-	epoch = sp->hdr.epoch;
-	cid = sp->hdr.cid & RXRPC_CIDMASK;
-
-	/* search the connection list first */
-	read_lock_bh(&peer->conn_lock);
-
-	p = peer->service_conns.rb_node;
-	while (p) {
-		conn = rb_entry(p, struct rxrpc_connection, service_node);
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
-			goto found_extant_connection;
-	}
-	read_unlock_bh(&peer->conn_lock);
-
-	/* not yet present - create a candidate for a new record and then
-	 * redo the search */
-	candidate = rxrpc_alloc_connection(GFP_NOIO);
-	if (!candidate) {
-		_leave(" = -ENOMEM");
-		return ERR_PTR(-ENOMEM);
-	}
-
-	candidate->proto.local		= local;
-	candidate->proto.epoch		= sp->hdr.epoch;
-	candidate->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
-	candidate->proto.in_clientflag	= RXRPC_CLIENT_INITIATED;
-	candidate->params.local		= local;
-	candidate->params.peer		= peer;
-	candidate->params.service_id	= sp->hdr.serviceId;
-	candidate->security_ix		= sp->hdr.securityIndex;
-	candidate->out_clientflag	= 0;
-	candidate->state		= RXRPC_CONN_SERVICE;
-	if (candidate->params.service_id)
-		candidate->state	= RXRPC_CONN_SERVICE_UNSECURED;
-
-	write_lock_bh(&peer->conn_lock);
-
-	pp = &peer->service_conns.rb_node;
-	p = NULL;
-	while (*pp) {
-		p = *pp;
-		conn = rb_entry(p, struct rxrpc_connection, service_node);
-
-		if (epoch < conn->proto.epoch)
-			pp = &(*pp)->rb_left;
-		else if (epoch > conn->proto.epoch)
-			pp = &(*pp)->rb_right;
-		else if (cid < conn->proto.cid)
-			pp = &(*pp)->rb_left;
-		else if (cid > conn->proto.cid)
-			pp = &(*pp)->rb_right;
-		else
-			goto found_extant_second;
-	}
-
-	/* we can now add the new candidate to the list */
-	conn = candidate;
-	candidate = NULL;
-	rb_link_node(&conn->service_node, p, pp);
-	rb_insert_color(&conn->service_node, &peer->service_conns);
-	rxrpc_get_peer(peer);
-	rxrpc_get_local(local);
-
-	write_unlock_bh(&peer->conn_lock);
-
-	write_lock(&rxrpc_connection_lock);
-	list_add_tail(&conn->link, &rxrpc_connections);
-	write_unlock(&rxrpc_connection_lock);
-
-	new = "new";
-
-success:
-	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->proto.cid);
-
-	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
-	return conn;
-
-	/* we found the connection in the list immediately */
-found_extant_connection:
-	if (sp->hdr.securityIndex != conn->security_ix) {
-		read_unlock_bh(&peer->conn_lock);
-		goto security_mismatch;
-	}
-	rxrpc_get_connection(conn);
-	read_unlock_bh(&peer->conn_lock);
-	goto success;
-
-	/* we found the connection on the second time through the list */
-found_extant_second:
-	if (sp->hdr.securityIndex != conn->security_ix) {
-		write_unlock_bh(&peer->conn_lock);
-		goto security_mismatch;
-	}
-	rxrpc_get_connection(conn);
-	write_unlock_bh(&peer->conn_lock);
-	kfree(candidate);
-	goto success;
-
-security_mismatch:
-	kfree(candidate);
-	_leave(" = -EKEYREJECTED");
-	return ERR_PTR(-EKEYREJECTED);
-}
-
-/*
  * find a connection based on transport and RxRPC connection ID for an incoming
  * packet
  */
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
new file mode 100644
index 000000000000..2536d5276f67
--- /dev/null
+++ b/net/rxrpc/conn_service.c
@@ -0,0 +1,146 @@
+/* Service connection management
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
+#include <linux/slab.h>
+#include "ar-internal.h"
+
+/*
+ * get a record of an incoming connection
+ */
+struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
+						   struct rxrpc_peer *peer,
+						   struct sk_buff *skb)
+{
+	struct rxrpc_connection *conn, *candidate = NULL;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rb_node *p, **pp;
+	const char *new = "old";
+	__be32 epoch;
+	u32 cid;
+
+	_enter("");
+
+	ASSERT(sp->hdr.flags & RXRPC_CLIENT_INITIATED);
+
+	epoch = sp->hdr.epoch;
+	cid = sp->hdr.cid & RXRPC_CIDMASK;
+
+	/* search the connection list first */
+	read_lock_bh(&peer->conn_lock);
+
+	p = peer->service_conns.rb_node;
+	while (p) {
+		conn = rb_entry(p, struct rxrpc_connection, service_node);
+
+		_debug("maybe %x", conn->proto.cid);
+
+		if (epoch < conn->proto.epoch)
+			p = p->rb_left;
+		else if (epoch > conn->proto.epoch)
+			p = p->rb_right;
+		else if (cid < conn->proto.cid)
+			p = p->rb_left;
+		else if (cid > conn->proto.cid)
+			p = p->rb_right;
+		else
+			goto found_extant_connection;
+	}
+	read_unlock_bh(&peer->conn_lock);
+
+	/* not yet present - create a candidate for a new record and then
+	 * redo the search */
+	candidate = rxrpc_alloc_connection(GFP_NOIO);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	candidate->proto.local		= local;
+	candidate->proto.epoch		= sp->hdr.epoch;
+	candidate->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
+	candidate->proto.in_clientflag	= RXRPC_CLIENT_INITIATED;
+	candidate->params.local		= local;
+	candidate->params.peer		= peer;
+	candidate->params.service_id	= sp->hdr.serviceId;
+	candidate->security_ix		= sp->hdr.securityIndex;
+	candidate->out_clientflag	= 0;
+	candidate->state		= RXRPC_CONN_SERVICE;
+	if (candidate->params.service_id)
+		candidate->state	= RXRPC_CONN_SERVICE_UNSECURED;
+
+	write_lock_bh(&peer->conn_lock);
+
+	pp = &peer->service_conns.rb_node;
+	p = NULL;
+	while (*pp) {
+		p = *pp;
+		conn = rb_entry(p, struct rxrpc_connection, service_node);
+
+		if (epoch < conn->proto.epoch)
+			pp = &(*pp)->rb_left;
+		else if (epoch > conn->proto.epoch)
+			pp = &(*pp)->rb_right;
+		else if (cid < conn->proto.cid)
+			pp = &(*pp)->rb_left;
+		else if (cid > conn->proto.cid)
+			pp = &(*pp)->rb_right;
+		else
+			goto found_extant_second;
+	}
+
+	/* we can now add the new candidate to the list */
+	conn = candidate;
+	candidate = NULL;
+	rb_link_node(&conn->service_node, p, pp);
+	rb_insert_color(&conn->service_node, &peer->service_conns);
+	rxrpc_get_peer(peer);
+	rxrpc_get_local(local);
+
+	write_unlock_bh(&peer->conn_lock);
+
+	write_lock(&rxrpc_connection_lock);
+	list_add_tail(&conn->link, &rxrpc_connections);
+	write_unlock(&rxrpc_connection_lock);
+
+	new = "new";
+
+success:
+	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->proto.cid);
+
+	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
+	return conn;
+
+	/* we found the connection in the list immediately */
+found_extant_connection:
+	if (sp->hdr.securityIndex != conn->security_ix) {
+		read_unlock_bh(&peer->conn_lock);
+		goto security_mismatch;
+	}
+	rxrpc_get_connection(conn);
+	read_unlock_bh(&peer->conn_lock);
+	goto success;
+
+	/* we found the connection on the second time through the list */
+found_extant_second:
+	if (sp->hdr.securityIndex != conn->security_ix) {
+		write_unlock_bh(&peer->conn_lock);
+		goto security_mismatch;
+	}
+	rxrpc_get_connection(conn);
+	write_unlock_bh(&peer->conn_lock);
+	kfree(candidate);
+	goto success;
+
+security_mismatch:
+	kfree(candidate);
+	_leave(" = -EKEYREJECTED");
+	return ERR_PTR(-EKEYREJECTED);
+}
