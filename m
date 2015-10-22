From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 02/16] tipc: move broadcast link
	lock to struct tipc_net
Date: Thu, 22 Oct 2015 08:51:34 -0400
Message-ID: <1445518308-26200-3-git-send-email-jon.maloy@ericsson.com>
References: <1445518308-26200-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1445518308-26200-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The broadcast lock will need to be acquired outside bcast.c in a later
commit. For this reason, we move the lock to struct tipc_net. Consistent
with the changes in the previous commit, we also introducee two new
functions tipc_bcast_lock() and tipc_bcast_unlock(). The code that is
currently using tipc_bclink_lock()/unlock() will be phased out during
the coming commits in this series.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c | 12 +++---------
 net/tipc/bcast.h | 10 ++++++++++
 net/tipc/core.h  |  1 +
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2c5f544..ebf4fd7 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -90,7 +90,6 @@ struct tipc_bcbearer {
 
 /**
  * struct tipc_bc_base - link used for broadcast messages
- * @lock: spinlock governing access to structure
  * @link: (non-standard) broadcast link structure
  * @node: (non-standard) node structure representing b'cast link's peer node
  * @bcast_nodes: map of broadcast-capable nodes
@@ -99,7 +98,6 @@ struct tipc_bcbearer {
  * Handles sequence numbering, fragmentation, bundling, etc.
  */
 struct tipc_bc_base {
-	spinlock_t lock; /* spinlock protecting broadcast structs */
 	struct tipc_link link;
 	struct tipc_node node;
 	struct sk_buff_head arrvq;
@@ -124,16 +122,12 @@ static void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node);
 static void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node);
 static void tipc_bclink_lock(struct net *net)
 {
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-
-	spin_lock_bh(&tn->bcbase->lock);
+	tipc_bcast_lock(net);
 }
 
 static void tipc_bclink_unlock(struct net *net)
 {
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-
-	spin_unlock_bh(&tn->bcbase->lock);
+	tipc_bcast_unlock(net);
 }
 
 void tipc_bclink_input(struct net *net)
@@ -1031,7 +1025,7 @@ int tipc_bcast_init(struct net *net)
 	bcbearer->media.send_msg = tipc_bcbearer_send;
 	sprintf(bcbearer->media.name, "tipc-broadcast");
 
-	spin_lock_init(&bclink->lock);
+	spin_lock_init(&tipc_net(net)->bclock);
 	__skb_queue_head_init(&bcl->transmq);
 	__skb_queue_head_init(&bcl->backlogq);
 	__skb_queue_head_init(&bcl->deferdq);
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index d379b0a..eac912a 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -69,4 +69,14 @@ int tipc_nl_bc_link_set(struct net *net, struct nlattr *attrs[]);
 void tipc_bclink_input(struct net *net);
 void tipc_bclink_sync_state(struct tipc_node *n, struct tipc_msg *msg);
 
+static inline void tipc_bcast_lock(struct net *net)
+{
+	spin_lock_bh(&tipc_net(net)->bclock);
+}
+
+static inline void tipc_bcast_unlock(struct net *net)
+{
+	spin_unlock_bh(&tipc_net(net)->bclock);
+}
+
 #endif
diff --git a/net/tipc/core.h b/net/tipc/core.h
index e4e9a56..645dcac 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -93,6 +93,7 @@ struct tipc_net {
 	struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
 
 	/* Broadcast link */
+	spinlock_t bclock;
 	struct tipc_bcbearer *bcbearer;
 	struct tipc_bc_base *bcbase;
 	struct tipc_link *bcl;
-- 
1.9.1


------------------------------------------------------------------------------
