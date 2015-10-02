From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 3/3] af_unix: optimize the unix_dgram_recvmsg()
Date: Fri,  2 Oct 2015 20:44:02 +0000 (GMT)
Message-ID: <ba2b4c5c1d6fd3d99cd4b1286edace56c0f84a0d.1443817522.git.jbaron@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1443817522.git.jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that connect() permanently registers a callback routine, we can induce
extra overhead in unix_dgram_recvmsg(), which unconditionally wakes up
its peer_wait queue on every receive. This patch makes the wakeup there
conditional on there being waiters interested in wait events.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 include/net/af_unix.h |  1 +
 net/unix/af_unix.c    | 72 ++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 49 insertions(+), 24 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 6a4a345..cf21ffd 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -61,6 +61,7 @@ struct unix_sock {
 	unsigned long		flags;
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
+#define UNIX_NOSPACE		2
 	struct socket_wq	peer_wq;
 	wait_queue_t		wait;
 };
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f789423..b8ed1bc 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -326,7 +326,7 @@ found:
 	return s;
 }
 
-static inline int unix_writable(struct sock *sk)
+static inline bool unix_writable(struct sock *sk)
 {
 	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
 }
@@ -1079,6 +1079,9 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
 
 	prepare_to_wait_exclusive(&u->peer_wait, &wait, TASK_INTERRUPTIBLE);
 
+	set_bit(UNIX_NOSPACE, &u->flags);
+	/* pairs with mb in unix_dgram_recv */
+	smp_mb__after_atomic();
 	sched = !sock_flag(other, SOCK_DEAD) &&
 		!(other->sk_shutdown & RCV_SHUTDOWN) &&
 		unix_recvq_full(other);
@@ -1623,17 +1626,22 @@ restart:
 
 	if (unix_peer(other) != sk && unix_recvq_full(other)) {
 		if (!timeo) {
-			err = -EAGAIN;
-			goto out_unlock;
-		}
-
-		timeo = unix_wait_for_peer(other, timeo);
+			set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
+			/* pairs with mb in unix_dgram_recv */
+			smp_mb__after_atomic();
+			if (unix_recvq_full(other)) {
+				err = -EAGAIN;
+				goto out_unlock;
+			}
+		} else {
+			timeo = unix_wait_for_peer(other, timeo);
 
-		err = sock_intr_errno(timeo);
-		if (signal_pending(current))
-			goto out_free;
+			err = sock_intr_errno(timeo);
+			if (signal_pending(current))
+				goto out_free;
 
-		goto restart;
+			goto restart;
+		}
 	}
 
 	if (sock_flag(other, SOCK_RCVTSTAMP))
@@ -1939,8 +1947,14 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 		goto out_unlock;
 	}
 
-	wake_up_interruptible_sync_poll(&u->peer_wait,
-					POLLOUT | POLLWRNORM | POLLWRBAND);
+	/* pairs with unix_dgram_poll() and wait_for_peer() */
+	smp_mb();
+	if (test_bit(UNIX_NOSPACE, &u->flags)) {
+		clear_bit(UNIX_NOSPACE, &u->flags);
+		wake_up_interruptible_sync_poll(&u->peer_wait,
+						POLLOUT | POLLWRNORM |
+						POLLWRBAND);
+	}
 
 	if (msg->msg_name)
 		unix_copy_addr(msg, skb->sk);
@@ -2432,11 +2446,22 @@ static unsigned int unix_poll(struct file *file, struct socket *sock, poll_table
 	return mask;
 }
 
+static bool unix_dgram_writable(struct sock *sk, struct sock *other)
+{
+	bool writable;
+
+	writable = unix_writable(sk);
+	if (other && unix_peer(other) != sk && unix_recvq_full(other))
+		writable = false;
+
+	return writable;
+}
+
 static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 				    poll_table *wait)
 {
 	struct sock *sk = sock->sk, *other;
-	unsigned int mask, writable;
+	unsigned int mask;
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
@@ -2468,20 +2493,19 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	if (!(poll_requested_events(wait) & (POLLWRBAND|POLLWRNORM|POLLOUT)))
 		return mask;
 
-	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
-	if (other) {
-		if (unix_peer(other) != sk) {
-			if (unix_recvq_full(other))
-				writable = 0;
-		}
-		sock_put(other);
-	}
-
-	if (writable)
+	if (unix_dgram_writable(sk, other)) {
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
-	else
+	} else {
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
+		/* pairs with mb in unix_dgram_recv */
+		smp_mb__after_atomic();
+		if (unix_dgram_writable(sk, other))
+			mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+	}
+	if (other)
+		sock_put(other);
 
 	return mask;
 }
-- 
1.8.2.rc2
