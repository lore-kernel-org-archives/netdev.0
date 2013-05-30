From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/12] tipc: allow implicit connect for stream sockets
Date: Thu, 30 May 2013 15:36:08 -0400
Message-ID: <1369942577-39563-4-git-send-email-paul.gortmaker@windriver.com>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59123 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759645Ab3E3Tgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 15:36:35 -0400
In-Reply-To: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

TIPC's implied connect feature, aka piggyback connect, allows
applications to save one syscall and all SYN/SYN-ACK signalling
overhead when setting up a connection.  Until now, this has only
been supported for SEQPACKET sockets.  Here, we make it possible
to use this feature even with stream sockets.

At the connecting side, the connection is completed when the
first data message arrives from the accepting peer.  This means
that we must allow the connecting user to call blocking recv()
before the socket has reached state SS_CONNECTED.  So we must must
relax the state machine check at recv_stream(), and allow the
recv() call even if socket is in state SS_CONNECTING.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2dfabc7..10eba4d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -520,8 +520,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 			res = -EISCONN;
 			goto exit;
 		}
-		if ((tport->published) ||
-		    ((sock->type == SOCK_STREAM) && (total_len != 0))) {
+		if (tport->published) {
 			res = -EOPNOTSUPP;
 			goto exit;
 		}
@@ -1012,8 +1011,7 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 
 	lock_sock(sk);
 
-	if (unlikely((sock->state == SS_UNCONNECTED) ||
-		     (sock->state == SS_CONNECTING))) {
+	if (unlikely((sock->state == SS_UNCONNECTED))) {
 		res = -ENOTCONN;
 		goto exit;
 	}
-- 
1.8.1.2
