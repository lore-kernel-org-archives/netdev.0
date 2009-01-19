From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: 64k bind(0) bugfix.
Date: Tue, 20 Jan 2009 02:21:51 +0300
Message-ID: <20090119232151.GA13659@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:39628 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbZASXVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 18:21:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I found the bug in bind conflict resolve path, when bundle was not
unlocked after conflict was detected, attached patch should fix it.

If testing will reveal some new problems I will return with the fix
then. Please apply or queue for the appropriate tree.

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

--- ./net/ipv4/inet_connection_sock.c~	2009-01-19 22:19:11.000000000 +0300
+++ ./net/ipv4/inet_connection_sock.c	2009-01-19 22:21:08.000000000 +0300
@@ -172,8 +172,10 @@
 		} else {
 			ret = 1;
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
-				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0)
+				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0) {
+					spin_unlock(&head->lock);
 					goto again;
+				}
 				goto fail_unlock;
 			}
 		}


-- 
	Evgeniy Polyakov
