From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 7/7] netlink: allow to listen "all" netns
Date: Thu,  7 May 2015 11:02:53 +0200
Message-ID: <1430989373-4515-8-git-send-email-nicolas.dichtel@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: tgraf@suug.ch, davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43511 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbbEGJDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 05:03:06 -0400
In-Reply-To: <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
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

Because 0 is a valid value for a nsid, the field nsid_is_set indicates if
the field nsid is valid or not. skb->cb is initialized to 0 on skb
allocation, thus we are sure that we will never send a nsid 0 by error to
the userland.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: put the nsid into the skb cb instead of the net pointer
    rename NETLINK_LISTEN_ALL to NETLINK_F_LISTEN_ALL_NSID

 include/linux/netlink.h      |  2 ++
 include/net/net_namespace.h  |  2 ++
 include/uapi/linux/netlink.h |  1 +
 net/core/net_namespace.c     | 10 ++++++++-
 net/netlink/af_netlink.c     | 52 +++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 61 insertions(+), 6 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 6835c1279df7..9120edb650a0 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -28,6 +28,8 @@ struct netlink_skb_parms {
 	__u32			dst_group;
 	__u32			flags;
 	struct sock		*sk;
+	bool			nsid_is_set;
+	int			nsid;
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
index ae5008b097de..a665bf490c88 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -229,7 +229,7 @@ int peernet2id_alloc(struct net *net, struct net *peer)
 EXPORT_SYMBOL(peernet2id_alloc);
 
 /* This function returns, if assigned, the id of a peer netns. */
-static int peernet2id(struct net *net, struct net *peer)
+int peernet2id(struct net *net, struct net *peer)
 {
 	unsigned long flags;
 	int id;
@@ -240,6 +240,14 @@ static int peernet2id(struct net *net, struct net *peer)
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
index bf7f56d7a9aa..a5fff75accf8 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -83,6 +83,7 @@ struct listeners {
 #define NETLINK_F_RECV_PKTINFO		0x2
 #define NETLINK_F_BROADCAST_SEND_ERROR	0x4
 #define NETLINK_F_RECV_NO_ENOBUFS	0x8
+#define NETLINK_F_LISTEN_ALL_NSID	0x10
 
 static inline int netlink_is_kernel(struct sock *sk)
 {
@@ -1932,8 +1933,17 @@ static void do_one_broadcast(struct sock *sk,
 	    !test_bit(p->group - 1, nlk->groups))
 		return;
 
-	if (!net_eq(sock_net(sk), p->net))
-		return;
+	if (!net_eq(sock_net(sk), p->net)) {
+		if (!(nlk->flags & NETLINK_F_LISTEN_ALL_NSID))
+			return;
+
+		if (!peernet_has_id(sock_net(sk), p->net))
+			return;
+
+		if (!file_ns_capable(sk->sk_socket->file, p->net->user_ns,
+				     CAP_NET_BROADCAST))
+			return;
+	}
 
 	if (p->failure) {
 		netlink_overrun(sk);
@@ -1959,13 +1969,22 @@ static void do_one_broadcast(struct sock *sk,
 		p->failure = 1;
 		if (nlk->flags & NETLINK_F_BROADCAST_SEND_ERROR)
 			p->delivery_failure = 1;
-	} else if (p->tx_filter && p->tx_filter(sk, p->skb2, p->tx_data)) {
+		goto out;
+	}
+	if (p->tx_filter && p->tx_filter(sk, p->skb2, p->tx_data)) {
 		kfree_skb(p->skb2);
 		p->skb2 = NULL;
-	} else if (sk_filter(sk, p->skb2)) {
+		goto out;
+	}
+	if (sk_filter(sk, p->skb2)) {
 		kfree_skb(p->skb2);
 		p->skb2 = NULL;
-	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
+		goto out;
+	}
+	NETLINK_CB(p->skb2).nsid = peernet2id(sock_net(sk), p->net);
+	NETLINK_CB(p->skb2).nsid_is_set = true;
+	val = netlink_broadcast_deliver(sk, p->skb2);
+	if (val < 0) {
 		netlink_overrun(sk);
 		if (nlk->flags & NETLINK_F_BROADCAST_SEND_ERROR)
 			p->delivery_failure = 1;
@@ -1974,6 +1993,7 @@ static void do_one_broadcast(struct sock *sk,
 		p->delivered = 1;
 		p->skb2 = NULL;
 	}
+out:
 	sock_put(sk);
 }
 
@@ -2202,6 +2222,16 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	}
 #endif /* CONFIG_NETLINK_MMAP */
+	case NETLINK_LISTEN_ALL_NSID:
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_BROADCAST))
+			return -EPERM;
+
+		if (val)
+			nlk->flags |= NETLINK_F_LISTEN_ALL_NSID;
+		else
+			nlk->flags &= ~NETLINK_F_LISTEN_ALL_NSID;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -2268,6 +2298,16 @@ static void netlink_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_NETLINK, NETLINK_PKTINFO, sizeof(info), &info);
 }
 
+static void netlink_cmsg_listen_all_nsid(struct sock *sk, struct msghdr *msg,
+					 struct sk_buff *skb)
+{
+	if (!NETLINK_CB(skb).nsid_is_set)
+		return;
+
+	put_cmsg(msg, SOL_NETLINK, NETLINK_LISTEN_ALL_NSID, sizeof(int),
+		 &NETLINK_CB(skb).nsid);
+}
+
 static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
@@ -2421,6 +2461,8 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 	if (nlk->flags & NETLINK_F_RECV_PKTINFO)
 		netlink_cmsg_recv_pktinfo(msg, skb);
+	if (nlk->flags & NETLINK_F_LISTEN_ALL_NSID)
+		netlink_cmsg_listen_all_nsid(sk, msg, skb);
 
 	memset(&scm, 0, sizeof(scm));
 	scm.creds = *NETLINK_CREDS(skb);
-- 
2.2.2
