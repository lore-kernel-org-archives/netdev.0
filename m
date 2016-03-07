From: David Howells <dhowells@redhat.com>
Subject: [PATCH 07/11] rxrpc: Rename ar-peer.c to peer-object.c
Date: Mon, 07 Mar 2016 14:38:48 +0000
Message-ID: <20160307143848.18567.57975.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932076AbcCGOiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 09:38:50 -0500
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename ar-peer.c to peer-object.c for consistency (to be) with the other
new object cache management files.  It will be modified in a later commit.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile      |    4 -
 net/rxrpc/ar-internal.h |   16 +-
 net/rxrpc/ar-peer.c     |  303 -----------------------------------------------
 net/rxrpc/peer-object.c |  303 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 313 insertions(+), 313 deletions(-)
 delete mode 100644 net/rxrpc/ar-peer.c
 create mode 100644 net/rxrpc/peer-object.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 7f41d272bf3d..38b23f6fb9aa 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -13,14 +13,14 @@ af-rxrpc-y := \
 	ar-input.o \
 	ar-key.o \
 	ar-output.o \
-	ar-peer.o \
 	ar-recvmsg.o \
 	ar-security.o \
 	ar-skbuff.o \
 	ar-transport.o \
 	local-event.o \
 	local-object.o \
-	objcache.o
+	objcache.o \
+	peer-object.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
 af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 79c965789c2c..ec18b06789e6 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -617,14 +617,6 @@ int rxrpc_client_sendmsg(struct rxrpc_sock *, struct rxrpc_transport *,
 int rxrpc_server_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
 
 /*
- * ar-peer.c
- */
-struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *, gfp_t);
-void rxrpc_put_peer(struct rxrpc_peer *);
-struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *, __be32, __be16);
-void __exit rxrpc_destroy_all_peers(void);
-
-/*
  * ar-proc.c
  */
 extern const char *const rxrpc_call_states[];
@@ -695,6 +687,14 @@ static inline void rxrpc_put_local(struct rxrpc_local *local)
 }
 
 /*
+ * peer-object.c
+ */
+struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *, gfp_t);
+void rxrpc_put_peer(struct rxrpc_peer *);
+struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *, __be32, __be16);
+void __exit rxrpc_destroy_all_peers(void);
+
+/*
  * sysctl.c
  */
 #ifdef CONFIG_SYSCTL
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
deleted file mode 100644
index dc089b1976aa..000000000000
--- a/net/rxrpc/ar-peer.c
+++ /dev/null
@@ -1,303 +0,0 @@
-/* RxRPC remote transport endpoint management
- *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <linux/net.h>
-#include <linux/skbuff.h>
-#include <linux/udp.h>
-#include <linux/in.h>
-#include <linux/in6.h>
-#include <linux/icmp.h>
-#include <linux/slab.h>
-#include <net/sock.h>
-#include <net/af_rxrpc.h>
-#include <net/ip.h>
-#include <net/route.h>
-#include "ar-internal.h"
-
-static LIST_HEAD(rxrpc_peers);
-static DEFINE_RWLOCK(rxrpc_peer_lock);
-static DECLARE_WAIT_QUEUE_HEAD(rxrpc_peer_wq);
-
-static void rxrpc_destroy_peer(struct work_struct *work);
-
-/*
- * assess the MTU size for the network interface through which this peer is
- * reached
- */
-static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
-{
-	struct rtable *rt;
-	struct flowi4 fl4;
-
-	peer->if_mtu = 1500;
-
-	rt = ip_route_output_ports(&init_net, &fl4, NULL,
-				   peer->srx.transport.sin.sin_addr.s_addr, 0,
-				   htons(7000), htons(7001),
-				   IPPROTO_UDP, 0, 0);
-	if (IS_ERR(rt)) {
-		_leave(" [route err %ld]", PTR_ERR(rt));
-		return;
-	}
-
-	peer->if_mtu = dst_mtu(&rt->dst);
-	dst_release(&rt->dst);
-
-	_leave(" [if_mtu %u]", peer->if_mtu);
-}
-
-/*
- * allocate a new peer
- */
-static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
-					   gfp_t gfp)
-{
-	struct rxrpc_peer *peer;
-
-	_enter("");
-
-	peer = kzalloc(sizeof(struct rxrpc_peer), gfp);
-	if (peer) {
-		INIT_WORK(&peer->destroyer, &rxrpc_destroy_peer);
-		INIT_LIST_HEAD(&peer->link);
-		INIT_LIST_HEAD(&peer->error_targets);
-		spin_lock_init(&peer->lock);
-		atomic_set(&peer->usage, 1);
-		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
-		memcpy(&peer->srx, srx, sizeof(*srx));
-
-		rxrpc_assess_MTU_size(peer);
-		peer->mtu = peer->if_mtu;
-
-		if (srx->transport.family == AF_INET) {
-			peer->hdrsize = sizeof(struct iphdr);
-			switch (srx->transport_type) {
-			case SOCK_DGRAM:
-				peer->hdrsize += sizeof(struct udphdr);
-				break;
-			default:
-				BUG();
-				break;
-			}
-		} else {
-			BUG();
-		}
-
-		peer->hdrsize += sizeof(struct rxrpc_wire_header);
-		peer->maxdata = peer->mtu - peer->hdrsize;
-	}
-
-	_leave(" = %p", peer);
-	return peer;
-}
-
-/*
- * obtain a remote transport endpoint for the specified address
- */
-struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
-{
-	struct rxrpc_peer *peer, *candidate;
-	const char *new = "old";
-	int usage;
-
-	_enter("{%d,%d,%pI4+%hu}",
-	       srx->transport_type,
-	       srx->transport_len,
-	       &srx->transport.sin.sin_addr,
-	       ntohs(srx->transport.sin.sin_port));
-
-	/* search the peer list first */
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
-
-	write_lock_bh(&rxrpc_peer_lock);
-
-	list_for_each_entry(peer, &rxrpc_peers, link) {
-		if (atomic_read(&peer->usage) > 0 &&
-		    peer->srx.transport_type == srx->transport_type &&
-		    peer->srx.transport_len == srx->transport_len &&
-		    memcmp(&peer->srx.transport,
-			   &srx->transport,
-			   srx->transport_len) == 0)
-			goto found_extant_second;
-	}
-
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
-	     peer->debug_id,
-	     peer->srx.transport_type,
-	     peer->srx.transport.family,
-	     &peer->srx.transport.sin.sin_addr,
-	     ntohs(peer->srx.transport.sin.sin_port));
-
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
-}
diff --git a/net/rxrpc/peer-object.c b/net/rxrpc/peer-object.c
new file mode 100644
index 000000000000..dc089b1976aa
--- /dev/null
+++ b/net/rxrpc/peer-object.c
@@ -0,0 +1,303 @@
+/* RxRPC remote transport endpoint management
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/udp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/icmp.h>
+#include <linux/slab.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <net/ip.h>
+#include <net/route.h>
+#include "ar-internal.h"
+
+static LIST_HEAD(rxrpc_peers);
+static DEFINE_RWLOCK(rxrpc_peer_lock);
+static DECLARE_WAIT_QUEUE_HEAD(rxrpc_peer_wq);
+
+static void rxrpc_destroy_peer(struct work_struct *work);
+
+/*
+ * assess the MTU size for the network interface through which this peer is
+ * reached
+ */
+static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
+{
+	struct rtable *rt;
+	struct flowi4 fl4;
+
+	peer->if_mtu = 1500;
+
+	rt = ip_route_output_ports(&init_net, &fl4, NULL,
+				   peer->srx.transport.sin.sin_addr.s_addr, 0,
+				   htons(7000), htons(7001),
+				   IPPROTO_UDP, 0, 0);
+	if (IS_ERR(rt)) {
+		_leave(" [route err %ld]", PTR_ERR(rt));
+		return;
+	}
+
+	peer->if_mtu = dst_mtu(&rt->dst);
+	dst_release(&rt->dst);
+
+	_leave(" [if_mtu %u]", peer->if_mtu);
+}
+
+/*
+ * allocate a new peer
+ */
+static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
+					   gfp_t gfp)
+{
+	struct rxrpc_peer *peer;
+
+	_enter("");
+
+	peer = kzalloc(sizeof(struct rxrpc_peer), gfp);
+	if (peer) {
+		INIT_WORK(&peer->destroyer, &rxrpc_destroy_peer);
+		INIT_LIST_HEAD(&peer->link);
+		INIT_LIST_HEAD(&peer->error_targets);
+		spin_lock_init(&peer->lock);
+		atomic_set(&peer->usage, 1);
+		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
+		memcpy(&peer->srx, srx, sizeof(*srx));
+
+		rxrpc_assess_MTU_size(peer);
+		peer->mtu = peer->if_mtu;
+
+		if (srx->transport.family == AF_INET) {
+			peer->hdrsize = sizeof(struct iphdr);
+			switch (srx->transport_type) {
+			case SOCK_DGRAM:
+				peer->hdrsize += sizeof(struct udphdr);
+				break;
+			default:
+				BUG();
+				break;
+			}
+		} else {
+			BUG();
+		}
+
+		peer->hdrsize += sizeof(struct rxrpc_wire_header);
+		peer->maxdata = peer->mtu - peer->hdrsize;
+	}
+
+	_leave(" = %p", peer);
+	return peer;
+}
+
+/*
+ * obtain a remote transport endpoint for the specified address
+ */
+struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
+{
+	struct rxrpc_peer *peer, *candidate;
+	const char *new = "old";
+	int usage;
+
+	_enter("{%d,%d,%pI4+%hu}",
+	       srx->transport_type,
+	       srx->transport_len,
+	       &srx->transport.sin.sin_addr,
+	       ntohs(srx->transport.sin.sin_port));
+
+	/* search the peer list first */
+	read_lock_bh(&rxrpc_peer_lock);
+	list_for_each_entry(peer, &rxrpc_peers, link) {
+		_debug("check PEER %d { u=%d t=%d l=%d }",
+		       peer->debug_id,
+		       atomic_read(&peer->usage),
+		       peer->srx.transport_type,
+		       peer->srx.transport_len);
+
+		if (atomic_read(&peer->usage) > 0 &&
+		    peer->srx.transport_type == srx->transport_type &&
+		    peer->srx.transport_len == srx->transport_len &&
+		    memcmp(&peer->srx.transport,
+			   &srx->transport,
+			   srx->transport_len) == 0)
+			goto found_extant_peer;
+	}
+	read_unlock_bh(&rxrpc_peer_lock);
+
+	/* not yet present - create a candidate for a new record and then
+	 * redo the search */
+	candidate = rxrpc_alloc_peer(srx, gfp);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	write_lock_bh(&rxrpc_peer_lock);
+
+	list_for_each_entry(peer, &rxrpc_peers, link) {
+		if (atomic_read(&peer->usage) > 0 &&
+		    peer->srx.transport_type == srx->transport_type &&
+		    peer->srx.transport_len == srx->transport_len &&
+		    memcmp(&peer->srx.transport,
+			   &srx->transport,
+			   srx->transport_len) == 0)
+			goto found_extant_second;
+	}
+
+	/* we can now add the new candidate to the list */
+	peer = candidate;
+	candidate = NULL;
+	usage = atomic_read(&peer->usage);
+
+	list_add_tail(&peer->link, &rxrpc_peers);
+	write_unlock_bh(&rxrpc_peer_lock);
+	new = "new";
+
+success:
+	_net("PEER %s %d {%d,%u,%pI4+%hu}",
+	     new,
+	     peer->debug_id,
+	     peer->srx.transport_type,
+	     peer->srx.transport.family,
+	     &peer->srx.transport.sin.sin_addr,
+	     ntohs(peer->srx.transport.sin.sin_port));
+
+	_leave(" = %p {u=%d}", peer, usage);
+	return peer;
+
+	/* we found the peer in the list immediately */
+found_extant_peer:
+	usage = atomic_inc_return(&peer->usage);
+	read_unlock_bh(&rxrpc_peer_lock);
+	goto success;
+
+	/* we found the peer on the second time through the list */
+found_extant_second:
+	usage = atomic_inc_return(&peer->usage);
+	write_unlock_bh(&rxrpc_peer_lock);
+	kfree(candidate);
+	goto success;
+}
+
+/*
+ * find the peer associated with a packet
+ */
+struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *local,
+				   __be32 addr, __be16 port)
+{
+	struct rxrpc_peer *peer;
+
+	_enter("");
+
+	/* search the peer list */
+	read_lock_bh(&rxrpc_peer_lock);
+
+	if (local->srx.transport.family == AF_INET &&
+	    local->srx.transport_type == SOCK_DGRAM
+	    ) {
+		list_for_each_entry(peer, &rxrpc_peers, link) {
+			if (atomic_read(&peer->usage) > 0 &&
+			    peer->srx.transport_type == SOCK_DGRAM &&
+			    peer->srx.transport.family == AF_INET &&
+			    peer->srx.transport.sin.sin_port == port &&
+			    peer->srx.transport.sin.sin_addr.s_addr == addr)
+				goto found_UDP_peer;
+		}
+
+		goto new_UDP_peer;
+	}
+
+	read_unlock_bh(&rxrpc_peer_lock);
+	_leave(" = -EAFNOSUPPORT");
+	return ERR_PTR(-EAFNOSUPPORT);
+
+found_UDP_peer:
+	_net("Rx UDP DGRAM from peer %d", peer->debug_id);
+	atomic_inc(&peer->usage);
+	read_unlock_bh(&rxrpc_peer_lock);
+	_leave(" = %p", peer);
+	return peer;
+
+new_UDP_peer:
+	_net("Rx UDP DGRAM from NEW peer");
+	read_unlock_bh(&rxrpc_peer_lock);
+	_leave(" = -EBUSY [new]");
+	return ERR_PTR(-EBUSY);
+}
+
+/*
+ * release a remote transport endpoint
+ */
+void rxrpc_put_peer(struct rxrpc_peer *peer)
+{
+	_enter("%p{u=%d}", peer, atomic_read(&peer->usage));
+
+	ASSERTCMP(atomic_read(&peer->usage), >, 0);
+
+	if (likely(!atomic_dec_and_test(&peer->usage))) {
+		_leave(" [in use]");
+		return;
+	}
+
+	rxrpc_queue_work(&peer->destroyer);
+	_leave("");
+}
+
+/*
+ * destroy a remote transport endpoint
+ */
+static void rxrpc_destroy_peer(struct work_struct *work)
+{
+	struct rxrpc_peer *peer =
+		container_of(work, struct rxrpc_peer, destroyer);
+
+	_enter("%p{%d}", peer, atomic_read(&peer->usage));
+
+	write_lock_bh(&rxrpc_peer_lock);
+	list_del(&peer->link);
+	write_unlock_bh(&rxrpc_peer_lock);
+
+	_net("DESTROY PEER %d", peer->debug_id);
+	kfree(peer);
+
+	if (list_empty(&rxrpc_peers))
+		wake_up_all(&rxrpc_peer_wq);
+	_leave("");
+}
+
+/*
+ * preemptively destroy all the peer records from a transport endpoint rather
+ * than waiting for them to time out
+ */
+void __exit rxrpc_destroy_all_peers(void)
+{
+	DECLARE_WAITQUEUE(myself,current);
+
+	_enter("");
+
+	/* we simply have to wait for them to go away */
+	if (!list_empty(&rxrpc_peers)) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&rxrpc_peer_wq, &myself);
+
+		while (!list_empty(&rxrpc_peers)) {
+			schedule();
+			set_current_state(TASK_UNINTERRUPTIBLE);
+		}
+
+		remove_wait_queue(&rxrpc_peer_wq, &myself);
+		set_current_state(TASK_RUNNING);
+	}
+
+	_leave("");
+}
