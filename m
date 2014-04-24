From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 2/2] tipc: add ioctl to fetch link names
Date: Thu, 24 Apr 2014 16:26:47 +0200
Message-ID: <1398349607-16012-3-git-send-email-erik.hugne@ericsson.com>
References: <1398349607-16012-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:45213 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756018AbaDXOZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:25:49 -0400
In-Reply-To: <1398349607-16012-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

We add a new ioctl for AF_TIPC that can be used to fetch the
logical name for a link to a remote node on a given bearer. This
should be used in combination with link state subscriptions.
The logical name size limit definitions are moved to tipc.h, as
they are now also needed by the new ioctl.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc.h        | 22 ++++++++++++++++++++++
 include/uapi/linux/tipc_config.h | 10 +---------
 net/tipc/node.c                  | 27 +++++++++++++++++++++++++++
 net/tipc/node.h                  |  1 +
 net/tipc/socket.c                | 29 ++++++++++++++++++++++++++---
 5 files changed, 77 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index 53cd790..6f71b9b 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -38,6 +38,7 @@
 #define _LINUX_TIPC_H_
 
 #include <linux/types.h>
+#include <linux/sockios.h>
 
 /*
  * TIPC addressing primitives
@@ -207,4 +208,25 @@ struct sockaddr_tipc {
 #define TIPC_NODE_RECVQ_DEPTH	131	/* Default: none (read only) */
 #define TIPC_SOCK_RECVQ_DEPTH	132	/* Default: none (read only) */
 
+/*
+ * Maximum sizes of TIPC bearer-related names (including terminating NULL)
+ * The string formatting for each name element is:
+ * media: media
+ * interface: media:interface name
+ * link: Z.C.N:interface-Z.C.N:interface
+ *
+ */
+
+#define TIPC_MAX_MEDIA_NAME	16
+#define TIPC_MAX_IF_NAME	16
+#define TIPC_MAX_BEARER_NAME	32
+#define TIPC_MAX_LINK_NAME	60
+
+#define SIOCGETLINKNAME		SIOCPROTOPRIVATE
+
+struct tipc_sioc_ln_req {
+	__u32 peer;
+	__u32 bearer_id;
+	char linkname[TIPC_MAX_LINK_NAME];
+};
 #endif
diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index 6b0bff0..41a76ac 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -39,6 +39,7 @@
 
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/tipc.h>
 #include <asm/byteorder.h>
 
 #ifndef __KERNEL__
@@ -155,15 +156,6 @@
 #define TIPC_TLV_PORT_REF	26	/* 32-bit port reference */
 
 /*
- * Maximum sizes of TIPC bearer-related names (including terminating NUL)
- */
-
-#define TIPC_MAX_MEDIA_NAME	16	/* format = media */
-#define TIPC_MAX_IF_NAME	16	/* format = interface */
-#define TIPC_MAX_BEARER_NAME	32	/* format = media:interface */
-#define TIPC_MAX_LINK_NAME	60	/* format = Z.C.N:interface-Z.C.N:interface */
-
-/*
  * Link priority limits (min, default, max, media default)
  */
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 3b86a74..1f938f3 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -438,3 +438,30 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	rcu_read_unlock();
 	return buf;
 }
+
+/**
+ * tipc_node_get_linkname - get the name of a link
+ *
+ * @bearer_id: id of the bearer
+ * @node: peer node address
+ * @linkname: link name output buffer
+ *
+ * Returns 0 on success
+ */
+int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
+{
+	struct tipc_link *link;
+	struct tipc_node *node = tipc_node_find(addr);
+
+	if ((bearer_id > MAX_BEARERS) || !node)
+		return -EINVAL;
+	tipc_node_lock(node);
+	link = node->links[bearer_id];
+	if (link) {
+		strncpy(linkname, link->name, len);
+		tipc_node_unlock(node);
+		return 0;
+	}
+	tipc_node_unlock(node);
+	return -EINVAL;
+}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 7cbb8ce..411b191 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -118,6 +118,7 @@ int tipc_node_active_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
+int tipc_node_get_linkname(u32 bearer_id, u32 node, char *linkname, size_t len);
 
 static inline void tipc_node_lock(struct tipc_node *n_ptr)
 {
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3c02569..3f9912f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -36,6 +36,7 @@
 
 #include "core.h"
 #include "port.h"
+#include "node.h"
 
 #include <linux/export.h>
 
@@ -1905,6 +1906,28 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
 	return put_user(sizeof(value), ol);
 }
 
+int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
+{
+	struct tipc_sioc_ln_req lnr;
+	void __user *argp = (void __user *)arg;
+
+	switch (cmd) {
+	case SIOCGETLINKNAME:
+		if (copy_from_user(&lnr, argp, sizeof(lnr)))
+			return -EFAULT;
+		if (!tipc_node_get_linkname(lnr.bearer_id, lnr.peer,
+					    lnr.linkname, TIPC_MAX_LINK_NAME)) {
+			if (copy_to_user(argp, &lnr, sizeof(lnr)))
+				return -EFAULT;
+			return 0;
+		}
+		return -EADDRNOTAVAIL;
+		break;
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+
 /* Protocol switches for the various types of TIPC sockets */
 
 static const struct proto_ops msg_ops = {
@@ -1917,7 +1940,7 @@ static const struct proto_ops msg_ops = {
 	.accept		= sock_no_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
-	.ioctl		= sock_no_ioctl,
+	.ioctl		= tipc_ioctl,
 	.listen		= sock_no_listen,
 	.shutdown	= tipc_shutdown,
 	.setsockopt	= tipc_setsockopt,
@@ -1938,7 +1961,7 @@ static const struct proto_ops packet_ops = {
 	.accept		= tipc_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
-	.ioctl		= sock_no_ioctl,
+	.ioctl		= tipc_ioctl,
 	.listen		= tipc_listen,
 	.shutdown	= tipc_shutdown,
 	.setsockopt	= tipc_setsockopt,
@@ -1959,7 +1982,7 @@ static const struct proto_ops stream_ops = {
 	.accept		= tipc_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
-	.ioctl		= sock_no_ioctl,
+	.ioctl		= tipc_ioctl,
 	.listen		= tipc_listen,
 	.shutdown	= tipc_shutdown,
 	.setsockopt	= tipc_setsockopt,
-- 
1.8.3.2
