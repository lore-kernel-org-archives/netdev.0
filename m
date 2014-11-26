From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 01/11] tipc: remove node
	subscription infrastructure
Date: Wed, 26 Nov 2014 11:41:45 +0800
Message-ID: <1416973315-6047-2-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The node subscribe infrastructure represents a virtual base class, so
its users, such as struct tipc_port and struct publication, can derive
its implemented functionalities. However, after the removal of struct
tipc_port, struct publication is left as its only single user now. So
defining an abstract infrastructure for one user becomes no longer
reasonable. If corresponding new functions associated with the
infrastructure are moved to name_table.c file, the node subscription
infrastructure can be removed as well.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/Makefile      |    4 +-
 net/tipc/name_distr.c  |   52 ++++++++++++++++++++++----
 net/tipc/name_distr.h  |    1 +
 net/tipc/name_table.c  |    2 +-
 net/tipc/name_table.h  |    6 +--
 net/tipc/node.c        |    6 +--
 net/tipc/node.h        |    5 +--
 net/tipc/node_subscr.c |   96 ------------------------------------------------
 net/tipc/node_subscr.h |   63 -------------------------------
 9 files changed, 56 insertions(+), 179 deletions(-)
 delete mode 100644 net/tipc/node_subscr.c
 delete mode 100644 net/tipc/node_subscr.h

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index b8a13ca..333e459 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -7,8 +7,8 @@ obj-$(CONFIG_TIPC) := tipc.o
 tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   core.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
-	   netlink.o node.o node_subscr.o \
-	   socket.o log.o eth_media.o server.o
+	   netlink.o node.o socket.o log.o eth_media.o \
+	   server.o
 
 tipc-$(CONFIG_TIPC_MEDIA_IB)	+= ib_media.o
 tipc-$(CONFIG_SYSCTL)		+= sysctl.o
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 376d2bb..6c2638d 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -250,13 +250,45 @@ void tipc_named_node_up(u32 dnode)
 	tipc_link_xmit(buf_chain, dnode, dnode);
 }
 
+static void tipc_publ_subscribe(struct publication *publ, u32 addr)
+{
+	struct tipc_node *node;
+
+	if (in_own_node(addr))
+		return;
+
+	node = tipc_node_find(addr);
+	if (!node) {
+		pr_warn("Node subscription rejected, unknown node 0x%x\n",
+			addr);
+		return;
+	}
+
+	tipc_node_lock(node);
+	list_add_tail(&publ->nodesub_list, &node->publ_list);
+	tipc_node_unlock(node);
+}
+
+static void tipc_publ_unsubscribe(struct publication *publ, u32 addr)
+{
+	struct tipc_node *node;
+
+	node = tipc_node_find(addr);
+	if (!node)
+		return;
+
+	tipc_node_lock(node);
+	list_del_init(&publ->nodesub_list);
+	tipc_node_unlock(node);
+}
+
 /**
- * named_purge_publ - remove publication associated with a failed node
+ * tipc_publ_purge - remove publication associated with a failed node
  *
  * Invoked for each publication issued by a newly failed node.
  * Removes publication structure from name table & deletes it.
  */
-static void named_purge_publ(struct publication *publ)
+static void tipc_publ_purge(struct publication *publ, u32 addr)
 {
 	struct publication *p;
 
@@ -264,7 +296,7 @@ static void named_purge_publ(struct publication *publ)
 	p = tipc_nametbl_remove_publ(publ->type, publ->lower,
 				     publ->node, publ->ref, publ->key);
 	if (p)
-		tipc_nodesub_unsubscribe(&p->subscr);
+		tipc_publ_unsubscribe(p, addr);
 	write_unlock_bh(&tipc_nametbl_lock);
 
 	if (p != publ) {
@@ -277,6 +309,14 @@ static void named_purge_publ(struct publication *publ)
 	kfree(p);
 }
 
+void tipc_publ_notify(struct list_head *nsub_list, u32 addr)
+{
+	struct publication *publ, *tmp;
+
+	list_for_each_entry_safe(publ, tmp, nsub_list, nodesub_list)
+		tipc_publ_purge(publ, addr);
+}
+
 /**
  * tipc_update_nametbl - try to process a nametable update and notify
  *			 subscribers
@@ -294,9 +334,7 @@ static bool tipc_update_nametbl(struct distr_item *i, u32 node, u32 dtype)
 						TIPC_CLUSTER_SCOPE, node,
 						ntohl(i->ref), ntohl(i->key));
 		if (publ) {
-			tipc_nodesub_subscribe(&publ->subscr, node, publ,
-					       (net_ev_handler)
-					       named_purge_publ);
+			tipc_publ_subscribe(publ, node);
 			return true;
 		}
 	} else if (dtype == WITHDRAWAL) {
@@ -304,7 +342,7 @@ static bool tipc_update_nametbl(struct distr_item *i, u32 node, u32 dtype)
 						node, ntohl(i->ref),
 						ntohl(i->key));
 		if (publ) {
-			tipc_nodesub_unsubscribe(&publ->subscr);
+			tipc_publ_unsubscribe(publ, node);
 			kfree(publ);
 			return true;
 		}
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index b9e75fe..cef55ce 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -74,5 +74,6 @@ void tipc_named_node_up(u32 dnode);
 void tipc_named_rcv(struct sk_buff *buf);
 void tipc_named_reinit(void);
 void tipc_named_process_backlog(void);
+void tipc_publ_notify(struct list_head *nsub_list, u32 addr);
 
 #endif
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 7cfb7a4..772be1c 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -144,7 +144,7 @@ static struct publication *publ_create(u32 type, u32 lower, u32 upper,
 	publ->key = key;
 	INIT_LIST_HEAD(&publ->local_list);
 	INIT_LIST_HEAD(&publ->pport_list);
-	INIT_LIST_HEAD(&publ->subscr.nodesub_list);
+	INIT_LIST_HEAD(&publ->nodesub_list);
 	return publ;
 }
 
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index b38ebec..c628778 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -37,8 +37,6 @@
 #ifndef _TIPC_NAME_TABLE_H
 #define _TIPC_NAME_TABLE_H
 
-#include "node_subscr.h"
-
 struct tipc_subscription;
 struct tipc_port_list;
 
@@ -56,7 +54,7 @@ struct tipc_port_list;
  * @node: network address of publishing port's node
  * @ref: publishing port
  * @key: publication key
- * @subscr: subscription to "node down" event (for off-node publications only)
+ * @nodesub_list: subscription to "node down" event (off-node publication only)
  * @local_list: adjacent entries in list of publications made by this node
  * @pport_list: adjacent entries in list of publications made by this port
  * @node_list: adjacent matching name seq publications with >= node scope
@@ -73,7 +71,7 @@ struct publication {
 	u32 node;
 	u32 ref;
 	u32 key;
-	struct tipc_node_subscr subscr;
+	struct list_head nodesub_list;
 	struct list_head local_list;
 	struct list_head pport_list;
 	struct list_head node_list;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 82e5edd..17b8092 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -113,7 +113,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 	spin_lock_init(&n_ptr->lock);
 	INIT_HLIST_NODE(&n_ptr->hash);
 	INIT_LIST_HEAD(&n_ptr->list);
-	INIT_LIST_HEAD(&n_ptr->nsub);
+	INIT_LIST_HEAD(&n_ptr->publ_list);
 	INIT_LIST_HEAD(&n_ptr->conn_sks);
 	__skb_queue_head_init(&n_ptr->waiting_sks);
 
@@ -574,7 +574,7 @@ void tipc_node_unlock(struct tipc_node *node)
 		skb_queue_splice_init(&node->waiting_sks, &waiting_sks);
 
 	if (flags & TIPC_NOTIFY_NODE_DOWN) {
-		list_replace_init(&node->nsub, &nsub_list);
+		list_replace_init(&node->publ_list, &nsub_list);
 		list_replace_init(&node->conn_sks, &conn_sks);
 	}
 	node->action_flags &= ~(TIPC_WAKEUP_USERS | TIPC_NOTIFY_NODE_DOWN |
@@ -591,7 +591,7 @@ void tipc_node_unlock(struct tipc_node *node)
 		tipc_node_abort_sock_conns(&conn_sks);
 
 	if (!list_empty(&nsub_list))
-		tipc_nodesub_notify(&nsub_list);
+		tipc_publ_notify(&nsub_list, addr);
 
 	if (flags & TIPC_WAKEUP_BCAST_USERS)
 		tipc_bclink_wakeup_users();
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 005fbce..f199451 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -37,7 +37,6 @@
 #ifndef _TIPC_NODE_H
 #define _TIPC_NODE_H
 
-#include "node_subscr.h"
 #include "addr.h"
 #include "net.h"
 #include "bearer.h"
@@ -104,7 +103,7 @@ struct tipc_node_bclink {
  * @link_cnt: number of links to node
  * @signature: node instance identifier
  * @link_id: local and remote bearer ids of changing link, if any
- * @nsub: list of "node down" subscriptions monitoring node
+ * @publ_list: list of publications
  * @rcu: rcu struct for tipc_node
  */
 struct tipc_node {
@@ -121,7 +120,7 @@ struct tipc_node {
 	int working_links;
 	u32 signature;
 	u32 link_id;
-	struct list_head nsub;
+	struct list_head publ_list;
 	struct sk_buff_head waiting_sks;
 	struct list_head conn_sks;
 	struct rcu_head rcu;
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
deleted file mode 100644
index 2d13eea..0000000
--- a/net/tipc/node_subscr.c
+++ /dev/null
@@ -1,96 +0,0 @@
-/*
- * net/tipc/node_subscr.c: TIPC "node down" subscription handling
- *
- * Copyright (c) 1995-2006, Ericsson AB
- * Copyright (c) 2005, 2010-2011, Wind River Systems
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
-#include "node_subscr.h"
-#include "node.h"
-
-/**
- * tipc_nodesub_subscribe - create "node down" subscription for specified node
- */
-void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
-			    void *usr_handle, net_ev_handler handle_down)
-{
-	if (in_own_node(addr)) {
-		node_sub->node = NULL;
-		return;
-	}
-
-	node_sub->node = tipc_node_find(addr);
-	if (!node_sub->node) {
-		pr_warn("Node subscription rejected, unknown node 0x%x\n",
-			addr);
-		return;
-	}
-	node_sub->handle_node_down = handle_down;
-	node_sub->usr_handle = usr_handle;
-
-	tipc_node_lock(node_sub->node);
-	list_add_tail(&node_sub->nodesub_list, &node_sub->node->nsub);
-	tipc_node_unlock(node_sub->node);
-}
-
-/**
- * tipc_nodesub_unsubscribe - cancel "node down" subscription (if any)
- */
-void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
-{
-	if (!node_sub->node)
-		return;
-
-	tipc_node_lock(node_sub->node);
-	list_del_init(&node_sub->nodesub_list);
-	tipc_node_unlock(node_sub->node);
-}
-
-/**
- * tipc_nodesub_notify - notify subscribers that a node is unreachable
- *
- * Note: node is locked by caller
- */
-void tipc_nodesub_notify(struct list_head *nsub_list)
-{
-	struct tipc_node_subscr *ns, *safe;
-	net_ev_handler handle_node_down;
-
-	list_for_each_entry_safe(ns, safe, nsub_list, nodesub_list) {
-		handle_node_down = ns->handle_node_down;
-		if (handle_node_down) {
-			ns->handle_node_down = NULL;
-			handle_node_down(ns->usr_handle);
-		}
-	}
-}
diff --git a/net/tipc/node_subscr.h b/net/tipc/node_subscr.h
deleted file mode 100644
index d91b8cc..0000000
--- a/net/tipc/node_subscr.h
+++ /dev/null
@@ -1,63 +0,0 @@
-/*
- * net/tipc/node_subscr.h: Include file for TIPC "node down" subscription handling
- *
- * Copyright (c) 1995-2006, Ericsson AB
- * Copyright (c) 2005, 2010-2011, Wind River Systems
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
-#ifndef _TIPC_NODE_SUBSCR_H
-#define _TIPC_NODE_SUBSCR_H
-
-#include "addr.h"
-
-typedef void (*net_ev_handler) (void *usr_handle);
-
-/**
- * struct tipc_node_subscr - "node down" subscription entry
- * @node: ptr to node structure of interest (or NULL, if none)
- * @handle_node_down: routine to invoke when node fails
- * @usr_handle: argument to pass to routine when node fails
- * @nodesub_list: adjacent entries in list of subscriptions for the node
- */
-struct tipc_node_subscr {
-	struct tipc_node *node;
-	net_ev_handler handle_node_down;
-	void *usr_handle;
-	struct list_head nodesub_list;
-};
-
-void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
-			    void *usr_handle, net_ev_handler handle_down);
-void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub);
-void tipc_nodesub_notify(struct list_head *nsub_list);
-
-#endif
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
