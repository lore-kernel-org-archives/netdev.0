From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/20] tipc: Convert name table publication lists to standard kernel lists
Date: Fri, 24 Jun 2011 18:07:17 -0400
Message-ID: <1308953247-25266-11-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34387 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756945Ab1FXWHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:48 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies the main circular linked lists of publications used in TIPC's
name table to use the standard kernel linked list type. This change
simplifies the deletion of an existing publication by eliminating
the need to search up to three lists to locate the publication.
The use of standard list routines also helps improve the readability
of the name table code by make it clearer what each list operation
being performed is actually doing.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |  240 +++++++++++++++++--------------------------------
 net/tipc/name_table.h |   14 ++--
 2 files changed, 90 insertions(+), 164 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 9cd58f8..7d85cc1 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -2,7 +2,7 @@
  * net/tipc/name_table.c: TIPC name table code
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2004-2008, Wind River Systems
+ * Copyright (c) 2004-2008, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -58,9 +58,9 @@ static int tipc_nametbl_size = 1024;		/* must be a power of 2 */
  */
 
 struct name_info {
-	struct publication *node_list;
-	struct publication *cluster_list;
-	struct publication *zone_list;
+	struct list_head node_list;
+	struct list_head cluster_list;
+	struct list_head zone_list;
 	u32 node_list_size;
 	u32 cluster_list_size;
 	u32 zone_list_size;
@@ -311,6 +311,10 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 			return NULL;
 		}
 
+		INIT_LIST_HEAD(&info->node_list);
+		INIT_LIST_HEAD(&info->cluster_list);
+		INIT_LIST_HEAD(&info->zone_list);
+
 		/* Insert new sub-sequence */
 
 		sseq = &nseq->sseqs[inspos];
@@ -330,33 +334,17 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	if (!publ)
 		return NULL;
 
+	list_add(&publ->zone_list, &info->zone_list);
 	info->zone_list_size++;
-	if (!info->zone_list)
-		info->zone_list = publ->zone_list_next = publ;
-	else {
-		publ->zone_list_next = info->zone_list->zone_list_next;
-		info->zone_list->zone_list_next = publ;
-	}
 
 	if (in_own_cluster(node)) {
+		list_add(&publ->cluster_list, &info->cluster_list);
 		info->cluster_list_size++;
-		if (!info->cluster_list)
-			info->cluster_list = publ->cluster_list_next = publ;
-		else {
-			publ->cluster_list_next =
-			info->cluster_list->cluster_list_next;
-			info->cluster_list->cluster_list_next = publ;
-		}
 	}
 
 	if (node == tipc_own_addr) {
+		list_add(&publ->node_list, &info->node_list);
 		info->node_list_size++;
-		if (!info->node_list)
-			info->node_list = publ->node_list_next = publ;
-		else {
-			publ->node_list_next = info->node_list->node_list_next;
-			info->node_list->node_list_next = publ;
-		}
 	}
 
 	/*
@@ -390,8 +378,6 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 						    u32 node, u32 ref, u32 key)
 {
 	struct publication *publ;
-	struct publication *curr;
-	struct publication *prev;
 	struct sub_seq *sseq = nameseq_find_subseq(nseq, inst);
 	struct name_info *info;
 	struct sub_seq *free;
@@ -403,96 +389,38 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 
 	info = sseq->info;
 
-	/* Remove publication from zone scope list */
+	/* Locate publication, if it exists */
 
-	prev = info->zone_list;
-	publ = info->zone_list->zone_list_next;
-	while ((publ->key != key) || (publ->ref != ref) ||
-	       (publ->node && (publ->node != node))) {
-		prev = publ;
-		publ = publ->zone_list_next;
-		if (prev == info->zone_list) {
+	list_for_each_entry(publ, &info->zone_list, zone_list) {
+		if ((publ->key == key) && (publ->ref == ref) &&
+		    (!publ->node || (publ->node == node)))
+			goto found;
+	}
+	return NULL;
 
-			/* Prevent endless loop if publication not found */
+found:
+	/* Remove publication from zone scope list */
 
-			return NULL;
-		}
-	}
-	if (publ != info->zone_list)
-		prev->zone_list_next = publ->zone_list_next;
-	else if (publ->zone_list_next != publ) {
-		prev->zone_list_next = publ->zone_list_next;
-		info->zone_list = publ->zone_list_next;
-	} else {
-		info->zone_list = NULL;
-	}
+	list_del(&publ->zone_list);
 	info->zone_list_size--;
 
 	/* Remove publication from cluster scope list, if present */
 
 	if (in_own_cluster(node)) {
-		prev = info->cluster_list;
-		curr = info->cluster_list->cluster_list_next;
-		while (curr != publ) {
-			prev = curr;
-			curr = curr->cluster_list_next;
-			if (prev == info->cluster_list) {
-
-				/* Prevent endless loop for malformed list */
-
-				err("Unable to de-list cluster publication\n"
-				    "{%u%u}, node=0x%x, ref=%u, key=%u)\n",
-				    publ->type, publ->lower, publ->node,
-				    publ->ref, publ->key);
-				goto end_cluster;
-			}
-		}
-		if (publ != info->cluster_list)
-			prev->cluster_list_next = publ->cluster_list_next;
-		else if (publ->cluster_list_next != publ) {
-			prev->cluster_list_next = publ->cluster_list_next;
-			info->cluster_list = publ->cluster_list_next;
-		} else {
-			info->cluster_list = NULL;
-		}
+		list_del(&publ->cluster_list);
 		info->cluster_list_size--;
 	}
-end_cluster:
 
 	/* Remove publication from node scope list, if present */
 
 	if (node == tipc_own_addr) {
-		prev = info->node_list;
-		curr = info->node_list->node_list_next;
-		while (curr != publ) {
-			prev = curr;
-			curr = curr->node_list_next;
-			if (prev == info->node_list) {
-
-				/* Prevent endless loop for malformed list */
-
-				err("Unable to de-list node publication\n"
-				    "{%u%u}, node=0x%x, ref=%u, key=%u)\n",
-				    publ->type, publ->lower, publ->node,
-				    publ->ref, publ->key);
-				goto end_node;
-			}
-		}
-		if (publ != info->node_list)
-			prev->node_list_next = publ->node_list_next;
-		else if (publ->node_list_next != publ) {
-			prev->node_list_next = publ->node_list_next;
-			info->node_list = publ->node_list_next;
-		} else {
-			info->node_list = NULL;
-		}
+		list_del(&publ->node_list);
 		info->node_list_size--;
 	}
-end_node:
 
 	/* Contract subseq list if no more publications for that subseq */
 
-	if (!info->zone_list) {
+	if (list_empty(&info->zone_list)) {
 		kfree(info);
 		free = &nseq->sseqs[nseq->first_free--];
 		memmove(sseq, sseq + 1, (free - (sseq + 1)) * sizeof(*sseq));
@@ -530,12 +458,12 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s
 		return;
 
 	while (sseq != &nseq->sseqs[nseq->first_free]) {
-		struct publication *zl = sseq->info->zone_list;
-		if (zl && tipc_subscr_overlap(s, sseq->lower, sseq->upper)) {
-			struct publication *crs = zl;
+		if (tipc_subscr_overlap(s, sseq->lower, sseq->upper)) {
+			struct publication *crs;
+			struct name_info *info = sseq->info;
 			int must_report = 1;
 
-			do {
+			list_for_each_entry(crs, &info->zone_list, zone_list) {
 				tipc_subscr_report_overlap(s,
 							   sseq->lower,
 							   sseq->upper,
@@ -544,8 +472,7 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s
 							   crs->node,
 							   must_report);
 				must_report = 0;
-				crs = crs->zone_list_next;
-			} while (crs != zl);
+			}
 		}
 		sseq++;
 	}
@@ -616,9 +543,9 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 {
 	struct sub_seq *sseq;
 	struct name_info *info;
-	struct publication *publ = NULL;
+	struct publication *publ;
 	struct name_seq *seq;
-	u32 ref;
+	u32 ref = 0;
 
 	if (!tipc_in_scope(*destnode, tipc_own_addr))
 		return 0;
@@ -635,52 +562,56 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 
 	/* Closest-First Algorithm: */
 	if (likely(!*destnode)) {
-		publ = info->node_list;
-		if (publ) {
-			info->node_list = publ->node_list_next;
-found:
-			ref = publ->ref;
-			*destnode = publ->node;
-			spin_unlock_bh(&seq->lock);
-			read_unlock_bh(&tipc_nametbl_lock);
-			return ref;
-		}
-		publ = info->cluster_list;
-		if (publ) {
-			info->cluster_list = publ->cluster_list_next;
-			goto found;
-		}
-		publ = info->zone_list;
-		if (publ) {
-			info->zone_list = publ->zone_list_next;
-			goto found;
-		}
+		if (!list_empty(&info->node_list)) {
+			publ = list_first_entry(&info->node_list,
+						struct publication,
+						node_list);
+			list_move_tail(&publ->node_list,
+				       &info->node_list);
+		} else if (!list_empty(&info->cluster_list)) {
+			publ = list_first_entry(&info->cluster_list,
+						struct publication,
+						cluster_list);
+			list_move_tail(&publ->cluster_list,
+				       &info->cluster_list);
+		} else if (!list_empty(&info->zone_list)) {
+			publ = list_first_entry(&info->zone_list,
+						struct publication,
+						zone_list);
+			list_move_tail(&publ->zone_list,
+				       &info->zone_list);
+		} else
+			goto no_match;
 	}
 
 	/* Round-Robin Algorithm: */
 	else if (*destnode == tipc_own_addr) {
-		publ = info->node_list;
-		if (publ) {
-			info->node_list = publ->node_list_next;
-			goto found;
-		}
+		if (list_empty(&info->node_list))
+			goto no_match;
+		publ = list_first_entry(&info->node_list, struct publication,
+					node_list);
+		list_move_tail(&publ->node_list, &info->node_list);
 	} else if (in_own_cluster(*destnode)) {
-		publ = info->cluster_list;
-		if (publ) {
-			info->cluster_list = publ->cluster_list_next;
-			goto found;
-		}
+		if (list_empty(&info->cluster_list))
+			goto no_match;
+		publ = list_first_entry(&info->cluster_list, struct publication,
+					cluster_list);
+		list_move_tail(&publ->cluster_list, &info->cluster_list);
 	} else {
-		publ = info->zone_list;
-		if (publ) {
-			info->zone_list = publ->zone_list_next;
-			goto found;
-		}
+		if (list_empty(&info->zone_list))
+			goto no_match;
+		publ = list_first_entry(&info->zone_list, struct publication,
+					zone_list);
+		list_move_tail(&publ->zone_list, &info->zone_list);
 	}
+
+	ref = publ->ref;
+	*destnode = publ->node;
+no_match:
 	spin_unlock_bh(&seq->lock);
 not_found:
 	read_unlock_bh(&tipc_nametbl_lock);
-	return 0;
+	return ref;
 }
 
 /**
@@ -721,13 +652,9 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 			break;
 
 		info = sseq->info;
-		publ = info->node_list;
-		if (publ) {
-			do {
-				if (publ->scope <= limit)
-					tipc_port_list_add(dports, publ->ref);
-				publ = publ->node_list_next;
-			} while (publ != info->node_list);
+		list_for_each_entry(publ, &info->node_list, node_list) {
+			if (publ->scope <= limit)
+				tipc_port_list_add(dports, publ->ref);
 		}
 
 		if (info->cluster_list_size != info->node_list_size)
@@ -868,16 +795,19 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 {
 	char portIdStr[27];
 	const char *scope_str[] = {"", " zone", " cluster", " node"};
-	struct publication *publ = sseq->info->zone_list;
+	struct publication *publ;
+	struct name_info *info;
 
 	tipc_printf(buf, "%-10u %-10u ", sseq->lower, sseq->upper);
 
-	if (depth == 2 || !publ) {
+	if (depth == 2) {
 		tipc_printf(buf, "\n");
 		return;
 	}
 
-	do {
+	info = sseq->info;
+
+	list_for_each_entry(publ, &info->zone_list, zone_list) {
 		sprintf(portIdStr, "<%u.%u.%u:%u>",
 			 tipc_zone(publ->node), tipc_cluster(publ->node),
 			 tipc_node(publ->node), publ->ref);
@@ -886,13 +816,9 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 			tipc_printf(buf, "%-10u %s", publ->key,
 				    scope_str[publ->scope]);
 		}
-
-		publ = publ->zone_list_next;
-		if (publ == sseq->info->zone_list)
-			break;
-
-		tipc_printf(buf, "\n%33s", " ");
-	} while (1);
+		if (!list_is_last(&publ->zone_list, &info->zone_list))
+			tipc_printf(buf, "\n%33s", " ");
+	};
 
 	tipc_printf(buf, "\n");
 }
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index d228bd6..62d77e5 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -2,7 +2,7 @@
  * net/tipc/name_table.h: Include file for TIPC name table code
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -61,9 +61,9 @@ struct port_list;
  * @subscr: subscription to "node down" event (for off-node publications only)
  * @local_list: adjacent entries in list of publications made by this node
  * @pport_list: adjacent entries in list of publications made by this port
- * @node_list: next matching name seq publication with >= node scope
- * @cluster_list: next matching name seq publication with >= cluster scope
- * @zone_list: next matching name seq publication with >= zone scope
+ * @node_list: adjacent matching name seq publications with >= node scope
+ * @cluster_list: adjacent matching name seq publications with >= cluster scope
+ * @zone_list: adjacent matching name seq publications with >= zone scope
  *
  * Note that the node list, cluster list, and zone list are circular lists.
  */
@@ -79,9 +79,9 @@ struct publication {
 	struct tipc_node_subscr subscr;
 	struct list_head local_list;
 	struct list_head pport_list;
-	struct publication *node_list_next;
-	struct publication *cluster_list_next;
-	struct publication *zone_list_next;
+	struct list_head node_list;
+	struct list_head cluster_list;
+	struct list_head zone_list;
 };
 
 
-- 
1.7.4.4

