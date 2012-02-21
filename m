From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/6] datagram: Add offset argument to __skb_recv_datagram
Date: Tue, 21 Feb 2012 21:30:58 +0400
Message-ID: <4F43D4D2.5080903@parallels.com>
References: <4F43D49E.3010401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19706 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693Ab2BURbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 12:31:07 -0500
In-Reply-To: <4F43D49E.3010401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is only considered for MSG_PEEK flag and the value pointed by
it specifies where to start peeking bytes from. If the offset happens to
point into the middle of the returned skb, the offset within this skb is
put back to this very argument.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/skbuff.h |    2 +-
 net/core/datagram.c    |   21 +++++++++++++--------
 net/ipv4/udp.c         |    4 ++--
 net/ipv6/udp.c         |    4 ++--
 4 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2b7317f..f3cf43d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2046,7 +2046,7 @@ static inline void skb_frag_add_head(struct sk_buff *skb, struct sk_buff *frag)
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
 extern struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
-					   int *peeked, int *err);
+					   int *peeked, int *off, int *err);
 extern struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
 					 int noblock, int *err);
 extern unsigned int    datagram_poll(struct file *file, struct socket *sock,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 6f54d0a..d3cf12f 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -132,6 +132,8 @@ out_noerr:
  *	__skb_recv_datagram - Receive a datagram skbuff
  *	@sk: socket
  *	@flags: MSG_ flags
+ *	@off: an offset in bytes to peek skb from. Returns an offset
+ *	      within an skb where data actually starts
  *	@peeked: returns non-zero if this packet has been seen before
  *	@err: error code returned
  *
@@ -158,7 +160,7 @@ out_noerr:
  *	the standard around please.
  */
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
-				    int *peeked, int *err)
+				    int *peeked, int *off, int *err)
 {
 	struct sk_buff *skb;
 	long timeo;
@@ -183,19 +185,22 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 		struct sk_buff_head *queue = &sk->sk_receive_queue;
 
 		spin_lock_irqsave(&queue->lock, cpu_flags);
-		skb = skb_peek(queue);
-		if (skb) {
+		skb_queue_walk(queue, skb) {
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
+				if (*off >= skb->len) {
+					*off -= skb->len;
+					continue;
+				}
 				skb->peeked = 1;
 				atomic_inc(&skb->users);
 			} else
 				__skb_unlink(skb, queue);
-		}
-		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
-		if (skb)
+			spin_unlock_irqrestore(&queue->lock, cpu_flags);
 			return skb;
+		}
+		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
 		/* User doesn't want to wait */
 		error = -EAGAIN;
@@ -215,10 +220,10 @@ EXPORT_SYMBOL(__skb_recv_datagram);
 struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
 				  int noblock, int *err)
 {
-	int peeked;
+	int peeked, off = 0;
 
 	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				   &peeked, err);
+				   &peeked, &off, err);
 }
 EXPORT_SYMBOL(skb_recv_datagram);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd99f1a..7c41ab8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1167,7 +1167,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
-	int peeked;
+	int peeked, off = 0;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool slow;
@@ -1183,7 +1183,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 try_again:
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &err);
+				  &peeked, &off, &err);
 	if (!skb)
 		goto out;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8aebf8f..37b0699 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -342,7 +342,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
-	int peeked;
+	int peeked, off = 0;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	int is_udp4;
@@ -359,7 +359,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 try_again:
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &err);
+				  &peeked, &off, &err);
 	if (!skb)
 		goto out;
 
-- 
1.5.5.6
