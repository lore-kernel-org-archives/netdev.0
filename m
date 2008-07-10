From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 7/7 net-next-2.6] tipc: Optimization to multicast name lookup algorithm
Date: Thu, 10 Jul 2008 17:26:11 -0400
Message-ID: <1215725171-10094-8-git-send-email-allan.stephens@windriver.com>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33135 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995AbYGJVZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:13 -0400
In-Reply-To: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simplifies and speeds up TIPC's algorithm for identifying
on-node and off-node destinations that overlap a multicast name
sequence range.  Rather than traversing the list of all known name
publications within the cluster, it now traverses the (potentially
much shorter) list of name publications made by the node itself, and
determines if any off-node destinations exist by comparing the sizes
of the two lists.  (Since the node list must be a subset of the
cluster list, a difference in sizes means that at least one off-node
destination must exist.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/name_table.c |   43 ++++++++++++++++++++++++++++++-------------
 1 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 1e53b0c..cd72e22 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -2,7 +2,7 @@
  * net/tipc/name_table.c: TIPC name table code
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2008, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -52,9 +52,16 @@ static int tipc_nametbl_size = 1024;		/* must be a power of 2 */
  * struct sub_seq - container for all published instances of a name sequence
  * @lower: name sequence lower bound
  * @upper: name sequence upper bound
- * @node_list: circular list of matching publications with >= node scope
- * @cluster_list: circular list of matching publications with >= cluster scope
- * @zone_list: circular list of matching publications with >= zone scope
+ * @node_list: circular list of publications made by own node
+ * @cluster_list: circular list of publications made by own cluster
+ * @zone_list: circular list of publications made by own zone
+ * @node_list_size: number of entries in "node_list"
+ * @cluster_list_size: number of entries in "cluster_list"
+ * @zone_list_size: number of entries in "zone_list"
+ *
+ * Note: The zone list always contains at least one entry, since all
+ *       publications of the associated name sequence belong to it.
+ *       (The cluster and node lists may be empty.)
  */
 
 struct sub_seq {
@@ -63,6 +70,9 @@ struct sub_seq {
 	struct publication *node_list;
 	struct publication *cluster_list;
 	struct publication *zone_list;
+	u32 node_list_size;
+	u32 cluster_list_size;
+	u32 zone_list_size;
 };
 
 /**
@@ -317,6 +327,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	dbg("inserting publ %p, node=0x%x publ->node=0x%x, subscr->node=%p\n",
 	    publ, node, publ->node, publ->subscr.node);
 
+	sseq->zone_list_size++;
 	if (!sseq->zone_list)
 		sseq->zone_list = publ->zone_list_next = publ;
 	else {
@@ -325,6 +336,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	}
 
 	if (in_own_cluster(node)) {
+		sseq->cluster_list_size++;
 		if (!sseq->cluster_list)
 			sseq->cluster_list = publ->cluster_list_next = publ;
 		else {
@@ -335,6 +347,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	}
 
 	if (node == tipc_own_addr) {
+		sseq->node_list_size++;
 		if (!sseq->node_list)
 			sseq->node_list = publ->node_list_next = publ;
 		else {
@@ -411,6 +424,7 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 	} else {
 		sseq->zone_list = NULL;
 	}
+	sseq->zone_list_size--;
 
 	/* Remove publication from cluster scope list, if present */
 
@@ -439,6 +453,7 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 		} else {
 			sseq->cluster_list = NULL;
 		}
+		sseq->cluster_list_size--;
 	}
 end_cluster:
 
@@ -469,6 +484,7 @@ end_cluster:
 		} else {
 			sseq->node_list = NULL;
 		}
+		sseq->node_list_size--;
 	}
 end_node:
 
@@ -709,17 +725,18 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 
 		if (sseq->lower > upper)
 			break;
-		publ = sseq->cluster_list;
-		if (publ)
+
+		publ = sseq->node_list;
+		if (publ) {
 			do {
-				if (publ->scope > limit)
-					/* ignore out-of-scope publication */ ;
-				else if (publ->node == tipc_own_addr)
+				if (publ->scope <= limit)
 					tipc_port_list_add(dports, publ->ref);
-				else
-					res = 1;
-				publ = publ->cluster_list_next;
-			} while (publ != sseq->cluster_list);
+				publ = publ->node_list_next;
+			} while (publ != sseq->node_list);
+		}
+
+		if (sseq->cluster_list_size != sseq->node_list_size)
+			res = 1;
 	}
 
 	spin_unlock_bh(&seq->lock);
-- 
1.5.4.3

