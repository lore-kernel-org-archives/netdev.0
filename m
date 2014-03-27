From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 09/10] tipc: use node_list_lock
	to protect tipc_num_nodes variable
Date: Thu, 27 Mar 2014 12:54:38 +0800
Message-ID: <1395896080-7926-10-git-send-email-ying.xue@windriver.com>
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

As tipc_node_list is protected by rcu read lock on read side, it's
unnecessary to hold node_list_lock to protect tipc_node_list in
tipc_node_get_links(). Instead, node_list_lock should just protects
tipc_num_nodes in the function.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 4f517ff..85405a6 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -352,11 +352,11 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many nodes)");
 	}
+	spin_unlock_bh(&node_list_lock);
+
 	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf) {
-		spin_unlock_bh(&node_list_lock);
+	if (!buf)
 		return NULL;
-	}
 
 	/* Add TLVs for all nodes in scope */
 	rcu_read_lock();
@@ -369,7 +369,6 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 				    &node_info, sizeof(node_info));
 	}
 	rcu_read_unlock();
-	spin_unlock_bh(&node_list_lock);
 	return buf;
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
