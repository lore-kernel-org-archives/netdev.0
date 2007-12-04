From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/3] [UDP]: Only increment counter on first peek/recv
Date: Wed, 5 Dec 2007 00:03:10 +1100
Message-ID: <20071204130310.GB3098@gondor.apana.org.au>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1415 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754403AbXLDNDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 08:03:14 -0500
Content-Disposition: inline
In-Reply-To: <20071204130109.GA3098@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[UDP]: Only increment counter on first peek/recv

The previous move of the the UDP inDatagrams counter caused each
peek of the same packet to be counted separately.  This may be
undesirable.

This patch fixes this by adding a bit to sk_buff to record whether
this packet has already been seen through skb_recv_datagram.  We
then only increment the counter when the packet is seen for the
first time.

The only dodgy part is the fact that skb_recv_datagram doesn't have
a good way of returning this new bit of information.  So I've added
a new function __skb_recv_datagram that does return this and made
skb_recv_datagram a wrapper around it.

The plan is to eventually replace all uses of skb_recv_datagram with
this new function at which time it can be renamed its proper name.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/skbuff.h |    3 +++
 net/core/datagram.c    |   41 ++++++++++++++++++++++++++---------------
 net/ipv4/udp.c         |    7 +++++--
 net/ipv6/udp.c         |    7 +++++--
 4 files changed, 39 insertions(+), 19 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -291,6 +291,7 @@ struct sk_buff {
 	__u8			pkt_type:3,
 				fclone:2,
 				ipvs_property:1,
+				peeked:1,
 				nf_trace:1;
 	__be16			protocol;
 
@@ -1541,6 +1542,8 @@ static inline int pskb_trim_rcsum(struct
 		     skb = skb->prev)
 
 
+extern struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
+					   int *peeked, int *err);
 extern struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
 					 int noblock, int *err);
 extern unsigned int    datagram_poll(struct file *file, struct socket *sock,
diff --git a/net/core/datagram.c b/net/core/datagram.c
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -115,10 +115,10 @@ out_noerr:
 }
 
 /**
- *	skb_recv_datagram - Receive a datagram skbuff
+ *	__skb_recv_datagram - Receive a datagram skbuff
  *	@sk: socket
  *	@flags: MSG_ flags
- *	@noblock: blocking operation?
+ *	@peeked: returns non-zero if this packet has been seen before
  *	@err: error code returned
  *
  *	Get a datagram skbuff, understands the peeking, nonblocking wakeups
@@ -143,8 +143,8 @@ out_noerr:
  *	quite explicitly by POSIX 1003.1g, don't change them without having
  *	the standard around please.
  */
-struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
-				  int noblock, int *err)
+struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
+				    int *peeked, int *err)
 {
 	struct sk_buff *skb;
 	long timeo;
@@ -156,7 +156,7 @@ struct sk_buff *skb_recv_datagram(struct
 	if (error)
 		goto no_packet;
 
-	timeo = sock_rcvtimeo(sk, noblock);
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
 	do {
 		/* Again only user level code calls this function, so nothing
@@ -165,18 +165,19 @@ struct sk_buff *skb_recv_datagram(struct
 		 * Look at current nfs client by the way...
 		 * However, this function was corrent in any case. 8)
 		 */
-		if (flags & MSG_PEEK) {
-			unsigned long cpu_flags;
+		unsigned long cpu_flags;
 
-			spin_lock_irqsave(&sk->sk_receive_queue.lock,
-					  cpu_flags);
-			skb = skb_peek(&sk->sk_receive_queue);
-			if (skb)
+		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb) {
+			*peeked = skb->peeked;
+			if (flags & MSG_PEEK) {
+				skb->peeked = 1;
 				atomic_inc(&skb->users);
-			spin_unlock_irqrestore(&sk->sk_receive_queue.lock,
-					       cpu_flags);
-		} else
-			skb = skb_dequeue(&sk->sk_receive_queue);
+			} else
+				__skb_unlink(skb, &sk->sk_receive_queue);
+		}
+		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 
 		if (skb)
 			return skb;
@@ -194,6 +195,16 @@ no_packet:
 	*err = error;
 	return NULL;
 }
+EXPORT_SYMBOL(__skb_recv_datagram);
+
+struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
+				  int noblock, int *err)
+{
+	int peeked;
+
+	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
+				   &peeked, err);
+}
 
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
 {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -827,6 +827,7 @@ int udp_recvmsg(struct kiocb *iocb, stru
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
+	int peeked;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 
@@ -840,7 +841,8 @@ int udp_recvmsg(struct kiocb *iocb, stru
 		return ip_recv_error(sk, msg, len);
 
 try_again:
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
+				  &peeked, &err);
 	if (!skb)
 		goto out;
 
@@ -875,7 +877,8 @@ try_again:
 	if (err)
 		goto out_free;
 
-	UDP_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
+	if (!peeked)
+		UDP_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
 
 	sock_recv_timestamp(msg, sk, skb);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -121,6 +121,7 @@ int udpv6_recvmsg(struct kiocb *iocb, st
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
+	int peeked;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 
@@ -131,7 +132,8 @@ int udpv6_recvmsg(struct kiocb *iocb, st
 		return ipv6_recv_error(sk, msg, len);
 
 try_again:
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
+				  &peeked, &err);
 	if (!skb)
 		goto out;
 
@@ -164,7 +166,8 @@ try_again:
 	if (err)
 		goto out_free;
 
-	UDP6_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
+	if (!peeked)
+		UDP6_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
 
 	sock_recv_timestamp(msg, sk, skb);
 
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
