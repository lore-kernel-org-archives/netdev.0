From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: eliminate risk of
	finding to-be-deleted node instance
Date: Wed, 24 Feb 2016 11:00:19 -0500
Message-ID: <1456329619-9209-1-git-send-email-jon.maloy@ericsson.com>
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

Although we have never seen it happen, we have identified the
following problematic scenario when nodes are stopped and deleted:

CPU0:                            CPU1:

tipc_node_xxx()                                   //ref == 1
   tipc_node_put()                                //ref -> 0
                                 tipc_node_find() // node still in table
       tipc_node_delete()
         list_del_rcu(n. list)
                                 tipc_node_get()  //ref -> 1, bad
         kfree_rcu()

                                 tipc_node_put() //ref to 0 again.
                                 kfree_rcu()     // BOOM!

We fix this by introducing use of the conditional kref_get_if_not_zero()
instead of kref_get() in the function tipc_node_find(). This eliminates
any risk of post-mortem access.

Reported-by: Zhijiang Hu <huzhijiang@gmail.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 9fcc2fb..792bbcb 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -245,23 +245,23 @@ static void tipc_node_get(struct tipc_node *node)
  */
 static struct tipc_node *tipc_node_find(struct net *net, u32 addr)
 {
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_net *tn = tipc_net(net);
 	struct tipc_node *node;
+	unsigned int thash = tipc_hashfn(addr);
 
 	if (unlikely(!in_own_cluster_exact(net, addr)))
 		return NULL;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(node, &tn->node_htable[tipc_hashfn(addr)],
-				 hash) {
-		if (node->addr == addr) {
-			tipc_node_get(node);
-			rcu_read_unlock();
-			return node;
-		}
+	hlist_for_each_entry_rcu(node, &tn->node_htable[thash], hash) {
+		if (node->addr != addr)
+			continue;
+		if (!kref_get_unless_zero(&node->kref))
+			node = NULL;
+		break;
 	}
 	rcu_read_unlock();
-	return NULL;
+	return node;
 }
 
 static void tipc_node_read_lock(struct tipc_node *n)
-- 
1.9.1


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
