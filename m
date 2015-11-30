From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 1/2] net: rename SOCK_ASYNC_NOSPACE and SOCK_ASYNC_WAITDATA
Date: Sun, 29 Nov 2015 20:03:10 -0800
Message-ID: <1448856191-31435-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35649 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbbK3EDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 23:03:17 -0500
Received: by pacej9 with SMTP id ej9so170544132pac.2
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 20:03:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a cleanup to make following patch easier to
review.

Goal is to move SOCK_ASYNC_NOSPACE and SOCK_ASYNC_WAITDATA
from (struct socket)->flags to a (struct socket_wq)->flags
to benefit from RCU protection in sock_wake_async()

To ease backports, we rename both constants.

Two new helpers, sk_set_bit(int nr, struct sock *sk)
and sk_clear_bit(int net, struct sock *sk) are added so that
following patch can change their implementation.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 crypto/algif_aead.c          |  4 ++--
 crypto/algif_skcipher.c      |  6 +++---
 drivers/net/macvtap.c        |  4 ++--
 drivers/net/tun.c            |  4 ++--
 fs/dlm/lowcomms.c            |  4 ++--
 include/linux/net.h          |  6 +++---
 include/net/sock.h           | 10 ++++++++++
 net/bluetooth/af_bluetooth.c |  6 +++---
 net/caif/caif_socket.c       |  4 ++--
 net/core/datagram.c          |  2 +-
 net/core/sock.c              |  8 ++++----
 net/core/stream.c            |  4 ++--
 net/dccp/proto.c             |  3 +--
 net/decnet/af_decnet.c       |  8 ++++----
 net/ipv4/tcp.c               |  7 +++----
 net/iucv/af_iucv.c           |  2 +-
 net/nfc/llcp_sock.c          |  2 +-
 net/rxrpc/ar-output.c        |  2 +-
 net/sctp/socket.c            |  2 +-
 net/socket.c                 |  4 ++--
 net/sunrpc/xprtsock.c        | 14 +++++++-------
 net/unix/af_unix.c           |  6 +++---
 22 files changed, 60 insertions(+), 52 deletions(-)

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 0aa6fdfb448a..6d4d4569447e 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -125,7 +125,7 @@ static int aead_wait_for_data(struct sock *sk, unsigned flags)
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
 
-	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	for (;;) {
 		if (signal_pending(current))
@@ -139,7 +139,7 @@ static int aead_wait_for_data(struct sock *sk, unsigned flags)
 	}
 	finish_wait(sk_sleep(sk), &wait);
 
-	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	return err;
 }
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index af31a0ee4057..ca9efe17db1a 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -212,7 +212,7 @@ static int skcipher_wait_for_wmem(struct sock *sk, unsigned flags)
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
 
-	set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	for (;;) {
 		if (signal_pending(current))
@@ -258,7 +258,7 @@ static int skcipher_wait_for_data(struct sock *sk, unsigned flags)
 		return -EAGAIN;
 	}
 
-	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	for (;;) {
 		if (signal_pending(current))
@@ -272,7 +272,7 @@ static int skcipher_wait_for_data(struct sock *sk, unsigned flags)
 	}
 	finish_wait(sk_sleep(sk), &wait);
 
-	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	return err;
 }
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 54036ae0a388..0fc521941c71 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -498,7 +498,7 @@ static void macvtap_sock_write_space(struct sock *sk)
 	wait_queue_head_t *wqueue;
 
 	if (!sock_writeable(sk) ||
-	    !test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
+	    !test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;
 
 	wqueue = sk_sleep(sk);
@@ -585,7 +585,7 @@ static unsigned int macvtap_poll(struct file *file, poll_table * wait)
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sock_writeable(&q->sk) ||
-	    (!test_and_set_bit(SOCK_ASYNC_NOSPACE, &q->sock.flags) &&
+	    (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &q->sock.flags) &&
 	     sock_writeable(&q->sk)))
 		mask |= POLLOUT | POLLWRNORM;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b1878faea397..f0db770e8b2f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1040,7 +1040,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sock_writeable(sk) ||
-	    (!test_and_set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
+	    (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
 	     sock_writeable(sk)))
 		mask |= POLLOUT | POLLWRNORM;
 
@@ -1488,7 +1488,7 @@ static void tun_sock_write_space(struct sock *sk)
 	if (!sock_writeable(sk))
 		return;
 
-	if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
+	if (!test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;
 
 	wqueue = sk_sleep(sk);
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 87e9d796cf7d..3a37bd3f9637 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -421,7 +421,7 @@ static void lowcomms_write_space(struct sock *sk)
 
 	if (test_and_clear_bit(CF_APP_LIMITED, &con->flags)) {
 		con->sock->sk->sk_write_pending--;
-		clear_bit(SOCK_ASYNC_NOSPACE, &con->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &con->sock->flags);
 	}
 
 	if (!test_and_set_bit(CF_WRITE_PENDING, &con->flags))
@@ -1448,7 +1448,7 @@ static void send_to_sock(struct connection *con)
 					      msg_flags);
 			if (ret == -EAGAIN || ret == 0) {
 				if (ret == -EAGAIN &&
-				    test_bit(SOCK_ASYNC_NOSPACE, &con->sock->flags) &&
+				    test_bit(SOCKWQ_ASYNC_NOSPACE, &con->sock->flags) &&
 				    !test_and_set_bit(CF_APP_LIMITED, &con->flags)) {
 					/* Notify TCP that we're limited by the
 					 * application window size.
diff --git a/include/linux/net.h b/include/linux/net.h
index 70ac5e28e6b7..f514e4dd5521 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -34,8 +34,8 @@ struct inode;
 struct file;
 struct net;
 
-#define SOCK_ASYNC_NOSPACE	0
-#define SOCK_ASYNC_WAITDATA	1
+#define SOCKWQ_ASYNC_NOSPACE	0
+#define SOCKWQ_ASYNC_WAITDATA	1
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
@@ -96,7 +96,7 @@ struct socket_wq {
  *  struct socket - general BSD socket
  *  @state: socket state (%SS_CONNECTED, etc)
  *  @type: socket type (%SOCK_STREAM, etc)
- *  @flags: socket flags (%SOCK_ASYNC_NOSPACE, etc)
+ *  @flags: socket flags (%SOCK_NOSPACE, etc)
  *  @ops: protocol specific socket operations
  *  @file: File back pointer for gc
  *  @sk: internal networking protocol agnostic socket representation
diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4ba18d1..c155d09d8af4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2005,6 +2005,16 @@ static inline unsigned long sock_wspace(struct sock *sk)
 	return amt;
 }
 
+static inline void sk_set_bit(int nr, struct sock *sk)
+{
+	set_bit(nr, &sk->sk_socket->flags);
+}
+
+static inline void sk_clear_bit(int nr, struct sock *sk)
+{
+	clear_bit(nr, &sk->sk_socket->flags);
+}
+
 static inline void sk_wake_async(struct sock *sk, int how, int band)
 {
 	if (sock_flag(sk, SOCK_FASYNC))
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index a3bffd1ec2b4..70306cc9d814 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -271,11 +271,11 @@ static long bt_sock_data_wait(struct sock *sk, long timeo)
 		if (signal_pending(current) || !timeo)
 			break;
 
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	}
 
 	__set_current_state(TASK_RUNNING);
@@ -441,7 +441,7 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock,
 	if (!test_bit(BT_SK_SUSPEND, &bt_sk(sk)->flags) && sock_writeable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index cc858919108e..aa209b1066c9 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -323,7 +323,7 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
 			!timeo)
 			break;
 
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
@@ -331,7 +331,7 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
 		if (sock_flag(sk, SOCK_DEAD))
 			break;
 
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	}
 
 	finish_wait(sk_sleep(sk), &wait);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 617088aee21d..d62af69ad844 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -785,7 +785,7 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 	if (sock_writeable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e4dd54bfb5a..9d79569935a3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1815,7 +1815,7 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
 {
 	DEFINE_WAIT(wait);
 
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 	for (;;) {
 		if (!timeo)
 			break;
@@ -1861,7 +1861,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		if (sk_wmem_alloc_get(sk) < sk->sk_sndbuf)
 			break;
 
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		err = -EAGAIN;
 		if (!timeo)
@@ -2048,9 +2048,9 @@ int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb)
 	DEFINE_WAIT(wait);
 
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	rc = sk_wait_event(sk, timeo, skb_peek_tail(&sk->sk_receive_queue) != skb);
-	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	finish_wait(sk_sleep(sk), &wait);
 	return rc;
 }
diff --git a/net/core/stream.c b/net/core/stream.c
index d70f77a0c889..43309428644d 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -126,7 +126,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 		current_timeo = vm_wait = (prandom_u32() % (HZ / 5)) + 2;
 
 	while (1) {
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
@@ -139,7 +139,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 		}
 		if (signal_pending(current))
 			goto do_interrupted;
-		clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 		if (sk_stream_memory_free(sk) && !vm_wait)
 			break;
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index b5cf13a28009..41e65804ddf5 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -339,8 +339,7 @@ unsigned int dccp_poll(struct file *file, struct socket *sock,
 			if (sk_stream_is_writeable(sk)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
-				set_bit(SOCK_ASYNC_NOSPACE,
-					&sk->sk_socket->flags);
+				sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 
 				/* Race breaker. If space is freed after
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 675cf94e04f8..eebf5ac8ce18 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1747,9 +1747,9 @@ static int dn_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		}
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		sk_wait_event(sk, &timeo, dn_data_ready(sk, queue, flags, target));
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		finish_wait(sk_sleep(sk), &wait);
 	}
 
@@ -2004,10 +2004,10 @@ static int dn_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 			}
 
 			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-			set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+			sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 			sk_wait_event(sk, &timeo,
 				      !dn_queue_too_long(scp, queue, flags));
-			clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+			sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 			finish_wait(sk_sleep(sk), &wait);
 			continue;
 		}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c1728771cf89..c82cca18c90f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -517,8 +517,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 			if (sk_stream_is_writeable(sk)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
-				set_bit(SOCK_ASYNC_NOSPACE,
-					&sk->sk_socket->flags);
+				sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 
 				/* Race breaker. If space is freed after
@@ -906,7 +905,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 			goto out_err;
 	}
 
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
 	copied = 0;
@@ -1134,7 +1133,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	}
 
 	/* This should be in poll */
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index fcb2752419c6..435608c4306d 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1483,7 +1483,7 @@ unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 	if (sock_writeable(sk) && iucv_below_msglim(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index b7de0da46acd..ecf0a0196f18 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -572,7 +572,7 @@ static unsigned int llcp_sock_poll(struct file *file, struct socket *sock,
 	if (sock_writeable(sk) && sk->sk_state == LLCP_CONNECTED)
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	pr_debug("mask 0x%x\n", mask);
 
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index a40d3afe93b7..14c4e12c47b0 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -531,7 +531,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
 
 	/* this should be in poll */
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		return -EPIPE;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 897c01c029ca..2353985d689c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6458,7 +6458,7 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	if (sctp_writeable(sk)) {
 		mask |= POLLOUT | POLLWRNORM;
 	} else {
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 		/*
 		 * Since the socket is not locked, the buffer
 		 * might be made available after the writeable check and
diff --git a/net/socket.c b/net/socket.c
index dd2c247c99e3..16be908205fc 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1072,11 +1072,11 @@ int sock_wake_async(struct socket *sock, int how, int band)
 	}
 	switch (how) {
 	case SOCK_WAKE_WAITD:
-		if (test_bit(SOCK_ASYNC_WAITDATA, &sock->flags))
+		if (test_bit(SOCKWQ_ASYNC_WAITDATA, &sock->flags))
 			break;
 		goto call_kill;
 	case SOCK_WAKE_SPACE:
-		if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags))
+		if (!test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->flags))
 			break;
 		/* fall through */
 	case SOCK_WAKE_IO:
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1d1a70498910..2ffaf6a79499 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -398,7 +398,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (unlikely(!sock))
 		return -ENOTSOCK;
 
-	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+	clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->flags);
 	if (base != 0) {
 		addr = NULL;
 		addrlen = 0;
@@ -442,7 +442,7 @@ static void xs_nospace_callback(struct rpc_task *task)
 	struct sock_xprt *transport = container_of(task->tk_rqstp->rq_xprt, struct sock_xprt, xprt);
 
 	transport->inet->sk_write_pending--;
-	clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+	clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->flags);
 }
 
 /**
@@ -467,7 +467,7 @@ static int xs_nospace(struct rpc_task *task)
 
 	/* Don't race with disconnect */
 	if (xprt_connected(xprt)) {
-		if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {
+		if (test_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->flags)) {
 			/*
 			 * Notify TCP that we're limited by the application
 			 * window size
@@ -478,7 +478,7 @@ static int xs_nospace(struct rpc_task *task)
 			xprt_wait_for_buffer_space(task, xs_nospace_callback);
 		}
 	} else {
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->flags);
 		ret = -ENOTCONN;
 	}
 
@@ -626,7 +626,7 @@ process_status:
 	case -EPERM:
 		/* When the server has died, an ICMP port unreachable message
 		 * prompts ECONNREFUSED. */
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->flags);
 	}
 
 	return status;
@@ -715,7 +715,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -EADDRINUSE:
 	case -ENOBUFS:
 	case -EPIPE:
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->flags);
 	}
 
 	return status;
@@ -1618,7 +1618,7 @@ static void xs_write_space(struct sock *sk)
 
 	if (unlikely(!(xprt = xprt_from_sock(sk))))
 		return;
-	if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
+	if (test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->flags) == 0)
 		return;
 
 	xprt_write_space(xprt);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4e95bdf973d9..1a87a0e1c9e3 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2139,7 +2139,7 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 		    !timeo)
 			break;
 
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		unix_state_unlock(sk);
 		timeo = freezable_schedule_timeout(timeo);
 		unix_state_lock(sk);
@@ -2147,7 +2147,7 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 		if (sock_flag(sk, SOCK_DEAD))
 			break;
 
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	}
 
 	finish_wait(sk_sleep(sk), &wait);
@@ -2634,7 +2634,7 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	if (writable)
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
-- 
2.6.0.rc2.230.g3dd15c0
