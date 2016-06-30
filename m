From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 19/19] rxrpc: Use RCU to access a peer's service
 connection tree
Date: Thu, 30 Jun 2016 15:12:58 +0100
Message-ID: <146729597856.26306.17024362508555652794.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move to using RCU access to a peer's service connection tree when routing
an incoming packet.  This is done using a seqlock to trigger retrying of
the tree walk if a change happened.

Further, we no longer get a ref on the connection looked up in the
data_ready handler unless we queue the connection's work item - and then
only if the refcount > 0.


Note that I'm avoiding the use of a hash table for service connections
because each service connection is addressed by a 62-bit number
(constructed from epoch and connection ID >> 2) that would allow the client
to engage in bucket stuffing, given knowledge of the hash algorithm.
Peers, however, are hashed as the network address is less controllable by
the client.  The total number of peers will also be limited in a future
commit.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |   21 ++--
 net/rxrpc/conn_client.c  |    2 
 net/rxrpc/conn_object.c  |   65 +++++------
 net/rxrpc/conn_service.c |  272 +++++++++++++++++++++++++++-------------------
 net/rxrpc/input.c        |   44 ++++---
 net/rxrpc/peer_object.c  |    2 
 6 files changed, 225 insertions(+), 181 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f7f85151b399..02945cc77399 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -10,6 +10,7 @@
  */
 
 #include <linux/atomic.h>
+#include <linux/seqlock.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <rxrpc/packet.h>
@@ -206,7 +207,7 @@ struct rxrpc_peer {
 	struct hlist_head	error_targets;	/* targets for net error distribution */
 	struct work_struct	error_distributor;
 	struct rb_root		service_conns;	/* Service connections */
-	rwlock_t		conn_lock;
+	seqlock_t		service_conn_lock;
 	spinlock_t		lock;		/* access lock */
 	unsigned int		if_mtu;		/* interface MTU for this peer */
 	unsigned int		mtu;		/* network MTU for this peer */
@@ -561,12 +562,10 @@ extern struct list_head rxrpc_connections;
 extern struct list_head rxrpc_connection_proc_list;
 extern rwlock_t rxrpc_connection_lock;
 
-void rxrpc_conn_hash_proto_key(struct rxrpc_conn_proto *);
-void rxrpc_extract_conn_params(struct rxrpc_conn_proto *,
-			       struct rxrpc_local *, struct sk_buff *);
+int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
 struct rxrpc_connection *rxrpc_alloc_connection(gfp_t);
-struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *,
-					       struct sk_buff *);
+struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *,
+						   struct sk_buff *);
 void __rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_put_connection(struct rxrpc_connection *);
@@ -593,16 +592,20 @@ struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *con
 	return atomic_inc_not_zero(&conn->usage) ? conn : NULL;
 }
 
-static inline void rxrpc_queue_conn(struct rxrpc_connection *conn)
+static inline bool rxrpc_queue_conn(struct rxrpc_connection *conn)
 {
-	if (rxrpc_get_connection_maybe(conn) &&
-	    !rxrpc_queue_work(&conn->processor))
+	if (!rxrpc_get_connection_maybe(conn))
+		return false;
+	if (!rxrpc_queue_work(&conn->processor))
 		rxrpc_put_connection(conn);
+	return true;
 }
 
 /*
  * conn_service.c
  */
+struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *,
+						     struct sk_buff *);
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
 						   struct sockaddr_rxrpc *,
 						   struct sk_buff *);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 74b97f67acf5..ebdc267ecfb4 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -132,8 +132,6 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	}
 
 	conn->params		= *cp;
-	conn->proto.epoch	= rxrpc_epoch;
-	conn->proto.cid		= 0;
 	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
 	conn->state		= RXRPC_CONN_CLIENT;
 
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index ff19ee123a9b..231aa28c0d88 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -15,7 +15,6 @@
 #include <linux/slab.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
-#include <linux/crypto.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
@@ -66,24 +65,30 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 }
 
 /*
- * find a connection based on transport and RxRPC connection ID for an incoming
- * packet
+ * Look up a connection in the cache by protocol parameters.
+ *
+ * If successful, a pointer to the connection is returned, but no ref is taken.
+ * NULL is returned if there is no match.
+ *
+ * The caller must be holding the RCU read lock.
  */
-struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
-					       struct sk_buff *skb)
+struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *local,
+						   struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn;
 	struct rxrpc_conn_proto k;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct sockaddr_rxrpc srx;
 	struct rxrpc_peer *peer;
-	struct rb_node *p;
 
-	_enter(",{%x,%x}", sp->hdr.cid, sp->hdr.flags);
+	_enter(",%x", sp->hdr.cid & RXRPC_CIDMASK);
 
 	if (rxrpc_extract_addr_from_skb(&srx, skb) < 0)
 		goto not_found;
 
+	k.epoch	= sp->hdr.epoch;
+	k.cid	= sp->hdr.cid & RXRPC_CIDMASK;
+
 	/* We may have to handle mixing IPv4 and IPv6 */
 	if (srx.transport.family != local->srx.transport.family) {
 		pr_warn_ratelimited("AF_RXRPC: Protocol mismatch %u not %u\n",
@@ -103,32 +108,23 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
 		peer = rxrpc_lookup_peer_rcu(local, &srx);
 		if (!peer)
 			goto not_found;
-
-		read_lock_bh(&peer->conn_lock);
-
-		p = peer->service_conns.rb_node;
-		while (p) {
-			conn = rb_entry(p, struct rxrpc_connection, service_node);
-
-			_debug("maybe %x", conn->proto.cid);
-
-			if (k.epoch < conn->proto.epoch)
-				p = p->rb_left;
-			else if (k.epoch > conn->proto.epoch)
-				p = p->rb_right;
-			else if (k.cid < conn->proto.cid)
-				p = p->rb_left;
-			else if (k.cid > conn->proto.cid)
-				p = p->rb_right;
-			else
-				goto found_service_conn;
-		}
-		read_unlock_bh(&peer->conn_lock);
+		conn = rxrpc_find_service_conn_rcu(peer, skb);
+		if (!conn || atomic_read(&conn->usage) == 0)
+			goto not_found;
+		_leave(" = %p", conn);
+		return conn;
 	} else {
+		/* Look up client connections by connection ID alone as their
+		 * IDs are unique for this machine.
+		 */
 		conn = idr_find(&rxrpc_client_conn_ids,
-				k.cid >> RXRPC_CIDSHIFT);
-		if (!conn ||
-		    conn->proto.epoch != k.epoch ||
+				sp->hdr.cid >> RXRPC_CIDSHIFT);
+		if (!conn || atomic_read(&conn->usage) == 0) {
+			_debug("no conn");
+			goto not_found;
+		}
+
+		if (conn->proto.epoch != k.epoch ||
 		    conn->params.local != local)
 			goto not_found;
 
@@ -145,7 +141,6 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
 			BUG();
 		}
 
-		conn = rxrpc_get_connection_maybe(conn);
 		_leave(" = %p", conn);
 		return conn;
 	}
@@ -153,12 +148,6 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
 not_found:
 	_leave(" = NULL");
 	return NULL;
-
-found_service_conn:
-	conn = rxrpc_get_connection_maybe(conn);
-	read_unlock_bh(&peer->conn_lock);
-	_leave(" = %p", conn);
-	return conn;
 }
 
 /*
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index ac56ecf1c079..acd73975353e 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -13,19 +13,122 @@
 #include "ar-internal.h"
 
 /*
+ * Find a service connection under RCU conditions.
+ *
+ * We could use a hash table, but that is subject to bucket stuffing by an
+ * attacker as the client gets to pick the epoch and cid values and would know
+ * the hash function.  So, instead, we use a hash table for the peer and from
+ * that an rbtree to find the service connection.  Under ordinary circumstances
+ * it might be slower than a large hash table, but it is at least limited in
+ * depth.
+ */
+struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *peer,
+						     struct sk_buff *skb)
+{
+	struct rxrpc_connection *conn = NULL;
+	struct rxrpc_conn_proto k;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rb_node *p;
+	unsigned int seq;
+
+	k.epoch	= sp->hdr.epoch;
+	k.cid	= sp->hdr.cid & RXRPC_CIDMASK;
+
+	do {
+		/* Unfortunately, rbtree walking doesn't give reliable results
+		 * under just the RCU read lock, so we have to check for
+		 * changes.
+		 */
+		read_seqbegin_or_lock(&peer->service_conn_lock, &seq);
+
+		p = peer->service_conns.rb_node;
+		while (p) {
+			conn = rb_entry(p, struct rxrpc_connection, service_node);
+
+			if (conn->proto.index_key < k.index_key)
+				p = p->rb_left;
+			else if (conn->proto.index_key > k.index_key)
+				p = p->rb_right;
+			else
+				goto done;
+			conn = NULL;
+		}
+	} while (need_seqretry(&peer->service_conn_lock, seq));
+
+done:
+	done_seqretry(&peer->service_conn_lock, seq);
+	_leave(" = %d", conn ? conn->debug_id : -1);
+	return conn;
+}
+
+/*
+ * Insert a service connection into a peer's tree, thereby making it a target
+ * for incoming packets.
+ */
+static struct rxrpc_connection *
+rxrpc_publish_service_conn(struct rxrpc_peer *peer,
+			   struct rxrpc_connection *conn)
+{
+	struct rxrpc_connection *cursor = NULL;
+	struct rxrpc_conn_proto k = conn->proto;
+	struct rb_node **pp, *parent;
+
+	write_seqlock_bh(&peer->service_conn_lock);
+
+	pp = &peer->service_conns.rb_node;
+	parent = NULL;
+	while (*pp) {
+		parent = *pp;
+		cursor = rb_entry(parent,
+				  struct rxrpc_connection, service_node);
+
+		if (cursor->proto.index_key < k.index_key)
+			pp = &(*pp)->rb_left;
+		else if (cursor->proto.index_key > k.index_key)
+			pp = &(*pp)->rb_right;
+		else
+			goto found_extant_conn;
+	}
+
+	rb_link_node(&conn->service_node, parent, pp);
+	rb_insert_color(&conn->service_node, &peer->service_conns);
+conn_published:
+	set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags);
+	write_sequnlock_bh(&peer->service_conn_lock);
+	_leave(" = %d [new]", conn->debug_id);
+	return conn;
+
+found_extant_conn:
+	if (atomic_read(&cursor->usage) == 0)
+		goto replace_old_connection;
+	write_sequnlock_bh(&peer->service_conn_lock);
+	/* We should not be able to get here.  rxrpc_incoming_connection() is
+	 * called in a non-reentrant context, so there can't be a race to
+	 * insert a new connection.
+	 */
+	BUG();
+
+replace_old_connection:
+	/* The old connection is from an outdated epoch. */
+	_debug("replace conn");
+	rb_replace_node(&cursor->service_node,
+			&conn->service_node,
+			&peer->service_conns);
+	clear_bit(RXRPC_CONN_IN_SERVICE_CONNS, &cursor->flags);
+	goto conn_published;
+}
+
+/*
  * get a record of an incoming connection
  */
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 						   struct sockaddr_rxrpc *srx,
 						   struct sk_buff *skb)
 {
-	struct rxrpc_connection *conn, *candidate = NULL;
+	struct rxrpc_connection *conn;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_peer *peer;
-	struct rb_node *p, **pp;
 	const char *new = "old";
-	__be32 epoch;
-	u32 cid;
 
 	_enter("");
 
@@ -37,131 +140,80 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 
 	ASSERT(sp->hdr.flags & RXRPC_CLIENT_INITIATED);
 
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
+	rcu_read_lock();
+	peer = rxrpc_lookup_peer_rcu(local, srx);
+	if (peer) {
+		conn = rxrpc_find_service_conn_rcu(peer, skb);
+		if (conn) {
+			if (sp->hdr.securityIndex != conn->security_ix)
+				goto security_mismatch_rcu;
+			if (rxrpc_get_connection_maybe(conn))
+				goto found_extant_connection_rcu;
+
+			/* The conn has expired but we can't remove it without
+			 * the appropriate lock, so we attempt to replace it
+			 * when we have a new candidate.
+			 */
+		}
+
+		if (!rxrpc_get_peer_maybe(peer))
+			peer = NULL;
 	}
-	read_unlock_bh(&peer->conn_lock);
-
-	/* not yet present - create a candidate for a new record and then
-	 * redo the search */
-	candidate = rxrpc_alloc_connection(GFP_NOIO);
-	if (!candidate) {
-		rxrpc_put_peer(peer);
-		_leave(" = -ENOMEM");
-		return ERR_PTR(-ENOMEM);
-	}
-
-	candidate->proto.epoch		= sp->hdr.epoch;
-	candidate->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
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
+	rcu_read_unlock();
 
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
+	if (!peer) {
+		peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
+		if (IS_ERR(peer))
+			goto enomem;
 	}
 
-	/* we can now add the new candidate to the list */
-	set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &candidate->flags);
-	rb_link_node(&candidate->service_node, p, pp);
-	rb_insert_color(&candidate->service_node, &peer->service_conns);
-attached:
-	conn = candidate;
-	candidate = NULL;
-	rxrpc_get_peer(peer);
-	rxrpc_get_local(local);
+	/* We don't have a matching record yet. */
+	conn = rxrpc_alloc_connection(GFP_NOIO);
+	if (!conn)
+		goto enomem_peer;
+
+	conn->proto.epoch	= sp->hdr.epoch;
+	conn->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
+	conn->params.local	= local;
+	conn->params.peer	= peer;
+	conn->params.service_id	= sp->hdr.serviceId;
+	conn->security_ix	= sp->hdr.securityIndex;
+	conn->out_clientflag	= 0;
+	conn->state		= RXRPC_CONN_SERVICE;
+	if (conn->params.service_id)
+		conn->state	= RXRPC_CONN_SERVICE_UNSECURED;
 
-	write_unlock_bh(&peer->conn_lock);
+	rxrpc_get_local(local);
 
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
+	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
 	write_unlock(&rxrpc_connection_lock);
 
+	/* Make the connection a target for incoming packets. */
+	rxrpc_publish_service_conn(peer, conn);
+
 	new = "new";
 
 success:
 	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->proto.cid);
-
-	rxrpc_put_peer(peer);
 	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
 	return conn;
 
-	/* we found the connection in the list immediately */
-found_extant_connection:
-	if (!rxrpc_get_connection_maybe(conn)) {
-		set_bit(RXRPC_CONN_IN_SERVICE_CONNS, &candidate->flags);
-		rb_replace_node(&conn->service_node,
-				&candidate->service_node,
-				&peer->service_conns);
-		clear_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags);
-		goto attached;
-	}
-
-	if (sp->hdr.securityIndex != conn->security_ix) {
-		read_unlock_bh(&peer->conn_lock);
-		goto security_mismatch_put;
-	}
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
+found_extant_connection_rcu:
+	rcu_read_unlock();
 	goto success;
 
-security_mismatch_put:
-	rxrpc_put_connection(conn);
-security_mismatch:
-	kfree(candidate);
+security_mismatch_rcu:
+	rcu_read_unlock();
 	_leave(" = -EKEYREJECTED");
 	return ERR_PTR(-EKEYREJECTED);
+
+enomem_peer:
+	rxrpc_put_peer(peer);
+enomem:
+	_leave(" = -ENOMEM");
+	return ERR_PTR(-ENOMEM);
 }
 
 /*
@@ -172,8 +224,8 @@ void rxrpc_unpublish_service_conn(struct rxrpc_connection *conn)
 {
 	struct rxrpc_peer *peer = conn->params.peer;
 
-	write_lock_bh(&peer->conn_lock);
+	write_seqlock_bh(&peer->service_conn_lock);
 	if (test_and_clear_bit(RXRPC_CONN_IN_SERVICE_CONNS, &conn->flags))
 		rb_erase(&conn->service_node, &peer->service_conns);
-	write_unlock_bh(&peer->conn_lock);
+	write_sequnlock_bh(&peer->service_conn_lock);
 }
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 51a7611dd2f6..52c02f1fa686 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -575,13 +575,13 @@ done:
  * post connection-level events to the connection
  * - this includes challenges, responses and some aborts
  */
-static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
+static bool rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 				      struct sk_buff *skb)
 {
 	_enter("%p,%p", conn, skb);
 
 	skb_queue_tail(&conn->rx_queue, skb);
-	rxrpc_queue_conn(conn);
+	return rxrpc_queue_conn(conn);
 }
 
 /*
@@ -636,6 +636,7 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
  */
 void rxrpc_data_ready(struct sock *sk)
 {
+	struct rxrpc_connection *conn;
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_local *local = sk->sk_user_data;
 	struct sk_buff *skb;
@@ -699,36 +700,37 @@ void rxrpc_data_ready(struct sock *sk)
 	    (sp->hdr.callNumber == 0 || sp->hdr.seq == 0))
 		goto bad_message;
 
-	if (sp->hdr.callNumber == 0) {
-		/* This is a connection-level packet. These should be
-		 * fairly rare, so the extra overhead of looking them up the
-		 * old-fashioned way doesn't really hurt */
-		struct rxrpc_connection *conn;
-
-		rcu_read_lock();
-		conn = rxrpc_find_connection(local, skb);
-		rcu_read_unlock();
-		if (!conn)
-			goto cant_route_call;
+	rcu_read_lock();
+
+retry_find_conn:
+	conn = rxrpc_find_connection_rcu(local, skb);
+	if (!conn)
+		goto cant_route_call;
 
+	if (sp->hdr.callNumber == 0) {
+		/* Connection-level packet */
 		_debug("CONN %p {%d}", conn, conn->debug_id);
-		rxrpc_post_packet_to_conn(conn, skb);
-		rxrpc_put_connection(conn);
+		if (!rxrpc_post_packet_to_conn(conn, skb))
+			goto retry_find_conn;
 	} else {
-		struct rxrpc_call *call;
+		/* Call-bound packets are routed by connection channel. */
+		unsigned int channel = sp->hdr.cid & RXRPC_CHANNELMASK;
+		struct rxrpc_channel *chan = &conn->channels[channel];
+		struct rxrpc_call *call = rcu_dereference(chan->call);
 
-		call = rxrpc_find_call_hash(&sp->hdr, local,
-					    AF_INET, &ip_hdr(skb)->saddr);
-		if (call)
-			rxrpc_post_packet_to_call(call, skb);
-		else
+		if (!call || atomic_read(&call->usage) == 0)
 			goto cant_route_call;
+
+		rxrpc_post_packet_to_call(call, skb);
 	}
 
+	rcu_read_unlock();
 out:
 	return;
 
 cant_route_call:
+	rcu_read_unlock();
+
 	_debug("can't route call");
 	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
 	    sp->hdr.type == RXRPC_PACKET_TYPE_DATA) {
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 01d4930a11f7..538e9831c699 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -189,7 +189,7 @@ struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *local, gfp_t gfp)
 		INIT_WORK(&peer->error_distributor,
 			  &rxrpc_peer_error_distributor);
 		peer->service_conns = RB_ROOT;
-		rwlock_init(&peer->conn_lock);
+		seqlock_init(&peer->service_conn_lock);
 		spin_lock_init(&peer->lock);
 		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
 	}
