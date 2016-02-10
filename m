From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: fix premature addition of
	node to lookup table
Date: Wed, 10 Feb 2016 16:14:57 -0500
Message-ID: <1455138898-3648-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In commit 5266698661401a ("tipc: let broadcast packet reception
use new link receive function") we introduced a new per-node
broadcast reception link instance. This link is created at the
moment the node itself is created. Unfortunately, the allocation
is done after the node instance has already been added to the node
lookup hash table. This creates a potential race condition, where
arriving broadcast packets are able to find and access the node
before it has been fully initialized, and before the above mentioned
link has been created. The result is occasional crashes in the function
tipc_bcast_rcv(), which is trying to access the not-yet existing link.

We fix this by deferring the addition of the node instance until after
it has been fully initialized in the function tipc_node_create().

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index fa97d96..9d7a16f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -346,12 +346,6 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr, u16 capabilities)
 	skb_queue_head_init(&n->bc_entry.inputq2);
 	for (i = 0; i < MAX_BEARERS; i++)
 		spin_lock_init(&n->links[i].lock);
-	hlist_add_head_rcu(&n->hash, &tn->node_htable[tipc_hashfn(addr)]);
-	list_for_each_entry_rcu(temp_node, &tn->node_list, list) {
-		if (n->addr < temp_node->addr)
-			break;
-	}
-	list_add_tail_rcu(&n->list, &temp_node->list);
 	n->state = SELF_DOWN_PEER_LEAVING;
 	n->signature = INVALID_NODE_SIG;
 	n->active_links[0] = INVALID_BEARER_ID;
@@ -372,6 +366,12 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr, u16 capabilities)
 	tipc_node_get(n);
 	setup_timer(&n->timer, tipc_node_timeout, (unsigned long)n);
 	n->keepalive_intv = U32_MAX;
+	hlist_add_head_rcu(&n->hash, &tn->node_htable[tipc_hashfn(addr)]);
+	list_for_each_entry_rcu(temp_node, &tn->node_list, list) {
+		if (n->addr < temp_node->addr)
+			break;
+	}
+	list_add_tail_rcu(&n->list, &temp_node->list);
 exit:
 	spin_unlock_bh(&tn->node_list_lock);
 	return n;
-- 
1.9.1


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
