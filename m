From: Pavel Pergamenshchik <ppergame@gmail.com>
Subject: [PATCH] net: change recvform to return same address length as
	getsockname on unnamed unix sockets
Date: Wed, 21 Apr 2010 20:29:25 -0700
Message-ID: <v2x7447a0ac1004212029qd1866eaekc769fee5b13ac09d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

unix_*_recvmsg() returns zero-length sockaddr if the sender is an
unnamed AF_UNIX socket. Change it to return a two-byte sockaddr with
just the address family, to be consistent with unix_getname().

Signed-off-by: Pavel Pergamenshchik <ppergame@gmail.com>

---
Minimal example at http://xzrq.net/uaddrwtf.c
Solaris/OS X print 16 and 16. Linux prints 0 and 2 as described above.

--- a/net/unix/af_unix.c	2010-04-01 16:02:33.000000000 -0700
+++ b/net/unix/af_unix.c	2010-04-21 20:17:43.564703748 -0700
@@ -1634,9 +1634,13 @@
 static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
 {
 	struct unix_sock *u = unix_sk(sk);
+	struct sockaddr_un *sunaddr;

-	msg->msg_namelen = 0;
-	if (u->addr) {
+	if (!u->addr) {
+		msg->msg_namelen = sizeof(short);
+		sunaddr = msg->msg_name;
+		sunaddr->sun_family = AF_UNIX;
+	} else {
 		msg->msg_namelen = u->addr->len;
 		memcpy(msg->msg_name, u->addr->name, u->addr->len);
 	}
