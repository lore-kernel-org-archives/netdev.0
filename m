From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 6/6] netlink: allow to listen "all" netns
Date: Wed,  6 May 2015 11:58:08 +0200
Message-ID: <1430906288-5108-7-git-send-email-nicolas.dichtel@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42323 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbbEFJ6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:58:18 -0400
In-Reply-To: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More accurately, listen all netns that have a nsid assigned into the netns
where the netlink socket is opened.
For this purpose, a netlink socket option is added:
NETLINK_LISTEN_ALL_NSID. When this option is set on a netlink socket, this
socket will receive netlink notifications from all netns that have a nsid
assigned into the netns where the socket has been opened. The nsid is sent
to userland via an anscillary data.

With this patch, a daemon needs only one socket to listen many netns. This
is useful when the number of netns is high.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netlink.h      |  1 +
 include/net/net_namespace.h  |  2 ++
 include/uapi/linux/netlink.h |  1 +
 net/core/net_namespace.c     | 10 +++++++++-
 net/netlink/af_netlink.c     | 39 +++++++++++++++++++++++++++++++++++++--
 5 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 6835c1279df7..2e34392ddfb7 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -28,6 +28,7 @@ struct netlink_skb_parms {
 	__u32			dst_group;
 	__u32			flags;
 	struct sock		*sk;
+	struct net		*net;
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 6d1e2eae32fb..3f850acc844e 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -272,6 +272,8 @@ static inline struct net *read_pnet(const possible_net_t *pnet)
 #endif
 
 int peernet2id_alloc(struct net *net, struct net *peer);
+int peernet2id(struct net *net, struct net *peer);
+bool peernet_has_id(struct net *net, struct net *peer);
 struct net *get_net_ns_by_id(struct net *net, int id);
 
 struct pernet_operations {
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 1a85940f8ab7..3e34b7d702f8 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -108,6 +108,7 @@ struct nlmsgerr {
 #define NETLINK_NO_ENOBUFS	5
 #define NETLINK_RX_RING		6
 #define NETLINK_TX_RING		7
+#define NETLINK_LISTEN_ALL_NSID	8
 
 struct nl_pktinfo {
 	__u32	group;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 0b4cb3d63449..2af3cc4ecf2d 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -221,7 +221,7 @@ int peernet2id_alloc(struct net *net, struct net *peer)
 EXPORT_SYMBOL(peernet2id_alloc);
 
 /* This function returns, if assigned, the id of a peer netns. */
-static int peernet2id(struct net *net, struct net *peer)
+int peernet2id(struct net *net, struct net *peer)
 {
 	unsigned long flags;
 	bool no = false;
@@ -233,6 +233,14 @@ static int peernet2id(struct net *net, struct net *peer)
 	return id;
 }
 
+/* This function returns true is the peer netns has an id assigned into the
+ * current netns.
+ */
+bool peernet_has_id(struct net *net, struct net *peer)
+{
+	return peernet2id(net, peer) >= 0;
+}
+
 struct net *get_net_ns_by_id(struct net *net, int id)
 {
 	unsigned long flags;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbdcb9b4..bdbde542e952 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -83,6 +83,7 @@ struct listeners {
 #define NETLINK_RECV_PKTINFO	0x2
 #define NETLINK_BROADCAST_SEND_ERROR	0x4
 #define NETLINK_RECV_NO_ENOBUFS	0x8
+#define NETLINK_LISTEN_ALL	0x10
 
 static inline int netlink_is_kernel(struct sock *sk)
 {
@@ -1931,8 +1932,18 @@ static void do_one_broadcast(struct sock *sk,
 	    !test_bit(p->group - 1, nlk->groups))
 		return;
 
-	if (!net_eq(sock_net(sk), p->net))
-		return;
+	if (!net_eq(sock_net(sk), p->net)) {
+		if (!(nlk->flags & NETLINK_LISTEN_ALL))
+			return;
+
+		if (!peernet_has_id(sock_net(sk), p->net))
+			return;
+
+		if (!file_ns_capable(sk->sk_socket->file, p->net->user_ns,
+				     CAP_NET_BROADCAST))
+			return;
+	}
+	NETLINK_CB(p->skb).net = p->net;
 
 	if (p->failure) {
 		netlink_overrun(sk);
@@ -2201,6 +2212,16 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	}
 #endif /* CONFIG_NETLINK_MMAP */
+	case NETLINK_LISTEN_ALL_NSID:
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_BROADCAST))
+			return -EPERM;
+
+		if (val)
+			nlk->flags |= NETLINK_LISTEN_ALL;
+		else
+			nlk->flags &= ~NETLINK_LISTEN_ALL;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -2267,6 +2288,18 @@ static void netlink_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_NETLINK, NETLINK_PKTINFO, sizeof(info), &info);
 }
 
+static void netlink_cmsg_listen_all_nsid(struct sock *sk, struct msghdr *msg,
+					 struct sk_buff *skb)
+{
+	int nsid;
+
+	if (!NETLINK_CB(skb).net)
+		return;
+
+	nsid = peernet2id(sock_net(sk), NETLINK_CB(skb).net);
+	put_cmsg(msg, SOL_NETLINK, NETLINK_LISTEN_ALL_NSID, sizeof(int), &nsid);
+}
+
 static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
@@ -2420,6 +2453,8 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 	if (nlk->flags & NETLINK_RECV_PKTINFO)
 		netlink_cmsg_recv_pktinfo(msg, skb);
+	if (nlk->flags & NETLINK_LISTEN_ALL)
+		netlink_cmsg_listen_all_nsid(sk, msg, skb);
 
 	memset(&scm, 0, sizeof(scm));
 	scm.creds = *NETLINK_CREDS(skb);
-- 
2.2.2
