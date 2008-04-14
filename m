From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 2/7 net-2.6.26] [TIPC]: Allow stream receive to read from multiple TIPC messages
Date: Mon, 14 Apr 2008 17:16:29 -0400
Message-ID: <1208207794-2229-3-git-send-email-allan.stephens@windriver.com>
References: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55759 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762640AbYDNVSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:24 -0400
In-Reply-To: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows a stream socket to receive data from multiple
TIPC messages in its receive queue, without requiring the use of
the MSG_WAITALL flag.

Acknowledgements to Florian Westphal <fw-tipc@strlen.de> for
identifying this issue and suggesting how to correct it.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 91aa2dc..c1a199c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1065,7 +1065,9 @@ restart:
 	/* Loop around if more data is required */
 
 	if ((sz_copied < buf_len)    /* didn't get all requested data */
-	    && (flags & MSG_WAITALL) /* ... and need to wait for more */
+	    && (!skb_queue_empty(&sock->sk->sk_receive_queue) ||
+		(flags & MSG_WAITALL))
+				     /* ... and more is ready or required */
 	    && (!(flags & MSG_PEEK)) /* ... and aren't just peeking at data */
 	    && (!err)                /* ... and haven't reached a FIN */
 	    )
-- 
1.5.3.2

