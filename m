From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 14/14] tipc: add node_lock
	protection to link lookup function
Date: Wed, 12 Feb 2014 13:31:14 -0500
Message-ID: <1392229874-29675-15-git-send-email-jon.maloy@ericsson.com>
References: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In an earlier commit, ("tipc: remove links list from bearer struct")
we described three issues that need to be pre-emptively resolved before
we can remove tipc_net_lock. Here we resolve issue a) described in that
commit:

"a) In access method #2, we access the link before taking the
    protecting node_lock. This will not work once net_lock is gone,
    so we will have to change the access order. We will deal with
    this in a later commit in this series."

Here, we change that access order, by ensuring that the function
link_find_link() returns only a safe reference for finding
the link, i.e., a node pointer and an index into its 'links' array,
not the link pointer itself. We also change all callers of this
function to first take the node lock before they can check if there
still is a valid link pointer at the returned index. Since the
function now returns a node pointer rather than a link pointer,
we rename it to the more appropriate 'tipc_link_find_owner().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |  110 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 65 insertions(+), 45 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index a13b90d..11f2222 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2389,35 +2389,40 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 	l_ptr->queue_limit[MSG_FRAGMENTER] = 4000;
 }
 
-/**
- * link_find_link - locate link by name
- * @name: ptr to link name string
- * @node: ptr to area to be filled with ptr to associated node
- *
+/* tipc_link_find_owner - locate owner node of link by link's name
+ * @name: pointer to link name string
+ * @bearer_id: pointer to index in 'node->links' array where the link was found.
  * Caller must hold 'tipc_net_lock' to ensure node and bearer are not deleted;
  * this also prevents link deletion.
  *
- * Returns pointer to link (or 0 if invalid link name).
+ * Returns pointer to node owning the link, or 0 if no matching link is found.
  */
-static struct tipc_link *link_find_link(const char *name,
-					struct tipc_node **node)
+static struct tipc_node *tipc_link_find_owner(const char *link_name,
+					      unsigned int *bearer_id)
 {
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
+	struct tipc_node *tmp_n_ptr;
+	struct tipc_node *found_node = 0;
+
 	int i;
 
-	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+	*bearer_id = 0;
+	list_for_each_entry_safe(n_ptr, tmp_n_ptr, &tipc_node_list, list) {
+		spin_lock(&n_ptr->lock);
 		for (i = 0; i < MAX_BEARERS; i++) {
 			l_ptr = n_ptr->links[i];
-			if (l_ptr && !strcmp(l_ptr->name, name))
-				goto found;
+			if (l_ptr && !strcmp(l_ptr->name, link_name)) {
+				*bearer_id = i;
+				found_node = n_ptr;
+				break;
+			}
 		}
+		spin_unlock(&n_ptr->lock);
+		if (found_node)
+			break;
 	}
-	l_ptr = NULL;
-	n_ptr = NULL;
-found:
-	*node = n_ptr;
-	return l_ptr;
+	return found_node;
 }
 
 /**
@@ -2459,32 +2464,33 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 	struct tipc_link *l_ptr;
 	struct tipc_bearer *b_ptr;
 	struct tipc_media *m_ptr;
+	int bearer_id;
 	int res = 0;
 
-	l_ptr = link_find_link(name, &node);
-	if (l_ptr) {
-		/*
-		 * acquire node lock for tipc_link_send_proto_msg().
-		 * see "TIPC locking policy" in net.c.
-		 */
+	node = tipc_link_find_owner(name, &bearer_id);
+	if (node) {
 		tipc_node_lock(node);
-		switch (cmd) {
-		case TIPC_CMD_SET_LINK_TOL:
-			link_set_supervision_props(l_ptr, new_value);
-			tipc_link_send_proto_msg(l_ptr,
-				STATE_MSG, 0, 0, new_value, 0, 0);
-			break;
-		case TIPC_CMD_SET_LINK_PRI:
-			l_ptr->priority = new_value;
-			tipc_link_send_proto_msg(l_ptr,
-				STATE_MSG, 0, 0, 0, new_value, 0);
-			break;
-		case TIPC_CMD_SET_LINK_WINDOW:
-			tipc_link_set_queue_limits(l_ptr, new_value);
-			break;
-		default:
-			res = -EINVAL;
-			break;
+		l_ptr = node->links[bearer_id];
+
+		if (l_ptr) {
+			switch (cmd) {
+			case TIPC_CMD_SET_LINK_TOL:
+				link_set_supervision_props(l_ptr, new_value);
+				tipc_link_send_proto_msg(l_ptr, STATE_MSG, 0,
+							 0, new_value, 0, 0);
+				break;
+			case TIPC_CMD_SET_LINK_PRI:
+				l_ptr->priority = new_value;
+				tipc_link_send_proto_msg(l_ptr, STATE_MSG, 0,
+							 0, 0, new_value, 0);
+				break;
+			case TIPC_CMD_SET_LINK_WINDOW:
+				tipc_link_set_queue_limits(l_ptr, new_value);
+				break;
+			default:
+				res = -EINVAL;
+				break;
+			}
 		}
 		tipc_node_unlock(node);
 		return res;
@@ -2579,6 +2585,7 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 	char *link_name;
 	struct tipc_link *l_ptr;
 	struct tipc_node *node;
+	unsigned int bearer_id;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -2589,15 +2596,19 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 			return tipc_cfg_reply_error_string("link not found");
 		return tipc_cfg_reply_none();
 	}
-
 	read_lock_bh(&tipc_net_lock);
-	l_ptr = link_find_link(link_name, &node);
+	node = tipc_link_find_owner(link_name, &bearer_id);
+	if (!node) {
+		read_unlock_bh(&tipc_net_lock);
+		return tipc_cfg_reply_error_string("link not found");
+	}
+	spin_lock(&node->lock);
+	l_ptr = node->links[bearer_id];
 	if (!l_ptr) {
+		tipc_node_unlock(node);
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string("link not found");
 	}
-
-	tipc_node_lock(node);
 	link_reset_statistics(l_ptr);
 	tipc_node_unlock(node);
 	read_unlock_bh(&tipc_net_lock);
@@ -2627,18 +2638,27 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 	struct tipc_node *node;
 	char *status;
 	u32 profile_total = 0;
+	unsigned int bearer_id;
 	int ret;
 
 	if (!strcmp(name, tipc_bclink_name))
 		return tipc_bclink_stats(buf, buf_size);
 
 	read_lock_bh(&tipc_net_lock);
-	l = link_find_link(name, &node);
-	if (!l) {
+	node = tipc_link_find_owner(name, &bearer_id);
+	if (!node) {
 		read_unlock_bh(&tipc_net_lock);
 		return 0;
 	}
 	tipc_node_lock(node);
+
+	l = node->links[bearer_id];
+	if (!l) {
+		tipc_node_unlock(node);
+		read_unlock_bh(&tipc_net_lock);
+		return 0;
+	}
+
 	s = &l->stats;
 
 	if (tipc_link_is_active(l))
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
