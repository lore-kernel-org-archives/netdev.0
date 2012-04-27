From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: cleanups in sock_setsockopt()
Date: Fri, 27 Apr 2012 08:07:59 +0200
Message-ID: <1335506879.2775.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:64913 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab2D0GIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 02:08:06 -0400
Received: by wgbds11 with SMTP id ds11so222036wgb.1
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 23:08:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use min_t()/max_t() macros, reformat two comments, use !!test_bit() to
match !!sock_flag()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |   42 +++++++++++++++---------------------------
 1 file changed, 15 insertions(+), 27 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 0431aaf..10605d2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -577,23 +577,15 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	case SO_SNDBUF:
 		/* Don't error on this BSD doesn't and if you think
-		   about it this is right. Otherwise apps have to
-		   play 'guess the biggest size' games. RCVBUF/SNDBUF
-		   are treated in BSD as hints */
-
-		if (val > sysctl_wmem_max)
-			val = sysctl_wmem_max;
+		 * about it this is right. Otherwise apps have to
+		 * play 'guess the biggest size' games. RCVBUF/SNDBUF
+		 * are treated in BSD as hints
+		 */
+		val = min_t(u32, val, sysctl_wmem_max);
 set_sndbuf:
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
-		if ((val * 2) < SOCK_MIN_SNDBUF)
-			sk->sk_sndbuf = SOCK_MIN_SNDBUF;
-		else
-			sk->sk_sndbuf = val * 2;
-
-		/*
-		 *	Wake up sending tasks if we
-		 *	upped the value.
-		 */
+		sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);
+		/* Wake up sending tasks if we upped the value. */
 		sk->sk_write_space(sk);
 		break;
 
@@ -606,12 +598,11 @@ set_sndbuf:
 
 	case SO_RCVBUF:
 		/* Don't error on this BSD doesn't and if you think
-		   about it this is right. Otherwise apps have to
-		   play 'guess the biggest size' games. RCVBUF/SNDBUF
-		   are treated in BSD as hints */
-
-		if (val > sysctl_rmem_max)
-			val = sysctl_rmem_max;
+		 * about it this is right. Otherwise apps have to
+		 * play 'guess the biggest size' games. RCVBUF/SNDBUF
+		 * are treated in BSD as hints
+		 */
+		val = min_t(u32, val, sysctl_rmem_max);
 set_rcvbuf:
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
 		/*
@@ -629,10 +620,7 @@ set_rcvbuf:
 		 * returning the value we actually used in getsockopt
 		 * is the most desirable behavior.
 		 */
-		if ((val * 2) < SOCK_MIN_RCVBUF)
-			sk->sk_rcvbuf = SOCK_MIN_RCVBUF;
-		else
-			sk->sk_rcvbuf = val * 2;
+		sk->sk_rcvbuf = max_t(u32, val * 2, SOCK_MIN_RCVBUF);
 		break;
 
 	case SO_RCVBUFFORCE:
@@ -975,7 +963,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_PASSCRED:
-		v.val = test_bit(SOCK_PASSCRED, &sock->flags) ? 1 : 0;
+		v.val = !!test_bit(SOCK_PASSCRED, &sock->flags);
 		break;
 
 	case SO_PEERCRED:
@@ -1010,7 +998,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_PASSSEC:
-		v.val = test_bit(SOCK_PASSSEC, &sock->flags) ? 1 : 0;
+		v.val = !!test_bit(SOCK_PASSSEC, &sock->flags);
 		break;
 
 	case SO_PEERSEC:
