From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/4] tipc: eliminate race during
	node creation
Date: Tue,  3 Feb 2015 08:59:19 -0500
Message-ID: <1422971960-9172-4-git-send-email-jon.maloy@ericsson.com>
References: <1422971960-9172-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1422971960-9172-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Instances of struct node are created in the function tipc_disc_rcv()
under the assumption that there is no race between received discovery
messages arriving from the same node. This assumption is wrong.
When we use more than one bearer, it is possible that discovery
messages from the same node arrive at the same moment, resulting in
creation of two instances of struct tipc_node. This may later cause
confusion during link establishment, and may result in one of the links
never becoming activated.

We fix this by making lookup and potential creation of nodes atomic.
Instead of first looking up the node, and in case of failure, create it,
we now start with looking up the node inside node_link_create(), and
return a reference to that one if found. Otherwise, we go ahead and
create the node as we did before.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/discover.c |  9 ++-------
 net/tipc/node.c     | 11 +++++------
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 5b40cb8..a580a40 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/discover.c
  *
- * Copyright (c) 2003-2006, 2014, Ericsson AB
+ * Copyright (c) 2003-2006, 2014-2015, Ericsson AB
  * Copyright (c) 2005-2006, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -47,7 +47,6 @@
 /* indicates no timer in use */
 #define TIPC_LINK_REQ_INACTIVE	0xffffffff
 
-
 /**
  * struct tipc_link_req - information about an ongoing link setup request
  * @bearer_id: identity of bearer issuing requests
@@ -163,13 +162,9 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
 	if (!tipc_in_scope(bearer->domain, onode))
 		return;
 
-	/* Locate, or if necessary, create, node: */
-	node = tipc_node_find(net, onode);
-	if (!node)
-		node = tipc_node_create(net, onode);
+	node = tipc_node_create(net, onode);
 	if (!node)
 		return;
-
 	tipc_node_lock(node);
 	link = node->links[bearer->identity];
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index d4cb8c1..842bd7a 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -96,14 +96,14 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 	struct tipc_node *n_ptr, *temp_node;
 
 	spin_lock_bh(&tn->node_list_lock);
-
+	n_ptr = tipc_node_find(net, addr);
+	if (n_ptr)
+		goto exit;
 	n_ptr = kzalloc(sizeof(*n_ptr), GFP_ATOMIC);
 	if (!n_ptr) {
-		spin_unlock_bh(&tn->node_list_lock);
 		pr_warn("Node creation failed, no memory\n");
-		return NULL;
+		goto exit;
 	}
-
 	n_ptr->addr = addr;
 	n_ptr->net = net;
 	spin_lock_init(&n_ptr->lock);
@@ -123,9 +123,8 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 	list_add_tail_rcu(&n_ptr->list, &temp_node->list);
 	n_ptr->action_flags = TIPC_WAIT_PEER_LINKS_DOWN;
 	n_ptr->signature = INVALID_NODE_SIG;
-
 	tn->num_nodes++;
-
+exit:
 	spin_unlock_bh(&tn->node_list_lock);
 	return n_ptr;
 }
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
