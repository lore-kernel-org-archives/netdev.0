From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 03/10] tipc: acquire necessary
	locks in named_cluster_distribute routine
Date: Thu, 27 Mar 2014 12:54:32 +0800
Message-ID: <1395896080-7926-4-git-send-email-ying.xue@windriver.com>
References: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The 'tipc_node_list' is guarded by tipc_net_lock and 'links' array
defined in 'tipc_node' structure is protected by node lock as well.
Without acquiring the two locks in named_cluster_distribute() a fatal
oops may happen in case that a destroyed link might be got and then
accessed. Therefore, above mentioned two locks must be held in
named_cluster_distribute() to prevent the issue from happening
accidentally.

As 'links' array in node struct must be protected by node lock,
we have to move the code of selecting an active link from
tipc_link_xmit() to named_cluster_distribute() and then call
__tipc_link_xmit() with the selected link to deliver name messages.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_distr.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 893c49a..c5904d1 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -131,16 +131,24 @@ static void named_cluster_distribute(struct sk_buff *buf)
 {
 	struct sk_buff *buf_copy;
 	struct tipc_node *n_ptr;
+	struct tipc_link *l_ptr;
 
+	read_lock_bh(&tipc_net_lock);
 	list_for_each_entry(n_ptr, &tipc_node_list, list) {
-		if (tipc_node_active_links(n_ptr)) {
+		spin_lock_bh(&n_ptr->lock);
+		l_ptr = n_ptr->active_links[n_ptr->addr & 1];
+		if (l_ptr) {
 			buf_copy = skb_copy(buf, GFP_ATOMIC);
-			if (!buf_copy)
+			if (!buf_copy) {
+				spin_unlock_bh(&n_ptr->lock);
 				break;
+			}
 			msg_set_destnode(buf_msg(buf_copy), n_ptr->addr);
-			tipc_link_xmit(buf_copy, n_ptr->addr, n_ptr->addr);
+			__tipc_link_xmit(l_ptr, buf_copy);
 		}
+		spin_unlock_bh(&n_ptr->lock);
 	}
+	read_unlock_bh(&tipc_net_lock);
 
 	kfree_skb(buf);
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
