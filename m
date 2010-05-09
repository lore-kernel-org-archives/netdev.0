From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH] X25: Replace BKL in sockopts calls
Date: Sun, 09 May 2010 22:45:23 +1000
Message-ID: <1273409123.2727.387.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:33179 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab0EIMp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 May 2010 08:45:29 -0400
Received: by pxi5 with SMTP id 5so1237765pxi.19
        for <netdev@vger.kernel.org>; Sun, 09 May 2010 05:45:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


x25_setsockopt only updates the socket
x25_get only reads

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 296e65e..9f177a1 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -453,7 +453,6 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
 	struct sock *sk = sock->sk;
 	int rc = -ENOPROTOOPT;
 
-	lock_kernel();
 	if (level != SOL_X25 || optname != X25_QBITINCL)
 		goto out;
 
@@ -465,20 +464,20 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
 	if (get_user(opt, (int __user *)optval))
 		goto out;
 
+	lock_sock(sk);
 	x25_sk(sk)->qbitincl = !!opt;
+	release_sock(sk);
 	rc = 0;
 out:
-	unlock_kernel();
 	return rc;
 }
 
 static int x25_getsockopt(struct socket *sock, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
-	struct sock *sk = sock->sk;
+	struct x25_sock *sk = x25_sk(sock->sk);
 	int val, len, rc = -ENOPROTOOPT;
 
-	lock_kernel();
 	if (level != SOL_X25 || optname != X25_QBITINCL)
 		goto out;
 
@@ -496,10 +495,9 @@ static int x25_getsockopt(struct socket *sock, int level, int optname,
 	if (put_user(len, optlen))
 		goto out;
 
-	val = x25_sk(sk)->qbitincl;
+	val = sk->qbitincl;
 	rc = copy_to_user(optval, &val, len) ? -EFAULT : 0;
 out:
-	unlock_kernel();
 	return rc;
 }
 
-- 
1.7.0.4


