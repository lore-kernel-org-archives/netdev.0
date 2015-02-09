From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 05/17] tipc: convert legacy nl
	link dump to nl compat
Date: Mon, 9 Feb 2015 09:50:07 +0100
Message-ID: <1423471819-23112-6-git-send-email-richard.alpe@ericsson.com>
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

Convert TIPC_CMD_GET_LINKS to compat dumpit and remove global link
counter solely used by the legacy API.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         |  4 ---
 net/tipc/netlink_compat.c | 23 +++++++++++++++
 net/tipc/node.c           | 73 -----------------------------------------------
 net/tipc/node.h           |  2 --
 4 files changed, 23 insertions(+), 79 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 67b76ee..1b17f58 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -209,10 +209,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_node_get_nodes(net, req_tlv_area,
 						  req_tlv_space);
 		break;
-	case TIPC_CMD_GET_LINKS:
-		rep_tlv_buf = tipc_node_get_links(net, req_tlv_area,
-						  req_tlv_space);
-		break;
 	case TIPC_CMD_RESET_LINK_STATS:
 		rep_tlv_buf = tipc_link_cmd_reset_stats(net, req_tlv_area,
 							req_tlv_space);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 899bd94..bff9403 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -553,6 +553,22 @@ static int tipc_nl_compat_link_stat_dump(struct tipc_nl_compat_msg *msg,
 	return 0;
 }
 
+static int tipc_nl_compat_link_dump(struct tipc_nl_compat_msg *msg,
+				    struct nlattr **attrs)
+{
+	struct nlattr *link[TIPC_NLA_LINK_MAX + 1];
+	struct tipc_link_info link_info;
+
+	nla_parse_nested(link, TIPC_NLA_LINK_MAX, attrs[TIPC_NLA_LINK], NULL);
+
+	link_info.dest = nla_get_flag(link[TIPC_NLA_LINK_DEST]);
+	link_info.up = htonl(nla_get_flag(link[TIPC_NLA_LINK_UP]));
+	strcpy(link_info.str, nla_data(link[TIPC_NLA_LINK_NAME]));
+
+	return tipc_add_tlv(msg->rep, TIPC_TLV_LINK_INFO,
+			    &link_info, sizeof(link_info));
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -584,6 +600,12 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_link_dump;
 		dump.format = tipc_nl_compat_link_stat_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_GET_LINKS:
+		msg->req_type = TIPC_TLV_NET_ADDR;
+		msg->rep_size = ULTRA_STRING_MAX_LEN;
+		dump.dumpit = tipc_nl_link_dump;
+		dump.format = tipc_nl_compat_link_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -684,6 +706,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_ENABLE_BEARER:
 	case TIPC_CMD_DISABLE_BEARER:
 	case TIPC_CMD_SHOW_LINK_STATS:
+	case TIPC_CMD_GET_LINKS:
 		return tipc_nl_compat_recv(skb, info);
 	}
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 995618d..46b87f7 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -319,27 +319,18 @@ int tipc_node_is_up(struct tipc_node *n_ptr)
 
 void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
-	struct tipc_net *tn = net_generic(n_ptr->net, tipc_net_id);
-
 	n_ptr->links[l_ptr->bearer_id] = l_ptr;
-	spin_lock_bh(&tn->node_list_lock);
-	tn->num_links++;
-	spin_unlock_bh(&tn->node_list_lock);
 	n_ptr->link_cnt++;
 }
 
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
-	struct tipc_net *tn = net_generic(n_ptr->net, tipc_net_id);
 	int i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		if (l_ptr != n_ptr->links[i])
 			continue;
 		n_ptr->links[i] = NULL;
-		spin_lock_bh(&tn->node_list_lock);
-		tn->num_links--;
-		spin_unlock_bh(&tn->node_list_lock);
 		n_ptr->link_cnt--;
 	}
 }
@@ -467,70 +458,6 @@ struct sk_buff *tipc_node_get_nodes(struct net *net, const void *req_tlv_area,
 	return buf;
 }
 
-struct sk_buff *tipc_node_get_links(struct net *net, const void *req_tlv_area,
-				    int req_tlv_space)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	u32 domain;
-	struct sk_buff *buf;
-	struct tipc_node *n_ptr;
-	struct tipc_link_info link_info;
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
-	if (!tn->own_addr)
-		return tipc_cfg_reply_none();
-
-	spin_lock_bh(&tn->node_list_lock);
-	/* Get space for all unicast links + broadcast link */
-	payload_size = TLV_SPACE((sizeof(link_info)) * (tn->num_links + 1));
-	if (payload_size > 32768u) {
-		spin_unlock_bh(&tn->node_list_lock);
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (too many links)");
-	}
-	spin_unlock_bh(&tn->node_list_lock);
-
-	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf)
-		return NULL;
-
-	/* Add TLV for broadcast link */
-	link_info.dest = htonl(tipc_cluster_mask(tn->own_addr));
-	link_info.up = htonl(1);
-	strlcpy(link_info.str, tipc_bclink_name, TIPC_MAX_LINK_NAME);
-	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
-
-	/* Add TLVs for any other links in scope */
-	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
-		u32 i;
-
-		if (!tipc_in_scope(domain, n_ptr->addr))
-			continue;
-		tipc_node_lock(n_ptr);
-		for (i = 0; i < MAX_BEARERS; i++) {
-			if (!n_ptr->links[i])
-				continue;
-			link_info.dest = htonl(n_ptr->addr);
-			link_info.up = htonl(tipc_link_is_up(n_ptr->links[i]));
-			strcpy(link_info.str, n_ptr->links[i]->name);
-			tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO,
-					    &link_info, sizeof(link_info));
-		}
-		tipc_node_unlock(n_ptr);
-	}
-	rcu_read_unlock();
-	return buf;
-}
-
 /**
  * tipc_node_get_linkname - get the name of a link
  *
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 20ec13f..59dafee 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -142,8 +142,6 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 int tipc_node_active_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
-struct sk_buff *tipc_node_get_links(struct net *net, const void *req_tlv_area,
-				    int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(struct net *net, const void *req_tlv_area,
 				    int req_tlv_space);
 int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 node,
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
