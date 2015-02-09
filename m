From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 11/17] tipc: convert legacy nl
	node dump to nl compat
Date: Mon, 9 Feb 2015 09:50:13 +0100
Message-ID: <1423471819-23112-12-git-send-email-richard.alpe@ericsson.com>
References: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

Convert TIPC_CMD_GET_NODES to compat dumpit and remove global node
counter solely used by the legacy API.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         |  4 ----
 net/tipc/netlink_compat.c | 22 +++++++++++++++++++
 net/tipc/node.c           | 54 -----------------------------------------------
 net/tipc/node.h           |  2 --
 4 files changed, 22 insertions(+), 60 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index df41082..74babd7 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -205,10 +205,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_NOOP:
 		rep_tlv_buf = tipc_cfg_reply_none();
 		break;
-	case TIPC_CMD_GET_NODES:
-		rep_tlv_buf = tipc_node_get_nodes(net, req_tlv_area,
-						  req_tlv_space);
-		break;
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index d23075e..0dc448e 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -37,6 +37,7 @@
 #include "link.h"
 #include "name_table.h"
 #include "socket.h"
+#include "node.h"
 #include <net/genetlink.h>
 #include <linux/tipc_config.h>
 
@@ -835,6 +836,21 @@ static int tipc_nl_compat_media_dump(struct tipc_nl_compat_msg *msg,
 			    nla_len(media[TIPC_NLA_MEDIA_NAME]));
 }
 
+static int tipc_nl_compat_node_dump(struct tipc_nl_compat_msg *msg,
+				    struct nlattr **attrs)
+{
+	struct tipc_node_info node_info;
+	struct nlattr *node[TIPC_NLA_NODE_MAX + 1];
+
+	nla_parse_nested(node, TIPC_NLA_NODE_MAX, attrs[TIPC_NLA_NODE], NULL);
+
+	node_info.addr = htonl(nla_get_u32(node[TIPC_NLA_NODE_ADDR]));
+	node_info.up = htonl(nla_get_flag(node[TIPC_NLA_NODE_UP]));
+
+	return tipc_add_tlv(msg->rep, TIPC_TLV_NODE_INFO, &node_info,
+			    sizeof(node_info));
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -903,6 +919,11 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_media_dump;
 		dump.format = tipc_nl_compat_media_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_GET_NODES:
+		msg->rep_size = ULTRA_STRING_MAX_LEN;
+		dump.dumpit = tipc_nl_node_dump;
+		dump.format = tipc_nl_compat_node_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -1011,6 +1032,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_SHOW_NAME_TABLE:
 	case TIPC_CMD_SHOW_PORTS:
 	case TIPC_CMD_GET_MEDIA_NAMES:
+	case TIPC_CMD_GET_NODES:
 		return tipc_nl_compat_recv(skb, info);
 	}
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 46b87f7..ddaa2bb 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -120,7 +120,6 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 	list_add_tail_rcu(&n_ptr->list, &temp_node->list);
 	n_ptr->action_flags = TIPC_WAIT_PEER_LINKS_DOWN;
 	n_ptr->signature = INVALID_NODE_SIG;
-	tn->num_nodes++;
 exit:
 	spin_unlock_bh(&tn->node_list_lock);
 	return n_ptr;
@@ -131,8 +130,6 @@ static void tipc_node_delete(struct tipc_net *tn, struct tipc_node *n_ptr)
 	list_del_rcu(&n_ptr->list);
 	hlist_del_rcu(&n_ptr->hash);
 	kfree_rcu(n_ptr, rcu);
-
-	tn->num_nodes--;
 }
 
 void tipc_node_stop(struct net *net)
@@ -407,57 +404,6 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	}
 }
 
-struct sk_buff *tipc_node_get_nodes(struct net *net, const void *req_tlv_area,
-				    int req_tlv_space)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	u32 domain;
-	struct sk_buff *buf;
-	struct tipc_node *n_ptr;
-	struct tipc_node_info node_info;
-	u32 payload_size;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	domain = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (!tipc_addr_domain_valid(domain))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (network address)");
-
-	spin_lock_bh(&tn->node_list_lock);
-	if (!tn->num_nodes) {
-		spin_unlock_bh(&tn->node_list_lock);
-		return tipc_cfg_reply_none();
-	}
-
-	/* For now, get space for all other nodes */
-	payload_size = TLV_SPACE(sizeof(node_info)) * tn->num_nodes;
-	if (payload_size > 32768u) {
-		spin_unlock_bh(&tn->node_list_lock);
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (too many nodes)");
-	}
-	spin_unlock_bh(&tn->node_list_lock);
-
-	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf)
-		return NULL;
-
-	/* Add TLVs for all nodes in scope */
-	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
-		if (!tipc_in_scope(domain, n_ptr->addr))
-			continue;
-		node_info.addr = htonl(n_ptr->addr);
-		node_info.up = htonl(tipc_node_is_up(n_ptr));
-		tipc_cfg_append_tlv(buf, TIPC_TLV_NODE_INFO,
-				    &node_info, sizeof(node_info));
-	}
-	rcu_read_unlock();
-	return buf;
-}
-
 /**
  * tipc_node_get_linkname - get the name of a link
  *
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 59dafee..3d18c66 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -142,8 +142,6 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 int tipc_node_active_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
-struct sk_buff *tipc_node_get_nodes(struct net *net, const void *req_tlv_area,
-				    int req_tlv_space);
 int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 node,
 			   char *linkname, size_t len);
 void tipc_node_unlock(struct tipc_node *node);
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
