From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/16] tipc: Reduce footprint by un-inlining nmap routines
Date: Tue, 11 May 2010 20:30:14 -0400
Message-ID: <ac466f8ca7f68d49163378453dad196bb0438eb8.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35255 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158Ab0ELAac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:32 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UWas000129
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:32 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Converts nmap inline routines that are more than one line into standard
functions, thereby eliminating a significant amount of repeated code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/bcast.h |   63 +++--------------------------------------------------
 2 files changed, 64 insertions(+), 59 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a8f22e7..1ee6424 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -822,3 +822,63 @@ void tipc_bclink_stop(void)
 	spin_unlock_bh(&bc_lock);
 }
 
+
+/**
+ * tipc_nmap_add - add a node to a node map
+ */
+
+void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
+{
+	int n = tipc_node(node);
+	int w = n / WSIZE;
+	u32 mask = (1 << (n % WSIZE));
+
+	if ((nm_ptr->map[w] & mask) == 0) {
+		nm_ptr->count++;
+		nm_ptr->map[w] |= mask;
+	}
+}
+
+/**
+ * tipc_nmap_remove - remove a node from a node map
+ */
+
+void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
+{
+	int n = tipc_node(node);
+	int w = n / WSIZE;
+	u32 mask = (1 << (n % WSIZE));
+
+	if ((nm_ptr->map[w] & mask) != 0) {
+		nm_ptr->map[w] &= ~mask;
+		nm_ptr->count--;
+	}
+}
+
+/**
+ * tipc_nmap_diff - find differences between node maps
+ * @nm_a: input node map A
+ * @nm_b: input node map B
+ * @nm_diff: output node map A-B (i.e. nodes of A that are not in B)
+ */
+
+void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
+				  struct tipc_node_map *nm_diff)
+{
+	int stop = ARRAY_SIZE(nm_a->map);
+	int w;
+	int b;
+	u32 map;
+
+	memset(nm_diff, 0, sizeof(*nm_diff));
+	for (w = 0; w < stop; w++) {
+		map = nm_a->map[w] ^ (nm_a->map[w] & nm_b->map[w]);
+		nm_diff->map[w] = map;
+		if (map != 0) {
+			for (b = 0 ; b < WSIZE; b++) {
+				if (map & (1 << b))
+					nm_diff->count++;
+			}
+		}
+	}
+}
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 2b1c4a7..cd77981 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -72,38 +72,8 @@ struct tipc_node;
 
 extern const char tipc_bclink_name[];
 
-
-/**
- * tipc_nmap_add - add a node to a node map
- */
-
-static inline void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
-{
-	int n = tipc_node(node);
-	int w = n / WSIZE;
-	u32 mask = (1 << (n % WSIZE));
-
-	if ((nm_ptr->map[w] & mask) == 0) {
-		nm_ptr->count++;
-		nm_ptr->map[w] |= mask;
-	}
-}
-
-/**
- * tipc_nmap_remove - remove a node from a node map
- */
-
-static inline void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
-{
-	int n = tipc_node(node);
-	int w = n / WSIZE;
-	u32 mask = (1 << (n % WSIZE));
-
-	if ((nm_ptr->map[w] & mask) != 0) {
-		nm_ptr->map[w] &= ~mask;
-		nm_ptr->count--;
-	}
-}
+void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node);
+void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node);
 
 /**
  * tipc_nmap_equal - test for equality of node maps
@@ -114,33 +84,8 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_m
 	return !memcmp(nm_a, nm_b, sizeof(*nm_a));
 }
 
-/**
- * tipc_nmap_diff - find differences between node maps
- * @nm_a: input node map A
- * @nm_b: input node map B
- * @nm_diff: output node map A-B (i.e. nodes of A that are not in B)
- */
-
-static inline void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
-				  struct tipc_node_map *nm_diff)
-{
-	int stop = ARRAY_SIZE(nm_a->map);
-	int w;
-	int b;
-	u32 map;
-
-	memset(nm_diff, 0, sizeof(*nm_diff));
-	for (w = 0; w < stop; w++) {
-		map = nm_a->map[w] ^ (nm_a->map[w] & nm_b->map[w]);
-		nm_diff->map[w] = map;
-		if (map != 0) {
-			for (b = 0 ; b < WSIZE; b++) {
-				if (map & (1 << b))
-					nm_diff->count++;
-			}
-		}
-	}
-}
+void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
+				  struct tipc_node_map *nm_diff);
 
 /**
  * tipc_port_list_add - add a port to a port list, ensuring no duplicates
-- 
1.7.1.rc2

