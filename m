From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netlink: add NETLINK_BROADCAST_ERROR socket option
Date: Tue, 17 Feb 2009 14:56:02 +0100
Message-ID: <20090217135602.25864.20453.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57163 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751224AbZBQN4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 08:56:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds NETLINK_BROADCAST_ERROR which is a netlink
socket option that the listener can set to make netlink_broadcast()
return errors in the delivery to the caller. This option is useful
if the caller of netlink_broadcast() do something with the result
of the message delivery, like in ctnetlink where it drops a network
packet if the event delivery failed, this is used to enable reliable
logging and state-synchronization. If this socket option is not set,
netlink_broadcast() only reports ESRCH errors and silently ignore
ENOBUFS errors, which is what most netlink_broadcast() callers
should do.

This socket option is based on a suggestion from Patrick McHardy.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |   26 +++++++++++++++++++++++---
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 51b09a1..1e6bf99 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -103,6 +103,7 @@ struct nlmsgerr
 #define NETLINK_ADD_MEMBERSHIP	1
 #define NETLINK_DROP_MEMBERSHIP	2
 #define NETLINK_PKTINFO		3
+#define NETLINK_BROADCAST_ERROR	4
 
 struct nl_pktinfo
 {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6ee69c2..f3f212e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -85,6 +85,7 @@ struct netlink_sock {
 
 #define NETLINK_KERNEL_SOCKET	0x1
 #define NETLINK_RECV_PKTINFO	0x2
+#define NETLINK_BROADCAST_SEND_ERROR	0x4
 
 static inline struct netlink_sock *nlk_sk(struct sock *sk)
 {
@@ -973,7 +974,7 @@ static inline int do_one_broadcast(struct sock *sk,
 	if (!net_eq(sock_net(sk), p->net))
 		goto out;
 
-	if (p->failure) {
+	if ((nlk->flags & NETLINK_BROADCAST_SEND_ERROR) && p->failure) {
 		netlink_overrun(sk);
 		goto out;
 	}
@@ -994,13 +995,15 @@ static inline int do_one_broadcast(struct sock *sk,
 	if (p->skb2 == NULL) {
 		netlink_overrun(sk);
 		/* Clone failed. Notify ALL listeners. */
-		p->failure = 1;
+		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
+			p->failure = 1;
 	} else if (sk_filter(sk, p->skb2)) {
 		kfree_skb(p->skb2);
 		p->skb2 = NULL;
 	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
 		netlink_overrun(sk);
-		p->delivery_failure = 1;
+		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
+			p->delivery_failure = 1;
 	} else {
 		p->congested |= val;
 		p->delivered = 1;
@@ -1163,6 +1166,13 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		err = 0;
 		break;
 	}
+	case NETLINK_BROADCAST_ERROR:
+		if (val)
+			nlk->flags |= NETLINK_BROADCAST_SEND_ERROR;
+		else
+			nlk->flags &= ~NETLINK_BROADCAST_SEND_ERROR;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -1195,6 +1205,16 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 			return -EFAULT;
 		err = 0;
 		break;
+	case NETLINK_BROADCAST_ERROR:
+		if (len < sizeof(int))
+			return -EINVAL;
+		len = sizeof(int);
+		val = nlk->flags & NETLINK_BROADCAST_SEND_ERROR ? 1 : 0;
+		if (put_user(len, optlen) ||
+		    put_user(val, optval))
+			return -EFAULT;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}

