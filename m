From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 3/4] udp: enable MSG_PEEK at non-zero offset
Date: Sun,  3 Apr 2016 19:29:52 -0400
Message-ID: <1459726193-20863-4-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, samanthakumar@google.com, edumazet@google.com,
	willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36712 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbcDCXaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 19:30:10 -0400
Received: by mail-qk0-f194.google.com with SMTP id e124so6998850qkc.3
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 16:30:10 -0700 (PDT)
In-Reply-To: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: samanthakumar <samanthakumar@google.com>

Enable peeking at UDP datagrams at the offset specified with socket
option SOL_SOCKET/SO_PEEK_OFF. Peek at any datagram in the queue, up
to the end of the given datagram.

When peeking, always checksum the packet immediately, to avoid
recomputation on subsequent peeks and final read.

This implementation does not move the peek offset. A follow-up patch
adds that.

Signed-off-by: Sam Kumar <samanthakumar@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h  |  2 ++
 net/core/sock.c     |  9 +++++++++
 net/ipv4/af_inet.c  |  1 +
 net/ipv4/udp.c      | 13 +++++++------
 net/ipv6/af_inet6.c |  1 +
 net/ipv6/udp.c      | 13 +++++++------
 6 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b30c2b3..5978bcf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -456,6 +456,8 @@ struct sock {
 #define SK_CAN_REUSE	1
 #define SK_FORCE_REUSE	2
 
+int sk_set_peek_off(struct sock *sk, int val);
+
 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
 	if (unlikely(flags & MSG_PEEK)) {
diff --git a/net/core/sock.c b/net/core/sock.c
index a33f494..3739381 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2149,6 +2149,15 @@ void __sk_mem_reclaim(struct sock *sk, int amount)
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
index 6ebc7de..016d13c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1342,7 +1342,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
-	int peeked, off = 0;
+	int peeked, peeking, off;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
@@ -1352,6 +1352,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		return ip_recv_error(sk, msg, len, addr_len);
 
 try_again:
+	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				  &peeked, &off, &err);
 	if (!skb)
@@ -1359,8 +1360,8 @@ try_again:
 
 	ulen = skb->len;
 	copied = len;
-	if (copied > ulen)
-		copied = ulen;
+	if (copied > ulen - off)
+		copied = ulen - off;
 	else if (copied < ulen)
 		msg->msg_flags |= MSG_TRUNC;
 
@@ -1370,16 +1371,16 @@ try_again:
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
index ebcf05f..d107810 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -401,7 +401,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
-	int peeked, off = 0;
+	int peeked, peeking, off;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool checksum_valid = false;
@@ -415,6 +415,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
 
 try_again:
+	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				  &peeked, &off, &err);
 	if (!skb)
@@ -422,8 +423,8 @@ try_again:
 
 	ulen = skb->len;
 	copied = len;
-	if (copied > ulen)
-		copied = ulen;
+	if (copied > ulen - off)
+		copied = ulen - off;
 	else if (copied < ulen)
 		msg->msg_flags |= MSG_TRUNC;
 
@@ -435,16 +436,16 @@ try_again:
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
-- 
2.8.0.rc3.226.g39d4020
