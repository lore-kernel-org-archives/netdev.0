From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 1/2] tipc: move netlink policies to netlink.h
Date: Tue, 5 Jan 2016 10:56:16 +0100
Message-ID: <1451987777-17421-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:53564 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbcAEJ41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 04:56:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the c files less cluttered and enable netlink attributes to be
shared between files. This will prove useful in a future patch where a
node message will contain a nested network.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c     | 19 +-----------
 net/tipc/link.c       |  8 -----
 net/tipc/name_table.c |  7 +----
 net/tipc/net.c        |  6 +---
 net/tipc/netlink.c    | 13 +-------
 net/tipc/netlink.h    | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/node.c       | 23 +-------------
 net/tipc/socket.c     |  9 +-----
 net/tipc/udp_media.c  |  9 +-----
 9 files changed, 92 insertions(+), 87 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 802ffad..d654cfe 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -40,6 +40,7 @@
 #include "link.h"
 #include "discover.h"
 #include "bcast.h"
+#include "netlink.h"
 
 #define MAX_ADDR_STR 60
 
@@ -53,24 +54,6 @@ static struct tipc_media * const media_info_array[] = {
 #endif
 	NULL
 };
-
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
index 0c2944f..cb807be 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -196,14 +196,6 @@ struct tipc_link {
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
index 91fce70..75992b5 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -44,15 +44,10 @@
 #include "addr.h"
 #include "node.h"
 #include <net/genetlink.h>
+#include "netlink.h"
 
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
index 8975b01..234cb93 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -42,18 +42,7 @@
 #include "node.h"
 #include "net.h"
 #include <net/genetlink.h>
-
-static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
-	[TIPC_NLA_UNSPEC]	= { .type = NLA_UNSPEC, },
-	[TIPC_NLA_BEARER]	= { .type = NLA_NESTED, },
-	[TIPC_NLA_SOCK]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_PUBL]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_LINK]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_MEDIA]	= { .type = NLA_NESTED, },
-	[TIPC_NLA_NODE]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_NET]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_NAME_TABLE]	= { .type = NLA_NESTED, }
-};
+#include "netlink.h"
 
 /* Users of the legacy API (tipc-config) can't handle that we add operations,
  * so we have a separate genl handling for the new API.
diff --git a/net/tipc/netlink.h b/net/tipc/netlink.h
index 08a1db6..ff7a39da 100644
--- a/net/tipc/netlink.h
+++ b/net/tipc/netlink.h
@@ -36,7 +36,92 @@
 #ifndef _TIPC_NETLINK_H
 #define _TIPC_NETLINK_H
 
+#include <net/netlink.h>
+
 extern struct genl_family tipc_genl_family;
+
+static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
+	[TIPC_NLA_UNSPEC]		= { .type = NLA_UNSPEC, },
+	[TIPC_NLA_BEARER]		= { .type = NLA_NESTED, },
+	[TIPC_NLA_SOCK]			= { .type = NLA_NESTED, },
+	[TIPC_NLA_PUBL]			= { .type = NLA_NESTED, },
+	[TIPC_NLA_LINK]			= { .type = NLA_NESTED, },
+	[TIPC_NLA_MEDIA]		= { .type = NLA_NESTED, },
+	[TIPC_NLA_NODE]			= { .type = NLA_NESTED, },
+	[TIPC_NLA_NET]			= { .type = NLA_NESTED, },
+	[TIPC_NLA_NAME_TABLE]		= { .type = NLA_NESTED, }
+};
+
+static const struct nla_policy tipc_nl_sock_policy[TIPC_NLA_SOCK_MAX + 1] = {
+	[TIPC_NLA_SOCK_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_SOCK_ADDR]		= { .type = NLA_U32 },
+	[TIPC_NLA_SOCK_REF]		= { .type = NLA_U32 },
+	[TIPC_NLA_SOCK_CON]		= { .type = NLA_NESTED },
+	[TIPC_NLA_SOCK_HAS_PUBL]	= { .type = NLA_FLAG }
+};
+
+static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
+	[TIPC_NLA_NET_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NET_ID]		= { .type = NLA_U32 }
+};
+
+static const struct nla_policy tipc_nl_node_policy[TIPC_NLA_NODE_MAX + 1] = {
+	[TIPC_NLA_NODE_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NODE_ADDR]		= { .type = NLA_U32 },
+	[TIPC_NLA_NODE_UP]		= { .type = NLA_FLAG }
+};
+
+static const struct nla_policy tipc_nl_link_policy[TIPC_NLA_LINK_MAX + 1] = {
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
+/* Properties valid for media, bearar and link */
+static const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
+	[TIPC_NLA_PROP_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_PROP_PRIO]		= { .type = NLA_U32 },
+	[TIPC_NLA_PROP_TOL]		= { .type = NLA_U32 },
+	[TIPC_NLA_PROP_WIN]		= { .type = NLA_U32 }
+};
+
+static const struct nla_policy
+tipc_nl_bearer_policy[TIPC_NLA_BEARER_MAX + 1]	= {
+	[TIPC_NLA_BEARER_UNSPEC]	= { .type = NLA_UNSPEC },
+	[TIPC_NLA_BEARER_NAME]		= { .type = NLA_STRING,
+					    .len = TIPC_MAX_BEARER_NAME },
+	[TIPC_NLA_BEARER_PROP]		= { .type = NLA_NESTED },
+	[TIPC_NLA_BEARER_DOMAIN]	= { .type = NLA_U32 }
+};
+
+static const struct nla_policy tipc_nl_media_policy[TIPC_NLA_MEDIA_MAX + 1] = {
+	[TIPC_NLA_MEDIA_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_MEDIA_NAME]		= { .type = NLA_STRING },
+	[TIPC_NLA_MEDIA_PROP]		= { .type = NLA_NESTED }
+};
+
+static const struct nla_policy tipc_nl_udp_policy[TIPC_NLA_UDP_MAX + 1] = {
+	[TIPC_NLA_UDP_UNSPEC]	= { .type = NLA_UNSPEC },
+	[TIPC_NLA_UDP_LOCAL]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct sockaddr_storage)},
+	[TIPC_NLA_UDP_REMOTE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct sockaddr_storage)},
+};
+
+static const struct nla_policy
+tipc_nl_name_table_policy[TIPC_NLA_NAME_TABLE_MAX + 1] = {
+	[TIPC_NLA_NAME_TABLE_UNSPEC]	= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NAME_TABLE_PUBL]	= { .type = NLA_NESTED }
+};
+
 int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***buf);
 
 struct tipc_nl_msg {
diff --git a/net/tipc/node.c b/net/tipc/node.c
index fa97d96..ee6f93c 100644
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
