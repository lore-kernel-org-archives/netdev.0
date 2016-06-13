From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 3/3] netlink/diag: report flags for netlink sockets
Date: Sun, 12 Jun 2016 23:07:21 -0700
Message-ID: <1465798041-6783-4-git-send-email-avagin@openvz.org>
References: <1465798041-6783-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, Andrey Vagin <avagin@openvz.org>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Herrmann <dh.herrmann@gmail.com>,
	Christophe Ricard <christophe.ricard@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34348 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933300AbcFMGIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:08:32 -0400
Received: by mail-pf0-f194.google.com with SMTP id 66so8022657pfy.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:08:32 -0700 (PDT)
In-Reply-To: <1465798041-6783-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to know flags for dumping and restoring netlink sockets.

All flags except NDIAG_FLAG_CB_RUNNING can be received with help of
getsockopt(), but in this case we need a socket descriptor and we need
to call getsockopt() to get each flag.

With this chages we will be able to show netlink sockets flags from the
ss tool.

In criu, we need to know if a callback is running now or not.

When a socket has some data in a receive queue and doesn't have running
callbacks, we can save all data from a receive queue on dump and queue
them back on restore.

If a socket has a running callback, a receive queue contains only a part
of data, and as soon as we read them, the callback will generate a new
portion. In this case, we can't be sure that all data will not exceed a
buffer limit on restore.

Now we are going to dump and restore sockets without running callbacks.

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/uapi/linux/netlink_diag.h | 10 ++++++++++
 net/netlink/af_netlink.c          |  9 ---------
 net/netlink/af_netlink.h          |  9 +++++++++
 net/netlink/diag.c                | 25 +++++++++++++++++++++++++
 4 files changed, 44 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
index d793993..1bf899b 100644
--- a/include/uapi/linux/netlink_diag.h
+++ b/include/uapi/linux/netlink_diag.h
@@ -38,6 +38,7 @@ enum {
 	NETLINK_DIAG_GROUPS,
 	NETLINK_DIAG_RX_RING,
 	NETLINK_DIAG_TX_RING,
+	NETLINK_DIAG_FLAGS,
 
 	__NETLINK_DIAG_MAX,
 };
@@ -51,5 +52,14 @@ enum {
 #ifndef __KERNEL__
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
index 18347a4..997a4eb 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -78,15 +78,6 @@ struct listeners {
 /* state bits */
 #define NETLINK_S_CONGESTED		0x0
 
-/* flags */
-#define NETLINK_F_KERNEL_SOCKET		0x1
-#define NETLINK_F_RECV_PKTINFO		0x2
-#define NETLINK_F_BROADCAST_SEND_ERROR	0x4
-#define NETLINK_F_RECV_NO_ENOBUFS	0x8
-#define NETLINK_F_LISTEN_ALL_NSID	0x10
-#define NETLINK_F_CAP_ACK		0x20
-#define NETLINK_F_REPAIR		0x40
-
 static inline int netlink_is_kernel(struct sock *sk)
 {
 	return nlk_sk(sk)->flags & NETLINK_F_KERNEL_SOCKET;
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 3cfd6cc..c996cc7 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -5,6 +5,15 @@
 #include <linux/atomic.h>
 #include <net/sock.h>
 
+/* flags */
+#define NETLINK_F_KERNEL_SOCKET		0x1
+#define NETLINK_F_RECV_PKTINFO		0x2
+#define NETLINK_F_BROADCAST_SEND_ERROR	0x4
+#define NETLINK_F_RECV_NO_ENOBUFS	0x8
+#define NETLINK_F_LISTEN_ALL_NSID	0x10
+#define NETLINK_F_CAP_ACK		0x20
+#define NETLINK_F_REPAIR		0x40
+
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 #define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
 
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 8dd836a..7246da2 100644
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
2.5.5
