From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: avoid signed overflows for SO_{SND|RCV}BUFFORCE
Date: Fri, 02 Dec 2016 09:44:53 -0800
Message-ID: <1480700693.18162.378.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33410 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752287AbcLBSza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:55:30 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so8647852pgd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:55:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

CAP_NET_ADMIN users should not be allowed to set negative
sk_sndbuf or sk_rcvbuf values, as it can lead to various memory
corruptions, crashes, OOM...

Note that before commit 82981930125a ("net: cleanups in
sock_setsockopt()"), the bug was even more serious, since SO_SNDBUF
and SO_RCVBUF were vulnerable.

This needs to be backported to all known linux kernels.

Again, many thanks to syzkaller team for discovering this gem.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/core/sock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5e3ca414357e2404db28eeacc5e9306051161493..00a074dbfe9bf169c2b81498e6ae265199745b22 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -715,7 +715,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		val = min_t(u32, val, sysctl_wmem_max);
 set_sndbuf:
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
-		sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);
+		sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);
 		/* Wake up sending tasks if we upped the value. */
 		sk->sk_write_space(sk);
 		break;
@@ -751,7 +751,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		 * returning the value we actually used in getsockopt
 		 * is the most desirable behavior.
 		 */
-		sk->sk_rcvbuf = max_t(u32, val * 2, SOCK_MIN_RCVBUF);
+		sk->sk_rcvbuf = max_t(int, val * 2, SOCK_MIN_RCVBUF);
 		break;
 
 	case SO_RCVBUFFORCE:
