From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 04/16] tipc: cleanup core.c and core.h files
Date: Fri, 9 Jan 2015 15:27:01 +0800
Message-ID: <1420788433-17960-5-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Tero.Aho@coriant.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64466 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbAIH1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 02:27:52 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the works of initializing and shutting down tipc module are done
in core.h and core.c files, so all stuffs which are not closely
associated with the two tasks should be moved to appropriate places.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/addr.h    |    2 --
 net/tipc/config.h  |    4 ++--
 net/tipc/core.c    |   23 -----------------------
 net/tipc/core.h    |   53 ----------------------------------------------------
 net/tipc/link.h    |    4 ++++
 net/tipc/msg.c     |   23 +++++++++++++++++++++++
 net/tipc/msg.h     |   37 ++++++++++++++++++++++++++++--------
 net/tipc/netlink.h |    3 +++
 net/tipc/server.c  |    1 +
 net/tipc/server.h  |    3 ++-
 net/tipc/socket.h  |    7 +++++++
 net/tipc/subscr.h  |    3 +++
 12 files changed, 74 insertions(+), 89 deletions(-)

diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index a74acf9..60b00ab 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -37,8 +37,6 @@
 #ifndef _TIPC_ADDR_H
 #define _TIPC_ADDR_H
 
-#include "core.h"
-
 #define TIPC_ZONE_MASK		0xff000000u
 #define TIPC_CLUSTER_MASK	0xfffff000u
 
diff --git a/net/tipc/config.h b/net/tipc/config.h
index 47b1bf1..a41a41c 100644
--- a/net/tipc/config.h
+++ b/net/tipc/config.h
@@ -37,10 +37,10 @@
 #ifndef _TIPC_CONFIG_H
 #define _TIPC_CONFIG_H
 
-/* ---------------------------------------------------------------------- */
-
 #include "link.h"
 
+#define ULTRA_STRING_MAX_LEN	32768
+
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size);
 int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
 			void *tlv_data, int tlv_data_size);
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 10bc0bf..b6ec3d7 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -52,29 +52,6 @@ u32 tipc_own_addr __read_mostly;
 int tipc_net_id __read_mostly;
 int sysctl_tipc_rmem[3] __read_mostly;	/* min/default/max */
 
-/**
- * tipc_buf_acquire - creates a TIPC message buffer
- * @size: message size (including TIPC header)
- *
- * Returns a new buffer with data pointers set to the specified size.
- *
- * NOTE: Headroom is reserved to allow prepending of a data link header.
- *       There may also be unrequested tailroom present at the buffer's end.
- */
-struct sk_buff *tipc_buf_acquire(u32 size)
-{
-	struct sk_buff *skb;
-	unsigned int buf_size = (BUF_HEADROOM + size + 3) & ~3u;
-
-	skb = alloc_skb_fclone(buf_size, GFP_ATOMIC);
-	if (skb) {
-		skb_reserve(skb, BUF_HEADROOM);
-		skb_put(skb, size);
-		skb->next = NULL;
-	}
-	return skb;
-}
-
 static int __init tipc_init(void)
 {
 	int err;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index d570689..a5b3140 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -60,20 +60,9 @@
 
 #define TIPC_MOD_VER "2.0.0"
 
-#define ULTRA_STRING_MAX_LEN	32768
-#define TIPC_MAX_SUBSCRIPTIONS	65535
-#define TIPC_MAX_PUBLICATIONS	65535
-
-struct tipc_msg;	/* msg.h */
-
 int tipc_snprintf(char *buf, int len, const char *fmt, ...);
 
 /*
- * TIPC-specific error codes
- */
-#define ELINKCONG EAGAIN	/* link congestion <=> resource unavailable */
-
-/*
  * Global configuration variables
  */
 extern u32 tipc_own_addr __read_mostly;
@@ -86,18 +75,6 @@ extern int sysctl_tipc_named_timeout __read_mostly;
  */
 extern int tipc_random __read_mostly;
 
-/*
- * Routines available to privileged subsystems
- */
-int tipc_netlink_start(void);
-void tipc_netlink_stop(void);
-int tipc_socket_init(void);
-void tipc_socket_stop(void);
-int tipc_sock_create_local(int type, struct socket **res);
-void tipc_sock_release_local(struct socket *sock);
-int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
-			   int flags);
-
 #ifdef CONFIG_SYSCTL
 int tipc_register_sysctl(void);
 void tipc_unregister_sysctl(void);
@@ -106,34 +83,4 @@ void tipc_unregister_sysctl(void);
 #define tipc_unregister_sysctl()
 #endif
 
-/*
- * TIPC message buffer code
- *
- * TIPC message buffer headroom reserves space for the worst-case
- * link-level device header (in case the message is sent off-node).
- *
- * Note: Headroom should be a multiple of 4 to ensure the TIPC header fields
- *       are word aligned for quicker access
- */
-#define BUF_HEADROOM LL_MAX_HEADER
-
-struct tipc_skb_cb {
-	void *handle;
-	struct sk_buff *tail;
-	bool deferred;
-	bool wakeup_pending;
-	bool bundling;
-	u16 chain_sz;
-	u16 chain_imp;
-};
-
-#define TIPC_SKB_CB(__skb) ((struct tipc_skb_cb *)&((__skb)->cb[0]))
-
-static inline struct tipc_msg *buf_msg(struct sk_buff *skb)
-{
-	return (struct tipc_msg *)skb->data;
-}
-
-struct sk_buff *tipc_buf_acquire(u32 size);
-
 #endif
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 15ca850..e96c318 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -41,6 +41,10 @@
 #include "msg.h"
 #include "node.h"
 
+/* TIPC-specific error codes
+*/
+#define ELINKCONG EAGAIN	/* link congestion <=> resource unavailable */
+
 /* Out-of-range value for link sequence numbers
  */
 #define INVALID_LINK_SEQ 0x10000
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index a687b30..35523fb 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -46,6 +46,29 @@ static unsigned int align(unsigned int i)
 	return (i + 3) & ~3u;
 }
 
+/**
+ * tipc_buf_acquire - creates a TIPC message buffer
+ * @size: message size (including TIPC header)
+ *
+ * Returns a new buffer with data pointers set to the specified size.
+ *
+ * NOTE: Headroom is reserved to allow prepending of a data link header.
+ *       There may also be unrequested tailroom present at the buffer's end.
+ */
+struct sk_buff *tipc_buf_acquire(u32 size)
+{
+	struct sk_buff *skb;
+	unsigned int buf_size = (BUF_HEADROOM + size + 3) & ~3u;
+
+	skb = alloc_skb_fclone(buf_size, GFP_ATOMIC);
+	if (skb) {
+		skb_reserve(skb, BUF_HEADROOM);
+		skb_put(skb, size);
+		skb->next = NULL;
+	}
+	return skb;
+}
+
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode)
 {
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 1a52f7c..0065a2e 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -77,10 +77,38 @@
 
 #define TIPC_MEDIA_ADDR_OFFSET	5
 
+/**
+ * TIPC message buffer code
+ *
+ * TIPC message buffer headroom reserves space for the worst-case
+ * link-level device header (in case the message is sent off-node).
+ *
+ * Note: Headroom should be a multiple of 4 to ensure the TIPC header fields
+ *       are word aligned for quicker access
+ */
+#define BUF_HEADROOM LL_MAX_HEADER
+
+struct tipc_skb_cb {
+	void *handle;
+	struct sk_buff *tail;
+	bool deferred;
+	bool wakeup_pending;
+	bool bundling;
+	u16 chain_sz;
+	u16 chain_imp;
+};
+
+#define TIPC_SKB_CB(__skb) ((struct tipc_skb_cb *)&((__skb)->cb[0]))
+
 struct tipc_msg {
 	__be32 hdr[15];
 };
 
+static inline struct tipc_msg *buf_msg(struct sk_buff *skb)
+{
+	return (struct tipc_msg *)skb->data;
+}
+
 static inline u32 msg_word(struct tipc_msg *m, u32 pos)
 {
 	return ntohl(m->hdr[pos]);
@@ -719,27 +747,20 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 	return msg_origport(m);
 }
 
+struct sk_buff *tipc_buf_acquire(u32 size);
 bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err);
-
 int tipc_msg_eval(struct sk_buff *buf, u32 *dnode);
-
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
-
 struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
 				uint data_sz, u32 dnode, u32 onode,
 				u32 dport, u32 oport, int errcode);
-
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
-
 bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
-
 bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
 			  u32 mtu, u32 dnode);
-
 int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
 		   int dsz, int mtu, struct sk_buff_head *list);
-
 struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
 
 #endif
diff --git a/net/tipc/netlink.h b/net/tipc/netlink.h
index 1425c68..ae2f2d9 100644
--- a/net/tipc/netlink.h
+++ b/net/tipc/netlink.h
@@ -45,4 +45,7 @@ struct tipc_nl_msg {
 	u32 seq;
 };
 
+int tipc_netlink_start(void);
+void tipc_netlink_stop(void);
+
 #endif
diff --git a/net/tipc/server.c b/net/tipc/server.c
index a538a02..869eb09 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -35,6 +35,7 @@
 
 #include "server.h"
 #include "core.h"
+#include "socket.h"
 #include <net/sock.h>
 
 /* Number of messages to send before rescheduling */
diff --git a/net/tipc/server.h b/net/tipc/server.h
index be817b0..87bc05c 100644
--- a/net/tipc/server.h
+++ b/net/tipc/server.h
@@ -36,7 +36,8 @@
 #ifndef _TIPC_SERVER_H
 #define _TIPC_SERVER_H
 
-#include "core.h"
+#include <linux/idr.h>
+#include <linux/tipc.h>
 
 #define TIPC_SERVER_NAME_LEN	32
 
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index c7d46d06..46bc370 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -42,6 +42,13 @@
 #define TIPC_FLOWCTRL_WIN        (TIPC_CONNACK_INTV * 2)
 #define TIPC_CONN_OVERLOAD_LIMIT ((TIPC_FLOWCTRL_WIN * 2 + 1) * \
 				  SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
+
+int tipc_socket_init(void);
+void tipc_socket_stop(void);
+int tipc_sock_create_local(int type, struct socket **res);
+void tipc_sock_release_local(struct socket *sock);
+int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
+			   int flags);
 int tipc_sk_rcv(struct sk_buff *buf);
 struct sk_buff *tipc_sk_socks_show(void);
 void tipc_sk_mcast_rcv(struct sk_buff *buf);
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index ab01713..0d39589 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -39,6 +39,9 @@
 
 #include "server.h"
 
+#define TIPC_MAX_SUBSCRIPTIONS	65535
+#define TIPC_MAX_PUBLICATIONS	65535
+
 struct tipc_subscription;
 struct tipc_subscriber;
 
-- 
1.7.9.5
