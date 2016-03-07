From: David Howells <dhowells@redhat.com>
Subject: [PATCH 08/11] rxrpc: Implement peer endpoint cache
Date: Mon, 07 Mar 2016 14:38:55 +0000
Message-ID: <20160307143855.18567.68444.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the peer RxRPC endpoint cache.  Only the primary cache is used.
This is indexed on the following details:

  - Network transport family - currently only AF_INET.
  - Network transport type - currently only UDP.
  - Peer network transport address.

We use the RCU read lock to handle non-creating lookups so that we can do
the look up from bottom half context in the sk_error_report handler.
Creating lookups are done under spinlock rather than mutex as they might be
set up due to an external stimulus if the local endpoint is a server.

Captured network error messages (ICMP) are handled with respect to this
struct and MTU size and RTT are cached here.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile       |    3 
 net/rxrpc/af_rxrpc.c     |    6 +
 net/rxrpc/ar-accept.c    |    2 
 net/rxrpc/ar-error.c     |   57 ++++++++
 net/rxrpc/ar-input.c     |   13 +-
 net/rxrpc/ar-internal.h  |   33 ++++-
 net/rxrpc/ar-transport.c |    2 
 net/rxrpc/peer-object.c  |  330 ++++++++++++++++++++--------------------------
 net/rxrpc/utils.c        |   41 ++++++
 9 files changed, 283 insertions(+), 204 deletions(-)
 create mode 100644 net/rxrpc/utils.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 38b23f6fb9aa..33ad62ea2a34 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -20,7 +20,8 @@ af-rxrpc-y := \
 	local-event.o \
 	local-object.o \
 	objcache.o \
-	peer-object.o
+	peer-object.o \
+	utils.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
 af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 23ebb127cac1..5f0ffb5f8306 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -240,7 +240,7 @@ static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
 		return ERR_PTR(-EAFNOSUPPORT);
 
 	/* find a remote transport endpoint from the local one */
-	peer = rxrpc_get_peer(srx, gfp);
+	peer = rxrpc_lookup_peer(srx, gfp);
 	if (IS_ERR(peer))
 		return ERR_CAST(peer);
 
@@ -792,6 +792,7 @@ static int __init af_rxrpc_init(void)
 	rxrpc_epoch = get_seconds();
 
 	objcache_init(&rxrpc_local_cache);
+	objcache_init(&rxrpc_peer_cache);
 
 	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
@@ -860,6 +861,7 @@ error_proto:
 error_work_queue:
 	kmem_cache_destroy(rxrpc_call_jar);
 error_call_jar:
+	objcache_clear(&rxrpc_peer_cache);
 	objcache_clear(&rxrpc_local_cache);
 	return ret;
 }
@@ -878,7 +880,7 @@ static void __exit af_rxrpc_exit(void)
 	rxrpc_destroy_all_calls();
 	rxrpc_destroy_all_connections();
 	rxrpc_destroy_all_transports();
-	rxrpc_destroy_all_peers();
+	objcache_clear(&rxrpc_peer_cache);
 	objcache_clear(&rxrpc_local_cache);
 
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index d43799f8d3ef..fa6f34d1065a 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -93,7 +93,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 	rxrpc_new_skb(notification);
 	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
 
-	peer = rxrpc_get_peer(srx, GFP_NOIO);
+	peer = rxrpc_lookup_peer(srx, GFP_NOIO);
 	if (IS_ERR(peer)) {
 		_debug("no peer");
 		ret = -EBUSY;
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 3e82d6f0313c..05eb2366ff22 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -23,6 +23,55 @@
 #include "ar-internal.h"
 
 /*
+ * Find the peer associated with an ICMP packet.
+ */
+static struct rxrpc_peer *rxrpc_find_icmp_peer_rcu(struct rxrpc_local *local,
+						   const struct sk_buff *skb)
+{
+	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
+	struct sockaddr_rxrpc srx;
+
+	_enter("");
+
+	memset(&srx, 0, sizeof(srx));
+	srx.transport_type = local->srx.transport_type;
+	srx.transport.family = local->srx.transport.family;
+
+	/* Can we see an ICMP4 packet on an ICMP6 listening socket?  and vice
+	 * versa?
+	 */
+	switch (srx.transport.family) {
+	case AF_INET:
+		srx.transport.sin.sin_port = serr->port;
+		srx.transport_len = sizeof(struct sockaddr_in);
+		switch (serr->ee.ee_origin) {
+		case SO_EE_ORIGIN_ICMP:
+			_net("Rx ICMP");
+			memcpy(&srx.transport.sin.sin_addr,
+			       skb_network_header(skb) + serr->addr_offset,
+			       sizeof(struct in_addr));
+			break;
+		case SO_EE_ORIGIN_ICMP6:
+			_net("Rx ICMP6 on v4 sock");
+			memcpy(&srx.transport.sin.sin_addr,
+			       skb_network_header(skb) + serr->addr_offset + 12,
+			       sizeof(struct in_addr));
+			break;
+		default:
+			memcpy(&srx.transport.sin.sin_addr, &ip_hdr(skb)->saddr,
+			       sizeof(struct in_addr));
+			break;
+		}
+		break;
+
+	default:
+		BUG();
+	}
+
+	return rxrpc_lookup_peer_rcu(&srx);
+}
+
+/*
  * handle an error received on the local endpoint
  */
 void rxrpc_UDP_error_report(struct sock *sk)
@@ -57,8 +106,10 @@ void rxrpc_UDP_error_report(struct sock *sk)
 	_net("Rx UDP Error from %pI4:%hu", &addr, ntohs(port));
 	_debug("Msg l:%d d:%d", skb->len, skb->data_len);
 
-	peer = rxrpc_find_peer(local, addr, port);
+	rcu_read_lock();
+	peer = rxrpc_find_icmp_peer_rcu(local, skb);
 	if (IS_ERR(peer)) {
+		rcu_read_unlock();
 		rxrpc_free_skb(skb);
 		_leave(" [no peer]");
 		return;
@@ -66,7 +117,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 
 	trans = rxrpc_find_transport(local, peer);
 	if (!trans) {
-		rxrpc_put_peer(peer);
+		rcu_read_unlock();
 		rxrpc_free_skb(skb);
 		_leave(" [no trans]");
 		return;
@@ -110,7 +161,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 		}
 	}
 
-	rxrpc_put_peer(peer);
+	rcu_read_unlock();
 
 	/* pass the transport ref to error_handler to release */
 	skb_queue_tail(&trans->error_queue, skb);
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 514bfdaba322..76a070792718 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -639,14 +639,16 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 	struct rxrpc_peer *peer;
 	struct rxrpc_transport *trans;
 	struct rxrpc_connection *conn;
+	struct sockaddr_rxrpc srx;
 
-	peer = rxrpc_find_peer(local, ip_hdr(skb)->saddr,
-				udp_hdr(skb)->source);
+	rxrpc_get_addr_from_skb(local, skb, &srx);
+	rcu_read_lock();
+	peer = rxrpc_lookup_peer_rcu(&srx);
 	if (IS_ERR(peer))
-		goto cant_find_conn;
+		goto cant_find_peer;
 
 	trans = rxrpc_find_transport(local, peer);
-	rxrpc_put_peer(peer);
+	rcu_read_unlock();
 	if (!trans)
 		goto cant_find_conn;
 
@@ -656,6 +658,9 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 		goto cant_find_conn;
 
 	return conn;
+
+cant_find_peer:
+	rcu_read_unlock();
 cant_find_conn:
 	return NULL;
 }
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ec18b06789e6..57fce54e9180 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -196,11 +196,9 @@ struct rxrpc_local {
  * - holds the connection ID counter for connections between the two endpoints
  */
 struct rxrpc_peer {
-	struct work_struct	destroyer;	/* peer destroyer */
-	struct list_head	link;		/* link in master peer list */
+	struct obj_node		obj;
 	struct list_head	error_targets;	/* targets for net error distribution */
 	spinlock_t		lock;		/* access lock */
-	atomic_t		usage;
 	unsigned int		if_mtu;		/* interface MTU for this peer */
 	unsigned int		mtu;		/* network MTU for this peer */
 	unsigned int		maxdata;	/* data size (MTU - hdrsize) */
@@ -689,10 +687,25 @@ static inline void rxrpc_put_local(struct rxrpc_local *local)
 /*
  * peer-object.c
  */
-struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *, gfp_t);
-void rxrpc_put_peer(struct rxrpc_peer *);
-struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *, __be32, __be16);
-void __exit rxrpc_destroy_all_peers(void);
+extern struct objcache rxrpc_peer_cache;
+
+struct rxrpc_peer *rxrpc_lookup_peer_rcu(const struct sockaddr_rxrpc *);
+struct rxrpc_peer *rxrpc_lookup_peer(struct sockaddr_rxrpc *, gfp_t);
+
+static inline void rxrpc_get_peer(struct rxrpc_peer *peer)
+{
+	objcache_get(&peer->obj);
+}
+
+static inline bool rxrpc_get_peer_maybe(struct rxrpc_peer *peer)
+{
+	return objcache_get_maybe(&peer->obj);
+}
+
+static inline void rxrpc_put_peer(struct rxrpc_peer *peer)
+{
+	objcache_put(&rxrpc_peer_cache, &peer->obj);
+}
 
 /*
  * sysctl.c
@@ -706,6 +719,12 @@ static inline void rxrpc_sysctl_exit(void) {}
 #endif
 
 /*
+ * utils.c
+ */
+void rxrpc_get_addr_from_skb(struct rxrpc_local *, const struct sk_buff *,
+			     struct sockaddr_rxrpc *);
+
+/*
  * debug tracing
  */
 extern unsigned int rxrpc_debug;
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 5f9b9d462f53..e055fa30422b 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -119,7 +119,7 @@ struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *local,
 	usage = atomic_read(&trans->usage);
 
 	rxrpc_get_local(trans->local);
-	atomic_inc(&trans->peer->usage);
+	rxrpc_get_peer(trans->peer);
 	list_add_tail(&trans->link, &rxrpc_transports);
 	write_unlock_bh(&rxrpc_transport_lock);
 	new = "new";
diff --git a/net/rxrpc/peer-object.c b/net/rxrpc/peer-object.c
index dc089b1976aa..35157c659bf7 100644
--- a/net/rxrpc/peer-object.c
+++ b/net/rxrpc/peer-object.c
@@ -1,6 +1,6 @@
 /* RxRPC remote transport endpoint management
  *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2007, 2015 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -14,8 +14,6 @@
 #include <linux/skbuff.h>
 #include <linux/udp.h>
 #include <linux/in.h>
-#include <linux/in6.h>
-#include <linux/icmp.h>
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
@@ -23,11 +21,128 @@
 #include <net/route.h>
 #include "ar-internal.h"
 
-static LIST_HEAD(rxrpc_peers);
-static DEFINE_RWLOCK(rxrpc_peer_lock);
-static DECLARE_WAIT_QUEUE_HEAD(rxrpc_peer_wq);
+static unsigned long rxrpc_peer_hash_key(const void *);
+static int rxrpc_peer_cmp_key(const struct obj_node *, const void *);
+static void rxrpc_peer_gc_rcu(struct rcu_head *);
 
-static void rxrpc_destroy_peer(struct work_struct *work);
+static struct hlist_head rxrpc_peer_cache_hash[256];
+
+struct objcache rxrpc_peer_cache = {
+	.name		= "peers",
+	.gc_rcu		= rxrpc_peer_gc_rcu,
+	.hash_key	= rxrpc_peer_hash_key,
+	.cmp_key	= rxrpc_peer_cmp_key,
+	.hash_table	= rxrpc_peer_cache_hash,
+	.gc_delay	= 2,
+	.nr_buckets	= ARRAY_SIZE(rxrpc_peer_cache_hash),
+};
+
+/*
+ * Destroy a peer after the RCU grace period expires.
+ */
+static void rxrpc_peer_gc_rcu(struct rcu_head *rcu)
+{
+	struct rxrpc_peer *peer = container_of(rcu, struct rxrpc_peer, obj.rcu);
+
+	_enter("%d", peer->debug_id);
+
+	_net("DESTROY PEER %d", peer->debug_id);
+
+	ASSERT(list_empty(&peer->error_targets));
+
+	kfree(peer);
+
+	objcache_obj_rcu_done(&rxrpc_peer_cache);
+}
+
+/*
+ * Hash a peer key.
+ */
+static unsigned long rxrpc_peer_hash_key(const void *_srx)
+{
+	const struct sockaddr_rxrpc *srx = _srx;
+	const u16 *p;
+	unsigned int i, size;
+	unsigned long hash_key;
+
+	_enter("");
+
+	hash_key = srx->transport_type;
+	hash_key += srx->transport_len;
+	hash_key += srx->transport.family;
+
+	switch (srx->transport.family) {
+	case AF_INET:
+		hash_key += (u16 __force)srx->transport.sin.sin_port;
+		size = sizeof(srx->transport.sin.sin_addr);
+		p = (u16 *)&srx->transport.sin.sin_addr;
+		break;
+	}
+
+	/* Step through the peer address in 16-bit portions for speed */
+	for (i = 0; i < size; i += sizeof(*p), p++)
+		hash_key += *p;
+
+	_leave(" 0x%lx", hash_key);
+	return hash_key;
+}
+
+/*
+ * Compare a peer to a key.  Return -ve, 0 or +ve to indicate less than, same
+ * or greater than.
+ */
+static int rxrpc_peer_cmp_key(const struct obj_node *obj, const void *_srx)
+{
+	const struct rxrpc_peer *peer =
+		container_of(obj, struct rxrpc_peer, obj);
+	const struct sockaddr_rxrpc *srx = _srx;
+	int diff;
+
+	diff = ((peer->srx.transport_type - srx->transport_type) ?:
+		(peer->srx.transport_len - srx->transport_len) ?:
+		(peer->srx.transport.family - srx->transport.family));
+	if (diff != 0)
+		return diff;
+
+	switch (srx->transport.family) {
+	case AF_INET:
+		return ((u16 __force)peer->srx.transport.sin.sin_port -
+			(u16 __force)srx->transport.sin.sin_port) ?:
+			memcmp(&peer->srx.transport.sin.sin_addr,
+			       &srx->transport.sin.sin_addr,
+			       sizeof(struct in_addr));
+	default:
+		BUG();
+	}
+}
+
+/*
+ * Look up a remote transport endpoint for the specified address using RCU.
+ */
+struct rxrpc_peer *rxrpc_lookup_peer_rcu(const struct sockaddr_rxrpc *srx)
+{
+	struct rxrpc_peer *peer;
+	struct obj_node *obj;
+
+	obj = objcache_lookup_rcu(&rxrpc_peer_cache, srx);
+	if (!obj)
+		return NULL;
+
+	peer = container_of(obj, struct rxrpc_peer, obj);
+	switch (srx->transport.family) {
+	case AF_INET:
+		_net("PEER %d {%d,%u,%pI4+%hu}",
+		     peer->debug_id,
+		     peer->srx.transport_type,
+		     peer->srx.transport.family,
+		     &peer->srx.transport.sin.sin_addr,
+		     ntohs(peer->srx.transport.sin.sin_port));
+		break;
+	}
+
+	_leave(" = %p {u=%d}", peer, atomic_read(&peer->obj.usage));
+	return peer;
+}
 
 /*
  * assess the MTU size for the network interface through which this peer is
@@ -67,11 +182,8 @@ static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
 
 	peer = kzalloc(sizeof(struct rxrpc_peer), gfp);
 	if (peer) {
-		INIT_WORK(&peer->destroyer, &rxrpc_destroy_peer);
-		INIT_LIST_HEAD(&peer->link);
 		INIT_LIST_HEAD(&peer->error_targets);
 		spin_lock_init(&peer->lock);
-		atomic_set(&peer->usage, 1);
 		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
 		memcpy(&peer->srx, srx, sizeof(*srx));
 
@@ -103,10 +215,10 @@ static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
 /*
  * obtain a remote transport endpoint for the specified address
  */
-struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
+struct rxrpc_peer *rxrpc_lookup_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
 {
 	struct rxrpc_peer *peer, *candidate;
-	const char *new = "old";
+	struct obj_node *obj;
 	int usage;
 
 	_enter("{%d,%d,%pI4+%hu}",
@@ -116,188 +228,36 @@ struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
 	       ntohs(srx->transport.sin.sin_port));
 
 	/* search the peer list first */
-	read_lock_bh(&rxrpc_peer_lock);
-	list_for_each_entry(peer, &rxrpc_peers, link) {
-		_debug("check PEER %d { u=%d t=%d l=%d }",
-		       peer->debug_id,
-		       atomic_read(&peer->usage),
-		       peer->srx.transport_type,
-		       peer->srx.transport_len);
-
-		if (atomic_read(&peer->usage) > 0 &&
-		    peer->srx.transport_type == srx->transport_type &&
-		    peer->srx.transport_len == srx->transport_len &&
-		    memcmp(&peer->srx.transport,
-			   &srx->transport,
-			   srx->transport_len) == 0)
-			goto found_extant_peer;
-	}
-	read_unlock_bh(&rxrpc_peer_lock);
-
-	/* not yet present - create a candidate for a new record and then
-	 * redo the search */
-	candidate = rxrpc_alloc_peer(srx, gfp);
-	if (!candidate) {
-		_leave(" = -ENOMEM");
-		return ERR_PTR(-ENOMEM);
-	}
+	rcu_read_lock();
+	peer = rxrpc_lookup_peer_rcu(srx);
+	if (peer && !rxrpc_get_peer_maybe(peer))
+		peer = NULL;
+	rcu_read_unlock();
+
+	if (!peer) {
+		/* The peer is not yet present in cache - create a candidate
+		 * for a new record and then redo the search.
+		 */
+		candidate = rxrpc_alloc_peer(srx, gfp);
+		if (!candidate) {
+			_leave(" = NULL [nomem]");
+			return NULL;
+		}
 
-	write_lock_bh(&rxrpc_peer_lock);
+		obj = objcache_try_add(&rxrpc_peer_cache, &candidate->obj,
+				       &candidate->srx);
+		peer = container_of(obj, struct rxrpc_peer, obj);
 
-	list_for_each_entry(peer, &rxrpc_peers, link) {
-		if (atomic_read(&peer->usage) > 0 &&
-		    peer->srx.transport_type == srx->transport_type &&
-		    peer->srx.transport_len == srx->transport_len &&
-		    memcmp(&peer->srx.transport,
-			   &srx->transport,
-			   srx->transport_len) == 0)
-			goto found_extant_second;
+		if (peer != candidate)
+			kfree(candidate);
 	}
 
-	/* we can now add the new candidate to the list */
-	peer = candidate;
-	candidate = NULL;
-	usage = atomic_read(&peer->usage);
-
-	list_add_tail(&peer->link, &rxrpc_peers);
-	write_unlock_bh(&rxrpc_peer_lock);
-	new = "new";
-
-success:
-	_net("PEER %s %d {%d,%u,%pI4+%hu}",
-	     new,
+	_net("PEER %d {%d,%pI4+%hu}",
 	     peer->debug_id,
 	     peer->srx.transport_type,
-	     peer->srx.transport.family,
 	     &peer->srx.transport.sin.sin_addr,
 	     ntohs(peer->srx.transport.sin.sin_port));
 
 	_leave(" = %p {u=%d}", peer, usage);
 	return peer;
-
-	/* we found the peer in the list immediately */
-found_extant_peer:
-	usage = atomic_inc_return(&peer->usage);
-	read_unlock_bh(&rxrpc_peer_lock);
-	goto success;
-
-	/* we found the peer on the second time through the list */
-found_extant_second:
-	usage = atomic_inc_return(&peer->usage);
-	write_unlock_bh(&rxrpc_peer_lock);
-	kfree(candidate);
-	goto success;
-}
-
-/*
- * find the peer associated with a packet
- */
-struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *local,
-				   __be32 addr, __be16 port)
-{
-	struct rxrpc_peer *peer;
-
-	_enter("");
-
-	/* search the peer list */
-	read_lock_bh(&rxrpc_peer_lock);
-
-	if (local->srx.transport.family == AF_INET &&
-	    local->srx.transport_type == SOCK_DGRAM
-	    ) {
-		list_for_each_entry(peer, &rxrpc_peers, link) {
-			if (atomic_read(&peer->usage) > 0 &&
-			    peer->srx.transport_type == SOCK_DGRAM &&
-			    peer->srx.transport.family == AF_INET &&
-			    peer->srx.transport.sin.sin_port == port &&
-			    peer->srx.transport.sin.sin_addr.s_addr == addr)
-				goto found_UDP_peer;
-		}
-
-		goto new_UDP_peer;
-	}
-
-	read_unlock_bh(&rxrpc_peer_lock);
-	_leave(" = -EAFNOSUPPORT");
-	return ERR_PTR(-EAFNOSUPPORT);
-
-found_UDP_peer:
-	_net("Rx UDP DGRAM from peer %d", peer->debug_id);
-	atomic_inc(&peer->usage);
-	read_unlock_bh(&rxrpc_peer_lock);
-	_leave(" = %p", peer);
-	return peer;
-
-new_UDP_peer:
-	_net("Rx UDP DGRAM from NEW peer");
-	read_unlock_bh(&rxrpc_peer_lock);
-	_leave(" = -EBUSY [new]");
-	return ERR_PTR(-EBUSY);
-}
-
-/*
- * release a remote transport endpoint
- */
-void rxrpc_put_peer(struct rxrpc_peer *peer)
-{
-	_enter("%p{u=%d}", peer, atomic_read(&peer->usage));
-
-	ASSERTCMP(atomic_read(&peer->usage), >, 0);
-
-	if (likely(!atomic_dec_and_test(&peer->usage))) {
-		_leave(" [in use]");
-		return;
-	}
-
-	rxrpc_queue_work(&peer->destroyer);
-	_leave("");
-}
-
-/*
- * destroy a remote transport endpoint
- */
-static void rxrpc_destroy_peer(struct work_struct *work)
-{
-	struct rxrpc_peer *peer =
-		container_of(work, struct rxrpc_peer, destroyer);
-
-	_enter("%p{%d}", peer, atomic_read(&peer->usage));
-
-	write_lock_bh(&rxrpc_peer_lock);
-	list_del(&peer->link);
-	write_unlock_bh(&rxrpc_peer_lock);
-
-	_net("DESTROY PEER %d", peer->debug_id);
-	kfree(peer);
-
-	if (list_empty(&rxrpc_peers))
-		wake_up_all(&rxrpc_peer_wq);
-	_leave("");
-}
-
-/*
- * preemptively destroy all the peer records from a transport endpoint rather
- * than waiting for them to time out
- */
-void __exit rxrpc_destroy_all_peers(void)
-{
-	DECLARE_WAITQUEUE(myself,current);
-
-	_enter("");
-
-	/* we simply have to wait for them to go away */
-	if (!list_empty(&rxrpc_peers)) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		add_wait_queue(&rxrpc_peer_wq, &myself);
-
-		while (!list_empty(&rxrpc_peers)) {
-			schedule();
-			set_current_state(TASK_UNINTERRUPTIBLE);
-		}
-
-		remove_wait_queue(&rxrpc_peer_wq, &myself);
-		set_current_state(TASK_RUNNING);
-	}
-
-	_leave("");
 }
diff --git a/net/rxrpc/utils.c b/net/rxrpc/utils.c
new file mode 100644
index 000000000000..f28122a15a24
--- /dev/null
+++ b/net/rxrpc/utils.c
@@ -0,0 +1,41 @@
+/* Utility routines
+ *
+ * Copyright (C) 2015 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include "ar-internal.h"
+
+/*
+ * Set up an RxRPC address from a socket buffer.
+ */
+void rxrpc_get_addr_from_skb(struct rxrpc_local *local,
+			     const struct sk_buff *skb,
+			     struct sockaddr_rxrpc *srx)
+{
+	memset(srx, 0, sizeof(*srx));
+	srx->transport_type = local->srx.transport_type;
+	srx->transport.family = local->srx.transport.family;
+
+	/* Can we see an ipv4 UDP packet on an ipv6 UDP socket?  and vice
+	 * versa?
+	 */
+	switch (srx->transport.family) {
+	case AF_INET:
+		srx->transport.sin.sin_port = udp_hdr(skb)->source;
+		srx->transport_len = sizeof(struct sockaddr_in);
+		memcpy(&srx->transport.sin.sin_addr, &ip_hdr(skb)->saddr,
+		       sizeof(struct in_addr));
+		break;
+
+	default:
+		BUG();
+	}
+}
