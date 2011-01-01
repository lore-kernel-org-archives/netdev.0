From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/20] tipc: Remove prototype code for supporting inter-cluster routing
Date: Fri, 31 Dec 2010 23:59:18 -0500
Message-ID: <1293857975-30267-4-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53113 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586Ab1AAFAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:00 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates routines and data structures that were intended to allow
TIPC to route messages to other clusters. Currently, TIPC supports only
networks consisting of a single cluster within a single zone, so this
code is unnecessary.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    5 -
 net/tipc/addr.h             |   15 ---
 net/tipc/cluster.c          |  279 +------------------------------------------
 net/tipc/cluster.h          |    8 --
 net/tipc/link.c             |   13 +-
 net/tipc/msg.h              |    7 +-
 net/tipc/net.c              |   45 -------
 net/tipc/net.h              |    4 -
 net/tipc/node.c             |  166 +------------------------
 net/tipc/node.h             |   21 ----
 10 files changed, 15 insertions(+), 548 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index dcc2b87..1f38df1 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -254,11 +254,6 @@ struct tipc_link_create {
 	struct tipc_media_addr peer_addr;
 	char bearer_name[TIPC_MAX_BEARER_NAME];
 };
-
-struct tipc_route_info {
-	__u32 dest;
-	__u32 router;
-};
 #endif
 
 /*
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index a16c6c8..2490fad 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -37,21 +37,6 @@
 #ifndef _TIPC_ADDR_H
 #define _TIPC_ADDR_H
 
-static inline u32 own_node(void)
-{
-	return tipc_node(tipc_own_addr);
-}
-
-static inline u32 own_cluster(void)
-{
-	return tipc_cluster(tipc_own_addr);
-}
-
-static inline u32 own_zone(void)
-{
-	return tipc_zone(tipc_own_addr);
-}
-
 static inline int in_own_cluster(u32 addr)
 {
 	return !((addr ^ tipc_own_addr) >> 12);
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 6bc9f07..ba6f5bf 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -38,9 +38,6 @@
 #include "cluster.h"
 #include "link.h"
 
-static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
-				u32 lower, u32 upper);
-
 struct tipc_node **tipc_local_nodes = NULL;
 struct tipc_node_map tipc_cltr_bcast_nodes = {0,{0,}};
 
@@ -65,8 +62,7 @@ struct cluster *tipc_cltr_create(u32 addr)
 		return NULL;
 	}
 
-	if (in_own_cluster(addr))
-		tipc_local_nodes = c_ptr->nodes;
+	tipc_local_nodes = c_ptr->nodes;
 	c_ptr->highest_node = 0;
 
 	tipc_net.clusters[1] = c_ptr;
@@ -101,278 +97,6 @@ void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr)
 }
 
 /**
- * tipc_cltr_select_router - select router to a cluster
- *
- * Uses deterministic and fair algorithm.
- */
-
-u32 tipc_cltr_select_router(struct cluster *c_ptr, u32 ref)
-{
-	u32 n_num;
-	u32 ulim = c_ptr->highest_node;
-	u32 mask;
-	u32 tstart;
-
-	assert(!in_own_cluster(c_ptr->addr));
-	if (!ulim)
-		return 0;
-
-	/* Start entry must be random */
-	mask = tipc_max_nodes;
-	while (mask > ulim)
-		mask >>= 1;
-	tstart = ref & mask;
-	n_num = tstart;
-
-	/* Lookup upwards with wrap-around */
-	do {
-		if (tipc_node_is_up(c_ptr->nodes[n_num]))
-			break;
-	} while (++n_num <= ulim);
-	if (n_num > ulim) {
-		n_num = 1;
-		do {
-			if (tipc_node_is_up(c_ptr->nodes[n_num]))
-				break;
-		} while (++n_num < tstart);
-		if (n_num == tstart)
-			return 0;
-	}
-	assert(n_num <= ulim);
-	return tipc_node_select_router(c_ptr->nodes[n_num], ref);
-}
-
-/**
- * tipc_cltr_select_node - select destination node within a remote cluster
- *
- * Uses deterministic and fair algorithm.
- */
-
-struct tipc_node *tipc_cltr_select_node(struct cluster *c_ptr, u32 selector)
-{
-	u32 n_num;
-	u32 mask = tipc_max_nodes;
-	u32 start_entry;
-
-	assert(!in_own_cluster(c_ptr->addr));
-	if (!c_ptr->highest_node)
-		return NULL;
-
-	/* Start entry must be random */
-	while (mask > c_ptr->highest_node) {
-		mask >>= 1;
-	}
-	start_entry = (selector & mask) ? selector & mask : 1u;
-	assert(start_entry <= c_ptr->highest_node);
-
-	/* Lookup upwards with wrap-around */
-	for (n_num = start_entry; n_num <= c_ptr->highest_node; n_num++) {
-		if (tipc_node_has_active_links(c_ptr->nodes[n_num]))
-			return c_ptr->nodes[n_num];
-	}
-	for (n_num = 1; n_num < start_entry; n_num++) {
-		if (tipc_node_has_active_links(c_ptr->nodes[n_num]))
-			return c_ptr->nodes[n_num];
-	}
-	return NULL;
-}
-
-/*
- *    Routing table management: See description in node.c
- */
-
-static struct sk_buff *tipc_cltr_prepare_routing_msg(u32 data_size, u32 dest)
-{
-	u32 size = INT_H_SIZE + data_size;
-	struct sk_buff *buf = tipc_buf_acquire(size);
-	struct tipc_msg *msg;
-
-	if (buf) {
-		msg = buf_msg(buf);
-		memset((char *)msg, 0, size);
-		tipc_msg_init(msg, ROUTE_DISTRIBUTOR, 0, INT_H_SIZE, dest);
-	}
-	return buf;
-}
-
-void tipc_cltr_bcast_new_route(struct cluster *c_ptr, u32 dest,
-			     u32 lower, u32 upper)
-{
-	struct sk_buff *buf = tipc_cltr_prepare_routing_msg(0, c_ptr->addr);
-	struct tipc_msg *msg;
-
-	if (buf) {
-		msg = buf_msg(buf);
-		msg_set_remote_node(msg, dest);
-		msg_set_type(msg, ROUTE_ADDITION);
-		tipc_cltr_multicast(c_ptr, buf, lower, upper);
-	} else {
-		warn("Memory squeeze: broadcast of new route failed\n");
-	}
-}
-
-void tipc_cltr_bcast_lost_route(struct cluster *c_ptr, u32 dest,
-				u32 lower, u32 upper)
-{
-	struct sk_buff *buf = tipc_cltr_prepare_routing_msg(0, c_ptr->addr);
-	struct tipc_msg *msg;
-
-	if (buf) {
-		msg = buf_msg(buf);
-		msg_set_remote_node(msg, dest);
-		msg_set_type(msg, ROUTE_REMOVAL);
-		tipc_cltr_multicast(c_ptr, buf, lower, upper);
-	} else {
-		warn("Memory squeeze: broadcast of lost route failed\n");
-	}
-}
-
-void tipc_cltr_send_ext_routes(struct cluster *c_ptr, u32 dest)
-{
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-	u32 highest = c_ptr->highest_node;
-	u32 n_num;
-	int send = 0;
-
-	if (in_own_cluster(c_ptr->addr))
-		return;
-	assert(in_own_cluster(dest));
-	highest = c_ptr->highest_node;
-	buf = tipc_cltr_prepare_routing_msg(highest + 1, c_ptr->addr);
-	if (buf) {
-		msg = buf_msg(buf);
-		msg_set_remote_node(msg, c_ptr->addr);
-		msg_set_type(msg, EXT_ROUTING_TABLE);
-		for (n_num = 1; n_num <= highest; n_num++) {
-			if (c_ptr->nodes[n_num] &&
-			    tipc_node_has_active_links(c_ptr->nodes[n_num])) {
-				send = 1;
-				msg_set_dataoctet(msg, n_num);
-			}
-		}
-		if (send)
-			tipc_link_send(buf, dest, dest);
-		else
-			buf_discard(buf);
-	} else {
-		warn("Memory squeeze: broadcast of external route failed\n");
-	}
-}
-
-void tipc_cltr_recv_routing_table(struct sk_buff *buf)
-{
-	struct tipc_msg *msg = buf_msg(buf);
-	struct cluster *c_ptr;
-	struct tipc_node *n_ptr;
-	unchar *node_table;
-	u32 table_size;
-	u32 router;
-	u32 rem_node = msg_remote_node(msg);
-	u32 z_num;
-	u32 c_num;
-	u32 n_num;
-
-	c_ptr = tipc_cltr_find(rem_node);
-	if (!c_ptr) {
-		c_ptr = tipc_cltr_create(rem_node);
-		if (!c_ptr) {
-			buf_discard(buf);
-			return;
-		}
-	}
-
-	node_table = buf->data + msg_hdr_sz(msg);
-	table_size = msg_size(msg) - msg_hdr_sz(msg);
-	router = msg_prevnode(msg);
-	z_num = tipc_zone(rem_node);
-	c_num = tipc_cluster(rem_node);
-
-	switch (msg_type(msg)) {
-	case EXT_ROUTING_TABLE:
-		for (n_num = 1; n_num < table_size; n_num++) {
-			if (node_table[n_num]) {
-				u32 addr = tipc_addr(z_num, c_num, n_num);
-				n_ptr = c_ptr->nodes[n_num];
-				if (!n_ptr) {
-					n_ptr = tipc_node_create(addr);
-				}
-				if (n_ptr)
-					tipc_node_add_router(n_ptr, router);
-			}
-		}
-		break;
-	case SLAVE_ROUTING_TABLE:
-		assert(in_own_cluster(c_ptr->addr));
-		break;
-	case ROUTE_ADDITION:
-		assert(!in_own_cluster(c_ptr->addr));
-		n_ptr = c_ptr->nodes[tipc_node(rem_node)];
-		if (!n_ptr)
-			n_ptr = tipc_node_create(rem_node);
-		if (n_ptr)
-			tipc_node_add_router(n_ptr, router);
-		break;
-	case ROUTE_REMOVAL:
-		assert(!in_own_cluster(c_ptr->addr));
-		n_ptr = c_ptr->nodes[tipc_node(rem_node)];
-		if (n_ptr)
-			tipc_node_remove_router(n_ptr, router);
-		break;
-	default:
-		assert(!"Illegal routing manager message received\n");
-	}
-	buf_discard(buf);
-}
-
-void tipc_cltr_remove_as_router(struct cluster *c_ptr, u32 router)
-{
-	u32 n_num;
-
-	if (in_own_cluster(c_ptr->addr))
-		return;
-
-	for (n_num = 1; n_num <= c_ptr->highest_node; n_num++) {
-		if (c_ptr->nodes[n_num]) {
-			tipc_node_remove_router(c_ptr->nodes[n_num], router);
-		}
-	}
-}
-
-/**
- * tipc_cltr_multicast - multicast message to local nodes
- */
-
-static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
-			 u32 lower, u32 upper)
-{
-	struct sk_buff *buf_copy;
-	struct tipc_node *n_ptr;
-	u32 n_num;
-	u32 tstop;
-
-	assert(lower <= upper);
-	assert((lower >= 1) && (lower <= tipc_max_nodes));
-	assert((upper >= 1) && (upper <= tipc_max_nodes));
-	assert(in_own_cluster(c_ptr->addr));
-
-	tstop = c_ptr->highest_node;
-	if (tstop > upper)
-		tstop = upper;
-	for (n_num = lower; n_num <= tstop; n_num++) {
-		n_ptr = c_ptr->nodes[n_num];
-		if (n_ptr && tipc_node_has_active_links(n_ptr)) {
-			buf_copy = skb_copy(buf, GFP_ATOMIC);
-			if (buf_copy == NULL)
-				break;
-			msg_set_destnode(buf_msg(buf_copy), n_ptr->addr);
-			tipc_link_send(buf_copy, n_ptr->addr, n_ptr->addr);
-		}
-	}
-	buf_discard(buf);
-}
-
-/**
  * tipc_cltr_broadcast - broadcast message to all nodes within cluster
  */
 
@@ -385,7 +109,6 @@ void tipc_cltr_broadcast(struct sk_buff *buf)
 
 	if (tipc_mode == TIPC_NET_MODE) {
 		c_ptr = tipc_cltr_find(tipc_own_addr);
-		assert(in_own_cluster(c_ptr->addr));	/* For now */
 
 		/* Send to nodes */
 		for (n_num = 1; n_num <= c_ptr->highest_node; n_num++) {
diff --git a/net/tipc/cluster.h b/net/tipc/cluster.h
index aa1fd6a..e4b6e4e 100644
--- a/net/tipc/cluster.h
+++ b/net/tipc/cluster.h
@@ -57,20 +57,12 @@ struct cluster {
 extern struct tipc_node **tipc_local_nodes;
 extern struct tipc_node_map tipc_cltr_bcast_nodes;
 
-void tipc_cltr_remove_as_router(struct cluster *c_ptr, u32 router);
-void tipc_cltr_send_ext_routes(struct cluster *c_ptr, u32 dest);
-struct tipc_node *tipc_cltr_select_node(struct cluster *c_ptr, u32 selector);
-u32 tipc_cltr_select_router(struct cluster *c_ptr, u32 ref);
-void tipc_cltr_recv_routing_table(struct sk_buff *buf);
 struct cluster *tipc_cltr_create(u32 addr);
 void tipc_cltr_delete(struct cluster *c_ptr);
 void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr);
 void tipc_cltr_broadcast(struct sk_buff *buf);
 int tipc_cltr_init(void);
 
-void tipc_cltr_bcast_new_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
-void tipc_cltr_bcast_lost_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
-
 static inline struct cluster *tipc_cltr_find(u32 addr)
 {
 	if (!in_own_cluster(addr))
diff --git a/net/tipc/link.c b/net/tipc/link.c
index cf414cf..671ffd3 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1061,7 +1061,7 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 	int res = -ELINKCONG;
 
 	read_lock_bh(&tipc_net_lock);
-	n_ptr = tipc_node_select(dest, selector);
+	n_ptr = tipc_node_find(dest);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[selector & 1];
@@ -1137,7 +1137,7 @@ int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
 		return tipc_port_recv_msg(buf);
 
 	read_lock_bh(&tipc_net_lock);
-	n_ptr = tipc_node_select(destnode, selector);
+	n_ptr = tipc_node_find(destnode);
 	if (likely(n_ptr)) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[selector];
@@ -1186,7 +1186,7 @@ again:
 			!sender->user_port, &buf);
 
 	read_lock_bh(&tipc_net_lock);
-	node = tipc_node_select(destaddr, selector);
+	node = tipc_node_find(destaddr);
 	if (likely(node)) {
 		tipc_node_lock(node);
 		l_ptr = node->active_links[selector];
@@ -1376,7 +1376,7 @@ error:
 	 * Now we have a buffer chain. Select a link and check
 	 * that packet size is still OK
 	 */
-	node = tipc_node_select(destaddr, sender->publ.ref & 1);
+	node = tipc_node_find(destaddr);
 	if (likely(node)) {
 		tipc_node_lock(node);
 		l_ptr = node->active_links[sender->publ.ref & 1];
@@ -1893,7 +1893,7 @@ deliver:
 						continue;
 					case ROUTE_DISTRIBUTOR:
 						tipc_node_unlock(n_ptr);
-						tipc_cltr_recv_routing_table(buf);
+						buf_discard(buf);
 						continue;
 					case NAME_DISTRIBUTOR:
 						tipc_node_unlock(n_ptr);
@@ -2852,7 +2852,6 @@ void tipc_link_set_queue_limits(struct link *l_ptr, u32 window)
 	l_ptr->queue_limit[TIPC_HIGH_IMPORTANCE + 4] = 900;
 	l_ptr->queue_limit[TIPC_CRITICAL_IMPORTANCE + 4] = 1200;
 	l_ptr->queue_limit[CONN_MANAGER] = 1200;
-	l_ptr->queue_limit[ROUTE_DISTRIBUTOR] = 1200;
 	l_ptr->queue_limit[CHANGEOVER_PROTOCOL] = 2500;
 	l_ptr->queue_limit[NAME_DISTRIBUTOR] = 3000;
 	/* FRAGMENT and LAST_FRAGMENT packets */
@@ -3154,7 +3153,7 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 		return MAX_MSG_SIZE;
 
 	read_lock_bh(&tipc_net_lock);
-	n_ptr = tipc_node_select(dest, selector);
+	n_ptr = tipc_node_find(dest);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[selector & 1];
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index c1b6217..68b65ef 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -540,7 +540,7 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define  MSG_BUNDLER          6
 #define  LINK_PROTOCOL        7
 #define  CONN_MANAGER         8
-#define  ROUTE_DISTRIBUTOR    9
+#define  ROUTE_DISTRIBUTOR    9		/* obsoleted */
 #define  CHANGEOVER_PROTOCOL  10
 #define  NAME_DISTRIBUTOR     11
 #define  MSG_FRAGMENTER       12
@@ -819,11 +819,6 @@ static inline void msg_set_remote_node(struct tipc_msg *m, u32 a)
 	msg_set_word(m, msg_hdr_sz(m)/4, a);
 }
 
-static inline void msg_set_dataoctet(struct tipc_msg *m, u32 pos)
-{
-	msg_data(m)[pos + 4] = 1;
-}
-
 /*
  * Segmentation message types
  */
diff --git a/net/tipc/net.c b/net/tipc/net.c
index a25f8bb..3967f1f 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -112,48 +112,6 @@
 DEFINE_RWLOCK(tipc_net_lock);
 struct network tipc_net;
 
-struct tipc_node *tipc_net_select_remote_node(u32 addr, u32 ref)
-{
-	struct cluster *c_ptr;
-
-	c_ptr = tipc_net.clusters[1];
-	if (!c_ptr)
-		return NULL;
-	return tipc_cltr_select_node(c_ptr, ref);
-}
-
-u32 tipc_net_select_router(u32 addr, u32 ref)
-{
-	struct cluster *c_ptr;
-
-	c_ptr = tipc_net.clusters[1];
-	if (!c_ptr)
-		return 0;
-	return tipc_cltr_select_router(c_ptr, ref);
-}
-
-void tipc_net_remove_as_router(u32 router)
-{
-	u32 c_num;
-
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
-		if (!tipc_net.clusters[c_num])
-			continue;
-		tipc_cltr_remove_as_router(tipc_net.clusters[c_num], router);
-	}
-}
-
-void tipc_net_send_external_routes(u32 dest)
-{
-	u32 c_num;
-
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
-		if (tipc_net.clusters[c_num])
-			tipc_cltr_send_ext_routes(tipc_net.clusters[c_num],
-						  dest);
-	}
-}
-
 static void net_stop(void)
 {
 	u32 c_num;
@@ -225,9 +183,6 @@ void tipc_net_route_msg(struct sk_buff *buf)
 			return;
 		}
 		switch (msg_user(msg)) {
-		case ROUTE_DISTRIBUTOR:
-			tipc_cltr_recv_routing_table(buf);
-			break;
 		case NAME_DISTRIBUTOR:
 			tipc_named_recv(buf);
 			break;
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 786c940..6e402d9 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -54,11 +54,7 @@ struct network {
 extern struct network tipc_net;
 extern rwlock_t tipc_net_lock;
 
-void tipc_net_remove_as_router(u32 router);
-void tipc_net_send_external_routes(u32 dest);
 void tipc_net_route_msg(struct sk_buff *buf);
-struct tipc_node *tipc_net_select_remote_node(u32 addr, u32 ref);
-u32 tipc_net_select_router(u32 addr, u32 ref);
 
 int tipc_net_start(u32 addr);
 void tipc_net_stop(void);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 8ffbdb3..c47cc69 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -95,11 +95,10 @@ struct tipc_node *tipc_node_create(u32 addr)
 	}
 
 	n_ptr->addr = addr;
-		spin_lock_init(&n_ptr->lock);
+	spin_lock_init(&n_ptr->lock);
 	INIT_LIST_HEAD(&n_ptr->nsub);
 	n_ptr->owner = c_ptr;
 	tipc_cltr_attach_node(c_ptr, n_ptr);
-	n_ptr->last_router = -1;
 
 	/* Insert node into ordered list */
 	for (curr_node = &tipc_nodes; *curr_node;
@@ -229,14 +228,9 @@ int tipc_node_has_redundant_links(struct tipc_node *n_ptr)
 	return n_ptr->working_links > 1;
 }
 
-static int tipc_node_has_active_routes(struct tipc_node *n_ptr)
-{
-	return n_ptr && (n_ptr->last_router >= 0);
-}
-
 int tipc_node_is_up(struct tipc_node *n_ptr)
 {
-	return tipc_node_has_active_links(n_ptr) || tipc_node_has_active_routes(n_ptr);
+	return tipc_node_has_active_links(n_ptr);
 }
 
 struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
@@ -323,36 +317,17 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
 
 static void node_established_contact(struct tipc_node *n_ptr)
 {
-	struct cluster *c_ptr;
-
 	dbg("node_established_contact:-> %x\n", n_ptr->addr);
-	if (!tipc_node_has_active_routes(n_ptr) && in_own_cluster(n_ptr->addr)) {
-		tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
-	}
+	tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
 
 	/* Syncronize broadcast acks */
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 
-	if (!in_own_cluster(n_ptr->addr)) {
-		/* Usage case 1 (see above) */
-		c_ptr = tipc_cltr_find(tipc_own_addr);
-		if (!c_ptr)
-			c_ptr = tipc_cltr_create(tipc_own_addr);
-		if (c_ptr)
-			tipc_cltr_bcast_new_route(c_ptr, n_ptr->addr, 1,
-						  tipc_max_nodes);
-		return;
-	}
-
-	c_ptr = n_ptr->owner;
 	if (n_ptr->bclink.supported) {
 		tipc_nmap_add(&tipc_cltr_bcast_nodes, n_ptr->addr);
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag++;
 	}
-
-	/* Case 3 (see above) */
-	tipc_net_send_external_routes(n_ptr->addr);
 }
 
 static void node_cleanup_finished(unsigned long node_addr)
@@ -371,7 +346,6 @@ static void node_cleanup_finished(unsigned long node_addr)
 
 static void node_lost_contact(struct tipc_node *n_ptr)
 {
-	struct cluster *c_ptr;
 	struct tipc_node_subscr *ns, *tns;
 	char addr_string[16];
 	u32 i;
@@ -392,23 +366,11 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	}
 
 	/* Update routing tables */
-	if (!in_own_cluster(n_ptr->addr)) {
-		/* Case 4 (see above) */
-		c_ptr = tipc_cltr_find(tipc_own_addr);
-		tipc_cltr_bcast_lost_route(c_ptr, n_ptr->addr, 1,
-					   tipc_max_nodes);
-	} else {
-		/* Case 5 (see above) */
-		c_ptr = tipc_cltr_find(n_ptr->addr);
-		if (n_ptr->bclink.supported) {
-			tipc_nmap_remove(&tipc_cltr_bcast_nodes, n_ptr->addr);
-			if (n_ptr->addr < tipc_own_addr)
-				tipc_own_tag--;
-		}
-		tipc_net_remove_as_router(n_ptr->addr);
+	if (n_ptr->bclink.supported) {
+		tipc_nmap_remove(&tipc_cltr_bcast_nodes, n_ptr->addr);
+		if (n_ptr->addr < tipc_own_addr)
+			tipc_own_tag--;
 	}
-	if (tipc_node_has_active_routes(n_ptr))
-		return;
 
 	info("Lost contact with %s\n",
 	     tipc_addr_string_fill(addr_string, n_ptr->addr));
@@ -437,120 +399,6 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	tipc_k_signal((Handler)node_cleanup_finished, n_ptr->addr);
 }
 
-/**
- * tipc_node_select_next_hop - find the next-hop node for a message
- *
- * Called by when cluster local lookup has failed.
- */
-
-struct tipc_node *tipc_node_select_next_hop(u32 addr, u32 selector)
-{
-	struct tipc_node *n_ptr;
-	u32 router_addr;
-
-	if (!tipc_addr_domain_valid(addr))
-		return NULL;
-
-	/* Look for direct link to destination processsor */
-	n_ptr = tipc_node_find(addr);
-	if (n_ptr && tipc_node_has_active_links(n_ptr))
-		return n_ptr;
-
-	/* Cluster local system nodes *must* have direct links */
-	if (in_own_cluster(addr))
-		return NULL;
-
-	/* Look for cluster local router with direct link to node */
-	router_addr = tipc_node_select_router(n_ptr, selector);
-	if (router_addr)
-		return tipc_node_select(router_addr, selector);
-
-	/* Inter zone/cluster -- find any direct link to remote cluster */
-	addr = tipc_addr(tipc_zone(addr), tipc_cluster(addr), 0);
-	n_ptr = tipc_net_select_remote_node(addr, selector);
-	if (n_ptr && tipc_node_has_active_links(n_ptr))
-		return n_ptr;
-
-	/* Last resort -- look for any router to anywhere in remote zone */
-	router_addr =  tipc_net_select_router(addr, selector);
-	if (router_addr)
-		return tipc_node_select(router_addr, selector);
-
-	return NULL;
-}
-
-/**
- * tipc_node_select_router - select router to reach specified node
- *
- * Uses a deterministic and fair algorithm for selecting router node.
- */
-
-u32 tipc_node_select_router(struct tipc_node *n_ptr, u32 ref)
-{
-	u32 ulim;
-	u32 mask;
-	u32 start;
-	u32 r;
-
-	if (!n_ptr)
-		return 0;
-
-	if (n_ptr->last_router < 0)
-		return 0;
-	ulim = ((n_ptr->last_router + 1) * 32) - 1;
-
-	/* Start entry must be random */
-	mask = tipc_max_nodes;
-	while (mask > ulim)
-		mask >>= 1;
-	start = ref & mask;
-	r = start;
-
-	/* Lookup upwards with wrap-around */
-	do {
-		if (((n_ptr->routers[r / 32]) >> (r % 32)) & 1)
-			break;
-	} while (++r <= ulim);
-	if (r > ulim) {
-		r = 1;
-		do {
-			if (((n_ptr->routers[r / 32]) >> (r % 32)) & 1)
-				break;
-		} while (++r < start);
-		assert(r != start);
-	}
-	assert(r && (r <= ulim));
-	return tipc_addr(own_zone(), own_cluster(), r);
-}
-
-void tipc_node_add_router(struct tipc_node *n_ptr, u32 router)
-{
-	u32 r_num = tipc_node(router);
-
-	n_ptr->routers[r_num / 32] =
-		((1 << (r_num % 32)) | n_ptr->routers[r_num / 32]);
-	n_ptr->last_router = tipc_max_nodes / 32;
-	while ((--n_ptr->last_router >= 0) &&
-	       !n_ptr->routers[n_ptr->last_router]);
-}
-
-void tipc_node_remove_router(struct tipc_node *n_ptr, u32 router)
-{
-	u32 r_num = tipc_node(router);
-
-	if (n_ptr->last_router < 0)
-		return;		/* No routes */
-
-	n_ptr->routers[r_num / 32] =
-		((~(1 << (r_num % 32))) & (n_ptr->routers[r_num / 32]));
-	n_ptr->last_router = tipc_max_nodes / 32;
-	while ((--n_ptr->last_router >= 0) &&
-	       !n_ptr->routers[n_ptr->last_router]);
-
-	if (!tipc_node_is_up(n_ptr))
-		node_lost_contact(n_ptr);
-}
-
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 {
 	u32 domain;
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 7bfaf5e..3abaaa2 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -54,8 +54,6 @@
  * @cleanup_required: non-zero if cleaning up after a prior loss of contact
  * @link_cnt: number of links to node
  * @permit_changeover: non-zero if node has redundant links to this system
- * @routers: bitmap (used for multicluster communication)
- * @last_router: (used for multicluster communication)
  * @bclink: broadcast-related info
  *    @supported: non-zero if node supports TIPC b'cast capability
  *    @acked: sequence # of last outbound b'cast message acknowledged by node
@@ -80,8 +78,6 @@ struct tipc_node {
 	int working_links;
 	int cleanup_required;
 	int permit_changeover;
-	u32 routers[512/32];
-	int last_router;
 	struct {
 		int supported;
 		u32 acked;
@@ -105,11 +101,7 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr);
 int tipc_node_has_active_links(struct tipc_node *n_ptr);
 int tipc_node_has_redundant_links(struct tipc_node *n_ptr);
-u32 tipc_node_select_router(struct tipc_node *n_ptr, u32 ref);
-struct tipc_node *tipc_node_select_next_hop(u32 addr, u32 selector);
 int tipc_node_is_up(struct tipc_node *n_ptr);
-void tipc_node_add_router(struct tipc_node *n_ptr, u32 router);
-void tipc_node_remove_router(struct tipc_node *n_ptr, u32 router);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
 
@@ -117,22 +109,9 @@ static inline struct tipc_node *tipc_node_find(u32 addr)
 {
 	if (likely(in_own_cluster(addr)))
 		return tipc_local_nodes[tipc_node(addr)];
-	else if (tipc_addr_domain_valid(addr)) {
-		struct cluster *c_ptr = tipc_cltr_find(addr);
-
-		if (c_ptr)
-			return c_ptr->nodes[tipc_node(addr)];
-	}
 	return NULL;
 }
 
-static inline struct tipc_node *tipc_node_select(u32 addr, u32 selector)
-{
-	if (likely(in_own_cluster(addr)))
-		return tipc_local_nodes[tipc_node(addr)];
-	return tipc_node_select_next_hop(addr, selector);
-}
-
 static inline void tipc_node_lock(struct tipc_node *n_ptr)
 {
 	spin_lock_bh(&n_ptr->lock);
-- 
1.7.3.3

