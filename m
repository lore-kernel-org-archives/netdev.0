From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 03/14] tipc: add bearer set to
	new netlink api
Date: Thu, 20 Nov 2014 10:29:09 +0100
Message-ID: <1416475760-18914-4-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_BEARER_SET command to the new tipc netlink API.

This command can set one or more link properties for a particular
bearer.

Netlink logical layout of bearer set message:
-> bearer
    -> name
    -> link properties
        [ -> tolerance ]
        [ -> priority ]
        [ -> window ]

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |    1 +
 net/tipc/bearer.c                 |   49 +++++++++++++++++++++++++++++++++++++
 net/tipc/bearer.h                 |    1 +
 net/tipc/netlink.c                |    5 ++++
 4 files changed, 56 insertions(+)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index 249ec7e..f446fba 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -44,6 +44,7 @@ enum {
 	TIPC_NL_BEARER_DISABLE,
 	TIPC_NL_BEARER_ENABLE,
 	TIPC_NL_BEARER_GET,
+	TIPC_NL_BEARER_SET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index d49b8c2..6d547d0 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -849,3 +849,52 @@ int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 
 	return 0;
 }
+
+int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	char *name;
+	struct tipc_bearer *b;
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+
+	if (!info->attrs[TIPC_NLA_BEARER])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
+			       info->attrs[TIPC_NLA_BEARER],
+			       tipc_nl_bearer_policy);
+	if (err)
+		return err;
+
+	if (!attrs[TIPC_NLA_BEARER_NAME])
+		return -EINVAL;
+	name = nla_data(attrs[TIPC_NLA_BEARER_NAME]);
+
+	rtnl_lock();
+	b = tipc_bearer_find(name);
+	if (!b) {
+		rtnl_unlock();
+		return -EINVAL;
+	}
+
+	if (attrs[TIPC_NLA_BEARER_PROP]) {
+		struct nlattr *props[TIPC_NLA_PROP_MAX + 1];
+
+		err = tipc_nl_parse_link_prop(attrs[TIPC_NLA_BEARER_PROP],
+					      props);
+		if (err) {
+			rtnl_unlock();
+			return err;
+		}
+
+		if (props[TIPC_NLA_PROP_TOL])
+			b->tolerance = nla_get_u32(props[TIPC_NLA_PROP_TOL]);
+		if (props[TIPC_NLA_PROP_PRIO])
+			b->priority = nla_get_u32(props[TIPC_NLA_PROP_PRIO]);
+		if (props[TIPC_NLA_PROP_WIN])
+			b->window = nla_get_u32(props[TIPC_NLA_PROP_WIN]);
+	}
+	rtnl_unlock();
+
+	return 0;
+}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 2d07e35..c6cf9df 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -182,6 +182,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_bearer_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info);
 
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 0c00422..a529131 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -118,6 +118,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.doit	= tipc_nl_bearer_get,
 		.dumpit	= tipc_nl_bearer_dump,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_BEARER_SET,
+		.doit	= tipc_nl_bearer_set,
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
