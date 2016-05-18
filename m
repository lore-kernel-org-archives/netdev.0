From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] net: af_unix: protect ->sk_shutdown change with lock_sock()
Date: Wed, 18 May 2016 13:14:46 +0300
Message-ID: <1463566486-9123-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

->sk_shutdown bits share one bitfield with some other bits in sock struct,
such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
sock_setsockopt() may write to these bits, while holding the socket lock.
In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
to corrupting these bits.

Fix that by protecting writes to ->sk_shutdown with lock_sock()

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 net/unix/af_unix.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 80aa6a3..7586a4e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -518,6 +518,7 @@ static void unix_release_sock(struct sock *sk, int embrion)
 	unix_remove_socket(sk);
 
 	/* Clear state */
+	lock_sock(sk);
 	unix_state_lock(sk);
 	sock_orphan(sk);
 	sk->sk_shutdown = SHUTDOWN_MASK;
@@ -527,6 +528,7 @@ static void unix_release_sock(struct sock *sk, int embrion)
 	state = sk->sk_state;
 	sk->sk_state = TCP_CLOSE;
 	unix_state_unlock(sk);
+	release_sock(sk);
 
 	wake_up_interruptible_all(&u->peer_wait);
 
@@ -534,12 +536,14 @@ static void unix_release_sock(struct sock *sk, int embrion)
 
 	if (skpair != NULL) {
 		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
+			lock_sock(skpair);
 			unix_state_lock(skpair);
 			/* No more writes */
 			skpair->sk_shutdown = SHUTDOWN_MASK;
 			if (!skb_queue_empty(&sk->sk_receive_queue) || embrion)
 				skpair->sk_err = ECONNRESET;
 			unix_state_unlock(skpair);
+			release_sock(skpair);
 			skpair->sk_state_change(skpair);
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
 		}
@@ -2547,12 +2551,14 @@ static int unix_shutdown(struct socket *sock, int mode)
 	 */
 	++mode;
 
+	lock_sock(sk);
 	unix_state_lock(sk);
 	sk->sk_shutdown |= mode;
 	other = unix_peer(sk);
 	if (other)
 		sock_hold(other);
 	unix_state_unlock(sk);
+	release_sock(sk);
 	sk->sk_state_change(sk);
 
 	if (other &&
@@ -2564,9 +2570,12 @@ static int unix_shutdown(struct socket *sock, int mode)
 			peer_mode |= SEND_SHUTDOWN;
 		if (mode&SEND_SHUTDOWN)
 			peer_mode |= RCV_SHUTDOWN;
+
+		lock_sock(other);
 		unix_state_lock(other);
 		other->sk_shutdown |= peer_mode;
 		unix_state_unlock(other);
+		release_sock(other);
 		other->sk_state_change(other);
 		if (peer_mode == SHUTDOWN_MASK)
 			sk_wake_async(other, SOCK_WAKE_WAITD, POLL_HUP);
-- 
2.7.3
