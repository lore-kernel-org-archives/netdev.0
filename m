From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 01/47] Bluetooth: Add proper shutdown support to SCO sockets
Date: Sun, 30 Aug 2009 01:50:15 -0700
Message-ID: <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53262 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbZH3Ivu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:50 -0400
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SCO sockets for Bluetooth audio setup and streaming are missing the
shutdown implementation. This hasn't been a problem so far, but with a
more deeper integration with PulseAudio it is important to shutdown SCO
sockets properly.

Also the Headset profile 1.2 has more detailed qualification tests that
require that SCO and RFCOMM channels are terminated in the right order. A
proper shutdown function is necessary for this.

Based on a report by Johan Hedberg <johan.hedberg@nokia.com>

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
Tested-by: Johan Hedberg <johan.hedberg@nokia.com>
---
 net/bluetooth/sco.c |   49 ++++++++++++++++++++++++++++++++++---------------
 1 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 51ae0c3..13c27f1 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -359,20 +359,9 @@ static void sco_sock_kill(struct sock *sk)
 	sock_put(sk);
 }
 
-/* Close socket.
- * Must be called on unlocked socket.
- */
-static void sco_sock_close(struct sock *sk)
+static void __sco_sock_close(struct sock *sk)
 {
-	struct sco_conn *conn;
-
-	sco_sock_clear_timer(sk);
-
-	lock_sock(sk);
-
-	conn = sco_pi(sk)->conn;
-
-	BT_DBG("sk %p state %d conn %p socket %p", sk, sk->sk_state, conn, sk->sk_socket);
+	BT_DBG("sk %p state %d socket %p", sk, sk->sk_state, sk->sk_socket);
 
 	switch (sk->sk_state) {
 	case BT_LISTEN:
@@ -390,9 +379,15 @@ static void sco_sock_close(struct sock *sk)
 		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
 	}
+}
 
+/* Must be called on unlocked socket. */
+static void sco_sock_close(struct sock *sk)
+{
+	sco_sock_clear_timer(sk);
+	lock_sock(sk);
+	__sco_sock_close(sk);
 	release_sock(sk);
-
 	sco_sock_kill(sk);
 }
 
@@ -748,6 +743,30 @@ static int sco_sock_getsockopt(struct socket *sock, int level, int optname, char
 	return err;
 }
 
+static int sco_sock_shutdown(struct socket *sock, int how)
+{
+	struct sock *sk = sock->sk;
+	int err = 0;
+
+	BT_DBG("sock %p, sk %p", sock, sk);
+
+	if (!sk)
+		return 0;
+
+	lock_sock(sk);
+	if (!sk->sk_shutdown) {
+		sk->sk_shutdown = SHUTDOWN_MASK;
+		sco_sock_clear_timer(sk);
+		__sco_sock_close(sk);
+
+		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
+			err = bt_sock_wait_state(sk, BT_CLOSED,
+							sk->sk_lingertime);
+	}
+	release_sock(sk);
+	return err;
+}
+
 static int sco_sock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -969,7 +988,7 @@ static const struct proto_ops sco_sock_ops = {
 	.ioctl		= bt_sock_ioctl,
 	.mmap		= sock_no_mmap,
 	.socketpair	= sock_no_socketpair,
-	.shutdown	= sock_no_shutdown,
+	.shutdown	= sco_sock_shutdown,
 	.setsockopt	= sco_sock_setsockopt,
 	.getsockopt	= sco_sock_getsockopt
 };
-- 
1.6.2.5

