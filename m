From: <erik.hugne@ericsson.com>
Subject: [PATCH] tipc: flow control should not account for sk_rcvbuf
Date: Thu, 4 Oct 2012 11:14:27 +0200
Message-ID: <1349342067-27586-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:56214 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab2JDJOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 05:14:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The TIPC flow control is design around message count, and it should not
account for the sk_rcvbuf when enqueueing messages to the socket
receive queue.

This fixes a problem when the sk_add_backlog fails due to this check
and TIPC_ERR_OVERLOAD is reported back to the sender.
The sender would then drop it's side of the connection only, leaving
a stale connection on the other end.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/socket.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 09dc5b9..02fed90 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1269,10 +1269,8 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		if (sk_add_backlog(sk, buf, sk->sk_rcvbuf))
-			res = TIPC_ERR_OVERLOAD;
-		else
-			res = TIPC_OK;
+		__sk_add_backlog(sk, buf);
+		res = TIPC_OK;
 	}
 	bh_unlock_sock(sk);
 
-- 
1.7.5.4
