From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 12/14] tipc: add net dump to
	new netlink api
Date: Thu, 20 Nov 2014 10:29:18 +0100
Message-ID: <1416475760-18914-13-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_NET_GET command to the new tipc netlink API.

This command dumps the network id of the node.

Netlink logical layout of returned network data:
-> net
    -> id

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |   11 +++++++
 net/tipc/net.c                    |   59 +++++++++++++++++++++++++++++++++++++
 net/tipc/net.h                    |    7 ++++-
 net/tipc/netlink.c                |    9 +++++-
 4 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index 08a7933..dcfd420 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -53,6 +53,7 @@ enum {
 	TIPC_NL_MEDIA_GET,
 	TIPC_NL_MEDIA_SET,
 	TIPC_NL_NODE_GET,
+	TIPC_NL_NET_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -67,6 +68,7 @@ enum {
 	TIPC_NLA_LINK,			/* nest */
 	TIPC_NLA_MEDIA,			/* nest */
 	TIPC_NLA_NODE,			/* nest */
+	TIPC_NLA_NET,			/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -133,6 +135,15 @@ enum {
 	TIPC_NLA_NODE_MAX = __TIPC_NLA_NODE_MAX - 1
 };
 
+/* Net info */
+enum {
+	TIPC_NLA_NET_UNSPEC,
+	TIPC_NLA_NET_ID,		/* u32 */
+
+	__TIPC_NLA_NET_MAX,
+	TIPC_NLA_NET_MAX = __TIPC_NLA_NET_MAX - 1
+};
+
 /* Publication info */
 enum {
 	TIPC_NLA_PUBL_UNSPEC,
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 93b9944..d9e666a 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -42,6 +42,11 @@
 #include "node.h"
 #include "config.h"
 
+static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
+	[TIPC_NLA_NET_UNSPEC]	= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NET_ID]	= { .type = NLA_U32 }
+};
+
 /*
  * The TIPC locking policy is designed to ensure a very fine locking
  * granularity, permitting complete parallel access to individual
@@ -138,3 +143,57 @@ void tipc_net_stop(void)
 
 	pr_info("Left network mode\n");
 }
+
+static int __tipc_nl_add_net(struct tipc_nl_msg *msg)
+{
+	void *hdr;
+	struct nlattr *attrs;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+			  NLM_F_MULTI, TIPC_NL_NET_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_NET);
+	if (!attrs)
+		goto msg_full;
+
+	if (nla_put_u32(msg->skb, TIPC_NLA_NET_ID, tipc_net_id))
+		goto attr_msg_full;
+
+	nla_nest_end(msg->skb, attrs);
+	genlmsg_end(msg->skb, hdr);
+
+	return 0;
+
+attr_msg_full:
+	nla_nest_cancel(msg->skb, attrs);
+msg_full:
+	genlmsg_cancel(msg->skb, hdr);
+
+	return -EMSGSIZE;
+}
+
+int tipc_nl_net_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int err;
+	int done = cb->args[0];
+	struct tipc_nl_msg msg;
+
+	if (done)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	err = __tipc_nl_add_net(&msg);
+	if (err)
+		goto out;
+
+	done = 1;
+out:
+	cb->args[0] = done;
+
+	return skb->len;
+}
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 59ef338..60dc22f 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/net.h: Include file for TIPC network routing code
  *
- * Copyright (c) 1995-2006, Ericsson AB
+ * Copyright (c) 1995-2006, 2014, Ericsson AB
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -37,7 +37,12 @@
 #ifndef _TIPC_NET_H
 #define _TIPC_NET_H
 
+#include <net/genetlink.h>
+
 int tipc_net_start(u32 addr);
+
 void tipc_net_stop(void);
 
+int tipc_nl_net_dump(struct sk_buff *skb, struct netlink_callback *cb);
+
 #endif
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 5b0e3c8..c143f9c 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -40,6 +40,7 @@
 #include "bearer.h"
 #include "link.h"
 #include "node.h"
+#include "net.h"
 #include <net/genetlink.h>
 
 static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
@@ -79,7 +80,8 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_PUBL]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_LINK]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_MEDIA]	= { .type = NLA_NESTED, },
-	[TIPC_NLA_NODE]		= { .type = NLA_NESTED, }
+	[TIPC_NLA_NODE]		= { .type = NLA_NESTED, },
+	[TIPC_NLA_NET]		= { .type = NLA_NESTED, }
 };
 
 /* Legacy ASCII API */
@@ -173,6 +175,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_NODE_GET,
 		.dumpit	= tipc_nl_node_dump,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_NET_GET,
+		.dumpit	= tipc_nl_net_dump,
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
