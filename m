From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 10/11] tipc: use bc_lock to
	protect node map in bearer structure
Date: Mon, 21 Apr 2014 10:55:51 +0800
Message-ID: <1398048952-7825-11-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The node map variable - 'nodes' in bearer structure is only used by
bclink. When bclink accesses it, bc_lock is held. But when change it,
for instance, in tipc_bearer_add_dest() or tipc_bearer_remove_dest()
the bc_lock is not taken at all. To avoid any inconsistent data, we
should always grab bc_lock while accessing node map variable.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bcast.c  |   14 ++++++++++----
 net/tipc/bcast.h  |    5 +----
 net/tipc/bearer.c |    6 ++----
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 0f32226..119a59b 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -112,6 +112,8 @@ const char tipc_bclink_name[] = "broadcast-link";
 static void tipc_nmap_diff(struct tipc_node_map *nm_a,
 			   struct tipc_node_map *nm_b,
 			   struct tipc_node_map *nm_diff);
+static void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node);
+static void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node);
 
 static u32 bcbuf_acks(struct sk_buff *buf)
 {
@@ -653,7 +655,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 /**
  * tipc_bcbearer_sort - create sets of bearer pairs used by broadcast bearer
  */
-void tipc_bcbearer_sort(void)
+void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action)
 {
 	struct tipc_bcbearer_pair *bp_temp = bcbearer->bpairs_temp;
 	struct tipc_bcbearer_pair *bp_curr;
@@ -663,6 +665,11 @@ void tipc_bcbearer_sort(void)
 
 	spin_lock_bh(&bc_lock);
 
+	if (action)
+		tipc_nmap_add(nm_ptr, node);
+	else
+		tipc_nmap_remove(nm_ptr, node);
+
 	/* Group bearers by priority (can assume max of two per priority) */
 	memset(bp_temp, 0, sizeof(bcbearer->bpairs_temp));
 
@@ -801,11 +808,10 @@ void tipc_bclink_stop(void)
 	memset(bcbearer, 0, sizeof(*bcbearer));
 }
 
-
 /**
  * tipc_nmap_add - add a node to a node map
  */
-void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
+static void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
 {
 	int n = tipc_node(node);
 	int w = n / WSIZE;
@@ -820,7 +826,7 @@ void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
 /**
  * tipc_nmap_remove - remove a node from a node map
  */
-void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
+static void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
 {
 	int n = tipc_node(node);
 	int w = n / WSIZE;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index a80ef54..7c1ef1b 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -69,9 +69,6 @@ struct tipc_node;
 
 extern const char tipc_bclink_name[];
 
-void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node);
-void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node);
-
 /**
  * tipc_nmap_equal - test for equality of node maps
  */
@@ -98,6 +95,6 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent);
 int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
-void tipc_bcbearer_sort(void);
+void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
 
 #endif
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 44fd22a..3abd970 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -220,8 +220,7 @@ void tipc_bearer_add_dest(u32 bearer_id, u32 dest)
 	rcu_read_lock();
 	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
 	if (b_ptr) {
-		tipc_nmap_add(&b_ptr->nodes, dest);
-		tipc_bcbearer_sort();
+		tipc_bcbearer_sort(&b_ptr->nodes, dest, true);
 		tipc_disc_add_dest(b_ptr->link_req);
 	}
 	rcu_read_unlock();
@@ -234,8 +233,7 @@ void tipc_bearer_remove_dest(u32 bearer_id, u32 dest)
 	rcu_read_lock();
 	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
 	if (b_ptr) {
-		tipc_nmap_remove(&b_ptr->nodes, dest);
-		tipc_bcbearer_sort();
+		tipc_bcbearer_sort(&b_ptr->nodes, dest, false);
 		tipc_disc_remove_dest(b_ptr->link_req);
 	}
 	rcu_read_unlock();
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
