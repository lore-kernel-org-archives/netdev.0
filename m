From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/20] tipc: Remove prototype code for supporting multiple clusters
Date: Fri, 31 Dec 2010 23:59:19 -0500
Message-ID: <1293857975-30267-5-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53176 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab1AAFAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:01 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates routines, data structures, and files that were intended
to allow TIPC to support a network containing multiple clusters.
Currently, TIPC supports only networks consisting of a single cluster
within a single zone, so this code is unnecessary.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    4 +-
 net/tipc/Kconfig            |   10 ---
 net/tipc/Makefile           |    2 +-
 net/tipc/addr.c             |    5 +-
 net/tipc/bcast.c            |    9 ++-
 net/tipc/bcast.h            |    1 +
 net/tipc/cluster.c          |  135 -------------------------------------------
 net/tipc/cluster.h          |   73 -----------------------
 net/tipc/config.c           |   21 +------
 net/tipc/core.c             |    6 --
 net/tipc/core.h             |    1 -
 net/tipc/name_distr.c       |   28 ++++++++-
 net/tipc/net.c              |   25 ++++++--
 net/tipc/net.h              |    8 ++-
 net/tipc/node.c             |   37 ++++++------
 net/tipc/node.h             |    7 +-
 16 files changed, 83 insertions(+), 289 deletions(-)
 delete mode 100644 net/tipc/cluster.c
 delete mode 100644 net/tipc/cluster.h

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 1f38df1..677aa13 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -95,7 +95,7 @@
 #define  TIPC_CMD_GET_MAX_PUBL      0x4005    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_SUBSCR    0x4006    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* obsoleted */
-#define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* tx none, rx unsigned */
+#define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* obsoleted */
 #define  TIPC_CMD_GET_MAX_NODES     0x4009    /* tx none, rx unsigned */
 #define  TIPC_CMD_GET_MAX_SLAVES    0x400A    /* obsoleted */
 #define  TIPC_CMD_GET_NETID         0x400B    /* tx none, rx unsigned */
@@ -131,7 +131,7 @@
 #define  TIPC_CMD_SET_MAX_PUBL      0x8005    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_SUBSCR    0x8006    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* obsoleted */
-#define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* tx unsigned, rx none */
+#define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* obsoleted */
 #define  TIPC_CMD_SET_MAX_NODES     0x8009    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_SLAVES    0x800A    /* obsoleted */
 #define  TIPC_CMD_SET_NETID         0x800B    /* tx unsigned, rx none */
diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 06d3290..c02d3e9 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -29,16 +29,6 @@ config TIPC_ADVANCED
 	  Saying Y here will open some advanced configuration for TIPC.
 	  Most users do not need to bother; if unsure, just say N.
 
-config TIPC_CLUSTERS
-	int "Maximum number of clusters in a zone"
-	depends on TIPC_ADVANCED
-	range 1 1
-	default "1"
-	help
-	  Specifies how many clusters can be supported in a TIPC zone.
-
-	  *** Currently TIPC only supports a single cluster per zone. ***
-
 config TIPC_NODES
 	int "Maximum number of nodes in a cluster"
 	depends on TIPC_ADVANCED
diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index 3d936f0..849d819 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_TIPC) := tipc.o
 
-tipc-y	+= addr.o bcast.o bearer.o config.o cluster.o \
+tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   core.o handler.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o port.o ref.o  \
diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 8823e03..483868a 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -35,7 +35,8 @@
  */
 
 #include "core.h"
-#include "cluster.h"
+#include "node.h"
+#include "addr.h"
 
 /**
  * tipc_addr_domain_valid - validates a network domain address
@@ -55,8 +56,6 @@ int tipc_addr_domain_valid(u32 addr)
 
 	if (n > max_nodes)
 		return 0;
-	if (c > tipc_max_clusters)
-		return 0;
 
 	if (n && (!z || !c))
 		return 0;
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 6d828d9..110829e 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -111,6 +111,9 @@ static struct bclink *bclink = NULL;
 static struct link *bcl = NULL;
 static DEFINE_SPINLOCK(bc_lock);
 
+/* broadcast-capable node map */
+struct tipc_node_map tipc_bcast_nmap;
+
 const char tipc_bclink_name[] = "broadcast-link";
 
 static void tipc_nmap_diff(struct tipc_node_map *nm_a,
@@ -566,8 +569,8 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 	if (likely(!msg_non_seq(buf_msg(buf)))) {
 		struct tipc_msg *msg;
 
-		assert(tipc_cltr_bcast_nodes.count != 0);
-		bcbuf_set_acks(buf, tipc_cltr_bcast_nodes.count);
+		assert(tipc_bcast_nmap.count != 0);
+		bcbuf_set_acks(buf, tipc_bcast_nmap.count);
 		msg = buf_msg(buf);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tipc_net_id);
@@ -576,7 +579,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 
 	/* Send buffer over bearers until all targets reached */
 
-	bcbearer->remains = tipc_cltr_bcast_nodes;
+	bcbearer->remains = tipc_bcast_nmap;
 
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
 		struct bearer *p = bcbearer->bpairs[bp_index].primary;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 011c03f..51f8c53 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -51,6 +51,7 @@ struct tipc_node_map {
 	u32 map[MAX_NODES / WSIZE];
 };
 
+extern struct tipc_node_map tipc_bcast_nmap;
 
 #define PLSIZE 32
 
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
deleted file mode 100644
index ba6f5bf..0000000
--- a/net/tipc/cluster.c
+++ /dev/null
@@ -1,135 +0,0 @@
-/*
- * net/tipc/cluster.c: TIPC cluster management routines
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
-#include "cluster.h"
-#include "link.h"
-
-struct tipc_node **tipc_local_nodes = NULL;
-struct tipc_node_map tipc_cltr_bcast_nodes = {0,{0,}};
-
-struct cluster *tipc_cltr_create(u32 addr)
-{
-	struct cluster *c_ptr;
-	int max_nodes;
-
-	c_ptr = kzalloc(sizeof(*c_ptr), GFP_ATOMIC);
-	if (c_ptr == NULL) {
-		warn("Cluster creation failure, no memory\n");
-		return NULL;
-	}
-
-	c_ptr->addr = tipc_addr(tipc_zone(addr), tipc_cluster(addr), 0);
-	max_nodes = tipc_max_nodes + 1;
-
-	c_ptr->nodes = kcalloc(max_nodes + 1, sizeof(void*), GFP_ATOMIC);
-	if (c_ptr->nodes == NULL) {
-		warn("Cluster creation failure, no memory for node area\n");
-		kfree(c_ptr);
-		return NULL;
-	}
-
-	tipc_local_nodes = c_ptr->nodes;
-	c_ptr->highest_node = 0;
-
-	tipc_net.clusters[1] = c_ptr;
-	return c_ptr;
-}
-
-void tipc_cltr_delete(struct cluster *c_ptr)
-{
-	u32 n_num;
-
-	if (!c_ptr)
-		return;
-	for (n_num = 1; n_num <= c_ptr->highest_node; n_num++) {
-		tipc_node_delete(c_ptr->nodes[n_num]);
-	}
-	kfree(c_ptr->nodes);
-	kfree(c_ptr);
-}
-
-
-void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr)
-{
-	u32 n_num = tipc_node(n_ptr->addr);
-	u32 max_n_num = tipc_max_nodes;
-
-	assert(n_num > 0);
-	assert(n_num <= max_n_num);
-	assert(c_ptr->nodes[n_num] == NULL);
-	c_ptr->nodes[n_num] = n_ptr;
-	if (n_num > c_ptr->highest_node)
-		c_ptr->highest_node = n_num;
-}
-
-/**
- * tipc_cltr_broadcast - broadcast message to all nodes within cluster
- */
-
-void tipc_cltr_broadcast(struct sk_buff *buf)
-{
-	struct sk_buff *buf_copy;
-	struct cluster *c_ptr;
-	struct tipc_node *n_ptr;
-	u32 n_num;
-
-	if (tipc_mode == TIPC_NET_MODE) {
-		c_ptr = tipc_cltr_find(tipc_own_addr);
-
-		/* Send to nodes */
-		for (n_num = 1; n_num <= c_ptr->highest_node; n_num++) {
-			n_ptr = c_ptr->nodes[n_num];
-			if (n_ptr && tipc_node_has_active_links(n_ptr)) {
-				buf_copy = skb_copy(buf, GFP_ATOMIC);
-				if (buf_copy == NULL)
-					goto exit;
-				msg_set_destnode(buf_msg(buf_copy),
-						 n_ptr->addr);
-				tipc_link_send(buf_copy, n_ptr->addr,
-					       n_ptr->addr);
-			}
-		}
-	}
-exit:
-	buf_discard(buf);
-}
-
-int tipc_cltr_init(void)
-{
-	return tipc_cltr_create(tipc_own_addr) ? 0 : -ENOMEM;
-}
-
diff --git a/net/tipc/cluster.h b/net/tipc/cluster.h
deleted file mode 100644
index e4b6e4e..0000000
--- a/net/tipc/cluster.h
+++ /dev/null
@@ -1,73 +0,0 @@
-/*
- * net/tipc/cluster.h: Include file for TIPC cluster management routines
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
-#ifndef _TIPC_CLUSTER_H
-#define _TIPC_CLUSTER_H
-
-#include "addr.h"
-#include "net.h"
-
-/**
- * struct cluster - TIPC cluster structure
- * @addr: network address of cluster
- * @nodes: array of pointers to all nodes within cluster
- * @highest_node: id of highest numbered node within cluster
- */
-
-struct cluster {
-	u32 addr;
-	struct tipc_node **nodes;
-	u32 highest_node;
-};
-
-
-extern struct tipc_node **tipc_local_nodes;
-extern struct tipc_node_map tipc_cltr_bcast_nodes;
-
-struct cluster *tipc_cltr_create(u32 addr);
-void tipc_cltr_delete(struct cluster *c_ptr);
-void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr);
-void tipc_cltr_broadcast(struct sk_buff *buf);
-int tipc_cltr_init(void);
-
-static inline struct cluster *tipc_cltr_find(u32 addr)
-{
-	if (!in_own_cluster(addr))
-		return NULL;
-	return tipc_net.clusters[1];
-}
-
-#endif
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 05dc102..bc51210 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -269,19 +269,6 @@ static struct sk_buff *cfg_set_max_ports(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_max_clusters(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value != delimit(value, 1, 1))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (max clusters fixed at 1)");
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_max_nodes(void)
 {
 	u32 value;
@@ -420,9 +407,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_SUBSCR:
 		rep_tlv_buf = cfg_set_max_subscriptions();
 		break;
-	case TIPC_CMD_SET_MAX_CLUSTERS:
-		rep_tlv_buf = cfg_set_max_clusters();
-		break;
 	case TIPC_CMD_SET_MAX_NODES:
 		rep_tlv_buf = cfg_set_max_nodes();
 		break;
@@ -441,9 +425,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_SUBSCR:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_subscriptions);
 		break;
-	case TIPC_CMD_GET_MAX_CLUSTERS:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_clusters);
-		break;
 	case TIPC_CMD_GET_MAX_NODES:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_nodes);
 		break;
@@ -458,6 +439,8 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_GET_MAX_ZONES:
 	case TIPC_CMD_SET_MAX_SLAVES:
 	case TIPC_CMD_GET_MAX_SLAVES:
+	case TIPC_CMD_SET_MAX_CLUSTERS:
+	case TIPC_CMD_GET_MAX_CLUSTERS:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (obsolete command)");
 		break;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 8b7af89..b9a3ef1 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -48,10 +48,6 @@
 #include "config.h"
 
 
-#ifndef CONFIG_TIPC_CLUSTERS
-#define CONFIG_TIPC_CLUSTERS 1
-#endif
-
 #ifndef CONFIG_TIPC_NODES
 #define CONFIG_TIPC_NODES 255
 #endif
@@ -76,7 +72,6 @@ const char tipc_alphabet[] =
 /* configurable TIPC parameters */
 
 u32 tipc_own_addr;
-int tipc_max_clusters;
 int tipc_max_nodes;
 int tipc_max_ports;
 int tipc_max_subscriptions;
@@ -199,7 +194,6 @@ static int __init tipc_init(void)
 	tipc_max_publications = 10000;
 	tipc_max_subscriptions = 2000;
 	tipc_max_ports = CONFIG_TIPC_PORTS;
-	tipc_max_clusters = CONFIG_TIPC_CLUSTERS;
 	tipc_max_nodes = CONFIG_TIPC_NODES;
 	tipc_net_id = 4711;
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 8313a16..c44f955 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -184,7 +184,6 @@ void tipc_dump_dbg(struct print_buf *, const char *fmt, ...);
  */
 
 extern u32 tipc_own_addr;
-extern int tipc_max_clusters;
 extern int tipc_max_nodes;
 extern int tipc_max_ports;
 extern int tipc_max_subscriptions;
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 10ff48b..c4583fe 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -35,7 +35,7 @@
  */
 
 #include "core.h"
-#include "cluster.h"
+#include "addr.h"
 #include "link.h"
 #include "name_distr.h"
 
@@ -107,6 +107,26 @@ static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 	return buf;
 }
 
+static void named_cluster_distribute(struct sk_buff *buf)
+{
+	struct sk_buff *buf_copy;
+	struct tipc_node *n_ptr;
+	u32 n_num;
+
+	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++) {
+		n_ptr = tipc_net.nodes[n_num];
+		if (n_ptr && tipc_node_has_active_links(n_ptr)) {
+			buf_copy = skb_copy(buf, GFP_ATOMIC);
+			if (!buf_copy)
+				break;
+			msg_set_destnode(buf_msg(buf_copy), n_ptr->addr);
+			tipc_link_send(buf_copy, n_ptr->addr, n_ptr->addr);
+		}
+	}
+
+	buf_discard(buf);
+}
+
 /**
  * tipc_named_publish - tell other nodes about a new publication by this node
  */
@@ -127,8 +147,8 @@ void tipc_named_publish(struct publication *publ)
 
 	item = (struct distr_item *)msg_data(buf_msg(buf));
 	publ_to_item(item, publ);
-	dbg("tipc_named_withdraw: broadcasting publish msg\n");
-	tipc_cltr_broadcast(buf);
+	dbg("tipc_named_publish: broadcasting publish msg\n");
+	named_cluster_distribute(buf);
 }
 
 /**
@@ -152,7 +172,7 @@ void tipc_named_withdraw(struct publication *publ)
 	item = (struct distr_item *)msg_data(buf_msg(buf));
 	publ_to_item(item, publ);
 	dbg("tipc_named_withdraw: broadcasting withdraw msg\n");
-	tipc_cltr_broadcast(buf);
+	named_cluster_distribute(buf);
 }
 
 /**
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 3967f1f..3baf55e 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -112,12 +112,23 @@
 DEFINE_RWLOCK(tipc_net_lock);
 struct network tipc_net;
 
+static int net_start(void)
+{
+	tipc_net.nodes = kcalloc(tipc_max_nodes + 1,
+				 sizeof(*tipc_net.nodes), GFP_ATOMIC);
+	tipc_net.highest_node = 0;
+
+	return tipc_net.nodes ? 0 : -ENOMEM;
+}
+
 static void net_stop(void)
 {
-	u32 c_num;
+	u32 n_num;
 
-	for (c_num = 1; c_num <= tipc_max_clusters; c_num++)
-		tipc_cltr_delete(tipc_net.clusters[c_num]);
+	for (n_num = 1; n_num <= tipc_net.highest_node; n_num++)
+		tipc_node_delete(tipc_net.nodes[n_num]);
+	kfree(tipc_net.nodes);
+	tipc_net.nodes = NULL;
 }
 
 static void net_route_named_msg(struct sk_buff *buf)
@@ -218,10 +229,12 @@ int tipc_net_start(u32 addr)
 	tipc_named_reinit();
 	tipc_port_reinit();
 
-	if ((res = tipc_cltr_init()) ||
-	    (res = tipc_bclink_init())) {
+	res = net_start();
+	if (res)
+		return res;
+	res = tipc_bclink_init();
+	if (res)
 		return res;
-	}
 
 	tipc_k_signal((Handler)tipc_subscr_start, 0);
 	tipc_k_signal((Handler)tipc_cfg_init, 0);
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 6e402d9..4ae59ad 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -37,16 +37,18 @@
 #ifndef _TIPC_NET_H
 #define _TIPC_NET_H
 
-struct cluster;
+struct tipc_node;
 
 /**
  * struct network - TIPC network structure
- * @clusters: array of pointers to all clusters within zone
+ * @nodes: array of pointers to all nodes within cluster
+ * @highest_node: id of highest numbered node within cluster
  * @links: number of (unicast) links to cluster
  */
 
 struct network {
-	struct cluster *clusters[2]; /* currently limited to just 1 cluster */
+	struct tipc_node **nodes;
+	u32 highest_node;
 	u32 links;
 };
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index c47cc69..58e189b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -62,9 +62,9 @@ u32 tipc_own_tag = 0;
 
 struct tipc_node *tipc_node_create(u32 addr)
 {
-	struct cluster *c_ptr;
 	struct tipc_node *n_ptr;
 	struct tipc_node **curr_node;
+	u32 n_num;
 
 	spin_lock_bh(&node_create_lock);
 
@@ -84,21 +84,14 @@ struct tipc_node *tipc_node_create(u32 addr)
 		return NULL;
 	}
 
-	c_ptr = tipc_cltr_find(addr);
-	if (!c_ptr) {
-		c_ptr = tipc_cltr_create(addr);
-	}
-	if (!c_ptr) {
-		spin_unlock_bh(&node_create_lock);
-		kfree(n_ptr);
-		return NULL;
-	}
-
 	n_ptr->addr = addr;
 	spin_lock_init(&n_ptr->lock);
 	INIT_LIST_HEAD(&n_ptr->nsub);
-	n_ptr->owner = c_ptr;
-	tipc_cltr_attach_node(c_ptr, n_ptr);
+
+	n_num = tipc_node(addr);
+	tipc_net.nodes[n_num] = n_ptr;
+	if (n_num > tipc_net.highest_node)
+		tipc_net.highest_node = n_num;
 
 	/* Insert node into ordered list */
 	for (curr_node = &tipc_nodes; *curr_node;
@@ -115,11 +108,19 @@ struct tipc_node *tipc_node_create(u32 addr)
 
 void tipc_node_delete(struct tipc_node *n_ptr)
 {
+	u32 n_num;
+
 	if (!n_ptr)
 		return;
 
 	dbg("node %x deleted\n", n_ptr->addr);
+	n_num = tipc_node(n_ptr->addr);
+	tipc_net.nodes[n_num] = NULL;
 	kfree(n_ptr);
+
+	while (!tipc_net.nodes[tipc_net.highest_node])
+		if (--tipc_net.highest_node == 0)
+			break;
 }
 
 
@@ -324,7 +325,7 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 
 	if (n_ptr->bclink.supported) {
-		tipc_nmap_add(&tipc_cltr_bcast_nodes, n_ptr->addr);
+		tipc_nmap_add(&tipc_bcast_nmap, n_ptr->addr);
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag++;
 	}
@@ -361,13 +362,11 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		buf_discard(n_ptr->bclink.defragm);
 		n_ptr->bclink.defragm = NULL;
 	}
-	if (in_own_cluster(n_ptr->addr) && n_ptr->bclink.supported) {
-		tipc_bclink_acknowledge(n_ptr, mod(n_ptr->bclink.acked + 10000));
-	}
 
-	/* Update routing tables */
 	if (n_ptr->bclink.supported) {
-		tipc_nmap_remove(&tipc_cltr_bcast_nodes, n_ptr->addr);
+		tipc_bclink_acknowledge(n_ptr,
+					mod(n_ptr->bclink.acked + 10000));
+		tipc_nmap_remove(&tipc_bcast_nmap, n_ptr->addr);
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag--;
 	}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 3abaaa2..206a8ef 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -38,14 +38,14 @@
 #define _TIPC_NODE_H
 
 #include "node_subscr.h"
-#include "cluster.h"
+#include "addr.h"
+#include "net.h"
 #include "bearer.h"
 
 /**
  * struct tipc_node - TIPC node structure
  * @addr: network address of node
  * @lock: spinlock governing access to structure
- * @owner: pointer to cluster that node belongs to
  * @next: pointer to next node in sorted list of cluster's nodes
  * @nsub: list of "node down" subscriptions monitoring node
  * @active_links: pointers to active links to node
@@ -69,7 +69,6 @@
 struct tipc_node {
 	u32 addr;
 	spinlock_t lock;
-	struct cluster *owner;
 	struct tipc_node *next;
 	struct list_head nsub;
 	struct link *active_links[2];
@@ -108,7 +107,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 static inline struct tipc_node *tipc_node_find(u32 addr)
 {
 	if (likely(in_own_cluster(addr)))
-		return tipc_local_nodes[tipc_node(addr)];
+		return tipc_net.nodes[tipc_node(addr)];
 	return NULL;
 }
 
-- 
1.7.3.3

