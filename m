From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 2/3] netlink: add an ability to restore messages in a receive queue
Date: Sun, 12 Jun 2016 23:07:20 -0700
Message-ID: <1465798041-6783-3-git-send-email-avagin@openvz.org>
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
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36518 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933270AbcFMGIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:08:31 -0400
Received: by mail-pf0-f195.google.com with SMTP id 62so9881714pfd.3
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:08:31 -0700 (PDT)
In-Reply-To: <1465798041-6783-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an repair mode for netlink sockets. sendmsg queues
messages into a receive queue if a socket is in the repair mode.

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/uapi/linux/netlink.h |  1 +
 net/netlink/af_netlink.c     | 50 +++++++++++++++++++++++++++++++-------------
 2 files changed, 36 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 0dba4e4..6472679 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -114,6 +114,7 @@ struct nlmsgerr {
 #define NETLINK_LISTEN_ALL_NSID		8
 #define NETLINK_LIST_MEMBERSHIPS	9
 #define NETLINK_CAP_ACK			10
+#define NETLINK_REPAIR			11
 
 struct nl_pktinfo {
 	__u32	group;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d334ffc..18347a4 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -85,6 +85,7 @@ struct listeners {
 #define NETLINK_F_RECV_NO_ENOBUFS	0x8
 #define NETLINK_F_LISTEN_ALL_NSID	0x10
 #define NETLINK_F_CAP_ACK		0x20
+#define NETLINK_F_REPAIR		0x40
 
 static inline int netlink_is_kernel(struct sock *sk)
 {
@@ -1223,6 +1224,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
 		    u32 portid, int nonblock)
 {
+	struct netlink_sock *nlk = nlk_sk(ssk);
 	struct sock *sk;
 	int err;
 	long timeo;
@@ -1231,19 +1233,24 @@ int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
 
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:
-	sk = netlink_getsockbyportid(ssk, portid);
-	if (IS_ERR(sk)) {
-		kfree_skb(skb);
-		return PTR_ERR(sk);
-	}
-	if (netlink_is_kernel(sk))
-		return netlink_unicast_kernel(sk, skb, ssk);
+	if (nlk->flags & NETLINK_F_REPAIR) {
+		sk = ssk;
+		sock_hold(sk);
+	} else {
+		sk = netlink_getsockbyportid(ssk, portid);
+		if (IS_ERR(sk)) {
+			kfree_skb(skb);
+			return PTR_ERR(sk);
+		}
+		if (netlink_is_kernel(sk))
+			return netlink_unicast_kernel(sk, skb, ssk);
 
-	if (sk_filter(sk, skb)) {
-		err = skb->len;
-		kfree_skb(skb);
-		sock_put(sk);
-		return err;
+		if (sk_filter(sk, skb)) {
+			err = skb->len;
+			kfree_skb(skb);
+			sock_put(sk);
+			return err;
+		}
 	}
 
 	err = netlink_attachskb(sk, skb, &timeo, ssk);
@@ -1537,6 +1544,13 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		return -EFAULT;
 
 	switch (optname) {
+	case NETLINK_REPAIR:
+		if (val)
+			nlk->flags |= NETLINK_F_REPAIR;
+		else
+			nlk->flags &= ~NETLINK_F_REPAIR;
+		err = 0;
+		break;
 	case NETLINK_PKTINFO:
 		if (val)
 			nlk->flags |= NETLINK_F_RECV_PKTINFO;
@@ -1721,6 +1735,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	int err;
 	struct scm_cookie scm;
 	u32 netlink_skb_flags = 0;
+	bool repair = nlk->flags & NETLINK_F_REPAIR;
 
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
@@ -1737,7 +1752,8 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
 		if ((dst_group || dst_portid) &&
-		    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
+		    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND &&
+		    !repair))
 			goto out;
 		netlink_skb_flags |= NETLINK_SKB_DST;
 	} else {
@@ -1762,7 +1778,11 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	if (skb == NULL)
 		goto out;
 
-	NETLINK_CB(skb).portid	= nlk->portid;
+	if (unlikely(repair))
+		NETLINK_CB(skb).portid = dst_portid;
+	else
+		NETLINK_CB(skb).portid	= nlk->portid;
+
 	NETLINK_CB(skb).dst_group = dst_group;
 	NETLINK_CB(skb).creds	= scm.creds;
 	NETLINK_CB(skb).flags	= netlink_skb_flags;
@@ -1779,7 +1799,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		goto out;
 	}
 
-	if (dst_group) {
+	if (dst_group && !repair) {
 		atomic_inc(&skb->users);
 		netlink_broadcast(sk, skb, dst_portid, dst_group, GFP_KERNEL);
 	}
-- 
2.5.5
