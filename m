From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net,v2] net: sock: adapt SOCK_MIN_RCVBUF and SOCK_MIN_SNDBUF
Date: Wed, 19 Jun 2013 12:51:20 +0200
Message-ID: <1371639080-10699-1-git-send-email-dborkman@redhat.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934421Ab3FSKvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 06:51:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current situation is that SOCK_MIN_RCVBUF is 2048 + sizeof(struct sk_buff))
while SOCK_MIN_SNDBUF is 2048. Since in both cases, skb->truesize is used for
sk_{r,w}mem_alloc accounting, we should have both sizes adjusted via defining a
TCP_SKB_MIN_TRUESIZE.

Further, as Eric Dumazet points out, the minimal skb truesize in transmit path is
SKB_TRUESIZE(2048) after commit f07d960df33c5 ("tcp: avoid frag allocation for
small frames"), and tcp_sendmsg() tries to limit skb size to half the congestion
window, meaning we try to build two skbs at minimum. Thus, having SOCK_MIN_SNDBUF
as 2048 can hit a small regression for some applications setting to low
SO_SNDBUF / SO_RCVBUF. Note that we define a TCP_SKB_MIN_TRUESIZE, because
SKB_TRUESIZE(2048) adds SKB_DATA_ALIGN(sizeof(struct skb_shared_info)), but in
case of TCP skbs, the skb_shared_info is part of the 2048 bytes allocation for
skb->head.

The minor adaption in sk_stream_moderate_sndbuf() is to silence a warning by
using a typed max macro, as similarly done in SOCK_MIN_RCVBUF occurences, that
would appear otherwise.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1 -> v2:
  - Applied Eric's feedback, fixed up commit message
  - Set subject to 'net' instead of 'net-next' due to the reported regression

 include/net/sock.h | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ac8e181..753e59f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2045,18 +2045,21 @@ static inline void sk_wake_async(struct sock *sk, int how, int band)
 		sock_wake_async(sk->sk_socket, how, band);
 }
 
-#define SOCK_MIN_SNDBUF 2048
-/*
- * Since sk_rmem_alloc sums skb->truesize, even a small frame might need
- * sizeof(sk_buff) + MTU + padding, unless net driver perform copybreak
+/* Since sk_{r,w}mem_alloc sums skb->truesize, even a small frame might
+ * need sizeof(sk_buff) + MTU + padding, unless net driver perform copybreak.
+ * Note: for send buffers, TCP works better if we can build two skbs at
+ * minimum.
  */
-#define SOCK_MIN_RCVBUF (2048 + sizeof(struct sk_buff))
+#define TCP_SKB_MIN_TRUESIZE	(2048 + sizeof(struct sk_buff))
+
+#define SOCK_MIN_SNDBUF		(TCP_SKB_MIN_TRUESIZE * 2)
+#define SOCK_MIN_RCVBUF		 TCP_SKB_MIN_TRUESIZE
 
 static inline void sk_stream_moderate_sndbuf(struct sock *sk)
 {
 	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
 		sk->sk_sndbuf = min(sk->sk_sndbuf, sk->sk_wmem_queued >> 1);
-		sk->sk_sndbuf = max(sk->sk_sndbuf, SOCK_MIN_SNDBUF);
+		sk->sk_sndbuf = max_t(u32, sk->sk_sndbuf, SOCK_MIN_SNDBUF);
 	}
 }
 
-- 
1.7.11.7
