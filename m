From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/20] tipc: Partition name table instance array info into two parts
Date: Fri, 24 Jun 2011 18:07:16 -0400
Message-ID: <1308953247-25266-10-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34382 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab1FXWHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:47 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies the name table array structure that contains the name
sequence instances for a given name type so that the publication
lists associated with a given instance are stored in a dynamically
allocated structure, rather than being embedded within the array
entry itself. This change is being done for several reasons:

1) It reduces the amount of data that needs to be copied whenever
a given array is expanded or contracted to accommodate the first
publication of a new name sequence or the removal of the last
publication of an existing name sequence.

2) It reduces the amount of memory associated with array entries that
are currently unused.

3) It facilitates the upcoming conversion of the publication lists
from TIPC-specific circular lists to standard kernel lists. (Standard
lists cannot be used with the former array structure because the
relocation of array entries during array expansion and contraction
would corrupt the lists.)

Note that, aside from introducing a small amount of code to dynamically
allocate and free the structure that now holds publication list info,
this change is largely a simple renaming exercise that replaces
references to "sseq->LIST" with "sseq->info->LIST" (or "info->LIST").

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |  150 +++++++++++++++++++++++++++++--------------------
 1 files changed, 89 insertions(+), 61 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 205ed4a..9cd58f8 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -44,9 +44,7 @@
 static int tipc_nametbl_size = 1024;		/* must be a power of 2 */
 
 /**
- * struct sub_seq - container for all published instances of a name sequence
- * @lower: name sequence lower bound
- * @upper: name sequence upper bound
+ * struct name_info - name sequence publication info
  * @node_list: circular list of publications made by own node
  * @cluster_list: circular list of publications made by own cluster
  * @zone_list: circular list of publications made by own zone
@@ -59,9 +57,7 @@ static int tipc_nametbl_size = 1024;		/* must be a power of 2 */
  *       (The cluster and node lists may be empty.)
  */
 
-struct sub_seq {
-	u32 lower;
-	u32 upper;
+struct name_info {
 	struct publication *node_list;
 	struct publication *cluster_list;
 	struct publication *zone_list;
@@ -71,6 +67,19 @@ struct sub_seq {
 };
 
 /**
+ * struct sub_seq - container for all published instances of a name sequence
+ * @lower: name sequence lower bound
+ * @upper: name sequence upper bound
+ * @info: pointer to name sequence publication info
+ */
+
+struct sub_seq {
+	u32 lower;
+	u32 upper;
+	struct name_info *info;
+};
+
+/**
  * struct name_seq - container for all published instances of a name type
  * @type: 32 bit 'type' value for name sequence
  * @sseq: pointer to dynamically-sized array of sub-sequences of this 'type';
@@ -246,6 +255,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	struct subscription *st;
 	struct publication *publ;
 	struct sub_seq *sseq;
+	struct name_info *info;
 	int created_subseq = 0;
 
 	sseq = nameseq_find_subseq(nseq, lower);
@@ -258,6 +268,8 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 			     type, lower, upper);
 			return NULL;
 		}
+
+		info = sseq->info;
 	} else {
 		u32 inspos;
 		struct sub_seq *freesseq;
@@ -292,6 +304,13 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 			nseq->alloc *= 2;
 		}
 
+		info = kzalloc(sizeof(*info), GFP_ATOMIC);
+		if (!info) {
+			warn("Cannot publish {%u,%u,%u}, no memory\n",
+			     type, lower, upper);
+			return NULL;
+		}
+
 		/* Insert new sub-sequence */
 
 		sseq = &nseq->sseqs[inspos];
@@ -301,6 +320,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		nseq->first_free++;
 		sseq->lower = lower;
 		sseq->upper = upper;
+		sseq->info = info;
 		created_subseq = 1;
 	}
 
@@ -310,32 +330,32 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	if (!publ)
 		return NULL;
 
-	sseq->zone_list_size++;
-	if (!sseq->zone_list)
-		sseq->zone_list = publ->zone_list_next = publ;
+	info->zone_list_size++;
+	if (!info->zone_list)
+		info->zone_list = publ->zone_list_next = publ;
 	else {
-		publ->zone_list_next = sseq->zone_list->zone_list_next;
-		sseq->zone_list->zone_list_next = publ;
+		publ->zone_list_next = info->zone_list->zone_list_next;
+		info->zone_list->zone_list_next = publ;
 	}
 
 	if (in_own_cluster(node)) {
-		sseq->cluster_list_size++;
-		if (!sseq->cluster_list)
-			sseq->cluster_list = publ->cluster_list_next = publ;
+		info->cluster_list_size++;
+		if (!info->cluster_list)
+			info->cluster_list = publ->cluster_list_next = publ;
 		else {
 			publ->cluster_list_next =
-			sseq->cluster_list->cluster_list_next;
-			sseq->cluster_list->cluster_list_next = publ;
+			info->cluster_list->cluster_list_next;
+			info->cluster_list->cluster_list_next = publ;
 		}
 	}
 
 	if (node == tipc_own_addr) {
-		sseq->node_list_size++;
-		if (!sseq->node_list)
-			sseq->node_list = publ->node_list_next = publ;
+		info->node_list_size++;
+		if (!info->node_list)
+			info->node_list = publ->node_list_next = publ;
 		else {
-			publ->node_list_next = sseq->node_list->node_list_next;
-			sseq->node_list->node_list_next = publ;
+			publ->node_list_next = info->node_list->node_list_next;
+			info->node_list->node_list_next = publ;
 		}
 	}
 
@@ -373,6 +393,7 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 	struct publication *curr;
 	struct publication *prev;
 	struct sub_seq *sseq = nameseq_find_subseq(nseq, inst);
+	struct name_info *info;
 	struct sub_seq *free;
 	struct subscription *s, *st;
 	int removed_subseq = 0;
@@ -380,40 +401,42 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 	if (!sseq)
 		return NULL;
 
+	info = sseq->info;
+
 	/* Remove publication from zone scope list */
 
-	prev = sseq->zone_list;
-	publ = sseq->zone_list->zone_list_next;
+	prev = info->zone_list;
+	publ = info->zone_list->zone_list_next;
 	while ((publ->key != key) || (publ->ref != ref) ||
 	       (publ->node && (publ->node != node))) {
 		prev = publ;
 		publ = publ->zone_list_next;
-		if (prev == sseq->zone_list) {
+		if (prev == info->zone_list) {
 
 			/* Prevent endless loop if publication not found */
 
 			return NULL;
 		}
 	}
-	if (publ != sseq->zone_list)
+	if (publ != info->zone_list)
 		prev->zone_list_next = publ->zone_list_next;
 	else if (publ->zone_list_next != publ) {
 		prev->zone_list_next = publ->zone_list_next;
-		sseq->zone_list = publ->zone_list_next;
+		info->zone_list = publ->zone_list_next;
 	} else {
-		sseq->zone_list = NULL;
+		info->zone_list = NULL;
 	}
-	sseq->zone_list_size--;
+	info->zone_list_size--;
 
 	/* Remove publication from cluster scope list, if present */
 
 	if (in_own_cluster(node)) {
-		prev = sseq->cluster_list;
-		curr = sseq->cluster_list->cluster_list_next;
+		prev = info->cluster_list;
+		curr = info->cluster_list->cluster_list_next;
 		while (curr != publ) {
 			prev = curr;
 			curr = curr->cluster_list_next;
-			if (prev == sseq->cluster_list) {
+			if (prev == info->cluster_list) {
 
 				/* Prevent endless loop for malformed list */
 
@@ -424,27 +447,27 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 				goto end_cluster;
 			}
 		}
-		if (publ != sseq->cluster_list)
+		if (publ != info->cluster_list)
 			prev->cluster_list_next = publ->cluster_list_next;
 		else if (publ->cluster_list_next != publ) {
 			prev->cluster_list_next = publ->cluster_list_next;
-			sseq->cluster_list = publ->cluster_list_next;
+			info->cluster_list = publ->cluster_list_next;
 		} else {
-			sseq->cluster_list = NULL;
+			info->cluster_list = NULL;
 		}
-		sseq->cluster_list_size--;
+		info->cluster_list_size--;
 	}
 end_cluster:
 
 	/* Remove publication from node scope list, if present */
 
 	if (node == tipc_own_addr) {
-		prev = sseq->node_list;
-		curr = sseq->node_list->node_list_next;
+		prev = info->node_list;
+		curr = info->node_list->node_list_next;
 		while (curr != publ) {
 			prev = curr;
 			curr = curr->node_list_next;
-			if (prev == sseq->node_list) {
+			if (prev == info->node_list) {
 
 				/* Prevent endless loop for malformed list */
 
@@ -455,21 +478,22 @@ end_cluster:
 				goto end_node;
 			}
 		}
-		if (publ != sseq->node_list)
+		if (publ != info->node_list)
 			prev->node_list_next = publ->node_list_next;
 		else if (publ->node_list_next != publ) {
 			prev->node_list_next = publ->node_list_next;
-			sseq->node_list = publ->node_list_next;
+			info->node_list = publ->node_list_next;
 		} else {
-			sseq->node_list = NULL;
+			info->node_list = NULL;
 		}
-		sseq->node_list_size--;
+		info->node_list_size--;
 	}
 end_node:
 
 	/* Contract subseq list if no more publications for that subseq */
 
-	if (!sseq->zone_list) {
+	if (!info->zone_list) {
+		kfree(info);
 		free = &nseq->sseqs[nseq->first_free--];
 		memmove(sseq, sseq + 1, (free - (sseq + 1)) * sizeof(*sseq));
 		removed_subseq = 1;
@@ -506,7 +530,7 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s
 		return;
 
 	while (sseq != &nseq->sseqs[nseq->first_free]) {
-		struct publication *zl = sseq->zone_list;
+		struct publication *zl = sseq->info->zone_list;
 		if (zl && tipc_subscr_overlap(s, sseq->lower, sseq->upper)) {
 			struct publication *crs = zl;
 			int must_report = 1;
@@ -591,6 +615,7 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 {
 	struct sub_seq *sseq;
+	struct name_info *info;
 	struct publication *publ = NULL;
 	struct name_seq *seq;
 	u32 ref;
@@ -606,12 +631,13 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 	if (unlikely(!sseq))
 		goto not_found;
 	spin_lock_bh(&seq->lock);
+	info = sseq->info;
 
 	/* Closest-First Algorithm: */
 	if (likely(!*destnode)) {
-		publ = sseq->node_list;
+		publ = info->node_list;
 		if (publ) {
-			sseq->node_list = publ->node_list_next;
+			info->node_list = publ->node_list_next;
 found:
 			ref = publ->ref;
 			*destnode = publ->node;
@@ -619,35 +645,35 @@ found:
 			read_unlock_bh(&tipc_nametbl_lock);
 			return ref;
 		}
-		publ = sseq->cluster_list;
+		publ = info->cluster_list;
 		if (publ) {
-			sseq->cluster_list = publ->cluster_list_next;
+			info->cluster_list = publ->cluster_list_next;
 			goto found;
 		}
-		publ = sseq->zone_list;
+		publ = info->zone_list;
 		if (publ) {
-			sseq->zone_list = publ->zone_list_next;
+			info->zone_list = publ->zone_list_next;
 			goto found;
 		}
 	}
 
 	/* Round-Robin Algorithm: */
 	else if (*destnode == tipc_own_addr) {
-		publ = sseq->node_list;
+		publ = info->node_list;
 		if (publ) {
-			sseq->node_list = publ->node_list_next;
+			info->node_list = publ->node_list_next;
 			goto found;
 		}
 	} else if (in_own_cluster(*destnode)) {
-		publ = sseq->cluster_list;
+		publ = info->cluster_list;
 		if (publ) {
-			sseq->cluster_list = publ->cluster_list_next;
+			info->cluster_list = publ->cluster_list_next;
 			goto found;
 		}
 	} else {
-		publ = sseq->zone_list;
+		publ = info->zone_list;
 		if (publ) {
-			sseq->zone_list = publ->zone_list_next;
+			info->zone_list = publ->zone_list_next;
 			goto found;
 		}
 	}
@@ -676,6 +702,7 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 	struct name_seq *seq;
 	struct sub_seq *sseq;
 	struct sub_seq *sseq_stop;
+	struct name_info *info;
 	int res = 0;
 
 	read_lock_bh(&tipc_nametbl_lock);
@@ -693,16 +720,17 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 		if (sseq->lower > upper)
 			break;
 
-		publ = sseq->node_list;
+		info = sseq->info;
+		publ = info->node_list;
 		if (publ) {
 			do {
 				if (publ->scope <= limit)
 					tipc_port_list_add(dports, publ->ref);
 				publ = publ->node_list_next;
-			} while (publ != sseq->node_list);
+			} while (publ != info->node_list);
 		}
 
-		if (sseq->cluster_list_size != sseq->node_list_size)
+		if (info->cluster_list_size != info->node_list_size)
 			res = 1;
 	}
 
@@ -840,7 +868,7 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 {
 	char portIdStr[27];
 	const char *scope_str[] = {"", " zone", " cluster", " node"};
-	struct publication *publ = sseq->zone_list;
+	struct publication *publ = sseq->info->zone_list;
 
 	tipc_printf(buf, "%-10u %-10u ", sseq->lower, sseq->upper);
 
@@ -860,7 +888,7 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 		}
 
 		publ = publ->zone_list_next;
-		if (publ == sseq->zone_list)
+		if (publ == sseq->info->zone_list)
 			break;
 
 		tipc_printf(buf, "\n%33s", " ");
-- 
1.7.4.4

