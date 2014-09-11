From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next 04/14] tipc: add sock dump to new
	netlink api
Date: Thu, 11 Sep 2014 10:29:17 +0200
Message-ID: <1410424167-17427-5-git-send-email-richard.alpe@ericsson.com>
References: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_SOCK_GET command to the new tipc netlink API.

This command supports dumping of all available sockets with their
associated connection or publication(s). It could be extended to reply
with a single socket if the NLM_F_DUMP isn't set.

The information about a socket includes reference, address, connection
information / publication information.

Netlink logical layout of response message:
-> socket
    -> reference
    -> address
    [
    -> connection
        -> node
        -> socket
        [
        -> connected flag
        -> type
        -> instance
        ]
    ]
    [
    -> publications
        -> publication
            -> type
            -> lower
            -> upper
    ]

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_config.h |   44 +++++++++++
 net/tipc/netlink.c               |    7 ++
 net/tipc/socket.c                |  159 ++++++++++++++++++++++++++++++++++++++
 net/tipc/socket.h                |    2 +
 4 files changed, 212 insertions(+)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index af7acac..e09dec2 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -54,6 +54,7 @@ enum {
 	TIPC_NL_BEARER_ENABLE,
 	TIPC_NL_BEARER_GET,
 	TIPC_NL_BEARER_SET,
+	TIPC_NL_SOCK_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -63,6 +64,7 @@ enum {
 enum {
 	TIPC_NLA_UNSPEC,
 	TIPC_NLA_BEARER,		/* nest */
+	TIPC_NLA_SOCK,			/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -79,6 +81,48 @@ enum {
 	TIPC_NLA_BEARER_MAX = __TIPC_NLA_BEARER_MAX - 1
 };
 
+/* Port info */
+enum {
+	TIPC_NLA_SOCK_UNSPEC,
+	TIPC_NLA_SOCK_ADDR,		/* u32 */
+	TIPC_NLA_SOCK_REF,		/* u32 */
+	TIPC_NLA_SOCK_CON,		/* nest */
+	TIPC_NLA_SOCK_PUBL,		/* nest */
+
+	__TIPC_NLA_SOCK_MAX,
+	TIPC_NLA_SOCK_MAX = __TIPC_NLA_SOCK_MAX - 1
+};
+
+/* Nest, publication info */
+enum {
+	TIPC_NLA_PUBL_UNSPEC,
+
+	TIPC_NLA_PUBL_TYPE,		/* u32 */
+	TIPC_NLA_PUBL_LOWER,		/* u32 */
+	TIPC_NLA_PUBL_UPPER,		/* u32 */
+	TIPC_NLA_PUBL_SCOPE,		/* u32 */
+	TIPC_NLA_PUBL_NODE,		/* u32 */
+	TIPC_NLA_PUBL_REF,		/* u32 */
+	TIPC_NLA_PUBL_KEY,		/* u32 */
+
+	__TIPC_NLA_PUBL_MAX,
+	TIPC_NLA_PUBL_MAX = __TIPC_NLA_PUBL_MAX - 1
+};
+
+/* Nest, connection info */
+enum {
+	TIPC_NLA_CON_UNSPEC,
+
+	TIPC_NLA_CON_FLAG,		/* flag */
+	TIPC_NLA_CON_NODE,		/* u32 */
+	TIPC_NLA_CON_SOCK,		/* u32 */
+	TIPC_NLA_CON_TYPE,		/* u32 */
+	TIPC_NLA_CON_INST,		/* u32 */
+
+	__TIPC_NLA_CON_MAX,
+	TIPC_NLA_CON_MAX = __TIPC_NLA_CON_MAX - 1
+};
+
 /* Nest, link propreties. Valid for link, media and bearer */
 enum {
 	TIPC_NLA_PROP_UNSPEC,
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index e5fbea9..52973ce 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -36,6 +36,7 @@
 
 #include "core.h"
 #include "config.h"
+#include "socket.h"
 #include "bearer.h"
 #include <net/genetlink.h>
 
@@ -72,6 +73,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_UNSPEC]	= { .type = NLA_UNSPEC, },
 	[TIPC_NLA_BEARER]	= { .type = NLA_NESTED, },
+	[TIPC_NLA_SOCK]		= { .type = NLA_NESTED, },
 };
 
 struct genl_family tipc_genl_family = {
@@ -108,6 +110,11 @@ static const struct genl_ops tipc_genl_ops[] = {
 		.cmd	= TIPC_NL_BEARER_SET,
 		.doit	= tipc_nl_bearer_set,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_SOCK_GET,
+		.dumpit	= tipc_nl_sk_dump,
+		.policy = tipc_nl_policy,
 	}
 };
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 75275c5..bb58029 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2802,3 +2802,162 @@ void tipc_socket_stop(void)
 	sock_unregister(tipc_family_ops.family);
 	proto_unregister(&tipc_proto);
 }
+
+/* Caller should hold socket lock for the passed tipc socket. */
+int __tipc_nl_list_sk_publ(struct sk_buff *skb, struct netlink_callback *cb,
+			   struct tipc_sock *tsk, u32 *prev_publ)
+{
+	struct nlattr *publ;
+	struct publication *p;
+
+	if (*prev_publ) {
+		list_for_each_entry(p, &tsk->publications, pport_list) {
+			if (p->key == *prev_publ)
+				break;
+		}
+
+		if (p->key != *prev_publ) {
+			nlmsg_hdr(skb)->nlmsg_flags |= NLM_F_DUMP_INTR;
+			*prev_publ = 0;
+			return -EPIPE;
+		}
+	} else {
+		p = list_first_entry(&tsk->publications, struct publication,
+				     pport_list);
+	}
+
+	list_for_each_entry_from(p, &tsk->publications, pport_list) {
+		publ = nla_nest_start(skb, TIPC_NLA_SOCK_PUBL);
+		if (nla_put_u32(skb, TIPC_NLA_PUBL_TYPE, p->type))
+			goto msg_full;
+		if (nla_put_u32(skb, TIPC_NLA_PUBL_LOWER, p->lower))
+			goto msg_full;
+		if (nla_put_u32(skb, TIPC_NLA_PUBL_UPPER, p->upper))
+			goto msg_full;
+		nla_nest_end(skb, publ);
+	}
+
+	*prev_publ = 0;
+
+	return 0;
+
+msg_full:
+	*prev_publ = p->key;
+	nla_nest_cancel(skb, publ);
+
+	return -EMSGSIZE;
+}
+
+/* Caller should hold socket lock for the passed tipc socket. */
+int __tipc_nl_add_sk_con(struct sk_buff *skb, struct tipc_sock *tsk)
+{
+	u32 peer_node;
+	u32 peer_port;
+	struct nlattr *nest;
+
+	peer_node = tsk_peer_node(tsk);
+	peer_port = tsk_peer_port(tsk);
+
+	nest = nla_nest_start(skb, TIPC_NLA_SOCK_CON);
+
+	if (nla_put_u32(skb, TIPC_NLA_CON_NODE, peer_node))
+		goto msg_full;
+	if (nla_put_u32(skb, TIPC_NLA_CON_SOCK, peer_port))
+		goto msg_full;
+
+	if (tsk->conn_type != 0) {
+		if (nla_put_flag(skb, TIPC_NLA_CON_FLAG))
+			goto msg_full;
+		if (nla_put_u32(skb, TIPC_NLA_CON_TYPE, tsk->conn_type))
+			goto msg_full;
+		if (nla_put_u32(skb, TIPC_NLA_CON_INST, tsk->conn_instance))
+			goto msg_full;
+	}
+	nla_nest_end(skb, nest);
+
+	return 0;
+
+msg_full:
+	nla_nest_cancel(skb, nest);
+
+	return -EMSGSIZE;
+}
+
+/* Caller should hold socket lock for the passed tipc socket. */
+int __tipc_nl_add_sk(struct sk_buff *skb, struct netlink_callback *cb,
+		     struct tipc_sock *tsk, u32 *prev_publ)
+{
+	void *hdr;
+	int res = 0;
+	struct nlattr *attrs;
+	struct nlattr *publs;
+
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
+			  &tipc_genl_family, NLM_F_MULTI, TIPC_NL_SOCK_GET);
+	if (!hdr)
+		goto msg_cancel;
+
+	attrs = nla_nest_start(skb, TIPC_NLA_SOCK);
+	if (!attrs)
+		goto genlmsg_cancel;
+
+	if (nla_put_u32(skb, TIPC_NLA_SOCK_REF, tsk->ref))
+		goto attr_msg_cancel;
+	if (nla_put_u32(skb, TIPC_NLA_SOCK_ADDR, tipc_own_addr))
+		goto attr_msg_cancel;
+
+	/* We assume a socket is either connected or published */
+	if (tsk->connected) {
+		res = __tipc_nl_add_sk_con(skb, tsk);
+		if (res != 0)
+			goto attr_msg_cancel;
+	} else {
+		publs = nla_nest_start(skb, TIPC_NLA_SOCK_PUBL);
+		if (!publs)
+			goto attr_msg_cancel;
+
+		res = __tipc_nl_list_sk_publ(skb, cb, tsk, prev_publ);
+		/* As the publication count is arbitrary large, we send even an
+		 * incomplete listing.
+		 */
+		nla_nest_end(skb, publs);
+	}
+
+	nla_nest_end(skb, attrs);
+	genlmsg_end(skb, hdr);
+
+	return res;
+
+attr_msg_cancel:
+	nla_nest_cancel(skb, attrs);
+genlmsg_cancel:
+	genlmsg_cancel(skb, hdr);
+msg_cancel:
+	return -EMSGSIZE;
+}
+
+int tipc_nl_sk_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int err;
+	struct tipc_sock *tsk;
+	u32 prev_tsk = cb->args[0];
+	u32 prev_publ = cb->args[1];
+	u32 tsk_ref = prev_tsk;
+
+	tsk = tipc_sk_get_next(&tsk_ref);
+	for (; tsk; tsk = tipc_sk_get_next(&tsk_ref)) {
+		lock_sock(&tsk->sk);
+		err = __tipc_nl_add_sk(skb, cb, tsk, &prev_publ);
+		release_sock(&tsk->sk);
+		tipc_sk_put(tsk);
+		if (err)
+			break;
+
+		prev_tsk = tsk_ref;
+	}
+
+	cb->args[0] = prev_tsk;
+	cb->args[1] = prev_publ;
+
+	return skb->len;
+}
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index baa43d0..16dfd62 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -36,6 +36,7 @@
 #define _TIPC_SOCK_H
 
 #include <net/sock.h>
+#include <net/genetlink.h>
 
 #define TIPC_CONNACK_INTV         256
 #define TIPC_FLOWCTRL_WIN        (TIPC_CONNACK_INTV * 2)
@@ -47,5 +48,6 @@ void tipc_sk_mcast_rcv(struct sk_buff *buf);
 void tipc_sk_reinit(void);
 int tipc_sk_ref_table_init(u32 requested_size, u32 start);
 void tipc_sk_ref_table_stop(void);
+int tipc_nl_sk_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
 #endif
-- 
1.7.10.4


------------------------------------------------------------------------------
Want excitement?
Manually upgrade your production database.
When you want reliability, choose Perforce
Perforce version control. Predictably reliable.
http://pubads.g.doubleclick.net/gampad/clk?id=157508191&iu=/4140/ostg.clktrk
