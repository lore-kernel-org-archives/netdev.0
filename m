From: David Howells <dhowells@redhat.com>
Subject: [PATCH 8/8] af_rxrpc: Keep rxrpc_call pointers in a hashtable [ver
 #2]
Date: Thu, 06 Mar 2014 12:47:11 +0000
Message-ID: <20140306124711.16645.46605.stgit@warthog.procyon.org.uk>
References: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Smith <tim@electronghost.co.uk>

Keep track of rxrpc_call structures in a hashtable so they can be
found directly from the network parameters which define the call.

This allows incoming packets to be routed directly to a call without walking
through hierarchy of peer -> transport -> connection -> call and all the
spinlocks that that entailed.

Signed-off-by: Tim Smith <tim@electronghost.co.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-call.c     |  193 +++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/ar-input.c    |  177 ++++++++++++++++++-------------------------
 net/rxrpc/ar-internal.h |   13 +++
 3 files changed, 277 insertions(+), 106 deletions(-)

diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 6e4d58c9b042..a9e05db0f5d5 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -12,6 +12,8 @@
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/circ_buf.h>
+#include <linux/hashtable.h>
+#include <linux/spinlock_types.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
@@ -55,6 +57,145 @@ static void rxrpc_dead_call_expired(unsigned long _call);
 static void rxrpc_ack_time_expired(unsigned long _call);
 static void rxrpc_resend_time_expired(unsigned long _call);
 
+static DEFINE_SPINLOCK(rxrpc_call_hash_lock);
+static DEFINE_HASHTABLE(rxrpc_call_hash, 10);
+
+/*
+ * Hash function for rxrpc_call_hash
+ */
+static unsigned long rxrpc_call_hashfunc(
+	u8		clientflag,
+	__be32		cid,
+	__be32		call_id,
+	__be32		epoch,
+	__be16		service_id,
+	sa_family_t	proto,
+	void		*localptr,
+	unsigned int	addr_size,
+	const u8	*peer_addr)
+{
+	const u16 *p;
+	unsigned int i;
+	unsigned long key;
+	u32 hcid = ntohl(cid);
+
+	_enter("");
+
+	key = (unsigned long)localptr;
+	/* We just want to add up the __be32 values, so forcing the
+	 * cast should be okay.
+	 */
+	key += (__force u32)epoch;
+	key += (__force u16)service_id;
+	key += (__force u32)call_id;
+	key += (hcid & RXRPC_CIDMASK) >> RXRPC_CIDSHIFT;
+	key += hcid & RXRPC_CHANNELMASK;
+	key += clientflag;
+	key += proto;
+	/* Step through the peer address in 16-bit portions for speed */
+	for (i = 0, p = (const u16 *)peer_addr; i < addr_size >> 1; i++, p++)
+		key += *p;
+	_leave(" key = 0x%lx", key);
+	return key;
+}
+
+/*
+ * Add a call to the hashtable
+ */
+static void rxrpc_call_hash_add(struct rxrpc_call *call)
+{
+	unsigned long key;
+	unsigned int addr_size = 0;
+
+	_enter("");
+	switch (call->proto) {
+	case AF_INET:
+		addr_size = sizeof(call->peer_ip.ipv4_addr);
+		break;
+	case AF_INET6:
+		addr_size = sizeof(call->peer_ip.ipv6_addr);
+		break;
+	default:
+		break;
+	}
+	key = rxrpc_call_hashfunc(call->in_clientflag, call->cid,
+				  call->call_id, call->epoch,
+				  call->service_id, call->proto,
+				  call->conn->trans->local, addr_size,
+				  call->peer_ip.ipv6_addr);
+	/* Store the full key in the call */
+	call->hash_key = key;
+	spin_lock(&rxrpc_call_hash_lock);
+	hash_add_rcu(rxrpc_call_hash, &call->hash_node, key);
+	spin_unlock(&rxrpc_call_hash_lock);
+	_leave("");
+}
+
+/*
+ * Remove a call from the hashtable
+ */
+static void rxrpc_call_hash_del(struct rxrpc_call *call)
+{
+	_enter("");
+	spin_lock(&rxrpc_call_hash_lock);
+	hash_del_rcu(&call->hash_node);
+	spin_unlock(&rxrpc_call_hash_lock);
+	_leave("");
+}
+
+/*
+ * Find a call in the hashtable and return it, or NULL if it
+ * isn't there.
+ */
+struct rxrpc_call *rxrpc_find_call_hash(
+	u8		clientflag,
+	__be32		cid,
+	__be32		call_id,
+	__be32		epoch,
+	__be16		service_id,
+	void		*localptr,
+	sa_family_t	proto,
+	const u8	*peer_addr)
+{
+	unsigned long key;
+	unsigned int addr_size = 0;
+	struct rxrpc_call *call = NULL;
+	struct rxrpc_call *ret = NULL;
+
+	_enter("");
+	switch (proto) {
+	case AF_INET:
+		addr_size = sizeof(call->peer_ip.ipv4_addr);
+		break;
+	case AF_INET6:
+		addr_size = sizeof(call->peer_ip.ipv6_addr);
+		break;
+	default:
+		break;
+	}
+
+	key = rxrpc_call_hashfunc(clientflag, cid, call_id, epoch,
+				  service_id, proto, localptr, addr_size,
+				  peer_addr);
+	hash_for_each_possible_rcu(rxrpc_call_hash, call, hash_node, key) {
+		if (call->hash_key == key &&
+		    call->call_id == call_id &&
+		    call->cid == cid &&
+		    call->in_clientflag == clientflag &&
+		    call->service_id == service_id &&
+		    call->proto == proto &&
+		    call->local == localptr &&
+		    memcmp(call->peer_ip.ipv6_addr, peer_addr,
+			      addr_size) == 0 &&
+		    call->epoch == epoch) {
+			ret = call;
+			break;
+		}
+	}
+	_leave(" = %p", ret);
+	return ret;
+}
+
 /*
  * allocate a new call
  */
@@ -136,6 +277,26 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 		return ERR_PTR(ret);
 	}
 
+	/* Record copies of information for hashtable lookup */
+	call->proto = rx->proto;
+	call->local = trans->local;
+	switch (call->proto) {
+	case AF_INET:
+		call->peer_ip.ipv4_addr =
+			trans->peer->srx.transport.sin.sin_addr.s_addr;
+		break;
+	case AF_INET6:
+		memcpy(call->peer_ip.ipv6_addr,
+		       trans->peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
+		       sizeof(call->peer_ip.ipv6_addr));
+		break;
+	}
+	call->epoch = call->conn->epoch;
+	call->service_id = call->conn->service_id;
+	call->in_clientflag = call->conn->in_clientflag;
+	/* Add the new call to the hashtable */
+	rxrpc_call_hash_add(call);
+
 	spin_lock(&call->conn->trans->peer->lock);
 	list_add(&call->error_link, &call->conn->trans->peer->error_targets);
 	spin_unlock(&call->conn->trans->peer->lock);
@@ -328,9 +489,12 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		parent = *p;
 		call = rb_entry(parent, struct rxrpc_call, conn_node);
 
-		if (call_id < call->call_id)
+		/* The tree is sorted in order of the __be32 value without
+		 * turning it into host order.
+		 */
+		if ((__force u32)call_id < (__force u32)call->call_id)
 			p = &(*p)->rb_left;
-		else if (call_id > call->call_id)
+		else if ((__force u32)call_id > (__force u32)call->call_id)
 			p = &(*p)->rb_right;
 		else
 			goto old_call;
@@ -355,6 +519,28 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	list_add_tail(&call->link, &rxrpc_calls);
 	write_unlock_bh(&rxrpc_call_lock);
 
+	/* Record copies of information for hashtable lookup */
+	call->proto = rx->proto;
+	call->local = conn->trans->local;
+	switch (call->proto) {
+	case AF_INET:
+		call->peer_ip.ipv4_addr =
+			conn->trans->peer->srx.transport.sin.sin_addr.s_addr;
+		break;
+	case AF_INET6:
+		memcpy(call->peer_ip.ipv6_addr,
+		       conn->trans->peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
+		       sizeof(call->peer_ip.ipv6_addr));
+		break;
+	default:
+		break;
+	}
+	call->epoch = conn->epoch;
+	call->service_id = conn->service_id;
+	call->in_clientflag = conn->in_clientflag;
+	/* Add the new call to the hashtable */
+	rxrpc_call_hash_add(call);
+
 	_net("CALL incoming %d on CONN %d", call->debug_id, call->conn->debug_id);
 
 	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
@@ -673,6 +859,9 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 		rxrpc_put_connection(call->conn);
 	}
 
+	/* Remove the call from the hash */
+	rxrpc_call_hash_del(call);
+
 	if (call->acks_window) {
 		_debug("kill Tx window %d",
 		       CIRC_CNT(call->acks_head, call->acks_tail,
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index e449c675c36a..73742647c135 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -523,36 +523,38 @@ protocol_error:
  * post an incoming packet to the appropriate call/socket to deal with
  * - must get rid of the sk_buff, either by freeing it or by queuing it
  */
-static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
+static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 				      struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp;
-	struct rxrpc_call *call;
-	struct rb_node *p;
-	__be32 call_id;
 
-	_enter("%p,%p", conn, skb);
-
-	read_lock_bh(&conn->lock);
+	_enter("%p,%p", call, skb);
 
 	sp = rxrpc_skb(skb);
 
-	/* look at extant calls by channel number first */
-	call = conn->channels[ntohl(sp->hdr.cid) & RXRPC_CHANNELMASK];
-	if (!call || call->call_id != sp->hdr.callNumber)
-		goto call_not_extant;
-
 	_debug("extant call [%d]", call->state);
-	ASSERTCMP(call->conn, ==, conn);
 
 	read_lock(&call->state_lock);
 	switch (call->state) {
 	case RXRPC_CALL_LOCALLY_ABORTED:
-		if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
+		if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events)) {
 			rxrpc_queue_call(call);
+			goto free_unlock;
+		}
 	case RXRPC_CALL_REMOTELY_ABORTED:
 	case RXRPC_CALL_NETWORK_ERROR:
 	case RXRPC_CALL_DEAD:
+		goto dead_call;
+	case RXRPC_CALL_COMPLETE:
+	case RXRPC_CALL_CLIENT_FINAL_ACK:
+		/* complete server call */
+		if (call->conn->in_clientflag)
+			goto dead_call;
+		/* resend last packet of a completed call */
+		_debug("final ack again");
+		rxrpc_get_call(call);
+		set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
+		rxrpc_queue_call(call);
 		goto free_unlock;
 	default:
 		break;
@@ -560,7 +562,6 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 
 	read_unlock(&call->state_lock);
 	rxrpc_get_call(call);
-	read_unlock_bh(&conn->lock);
 
 	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
 	    sp->hdr.flags & RXRPC_JUMBO_PACKET)
@@ -571,80 +572,16 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 	rxrpc_put_call(call);
 	goto done;
 
-call_not_extant:
-	/* search the completed calls in case what we're dealing with is
-	 * there */
-	_debug("call not extant");
-
-	call_id = sp->hdr.callNumber;
-	p = conn->calls.rb_node;
-	while (p) {
-		call = rb_entry(p, struct rxrpc_call, conn_node);
-
-		if (call_id < call->call_id)
-			p = p->rb_left;
-		else if (call_id > call->call_id)
-			p = p->rb_right;
-		else
-			goto found_completed_call;
-	}
-
 dead_call:
-	/* it's a either a really old call that we no longer remember or its a
-	 * new incoming call */
-	read_unlock_bh(&conn->lock);
-
-	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
-	    sp->hdr.seq == cpu_to_be32(1)) {
-		_debug("incoming call");
-		skb_queue_tail(&conn->trans->local->accept_queue, skb);
-		rxrpc_queue_work(&conn->trans->local->acceptor);
-		goto done;
-	}
-
-	_debug("dead call");
 	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
 		skb->priority = RX_CALL_DEAD;
-		rxrpc_reject_packet(conn->trans->local, skb);
-	}
-	goto done;
-
-	/* resend last packet of a completed call
-	 * - client calls may have been aborted or ACK'd
-	 * - server calls may have been aborted
-	 */
-found_completed_call:
-	_debug("completed call");
-
-	if (atomic_read(&call->usage) == 0)
-		goto dead_call;
-
-	/* synchronise any state changes */
-	read_lock(&call->state_lock);
-	ASSERTIFCMP(call->state != RXRPC_CALL_CLIENT_FINAL_ACK,
-		    call->state, >=, RXRPC_CALL_COMPLETE);
-
-	if (call->state == RXRPC_CALL_LOCALLY_ABORTED ||
-	    call->state == RXRPC_CALL_REMOTELY_ABORTED ||
-	    call->state == RXRPC_CALL_DEAD) {
-		read_unlock(&call->state_lock);
-		goto dead_call;
+		rxrpc_reject_packet(call->conn->trans->local, skb);
+		goto unlock;
 	}
-
-	if (call->conn->in_clientflag) {
-		read_unlock(&call->state_lock);
-		goto dead_call; /* complete server call */
-	}
-
-	_debug("final ack again");
-	rxrpc_get_call(call);
-	set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
-	rxrpc_queue_call(call);
-
 free_unlock:
-	read_unlock(&call->state_lock);
-	read_unlock_bh(&conn->lock);
 	rxrpc_free_skb(skb);
+unlock:
+	read_unlock(&call->state_lock);
 done:
 	_leave("");
 }
@@ -663,17 +600,42 @@ static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 	rxrpc_queue_conn(conn);
 }
 
+static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
+					       struct sk_buff *skb,
+					       struct rxrpc_skb_priv *sp)
+{
+	struct rxrpc_peer *peer;
+	struct rxrpc_transport *trans;
+	struct rxrpc_connection *conn;
+
+	peer = rxrpc_find_peer(local, ip_hdr(skb)->saddr,
+				udp_hdr(skb)->source);
+	if (IS_ERR(peer))
+		goto cant_find_conn;
+
+	trans = rxrpc_find_transport(local, peer);
+	rxrpc_put_peer(peer);
+	if (!trans)
+		goto cant_find_conn;
+
+	conn = rxrpc_find_connection(trans, &sp->hdr);
+	rxrpc_put_transport(trans);
+	if (!conn)
+		goto cant_find_conn;
+
+	return conn;
+cant_find_conn:
+	return NULL;
+}
+
 /*
  * handle data received on the local endpoint
  * - may be called in interrupt context
  */
 void rxrpc_data_ready(struct sock *sk, int count)
 {
-	struct rxrpc_connection *conn;
-	struct rxrpc_transport *trans;
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_local *local;
-	struct rxrpc_peer *peer;
 	struct sk_buff *skb;
 	int ret;
 
@@ -748,27 +710,34 @@ void rxrpc_data_ready(struct sock *sk, int count)
 	    (sp->hdr.callNumber == 0 || sp->hdr.seq == 0))
 		goto bad_message;
 
-	peer = rxrpc_find_peer(local, ip_hdr(skb)->saddr, udp_hdr(skb)->source);
-	if (IS_ERR(peer))
-		goto cant_route_call;
-
-	trans = rxrpc_find_transport(local, peer);
-	rxrpc_put_peer(peer);
-	if (!trans)
-		goto cant_route_call;
-
-	conn = rxrpc_find_connection(trans, &sp->hdr);
-	rxrpc_put_transport(trans);
-	if (!conn)
-		goto cant_route_call;
+	if (sp->hdr.callNumber == 0) {
+		/* This is a connection-level packet. These should be
+		 * fairly rare, so the extra overhead of looking them up the
+		 * old-fashioned way doesn't really hurt */
+		struct rxrpc_connection *conn;
 
-	_debug("CONN %p {%d}", conn, conn->debug_id);
+		conn = rxrpc_conn_from_local(local, skb, sp);
+		if (!conn)
+			goto cant_route_call;
 
-	if (sp->hdr.callNumber == 0)
+		_debug("CONN %p {%d}", conn, conn->debug_id);
 		rxrpc_post_packet_to_conn(conn, skb);
-	else
-		rxrpc_post_packet_to_call(conn, skb);
-	rxrpc_put_connection(conn);
+		rxrpc_put_connection(conn);
+	} else {
+		struct rxrpc_call *call;
+		u8 in_clientflag = 0;
+
+		if (sp->hdr.flags & RXRPC_CLIENT_INITIATED)
+			in_clientflag = RXRPC_CLIENT_INITIATED;
+		call = rxrpc_find_call_hash(in_clientflag, sp->hdr.cid,
+					    sp->hdr.callNumber, sp->hdr.epoch,
+					    sp->hdr.serviceId, local, AF_INET,
+					    (u8 *)&ip_hdr(skb)->saddr);
+		if (call)
+			rxrpc_post_packet_to_call(call, skb);
+		else
+			goto cant_route_call;
+	}
 	rxrpc_put_local(local);
 	return;
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 1ecd070e9149..c831d44b0841 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -396,9 +396,20 @@ struct rxrpc_call {
 #define RXRPC_ACKR_WINDOW_ASZ DIV_ROUND_UP(RXRPC_MAXACKS, BITS_PER_LONG)
 	unsigned long		ackr_window[RXRPC_ACKR_WINDOW_ASZ + 1];
 
+	struct hlist_node	hash_node;
+	unsigned long		hash_key;	/* Full hash key */
+	u8			in_clientflag;	/* Copy of conn->in_clientflag for hashing */
+	struct rxrpc_local	*local;		/* Local endpoint. Used for hashing. */
+	sa_family_t		proto;		/* Frame protocol */
 	/* the following should all be in net order */
 	__be32			cid;		/* connection ID + channel index  */
 	__be32			call_id;	/* call ID on connection  */
+	__be32			epoch;		/* epoch of this connection */
+	__be16			service_id;	/* service ID */
+	union {					/* Peer IP address for hashing */
+		__be32	ipv4_addr;
+		__u8	ipv6_addr[16];		/* Anticipates eventual IPv6 support */
+	} peer_ip;
 };
 
 /*
@@ -453,6 +464,8 @@ extern struct kmem_cache *rxrpc_call_jar;
 extern struct list_head rxrpc_calls;
 extern rwlock_t rxrpc_call_lock;
 
+struct rxrpc_call *rxrpc_find_call_hash(u8,  __be32, __be32, __be32,
+					__be16, void *, sa_family_t, const u8 *);
 struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *,
 					 struct rxrpc_transport *,
 					 struct rxrpc_conn_bundle *,
