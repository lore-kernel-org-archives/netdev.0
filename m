From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 15/17] tipc: convert legacy nl
	stats show to nl compat
Date: Mon, 9 Feb 2015 09:50:17 +0100
Message-ID: <1423471819-23112-16-git-send-email-richard.alpe@ericsson.com>
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

Convert TIPC_CMD_SHOW_STATS to compat layer. This command does not
have any counterpart in the new API, meaning it now solely exists as a
function in the compat layer.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         | 35 -----------------------------------
 net/tipc/netlink_compat.c | 15 +++++++++++++++
 2 files changed, 15 insertions(+), 35 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 019f46c..c2ad2ff 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -83,38 +83,6 @@ struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
 	return buf;
 }
 
-static struct sk_buff *tipc_show_stats(void)
-{
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	char *pb;
-	int pb_len;
-	int str_len;
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	value = ntohl(*(u32 *)TLV_DATA(req_tlv_area));
-	if (value != 0)
-		return tipc_cfg_reply_error_string("unsupported argument");
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (buf == NULL)
-		return NULL;
-
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-
-	str_len = tipc_snprintf(pb, pb_len, "TIPC version " TIPC_MOD_VER "\n");
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
 struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 				const void *request_area, int request_space,
 				int reply_headroom)
@@ -142,9 +110,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_NOOP:
 		rep_tlv_buf = tipc_cfg_reply_none();
 		break;
-	case TIPC_CMD_SHOW_STATS:
-		rep_tlv_buf = tipc_show_stats();
-		break;
 	case TIPC_CMD_NOT_NET_ADMIN:
 		rep_tlv_buf =
 			tipc_cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 4159090..cb9086d 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -888,6 +888,18 @@ static int tipc_nl_compat_net_dump(struct tipc_nl_compat_msg *msg,
 	return tipc_add_tlv(msg->rep, TIPC_TLV_UNSIGNED, &id, sizeof(id));
 }
 
+static int tipc_cmd_show_stats_compat(struct tipc_nl_compat_msg *msg)
+{
+	msg->rep = tipc_tlv_alloc(ULTRA_STRING_MAX_LEN);
+	if (!msg->rep)
+		return -ENOMEM;
+
+	tipc_tlv_init(msg->rep, TIPC_TLV_ULTRA_STRING);
+	tipc_tlv_sprintf(msg->rep, "TIPC version " TIPC_MOD_VER "\n");
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -976,6 +988,8 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_net_dump;
 		dump.format = tipc_nl_compat_net_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_SHOW_STATS:
+		return tipc_cmd_show_stats_compat(msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -1088,6 +1102,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_SET_NODE_ADDR:
 	case TIPC_CMD_SET_NETID:
 	case TIPC_CMD_GET_NETID:
+	case TIPC_CMD_SHOW_STATS:
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
