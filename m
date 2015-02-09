From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 12/17] tipc: convert legacy nl
	node addr set to nl compat
Date: Mon, 9 Feb 2015 09:50:14 +0100
Message-ID: <1423471819-23112-13-git-send-email-richard.alpe@ericsson.com>
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

Convert TIPC_CMD_SET_NODE_ADDR to compat doit.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         | 26 --------------------------
 net/tipc/net.c            |  2 +-
 net/tipc/netlink_compat.c | 26 ++++++++++++++++++++++++++
 3 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 74babd7..2a2d05b 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -134,29 +134,6 @@ static struct sk_buff *tipc_show_stats(void)
 	return buf;
 }
 
-static struct sk_buff *cfg_set_own_addr(struct net *net)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	u32 addr;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	addr = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (addr == tn->own_addr)
-		return tipc_cfg_reply_none();
-	if (!tipc_addr_node_valid(addr))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (node address)");
-	if (tn->own_addr)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (cannot change node address once assigned)");
-	if (!tipc_net_start(net, addr))
-		return tipc_cfg_reply_none();
-
-	return tipc_cfg_reply_error_string("cannot change to network mode");
-}
-
 static struct sk_buff *cfg_set_netid(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
@@ -208,9 +185,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
-	case TIPC_CMD_SET_NODE_ADDR:
-		rep_tlv_buf = cfg_set_own_addr(net);
-		break;
 	case TIPC_CMD_SET_NETID:
 		rep_tlv_buf = cfg_set_netid(net);
 		break;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 8b0fb09..e4028f9 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -208,7 +208,7 @@ out:
 
 int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 {
-	struct net *net = genl_info_net(info);
+	struct net *net = sock_net(skb->sk);
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct nlattr *attrs[TIPC_NLA_NET_MAX + 1];
 	int err;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 0dc448e..aa0e325 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -851,6 +851,26 @@ static int tipc_nl_compat_node_dump(struct tipc_nl_compat_msg *msg,
 			    sizeof(node_info));
 }
 
+static int tipc_nl_compat_net_set(struct sk_buff *skb,
+				  struct tipc_nl_compat_msg *msg)
+{
+	u32 val;
+	struct nlattr *net;
+
+	val = ntohl(*(__be32 *)TLV_DATA(msg->req));
+
+	net = nla_nest_start(skb, TIPC_NLA_NET);
+	if (!net)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, TIPC_NLA_NET_ADDR, val))
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, net);
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -924,6 +944,11 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_node_dump;
 		dump.format = tipc_nl_compat_node_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_SET_NODE_ADDR:
+		msg->req_type = TIPC_TLV_NET_ADDR;
+		doit.doit = tipc_nl_net_set;
+		doit.transcode = tipc_nl_compat_net_set;
+		return tipc_nl_compat_doit(&doit, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -1033,6 +1058,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_SHOW_PORTS:
 	case TIPC_CMD_GET_MEDIA_NAMES:
 	case TIPC_CMD_GET_NODES:
+	case TIPC_CMD_SET_NODE_ADDR:
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
