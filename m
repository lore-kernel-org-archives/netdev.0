From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 3/3] IPv6: Complete IPV6_DONTFRAG support
Date: Fri, 23 Apr 2010 17:26:09 -0400
Message-ID: <1272057969-6526-4-git-send-email-brian.haley@hp.com>
References: <>
 <1272057969-6526-1-git-send-email-brian.haley@hp.com>
 <1272057969-6526-2-git-send-email-brian.haley@hp.com>
 <1272057969-6526-3-git-send-email-brian.haley@hp.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:42510 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307Ab0DWVei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 17:34:38 -0400
In-Reply-To: <1272057969-6526-3-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Finally add support to detect a local IPV6_DONTFRAG event
and return the relevant data to the user if they've enabled
IPV6_RECVPATHMTU on the socket.  The next recvmsg() will
return no data, but have an IPV6_PATHMTU as ancillary data.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
 include/linux/ipv6.h  |    2 +
 include/net/ipv6.h    |    2 +
 net/ipv6/af_inet6.c   |    3 ++
 net/ipv6/datagram.c   |   87 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_output.c |   24 +++++++++----
 net/ipv6/raw.c        |    3 ++
 net/ipv6/udp.c        |    3 ++
 7 files changed, 116 insertions(+), 8 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 1976942..2ab5509 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -257,6 +257,7 @@ struct inet6_skb_parm {
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
+#define IP6CBMTU(skb)	((struct ip6_mtuinfo *)((skb)->cb))
 
 static inline int inet6_iif(const struct sk_buff *skb)
 {
@@ -366,6 +367,7 @@ struct ipv6_pinfo {
 
 	struct ipv6_txoptions	*opt;
 	struct sk_buff		*pktoptions;
+	struct sk_buff		*rxpmtu;
 	struct {
 		struct ipv6_txoptions *opt;
 		u8 hop_limit;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7ab6323..eba5cc0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -578,9 +578,11 @@ extern int			ip6_datagram_connect(struct sock *sk,
 						     struct sockaddr *addr, int addr_len);
 
 extern int 			ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len);
+extern int 			ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len);
 extern void			ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
 						u32 info, u8 *payload);
 extern void			ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info);
+extern void			ipv6_local_rxpmtu(struct sock *sk, struct flowi *fl, u32 mtu);
 
 extern int inet6_release(struct socket *sock);
 extern int inet6_bind(struct socket *sock, struct sockaddr *uaddr, 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3192aa0..d2df314 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -417,6 +417,9 @@ void inet6_destroy_sock(struct sock *sk)
 	if ((skb = xchg(&np->pktoptions, NULL)) != NULL)
 		kfree_skb(skb);
 
+	if ((skb = xchg(&np->rxpmtu, NULL)) != NULL)
+		kfree_skb(skb);
+
 	/* Free flowlabels */
 	fl6_free_socklist(sk);
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index f5076d3..5959230 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -278,6 +278,45 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info)
 		kfree_skb(skb);
 }
 
+void ipv6_local_rxpmtu(struct sock *sk, struct flowi *fl, u32 mtu)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6hdr *iph;
+	struct sk_buff *skb;
+	struct ip6_mtuinfo *mtu_info;
+
+	if (!np->rxopt.bits.rxpmtu)
+		return;
+
+	skb = alloc_skb(sizeof(struct ipv6hdr), GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	skb_put(skb, sizeof(struct ipv6hdr));
+	skb_reset_network_header(skb);
+	iph = ipv6_hdr(skb);
+	ipv6_addr_copy(&iph->daddr, &fl->fl6_dst);
+
+	mtu_info = IP6CBMTU(skb);
+	if (!mtu_info) {
+		kfree_skb(skb);
+		return;
+	}
+
+	mtu_info->ip6m_mtu = mtu;
+	mtu_info->ip6m_addr.sin6_family = AF_INET6;
+	mtu_info->ip6m_addr.sin6_port = 0;
+	mtu_info->ip6m_addr.sin6_flowinfo = 0;
+	mtu_info->ip6m_addr.sin6_scope_id = fl->oif;
+	ipv6_addr_copy(&mtu_info->ip6m_addr.sin6_addr, &ipv6_hdr(skb)->daddr);
+
+	__skb_pull(skb, skb_tail_pointer(skb) - skb->data);
+	skb_reset_transport_header(skb);
+
+	skb = xchg(&np->rxpmtu, skb);
+	kfree_skb(skb);
+}
+
 /*
  *	Handle MSG_ERRQUEUE
  */
@@ -381,6 +420,54 @@ out:
 	return err;
 }
 
+/*
+ *	Handle IPV6_RECVPATHMTU
+ */
+int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct sk_buff *skb;
+	struct sockaddr_in6 *sin;
+	struct ip6_mtuinfo mtu_info;
+	int err;
+	int copied;
+
+	err = -EAGAIN;
+	skb = xchg(&np->rxpmtu, NULL);
+	if (skb == NULL)
+		goto out;
+
+	copied = skb->len;
+	if (copied > len) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto out_free_skb;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	memcpy(&mtu_info, IP6CBMTU(skb), sizeof(mtu_info));
+
+	sin = (struct sockaddr_in6 *)msg->msg_name;
+	if (sin) {
+		sin->sin6_family = AF_INET6;
+		sin->sin6_flowinfo = 0;
+		sin->sin6_port = 0;
+		sin->sin6_scope_id = mtu_info.ip6m_addr.sin6_scope_id;
+		ipv6_addr_copy(&sin->sin6_addr, &mtu_info.ip6m_addr.sin6_addr);
+	}
+
+	put_cmsg(msg, SOL_IPV6, IPV6_PATHMTU, sizeof(mtu_info), &mtu_info);
+
+	err = copied;
+
+out_free_skb:
+	kfree_skb(skb);
+out:
+	return err;
+}
 
 
 int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 54d43dd..61e2bef 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1219,15 +1219,23 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	 */
 
 	inet->cork.length += length;
-	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
-	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+	if (length > mtu) {
+		int proto = sk->sk_protocol;
+		if (dontfrag && (proto == IPPROTO_UDP || proto == IPPROTO_RAW)){
+			ipv6_local_rxpmtu(sk, fl, mtu-exthdrlen);
+			return -EMSGSIZE;
+		}
 
-		err = ip6_ufo_append_data(sk, getfrag, from, length, hh_len,
-					  fragheaderlen, transhdrlen, mtu,
-					  flags);
-		if (err)
-			goto error;
-		return 0;
+		if (proto == IPPROTO_UDP &&
+		    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+
+			err = ip6_ufo_append_data(sk, getfrag, from, length,
+						  hh_len, fragheaderlen,
+						  transhdrlen, mtu, flags);
+			if (err)
+				goto error;
+			return 0;
+		}
 	}
 
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 44a84ea..8562738 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -461,6 +461,9 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (flags & MSG_ERRQUEUE)
 		return ipv6_recv_error(sk, msg, len);
 
+	if (np->rxpmtu && np->rxopt.bits.rxpmtu)
+		return ipv6_recv_rxpmtu(sk, msg, len);
+
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
 		goto out;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 39e3665..2850e35 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -335,6 +335,9 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (flags & MSG_ERRQUEUE)
 		return ipv6_recv_error(sk, msg, len);
 
+	if (np->rxpmtu && np->rxopt.bits.rxpmtu)
+		return ipv6_recv_rxpmtu(sk, msg, len);
+
 try_again:
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				  &peeked, &err);
-- 
1.5.4.3

