From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 13/17] tipc: convert legacy nl
	net id set to nl compat
Date: Mon, 9 Feb 2015 09:50:15 +0100
Message-ID: <1423471819-23112-14-git-send-email-richard.alpe@ericsson.com>
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

Convert TIPC_CMD_SET_NETID to compat doit.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         | 23 -----------------------
 net/tipc/netlink_compat.c | 17 ++++++++++++++---
 2 files changed, 14 insertions(+), 26 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 2a2d05b..080cc92 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -134,26 +134,6 @@ static struct sk_buff *tipc_show_stats(void)
 	return buf;
 }
 
-static struct sk_buff *cfg_set_netid(struct net *net)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value == tn->net_id)
-		return tipc_cfg_reply_none();
-	if (value < 1 || value > 9999)
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (network id must be 1-9999)");
-	if (tn->own_addr)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-			" (cannot change network id once TIPC has joined a network)");
-	tn->net_id = value;
-	return tipc_cfg_reply_none();
-}
-
 struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 				const void *request_area, int request_space,
 				int reply_headroom)
@@ -185,9 +165,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
-	case TIPC_CMD_SET_NETID:
-		rep_tlv_buf = cfg_set_netid(net);
-		break;
 	case TIPC_CMD_GET_NETID:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tn->net_id);
 		break;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index aa0e325..c355476 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -38,6 +38,7 @@
 #include "name_table.h"
 #include "socket.h"
 #include "node.h"
+#include "net.h"
 #include <net/genetlink.h>
 #include <linux/tipc_config.h>
 
@@ -863,9 +864,13 @@ static int tipc_nl_compat_net_set(struct sk_buff *skb,
 	if (!net)
 		return -EMSGSIZE;
 
-	if (nla_put_u32(skb, TIPC_NLA_NET_ADDR, val))
-		return -EMSGSIZE;
-
+	if (msg->cmd == TIPC_CMD_SET_NODE_ADDR) {
+		if (nla_put_u32(skb, TIPC_NLA_NET_ADDR, val))
+			return -EMSGSIZE;
+	} else if (msg->cmd == TIPC_CMD_SET_NETID) {
+		if (nla_put_u32(skb, TIPC_NLA_NET_ID, val))
+			return -EMSGSIZE;
+	}
 	nla_nest_end(skb, net);
 
 	return 0;
@@ -949,6 +954,11 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		doit.doit = tipc_nl_net_set;
 		doit.transcode = tipc_nl_compat_net_set;
 		return tipc_nl_compat_doit(&doit, msg);
+	case TIPC_CMD_SET_NETID:
+		msg->req_type = TIPC_TLV_UNSIGNED;
+		doit.doit = tipc_nl_net_set;
+		doit.transcode = tipc_nl_compat_net_set;
+		return tipc_nl_compat_doit(&doit, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -1059,6 +1069,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_GET_MEDIA_NAMES:
 	case TIPC_CMD_GET_NODES:
 	case TIPC_CMD_SET_NODE_ADDR:
+	case TIPC_CMD_SET_NETID:
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
