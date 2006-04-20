From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 1/1]x25: fix for spinlock recurse and spinlock lockup with
	timer handler in x25
Date: Thu, 20 Apr 2006 15:03:23 +1000
Message-ID: <1145509403.16180.10.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-x25-owner@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>,
	linux-x25 <linux-x25@vger.kernel.org>,
	linux-kenel <linux-kernel@vger.kernel.org>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: spereira@tusc.com.au

When the sk_timer function x25_heartbeat_expiry() is called by the kernel
in a running/terminating process, spinlock-recursion and spinlock-lockup
locks up the kernel. 
This has happened with testing on some distro's and the patch below fixed it.

Signed-off-by:Shaun Pereira <spereira@tusc.com.au>

diff -uprN -X dontdiff linux-2.6.17-rc2-vanilla/net/x25/x25_timer.c linux-2.6.17-rc2/net/x25/x25_timer.c
--- linux-2.6.17-rc2-vanilla/net/x25/x25_timer.c	2006-04-20 12:00:03.000000000 +1000
+++ linux-2.6.17-rc2/net/x25/x25_timer.c	2006-04-20 12:02:43.000000000 +1000
@@ -114,8 +114,9 @@ static void x25_heartbeat_expiry(unsigne
 			if (sock_flag(sk, SOCK_DESTROY) ||
 			    (sk->sk_state == TCP_LISTEN &&
 			     sock_flag(sk, SOCK_DEAD))) {
+				bh_unlock_sock(sk);
 				x25_destroy_socket(sk);
-				goto unlock;
+				return;
 			}
 			break;
 
@@ -128,7 +129,6 @@ static void x25_heartbeat_expiry(unsigne
 	}
 restart_heartbeat:
 	x25_start_heartbeat(sk);
-unlock:
 	bh_unlock_sock(sk);
 }
 





