From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 14/17] tipc: convert legacy nl
	net id get to nl compat
Date: Mon, 9 Feb 2015 09:50:16 +0100
Message-ID: <1423471819-23112-15-git-send-email-richard.alpe@ericsson.com>
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

Convert TIPC_CMD_GET_NETID to compat dumpit.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         | 23 -----------------------
 net/tipc/netlink_compat.c | 18 ++++++++++++++++++
 2 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 080cc92..019f46c 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -72,25 +72,6 @@ int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
 	return 1;
 }
 
-static struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value)
-{
-	struct sk_buff *buf;
-	__be32 value_net;
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(sizeof(value)));
-	if (buf) {
-		value_net = htonl(value);
-		tipc_cfg_append_tlv(buf, tlv_type, &value_net,
-				    sizeof(value_net));
-	}
-	return buf;
-}
-
-static struct sk_buff *tipc_cfg_reply_unsigned(u32 value)
-{
-	return tipc_cfg_reply_unsigned_type(TIPC_TLV_UNSIGNED, value);
-}
-
 struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
 {
 	struct sk_buff *buf;
@@ -139,7 +120,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 				int reply_headroom)
 {
 	struct sk_buff *rep_tlv_buf;
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	rtnl_lock();
 
@@ -165,9 +145,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
-	case TIPC_CMD_GET_NETID:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tn->net_id);
-		break;
 	case TIPC_CMD_NOT_NET_ADMIN:
 		rep_tlv_buf =
 			tipc_cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index c355476..4159090 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -876,6 +876,18 @@ static int tipc_nl_compat_net_set(struct sk_buff *skb,
 	return 0;
 }
 
+static int tipc_nl_compat_net_dump(struct tipc_nl_compat_msg *msg,
+				   struct nlattr **attrs)
+{
+	__be32 id;
+	struct nlattr *net[TIPC_NLA_NET_MAX + 1];
+
+	nla_parse_nested(net, TIPC_NLA_NET_MAX, attrs[TIPC_NLA_NET], NULL);
+	id = htonl(nla_get_u32(net[TIPC_NLA_NET_ID]));
+
+	return tipc_add_tlv(msg->rep, TIPC_TLV_UNSIGNED, &id, sizeof(id));
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -959,6 +971,11 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		doit.doit = tipc_nl_net_set;
 		doit.transcode = tipc_nl_compat_net_set;
 		return tipc_nl_compat_doit(&doit, msg);
+	case TIPC_CMD_GET_NETID:
+		msg->rep_size = sizeof(u32);
+		dump.dumpit = tipc_nl_net_dump;
+		dump.format = tipc_nl_compat_net_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -1070,6 +1087,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_GET_NODES:
 	case TIPC_CMD_SET_NODE_ADDR:
 	case TIPC_CMD_SET_NETID:
+	case TIPC_CMD_GET_NETID:
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
