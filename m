From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 24/24] rxrpc: Kill off the call hash table
Date: Tue, 05 Jul 2016 14:15:03 +0100
Message-ID: <146772450380.21657.3650740406235253291.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754852AbcGENPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 09:15:06 -0400
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call hash table is now no longer used as calls are looked up directly
by channel slot on the connection, so kill it off.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   13 +---
 net/rxrpc/call_object.c |  173 -----------------------------------------------
 2 files changed, 2 insertions(+), 184 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 02945cc77399..e07f6d051c86 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -462,19 +462,12 @@ struct rxrpc_call {
 #define RXRPC_ACKR_WINDOW_ASZ DIV_ROUND_UP(RXRPC_MAXACKS, BITS_PER_LONG)
 	unsigned long		ackr_window[RXRPC_ACKR_WINDOW_ASZ + 1];
 
-	struct hlist_node	hash_node;
-	unsigned long		hash_key;	/* Full hash key */
-	u8			in_clientflag;	/* Copy of conn->in_clientflag for hashing */
-	struct rxrpc_local	*local;		/* Local endpoint. Used for hashing. */
-	sa_family_t		family;		/* Frame protocol */
+	u8			in_clientflag;	/* Copy of conn->in_clientflag */
+	struct rxrpc_local	*local;		/* Local endpoint. */
 	u32			call_id;	/* call ID on connection  */
 	u32			cid;		/* connection ID plus channel index */
 	u32			epoch;		/* epoch of this connection */
 	u16			service_id;	/* service ID */
-	union {					/* Peer IP address for hashing */
-		__be32	ipv4_addr;
-		__u8	ipv6_addr[16];		/* Anticipates eventual IPv6 support */
-	} peer_ip;
 };
 
 /*
@@ -522,8 +515,6 @@ extern struct kmem_cache *rxrpc_call_jar;
 extern struct list_head rxrpc_calls;
 extern rwlock_t rxrpc_call_lock;
 
-struct rxrpc_call *rxrpc_find_call_hash(struct rxrpc_host_header *,
-					void *, sa_family_t, const void *);
 struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *, unsigned long);
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_conn_parameters *,
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index ebbd7dd5292f..91287c9d01bb 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -14,7 +14,6 @@
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/circ_buf.h>
-#include <linux/hashtable.h>
 #include <linux/spinlock_types.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
@@ -61,142 +60,6 @@ static void rxrpc_dead_call_expired(unsigned long _call);
 static void rxrpc_ack_time_expired(unsigned long _call);
 static void rxrpc_resend_time_expired(unsigned long _call);
 
-static DEFINE_SPINLOCK(rxrpc_call_hash_lock);
-static DEFINE_HASHTABLE(rxrpc_call_hash, 10);
-
-/*
- * Hash function for rxrpc_call_hash
- */
-static unsigned long rxrpc_call_hashfunc(
-	u8		in_clientflag,
-	u32		cid,
-	u32		call_id,
-	u32		epoch,
-	u16		service_id,
-	sa_family_t	family,
-	void		*localptr,
-	unsigned int	addr_size,
-	const u8	*peer_addr)
-{
-	const u16 *p;
-	unsigned int i;
-	unsigned long key;
-
-	_enter("");
-
-	key = (unsigned long)localptr;
-	/* We just want to add up the __be32 values, so forcing the
-	 * cast should be okay.
-	 */
-	key += epoch;
-	key += service_id;
-	key += call_id;
-	key += (cid & RXRPC_CIDMASK) >> RXRPC_CIDSHIFT;
-	key += cid & RXRPC_CHANNELMASK;
-	key += in_clientflag;
-	key += family;
-	/* Step through the peer address in 16-bit portions for speed */
-	for (i = 0, p = (const u16 *)peer_addr; i < addr_size >> 1; i++, p++)
-		key += *p;
-	_leave(" key = 0x%lx", key);
-	return key;
-}
-
-/*
- * Add a call to the hashtable
- */
-static void rxrpc_call_hash_add(struct rxrpc_call *call)
-{
-	unsigned long key;
-	unsigned int addr_size = 0;
-
-	_enter("");
-	switch (call->family) {
-	case AF_INET:
-		addr_size = sizeof(call->peer_ip.ipv4_addr);
-		break;
-	case AF_INET6:
-		addr_size = sizeof(call->peer_ip.ipv6_addr);
-		break;
-	default:
-		break;
-	}
-	key = rxrpc_call_hashfunc(call->in_clientflag, call->cid,
-				  call->call_id, call->epoch,
-				  call->service_id, call->family,
-				  call->conn->params.local, addr_size,
-				  call->peer_ip.ipv6_addr);
-	/* Store the full key in the call */
-	call->hash_key = key;
-	spin_lock(&rxrpc_call_hash_lock);
-	hash_add_rcu(rxrpc_call_hash, &call->hash_node, key);
-	spin_unlock(&rxrpc_call_hash_lock);
-	_leave("");
-}
-
-/*
- * Remove a call from the hashtable
- */
-static void rxrpc_call_hash_del(struct rxrpc_call *call)
-{
-	_enter("");
-	spin_lock(&rxrpc_call_hash_lock);
-	hash_del_rcu(&call->hash_node);
-	spin_unlock(&rxrpc_call_hash_lock);
-	_leave("");
-}
-
-/*
- * Find a call in the hashtable and return it, or NULL if it
- * isn't there.
- */
-struct rxrpc_call *rxrpc_find_call_hash(
-	struct rxrpc_host_header *hdr,
-	void		*localptr,
-	sa_family_t	family,
-	const void	*peer_addr)
-{
-	unsigned long key;
-	unsigned int addr_size = 0;
-	struct rxrpc_call *call = NULL;
-	struct rxrpc_call *ret = NULL;
-	u8 in_clientflag = hdr->flags & RXRPC_CLIENT_INITIATED;
-
-	_enter("");
-	switch (family) {
-	case AF_INET:
-		addr_size = sizeof(call->peer_ip.ipv4_addr);
-		break;
-	case AF_INET6:
-		addr_size = sizeof(call->peer_ip.ipv6_addr);
-		break;
-	default:
-		break;
-	}
-
-	key = rxrpc_call_hashfunc(in_clientflag, hdr->cid, hdr->callNumber,
-				  hdr->epoch, hdr->serviceId,
-				  family, localptr, addr_size,
-				  peer_addr);
-	hash_for_each_possible_rcu(rxrpc_call_hash, call, hash_node, key) {
-		if (call->hash_key == key &&
-		    call->call_id == hdr->callNumber &&
-		    call->cid == hdr->cid &&
-		    call->in_clientflag == in_clientflag &&
-		    call->service_id == hdr->serviceId &&
-		    call->family == family &&
-		    call->local == localptr &&
-		    memcmp(call->peer_ip.ipv6_addr, peer_addr,
-			   addr_size) == 0 &&
-		    call->epoch == hdr->epoch) {
-			ret = call;
-			break;
-		}
-	}
-	_leave(" = %p", ret);
-	return ret;
-}
-
 /*
  * find an extant server call
  * - called in process context with IRQs enabled
@@ -305,20 +168,7 @@ static struct rxrpc_call *rxrpc_alloc_client_call(struct rxrpc_sock *rx,
 	call->socket = rx;
 	call->rx_data_post = 1;
 
-	/* Record copies of information for hashtable lookup */
-	call->family = rx->family;
 	call->local = rx->local;
-	switch (call->family) {
-	case AF_INET:
-		call->peer_ip.ipv4_addr = srx->transport.sin.sin_addr.s_addr;
-		break;
-	case AF_INET6:
-		memcpy(call->peer_ip.ipv6_addr,
-		       srx->transport.sin6.sin6_addr.in6_u.u6_addr8,
-		       sizeof(call->peer_ip.ipv6_addr));
-		break;
-	}
-
 	call->service_id = srx->srx_service;
 	call->in_clientflag = 0;
 
@@ -345,9 +195,6 @@ static int rxrpc_begin_client_call(struct rxrpc_call *call,
 
 	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
 
-	/* Add the new call to the hashtable */
-	rxrpc_call_hash_add(call);
-
 	spin_lock(&call->conn->params.peer->lock);
 	hlist_add_head(&call->error_link, &call->conn->params.peer->error_targets);
 	spin_unlock(&call->conn->params.peer->lock);
@@ -548,27 +395,10 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	list_add_tail(&call->link, &rxrpc_calls);
 	write_unlock_bh(&rxrpc_call_lock);
 
-	/* Record copies of information for hashtable lookup */
-	call->family = rx->family;
 	call->local = conn->params.local;
-	switch (call->family) {
-	case AF_INET:
-		call->peer_ip.ipv4_addr =
-			conn->params.peer->srx.transport.sin.sin_addr.s_addr;
-		break;
-	case AF_INET6:
-		memcpy(call->peer_ip.ipv6_addr,
-		       conn->params.peer->srx.transport.sin6.sin6_addr.in6_u.u6_addr8,
-		       sizeof(call->peer_ip.ipv6_addr));
-		break;
-	default:
-		break;
-	}
 	call->epoch = conn->proto.epoch;
 	call->service_id = conn->params.service_id;
 	call->in_clientflag = RXRPC_CLIENT_INITIATED;
-	/* Add the new call to the hashtable */
-	rxrpc_call_hash_add(call);
 
 	_net("CALL incoming %d on CONN %d", call->debug_id, call->conn->debug_id);
 
@@ -818,9 +648,6 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 
 	ASSERTCMP(call->conn, ==, NULL);
 
-	/* Remove the call from the hash */
-	rxrpc_call_hash_del(call);
-
 	if (call->acks_window) {
 		_debug("kill Tx window %d",
 		       CIRC_CNT(call->acks_head, call->acks_tail,
