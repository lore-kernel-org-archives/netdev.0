From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 2/5 net-next-2.6] [TIPC]: Prevent node object duplication due to simultaneous discovery
Date: Tue, 20 May 2008 17:08:29 -0400
Message-ID: <1211317712-13596-3-git-send-email-allan.stephens@windriver.com>
References: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41787 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762199AbYETVJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 17:09:53 -0400
In-Reply-To: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that the simultaneous discovery of the same
neighboring node by multiple interfaces does not cause TIPC to add
the node into its internal data structures more than once.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/node.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 598f4d3..34e9a2b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -52,16 +52,40 @@ static void node_established_contact(struct node *n_ptr);
 
 struct node *tipc_nodes = NULL;	/* sorted list of nodes within cluster */
 
+static DEFINE_SPINLOCK(node_create_lock);
+
 u32 tipc_own_tag = 0;
 
+/**
+ * tipc_node_create - create neighboring node
+ *
+ * Currently, this routine is called by neighbor discovery code, which holds
+ * net_lock for reading only.  We must take node_create_lock to ensure a node
+ * isn't created twice if two different bearers discover the node at the same
+ * time.  (It would be preferable to switch to holding net_lock in write mode,
+ * but this is a non-trivial change.)
+ */
+
 struct node *tipc_node_create(u32 addr)
 {
 	struct cluster *c_ptr;
 	struct node *n_ptr;
 	struct node **curr_node;
 
+	spin_lock_bh(&node_create_lock);
+
+	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
+		if (addr < n_ptr->addr)
+			break;
+		if (addr == n_ptr->addr) {
+			spin_unlock_bh(&node_create_lock);
+			return n_ptr;
+		}
+	}
+
 	n_ptr = kzalloc(sizeof(*n_ptr),GFP_ATOMIC);
 	if (!n_ptr) {
+		spin_unlock_bh(&node_create_lock);
 		warn("Node creation failed, no memory\n");
 		return NULL;
 	}
@@ -71,6 +95,7 @@ struct node *tipc_node_create(u32 addr)
 		c_ptr = tipc_cltr_create(addr);
 	}
 	if (!c_ptr) {
+		spin_unlock_bh(&node_create_lock);
 		kfree(n_ptr);
 		return NULL;
 	}
@@ -91,6 +116,7 @@ struct node *tipc_node_create(u32 addr)
 		}
 	}
 	(*curr_node) = n_ptr;
+	spin_unlock_bh(&node_create_lock);
 	return n_ptr;
 }
 
-- 
1.5.3.2

