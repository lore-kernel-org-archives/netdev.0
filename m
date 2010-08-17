From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/14] tipc: add SO_RCVLOWAT support to stream socket receive path
Date: Tue, 17 Aug 2010 17:00:04 -0400
Message-ID: <1282078816-11844-3-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57114 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab0HQVAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:23 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Add support for the SO_RCVLOWAT socket option to TIPC's stream socket
type.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 66e889b..69d0fd1 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1026,9 +1026,8 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
 	unsigned int sz;
-	int sz_to_copy;
+	int sz_to_copy, target, needed;
 	int sz_copied = 0;
-	int needed;
 	char __user *crs = m->msg_iov->iov_base;
 	unsigned char *buf_crs;
 	u32 err;
@@ -1050,6 +1049,8 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, buf_len);
+
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
@@ -1138,7 +1139,7 @@ restart:
 
 	if ((sz_copied < buf_len) &&	/* didn't get all requested data */
 	    (!skb_queue_empty(&sk->sk_receive_queue) ||
-	     (flags & MSG_WAITALL)) &&	/* and more is ready or required */
+	    (sz_copied < target)) &&	/* and more is ready or required */
 	    (!(flags & MSG_PEEK)) &&	/* and aren't just peeking at data */
 	    (!err))			/* and haven't reached a FIN */
 		goto restart;
-- 
1.7.2.1

