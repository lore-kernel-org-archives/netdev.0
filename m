From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/26] tipc: Cosmetic changes to node subscription code
Date: Sun, 13 Mar 2011 17:33:53 -0400
Message-ID: <1300052054-7531-6-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49866 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241Ab1CMVef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:35 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Relocates the code that notifies users of node subscriptions so that
it is adjacent to the rest of the routines that implement TIPC's node
subscription capability. Renames the name table routine that is
invoked by a node subscription to better reflect its purpose and to
be consistent with other, similar name table routines.

These changes are cosmetic in nature, and do not alter the behavior
of TIPC.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c  |    7 ++++---
 net/tipc/node.c        |    9 +--------
 net/tipc/node_subscr.c |   21 ++++++++++++++++++++-
 net/tipc/node_subscr.h |    3 ++-
 4 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 1d4a18a..d58dae7 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -214,7 +214,7 @@ exit:
 }
 
 /**
- * node_is_down - remove publication associated with a failed node
+ * named_purge_publ - remove publication associated with a failed node
  *
  * Invoked for each publication issued by a newly failed node.
  * Removes publication structure from name table & deletes it.
@@ -223,7 +223,7 @@ exit:
  * publication. Nudge this item's key to distinguish it from the other.
  */
 
-static void node_is_down(struct publication *publ)
+static void named_purge_publ(struct publication *publ)
 {
 	struct publication *p;
 
@@ -269,7 +269,8 @@ void tipc_named_recv(struct sk_buff *buf)
 				tipc_nodesub_subscribe(&publ->subscr,
 						       msg_orignode(msg),
 						       publ,
-						       (net_ev_handler)node_is_down);
+						       (net_ev_handler)
+						       named_purge_publ);
 			}
 		} else if (msg_type(msg) == WITHDRAWAL) {
 			publ = tipc_nametbl_remove_publ(ntohl(item->type),
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 8926caa..713ab5d 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -327,7 +327,6 @@ static void node_cleanup_finished(unsigned long node_addr)
 
 static void node_lost_contact(struct tipc_node *n_ptr)
 {
-	struct tipc_node_subscr *ns;
 	char addr_string[16];
 	u32 i;
 
@@ -365,13 +364,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	}
 
 	/* Notify subscribers */
-	list_for_each_entry(ns, &n_ptr->nsub, nodesub_list) {
-		if (ns->handle_node_down) {
-			tipc_k_signal((Handler)ns->handle_node_down,
-				      (unsigned long)ns->usr_handle);
-			ns->handle_node_down = NULL;
-		}
-	}
+	tipc_nodesub_notify(n_ptr);
 
 	/* Prevent re-contact with node until all cleanup is done */
 
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 018a553..c3c2815 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -2,7 +2,7 @@
  * net/tipc/node_subscr.c: TIPC "node down" subscription handling
  *
  * Copyright (c) 1995-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -76,3 +76,22 @@ void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
 	list_del_init(&node_sub->nodesub_list);
 	tipc_node_unlock(node_sub->node);
 }
+
+/**
+ * tipc_nodesub_notify - notify subscribers that a node is unreachable
+ *
+ * Note: node is locked by caller
+ */
+
+void tipc_nodesub_notify(struct tipc_node *node)
+{
+	struct tipc_node_subscr *ns;
+
+	list_for_each_entry(ns, &node->nsub, nodesub_list) {
+		if (ns->handle_node_down) {
+			tipc_k_signal((Handler)ns->handle_node_down,
+				      (unsigned long)ns->usr_handle);
+			ns->handle_node_down = NULL;
+		}
+	}
+}
diff --git a/net/tipc/node_subscr.h b/net/tipc/node_subscr.h
index 006ed73..4bc2ca0 100644
--- a/net/tipc/node_subscr.h
+++ b/net/tipc/node_subscr.h
@@ -2,7 +2,7 @@
  * net/tipc/node_subscr.h: Include file for TIPC "node down" subscription handling
  *
  * Copyright (c) 1995-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -59,5 +59,6 @@ struct tipc_node_subscr {
 void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 			    void *usr_handle, net_ev_handler handle_down);
 void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub);
+void tipc_nodesub_notify(struct tipc_node *node);
 
 #endif
-- 
1.7.3.3

