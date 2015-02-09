From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 09/17] tipc: convert legacy nl
	socket dump to nl compat
Date: Mon, 9 Feb 2015 09:50:11 +0100
Message-ID: <1423471819-23112-10-git-send-email-richard.alpe@ericsson.com>
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

Convert socket (port) listing to compat dumpit call. If a socket
(port) has publications a second dumpit call is issued to collect them
and format then into the legacy buffer before continuing to process
the sockets (ports).

Command converted in this patch:
TIPC_CMD_SHOW_PORTS

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         |   3 --
 net/tipc/netlink_compat.c | 111 ++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/socket.c         |  85 -----------------------------------
 net/tipc/socket.h         |   1 -
 4 files changed, 111 insertions(+), 89 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 7b053fc..6e4c215 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -212,9 +212,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_GET_MEDIA_NAMES:
 		rep_tlv_buf = tipc_media_get_names();
 		break;
-	case TIPC_CMD_SHOW_PORTS:
-		rep_tlv_buf = tipc_sk_socks_show(net);
-		break;
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 40c24ea..48e15a4 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -36,6 +36,7 @@
 #include "bearer.h"
 #include "link.h"
 #include "name_table.h"
+#include "socket.h"
 #include <net/genetlink.h>
 #include <linux/tipc_config.h>
 
@@ -718,6 +719,109 @@ out:
 	return 0;
 }
 
+static int __tipc_nl_compat_publ_dump(struct tipc_nl_compat_msg *msg,
+				      struct nlattr **attrs)
+{
+	u32 type, lower, upper;
+	struct nlattr *publ[TIPC_NLA_PUBL_MAX + 1];
+
+	nla_parse_nested(publ, TIPC_NLA_PUBL_MAX, attrs[TIPC_NLA_PUBL], NULL);
+
+	type = nla_get_u32(publ[TIPC_NLA_PUBL_TYPE]);
+	lower = nla_get_u32(publ[TIPC_NLA_PUBL_LOWER]);
+	upper = nla_get_u32(publ[TIPC_NLA_PUBL_UPPER]);
+
+	if (lower == upper)
+		tipc_tlv_sprintf(msg->rep, " {%u,%u}", type, lower);
+	else
+		tipc_tlv_sprintf(msg->rep, " {%u,%u,%u}", type, lower, upper);
+
+	return 0;
+}
+
+static int tipc_nl_compat_publ_dump(struct tipc_nl_compat_msg *msg, u32 sock)
+{
+	int err;
+	void *hdr;
+	struct nlattr *nest;
+	struct sk_buff *args;
+	struct tipc_nl_compat_cmd_dump dump;
+
+	args = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!args)
+		return -ENOMEM;
+
+	hdr = genlmsg_put(args, 0, 0, &tipc_genl_family, NLM_F_MULTI,
+			  TIPC_NL_PUBL_GET);
+
+	nest = nla_nest_start(args, TIPC_NLA_SOCK);
+	if (!nest) {
+		kfree_skb(args);
+		return -EMSGSIZE;
+	}
+
+	if (nla_put_u32(args, TIPC_NLA_SOCK_REF, sock)) {
+		kfree_skb(args);
+		return -EMSGSIZE;
+	}
+
+	nla_nest_end(args, nest);
+	genlmsg_end(args, hdr);
+
+	dump.dumpit = tipc_nl_publ_dump;
+	dump.format = __tipc_nl_compat_publ_dump;
+
+	err = __tipc_nl_compat_dumpit(&dump, msg, args);
+
+	kfree_skb(args);
+
+	return err;
+}
+
+static int tipc_nl_compat_sk_dump(struct tipc_nl_compat_msg *msg,
+				  struct nlattr **attrs)
+{
+	int err;
+	u32 sock_ref;
+	struct nlattr *sock[TIPC_NLA_SOCK_MAX + 1];
+
+	nla_parse_nested(sock, TIPC_NLA_SOCK_MAX, attrs[TIPC_NLA_SOCK], NULL);
+
+	sock_ref = nla_get_u32(sock[TIPC_NLA_SOCK_REF]);
+	tipc_tlv_sprintf(msg->rep, "%u:", sock_ref);
+
+	if (sock[TIPC_NLA_SOCK_CON]) {
+		u32 node;
+		struct nlattr *con[TIPC_NLA_CON_MAX + 1];
+
+		nla_parse_nested(con, TIPC_NLA_CON_MAX, sock[TIPC_NLA_SOCK_CON],
+				 NULL);
+
+		node = nla_get_u32(con[TIPC_NLA_CON_NODE]);
+		tipc_tlv_sprintf(msg->rep, "  connected to <%u.%u.%u:%u>",
+				 tipc_zone(node),
+				 tipc_cluster(node),
+				 tipc_node(node),
+				 nla_get_u32(con[TIPC_NLA_CON_SOCK]));
+
+		if (con[TIPC_NLA_CON_FLAG])
+			tipc_tlv_sprintf(msg->rep, " via {%u,%u}\n",
+					 nla_get_u32(con[TIPC_NLA_CON_TYPE]),
+					 nla_get_u32(con[TIPC_NLA_CON_INST]));
+		else
+			tipc_tlv_sprintf(msg->rep, "\n");
+	} else if (sock[TIPC_NLA_SOCK_HAS_PUBL]) {
+		tipc_tlv_sprintf(msg->rep, " bound to");
+
+		err = tipc_nl_compat_publ_dump(msg, sock_ref);
+		if (err)
+			return err;
+	}
+	tipc_tlv_sprintf(msg->rep, "\n");
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -775,6 +879,12 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_name_table_dump;
 		dump.format = tipc_nl_compat_name_table_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_SHOW_PORTS:
+		msg->rep_size = ULTRA_STRING_MAX_LEN;
+		msg->rep_type = TIPC_TLV_ULTRA_STRING;
+		dump.dumpit = tipc_nl_sk_dump;
+		dump.format = tipc_nl_compat_sk_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -881,6 +991,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_SET_LINK_WINDOW:
 	case TIPC_CMD_RESET_LINK_STATS:
 	case TIPC_CMD_SHOW_NAME_TABLE:
+	case TIPC_CMD_SHOW_PORTS:
 		return tipc_nl_compat_recv(skb, info);
 	}
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d76c171..e77d738 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2281,91 +2281,6 @@ static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 	return rc;
 }
 
-static int tipc_sk_show(struct tipc_sock *tsk, char *buf,
-			int len, int full_id)
-{
-	struct net *net = sock_net(&tsk->sk);
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct publication *publ;
-	int ret;
-
-	if (full_id)
-		ret = tipc_snprintf(buf, len, "<%u.%u.%u:%u>:",
-				    tipc_zone(tn->own_addr),
-				    tipc_cluster(tn->own_addr),
-				    tipc_node(tn->own_addr), tsk->portid);
-	else
-		ret = tipc_snprintf(buf, len, "%-10u:", tsk->portid);
-
-	if (tsk->connected) {
-		u32 dport = tsk_peer_port(tsk);
-		u32 destnode = tsk_peer_node(tsk);
-
-		ret += tipc_snprintf(buf + ret, len - ret,
-				     " connected to <%u.%u.%u:%u>",
-				     tipc_zone(destnode),
-				     tipc_cluster(destnode),
-				     tipc_node(destnode), dport);
-		if (tsk->conn_type != 0)
-			ret += tipc_snprintf(buf + ret, len - ret,
-					     " via {%u,%u}", tsk->conn_type,
-					     tsk->conn_instance);
-	} else if (tsk->published) {
-		ret += tipc_snprintf(buf + ret, len - ret, " bound to");
-		list_for_each_entry(publ, &tsk->publications, pport_list) {
-			if (publ->lower == publ->upper)
-				ret += tipc_snprintf(buf + ret, len - ret,
-						     " {%u,%u}", publ->type,
-						     publ->lower);
-			else
-				ret += tipc_snprintf(buf + ret, len - ret,
-						     " {%u,%u,%u}", publ->type,
-						     publ->lower, publ->upper);
-		}
-	}
-	ret += tipc_snprintf(buf + ret, len - ret, "\n");
-	return ret;
-}
-
-struct sk_buff *tipc_sk_socks_show(struct net *net)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	const struct bucket_table *tbl;
-	struct rhash_head *pos;
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	char *pb;
-	int pb_len;
-	struct tipc_sock *tsk;
-	int str_len = 0;
-	int i;
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (!buf)
-		return NULL;
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-
-	rcu_read_lock();
-	tbl = rht_dereference_rcu((&tn->sk_rht)->tbl, &tn->sk_rht);
-	for (i = 0; i < tbl->size; i++) {
-		rht_for_each_entry_rcu(tsk, pos, tbl, i, node) {
-			spin_lock_bh(&tsk->sk.sk_lock.slock);
-			str_len += tipc_sk_show(tsk, pb + str_len,
-						pb_len - str_len, 0);
-			spin_unlock_bh(&tsk->sk.sk_lock.slock);
-		}
-	}
-	rcu_read_unlock();
-
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
 /* tipc_sk_reinit: set non-zero address in all existing sockets
  *                 when we go from standalone to network mode.
  */
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 8be0da7..238f1b7 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -49,7 +49,6 @@ void tipc_sock_release_local(struct socket *sock);
 int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
 			   int flags);
 int tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq);
-struct sk_buff *tipc_sk_socks_show(struct net *net);
 void tipc_sk_mcast_rcv(struct net *net, struct sk_buff_head *arrvq,
 		       struct sk_buff_head *inputq);
 void tipc_sk_reinit(struct net *net);
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
