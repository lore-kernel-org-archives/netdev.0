From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/5] net/udp: factor out main skb processing routine
Date: Fri, 25 Nov 2016 16:39:54 +0100
Message-ID: <49cd43223aa03a70189983514b53a1d41a522d3e.1480086321.git.pabeni@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50854 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754900AbcKYPlS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 10:41:18 -0500
In-Reply-To: <cover.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we will reuse it later for mmsg implementation

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 67 ++++++++++++++++++++++++++++++++---------------------
 net/ipv6/udp.c | 73 ++++++++++++++++++++++++++++++++++++----------------------
 2 files changed, 86 insertions(+), 54 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b3b6bc5..d99429d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1350,34 +1350,18 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 }
 EXPORT_SYMBOL(udp_ioctl);
 
-/*
- * 	This should be easy, if there is something there we
- * 	return it, otherwise we block.
- */
-
-int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
-		int flags, int *addr_len)
+static int udp_process_skb(struct sock *sk, struct sk_buff *skb,
+			   struct msghdr *msg, size_t len, int flags,
+			   int *addr_len, int off, int peeking, int peeked)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
-	struct sk_buff *skb;
-	unsigned int ulen, copied;
-	int peeked, peeking, off;
-	int err;
+	struct inet_sock *inet = inet_sk(sk);
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
+	int ulen = skb->len;
+	int copied = len;
+	int err;
 
-	if (flags & MSG_ERRQUEUE)
-		return ip_recv_error(sk, msg, len, addr_len);
-
-try_again:
-	peeking = off = sk_peek_offset(sk, flags);
-	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
-	if (!skb)
-		return err;
-
-	ulen = skb->len;
-	copied = len;
 	if (copied > ulen - off)
 		copied = ulen - off;
 	else if (copied < ulen)
@@ -1446,10 +1430,41 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	}
 	kfree_skb(skb);
 
-	/* starting over for a new packet, but check if we need to yield */
-	cond_resched();
 	msg->msg_flags &= ~MSG_TRUNC;
-	goto try_again;
+	return -EINVAL;
+}
+
+/*
+ *	This should be easy, if there is something there we
+ *	return it, otherwise we block.
+ */
+int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
+		int flags, int *addr_len)
+{
+	struct sk_buff *skb;
+	int peeked, peeking, off;
+	int err;
+
+	if (flags & MSG_ERRQUEUE)
+		return ip_recv_error(sk, msg, len, addr_len);
+
+try_again:
+	peeking = off = sk_peek_offset(sk, flags);
+	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
+	if (!skb)
+		return err;
+
+	err = udp_process_skb(sk, skb, msg, len, flags, addr_len, off, peeking,
+			      peeked);
+	if (err < 0) {
+		if (err != -EINVAL)
+			return err;
+
+		/* restarting for a new packet, but check if we need to yield */
+		cond_resched();
+		goto try_again;
+	}
+	return err;
 }
 
 int __udp_disconnect(struct sock *sk, int flags)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index ba25ec2..3218c64 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -318,38 +318,19 @@ struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be
 EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 #endif
 
-/*
- *	This should be easy, if there is something there we
- *	return it, otherwise we block.
- */
-
-int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
-		  int noblock, int flags, int *addr_len)
+static int udp6_process_skb(struct sock *sk, struct sk_buff *skb,
+			    struct msghdr *msg, size_t len, int flags,
+			    int *addr_len, int off, int peeking, int peeked)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
-	struct sk_buff *skb;
-	unsigned int ulen, copied;
-	int peeked, peeking, off;
-	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
+	int ulen = skb->len;
+	int copied = len;
 	int is_udp4;
+	int err;
 
-	if (flags & MSG_ERRQUEUE)
-		return ipv6_recv_error(sk, msg, len, addr_len);
-
-	if (np->rxpmtu && np->rxopt.bits.rxpmtu)
-		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
-
-try_again:
-	peeking = off = sk_peek_offset(sk, flags);
-	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
-	if (!skb)
-		return err;
-
-	ulen = skb->len;
-	copied = len;
 	if (copied > ulen - off)
 		copied = ulen - off;
 	else if (copied < ulen)
@@ -456,10 +437,46 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	}
 	kfree_skb(skb);
 
-	/* starting over for a new packet, but check if we need to yield */
-	cond_resched();
 	msg->msg_flags &= ~MSG_TRUNC;
-	goto try_again;
+	return -EINVAL;
+}
+
+/*
+ *	This should be easy, if there is something there we
+ *	return it, otherwise we block.
+ */
+int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+		  int noblock, int flags, int *addr_len)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	int peeked, peeking, off;
+	struct sk_buff *skb;
+	int err;
+
+	if (flags & MSG_ERRQUEUE)
+		return ipv6_recv_error(sk, msg, len, addr_len);
+
+	if (np->rxpmtu && np->rxopt.bits.rxpmtu)
+		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
+
+try_again:
+	peeking = off = sk_peek_offset(sk, flags);
+	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
+	if (!skb)
+		return err;
+
+	err = udp6_process_skb(sk, skb, msg, len, flags, addr_len, off, peeking,
+			       peeked);
+	if (err < 0) {
+		if (err != -EINVAL)
+			return err;
+
+		/* restarting for a new packet, but check if we need to yield */
+		cond_resched();
+		goto try_again;
+	}
+	return err;
+
 }
 
 void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-- 
1.8.3.1
