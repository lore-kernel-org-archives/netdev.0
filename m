From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 3/3] udp: enable MSG_PEEK at non-zero offset
Date: Tue,  5 Apr 2016 12:41:16 -0400
Message-ID: <1459874476-92838-4-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1459874476-92838-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, samanthakumar@google.com, edumazet@google.com,
	willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:35487 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758397AbcDEQlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:41:25 -0400
Received: by mail-qg0-f68.google.com with SMTP id b32so1717327qgf.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 09:41:24 -0700 (PDT)
In-Reply-To: <1459874476-92838-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: samanthakumar <samanthakumar@google.com>

Enable peeking at UDP datagrams at the offset specified with socket
option SOL_SOCKET/SO_PEEK_OFF. Peek at any datagram in the queue, up
to the end of the given datagram.

Implement the SO_PEEK_OFF semantics introduced in commit ef64a54f6e55
("sock: Introduce the SO_PEEK_OFF sock option"). Increase the offset
on peek, decrease it on regular reads.

When peeking, always checksum the packet immediately, to avoid
recomputation on subsequent peeks and final read.

The socket lock is not held for the duration of udp_recvmsg, so
peek and read operations can run concurrently. Only the last store
to sk_peek_off is preserved.

Signed-off-by: Sam Kumar <samanthakumar@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h |  7 ++++++-
 include/net/sock.h     |  2 ++
 net/core/datagram.c    |  9 ++++++---
 net/core/sock.c        |  9 +++++++++
 net/ipv4/af_inet.c     |  1 +
 net/ipv4/udp.c         | 22 +++++++++++-----------
 net/ipv6/af_inet6.c    |  1 +
 net/ipv6/udp.c         | 22 +++++++++++-----------
 8 files changed, 47 insertions(+), 26 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 15d0df9..0073812 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2949,7 +2949,12 @@ int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 				 struct iov_iter *from, int len);
 int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *frm);
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
-void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb);
+void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len);
+static inline void skb_free_datagram_locked(struct sock *sk,
+					    struct sk_buff *skb)
+{
+	__skb_free_datagram_locked(sk, skb, 0);
+}
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags);
 int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len);
diff --git a/include/net/sock.h b/include/net/sock.h
index b759989..1decb7a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -457,6 +457,8 @@ struct sock {
 #define SK_CAN_REUSE	1
 #define SK_FORCE_REUSE	2
 
+int sk_set_peek_off(struct sock *sk, int val);
+
 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
 	if (unlikely(flags & MSG_PEEK)) {
diff --git a/net/core/datagram.c b/net/core/datagram.c
index fa9dc64..b7de71f 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -301,16 +301,19 @@ void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_free_datagram);
 
-void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
+void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 {
 	bool slow;
 
 	if (likely(atomic_read(&skb->users) == 1))
 		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users)))
+	else if (likely(!atomic_dec_and_test(&skb->users))) {
+		sk_peek_offset_bwd(sk, len);
 		return;
+	}
 
 	slow = lock_sock_fast(sk);
+	sk_peek_offset_bwd(sk, len);
 	skb_orphan(skb);
 	sk_mem_reclaim_partial(sk);
 	unlock_sock_fast(sk, slow);
@@ -318,7 +321,7 @@ void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 	/* skb is now orphaned, can be freed outside of locked section */
 	__kfree_skb(skb);
 }
-EXPORT_SYMBOL(skb_free_datagram_locked);
+EXPORT_SYMBOL(__skb_free_datagram_locked);
 
 /**
  *	skb_kill_datagram - Free a datagram skbuff forcibly
diff --git a/net/core/sock.c b/net/core/sock.c
index e12197b..2ce76e8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2187,6 +2187,15 @@ void __sk_mem_reclaim(struct sock *sk, int amount)
 }
 EXPORT_SYMBOL(__sk_mem_reclaim);
 
+int sk_set_peek_off(struct sock *sk, int val)
+{
+	if (val < 0)
+		return -EINVAL;
+
+	sk->sk_peek_off = val;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(sk_set_peek_off);
 
 /*
  * Set of default routines for initialising struct proto_ops when
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9e48199..a38b991 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -948,6 +948,7 @@ const struct proto_ops inet_dgram_ops = {
 	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
+	.set_peek_off	   = sk_set_peek_off,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cf747e8..d80312d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1294,7 +1294,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
-	int peeked, off = 0;
+	int peeked, peeking, off;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
@@ -1304,15 +1304,16 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		return ip_recv_error(sk, msg, len, addr_len);
 
 try_again:
+	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				  &peeked, &off, &err);
 	if (!skb)
-		goto out;
+		return err;
 
 	ulen = skb->len;
 	copied = len;
-	if (copied > ulen)
-		copied = ulen;
+	if (copied > ulen - off)
+		copied = ulen - off;
 	else if (copied < ulen)
 		msg->msg_flags |= MSG_TRUNC;
 
@@ -1322,16 +1323,16 @@ try_again:
 	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
 
-	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
+	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov || peeking) {
 		checksum_valid = !udp_lib_checksum_complete(skb);
 		if (!checksum_valid)
 			goto csum_copy_err;
 	}
 
 	if (checksum_valid || skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_msg(skb, 0, msg, copied);
+		err = skb_copy_datagram_msg(skb, off, msg, copied);
 	else {
-		err = skb_copy_and_csum_datagram_msg(skb, 0, msg);
+		err = skb_copy_and_csum_datagram_msg(skb, off, msg);
 
 		if (err == -EINVAL)
 			goto csum_copy_err;
@@ -1344,7 +1345,8 @@ try_again:
 			UDP_INC_STATS_USER(sock_net(sk),
 					   UDP_MIB_INERRORS, is_udplite);
 		}
-		goto out_free;
+		skb_free_datagram_locked(sk, skb);
+		return err;
 	}
 
 	if (!peeked)
@@ -1368,9 +1370,7 @@ try_again:
 	if (flags & MSG_TRUNC)
 		err = ulen;
 
-out_free:
-	skb_free_datagram_locked(sk, skb);
-out:
+	__skb_free_datagram_locked(sk, skb, peeking ? -err : err);
 	return err;
 
 csum_copy_err:
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b11c37c..2b78aad 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -561,6 +561,7 @@ const struct proto_ops inet6_dgram_ops = {
 	.recvmsg	   = inet_recvmsg,		/* ok		*/
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
+	.set_peek_off	   = sk_set_peek_off,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 84c8d7b..87bd7af 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -357,7 +357,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
-	int peeked, off = 0;
+	int peeked, peeking, off;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
@@ -371,15 +371,16 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
 
 try_again:
+	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				  &peeked, &off, &err);
 	if (!skb)
-		goto out;
+		return err;
 
 	ulen = skb->len;
 	copied = len;
-	if (copied > ulen)
-		copied = ulen;
+	if (copied > ulen - off)
+		copied = ulen - off;
 	else if (copied < ulen)
 		msg->msg_flags |= MSG_TRUNC;
 
@@ -391,16 +392,16 @@ try_again:
 	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
 
-	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
+	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov || peeking) {
 		checksum_valid = !udp_lib_checksum_complete(skb);
 		if (!checksum_valid)
 			goto csum_copy_err;
 	}
 
 	if (checksum_valid || skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_msg(skb, 0, msg, copied);
+		err = skb_copy_datagram_msg(skb, off, msg, copied);
 	else {
-		err = skb_copy_and_csum_datagram_msg(skb, 0, msg);
+		err = skb_copy_and_csum_datagram_msg(skb, off, msg);
 		if (err == -EINVAL)
 			goto csum_copy_err;
 	}
@@ -417,7 +418,8 @@ try_again:
 						    UDP_MIB_INERRORS,
 						    is_udplite);
 		}
-		goto out_free;
+		skb_free_datagram_locked(sk, skb);
+		return err;
 	}
 	if (!peeked) {
 		if (is_udp4)
@@ -465,9 +467,7 @@ try_again:
 	if (flags & MSG_TRUNC)
 		err = ulen;
 
-out_free:
-	skb_free_datagram_locked(sk, skb);
-out:
+	__skb_free_datagram_locked(sk, skb, peeking ? -err : err);
 	return err;
 
 csum_copy_err:
-- 
2.8.0.rc3.226.g39d4020
