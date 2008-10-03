From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 2/6] Phonet: connected sockets glue
Date: Fri,  3 Oct 2008 17:09:35 +0300
Message-ID: <1223042979-21124-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200810031709.11828.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:32263 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbYJCOJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 10:09:44 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m93E9MYJ013730
	for <netdev@vger.kernel.org>; Fri, 3 Oct 2008 17:09:41 +0300
In-Reply-To: <200810031709.11828.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/phonet/pep.h |   43 ++++++++++++++++++++
 net/phonet/socket.c      |   97 ++++++++++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 140 insertions(+), 0 deletions(-)
 create mode 100644 include/net/phonet/pep.h

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
new file mode 100644
index 0000000..b2f8c54
--- /dev/null
+++ b/include/net/phonet/pep.h
@@ -0,0 +1,43 @@
+/*
+ * File: pep.h
+ *
+ * Phonet Pipe End Point sockets definitions
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#ifndef NET_PHONET_PEP_H
+#define NET_PHONET_PEP_H
+
+struct pep_sock {
+	struct pn_sock		pn_sk;
+
+	/* Listening socket stuff: */
+	struct hlist_head	ackq;
+
+	/* Connected socket stuff: */
+	u8			tx_credits;
+};
+
+static inline struct pep_sock *pep_sk(struct sock *sk)
+{
+	return (struct pep_sock *)sk;
+}
+
+extern const struct proto_ops phonet_stream_ops;
+
+#endif
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index dfd4061..cea1136 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -25,11 +25,13 @@
=20
 #include <linux/kernel.h>
 #include <linux/net.h>
+#include <linux/poll.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
=20
 #include <linux/phonet.h>
 #include <net/phonet/phonet.h>
+#include <net/phonet/pep.h>
 #include <net/phonet/pn_dev.h>
=20
 static int pn_socket_release(struct socket *sock)
@@ -166,6 +168,24 @@ static int pn_socket_autobind(struct socket *sock)
 	return 0; /* socket was already bound */
 }
=20
+static int pn_socket_accept(struct socket *sock, struct socket *newsoc=
k,
+				int flags)
+{
+	struct sock *sk =3D sock->sk;
+	struct sock *newsk;
+	int err;
+
+	newsk =3D sk->sk_prot->accept(sk, flags, &err);
+	if (!newsk)
+		return err;
+
+	lock_sock(newsk);
+	sock_graft(newsk, newsock);
+	newsock->state =3D SS_CONNECTED;
+	release_sock(newsk);
+	return 0;
+}
+
 static int pn_socket_getname(struct socket *sock, struct sockaddr *add=
r,
 				int *sockaddr_len, int peer)
 {
@@ -182,6 +202,33 @@ static int pn_socket_getname(struct socket *sock, =
struct sockaddr *addr,
 	return 0;
 }
=20
+static unsigned int pn_socket_poll(struct file *file, struct socket *s=
ock,
+					poll_table *wait)
+{
+	struct sock *sk =3D sock->sk;
+	struct pep_sock *pn =3D pep_sk(sk);
+	unsigned int mask =3D 0;
+
+	poll_wait(file, &sock->wait, wait);
+
+	switch (sk->sk_state) {
+	case TCP_LISTEN:
+		return hlist_empty(&pn->ackq) ? 0 : POLLIN;
+	case TCP_CLOSE:
+		return POLLERR;
+	}
+
+	if (!skb_queue_empty(&sk->sk_receive_queue))
+		mask |=3D POLLIN | POLLRDNORM;
+	else if (sk->sk_state =3D=3D TCP_CLOSE_WAIT)
+		return POLLHUP;
+
+	if (sk->sk_state =3D=3D TCP_ESTABLISHED && pn->tx_credits)
+		mask |=3D POLLOUT | POLLWRNORM | POLLWRBAND;
+
+	return mask;
+}
+
 static int pn_socket_ioctl(struct socket *sock, unsigned int cmd,
 				unsigned long arg)
 {
@@ -220,6 +267,30 @@ static int pn_socket_ioctl(struct socket *sock, un=
signed int cmd,
 	return sk->sk_prot->ioctl(sk, cmd, arg);
 }
=20
+static int pn_socket_listen(struct socket *sock, int backlog)
+{
+	struct sock *sk =3D sock->sk;
+	int err =3D 0;
+
+	if (sock->state !=3D SS_UNCONNECTED)
+		return -EINVAL;
+	if (pn_socket_autobind(sock))
+		return -ENOBUFS;
+
+	lock_sock(sk);
+	if (sk->sk_state !=3D TCP_CLOSE) {
+		err =3D -EINVAL;
+		goto out;
+	}
+
+	sk->sk_state =3D TCP_LISTEN;
+	sk->sk_ack_backlog =3D 0;
+	sk->sk_max_ack_backlog =3D backlog;
+out:
+	release_sock(sk);
+	return err;
+}
+
 static int pn_socket_sendmsg(struct kiocb *iocb, struct socket *sock,
 				struct msghdr *m, size_t total_len)
 {
@@ -256,6 +327,32 @@ const struct proto_ops phonet_dgram_ops =3D {
 	.sendpage	=3D sock_no_sendpage,
 };
=20
+const struct proto_ops phonet_stream_ops =3D {
+	.family		=3D AF_PHONET,
+	.owner		=3D THIS_MODULE,
+	.release	=3D pn_socket_release,
+	.bind		=3D pn_socket_bind,
+	.connect	=3D sock_no_connect,
+	.socketpair	=3D sock_no_socketpair,
+	.accept		=3D pn_socket_accept,
+	.getname	=3D pn_socket_getname,
+	.poll		=3D pn_socket_poll,
+	.ioctl		=3D pn_socket_ioctl,
+	.listen		=3D pn_socket_listen,
+	.shutdown	=3D sock_no_shutdown,
+	.setsockopt	=3D sock_no_setsockopt,
+	.getsockopt	=3D sock_no_getsockopt,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt =3D sock_no_setsockopt,
+	.compat_getsockopt =3D compat_sock_no_getsockopt,
+#endif
+	.sendmsg	=3D pn_socket_sendmsg,
+	.recvmsg	=3D sock_common_recvmsg,
+	.mmap		=3D sock_no_mmap,
+	.sendpage	=3D sock_no_sendpage,
+};
+EXPORT_SYMBOL(phonet_stream_ops);
+
 static DEFINE_MUTEX(port_mutex);
=20
 /* allocate port for a socket */
--=20
1.5.4.3

