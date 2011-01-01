From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/20] tipc: Remove prototype code for supporting slave nodes
Date: Fri, 31 Dec 2010 23:59:17 -0500
Message-ID: <1293857975-30267-3-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53099 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab1AAE77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 23:59:59 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Simplifies routines and data structures that were intended to allow
TIPC to support slave nodes (i.e. nodes that did not have links to
all of the other nodes in its cluster, forcing TIPC to route messages
that it could not deliver directly through a non-slave node).

Currently, TIPC supports only networks containing non-slave nodes,
so this code is unnecessary.

Note: The latest edition of the TIPC 2.0 Specification has eliminated
the concept of slave nodes entirely.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    4 +-
 net/tipc/addr.c             |    2 -
 net/tipc/addr.h             |   10 ---
 net/tipc/cluster.c          |  166 +++++-------------------------------------
 net/tipc/cluster.h          |    7 --
 net/tipc/config.c           |   21 +-----
 net/tipc/core.c             |    6 --
 net/tipc/core.h             |    1 -
 net/tipc/discover.c         |    4 -
 net/tipc/msg.h              |    2 +-
 net/tipc/node.c             |   59 ++++------------
 net/tipc/port.c             |    5 +-
 12 files changed, 40 insertions(+), 247 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index fa3aeaa..dcc2b87 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -97,7 +97,7 @@
 #define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_NODES     0x4009    /* tx none, rx unsigned */
-#define  TIPC_CMD_GET_MAX_SLAVES    0x400A    /* tx none, rx unsigned */
+#define  TIPC_CMD_GET_MAX_SLAVES    0x400A    /* obsoleted */
 #define  TIPC_CMD_GET_NETID         0x400B    /* tx none, rx unsigned */
 
 #define  TIPC_CMD_ENABLE_BEARER     0x4101    /* tx bearer_config, rx none */
@@ -133,7 +133,7 @@
 #define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_NODES     0x8009    /* tx unsigned, rx none */
-#define  TIPC_CMD_SET_MAX_SLAVES    0x800A    /* tx unsigned, rx none */
+#define  TIPC_CMD_SET_MAX_SLAVES    0x800A    /* obsoleted */
 #define  TIPC_CMD_SET_NETID         0x800B    /* tx unsigned, rx none */
 
 /*
diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 3d0f97d..8823e03 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -53,8 +53,6 @@ int tipc_addr_domain_valid(u32 addr)
 	u32 z = tipc_zone(addr);
 	u32 max_nodes = tipc_max_nodes;
 
-	if (is_slave(addr))
-		max_nodes = LOWEST_SLAVE + tipc_max_slaves;
 	if (n > max_nodes)
 		return 0;
 	if (c > tipc_max_clusters)
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index c1cc572..a16c6c8 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -57,16 +57,6 @@ static inline int in_own_cluster(u32 addr)
 	return !((addr ^ tipc_own_addr) >> 12);
 }
 
-static inline int is_slave(u32 addr)
-{
-	return addr & 0x800;
-}
-
-static inline int may_route(u32 addr)
-{
-	return(addr ^ tipc_own_addr) >> 11;
-}
-
 /**
  * addr_domain - convert 2-bit scope value to equivalent message lookup domain
  *
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 996b2b6..6bc9f07 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -43,7 +43,6 @@ static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
 
 struct tipc_node **tipc_local_nodes = NULL;
 struct tipc_node_map tipc_cltr_bcast_nodes = {0,{0,}};
-u32 tipc_highest_allowed_slave = 0;
 
 struct cluster *tipc_cltr_create(u32 addr)
 {
@@ -57,10 +56,7 @@ struct cluster *tipc_cltr_create(u32 addr)
 	}
 
 	c_ptr->addr = tipc_addr(tipc_zone(addr), tipc_cluster(addr), 0);
-	if (in_own_cluster(addr))
-		max_nodes = LOWEST_SLAVE + tipc_max_slaves;
-	else
-		max_nodes = tipc_max_nodes + 1;
+	max_nodes = tipc_max_nodes + 1;
 
 	c_ptr->nodes = kcalloc(max_nodes + 1, sizeof(void*), GFP_ATOMIC);
 	if (c_ptr->nodes == NULL) {
@@ -71,7 +67,6 @@ struct cluster *tipc_cltr_create(u32 addr)
 
 	if (in_own_cluster(addr))
 		tipc_local_nodes = c_ptr->nodes;
-	c_ptr->highest_slave = LOWEST_SLAVE - 1;
 	c_ptr->highest_node = 0;
 
 	tipc_net.clusters[1] = c_ptr;
@@ -87,9 +82,6 @@ void tipc_cltr_delete(struct cluster *c_ptr)
 	for (n_num = 1; n_num <= c_ptr->highest_node; n_num++) {
 		tipc_node_delete(c_ptr->nodes[n_num]);
 	}
-	for (n_num = LOWEST_SLAVE; n_num <= c_ptr->highest_slave; n_num++) {
-		tipc_node_delete(c_ptr->nodes[n_num]);
-	}
 	kfree(c_ptr->nodes);
 	kfree(c_ptr);
 }
@@ -100,8 +92,6 @@ void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr)
 	u32 n_num = tipc_node(n_ptr->addr);
 	u32 max_n_num = tipc_max_nodes;
 
-	if (in_own_cluster(n_ptr->addr))
-		max_n_num = tipc_highest_allowed_slave;
 	assert(n_num > 0);
 	assert(n_num <= max_n_num);
 	assert(c_ptr->nodes[n_num] == NULL);
@@ -237,41 +227,6 @@ void tipc_cltr_bcast_lost_route(struct cluster *c_ptr, u32 dest,
 	}
 }
 
-void tipc_cltr_send_slave_routes(struct cluster *c_ptr, u32 dest)
-{
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-	u32 highest = c_ptr->highest_slave;
-	u32 n_num;
-	int send = 0;
-
-	assert(!is_slave(dest));
-	assert(in_own_cluster(dest));
-	assert(in_own_cluster(c_ptr->addr));
-	if (highest <= LOWEST_SLAVE)
-		return;
-	buf = tipc_cltr_prepare_routing_msg(highest - LOWEST_SLAVE + 1,
-					    c_ptr->addr);
-	if (buf) {
-		msg = buf_msg(buf);
-		msg_set_remote_node(msg, c_ptr->addr);
-		msg_set_type(msg, SLAVE_ROUTING_TABLE);
-		for (n_num = LOWEST_SLAVE; n_num <= highest; n_num++) {
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
-		warn("Memory squeeze: broadcast of lost route failed\n");
-	}
-}
-
 void tipc_cltr_send_ext_routes(struct cluster *c_ptr, u32 dest)
 {
 	struct sk_buff *buf;
@@ -282,7 +237,6 @@ void tipc_cltr_send_ext_routes(struct cluster *c_ptr, u32 dest)
 
 	if (in_own_cluster(c_ptr->addr))
 		return;
-	assert(!is_slave(dest));
 	assert(in_own_cluster(dest));
 	highest = c_ptr->highest_node;
 	buf = tipc_cltr_prepare_routing_msg(highest + 1, c_ptr->addr);
@@ -306,37 +260,6 @@ void tipc_cltr_send_ext_routes(struct cluster *c_ptr, u32 dest)
 	}
 }
 
-void tipc_cltr_send_local_routes(struct cluster *c_ptr, u32 dest)
-{
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-	u32 highest = c_ptr->highest_node;
-	u32 n_num;
-	int send = 0;
-
-	assert(is_slave(dest));
-	assert(in_own_cluster(c_ptr->addr));
-	buf = tipc_cltr_prepare_routing_msg(highest, c_ptr->addr);
-	if (buf) {
-		msg = buf_msg(buf);
-		msg_set_remote_node(msg, c_ptr->addr);
-		msg_set_type(msg, LOCAL_ROUTING_TABLE);
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
-		warn("Memory squeeze: broadcast of local route failed\n");
-	}
-}
-
 void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
@@ -366,8 +289,6 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 	c_num = tipc_cluster(rem_node);
 
 	switch (msg_type(msg)) {
-	case LOCAL_ROUTING_TABLE:
-		assert(is_slave(tipc_own_addr));
 	case EXT_ROUTING_TABLE:
 		for (n_num = 1; n_num < table_size; n_num++) {
 			if (node_table[n_num]) {
@@ -382,29 +303,10 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 		}
 		break;
 	case SLAVE_ROUTING_TABLE:
-		assert(!is_slave(tipc_own_addr));
 		assert(in_own_cluster(c_ptr->addr));
-		for (n_num = 1; n_num < table_size; n_num++) {
-			if (node_table[n_num]) {
-				u32 slave_num = n_num + LOWEST_SLAVE;
-				u32 addr = tipc_addr(z_num, c_num, slave_num);
-				n_ptr = c_ptr->nodes[slave_num];
-				if (!n_ptr) {
-					n_ptr = tipc_node_create(addr);
-				}
-				if (n_ptr)
-					tipc_node_add_router(n_ptr, router);
-			}
-		}
 		break;
 	case ROUTE_ADDITION:
-		if (!is_slave(tipc_own_addr)) {
-			assert(!in_own_cluster(c_ptr->addr) ||
-			       is_slave(rem_node));
-		} else {
-			assert(in_own_cluster(c_ptr->addr) &&
-			       !is_slave(rem_node));
-		}
+		assert(!in_own_cluster(c_ptr->addr));
 		n_ptr = c_ptr->nodes[tipc_node(rem_node)];
 		if (!n_ptr)
 			n_ptr = tipc_node_create(rem_node);
@@ -412,13 +314,7 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 			tipc_node_add_router(n_ptr, router);
 		break;
 	case ROUTE_REMOVAL:
-		if (!is_slave(tipc_own_addr)) {
-			assert(!in_own_cluster(c_ptr->addr) ||
-			       is_slave(rem_node));
-		} else {
-			assert(in_own_cluster(c_ptr->addr) &&
-			       !is_slave(rem_node));
-		}
+		assert(!in_own_cluster(c_ptr->addr));
 		n_ptr = c_ptr->nodes[tipc_node(rem_node)];
 		if (n_ptr)
 			tipc_node_remove_router(n_ptr, router);
@@ -431,22 +327,12 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 
 void tipc_cltr_remove_as_router(struct cluster *c_ptr, u32 router)
 {
-	u32 start_entry;
-	u32 tstop;
 	u32 n_num;
 
-	if (is_slave(router))
-		return;	/* Slave nodes can not be routers */
-
-	if (in_own_cluster(c_ptr->addr)) {
-		start_entry = LOWEST_SLAVE;
-		tstop = c_ptr->highest_slave;
-	} else {
-		start_entry = 1;
-		tstop = c_ptr->highest_node;
-	}
+	if (in_own_cluster(c_ptr->addr))
+		return;
 
-	for (n_num = start_entry; n_num <= tstop; n_num++) {
+	for (n_num = 1; n_num <= c_ptr->highest_node; n_num++) {
 		if (c_ptr->nodes[n_num]) {
 			tipc_node_remove_router(c_ptr->nodes[n_num], router);
 		}
@@ -466,13 +352,11 @@ static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
 	u32 tstop;
 
 	assert(lower <= upper);
-	assert(((lower >= 1) && (lower <= tipc_max_nodes)) ||
-	       ((lower >= LOWEST_SLAVE) && (lower <= tipc_highest_allowed_slave)));
-	assert(((upper >= 1) && (upper <= tipc_max_nodes)) ||
-	       ((upper >= LOWEST_SLAVE) && (upper <= tipc_highest_allowed_slave)));
+	assert((lower >= 1) && (lower <= tipc_max_nodes));
+	assert((upper >= 1) && (upper <= tipc_max_nodes));
 	assert(in_own_cluster(c_ptr->addr));
 
-	tstop = is_slave(upper) ? c_ptr->highest_slave : c_ptr->highest_node;
+	tstop = c_ptr->highest_node;
 	if (tstop > upper)
 		tstop = upper;
 	for (n_num = lower; n_num <= tstop; n_num++) {
@@ -498,32 +382,23 @@ void tipc_cltr_broadcast(struct sk_buff *buf)
 	struct cluster *c_ptr;
 	struct tipc_node *n_ptr;
 	u32 n_num;
-	u32 tstart;
-	u32 tstop;
-	u32 node_type;
 
 	if (tipc_mode == TIPC_NET_MODE) {
 		c_ptr = tipc_cltr_find(tipc_own_addr);
 		assert(in_own_cluster(c_ptr->addr));	/* For now */
 
-		/* Send to standard nodes, then repeat loop sending to slaves */
-		tstart = 1;
-		tstop = c_ptr->highest_node;
-		for (node_type = 1; node_type <= 2; node_type++) {
-			for (n_num = tstart; n_num <= tstop; n_num++) {
-				n_ptr = c_ptr->nodes[n_num];
-				if (n_ptr && tipc_node_has_active_links(n_ptr)) {
-					buf_copy = skb_copy(buf, GFP_ATOMIC);
-					if (buf_copy == NULL)
-						goto exit;
-					msg_set_destnode(buf_msg(buf_copy),
-							 n_ptr->addr);
-					tipc_link_send(buf_copy, n_ptr->addr,
-						       n_ptr->addr);
-				}
+		/* Send to nodes */
+		for (n_num = 1; n_num <= c_ptr->highest_node; n_num++) {
+			n_ptr = c_ptr->nodes[n_num];
+			if (n_ptr && tipc_node_has_active_links(n_ptr)) {
+				buf_copy = skb_copy(buf, GFP_ATOMIC);
+				if (buf_copy == NULL)
+					goto exit;
+				msg_set_destnode(buf_msg(buf_copy),
+						 n_ptr->addr);
+				tipc_link_send(buf_copy, n_ptr->addr,
+					       n_ptr->addr);
 			}
-			tstart = LOWEST_SLAVE;
-			tstop = c_ptr->highest_slave;
 		}
 	}
 exit:
@@ -532,7 +407,6 @@ exit:
 
 int tipc_cltr_init(void)
 {
-	tipc_highest_allowed_slave = LOWEST_SLAVE + tipc_max_slaves;
 	return tipc_cltr_create(tipc_own_addr) ? 0 : -ENOMEM;
 }
 
diff --git a/net/tipc/cluster.h b/net/tipc/cluster.h
index 21493f7..aa1fd6a 100644
--- a/net/tipc/cluster.h
+++ b/net/tipc/cluster.h
@@ -40,26 +40,21 @@
 #include "addr.h"
 #include "net.h"
 
-#define LOWEST_SLAVE  2048u
-
 /**
  * struct cluster - TIPC cluster structure
  * @addr: network address of cluster
  * @nodes: array of pointers to all nodes within cluster
  * @highest_node: id of highest numbered node within cluster
- * @highest_slave: (used for secondary node support)
  */
 
 struct cluster {
 	u32 addr;
 	struct tipc_node **nodes;
 	u32 highest_node;
-	u32 highest_slave;
 };
 
 
 extern struct tipc_node **tipc_local_nodes;
-extern u32 tipc_highest_allowed_slave;
 extern struct tipc_node_map tipc_cltr_bcast_nodes;
 
 void tipc_cltr_remove_as_router(struct cluster *c_ptr, u32 router);
@@ -70,12 +65,10 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf);
 struct cluster *tipc_cltr_create(u32 addr);
 void tipc_cltr_delete(struct cluster *c_ptr);
 void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr);
-void tipc_cltr_send_slave_routes(struct cluster *c_ptr, u32 dest);
 void tipc_cltr_broadcast(struct sk_buff *buf);
 int tipc_cltr_init(void);
 
 void tipc_cltr_bcast_new_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
-void tipc_cltr_send_local_routes(struct cluster *c_ptr, u32 dest);
 void tipc_cltr_bcast_lost_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
 
 static inline struct cluster *tipc_cltr_find(u32 addr)
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 8de97dd..05dc102 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -301,19 +301,6 @@ static struct sk_buff *cfg_set_max_nodes(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_max_slaves(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value != 0)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (max secondary nodes fixed at 0)");
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_netid(void)
 {
 	u32 value;
@@ -439,9 +426,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_NODES:
 		rep_tlv_buf = cfg_set_max_nodes();
 		break;
-	case TIPC_CMD_SET_MAX_SLAVES:
-		rep_tlv_buf = cfg_set_max_slaves();
-		break;
 	case TIPC_CMD_SET_NETID:
 		rep_tlv_buf = cfg_set_netid();
 		break;
@@ -463,9 +447,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_NODES:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_nodes);
 		break;
-	case TIPC_CMD_GET_MAX_SLAVES:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_slaves);
-		break;
 	case TIPC_CMD_GET_NETID:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
 		break;
@@ -475,6 +456,8 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 		break;
 	case TIPC_CMD_SET_MAX_ZONES:
 	case TIPC_CMD_GET_MAX_ZONES:
+	case TIPC_CMD_SET_MAX_SLAVES:
+	case TIPC_CMD_GET_MAX_SLAVES:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (obsolete command)");
 		break;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 1394633..8b7af89 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -56,10 +56,6 @@
 #define CONFIG_TIPC_NODES 255
 #endif
 
-#ifndef CONFIG_TIPC_SLAVE_NODES
-#define CONFIG_TIPC_SLAVE_NODES 0
-#endif
-
 #ifndef CONFIG_TIPC_PORTS
 #define CONFIG_TIPC_PORTS 8191
 #endif
@@ -82,7 +78,6 @@ const char tipc_alphabet[] =
 u32 tipc_own_addr;
 int tipc_max_clusters;
 int tipc_max_nodes;
-int tipc_max_slaves;
 int tipc_max_ports;
 int tipc_max_subscriptions;
 int tipc_max_publications;
@@ -206,7 +201,6 @@ static int __init tipc_init(void)
 	tipc_max_ports = CONFIG_TIPC_PORTS;
 	tipc_max_clusters = CONFIG_TIPC_CLUSTERS;
 	tipc_max_nodes = CONFIG_TIPC_NODES;
-	tipc_max_slaves = CONFIG_TIPC_SLAVE_NODES;
 	tipc_net_id = 4711;
 
 	if ((res = tipc_core_start()))
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 9403a22..8313a16 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -186,7 +186,6 @@ void tipc_dump_dbg(struct print_buf *, const char *fmt, ...);
 extern u32 tipc_own_addr;
 extern int tipc_max_clusters;
 extern int tipc_max_nodes;
-extern int tipc_max_slaves;
 extern int tipc_max_ports;
 extern int tipc_max_subscriptions;
 extern int tipc_max_publications;
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f2ce36b..80799f6 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -149,10 +149,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 	}
 	if (!tipc_in_scope(dest, tipc_own_addr))
 		return;
-	if (is_slave(tipc_own_addr) && is_slave(orig))
-		return;
-	if (is_slave(orig) && !in_own_cluster(orig))
-		return;
 	if (in_own_cluster(orig)) {
 		/* Always accept link here */
 		struct sk_buff *rbuf;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index aee5386..c1b6217 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -850,7 +850,7 @@ static inline void msg_set_dataoctet(struct tipc_msg *m, u32 pos)
  * Routing table message types
  */
 #define EXT_ROUTING_TABLE    0
-#define LOCAL_ROUTING_TABLE  1
+#define LOCAL_ROUTING_TABLE  1		/* obsoleted */
 #define SLAVE_ROUTING_TABLE  2
 #define ROUTE_ADDITION       3
 #define ROUTE_REMOVAL        4
diff --git a/net/tipc/node.c b/net/tipc/node.c
index c20bd85..8ffbdb3 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -333,8 +333,6 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	/* Syncronize broadcast acks */
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 
-	if (is_slave(tipc_own_addr))
-		return;
 	if (!in_own_cluster(n_ptr->addr)) {
 		/* Usage case 1 (see above) */
 		c_ptr = tipc_cltr_find(tipc_own_addr);
@@ -347,13 +345,6 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	}
 
 	c_ptr = n_ptr->owner;
-	if (is_slave(n_ptr->addr)) {
-		/* Usage case 2 (see above) */
-		tipc_cltr_bcast_new_route(c_ptr, n_ptr->addr, 1, tipc_max_nodes);
-		tipc_cltr_send_local_routes(c_ptr, n_ptr->addr);
-		return;
-	}
-
 	if (n_ptr->bclink.supported) {
 		tipc_nmap_add(&tipc_cltr_bcast_nodes, n_ptr->addr);
 		if (n_ptr->addr < tipc_own_addr)
@@ -362,9 +353,6 @@ static void node_established_contact(struct tipc_node *n_ptr)
 
 	/* Case 3 (see above) */
 	tipc_net_send_external_routes(n_ptr->addr);
-	tipc_cltr_send_slave_routes(c_ptr, n_ptr->addr);
-	tipc_cltr_bcast_new_route(c_ptr, n_ptr->addr, LOWEST_SLAVE,
-				  tipc_highest_allowed_slave);
 }
 
 static void node_cleanup_finished(unsigned long node_addr)
@@ -404,33 +392,20 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	}
 
 	/* Update routing tables */
-	if (is_slave(tipc_own_addr)) {
-		tipc_net_remove_as_router(n_ptr->addr);
+	if (!in_own_cluster(n_ptr->addr)) {
+		/* Case 4 (see above) */
+		c_ptr = tipc_cltr_find(tipc_own_addr);
+		tipc_cltr_bcast_lost_route(c_ptr, n_ptr->addr, 1,
+					   tipc_max_nodes);
 	} else {
-		if (!in_own_cluster(n_ptr->addr)) {
-			/* Case 4 (see above) */
-			c_ptr = tipc_cltr_find(tipc_own_addr);
-			tipc_cltr_bcast_lost_route(c_ptr, n_ptr->addr, 1,
-						   tipc_max_nodes);
-		} else {
-			/* Case 5 (see above) */
-			c_ptr = tipc_cltr_find(n_ptr->addr);
-			if (is_slave(n_ptr->addr)) {
-				tipc_cltr_bcast_lost_route(c_ptr, n_ptr->addr, 1,
-							   tipc_max_nodes);
-			} else {
-				if (n_ptr->bclink.supported) {
-					tipc_nmap_remove(&tipc_cltr_bcast_nodes,
-							 n_ptr->addr);
-					if (n_ptr->addr < tipc_own_addr)
-						tipc_own_tag--;
-				}
-				tipc_net_remove_as_router(n_ptr->addr);
-				tipc_cltr_bcast_lost_route(c_ptr, n_ptr->addr,
-							   LOWEST_SLAVE,
-							   tipc_highest_allowed_slave);
-			}
+		/* Case 5 (see above) */
+		c_ptr = tipc_cltr_find(n_ptr->addr);
+		if (n_ptr->bclink.supported) {
+			tipc_nmap_remove(&tipc_cltr_bcast_nodes, n_ptr->addr);
+			if (n_ptr->addr < tipc_own_addr)
+				tipc_own_tag--;
 		}
+		tipc_net_remove_as_router(n_ptr->addr);
 	}
 	if (tipc_node_has_active_routes(n_ptr))
 		return;
@@ -482,7 +457,7 @@ struct tipc_node *tipc_node_select_next_hop(u32 addr, u32 selector)
 		return n_ptr;
 
 	/* Cluster local system nodes *must* have direct links */
-	if (!is_slave(addr) && in_own_cluster(addr))
+	if (in_own_cluster(addr))
 		return NULL;
 
 	/* Look for cluster local router with direct link to node */
@@ -490,11 +465,6 @@ struct tipc_node *tipc_node_select_next_hop(u32 addr, u32 selector)
 	if (router_addr)
 		return tipc_node_select(router_addr, selector);
 
-	/* Slave nodes can only be accessed within own cluster via a
-	   known router with direct link -- if no router was found,give up */
-	if (is_slave(addr))
-		return NULL;
-
 	/* Inter zone/cluster -- find any direct link to remote cluster */
 	addr = tipc_addr(tipc_zone(addr), tipc_cluster(addr), 0);
 	n_ptr = tipc_net_select_remote_node(addr, selector);
@@ -603,8 +573,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 		return tipc_cfg_reply_none();
 	}
 
-	/* For now, get space for all other nodes
-	   (will need to modify this when slave nodes are supported */
+	/* For now, get space for all other nodes */
 
 	payload_size = TLV_SPACE(sizeof(node_info)) * (tipc_max_nodes - 1);
 	if (payload_size > 32768u) {
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 7873283..c033cb8 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1110,10 +1110,7 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	msg_set_origport(msg, p_ptr->publ.ref);
 	msg_set_transp_seqno(msg, 42);
 	msg_set_type(msg, TIPC_CONN_MSG);
-	if (!may_route(peer->node))
-		msg_set_hdr_sz(msg, SHORT_H_SIZE);
-	else
-		msg_set_hdr_sz(msg, LONG_H_SIZE);
+	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
 	p_ptr->probing_interval = PROBING_INTERVAL;
 	p_ptr->probing_state = CONFIRMED;
-- 
1.7.3.3

