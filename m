From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATH 02/02] af_unix: fix unix_dgram_recvmsg entry locking
Date: Sun, 06 Dec 2015 21:11:38 +0000
Message-ID: <8737vf7051.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current unix_dgram_recvsmg code acquires the u->readlock mutex in
order to protect access to the peek offset prior to calling
__skb_recv_datagram for actually receiving data. This implies that a
blocking reader will go to sleep with this mutex held if there's
presently no data to return to userspace. Two non-desirable side effects
of this are that a later non-blocking read call on the same socket will
block on the ->readlock mutex until the earlier blocking call releases it
(or the readers is interrupted) and that later blocking read calls
will wait longer than the effective socket read timeout says they
should: The timeout will only start 'ticking' once such a reader hits
the schedule_timeout in wait_for_more_packets (core.c) while the time it
already had to wait until it could acquire the mutex is unaccounted for.

The patch avoids both by using the __skb_try_recv_datagram and
__skb_wait_for_more packets functions created by the first patch to
implement a unix_dgram_recvmsg read loop which releases the readlock
mutex prior to going to sleep and reacquires it as needed
afterwards. Non-blocking readers will thus immediately return with
-EAGAIN if there's no data available regardless of any concurrent
blocking readers and all blocking readers will end up sleeping via
schedule_timeout, thus honouring the configured socket receive timeout.

Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 45aebd9..47dfa97 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2078,8 +2078,8 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
-	int noblock = flags & MSG_DONTWAIT;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *last;
+	long timeo;
 	int err;
 	int peeked, skip;
 
@@ -2087,26 +2087,32 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 	if (flags&MSG_OOB)
 		goto out;
 
-	err = mutex_lock_interruptible(&u->readlock);
-	if (unlikely(err)) {
-		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
-		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
-		 */
-		err = noblock ? -EAGAIN : -ERESTARTSYS;
-		goto out;
-	}
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
-	skip = sk_peek_offset(sk, flags);
+	do {
+		mutex_lock(&u->readlock);
 
-	skb = __skb_recv_datagram(sk, flags, &peeked, &skip, &err);
-	if (!skb) {
+		skip = sk_peek_offset(sk, flags);
+		skb = __skb_try_recv_datagram(sk, flags, &peeked, &skip, &err,
+					      &last);
+		if (skb)
+			break;
+
+		mutex_unlock(&u->readlock);
+
+		if (err != -EAGAIN)
+			break;
+	} while (timeo &&
+		 !__skb_wait_for_more_packets(sk, &err, &timeo, last));
+
+	if (!skb) { /* implies readlock unlocked */
 		unix_state_lock(sk);
 		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
 		if (sk->sk_type == SOCK_SEQPACKET && err == -EAGAIN &&
 		    (sk->sk_shutdown & RCV_SHUTDOWN))
 			err = 0;
 		unix_state_unlock(sk);
-		goto out_unlock;
+		goto out;
 	}
 
 	wake_up_interruptible_sync_poll(&u->peer_wait,
@@ -2162,7 +2168,6 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 
 out_free:
 	skb_free_datagram(sk, skb);
-out_unlock:
 	mutex_unlock(&u->readlock);
 out:
 	return err;
