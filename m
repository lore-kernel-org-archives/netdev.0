From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next 1/2] net: add sk_stream_is_writeable() helper
Date: Mon, 22 Jul 2013 20:26:31 -0700
Message-ID: <1374549991.4990.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:63214 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab3GWD0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 23:26:35 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so7887440pbc.1
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 20:26:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Several call sites use the hardcoded following condition :

sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)

Lets use a helper because TCP_NOTSENT_LOWAT support will change this
condition for TCP sockets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/sock.h    |    4 ++++
 net/ceph/messenger.c  |    2 +-
 net/core/stream.c     |    2 +-
 net/dccp/proto.c      |    4 ++--
 net/ipv4/tcp.c        |    4 ++--
 net/sunrpc/svcsock.c  |    2 +-
 net/sunrpc/xprtsock.c |    2 +-
 7 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e0473f6..d0b5fde 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1088,6 +1088,10 @@ static inline struct cg_proto *parent_cg_proto(struct proto *proto,
 }
 #endif
 
+static inline bool sk_stream_is_writeable(const struct sock *sk)
+{
+	return sk_stream_wspace(sk) >= sk_stream_min_wspace(sk);
+}
 
 static inline bool sk_has_memory_pressure(const struct sock *sk)
 {
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index eb0a46a..3be308e 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -409,7 +409,7 @@ static void ceph_sock_write_space(struct sock *sk)
 	 * and net/core/stream.c:sk_stream_write_space().
 	 */
 	if (con_flag_test(con, CON_FLAG_WRITE_PENDING)) {
-		if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
+		if (sk_stream_is_writeable(sk)) {
 			dout("%s %p queueing write work\n", __func__, con);
 			clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 			queue_con(con);
diff --git a/net/core/stream.c b/net/core/stream.c
index f5df85d..512f0a2 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -30,7 +30,7 @@ void sk_stream_write_space(struct sock *sk)
 	struct socket *sock = sk->sk_socket;
 	struct socket_wq *wq;
 
-	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk) && sock) {
+	if (sk_stream_is_writeable(sk) && sock) {
 		clear_bit(SOCK_NOSPACE, &sock->flags);
 
 		rcu_read_lock();
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 6c7c78b..ba64750 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -336,7 +336,7 @@ unsigned int dccp_poll(struct file *file, struct socket *sock,
 			mask |= POLLIN | POLLRDNORM;
 
 		if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
-			if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
+			if (sk_stream_is_writeable(sk)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
 				set_bit(SOCK_ASYNC_NOSPACE,
@@ -347,7 +347,7 @@ unsigned int dccp_poll(struct file *file, struct socket *sock,
 				 * wspace test but before the flags are set,
 				 * IO signal will be lost.
 				 */
-				if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
+				if (sk_stream_is_writeable(sk))
 					mask |= POLLOUT | POLLWRNORM;
 			}
 		}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5423223..5eca906 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -499,7 +499,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 			mask |= POLLIN | POLLRDNORM;
 
 		if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
-			if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
+			if (sk_stream_is_writeable(sk)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
 				set_bit(SOCK_ASYNC_NOSPACE,
@@ -510,7 +510,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 				 * wspace test but before the flags are set,
 				 * IO signal will be lost.
 				 */
-				if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
+				if (sk_stream_is_writeable(sk))
 					mask |= POLLOUT | POLLWRNORM;
 			}
 		} else
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 305374d..0da6785 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -442,7 +442,7 @@ static void svc_tcp_write_space(struct sock *sk)
 {
 	struct socket *sock = sk->sk_socket;
 
-	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk) && sock)
+	if (sk_stream_is_writeable(sk) && sock)
 		clear_bit(SOCK_NOSPACE, &sock->flags);
 	svc_write_space(sk);
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ddf0602..d6656d7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1602,7 +1602,7 @@ static void xs_tcp_write_space(struct sock *sk)
 	read_lock_bh(&sk->sk_callback_lock);
 
 	/* from net/core/stream.c:sk_stream_write_space */
-	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
+	if (sk_stream_is_writeable(sk))
 		xs_write_space(sk);
 
 	read_unlock_bh(&sk->sk_callback_lock);
