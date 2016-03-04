From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v2] tipc: move netlink policies
	to netlink.c
Date: Fri, 4 Mar 2016 17:04:42 +0100
Message-ID: <1457107482-15425-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net, Richard
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Make the c files less cluttered and enable netlink attributes to be
shared between files.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/bearer.c     | 18 +-------------
 net/tipc/link.c       |  8 ------
 net/tipc/name_table.c |  6 -----
 net/tipc/net.c        |  6 +----
 net/tipc/netlink.c    | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/netlink.h    | 11 ++++++++
 net/tipc/node.c       | 23 +----------------
 net/tipc/socket.c     |  9 +------
 net/tipc/udp_media.c  |  9 +------
 9 files changed, 85 insertions(+), 74 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 802ffad..27a5406 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -40,6 +40,7 @@
 #include "link.h"
 #include "discover.h"
 #include "bcast.h"
+#include "netlink.h"
 
 #define MAX_ADDR_STR 60
 
@@ -54,23 +55,6 @@ static struct tipc_media * const media_info_array[] = {
 	NULL
 };
 
-static const struct nla_policy
-tipc_nl_bearer_policy[TIPC_NLA_BEARER_MAX + 1]	= {
-	[TIPC_NLA_BEARER_UNSPEC]		= { .type = NLA_UNSPEC },
-	[TIPC_NLA_BEARER_NAME] = {
-		.type = NLA_STRING,
-		.len = TIPC_MAX_BEARER_NAME
-	},
-	[TIPC_NLA_BEARER_PROP]			= { .type = NLA_NESTED },
-	[TIPC_NLA_BEARER_DOMAIN]		= { .type = NLA_U32 }
-};
-
-static const struct nla_policy tipc_nl_media_policy[TIPC_NLA_MEDIA_MAX + 1] = {
-	[TIPC_NLA_MEDIA_UNSPEC]		= { .type = NLA_UNSPEC },
-	[TIPC_NLA_MEDIA_NAME]		= { .type = NLA_STRING },
-	[TIPC_NLA_MEDIA_PROP]		= { .type = NLA_NESTED }
-};
-
 static void bearer_disable(struct net *net, struct tipc_bearer *b);
 
 /**
diff --git a/net/tipc/link.c b/net/tipc/link.c
index e31d92f..c46d620 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -195,14 +195,6 @@ struct tipc_link {
 static const char *link_co_err = "Link tunneling error, ";
 static const char *link_rst_msg = "Resetting link ";
 
-/* Properties valid for media, bearar and link */
-static const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
-	[TIPC_NLA_PROP_UNSPEC]		= { .type = NLA_UNSPEC },
-	[TIPC_NLA_PROP_PRIO]		= { .type = NLA_U32 },
-	[TIPC_NLA_PROP_TOL]		= { .type = NLA_U32 },
-	[TIPC_NLA_PROP_WIN]		= { .type = NLA_U32 }
-};
-
 /* Send states for broadcast NACKs
  */
 enum {
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 777b979..e190460 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -47,12 +47,6 @@
 
 #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
 
-static const struct nla_policy
-tipc_nl_name_table_policy[TIPC_NLA_NAME_TABLE_MAX + 1] = {
-	[TIPC_NLA_NAME_TABLE_UNSPEC]	= { .type = NLA_UNSPEC },
-	[TIPC_NLA_NAME_TABLE_PUBL]	= { .type = NLA_NESTED }
-};
-
 /**
  * struct name_info - name sequence publication info
  * @node_list: circular list of publications made by own node
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 77bf911..d7a5c11 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -41,11 +41,7 @@
 #include "socket.h"
 #include "node.h"
 #include "bcast.h"
-
-static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
-	[TIPC_NLA_NET_UNSPEC]	= { .type = NLA_UNSPEC },
-	[TIPC_NLA_NET_ID]	= { .type = NLA_U32 }
-};
+#include "netlink.h"
 
 /*
  * The TIPC locking policy is designed to ensure a very fine locking
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 8975b01..56935df2 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -55,6 +55,75 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_NAME_TABLE]	= { .type = NLA_NESTED, }
 };
 
+const struct nla_policy
+tipc_nl_name_table_policy[TIPC_NLA_NAME_TABLE_MAX + 1] = {
+	[TIPC_NLA_NAME_TABLE_UNSPEC]	= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NAME_TABLE_PUBL]	= { .type = NLA_NESTED }
+};
+
+const struct nla_policy tipc_nl_sock_policy[TIPC_NLA_SOCK_MAX + 1] = {
+	[TIPC_NLA_SOCK_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_SOCK_ADDR]		= { .type = NLA_U32 },
+	[TIPC_NLA_SOCK_REF]		= { .type = NLA_U32 },
+	[TIPC_NLA_SOCK_CON]		= { .type = NLA_NESTED },
+	[TIPC_NLA_SOCK_HAS_PUBL]	= { .type = NLA_FLAG }
+};
+
+const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
+	[TIPC_NLA_NET_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NET_ID]		= { .type = NLA_U32 }
+};
+
+const struct nla_policy tipc_nl_link_policy[TIPC_NLA_LINK_MAX + 1] = {
+	[TIPC_NLA_LINK_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_LINK_NAME]		= { .type = NLA_STRING,
+					    .len = TIPC_MAX_LINK_NAME },
+	[TIPC_NLA_LINK_MTU]		= { .type = NLA_U32 },
+	[TIPC_NLA_LINK_BROADCAST]	= { .type = NLA_FLAG },
+	[TIPC_NLA_LINK_UP]		= { .type = NLA_FLAG },
+	[TIPC_NLA_LINK_ACTIVE]		= { .type = NLA_FLAG },
+	[TIPC_NLA_LINK_PROP]		= { .type = NLA_NESTED },
+	[TIPC_NLA_LINK_STATS]		= { .type = NLA_NESTED },
+	[TIPC_NLA_LINK_RX]		= { .type = NLA_U32 },
+	[TIPC_NLA_LINK_TX]		= { .type = NLA_U32 }
+};
+
+const struct nla_policy tipc_nl_node_policy[TIPC_NLA_NODE_MAX + 1] = {
+	[TIPC_NLA_NODE_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NODE_ADDR]		= { .type = NLA_U32 },
+	[TIPC_NLA_NODE_UP]		= { .type = NLA_FLAG }
+};
+
+/* Properties valid for media, bearer and link */
+const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
+	[TIPC_NLA_PROP_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_PROP_PRIO]		= { .type = NLA_U32 },
+	[TIPC_NLA_PROP_TOL]		= { .type = NLA_U32 },
+	[TIPC_NLA_PROP_WIN]		= { .type = NLA_U32 }
+};
+
+const struct nla_policy tipc_nl_bearer_policy[TIPC_NLA_BEARER_MAX + 1]	= {
+	[TIPC_NLA_BEARER_UNSPEC]	= { .type = NLA_UNSPEC },
+	[TIPC_NLA_BEARER_NAME]		= { .type = NLA_STRING,
+					    .len = TIPC_MAX_BEARER_NAME },
+	[TIPC_NLA_BEARER_PROP]		= { .type = NLA_NESTED },
+	[TIPC_NLA_BEARER_DOMAIN]	= { .type = NLA_U32 }
+};
+
+const struct nla_policy tipc_nl_media_policy[TIPC_NLA_MEDIA_MAX + 1] = {
+	[TIPC_NLA_MEDIA_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_MEDIA_NAME]		= { .type = NLA_STRING },
+	[TIPC_NLA_MEDIA_PROP]		= { .type = NLA_NESTED }
+};
+
+const struct nla_policy tipc_nl_udp_policy[TIPC_NLA_UDP_MAX + 1] = {
+	[TIPC_NLA_UDP_UNSPEC]	= {.type = NLA_UNSPEC},
+	[TIPC_NLA_UDP_LOCAL]	= {.type = NLA_BINARY,
+				   .len = sizeof(struct sockaddr_storage)},
+	[TIPC_NLA_UDP_REMOTE]	= {.type = NLA_BINARY,
+				   .len = sizeof(struct sockaddr_storage)},
+};
+
 /* Users of the legacy API (tipc-config) can't handle that we add operations,
  * so we have a separate genl handling for the new API.
  */
diff --git a/net/tipc/netlink.h b/net/tipc/netlink.h
index 08a1db6..ed1dbcb 100644
--- a/net/tipc/netlink.h
+++ b/net/tipc/netlink.h
@@ -35,6 +35,7 @@
 
 #ifndef _TIPC_NETLINK_H
 #define _TIPC_NETLINK_H
+#include <net/netlink.h>
 
 extern struct genl_family tipc_genl_family;
 int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***buf);
@@ -45,6 +46,16 @@ struct tipc_nl_msg {
 	u32 seq;
 };
 
+extern const struct nla_policy tipc_nl_name_table_policy[];
+extern const struct nla_policy tipc_nl_sock_policy[];
+extern const struct nla_policy tipc_nl_net_policy[];
+extern const struct nla_policy tipc_nl_link_policy[];
+extern const struct nla_policy tipc_nl_node_policy[];
+extern const struct nla_policy tipc_nl_prop_policy[];
+extern const struct nla_policy tipc_nl_bearer_policy[];
+extern const struct nla_policy tipc_nl_media_policy[];
+extern const struct nla_policy tipc_nl_udp_policy[];
+
 int tipc_netlink_start(void);
 int tipc_netlink_compat_start(void);
 void tipc_netlink_stop(void);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index cdb7950..3f7af5f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -41,6 +41,7 @@
 #include "socket.h"
 #include "bcast.h"
 #include "discover.h"
+#include "netlink.h"
 
 #define INVALID_NODE_SIG	0x10000
 
@@ -164,28 +165,6 @@ struct tipc_sock_conn {
 	struct list_head list;
 };
 
-static const struct nla_policy tipc_nl_link_policy[TIPC_NLA_LINK_MAX + 1] = {
-	[TIPC_NLA_LINK_UNSPEC]		= { .type = NLA_UNSPEC },
-	[TIPC_NLA_LINK_NAME] = {
-		.type = NLA_STRING,
-		.len = TIPC_MAX_LINK_NAME
-	},
-	[TIPC_NLA_LINK_MTU]		= { .type = NLA_U32 },
-	[TIPC_NLA_LINK_BROADCAST]	= { .type = NLA_FLAG },
-	[TIPC_NLA_LINK_UP]		= { .type = NLA_FLAG },
-	[TIPC_NLA_LINK_ACTIVE]		= { .type = NLA_FLAG },
-	[TIPC_NLA_LINK_PROP]		= { .type = NLA_NESTED },
-	[TIPC_NLA_LINK_STATS]		= { .type = NLA_NESTED },
-	[TIPC_NLA_LINK_RX]		= { .type = NLA_U32 },
-	[TIPC_NLA_LINK_TX]		= { .type = NLA_U32 }
-};
-
-static const struct nla_policy tipc_nl_node_policy[TIPC_NLA_NODE_MAX + 1] = {
-	[TIPC_NLA_NODE_UNSPEC]		= { .type = NLA_UNSPEC },
-	[TIPC_NLA_NODE_ADDR]		= { .type = NLA_U32 },
-	[TIPC_NLA_NODE_UP]		= { .type = NLA_FLAG }
-};
-
 static struct tipc_link *node_active_link(struct tipc_node *n, int sel)
 {
 	int bearer_id = n->active_links[sel & 1];
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 69c2905..56b8a96 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -42,6 +42,7 @@
 #include "name_distr.h"
 #include "socket.h"
 #include "bcast.h"
+#include "netlink.h"
 
 #define SS_LISTENING		-1	/* socket is listening */
 #define SS_READY		-2	/* socket is connectionless */
@@ -126,14 +127,6 @@ static const struct proto_ops stream_ops;
 static const struct proto_ops msg_ops;
 static struct proto tipc_proto;
 
-static const struct nla_policy tipc_nl_sock_policy[TIPC_NLA_SOCK_MAX + 1] = {
-	[TIPC_NLA_SOCK_UNSPEC]		= { .type = NLA_UNSPEC },
-	[TIPC_NLA_SOCK_ADDR]		= { .type = NLA_U32 },
-	[TIPC_NLA_SOCK_REF]		= { .type = NLA_U32 },
-	[TIPC_NLA_SOCK_CON]		= { .type = NLA_NESTED },
-	[TIPC_NLA_SOCK_HAS_PUBL]	= { .type = NLA_FLAG }
-};
-
 static const struct rhashtable_params tsk_rht_params;
 
 /*
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index d63a911..f3b9d9a 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -48,20 +48,13 @@
 #include <linux/tipc_netlink.h>
 #include "core.h"
 #include "bearer.h"
+#include "netlink.h"
 
 /* IANA assigned UDP port */
 #define UDP_PORT_DEFAULT	6118
 
 #define UDP_MIN_HEADROOM        28
 
-static const struct nla_policy tipc_nl_udp_policy[TIPC_NLA_UDP_MAX + 1] = {
-	[TIPC_NLA_UDP_UNSPEC]	= {.type = NLA_UNSPEC},
-	[TIPC_NLA_UDP_LOCAL]	= {.type = NLA_BINARY,
-				   .len = sizeof(struct sockaddr_storage)},
-	[TIPC_NLA_UDP_REMOTE]	= {.type = NLA_BINARY,
-				   .len = sizeof(struct sockaddr_storage)},
-};
-
 /**
  * struct udp_media_addr - IP/UDP addressing information
  *
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
