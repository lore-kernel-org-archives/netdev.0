From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Tue, 25 Mar 2014 18:42:27 -0700
Message-ID: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:54823 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaCZBma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 21:42:30 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so1242725pbc.24
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 18:42:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some applications didn't expect recvmsg() on a non blocking socket
could return -EINTR. This possibility was added as a side effect
of commit b3ca9b02b00704 ("net: fix multithreaded signal handling in
unix recv routines").

To hit this bug, you need to be a bit unlucky, as the u->readlock
mutex is usually held for very small periods.

Fixes: b3ca9b02b00704 ("net: fix multithreaded signal handling in unix recv routines")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---
 net/unix/af_unix.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ce6ec6c2f4de..94404f19f9de 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1787,8 +1787,11 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 
 	err = mutex_lock_interruptible(&u->readlock);
-	if (err) {
-		err = sock_intr_errno(sock_rcvtimeo(sk, noblock));
+	if (unlikely(err)) {
+		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
+		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
+		 */
+		err = noblock ? -EAGAIN : -ERESTARTSYS;
 		goto out;
 	}
 
@@ -1913,6 +1916,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct unix_sock *u = unix_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, msg->msg_name);
 	int copied = 0;
+	int noblock = flags & MSG_DONTWAIT;
 	int check_creds = 0;
 	int target;
 	int err = 0;
@@ -1928,7 +1932,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 
 	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
-	timeo = sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
+	timeo = sock_rcvtimeo(sk, noblock);
 
 	/* Lock the socket to prevent queue disordering
 	 * while sleeps in memcpy_tomsg
@@ -1940,8 +1944,11 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	err = mutex_lock_interruptible(&u->readlock);
-	if (err) {
-		err = sock_intr_errno(timeo);
+	if (unlikely(err)) {
+		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
+		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
+		 */
+		err = noblock ? -EAGAIN : -ERESTARTSYS;
 		goto out;
 	}
 
