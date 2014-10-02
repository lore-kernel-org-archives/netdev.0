From: <richard.alpe@ericsson.com>
Subject: [PATCH v2 net-next 04/15] tipc: add sock dump to
	new netlink api
Date: Thu, 2 Oct 2014 16:58:30 +0200
Message-ID: <1412261921-28510-5-git-send-email-richard.alpe@ericsson.com>
References: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
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
    -> publication flag
    ]

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc_config.h |   28 +++++++++++
 net/tipc/netlink.c               |    7 +++
 net/tipc/socket.c                |  101 ++++++++++++++++++++++++++++++++++++++
 net/tipc/socket.h                |    2 +
 4 files changed, 138 insertions(+)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index af7acac..b49e43a 100644
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
@@ -79,6 +81,32 @@ enum {
 	TIPC_NLA_BEARER_MAX = __TIPC_NLA_BEARER_MAX - 1
 };
 
+/* Socket info */
+enum {
+	TIPC_NLA_SOCK_UNSPEC,
+	TIPC_NLA_SOCK_ADDR,		/* u32 */
+	TIPC_NLA_SOCK_REF,		/* u32 */
+	TIPC_NLA_SOCK_CON,		/* nest */
+	TIPC_NLA_SOCK_HAS_PUBL,		/* flag */
+
+	__TIPC_NLA_SOCK_MAX,
+	TIPC_NLA_SOCK_MAX = __TIPC_NLA_SOCK_MAX - 1
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
index 75275c5..d1c725a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2802,3 +2802,104 @@ void tipc_socket_stop(void)
 	sock_unregister(tipc_family_ops.family);
 	proto_unregister(&tipc_proto);
 }
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
+		     struct tipc_sock *tsk)
+{
+	int err;
+	void *hdr;
+	struct nlattr *attrs;
+
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
+			  &tipc_genl_family, NLM_F_MULTI, TIPC_NL_SOCK_GET);
+	if (!hdr)
+		goto msg_cancel;
+
+	attrs = nla_nest_start(skb, TIPC_NLA_SOCK);
+	if (!attrs)
+		goto genlmsg_cancel;
+	if (nla_put_u32(skb, TIPC_NLA_SOCK_REF, tsk->ref))
+		goto attr_msg_cancel;
+	if (nla_put_u32(skb, TIPC_NLA_SOCK_ADDR, tipc_own_addr))
+		goto attr_msg_cancel;
+
+	if (tsk->connected) {
+		err = __tipc_nl_add_sk_con(skb, tsk);
+		if (err)
+			goto attr_msg_cancel;
+	} else if (!list_empty(&tsk->publications)) {
+		if (nla_put_flag(skb, TIPC_NLA_SOCK_HAS_PUBL))
+			goto attr_msg_cancel;
+	}
+	nla_nest_end(skb, attrs);
+	genlmsg_end(skb, hdr);
+
+	return 0;
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
+	u32 prev_ref = cb->args[0];
+	u32 ref = prev_ref;
+
+	tsk = tipc_sk_get_next(&ref);
+	for (; tsk; tsk = tipc_sk_get_next(&ref)) {
+		lock_sock(&tsk->sk);
+		err = __tipc_nl_add_sk(skb, cb, tsk);
+		release_sock(&tsk->sk);
+		tipc_sk_put(tsk);
+		if (err)
+			break;
+
+		prev_ref = ref;
+	}
+
+	cb->args[0] = prev_ref;
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
Meet PCI DSS 3.0 Compliance Requirements with EventLog Analyzer
Achieve PCI DSS 3.0 Compliant Status with Out-of-the-box PCI DSS Reports
Are you Audit-Ready for PCI DSS 3.0 Compliance? Download White paper
Comply to PCI DSS 3.0 Requirement 10 and 11.5 with EventLog Analyzer
http://pubads.g.doubleclick.net/gampad/clk?id=154622311&iu=/4140/ostg.clktrk
