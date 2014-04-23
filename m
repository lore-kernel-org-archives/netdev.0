From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 2/2] tipc: add ioctl to fetch link names
Date: Wed, 23 Apr 2014 17:01:15 +0200
Message-ID: <1398265275-19849-3-git-send-email-erik.hugne@ericsson.com>
References: <1398265275-19849-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:58234 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbaDWPAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 11:00:30 -0400
In-Reply-To: <1398265275-19849-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

We add a new ioctl for AF_TIPC that can be used to fetch the
logical name for a link to a remote node on a given bearer. This
should be used in combination with link state subscriptions.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc.h |  9 +++++++++
 net/tipc/node.c           | 27 +++++++++++++++++++++++++++
 net/tipc/node.h           |  1 +
 net/tipc/socket.c         | 29 ++++++++++++++++++++++++++---
 4 files changed, 63 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index 53cd790..172042c 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -38,6 +38,7 @@
 #define _LINUX_TIPC_H_
 
 #include <linux/types.h>
+#include <linux/sockios.h>
 
 /*
  * TIPC addressing primitives
@@ -207,4 +208,12 @@ struct sockaddr_tipc {
 #define TIPC_NODE_RECVQ_DEPTH	131	/* Default: none (read only) */
 #define TIPC_SOCK_RECVQ_DEPTH	132	/* Default: none (read only) */
 
+
+#define SIOCGETLINKNAME		SIOCPROTOPRIVATE
+
+struct tipc_sioc_ln_req {
+	__u32 peer;
+	__u32 bearer_id;
+	char linkname[255];
+};
 #endif
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 527e751..5172221 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -442,3 +442,30 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
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
+int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname)
+{
+	struct tipc_link *link;
+	struct tipc_node *node = tipc_node_find(addr);
+
+	if ((bearer_id > MAX_BEARERS) || !node)
+		return -EINVAL;
+	tipc_node_lock(node);
+	link = node->links[bearer_id];
+	if (link) {
+		strncpy(linkname, link->name, TIPC_MAX_LINK_NAME);
+		tipc_node_unlock(node);
+		return 0;
+	}
+	tipc_node_unlock(node);
+	return -EINVAL;
+}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 7cbb8ce..baf3bf7 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -118,6 +118,7 @@ int tipc_node_active_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
+int tipc_node_get_linkname(u32 bearer_id, u32 node, char *linkname);
 
 static inline void tipc_node_lock(struct tipc_node *n_ptr)
 {
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 29b7f26..841f986 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -36,6 +36,7 @@
 
 #include "core.h"
 #include "port.h"
+#include "node.h"
 
 #include <linux/export.h>
 
@@ -1906,6 +1907,28 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
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
+					    lnr.linkname)) {
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
@@ -1918,7 +1941,7 @@ static const struct proto_ops msg_ops = {
 	.accept		= sock_no_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
-	.ioctl		= sock_no_ioctl,
+	.ioctl		= tipc_ioctl,
 	.listen		= sock_no_listen,
 	.shutdown	= tipc_shutdown,
 	.setsockopt	= tipc_setsockopt,
@@ -1939,7 +1962,7 @@ static const struct proto_ops packet_ops = {
 	.accept		= tipc_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
-	.ioctl		= sock_no_ioctl,
+	.ioctl		= tipc_ioctl,
 	.listen		= tipc_listen,
 	.shutdown	= tipc_shutdown,
 	.setsockopt	= tipc_setsockopt,
@@ -1960,7 +1983,7 @@ static const struct proto_ops stream_ops = {
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
