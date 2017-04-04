From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH net-next] netlink/diag: report flags for netlink sockets
Date: Mon,  3 Apr 2017 18:13:32 -0700
Message-ID: <20170404011332.13469-1-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrey Vagin <avagin@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34111 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdDDBNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 21:13:36 -0400
Received: by mail-pg0-f67.google.com with SMTP id o123so33381030pga.1
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 18:13:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>

cb_running is reported in /proc/self/net/netlink and it is reported by
the ss tool, when it gets information from the proc files.

sock_diag is a new interface which is used instead of proc files, so it
looks reasonable that this interface has to report no less information
about sockets than proc files.

We use these flags to dump and restore netlink sockets.

Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 include/uapi/linux/netlink_diag.h | 10 ++++++++++
 net/netlink/af_netlink.c          |  8 --------
 net/netlink/af_netlink.h          |  8 ++++++++
 net/netlink/diag.c                | 25 +++++++++++++++++++++++++
 4 files changed, 43 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
index 76b4d87..6dcd4de 100644
--- a/include/uapi/linux/netlink_diag.h
+++ b/include/uapi/linux/netlink_diag.h
@@ -38,6 +38,7 @@ enum {
 	NETLINK_DIAG_GROUPS,
 	NETLINK_DIAG_RX_RING,
 	NETLINK_DIAG_TX_RING,
+	NETLINK_DIAG_FLAGS,
 
 	__NETLINK_DIAG_MAX,
 };
@@ -52,5 +53,14 @@ enum {
 /* deprecated since 4.6 */
 #define NDIAG_SHOW_RING_CFG	0x00000004 /* show ring configuration */
 #endif
+#define NDIAG_SHOW_FLAGS	0x00000008 /* show flags of a netlink socket */
+
+/* flags */
+#define NDIAG_FLAG_CB_RUNNING		0x00000001
+#define NDIAG_FLAG_PKTINFO		0x00000002
+#define NDIAG_FLAG_BROADCAST_ERROR	0x00000004
+#define NDIAG_FLAG_NO_ENOBUFS		0x00000008
+#define NDIAG_FLAG_LISTEN_ALL_NSID	0x00000010
+#define NDIAG_FLAG_CAP_ACK		0x00000020
 
 #endif
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 596eaff..fc23244 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -78,14 +78,6 @@ struct listeners {
 /* state bits */
 #define NETLINK_S_CONGESTED		0x0
 
-/* flags */
-#define NETLINK_F_KERNEL_SOCKET		0x1
-#define NETLINK_F_RECV_PKTINFO		0x2
-#define NETLINK_F_BROADCAST_SEND_ERROR	0x4
-#define NETLINK_F_RECV_NO_ENOBUFS	0x8
-#define NETLINK_F_LISTEN_ALL_NSID	0x10
-#define NETLINK_F_CAP_ACK		0x20
-
 static inline int netlink_is_kernel(struct sock *sk)
 {
 	return nlk_sk(sk)->flags & NETLINK_F_KERNEL_SOCKET;
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 4fdb383..f792f8d 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -6,6 +6,14 @@
 #include <linux/workqueue.h>
 #include <net/sock.h>
 
+/* flags */
+#define NETLINK_F_KERNEL_SOCKET		0x1
+#define NETLINK_F_RECV_PKTINFO		0x2
+#define NETLINK_F_BROADCAST_SEND_ERROR	0x4
+#define NETLINK_F_RECV_NO_ENOBUFS	0x8
+#define NETLINK_F_LISTEN_ALL_NSID	0x10
+#define NETLINK_F_CAP_ACK		0x20
+
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 #define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
 
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index a554624..8faa20b 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -19,6 +19,27 @@ static int sk_diag_dump_groups(struct sock *sk, struct sk_buff *nlskb)
 		       nlk->groups);
 }
 
+static int sk_diag_put_flags(struct sock *sk, struct sk_buff *skb)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+	u32 flags = 0;
+
+	if (nlk->cb_running)
+		flags |= NDIAG_FLAG_CB_RUNNING;
+	if (nlk->flags & NETLINK_F_RECV_PKTINFO)
+		flags |= NDIAG_FLAG_PKTINFO;
+	if (nlk->flags & NETLINK_F_BROADCAST_SEND_ERROR)
+		flags |= NDIAG_FLAG_BROADCAST_ERROR;
+	if (nlk->flags & NETLINK_F_RECV_NO_ENOBUFS)
+		flags |= NDIAG_FLAG_NO_ENOBUFS;
+	if (nlk->flags & NETLINK_F_LISTEN_ALL_NSID)
+		flags |= NDIAG_FLAG_LISTEN_ALL_NSID;
+	if (nlk->flags & NETLINK_F_CAP_ACK)
+		flags |= NDIAG_FLAG_CAP_ACK;
+
+	return nla_put_u32(skb, NETLINK_DIAG_FLAGS, flags);
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			struct netlink_diag_req *req,
 			u32 portid, u32 seq, u32 flags, int sk_ino)
@@ -52,6 +73,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	    sock_diag_put_meminfo(sk, skb, NETLINK_DIAG_MEMINFO))
 		goto out_nlmsg_trim;
 
+	if ((req->ndiag_show & NDIAG_SHOW_FLAGS) &&
+	    sk_diag_put_flags(sk, skb))
+		goto out_nlmsg_trim;
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
-- 
2.9.3
