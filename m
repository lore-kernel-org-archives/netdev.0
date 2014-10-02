From: <richard.alpe@ericsson.com>
Subject: [PATCH v2 net-next 13/15] tipc: add net set to
	new netlink api
Date: Thu, 2 Oct 2014 16:58:39 +0200
Message-ID: <1412261921-28510-14-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_NET_SET command to the new tipc netlink API.

This command can set the network id and network (tipc) address.

Netlink logical layout of network set message:
-> net
     [ -> id ]
     [ -> address ]

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_config.h |    2 ++
 net/tipc/net.c                   |   47 ++++++++++++++++++++++++++++++++++++++
 net/tipc/net.h                   |    1 +
 net/tipc/netlink.c               |    5 ++++
 4 files changed, 55 insertions(+)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index e748b7e..ddd83b2 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -63,6 +63,7 @@ enum {
 	TIPC_NL_MEDIA_SET,
 	TIPC_NL_NODE_GET,
 	TIPC_NL_NET_GET,
+	TIPC_NL_NET_SET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -147,6 +148,7 @@ enum {
 enum {
 	TIPC_NLA_NET_UNSPEC,
 	TIPC_NLA_NET_ID,		/* u32 */
+	TIPC_NLA_NET_ADDR,		/* u32 */
 
 	__TIPC_NLA_NET_MAX,
 	TIPC_NLA_NET_MAX = __TIPC_NLA_NET_MAX - 1
diff --git a/net/tipc/net.c b/net/tipc/net.c
index b5435a6..fdbbedf 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -197,3 +197,50 @@ out:
 
 	return skb->len;
 }
+
+int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	struct nlattr *attrs[TIPC_NLA_NET_MAX + 1];
+
+	if (!info->attrs[TIPC_NLA_NET])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_NET_MAX,
+			       info->attrs[TIPC_NLA_NET],
+			       tipc_nl_net_policy);
+	if (err)
+		return err;
+
+	if (attrs[TIPC_NLA_NET_ID]) {
+		u32 val;
+
+		/* Can't change net id once TIPC has joined a network */
+		if (tipc_own_addr)
+			return -EPERM;
+
+		val = nla_get_u32(attrs[TIPC_NLA_NET_ID]);
+		if (val < 1 || val > 9999)
+			return -EINVAL;
+
+		tipc_net_id = val;
+	}
+
+	if (attrs[TIPC_NLA_NET_ADDR]) {
+		u32 addr;
+
+		/* Can't change net addr once TIPC has joined a network */
+		if (tipc_own_addr)
+			return -EPERM;
+
+		addr = nla_get_u32(attrs[TIPC_NLA_NET_ADDR]);
+		if (!tipc_addr_node_valid(addr))
+			return -EINVAL;
+
+		rtnl_lock();
+		tipc_net_start(addr);
+		rtnl_unlock();
+	}
+
+	return 0;
+}
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 60dc22f..a81c1b9 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -44,5 +44,6 @@ int tipc_net_start(u32 addr);
 void tipc_net_stop(void);
 
 int tipc_nl_net_dump(struct sk_buff *skb, struct netlink_callback *cb);
+int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info);
 
 #endif
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index a685a6f..843b2cc 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -165,6 +165,11 @@ static const struct genl_ops tipc_genl_ops[] = {
 		.cmd	= TIPC_NL_NET_GET,
 		.dumpit	= tipc_nl_net_dump,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_NET_SET,
+		.doit	= tipc_nl_net_set,
+		.policy = tipc_nl_policy,
 	}
 };
 
-- 
1.7.10.4


------------------------------------------------------------------------------
Meet PCI DSS 3.0 Compliance Requirements with EventLog Analyzer
Achieve PCI DSS 3.0 Compliant Status with Out-of-the-box PCI DSS Reports
Are you Audit-Ready for PCI DSS 3.0 Compliance? Download White paper
Comply to PCI DSS 3.0 Requirement 10 and 11.5 with EventLog Analyzer
http://pubads.g.doubleclick.net/gampad/clk?id=154622311&iu=/4140/ostg.clktrk
