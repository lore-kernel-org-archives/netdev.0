From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 08/14] tipc: add link stat
	reset to new netlink api
Date: Thu, 20 Nov 2014 10:29:14 +0100
Message-ID: <1416475760-18914-9-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_LINK_RESET_STATS command to the new netlink API.

This command resets the link statistics for a particular link.

Netlink logical layout of link reset message:
-> link
    -> name

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |    1 +
 net/tipc/link.c                   |   49 +++++++++++++++++++++++++++++++++++++
 net/tipc/link.h                   |    1 +
 net/tipc/netlink.c                |    5 ++++
 4 files changed, 56 insertions(+)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index 2deb7fd..574882a 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -49,6 +49,7 @@ enum {
 	TIPC_NL_PUBL_GET,
 	TIPC_NL_LINK_GET,
 	TIPC_NL_LINK_SET,
+	TIPC_NL_LINK_RESET_STATS,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6785dcf..629e8cf 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2783,3 +2783,52 @@ err_out:
 
 	return err;
 }
+
+int tipc_nl_link_reset_stats(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	char *link_name;
+	unsigned int bearer_id;
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
+	link_name = nla_data(attrs[TIPC_NLA_LINK_NAME]);
+
+	if (strcmp(link_name, tipc_bclink_name) == 0) {
+		err = tipc_bclink_reset_stats();
+		if (err)
+			return err;
+		return 0;
+	}
+
+	node = tipc_link_find_owner(link_name, &bearer_id);
+	if (!node)
+		return -EINVAL;
+
+	tipc_node_lock(node);
+
+	link = node->links[bearer_id];
+	if (!link) {
+		tipc_node_unlock(node);
+		return -EINVAL;
+	}
+
+	link_reset_statistics(link);
+
+	tipc_node_unlock(node);
+
+	return 0;
+}
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 3738ba1..f463e7b 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -243,6 +243,7 @@ void tipc_link_retransmit(struct tipc_link *l_ptr,
 int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_link_reset_stats(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[]);
 
 /*
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index d4444e5..68bfd11 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -149,6 +149,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_LINK_SET,
 		.doit	= tipc_nl_link_set,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_LINK_RESET_STATS,
+		.doit   = tipc_nl_link_reset_stats,
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
