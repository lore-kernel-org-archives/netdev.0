From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/2] net: fix sock_wake_async() rcu protection
Date: Sun, 29 Nov 2015 20:03:11 -0800
Message-ID: <1448856191-31435-2-git-send-email-edumazet@google.com>
References: <1448856191-31435-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33317 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbbK3EDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 23:03:24 -0500
Received: by pabfh17 with SMTP id fh17so175781133pab.0
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 20:03:23 -0800 (PST)
In-Reply-To: <1448856191-31435-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry provided a syzkaller (http://github.com/google/syzkaller)
triggering a fault in sock_wake_async() when async IO is requested.

Said program stressed af_unix sockets, but the issue is generic
and should be addressed in core networking stack.

The problem is that by the time sock_wake_async() is called,
we should not access the @flags field of 'struct socket',
as the inode containing this socket might be freed without
further notice, and without RCU grace period.

We already maintain an RCU protected structure, "struct socket_wq"
so moving SOCKWQ_ASYNC_NOSPACE & SOCKWQ_ASYNC_WAITDATA into it
is the safe route.

It also reduces number of cache lines needing dirtying, so might
provide a performance improvement anyway.

In followup patches, we might move remaining flags (SOCK_NOSPACE,
SOCK_PASSCRED, SOCK_PASSSEC) to save 8 bytes and let 'struct socket'
being mostly read and let it being shared between cpus.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/net.h |  7 ++++++-
 include/net/sock.h  | 23 ++++++++++++++++-------
 net/core/stream.c   |  2 +-
 net/sctp/socket.c   | 24 ++++++++++++++----------
 net/socket.c        | 21 +++++++--------------
 5 files changed, 44 insertions(+), 33 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index f514e4dd5521..0b4ac7da583a 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -34,6 +34,10 @@ struct inode;
 struct file;
 struct net;
 
+/* Historically, SOCKWQ_ASYNC_NOSPACE & SOCKWQ_ASYNC_WAITDATA were located
+ * in sock->flags, but moved into sk->sk_wq->flags to be RCU protected.
+ * Eventually all flags will be in sk->sk_wq_flags.
+ */
 #define SOCKWQ_ASYNC_NOSPACE	0
 #define SOCKWQ_ASYNC_WAITDATA	1
 #define SOCK_NOSPACE		2
@@ -89,6 +93,7 @@ struct socket_wq {
 	/* Note: wait MUST be first field of socket_wq */
 	wait_queue_head_t	wait;
 	struct fasync_struct	*fasync_list;
+	unsigned long		flags; /* %SOCKWQ_ASYNC_NOSPACE, etc */
 	struct rcu_head		rcu;
 } ____cacheline_aligned_in_smp;
 
@@ -202,7 +207,7 @@ enum {
 	SOCK_WAKE_URG,
 };
 
-int sock_wake_async(struct socket *sk, int how, int band);
+int sock_wake_async(struct socket_wq *sk_wq, int how, int band);
 int sock_register(const struct net_proto_family *fam);
 void sock_unregister(int family);
 int __sock_create(struct net *net, int family, int type, int proto,
diff --git a/include/net/sock.h b/include/net/sock.h
index c155d09d8af4..0434138c5f95 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -384,8 +384,10 @@ struct sock {
 	int			sk_rcvbuf;
 
 	struct sk_filter __rcu	*sk_filter;
-	struct socket_wq __rcu	*sk_wq;
-
+	union {
+		struct socket_wq __rcu	*sk_wq;
+		struct socket_wq	*sk_wq_raw;
+	};
 #ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
 #endif
@@ -2005,20 +2007,27 @@ static inline unsigned long sock_wspace(struct sock *sk)
 	return amt;
 }
 
+/* Note:
+ *  We use sk->sk_wq_raw, from contexts knowing this
+ *  pointer is not NULL and cannot disappear/change.
+ */
 static inline void sk_set_bit(int nr, struct sock *sk)
 {
-	set_bit(nr, &sk->sk_socket->flags);
+	set_bit(nr, &sk->sk_wq_raw->flags);
 }
 
 static inline void sk_clear_bit(int nr, struct sock *sk)
 {
-	clear_bit(nr, &sk->sk_socket->flags);
+	clear_bit(nr, &sk->sk_wq_raw->flags);
 }
 
-static inline void sk_wake_async(struct sock *sk, int how, int band)
+static inline void sk_wake_async(const struct sock *sk, int how, int band)
 {
-	if (sock_flag(sk, SOCK_FASYNC))
-		sock_wake_async(sk->sk_socket, how, band);
+	if (sock_flag(sk, SOCK_FASYNC)) {
+		rcu_read_lock();
+		sock_wake_async(rcu_dereference(sk->sk_wq), how, band);
+		rcu_read_unlock();
+	}
 }
 
 /* Since sk_{r,w}mem_alloc sums skb->truesize, even a small frame might
diff --git a/net/core/stream.c b/net/core/stream.c
index 43309428644d..b96f7a79e544 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -39,7 +39,7 @@ void sk_stream_write_space(struct sock *sk)
 			wake_up_interruptible_poll(&wq->wait, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
 		if (wq && wq->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
-			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
+			sock_wake_async(wq, SOCK_WAKE_SPACE, POLL_OUT);
 		rcu_read_unlock();
 	}
 }
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2353985d689c..5e35ef34008b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6801,26 +6801,30 @@ no_packet:
 static void __sctp_write_space(struct sctp_association *asoc)
 {
 	struct sock *sk = asoc->base.sk;
-	struct socket *sock = sk->sk_socket;
 
-	if ((sctp_wspace(asoc) > 0) && sock) {
-		if (waitqueue_active(&asoc->wait))
-			wake_up_interruptible(&asoc->wait);
+	if (sctp_wspace(asoc) <= 0)
+		return;
+
+	if (waitqueue_active(&asoc->wait))
+		wake_up_interruptible(&asoc->wait);
 
-		if (sctp_writeable(sk)) {
-			wait_queue_head_t *wq = sk_sleep(sk);
+	if (sctp_writeable(sk)) {
+		struct socket_wq *wq;
 
-			if (wq && waitqueue_active(wq))
-				wake_up_interruptible(wq);
+		rcu_read_lock();
+		wq = rcu_dereference(sk->sk_wq);
+		if (wq) {
+			if (waitqueue_active(&wq->wait))
+				wake_up_interruptible(&wq->wait);
 
 			/* Note that we try to include the Async I/O support
 			 * here by modeling from the current TCP/UDP code.
 			 * We have not tested with it yet.
 			 */
 			if (!(sk->sk_shutdown & SEND_SHUTDOWN))
-				sock_wake_async(sock,
-						SOCK_WAKE_SPACE, POLL_OUT);
+				sock_wake_async(wq, SOCK_WAKE_SPACE, POLL_OUT);
 		}
+		rcu_read_unlock();
 	}
 }
 
diff --git a/net/socket.c b/net/socket.c
index 16be908205fc..456fadb3d819 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1056,27 +1056,20 @@ static int sock_fasync(int fd, struct file *filp, int on)
 	return 0;
 }
 
-/* This function may be called only under socket lock or callback_lock or rcu_lock */
+/* This function may be called only under rcu_lock */
 
-int sock_wake_async(struct socket *sock, int how, int band)
+int sock_wake_async(struct socket_wq *wq, int how, int band)
 {
-	struct socket_wq *wq;
-
-	if (!sock)
-		return -1;
-	rcu_read_lock();
-	wq = rcu_dereference(sock->wq);
-	if (!wq || !wq->fasync_list) {
-		rcu_read_unlock();
+	if (!wq || !wq->fasync_list)
 		return -1;
-	}
+
 	switch (how) {
 	case SOCK_WAKE_WAITD:
-		if (test_bit(SOCKWQ_ASYNC_WAITDATA, &sock->flags))
+		if (test_bit(SOCKWQ_ASYNC_WAITDATA, &wq->flags))
 			break;
 		goto call_kill;
 	case SOCK_WAKE_SPACE:
-		if (!test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->flags))
+		if (!test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &wq->flags))
 			break;
 		/* fall through */
 	case SOCK_WAKE_IO:
@@ -1086,7 +1079,7 @@ call_kill:
 	case SOCK_WAKE_URG:
 		kill_fasync(&wq->fasync_list, SIGURG, band);
 	}
-	rcu_read_unlock();
+
 	return 0;
 }
 EXPORT_SYMBOL(sock_wake_async);
-- 
2.6.0.rc2.230.g3dd15c0
