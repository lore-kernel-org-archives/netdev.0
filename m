From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 4/4] udp: move peek offset on read and peek
Date: Sun,  3 Apr 2016 19:29:53 -0400
Message-ID: <1459726193-20863-5-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, samanthakumar@google.com, edumazet@google.com,
	willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34176 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbcDCXaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 19:30:12 -0400
Received: by mail-qk0-f193.google.com with SMTP id z64so1939851qkb.1
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 16:30:11 -0700 (PDT)
In-Reply-To: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

For UDP sockets, implement the SO_PEEK_OFF semantics introduced in
commit ef64a54f6e55 ("sock: Introduce the SO_PEEK_OFF sock option").

Move the offset forward on peek by the size of the data peeked,
move it backwards on regular reads.

The socket lock is not held for the duration of udp_recvmsg, so
peek and read operations can run concurrently. Only the last store
to sk_peek_off is preserved.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 7 ++++++-
 net/core/datagram.c    | 9 ++++++---
 net/ipv4/udp.c         | 9 ++++-----
 net/ipv6/udp.c         | 9 ++++-----
 4 files changed, 20 insertions(+), 14 deletions(-)

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
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 016d13c..075c874 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1356,7 +1356,7 @@ try_again:
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				  &peeked, &off, &err);
 	if (!skb)
-		goto out;
+		return err;
 
 	ulen = skb->len;
 	copied = len;
@@ -1393,7 +1393,8 @@ try_again:
 			UDP_INC_STATS_USER(sock_net(sk),
 					   UDP_MIB_INERRORS, is_udplite);
 		}
-		goto out_free;
+		skb_free_datagram_locked(sk, skb);
+		return err;
 	}
 
 	if (!peeked)
@@ -1417,9 +1418,7 @@ try_again:
 	if (flags & MSG_TRUNC)
 		err = ulen;
 
-out_free:
-	skb_free_datagram_locked(sk, skb);
-out:
+	__skb_free_datagram_locked(sk, skb, peeking ? -err : err);
 	return err;
 
 csum_copy_err:
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d107810..323282a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -419,7 +419,7 @@ try_again:
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				  &peeked, &off, &err);
 	if (!skb)
-		goto out;
+		return err;
 
 	ulen = skb->len;
 	copied = len;
@@ -462,7 +462,8 @@ try_again:
 						    UDP_MIB_INERRORS,
 						    is_udplite);
 		}
-		goto out_free;
+		skb_free_datagram_locked(sk, skb);
+		return err;
 	}
 	if (!peeked) {
 		if (is_udp4)
@@ -510,9 +511,7 @@ try_again:
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
