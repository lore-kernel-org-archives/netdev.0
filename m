From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 1/8] tcp: tsq: add tsq_flags / tsq_enum
Date: Sat,  3 Dec 2016 11:14:50 -0800
Message-ID: <1480792497-16607-2-git-send-email-edumazet@google.com>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:32964 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbcLCTQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 14:16:28 -0500
Received: by mail-pg0-f46.google.com with SMTP id 3so120161033pgd.0
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 11:15:04 -0800 (PST)
In-Reply-To: <1480792497-16607-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cleanup, to ease code review of following patches.

Old 'enum tsq_flags' is renamed, and a new enumeration is added
with the flags used in cmpxchg() operations as opposed to
single bit operations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h   | 11 ++++++++++-
 net/ipv4/tcp_output.c | 16 ++++++++--------
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 734bab4c3bef..d8be083ab0b0 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -364,7 +364,7 @@ struct tcp_sock {
 	u32	*saved_syn;
 };
 
-enum tsq_flags {
+enum tsq_enum {
 	TSQ_THROTTLED,
 	TSQ_QUEUED,
 	TCP_TSQ_DEFERRED,	   /* tcp_tasklet_func() found socket was owned */
@@ -375,6 +375,15 @@ enum tsq_flags {
 				    */
 };
 
+enum tsq_flags {
+	TSQF_THROTTLED			= (1UL << TSQ_THROTTLED),
+	TSQF_QUEUED			= (1UL << TSQ_QUEUED),
+	TCPF_TSQ_DEFERRED		= (1UL << TCP_TSQ_DEFERRED),
+	TCPF_WRITE_TIMER_DEFERRED	= (1UL << TCP_WRITE_TIMER_DEFERRED),
+	TCPF_DELACK_TIMER_DEFERRED	= (1UL << TCP_DELACK_TIMER_DEFERRED),
+	TCPF_MTU_REDUCED_DEFERRED	= (1UL << TCP_MTU_REDUCED_DEFERRED),
+};
+
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
 {
 	return (struct tcp_sock *)sk;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c7adcb57654e..8f0289b0fb24 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -784,10 +784,10 @@ static void tcp_tasklet_func(unsigned long data)
 	}
 }
 
-#define TCP_DEFERRED_ALL ((1UL << TCP_TSQ_DEFERRED) |		\
-			  (1UL << TCP_WRITE_TIMER_DEFERRED) |	\
-			  (1UL << TCP_DELACK_TIMER_DEFERRED) |	\
-			  (1UL << TCP_MTU_REDUCED_DEFERRED))
+#define TCP_DEFERRED_ALL (TCPF_TSQ_DEFERRED |		\
+			  TCPF_WRITE_TIMER_DEFERRED |	\
+			  TCPF_DELACK_TIMER_DEFERRED |	\
+			  TCPF_MTU_REDUCED_DEFERRED)
 /**
  * tcp_release_cb - tcp release_sock() callback
  * @sk: socket
@@ -808,7 +808,7 @@ void tcp_release_cb(struct sock *sk)
 		nflags = flags & ~TCP_DEFERRED_ALL;
 	} while (cmpxchg(&tp->tsq_flags, flags, nflags) != flags);
 
-	if (flags & (1UL << TCP_TSQ_DEFERRED))
+	if (flags & TCPF_TSQ_DEFERRED)
 		tcp_tsq_handler(sk);
 
 	/* Here begins the tricky part :
@@ -822,15 +822,15 @@ void tcp_release_cb(struct sock *sk)
 	 */
 	sock_release_ownership(sk);
 
-	if (flags & (1UL << TCP_WRITE_TIMER_DEFERRED)) {
+	if (flags & TCPF_WRITE_TIMER_DEFERRED) {
 		tcp_write_timer_handler(sk);
 		__sock_put(sk);
 	}
-	if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED)) {
+	if (flags & TCPF_DELACK_TIMER_DEFERRED) {
 		tcp_delack_timer_handler(sk);
 		__sock_put(sk);
 	}
-	if (flags & (1UL << TCP_MTU_REDUCED_DEFERRED)) {
+	if (flags & TCPF_MTU_REDUCED_DEFERRED) {
 		inet_csk(sk)->icsk_af_ops->mtu_reduced(sk);
 		__sock_put(sk);
 	}
-- 
2.8.0.rc3.226.g39d4020
