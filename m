From: Steven Dake <scd@broked.org>
Subject: [PATCH] Add SOCK_SEQPACKET to PF_UNIX protocol family
Date: Sat, 28 Feb 2004 00:19:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077952763.21806.78.camel@slickdeal.broked.org>
Reply-To: scd@broked.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-sRHf0cmxArlz/zqyfL//"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-sRHf0cmxArlz/zqyfL//
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Folks,

Attached is a patch which adds SOCK_SEQPACKET to the PF_UNIX protocol
family.  It doesn't seem to break SOCK_STREAM or SOCK_DGRAM for PF_UNIX
and adds the desired functionality.  I could find alot of questions
about "is this supported" but only one response stating as of yet it is
not.

SOCK_DGRAM doesn't work on connected sockets.  Using SOCK_STREAM for
connection oriented sockets requires the application to frame if
variable length messages are desired.

This patch provides the best of both of those protocols by following the
SOCK_SEQPACKET semantics of allowing datagrams over connected PF_UNIX
sockets.

SOCK_SEQPACKET provides several advantages over SOCK_STREAM or
SOCK_DGRAM:
1. only one system call (vs two for SOCK_STREAM) is required for
variable length messages, no framing is required
2. the end of a large message can be discarded without processing if the
application is only interested in the beginning of the message.
3. connected fds can be used to uniquely identify a connection. (the
kernel is used to ensure application security).

Comments welcome, enjoy

-steve


--=-sRHf0cmxArlz/zqyfL//
Content-Disposition: attachment; filename=linux-2.6.3-af_unix-sockseqpacket.patch
Content-Type: text/plain; name=linux-2.6.3-af_unix-sockseqpacket.patch; charset=
Content-Transfer-Encoding: 7bit

--- linux-2.6.3/net/unix/af_unix.c	2004-02-17 20:58:33.000000000 -0700
+++ linux-2.6.3-seqpacket/net/unix/af_unix.c	2004-02-27 23:25:23.000000000 -0700
@@ -377,7 +377,7 @@
 	skpair=unix_peer(sk);
 
 	if (skpair!=NULL) {
-		if (sk->sk_type == SOCK_STREAM) {
+		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
 			unix_state_wlock(skpair);
 			/* No more writes */
 			skpair->sk_shutdown = SHUTDOWN_MASK;
@@ -435,8 +435,8 @@
 	struct unix_sock *u = unix_sk(sk);
 
 	err = -EOPNOTSUPP;
-	if (sock->type!=SOCK_STREAM)
-		goto out;			/* Only stream sockets accept */
+	if (sock->type!=SOCK_STREAM && sock->type!=SOCK_SEQPACKET)
+		goto out;			/* Only stream/seqpacket sockets accept */
 	err = -EINVAL;
 	if (!u->addr)
 		goto out;			/* No listens on an unbound socket */
@@ -461,6 +461,7 @@
 
 extern struct proto_ops unix_stream_ops;
 extern struct proto_ops unix_dgram_ops;
+extern struct proto_ops unix_seqpacket_ops;
 
 static struct sock * unix_create1(struct socket *sock)
 {
@@ -515,6 +516,9 @@
 	case SOCK_DGRAM:
 		sock->ops = &unix_dgram_ops;
 		break;
+	case SOCK_SEQPACKET:
+		sock->ops = &unix_seqpacket_ops;
+		break;
 	default:
 		return -ESOCKTNOSUPPORT;
 	}
@@ -982,7 +986,7 @@
 	sock_hold(sk);
 	unix_peer(newsk)	= sk;
 	newsk->sk_state		= TCP_ESTABLISHED;
-	newsk->sk_type		= SOCK_STREAM;
+	newsk->sk_type		= sk->sk_type;
 	newsk->sk_peercred.pid	= current->tgid;
 	newsk->sk_peercred.uid	= current->euid;
 	newsk->sk_peercred.gid	= current->egid;
@@ -1066,7 +1070,7 @@
 	int err;
 
 	err = -EOPNOTSUPP;
-	if (sock->type!=SOCK_STREAM)
+	if (sock->type!=SOCK_STREAM && sock->type!=SOCK_SEQPACKET)
 		goto out;
 
 	err = -EINVAL;
@@ -1711,7 +1715,9 @@
 		unix_state_wunlock(sk);
 		sk->sk_state_change(sk);
 
-		if (other && sk->sk_type == SOCK_STREAM) {
+		if (other &&
+			(sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET)) {
+
 			int peer_mode = 0;
 
 			if (mode&RCV_SHUTDOWN)
@@ -1791,7 +1797,7 @@
 		mask |= POLLIN | POLLRDNORM;
 
 	/* Connection-based need to check for termination and startup */
-	if (sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_CLOSE)
+	if ((sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) && sk->sk_state == TCP_CLOSE)
 		mask |= POLLHUP;
 
 	/*
@@ -1967,6 +1973,27 @@
 	.sendpage =	sock_no_sendpage,
 };
 
+struct proto_ops unix_seqpacket_ops = {
+	.family =	PF_UNIX,
+	.owner =	THIS_MODULE,
+	.release =	unix_release,
+	.bind =		unix_bind,
+	.connect =	unix_stream_connect,
+	.socketpair =	unix_socketpair,
+	.accept =	unix_accept,
+	.getname =	unix_getname,
+	.poll =		datagram_poll,
+	.ioctl =	unix_ioctl,
+	.listen =	unix_listen,
+	.shutdown =	unix_shutdown,
+	.setsockopt =	sock_no_setsockopt,
+	.getsockopt =	sock_no_getsockopt,
+	.sendmsg =	unix_dgram_sendmsg,
+	.recvmsg =	unix_dgram_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
+};
+
 struct net_proto_family unix_family_ops = {
 	.family = PF_UNIX,
 	.create = unix_create,

--=-sRHf0cmxArlz/zqyfL//--
