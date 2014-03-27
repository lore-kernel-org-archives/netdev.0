From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 10/10] tipc: use node list lock
	to protect tipc_num_links variable
Date: Thu, 27 Mar 2014 12:54:39 +0800
Message-ID: <1395896080-7926-11-git-send-email-ying.xue@windriver.com>
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

Without properly implicit or explicit read memory barrier, it's
unsafe to read an atomic variable with atomic_read() from another
thread which is different with the thread of changing the atomic
variable with atomic_inc() or atomic_dec(). So a stale tipc_num_links
may be got with atomic_read() in tipc_node_get_links(). If the
tipc_num_links variable type is converted from atomic to unsigned
integer and node list lock is used to protect it, the issue would
be avoided.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 85405a6..1d3a499 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -47,10 +47,9 @@ static void node_established_contact(struct tipc_node *n_ptr);
 static struct hlist_head node_htable[NODE_HTABLE_SIZE];
 LIST_HEAD(tipc_node_list);
 static u32 tipc_num_nodes;
+static u32 tipc_num_links;
 static DEFINE_SPINLOCK(node_list_lock);
 
-static atomic_t tipc_num_links = ATOMIC_INIT(0);
-
 /*
  * A trivial power-of-two bitmask technique is used for speed, since this
  * operation is done for every incoming TIPC packet. The number of hash table
@@ -241,7 +240,9 @@ int tipc_node_is_up(struct tipc_node *n_ptr)
 void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	n_ptr->links[l_ptr->b_ptr->identity] = l_ptr;
-	atomic_inc(&tipc_num_links);
+	spin_lock_bh(&node_list_lock);
+	tipc_num_links++;
+	spin_unlock_bh(&node_list_lock);
 	n_ptr->link_cnt++;
 }
 
@@ -253,7 +254,9 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		if (l_ptr != n_ptr->links[i])
 			continue;
 		n_ptr->links[i] = NULL;
-		atomic_dec(&tipc_num_links);
+		spin_lock_bh(&node_list_lock);
+		tipc_num_links--;
+		spin_unlock_bh(&node_list_lock);
 		n_ptr->link_cnt--;
 	}
 }
@@ -393,18 +396,17 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	spin_lock_bh(&node_list_lock);
 	/* Get space for all unicast links + broadcast link */
-	payload_size = TLV_SPACE(sizeof(link_info)) *
-		(atomic_read(&tipc_num_links) + 1);
+	payload_size = TLV_SPACE((sizeof(link_info)) * (tipc_num_links + 1));
 	if (payload_size > 32768u) {
 		spin_unlock_bh(&node_list_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many links)");
 	}
+	spin_unlock_bh(&node_list_lock);
+
 	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf) {
-		spin_unlock_bh(&node_list_lock);
+	if (!buf)
 		return NULL;
-	}
 
 	/* Add TLV for broadcast link */
 	link_info.dest = htonl(tipc_cluster_mask(tipc_own_addr));
@@ -432,6 +434,5 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 		tipc_node_unlock(n_ptr);
 	}
 	rcu_read_unlock();
-	spin_unlock_bh(&node_list_lock);
 	return buf;
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
