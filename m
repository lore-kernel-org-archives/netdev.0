From: Josh Hunt <johunt@akamai.com>
Subject: [RFC PATCH] sock: add SO_RCVQUEUE_SIZE getsockopt
Date: Mon, 13 Mar 2017 11:59:46 -0400
Message-ID: <1489420786-19547-1-git-send-email-johunt@akamai.com>
Cc: edumazet@google.com, soheil@google.com, willemb@google.com,
        pabeni@redhat.com, linux-arch@vger.kernel.org,
        netdev@vger.kernel.org, Josh Hunt <johunt@akamai.com>
To: davem@davemloft.net, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay06.akamai.com ([96.6.114.98]:58706 "EHLO
        prod-mail-xrelay06.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752359AbdCMP7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:59:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows application to read the amount of data sitting in the receive
queue.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---

A team here is looking for a way to get the amount of data in a UDP socket's
receive queue. It seems like this should be SIOCINQ, but for UDP sockets that
returns the size of the next pending datagram. I implemented the patch below,
but am wondering if this is the right place for this change? I was debating
between this or a new UDP ioctl.

 include/net/sock.h                | 7 ++++++-
 include/uapi/asm-generic/socket.h | 2 ++
 net/core/sock.c                   | 4 ++++
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5e59976..bcfed2ae 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -854,6 +854,11 @@ static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 	skb->next = NULL;
 }
 
+static unsigned int sk_rcvqueue_size(const struct sock *sk)
+{
+	return sk->sk_backlog.len + atomic_read(&sk->sk_rmem_alloc);
+}
+
 /*
  * Take into account size of receive queue and backlog queue
  * Do not take into account this skb truesize,
@@ -861,7 +866,7 @@ static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
  */
 static inline bool sk_rcvqueues_full(const struct sock *sk, unsigned int limit)
 {
-	unsigned int qsize = sk->sk_backlog.len + atomic_read(&sk->sk_rmem_alloc);
+	unsigned int qsize = sk_rcvqueue_size(sk);
 
 	return qsize > limit;
 }
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2c748dd..36b8cd5 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -94,4 +94,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RCVQUEUE_SIZE	55
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index f6fd79f..fa69864 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1269,6 +1269,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_incoming_cpu;
 		break;
 
+	case SO_RCVQUEUE_SIZE:
+		v.val = sk_rcvqueue_size(sk);
+		break;
+
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
-- 
1.9.1
