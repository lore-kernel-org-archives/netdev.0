From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 07/17] tipc: convert legacy nl
	link stat reset to nl compat
Date: Mon, 9 Feb 2015 09:50:09 +0100
Message-ID: <1423471819-23112-8-git-send-email-richard.alpe@ericsson.com>
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

Convert TIPC_CMD_RESET_LINK_STATS to compat doit.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         |  4 ----
 net/tipc/link.c           | 35 +----------------------------------
 net/tipc/link.h           |  3 ---
 net/tipc/netlink_compat.c | 26 ++++++++++++++++++++++++++
 4 files changed, 27 insertions(+), 41 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 75a130e..11c16d1 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -209,10 +209,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_node_get_nodes(net, req_tlv_area,
 						  req_tlv_space);
 		break;
-	case TIPC_CMD_RESET_LINK_STATS:
-		rep_tlv_buf = tipc_link_cmd_reset_stats(net, req_tlv_area,
-							req_tlv_space);
-		break;
 	case TIPC_CMD_SHOW_NAME_TABLE:
 		rep_tlv_buf = tipc_nametbl_get(net, req_tlv_area,
 					       req_tlv_space);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index ec136b5..dfe6f4d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1969,39 +1969,6 @@ static void link_reset_statistics(struct tipc_link *l_ptr)
 	l_ptr->stats.recv_info = l_ptr->next_in_no;
 }
 
-struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
-					  const void *req_tlv_area,
-					  int req_tlv_space)
-{
-	char *link_name;
-	struct tipc_link *l_ptr;
-	struct tipc_node *node;
-	unsigned int bearer_id;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	link_name = (char *)TLV_DATA(req_tlv_area);
-	if (!strcmp(link_name, tipc_bclink_name)) {
-		if (tipc_bclink_reset_stats(net))
-			return tipc_cfg_reply_error_string("link not found");
-		return tipc_cfg_reply_none();
-	}
-	node = tipc_link_find_owner(net, link_name, &bearer_id);
-	if (!node)
-		return tipc_cfg_reply_error_string("link not found");
-
-	tipc_node_lock(node);
-	l_ptr = node->links[bearer_id];
-	if (!l_ptr) {
-		tipc_node_unlock(node);
-		return tipc_cfg_reply_error_string("link not found");
-	}
-	link_reset_statistics(l_ptr);
-	tipc_node_unlock(node);
-	return tipc_cfg_reply_none();
-}
-
 static void link_print(struct tipc_link *l_ptr, const char *str)
 {
 	struct tipc_net *tn = net_generic(l_ptr->owner->net, tipc_net_id);
@@ -2424,7 +2391,7 @@ int tipc_nl_link_reset_stats(struct sk_buff *skb, struct genl_info *info)
 	struct tipc_link *link;
 	struct tipc_node *node;
 	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1];
-	struct net *net = genl_info_net(info);
+	struct net *net = sock_net(skb->sk);
 
 	if (!info->attrs[TIPC_NLA_LINK])
 		return -EINVAL;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 6eb9d60..7aeb520 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -215,9 +215,6 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
 void tipc_link_purge_queues(struct tipc_link *l_ptr);
-struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
-					  const void *req_tlv_area,
-					  int req_tlv_space);
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(struct net *net, unsigned int bearer_id);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 056532b..0246123 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -606,6 +606,26 @@ static int tipc_nl_compat_link_set(struct sk_buff *skb,
 	return 0;
 }
 
+static int tipc_nl_compat_link_reset_stats(struct sk_buff *skb,
+					   struct tipc_nl_compat_msg *msg)
+{
+	char *name;
+	struct nlattr *link;
+
+	name = (char *)TLV_DATA(msg->req);
+
+	link = nla_nest_start(skb, TIPC_NLA_LINK);
+	if (!link)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, TIPC_NLA_LINK_NAME, name))
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, link);
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -650,6 +670,11 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		doit.doit = tipc_nl_link_set;
 		doit.transcode = tipc_nl_compat_link_set;
 		return tipc_nl_compat_doit(&doit, msg);
+	case TIPC_CMD_RESET_LINK_STATS:
+		msg->req_type = TIPC_TLV_LINK_NAME;
+		doit.doit = tipc_nl_link_reset_stats;
+		doit.transcode = tipc_nl_compat_link_reset_stats;
+		return tipc_nl_compat_doit(&doit, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -754,6 +779,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_SET_LINK_TOL:
 	case TIPC_CMD_SET_LINK_PRI:
 	case TIPC_CMD_SET_LINK_WINDOW:
+	case TIPC_CMD_RESET_LINK_STATS:
 		return tipc_nl_compat_recv(skb, info);
 	}
 
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
