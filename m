From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/16] tipc: Reduce footprint by un-inlining port list routines
Date: Tue, 11 May 2010 20:30:15 -0400
Message-ID: <7f1f098b6118144d29e12af4f70e354606031229.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35257 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173Ab0ELAad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:33 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UWLp000133
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:32 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Converts port list inline routines that are more than one line into
standard functions, thereby eliminating a significant amount of
repeated code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/bcast.h |   52 ++--------------------------------------------------
 2 files changed, 52 insertions(+), 50 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 1ee6424..a008c66 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -882,3 +882,53 @@ void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
 		}
 	}
 }
+
+/**
+ * tipc_port_list_add - add a port to a port list, ensuring no duplicates
+ */
+
+void tipc_port_list_add(struct port_list *pl_ptr, u32 port)
+{
+	struct port_list *item = pl_ptr;
+	int i;
+	int item_sz = PLSIZE;
+	int cnt = pl_ptr->count;
+
+	for (; ; cnt -= item_sz, item = item->next) {
+		if (cnt < PLSIZE)
+			item_sz = cnt;
+		for (i = 0; i < item_sz; i++)
+			if (item->ports[i] == port)
+				return;
+		if (i < PLSIZE) {
+			item->ports[i] = port;
+			pl_ptr->count++;
+			return;
+		}
+		if (!item->next) {
+			item->next = kmalloc(sizeof(*item), GFP_ATOMIC);
+			if (!item->next) {
+				warn("Incomplete multicast delivery, no memory\n");
+				return;
+			}
+			item->next->next = NULL;
+		}
+	}
+}
+
+/**
+ * tipc_port_list_free - free dynamically created entries in port_list chain
+ *
+ */
+
+void tipc_port_list_free(struct port_list *pl_ptr)
+{
+	struct port_list *item;
+	struct port_list *next;
+
+	for (item = pl_ptr->next; item; item = next) {
+		next = item->next;
+		kfree(item);
+	}
+}
+
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index cd77981..e8c2b81 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -87,56 +87,8 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_m
 void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
 				  struct tipc_node_map *nm_diff);
 
-/**
- * tipc_port_list_add - add a port to a port list, ensuring no duplicates
- */
-
-static inline void tipc_port_list_add(struct port_list *pl_ptr, u32 port)
-{
-	struct port_list *item = pl_ptr;
-	int i;
-	int item_sz = PLSIZE;
-	int cnt = pl_ptr->count;
-
-	for (; ; cnt -= item_sz, item = item->next) {
-		if (cnt < PLSIZE)
-			item_sz = cnt;
-		for (i = 0; i < item_sz; i++)
-			if (item->ports[i] == port)
-				return;
-		if (i < PLSIZE) {
-			item->ports[i] = port;
-			pl_ptr->count++;
-			return;
-		}
-		if (!item->next) {
-			item->next = kmalloc(sizeof(*item), GFP_ATOMIC);
-			if (!item->next) {
-				warn("Incomplete multicast delivery, no memory\n");
-				return;
-			}
-			item->next->next = NULL;
-		}
-	}
-}
-
-/**
- * tipc_port_list_free - free dynamically created entries in port_list chain
- *
- * Note: First item is on stack, so it doesn't need to be released
- */
-
-static inline void tipc_port_list_free(struct port_list *pl_ptr)
-{
-	struct port_list *item;
-	struct port_list *next;
-
-	for (item = pl_ptr->next; item; item = next) {
-		next = item->next;
-		kfree(item);
-	}
-}
-
+void tipc_port_list_add(struct port_list *pl_ptr, u32 port);
+void tipc_port_list_free(struct port_list *pl_ptr);
 
 int  tipc_bclink_init(void);
 void tipc_bclink_stop(void);
-- 
1.7.1.rc2

