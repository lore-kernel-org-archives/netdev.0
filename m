From: Nicolai Stange <nicstange@gmail.com>
Subject: [PATCH v2] net, socket, socket_wq: fix missing initialization of flags
Date: Tue, 29 Dec 2015 13:29:55 +0100
Message-ID: <87ziwtphdo.fsf_-_@gmail.com>
References: <87ege73bma.fsf@gmail.com>
	<1451323186.8255.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nicolai Stange <nicstange@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451323186.8255.5.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 28 Dec 2015 12:19:46 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes: ceb5d58b2170 ("net: fix sock_wake_async() rcu protection")

Commit ceb5d58b2170 ("net: fix sock_wake_async() rcu protection") from
the current 4.4 release cycle introduced a new flags member in
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
somehow SOCKWQ_ASYNC_WAITDATA got set in the uninitialized ->flags,
preventing my Emacs from receiving any SIGIO's due to data becoming
available and it got stuck.

Make sock_alloc_inode() set the newly created struct socket_wq's ->flags
member to zero.

Signed-off-by: Nicolai Stange <nicstange@gmail.com>
---
 Changes to V1 (only commit message changes):
 - Uhm, I misread sock_wake_async(). The meaning of the flags is actually
   inverted. My Ghostmacs wasn't waiting for free send space, but some
   received data becoming available. This makes indeed more sense and I
   replaced "SOCKWQ_ASYNC_NOSPACE" by "SOCKWQ_ASYNC_WAITDATA" in my
   speculative explanation above.
 - Furthermore I fixed some minor grammar issues.

 Sorry for any inconvenience this late-night induced brainfart might
 have caused at your side...

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
