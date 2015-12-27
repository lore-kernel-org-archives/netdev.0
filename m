From: Nicolai Stange <nicstange@gmail.com>
Subject: [PATCH] net, socket, socket_wq: fix missing initialization of flags
Date: Sun, 27 Dec 2015 21:00:45 +0100
Message-ID: <87ege73bma.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36504 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbbL0UAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 15:00:49 -0500
CC: Nicolai Stange <nicstange@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: ceb5d58b2170 ("net: fix sock_wake_async() rcu protection")

Commit ceb5d58b2170 ("net: fix sock_wake_async() rcu protection") from
the current 4.4 release cycle introduces a new flags member in
struct socket_wq and moved SOCKWQ_ASYNC_NOSPACE and SOCKWQ_ASYNC_WAITDATA
from struct socket's flags member into that new place.

Unfortunately, the new flags field is never initialized properly, at least
not for the struct socket_wq instance created in sock_alloc_inode().

One particular issue I encountered because of this is that my GNU Emacs
failed to draw anything on my desktop -- i.e. what I got is a transparent
window, including the title bar. Bisection lead to the commit mentioned
above and further investigation by means of strace told me that Emacs
is indeed speaking to my Xorg through an O_ASYNC AF_UNIX socket. This is
reproducible 100% of times and the fact that properly initializing the
struct socket_wq ->flags fixes the issue leads me to the conclusion that
somehow SOCKWQ_ASYNC_NOSPACE got set in the uninitialized ->flags,
preventing my Emacs from receiving any SIGIO's due to send space becoming
available again and it got stuck.

Make sock_alloc_inode() set the newly created struct socket_wq's ->flags
member to zero.

Signed-off-by: Nicolai Stange <nicstange@gmail.com>
---
 net/socket.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/socket.c b/net/socket.c
index 29822d6..d730ef9 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -257,6 +257,7 @@ static struct inode *sock_alloc_inode(struct super_block *sb)
 	}
 	init_waitqueue_head(&wq->wait);
 	wq->fasync_list = NULL;
+	wq->flags = 0;
 	RCU_INIT_POINTER(ei->socket.wq, wq);
 
 	ei->socket.state = SS_UNCONNECTED;
-- 
2.6.4
