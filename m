From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] [UDP]: Avoid repeated counting of checksum errors due to peeking
Date: Tue, 4 Dec 2007 23:58:44 +1100
Message-ID: <20071204125844.GA2750@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1375 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752177AbXLDM6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 07:58:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[UDP]: Avoid repeated counting of checksum errors due to peeking

Currently it is possible for two processes to peek on the same socket
and end up incrementing the error counter twice for the same packet.

This patch fixes it by making skb_kill_datagram return whether it
succeeded in unlinking the packet and only incrementing the counter
if it did.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/skbuff.h |    2 +-
 net/core/datagram.c    |    9 ++++++++-
 net/ipv4/udp.c         |    5 ++---
 net/ipv6/udp.c         |    4 ++--
 4 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1552,7 +1552,7 @@ extern int	       skb_copy_and_csum_data
 							int hlen,
 							struct iovec *iov);
 extern void	       skb_free_datagram(struct sock *sk, struct sk_buff *skb);
-extern void	       skb_kill_datagram(struct sock *sk, struct sk_buff *skb,
+extern int	       skb_kill_datagram(struct sock *sk, struct sk_buff *skb,
 					 unsigned int flags);
 extern __wsum	       skb_checksum(const struct sk_buff *skb, int offset,
 				    int len, __wsum csum);
diff --git a/net/core/datagram.c b/net/core/datagram.c
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -217,20 +217,27 @@ void skb_free_datagram(struct sock *sk, 
  *	This function currently only disables BH when acquiring the
  *	sk_receive_queue lock.  Therefore it must not be used in a
  *	context where that lock is acquired in an IRQ context.
+ *
+ *	It returns 0 if the packet was removed by us.
  */
 
-void skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
+int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 {
+	int err = 0;
+
 	if (flags & MSG_PEEK) {
+		err = -ENOENT;
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		if (skb == skb_peek(&sk->sk_receive_queue)) {
 			__skb_unlink(skb, &sk->sk_receive_queue);
 			atomic_dec(&skb->users);
+			err = 0;
 		}
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 	}
 
 	kfree_skb(skb);
+	return err;
 }
 
 EXPORT_SYMBOL(skb_kill_datagram);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -899,9 +899,8 @@ out:
 	return err;
 
 csum_copy_err:
-	UDP_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
-
-	skb_kill_datagram(sk, skb, flags);
+	if (!skb_kill_datagram(sk, skb, flags))
+		UDP_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
 
 	if (noblock)
 		return -EAGAIN;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -207,8 +207,8 @@ out:
 	return err;
 
 csum_copy_err:
-	UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
-	skb_kill_datagram(sk, skb, flags);
+	if (!skb_kill_datagram(sk, skb, flags))
+		UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
 
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
