From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 06/17] tipc: convert legacy nl
	link prop set to nl compat
Date: Mon, 9 Feb 2015 09:50:08 +0100
Message-ID: <1423471819-23112-7-git-send-email-richard.alpe@ericsson.com>
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

Convert setting of link proprieties to compat doit calls.

Commands converted in this patch:
TIPC_CMD_SET_LINK_TOL
TIPC_CMD_SET_LINK_PRI
TIPC_CMD_SET_LINK_WINDOW

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         |   6 --
 net/tipc/link.c           | 146 +---------------------------------------------
 net/tipc/link.h           |   2 -
 net/tipc/netlink_compat.c |  47 +++++++++++++++
 4 files changed, 48 insertions(+), 153 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 1b17f58..75a130e 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -226,12 +226,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
-	case TIPC_CMD_SET_LINK_TOL:
-	case TIPC_CMD_SET_LINK_PRI:
-	case TIPC_CMD_SET_LINK_WINDOW:
-		rep_tlv_buf = tipc_link_cmd_config(net, req_tlv_area,
-						   req_tlv_space, cmd);
-		break;
 	case TIPC_CMD_SET_NODE_ADDR:
 		rep_tlv_buf = cfg_set_own_addr(net);
 		break;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2622fb9..ec136b5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1959,150 +1959,6 @@ static struct tipc_node *tipc_link_find_owner(struct net *net,
 }
 
 /**
- * link_value_is_valid -- validate proposed link tolerance/priority/window
- *
- * @cmd: value type (TIPC_CMD_SET_LINK_*)
- * @new_value: the new value
- *
- * Returns 1 if value is within range, 0 if not.
- */
-static int link_value_is_valid(u16 cmd, u32 new_value)
-{
-	switch (cmd) {
-	case TIPC_CMD_SET_LINK_TOL:
-		return (new_value >= TIPC_MIN_LINK_TOL) &&
-			(new_value <= TIPC_MAX_LINK_TOL);
-	case TIPC_CMD_SET_LINK_PRI:
-		return (new_value <= TIPC_MAX_LINK_PRI);
-	case TIPC_CMD_SET_LINK_WINDOW:
-		return (new_value >= TIPC_MIN_LINK_WIN) &&
-			(new_value <= TIPC_MAX_LINK_WIN);
-	}
-	return 0;
-}
-
-/**
- * link_cmd_set_value - change priority/tolerance/window for link/bearer/media
- * @net: the applicable net namespace
- * @name: ptr to link, bearer, or media name
- * @new_value: new value of link, bearer, or media setting
- * @cmd: which link, bearer, or media attribute to set (TIPC_CMD_SET_LINK_*)
- *
- * Caller must hold RTNL lock to ensure link/bearer/media is not deleted.
- *
- * Returns 0 if value updated and negative value on error.
- */
-static int link_cmd_set_value(struct net *net, const char *name, u32 new_value,
-			      u16 cmd)
-{
-	struct tipc_node *node;
-	struct tipc_link *l_ptr;
-	struct tipc_bearer *b_ptr;
-	struct tipc_media *m_ptr;
-	int bearer_id;
-	int res = 0;
-
-	node = tipc_link_find_owner(net, name, &bearer_id);
-	if (node) {
-		tipc_node_lock(node);
-		l_ptr = node->links[bearer_id];
-
-		if (l_ptr) {
-			switch (cmd) {
-			case TIPC_CMD_SET_LINK_TOL:
-				link_set_supervision_props(l_ptr, new_value);
-				tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0,
-						     new_value, 0, 0);
-				break;
-			case TIPC_CMD_SET_LINK_PRI:
-				l_ptr->priority = new_value;
-				tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0,
-						     0, new_value, 0);
-				break;
-			case TIPC_CMD_SET_LINK_WINDOW:
-				tipc_link_set_queue_limits(l_ptr, new_value);
-				break;
-			default:
-				res = -EINVAL;
-				break;
-			}
-		}
-		tipc_node_unlock(node);
-		return res;
-	}
-
-	b_ptr = tipc_bearer_find(net, name);
-	if (b_ptr) {
-		switch (cmd) {
-		case TIPC_CMD_SET_LINK_TOL:
-			b_ptr->tolerance = new_value;
-			break;
-		case TIPC_CMD_SET_LINK_PRI:
-			b_ptr->priority = new_value;
-			break;
-		case TIPC_CMD_SET_LINK_WINDOW:
-			b_ptr->window = new_value;
-			break;
-		default:
-			res = -EINVAL;
-			break;
-		}
-		return res;
-	}
-
-	m_ptr = tipc_media_find(name);
-	if (!m_ptr)
-		return -ENODEV;
-	switch (cmd) {
-	case TIPC_CMD_SET_LINK_TOL:
-		m_ptr->tolerance = new_value;
-		break;
-	case TIPC_CMD_SET_LINK_PRI:
-		m_ptr->priority = new_value;
-		break;
-	case TIPC_CMD_SET_LINK_WINDOW:
-		m_ptr->window = new_value;
-		break;
-	default:
-		res = -EINVAL;
-		break;
-	}
-	return res;
-}
-
-struct sk_buff *tipc_link_cmd_config(struct net *net, const void *req_tlv_area,
-				     int req_tlv_space, u16 cmd)
-{
-	struct tipc_link_config *args;
-	u32 new_value;
-	int res;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_CONFIG))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	args = (struct tipc_link_config *)TLV_DATA(req_tlv_area);
-	new_value = ntohl(args->value);
-
-	if (!link_value_is_valid(cmd, new_value))
-		return tipc_cfg_reply_error_string(
-			"cannot change, value invalid");
-
-	if (!strcmp(args->name, tipc_bclink_name)) {
-		if ((cmd == TIPC_CMD_SET_LINK_WINDOW) &&
-		    (tipc_bclink_set_queue_limits(net, new_value) == 0))
-			return tipc_cfg_reply_none();
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (cannot change setting on broadcast link)");
-	}
-
-	res = link_cmd_set_value(net, args->name, new_value, cmd);
-	if (res)
-		return tipc_cfg_reply_error_string("cannot change link setting");
-
-	return tipc_cfg_reply_none();
-}
-
-/**
  * link_reset_statistics - reset link statistics
  * @l_ptr: pointer to link
  */
@@ -2216,7 +2072,7 @@ int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info)
 	struct tipc_link *link;
 	struct tipc_node *node;
 	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1];
-	struct net *net = genl_info_net(info);
+	struct net *net = sock_net(skb->sk);
 
 	if (!info->attrs[TIPC_NLA_LINK])
 		return -EINVAL;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 8c8340c..6eb9d60 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -215,8 +215,6 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
 void tipc_link_purge_queues(struct tipc_link *l_ptr);
-struct sk_buff *tipc_link_cmd_config(struct net *net, const void *req_tlv_area,
-				     int req_tlv_space, u16 cmd);
 struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
 					  const void *req_tlv_area,
 					  int req_tlv_space);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index bff9403..056532b 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -569,6 +569,43 @@ static int tipc_nl_compat_link_dump(struct tipc_nl_compat_msg *msg,
 			    &link_info, sizeof(link_info));
 }
 
+static int tipc_nl_compat_link_set(struct sk_buff *skb,
+				   struct tipc_nl_compat_msg *msg)
+{
+	struct nlattr *link;
+	struct nlattr *prop;
+	struct tipc_link_config *lc;
+
+	lc = (struct tipc_link_config *)TLV_DATA(msg->req);
+
+	link = nla_nest_start(skb, TIPC_NLA_LINK);
+	if (!link)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, TIPC_NLA_LINK_NAME, lc->name))
+		return -EMSGSIZE;
+
+	prop = nla_nest_start(skb, TIPC_NLA_LINK_PROP);
+	if (!prop)
+		return -EMSGSIZE;
+
+	if (msg->cmd == TIPC_CMD_SET_LINK_PRI) {
+		if (nla_put_u32(skb, TIPC_NLA_PROP_PRIO, ntohl(lc->value)))
+			return -EMSGSIZE;
+	} else if (msg->cmd == TIPC_CMD_SET_LINK_TOL) {
+		if (nla_put_u32(skb, TIPC_NLA_PROP_TOL, ntohl(lc->value)))
+			return -EMSGSIZE;
+	} else if (msg->cmd == TIPC_CMD_SET_LINK_WINDOW) {
+		if (nla_put_u32(skb, TIPC_NLA_PROP_WIN, ntohl(lc->value)))
+			return -EMSGSIZE;
+	}
+
+	nla_nest_end(skb, prop);
+	nla_nest_end(skb, link);
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -606,6 +643,13 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_link_dump;
 		dump.format = tipc_nl_compat_link_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_SET_LINK_TOL:
+	case TIPC_CMD_SET_LINK_PRI:
+	case TIPC_CMD_SET_LINK_WINDOW:
+		msg->req_type =  TIPC_TLV_LINK_CONFIG;
+		doit.doit = tipc_nl_link_set;
+		doit.transcode = tipc_nl_compat_link_set;
+		return tipc_nl_compat_doit(&doit, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -707,6 +751,9 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_DISABLE_BEARER:
 	case TIPC_CMD_SHOW_LINK_STATS:
 	case TIPC_CMD_GET_LINKS:
+	case TIPC_CMD_SET_LINK_TOL:
+	case TIPC_CMD_SET_LINK_PRI:
+	case TIPC_CMD_SET_LINK_WINDOW:
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
