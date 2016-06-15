From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/8] rxrpc: Rework peer object handling to use hash
 table and RCU
Date: Wed, 15 Jun 2016 17:41:45 +0100
Message-ID: <146600890561.18270.2591012055193115542.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35355 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932627AbcFOQls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 12:41:48 -0400
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework peer object handling to use a hash table instead of a flat list and
to use RCU.  Peer objects are no longer destroyed by passing them to a
workqueue to process, but rather are just passed to the RCU garbage
collector as kfree'able objects.

The hash function uses the local endpoint plus all the components of the
remote address, except for the RxRPC service ID.  Peers thus represent a
UDP port on the remote machine as contacted by a UDP port on this machine.

The RCU read lock is used to handle non-creating lookups so that they can
be called from bottom half context in the sk_error_report handler without
having to lock the hash table against modification.
rxrpc_lookup_peer_rcu() *does* take a reference on the peer object as in
the future, this will be passed to a work item for error distribution in
the error_report path and this function will cease being used in the
data_ready path.

Creating lookups are done under spinlock rather than mutex as they might be
set up due to an external stimulus if the local endpoint is a server.

Captured network error messages (ICMP) are handled with respect to this
struct and MTU size and RTT are cached here.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile      |    3 
 net/rxrpc/af_rxrpc.c    |    3 
 net/rxrpc/ar-internal.h |   46 +++++-
 net/rxrpc/call_accept.c |    2 
 net/rxrpc/input.c       |   13 +-
 net/rxrpc/peer_event.c  |   59 +++++++-
 net/rxrpc/peer_object.c |  369 ++++++++++++++++++++++++-----------------------
 net/rxrpc/transport.c   |    2 
 net/rxrpc/utils.c       |   41 +++++
 9 files changed, 335 insertions(+), 203 deletions(-)
 create mode 100644 net/rxrpc/utils.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 7e1006a3bfa5..a6f6f21d8a59 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -20,7 +20,8 @@ af-rxrpc-y := \
 	recvmsg.o \
 	security.o \
 	skbuff.o \
-	transport.o
+	transport.o \
+	utils.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += proc.o
 af-rxrpc-$(CONFIG_RXKAD) += rxkad.o
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index a1bcb0e17250..ba373caddbeb 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -244,7 +244,7 @@ struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *rx,
 		return ERR_PTR(-EAFNOSUPPORT);
 
 	/* find a remote transport endpoint from the local one */
-	peer = rxrpc_get_peer(srx, gfp);
+	peer = rxrpc_lookup_peer(rx->local, srx, gfp);
 	if (IS_ERR(peer))
 		return ERR_CAST(peer);
 
@@ -835,7 +835,6 @@ static void __exit af_rxrpc_exit(void)
 	rxrpc_destroy_all_calls();
 	rxrpc_destroy_all_connections();
 	rxrpc_destroy_all_transports();
-	rxrpc_destroy_all_peers();
 	rxrpc_destroy_all_locals();
 
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 03919b9a8a31..7dba6677b9d5 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -9,7 +9,9 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <linux/atomic.h>
 #include <net/sock.h>
+#include <net/af_rxrpc.h>
 #include <rxrpc/packet.h>
 
 #if 0
@@ -193,15 +195,16 @@ struct rxrpc_local {
 
 /*
  * RxRPC remote transport endpoint definition
- * - matched by remote port, address and protocol type
- * - holds the connection ID counter for connections between the two endpoints
+ * - matched by local endpoint, remote port, address and protocol type
  */
 struct rxrpc_peer {
-	struct work_struct	destroyer;	/* peer destroyer */
-	struct list_head	link;		/* link in master peer list */
+	struct rcu_head		rcu;		/* This must be first */
+	atomic_t		usage;
+	unsigned long		hash_key;
+	struct hlist_node	hash_link;
+	struct rxrpc_local	*local;
 	struct list_head	error_targets;	/* targets for net error distribution */
 	spinlock_t		lock;		/* access lock */
-	atomic_t		usage;
 	unsigned int		if_mtu;		/* interface MTU for this peer */
 	unsigned int		mtu;		/* network MTU for this peer */
 	unsigned int		maxdata;	/* data size (MTU - hdrsize) */
@@ -611,10 +614,29 @@ void rxrpc_UDP_error_handler(struct work_struct *);
 /*
  * peer_object.c
  */
-struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *, gfp_t);
-void rxrpc_put_peer(struct rxrpc_peer *);
-struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *, __be32, __be16);
-void __exit rxrpc_destroy_all_peers(void);
+struct rxrpc_peer *rxrpc_lookup_peer_rcu(struct rxrpc_local *,
+					 const struct sockaddr_rxrpc *);
+struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *,
+				     struct sockaddr_rxrpc *, gfp_t);
+struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *, gfp_t);
+
+static inline void rxrpc_get_peer(struct rxrpc_peer *peer)
+{
+	atomic_inc(&peer->usage);
+}
+
+static inline
+struct rxrpc_peer *rxrpc_get_peer_maybe(struct rxrpc_peer *peer)
+{
+	return atomic_inc_not_zero(&peer->usage) ? peer : NULL;
+}
+
+extern void __rxrpc_put_peer(struct rxrpc_peer *peer);
+static inline void rxrpc_put_peer(struct rxrpc_peer *peer)
+{
+	if (atomic_dec_and_test(&peer->usage))
+		__rxrpc_put_peer(peer);
+}
 
 /*
  * proc.c
@@ -673,6 +695,12 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 					     struct rxrpc_peer *);
 
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
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index eea5f4a5d8b1..e5723f4dce89 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -95,7 +95,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 	rxrpc_new_skb(notification);
 	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
 
-	peer = rxrpc_get_peer(srx, GFP_NOIO);
+	peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
 	if (IS_ERR(peer)) {
 		_debug("no peer");
 		ret = -EBUSY;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index e0815a033999..3b405dbf3a05 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -635,14 +635,16 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 	struct rxrpc_peer *peer;
 	struct rxrpc_transport *trans;
 	struct rxrpc_connection *conn;
+	struct sockaddr_rxrpc srx;
 
-	peer = rxrpc_find_peer(local, ip_hdr(skb)->saddr,
-				udp_hdr(skb)->source);
+	rxrpc_get_addr_from_skb(local, skb, &srx);
+	rcu_read_lock();
+	peer = rxrpc_lookup_peer_rcu(local, &srx);
 	if (IS_ERR(peer))
-		goto cant_find_conn;
+		goto cant_find_peer;
 
 	trans = rxrpc_find_transport(local, peer);
-	rxrpc_put_peer(peer);
+	rcu_read_unlock();
 	if (!trans)
 		goto cant_find_conn;
 
@@ -652,6 +654,9 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 		goto cant_find_conn;
 
 	return conn;
+
+cant_find_peer:
+	rcu_read_unlock();
 cant_find_conn:
 	return NULL;
 }
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 3e82d6f0313c..24f5ec0fcd20 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -23,6 +23,55 @@
 #include "ar-internal.h"
 
 /*
+ * Find the peer associated with an ICMP packet.
+ */
+static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
+						     const struct sk_buff *skb)
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
+	return rxrpc_lookup_peer_rcu(local, &srx);
+}
+
+/*
  * handle an error received on the local endpoint
  */
 void rxrpc_UDP_error_report(struct sock *sk)
@@ -57,8 +106,12 @@ void rxrpc_UDP_error_report(struct sock *sk)
 	_net("Rx UDP Error from %pI4:%hu", &addr, ntohs(port));
 	_debug("Msg l:%d d:%d", skb->len, skb->data_len);
 
-	peer = rxrpc_find_peer(local, addr, port);
-	if (IS_ERR(peer)) {
+	rcu_read_lock();
+	peer = rxrpc_lookup_peer_icmp_rcu(local, skb);
+	if (peer && !rxrpc_get_peer_maybe(peer))
+		peer = NULL;
+	if (!peer) {
+		rcu_read_unlock();
 		rxrpc_free_skb(skb);
 		_leave(" [no peer]");
 		return;
@@ -66,6 +119,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 
 	trans = rxrpc_find_transport(local, peer);
 	if (!trans) {
+		rcu_read_unlock();
 		rxrpc_put_peer(peer);
 		rxrpc_free_skb(skb);
 		_leave(" [no trans]");
@@ -110,6 +164,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 		}
 	}
 
+	rcu_read_unlock();
 	rxrpc_put_peer(peer);
 
 	/* pass the transport ref to error_handler to release */
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 0b54cda3d8e5..7fc50dc7d333 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -1,6 +1,6 @@
-/* RxRPC remote transport endpoint management
+/* RxRPC remote transport endpoint record management
  *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2007, 2016 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -16,20 +16,132 @@
 #include <linux/skbuff.h>
 #include <linux/udp.h>
 #include <linux/in.h>
-#include <linux/in6.h>
-#include <linux/icmp.h>
 #include <linux/slab.h>
+#include <linux/hashtable.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <net/ip.h>
 #include <net/route.h>
 #include "ar-internal.h"
 
-static LIST_HEAD(rxrpc_peers);
-static DEFINE_RWLOCK(rxrpc_peer_lock);
-static DECLARE_WAIT_QUEUE_HEAD(rxrpc_peer_wq);
+static DEFINE_HASHTABLE(rxrpc_peer_hash, 10);
+static DEFINE_SPINLOCK(rxrpc_peer_hash_lock);
 
-static void rxrpc_destroy_peer(struct work_struct *work);
+/*
+ * Hash a peer key.
+ */
+static unsigned long rxrpc_peer_hash_key(struct rxrpc_local *local,
+					 const struct sockaddr_rxrpc *srx)
+{
+	const u16 *p;
+	unsigned int i, size;
+	unsigned long hash_key;
+
+	_enter("");
+
+	hash_key = (unsigned long)local / __alignof__(*local);
+	hash_key += srx->transport_type;
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
+ *
+ * Unfortunately, the primitives in linux/hashtable.h don't allow for sorted
+ * buckets and mid-bucket insertion, so we don't make full use of this
+ * information at this point.
+ */
+static long rxrpc_peer_cmp_key(const struct rxrpc_peer *peer,
+			       struct rxrpc_local *local,
+			       const struct sockaddr_rxrpc *srx,
+			       unsigned long hash_key)
+{
+	long diff;
+
+	diff = ((peer->hash_key - hash_key) ?:
+		((unsigned long)peer->local - (unsigned long)local) ?:
+		(peer->srx.transport_type - srx->transport_type) ?:
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
+static struct rxrpc_peer *__rxrpc_lookup_peer_rcu(
+	struct rxrpc_local *local,
+	const struct sockaddr_rxrpc *srx,
+	unsigned long hash_key)
+{
+	struct rxrpc_peer *peer;
+
+	hash_for_each_possible_rcu(rxrpc_peer_hash, peer, hash_link, hash_key) {
+		if (rxrpc_peer_cmp_key(peer, local, srx, hash_key) == 0) {
+			if (atomic_read(&peer->usage) == 0)
+				return NULL;
+			return peer;
+		}
+	}
+
+	return NULL;
+}
+
+/*
+ * Look up a remote transport endpoint for the specified address using RCU.
+ */
+struct rxrpc_peer *rxrpc_lookup_peer_rcu(struct rxrpc_local *local,
+					 const struct sockaddr_rxrpc *srx)
+{
+	struct rxrpc_peer *peer;
+	unsigned long hash_key = rxrpc_peer_hash_key(local, srx);
+
+	peer = __rxrpc_lookup_peer_rcu(local, srx, hash_key);
+	if (peer) {
+		switch (srx->transport.family) {
+		case AF_INET:
+			_net("PEER %d {%d,%u,%pI4+%hu}",
+			     peer->debug_id,
+			     peer->srx.transport_type,
+			     peer->srx.transport.family,
+			     &peer->srx.transport.sin.sin_addr,
+			     ntohs(peer->srx.transport.sin.sin_port));
+			break;
+		}
+
+		_leave(" = %p {u=%d}", peer, atomic_read(&peer->usage));
+	}
+	return peer;
+}
 
 /*
  * assess the MTU size for the network interface through which this peer is
@@ -58,10 +170,9 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 }
 
 /*
- * allocate a new peer
+ * Allocate a peer.
  */
-static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
-					   gfp_t gfp)
+struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *local, gfp_t gfp)
 {
 	struct rxrpc_peer *peer;
 
@@ -69,12 +180,32 @@ static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
 
 	peer = kzalloc(sizeof(struct rxrpc_peer), gfp);
 	if (peer) {
-		INIT_WORK(&peer->destroyer, &rxrpc_destroy_peer);
-		INIT_LIST_HEAD(&peer->link);
+		atomic_set(&peer->usage, 1);
+		peer->local = local;
 		INIT_LIST_HEAD(&peer->error_targets);
 		spin_lock_init(&peer->lock);
-		atomic_set(&peer->usage, 1);
 		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
+	}
+
+	_leave(" = %p", peer);
+	return peer;
+}
+
+/*
+ * Set up a new peer.
+ */
+static struct rxrpc_peer *rxrpc_create_peer(struct rxrpc_local *local,
+					    struct sockaddr_rxrpc *srx,
+					    unsigned long hash_key,
+					    gfp_t gfp)
+{
+	struct rxrpc_peer *peer;
+
+	_enter("");
+
+	peer = rxrpc_alloc_peer(local, gfp);
+	if (peer) {
+		peer->hash_key = hash_key;
 		memcpy(&peer->srx, srx, sizeof(*srx));
 
 		rxrpc_assess_MTU_size(peer);
@@ -105,11 +236,11 @@ static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
 /*
  * obtain a remote transport endpoint for the specified address
  */
-struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
+struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
+				     struct sockaddr_rxrpc *srx, gfp_t gfp)
 {
 	struct rxrpc_peer *peer, *candidate;
-	const char *new = "old";
-	int usage;
+	unsigned long hash_key = rxrpc_peer_hash_key(local, srx);
 
 	_enter("{%d,%d,%pI4+%hu}",
 	       srx->transport_type,
@@ -118,188 +249,60 @@ struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
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
+	peer = __rxrpc_lookup_peer_rcu(local, srx, hash_key);
+	if (peer && !rxrpc_get_peer_maybe(peer))
+		peer = NULL;
+	rcu_read_unlock();
+
+	if (!peer) {
+		/* The peer is not yet present in hash - create a candidate
+		 * for a new record and then redo the search.
+		 */
+		candidate = rxrpc_create_peer(local, srx, hash_key, gfp);
+		if (!candidate) {
+			_leave(" = NULL [nomem]");
+			return NULL;
+		}
 
-	write_lock_bh(&rxrpc_peer_lock);
+		spin_lock(&rxrpc_peer_hash_lock);
 
-	list_for_each_entry(peer, &rxrpc_peers, link) {
-		if (atomic_read(&peer->usage) > 0 &&
-		    peer->srx.transport_type == srx->transport_type &&
-		    peer->srx.transport_len == srx->transport_len &&
-		    memcmp(&peer->srx.transport,
-			   &srx->transport,
-			   srx->transport_len) == 0)
-			goto found_extant_second;
-	}
+		/* Need to check that we aren't racing with someone else */
+		peer = __rxrpc_lookup_peer_rcu(local, srx, hash_key);
+		if (peer && !rxrpc_get_peer_maybe(peer))
+			peer = NULL;
+		if (!peer)
+			hash_add_rcu(rxrpc_peer_hash,
+				     &candidate->hash_link, hash_key);
 
-	/* we can now add the new candidate to the list */
-	peer = candidate;
-	candidate = NULL;
-	usage = atomic_read(&peer->usage);
+		spin_unlock(&rxrpc_peer_hash_lock);
 
-	list_add_tail(&peer->link, &rxrpc_peers);
-	write_unlock_bh(&rxrpc_peer_lock);
-	new = "new";
+		if (peer)
+			kfree(candidate);
+		else
+			peer = candidate;
+	}
 
-success:
-	_net("PEER %s %d {%d,%u,%pI4+%hu}",
-	     new,
+	_net("PEER %d {%d,%pI4+%hu}",
 	     peer->debug_id,
 	     peer->srx.transport_type,
-	     peer->srx.transport.family,
 	     &peer->srx.transport.sin.sin_addr,
 	     ntohs(peer->srx.transport.sin.sin_port));
 
-	_leave(" = %p {u=%d}", peer, usage);
-	return peer;
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
+	_leave(" = %p {u=%d}", peer, atomic_read(&peer->usage));
 	return peer;
-
-new_UDP_peer:
-	_net("Rx UDP DGRAM from NEW peer");
-	read_unlock_bh(&rxrpc_peer_lock);
-	_leave(" = -EBUSY [new]");
-	return ERR_PTR(-EBUSY);
 }
 
 /*
- * release a remote transport endpoint
+ * Discard a ref on a remote peer record.
  */
-void rxrpc_put_peer(struct rxrpc_peer *peer)
+void __rxrpc_put_peer(struct rxrpc_peer *peer)
 {
-	_enter("%p{u=%d}", peer, atomic_read(&peer->usage));
+	ASSERT(list_empty(&peer->error_targets));
 
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
+	spin_lock(&rxrpc_peer_hash_lock);
+	hash_del_rcu(&peer->hash_link);
+	spin_unlock(&rxrpc_peer_hash_lock);
 
-	_leave("");
+	kfree_rcu(peer, rcu);
 }
diff --git a/net/rxrpc/transport.c b/net/rxrpc/transport.c
index a1b65183b07d..d33387dec0ce 100644
--- a/net/rxrpc/transport.c
+++ b/net/rxrpc/transport.c
@@ -121,7 +121,7 @@ struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *local,
 	usage = atomic_read(&trans->usage);
 
 	rxrpc_get_local(trans->local);
-	atomic_inc(&trans->peer->usage);
+	rxrpc_get_peer(trans->peer);
 	list_add_tail(&trans->link, &rxrpc_transports);
 	write_unlock_bh(&rxrpc_transport_lock);
 	new = "new";
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
