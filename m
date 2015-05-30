From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: fix behavior of wrong checksums
Date: Sat, 30 May 2015 09:16:53 -0700
Message-ID: <1433002613.7456.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38616 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756954AbbE3QQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 12:16:56 -0400
Received: by igbjd9 with SMTP id jd9so34880066igb.1
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 09:16:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We have two problems in UDP stack related to bogus checksums :

1) We return -EAGAIN to application even if receive queue is not empty.
   This breaks applications using edge trigger epoll()

2) Under UDP flood, we can loop forever without yielding to other
   processes, potentially hanging the host, especially on non SMP.


This patch is an attempt to make things better.

We might in the future add extra support for rt applications
wanting to better control time spent doing a recv() in a hostile
environment. For example we could validate checksums before queuing
packets in socket receive queue.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/udp.c |    6 ++----
 net/ipv6/udp.c |    6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d10b7e0112eb..1c92ea67baef 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1345,10 +1345,8 @@ csum_copy_err:
 	}
 	unlock_sock_fast(sk, slow);
 
-	if (noblock)
-		return -EAGAIN;
-
-	/* starting over for a new packet */
+	/* starting over for a new packet, but check if we need to yield */
+	cond_resched();
 	msg->msg_flags &= ~MSG_TRUNC;
 	goto try_again;
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c2ec41617a35..e51fc3eee6db 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -525,10 +525,8 @@ csum_copy_err:
 	}
 	unlock_sock_fast(sk, slow);
 
-	if (noblock)
-		return -EAGAIN;
-
-	/* starting over for a new packet */
+	/* starting over for a new packet, but check if we need to yield */
+	cond_resched();
 	msg->msg_flags &= ~MSG_TRUNC;
 	goto try_again;
 }
