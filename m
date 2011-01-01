From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/20] tipc: Remove prototype code for supporting multiple zones
Date: Fri, 31 Dec 2010 23:59:16 -0500
Message-ID: <1293857975-30267-2-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53096 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab1AAE76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 23:59:58 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates routines, data structures, and files that were intended
to allows TIPC to support a network containing multiple zones.
Currently, TIPC supports only networks consisting of a single cluster
within a single zone, so this code is unnecessary.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    4 +-
 net/tipc/Kconfig            |   12 ---
 net/tipc/Makefile           |    2 +-
 net/tipc/addr.c             |    4 -
 net/tipc/cluster.c          |   14 +----
 net/tipc/cluster.h          |   12 +--
 net/tipc/config.c           |   30 ++-------
 net/tipc/core.c             |    6 --
 net/tipc/core.h             |    1 -
 net/tipc/net.c              |   41 +++++++----
 net/tipc/net.h              |    8 ++-
 net/tipc/node.c             |    7 +-
 net/tipc/node.h             |    1 -
 net/tipc/zone.c             |  159 -------------------------------------------
 net/tipc/zone.h             |   70 -------------------
 15 files changed, 46 insertions(+), 325 deletions(-)
 delete mode 100644 net/tipc/zone.c
 delete mode 100644 net/tipc/zone.h

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 9cde86c..fa3aeaa 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -94,7 +94,7 @@
 #define  TIPC_CMD_GET_MAX_PORTS     0x4004    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_PUBL      0x4005    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_SUBSCR    0x4006    /* tx none, rx unsigned */
-#define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* tx none, rx unsigned */
+#define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_NODES     0x4009    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_SLAVES    0x400A    /* tx none, rx unsigned */
@@ -130,7 +130,7 @@
 #define  TIPC_CMD_SET_MAX_PORTS     0x8004    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_PUBL      0x8005    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_SUBSCR    0x8006    /* tx unsigned, rx none */
-#define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* tx unsigned, rx none */
+#define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_NODES     0x8009    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_SLAVES    0x800A    /* tx unsigned, rx none */
diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index b74f78d..06d3290 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -29,18 +29,6 @@ config TIPC_ADVANCED
 	  Saying Y here will open some advanced configuration for TIPC.
 	  Most users do not need to bother; if unsure, just say N.
 
-config TIPC_ZONES
-	int "Maximum number of zones in a network"
-	depends on TIPC_ADVANCED
-	range 1 255
-	default "3"
-	help
-	  Specifies how many zones can be supported in a TIPC network.
-	  Can range from 1 to 255 zones; default is 3.
-
-	  Setting this to a smaller value saves some memory;
-	  setting it to a higher value allows for more zones.
-
 config TIPC_CLUSTERS
 	int "Maximum number of clusters in a zone"
 	depends on TIPC_ADVANCED
diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index dceb702..3d936f0 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -8,6 +8,6 @@ tipc-y	+= addr.o bcast.o bearer.o config.o cluster.o \
 	   core.o handler.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o port.o ref.o  \
-	   socket.o user_reg.o zone.o dbg.o eth_media.o
+	   socket.o user_reg.o dbg.o eth_media.o
 
 # End of file
diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 886715a..3d0f97d 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -35,8 +35,6 @@
  */
 
 #include "core.h"
-#include "addr.h"
-#include "zone.h"
 #include "cluster.h"
 
 /**
@@ -61,8 +59,6 @@ int tipc_addr_domain_valid(u32 addr)
 		return 0;
 	if (c > tipc_max_clusters)
 		return 0;
-	if (z > tipc_max_zones)
-		return 0;
 
 	if (n && (!z || !c))
 		return 0;
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 405be87..996b2b6 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -47,7 +47,6 @@ u32 tipc_highest_allowed_slave = 0;
 
 struct cluster *tipc_cltr_create(u32 addr)
 {
-	struct _zone *z_ptr;
 	struct cluster *c_ptr;
 	int max_nodes;
 
@@ -75,18 +74,7 @@ struct cluster *tipc_cltr_create(u32 addr)
 	c_ptr->highest_slave = LOWEST_SLAVE - 1;
 	c_ptr->highest_node = 0;
 
-	z_ptr = tipc_zone_find(tipc_zone(addr));
-	if (!z_ptr) {
-		z_ptr = tipc_zone_create(addr);
-	}
-	if (!z_ptr) {
-		kfree(c_ptr->nodes);
-		kfree(c_ptr);
-		return NULL;
-	}
-
-	tipc_zone_attach_cluster(z_ptr, c_ptr);
-	c_ptr->owner = z_ptr;
+	tipc_net.clusters[1] = c_ptr;
 	return c_ptr;
 }
 
diff --git a/net/tipc/cluster.h b/net/tipc/cluster.h
index 32636d9..21493f7 100644
--- a/net/tipc/cluster.h
+++ b/net/tipc/cluster.h
@@ -38,14 +38,13 @@
 #define _TIPC_CLUSTER_H
 
 #include "addr.h"
-#include "zone.h"
+#include "net.h"
 
 #define LOWEST_SLAVE  2048u
 
 /**
  * struct cluster - TIPC cluster structure
  * @addr: network address of cluster
- * @owner: pointer to zone that cluster belongs to
  * @nodes: array of pointers to all nodes within cluster
  * @highest_node: id of highest numbered node within cluster
  * @highest_slave: (used for secondary node support)
@@ -53,7 +52,6 @@
 
 struct cluster {
 	u32 addr;
-	struct _zone *owner;
 	struct tipc_node **nodes;
 	u32 highest_node;
 	u32 highest_slave;
@@ -82,11 +80,9 @@ void tipc_cltr_bcast_lost_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi)
 
 static inline struct cluster *tipc_cltr_find(u32 addr)
 {
-	struct _zone *z_ptr = tipc_zone_find(addr);
-
-	if (z_ptr)
-		return z_ptr->clusters[1];
-	return NULL;
+	if (!in_own_cluster(addr))
+		return NULL;
+	return tipc_net.clusters[1];
 }
 
 #endif
diff --git a/net/tipc/config.c b/net/tipc/config.c
index bdde39f..8de97dd 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -269,25 +269,6 @@ static struct sk_buff *cfg_set_max_ports(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_max_zones(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value == tipc_max_zones)
-		return tipc_cfg_reply_none();
-	if (value != delimit(value, 1, 255))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (max zones must be 1-255)");
-	if (tipc_mode == TIPC_NET_MODE)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-			" (cannot change max zones once TIPC has joined a network)");
-	tipc_max_zones = value;
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_max_clusters(void)
 {
 	u32 value;
@@ -452,9 +433,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_SUBSCR:
 		rep_tlv_buf = cfg_set_max_subscriptions();
 		break;
-	case TIPC_CMD_SET_MAX_ZONES:
-		rep_tlv_buf = cfg_set_max_zones();
-		break;
 	case TIPC_CMD_SET_MAX_CLUSTERS:
 		rep_tlv_buf = cfg_set_max_clusters();
 		break;
@@ -479,9 +457,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_SUBSCR:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_subscriptions);
 		break;
-	case TIPC_CMD_GET_MAX_ZONES:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_zones);
-		break;
 	case TIPC_CMD_GET_MAX_CLUSTERS:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_clusters);
 		break;
@@ -498,6 +473,11 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 		rep_tlv_buf =
 			tipc_cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
 		break;
+	case TIPC_CMD_SET_MAX_ZONES:
+	case TIPC_CMD_GET_MAX_ZONES:
+		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+							  " (obsolete command)");
+		break;
 	default:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (unknown command)");
diff --git a/net/tipc/core.c b/net/tipc/core.c
index f5d62c1..1394633 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -48,10 +48,6 @@
 #include "config.h"
 
 
-#ifndef CONFIG_TIPC_ZONES
-#define CONFIG_TIPC_ZONES 3
-#endif
-
 #ifndef CONFIG_TIPC_CLUSTERS
 #define CONFIG_TIPC_CLUSTERS 1
 #endif
@@ -84,7 +80,6 @@ const char tipc_alphabet[] =
 /* configurable TIPC parameters */
 
 u32 tipc_own_addr;
-int tipc_max_zones;
 int tipc_max_clusters;
 int tipc_max_nodes;
 int tipc_max_slaves;
@@ -209,7 +204,6 @@ static int __init tipc_init(void)
 	tipc_max_publications = 10000;
 	tipc_max_subscriptions = 2000;
 	tipc_max_ports = CONFIG_TIPC_PORTS;
-	tipc_max_zones = CONFIG_TIPC_ZONES;
 	tipc_max_clusters = CONFIG_TIPC_CLUSTERS;
 	tipc_max_nodes = CONFIG_TIPC_NODES;
 	tipc_max_slaves = CONFIG_TIPC_SLAVE_NODES;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index ca7e171..9403a22 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -184,7 +184,6 @@ void tipc_dump_dbg(struct print_buf *, const char *fmt, ...);
  */
 
 extern u32 tipc_own_addr;
-extern int tipc_max_zones;
 extern int tipc_max_clusters;
 extern int tipc_max_nodes;
 extern int tipc_max_slaves;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index c2b4b86..a25f8bb 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -36,7 +36,6 @@
 
 #include "core.h"
 #include "net.h"
-#include "zone.h"
 #include "name_table.h"
 #include "name_distr.h"
 #include "subscr.h"
@@ -111,46 +110,56 @@
 */
 
 DEFINE_RWLOCK(tipc_net_lock);
-static struct _zone *tipc_zones[256] = { NULL, };
-struct network tipc_net = { tipc_zones };
+struct network tipc_net;
 
 struct tipc_node *tipc_net_select_remote_node(u32 addr, u32 ref)
 {
-	return tipc_zone_select_remote_node(tipc_net.zones[tipc_zone(addr)], addr, ref);
+	struct cluster *c_ptr;
+
+	c_ptr = tipc_net.clusters[1];
+	if (!c_ptr)
+		return NULL;
+	return tipc_cltr_select_node(c_ptr, ref);
 }
 
 u32 tipc_net_select_router(u32 addr, u32 ref)
 {
-	return tipc_zone_select_router(tipc_net.zones[tipc_zone(addr)], addr, ref);
+	struct cluster *c_ptr;
+
+	c_ptr = tipc_net.clusters[1];
+	if (!c_ptr)
+		return 0;
+	return tipc_cltr_select_router(c_ptr, ref);
 }
 
 void tipc_net_remove_as_router(u32 router)
 {
-	u32 z_num;
+	u32 c_num;
 
-	for (z_num = 1; z_num <= tipc_max_zones; z_num++) {
-		if (!tipc_net.zones[z_num])
+	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
+		if (!tipc_net.clusters[c_num])
 			continue;
-		tipc_zone_remove_as_router(tipc_net.zones[z_num], router);
+		tipc_cltr_remove_as_router(tipc_net.clusters[c_num], router);
 	}
 }
 
 void tipc_net_send_external_routes(u32 dest)
 {
-	u32 z_num;
+	u32 c_num;
 
-	for (z_num = 1; z_num <= tipc_max_zones; z_num++) {
-		if (tipc_net.zones[z_num])
-			tipc_zone_send_external_routes(tipc_net.zones[z_num], dest);
+	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
+		if (tipc_net.clusters[c_num])
+			tipc_cltr_send_ext_routes(tipc_net.clusters[c_num],
+						  dest);
 	}
 }
 
 static void net_stop(void)
 {
-	u32 z_num;
+	u32 c_num;
 
-	for (z_num = 1; z_num <= tipc_max_zones; z_num++)
-		tipc_zone_delete(tipc_net.zones[z_num]);
+	for (c_num = 1; c_num <= tipc_max_clusters; c_num++)
+		tipc_cltr_delete(tipc_net.clusters[c_num]);
 }
 
 static void net_route_named_msg(struct sk_buff *buf)
diff --git a/net/tipc/net.h b/net/tipc/net.h
index de2b9ad..786c940 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -37,15 +37,17 @@
 #ifndef _TIPC_NET_H
 #define _TIPC_NET_H
 
-struct _zone;
+struct cluster;
 
 /**
  * struct network - TIPC network structure
- * @zones: array of pointers to all zones within network
+ * @clusters: array of pointers to all clusters within zone
+ * @links: number of (unicast) links to cluster
  */
 
 struct network {
-	struct _zone **zones;
+	struct cluster *clusters[2]; /* currently limited to just 1 cluster */
+	u32 links;
 };
 
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index df71dfc..c20bd85 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -257,7 +257,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 
 		if (!n_ptr->links[bearer_id]) {
 			n_ptr->links[bearer_id] = l_ptr;
-			tipc_net.zones[tipc_zone(l_ptr->addr)]->links++;
+			tipc_net.links++;
 			n_ptr->link_cnt++;
 			return n_ptr;
 		}
@@ -271,7 +271,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
 {
 	n_ptr->links[l_ptr->b_ptr->identity] = NULL;
-	tipc_net.zones[tipc_zone(l_ptr->addr)]->links--;
+	tipc_net.links--;
 	n_ptr->link_cnt--;
 }
 
@@ -656,8 +656,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Get space for all unicast links + multicast link */
 
-	payload_size = TLV_SPACE(sizeof(link_info)) *
-		(tipc_net.zones[tipc_zone(tipc_own_addr)]->links + 1);
+	payload_size = TLV_SPACE(sizeof(link_info)) * (tipc_net.links + 1);
 	if (payload_size > 32768u) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
diff --git a/net/tipc/node.h b/net/tipc/node.h
index fff331b..7bfaf5e 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -38,7 +38,6 @@
 #define _TIPC_NODE_H
 
 #include "node_subscr.h"
-#include "addr.h"
 #include "cluster.h"
 #include "bearer.h"
 
diff --git a/net/tipc/zone.c b/net/tipc/zone.c
deleted file mode 100644
index 1b61ca8..0000000
--- a/net/tipc/zone.c
+++ /dev/null
@@ -1,159 +0,0 @@
-/*
- * net/tipc/zone.c: TIPC zone management routines
- *
- * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include "core.h"
-#include "zone.h"
-#include "cluster.h"
-#include "node.h"
-
-struct _zone *tipc_zone_create(u32 addr)
-{
-	struct _zone *z_ptr;
-	u32 z_num;
-
-	if (!tipc_addr_domain_valid(addr)) {
-		err("Zone creation failed, invalid domain 0x%x\n", addr);
-		return NULL;
-	}
-
-	z_ptr = kzalloc(sizeof(*z_ptr), GFP_ATOMIC);
-	if (!z_ptr) {
-		warn("Zone creation failed, insufficient memory\n");
-		return NULL;
-	}
-
-	z_num = tipc_zone(addr);
-	z_ptr->addr = tipc_addr(z_num, 0, 0);
-	tipc_net.zones[z_num] = z_ptr;
-	return z_ptr;
-}
-
-void tipc_zone_delete(struct _zone *z_ptr)
-{
-	u32 c_num;
-
-	if (!z_ptr)
-		return;
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
-		tipc_cltr_delete(z_ptr->clusters[c_num]);
-	}
-	kfree(z_ptr);
-}
-
-void tipc_zone_attach_cluster(struct _zone *z_ptr, struct cluster *c_ptr)
-{
-	u32 c_num = tipc_cluster(c_ptr->addr);
-
-	assert(c_ptr->addr);
-	assert(c_num <= tipc_max_clusters);
-	assert(z_ptr->clusters[c_num] == NULL);
-	z_ptr->clusters[c_num] = c_ptr;
-}
-
-void tipc_zone_remove_as_router(struct _zone *z_ptr, u32 router)
-{
-	u32 c_num;
-
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
-		if (z_ptr->clusters[c_num]) {
-			tipc_cltr_remove_as_router(z_ptr->clusters[c_num],
-						   router);
-		}
-	}
-}
-
-void tipc_zone_send_external_routes(struct _zone *z_ptr, u32 dest)
-{
-	u32 c_num;
-
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
-		if (z_ptr->clusters[c_num]) {
-			if (in_own_cluster(z_ptr->addr))
-				continue;
-			tipc_cltr_send_ext_routes(z_ptr->clusters[c_num], dest);
-		}
-	}
-}
-
-struct tipc_node *tipc_zone_select_remote_node(struct _zone *z_ptr, u32 addr, u32 ref)
-{
-	struct cluster *c_ptr;
-	struct tipc_node *n_ptr;
-	u32 c_num;
-
-	if (!z_ptr)
-		return NULL;
-	c_ptr = z_ptr->clusters[tipc_cluster(addr)];
-	if (!c_ptr)
-		return NULL;
-	n_ptr = tipc_cltr_select_node(c_ptr, ref);
-	if (n_ptr)
-		return n_ptr;
-
-	/* Links to any other clusters within this zone ? */
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
-		c_ptr = z_ptr->clusters[c_num];
-		if (!c_ptr)
-			return NULL;
-		n_ptr = tipc_cltr_select_node(c_ptr, ref);
-		if (n_ptr)
-			return n_ptr;
-	}
-	return NULL;
-}
-
-u32 tipc_zone_select_router(struct _zone *z_ptr, u32 addr, u32 ref)
-{
-	struct cluster *c_ptr;
-	u32 c_num;
-	u32 router;
-
-	if (!z_ptr)
-		return 0;
-	c_ptr = z_ptr->clusters[tipc_cluster(addr)];
-	router = c_ptr ? tipc_cltr_select_router(c_ptr, ref) : 0;
-	if (router)
-		return router;
-
-	/* Links to any other clusters within the zone? */
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++) {
-		c_ptr = z_ptr->clusters[c_num];
-		router = c_ptr ? tipc_cltr_select_router(c_ptr, ref) : 0;
-		if (router)
-			return router;
-	}
-	return 0;
-}
diff --git a/net/tipc/zone.h b/net/tipc/zone.h
deleted file mode 100644
index bd1c20c..0000000
--- a/net/tipc/zone.h
+++ /dev/null
@@ -1,70 +0,0 @@
-/*
- * net/tipc/zone.h: Include file for TIPC zone management routines
- *
- * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _TIPC_ZONE_H
-#define _TIPC_ZONE_H
-
-#include "node_subscr.h"
-#include "net.h"
-
-
-/**
- * struct _zone - TIPC zone structure
- * @addr: network address of zone
- * @clusters: array of pointers to all clusters within zone
- * @links: number of (unicast) links to zone
- */
-
-struct _zone {
-	u32 addr;
-	struct cluster *clusters[2]; /* currently limited to just 1 cluster */
-	u32 links;
-};
-
-struct tipc_node *tipc_zone_select_remote_node(struct _zone *z_ptr, u32 addr, u32 ref);
-u32 tipc_zone_select_router(struct _zone *z_ptr, u32 addr, u32 ref);
-void tipc_zone_remove_as_router(struct _zone *z_ptr, u32 router);
-void tipc_zone_send_external_routes(struct _zone *z_ptr, u32 dest);
-struct _zone *tipc_zone_create(u32 addr);
-void tipc_zone_delete(struct _zone *z_ptr);
-void tipc_zone_attach_cluster(struct _zone *z_ptr, struct cluster *c_ptr);
-
-static inline struct _zone *tipc_zone_find(u32 addr)
-{
-	return tipc_net.zones[tipc_zone(addr)];
-}
-
-#endif
-- 
1.7.3.3

