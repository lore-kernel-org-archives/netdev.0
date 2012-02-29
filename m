From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/17] tipc: Hide internal details of node table implementation
Date: Wed, 29 Feb 2012 18:18:34 -0500
Message-ID: <1330557523-2024-9-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53957 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965325Ab2B2XTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:02 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Relocates information about the size of TIPC's node table index and
its associated hash function, since only node subsystem routines need
to have access to this information.

Note that these changes are essentially cosmetic in nature, and have
no impact on the actual operation of TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |   13 +++++++++++++
 net/tipc/node.h |   12 ------------
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 1534259..1790f50 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -39,6 +39,8 @@
 #include "node.h"
 #include "name_distr.h"
 
+#define NODE_HTABLE_SIZE 512
+
 static void node_lost_contact(struct tipc_node *n_ptr);
 static void node_established_contact(struct tipc_node *n_ptr);
 
@@ -51,6 +53,17 @@ static u32 tipc_num_nodes;
 static atomic_t tipc_num_links = ATOMIC_INIT(0);
 
 /*
+ * A trivial power-of-two bitmask technique is used for speed, since this
+ * operation is done for every incoming TIPC packet. The number of hash table
+ * entries has been chosen so that no hash chain exceeds 8 nodes and will
+ * usually be much smaller (typically only a single node).
+ */
+static inline unsigned int tipc_hashfn(u32 addr)
+{
+	return addr & (NODE_HTABLE_SIZE - 1);
+}
+
+/*
  * tipc_node_find - locate specified node object, if it exists
  */
 
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 7bf526a..72561c9 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -107,20 +107,8 @@ struct tipc_node {
 	} bclink;
 };
 
-#define NODE_HTABLE_SIZE 512
 extern struct list_head tipc_node_list;
 
-/*
- * A trivial power-of-two bitmask technique is used for speed, since this
- * operation is done for every incoming TIPC packet. The number of hash table
- * entries has been chosen so that no hash chain exceeds 8 nodes and will
- * usually be much smaller (typically only a single node).
- */
-static inline unsigned int tipc_hashfn(u32 addr)
-{
-	return addr & (NODE_HTABLE_SIZE - 1);
-}
-
 struct tipc_node *tipc_node_find(u32 addr);
 struct tipc_node *tipc_node_create(u32 addr);
 void tipc_node_delete(struct tipc_node *n_ptr);
-- 
1.7.9.1
