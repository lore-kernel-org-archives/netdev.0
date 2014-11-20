From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 07/14] tipc: add link set to
	new netlink api
Date: Thu, 20 Nov 2014 10:29:13 +0100
Message-ID: <1416475760-18914-8-git-send-email-richard.alpe@ericsson.com>
References: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_LINK_SET to the new tipc netlink API.

This command can set one or more link properties for a particular
link.

Netlink logical layout of link set message:
-> link
    -> name
    -> properties
        [ -> tolerance ]
        [ -> priority ]
        [ -> window ]

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |    1 +
 net/tipc/link.c                   |   73 +++++++++++++++++++++++++++++++++++++
 net/tipc/link.h                   |    1 +
 net/tipc/netlink.c                |    5 +++
 4 files changed, 80 insertions(+)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index 1034fb4..2deb7fd 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -48,6 +48,7 @@ enum {
 	TIPC_NL_SOCK_GET,
 	TIPC_NL_PUBL_GET,
 	TIPC_NL_LINK_GET,
+	TIPC_NL_LINK_SET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/net/tipc/link.c b/net/tipc/link.c
index bdc4b5e..6785dcf 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2441,6 +2441,79 @@ int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[])
 	return 0;
 }
 
+int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	int res = 0;
+	int bearer_id;
+	char *name;
+	struct tipc_link *link;
+	struct tipc_node *node;
+	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1];
+
+	if (!info->attrs[TIPC_NLA_LINK])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_LINK_MAX,
+			       info->attrs[TIPC_NLA_LINK],
+			       tipc_nl_link_policy);
+	if (err)
+		return err;
+
+	if (!attrs[TIPC_NLA_LINK_NAME])
+		return -EINVAL;
+
+	name = nla_data(attrs[TIPC_NLA_LINK_NAME]);
+
+	node = tipc_link_find_owner(name, &bearer_id);
+	if (!node)
+		return -EINVAL;
+
+	tipc_node_lock(node);
+
+	link = node->links[bearer_id];
+	if (!link) {
+		res = -EINVAL;
+		goto out;
+	}
+
+	if (attrs[TIPC_NLA_LINK_PROP]) {
+		struct nlattr *props[TIPC_NLA_PROP_MAX + 1];
+
+		err = tipc_nl_parse_link_prop(attrs[TIPC_NLA_LINK_PROP],
+					      props);
+		if (err) {
+			res = err;
+			goto out;
+		}
+
+		if (props[TIPC_NLA_PROP_TOL]) {
+			u32 tol;
+
+			tol = nla_get_u32(props[TIPC_NLA_PROP_TOL]);
+			link_set_supervision_props(link, tol);
+			tipc_link_proto_xmit(link, STATE_MSG, 0, 0, tol, 0, 0);
+		}
+		if (props[TIPC_NLA_PROP_PRIO]) {
+			u32 prio;
+
+			prio = nla_get_u32(props[TIPC_NLA_PROP_PRIO]);
+			link->priority = prio;
+			tipc_link_proto_xmit(link, STATE_MSG, 0, 0, 0, prio, 0);
+		}
+		if (props[TIPC_NLA_PROP_WIN]) {
+			u32 win;
+
+			win = nla_get_u32(props[TIPC_NLA_PROP_WIN]);
+			tipc_link_set_queue_limits(link, win);
+		}
+	}
+
+out:
+	tipc_node_unlock(node);
+
+	return res;
+}
 int __tipc_nl_add_stats(struct sk_buff *skb, struct tipc_stats *s)
 {
 	int i;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 8e3542a..3738ba1 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -242,6 +242,7 @@ void tipc_link_retransmit(struct tipc_link *l_ptr,
 
 int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[]);
 
 /*
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index ea168b8..d4444e5 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -144,6 +144,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.doit   = tipc_nl_link_get,
 		.dumpit	= tipc_nl_link_dump,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_LINK_SET,
+		.doit	= tipc_nl_link_set,
+		.policy = tipc_nl_policy,
 	}
 };
 
-- 
1.7.10.4


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
