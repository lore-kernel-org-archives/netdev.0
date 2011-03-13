From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/26] tipc: Add support for SO_RCVTIMEO socket option
Date: Sun, 13 Mar 2011 17:33:54 -0400
Message-ID: <1300052054-7531-7-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49873 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245Ab1CMVeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:37 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Adds support for the SO_RCVTIMEO socket option to TIPC's socket
receive routines.

Thanks go out to Raj Hegde <rajenhegde@yahoo.ca> for his contribution
to the development and testing this enhancement.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d45a294..29d94d5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -58,6 +58,9 @@ struct tipc_sock {
 #define tipc_sk(sk) ((struct tipc_sock *)(sk))
 #define tipc_sk_port(sk) ((struct tipc_port *)(tipc_sk(sk)->p))
 
+#define tipc_rx_ready(sock) (!skb_queue_empty(&sock->sk->sk_receive_queue) || \
+			(sock->state == SS_DISCONNECTING))
+
 static int backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf);
 static void wakeupdispatch(struct tipc_port *tport);
@@ -911,6 +914,7 @@ static int recv_msg(struct kiocb *iocb, struct socket *sock,
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
+	long timeout;
 	unsigned int sz;
 	u32 err;
 	int res;
@@ -927,6 +931,7 @@ static int recv_msg(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
+	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
@@ -936,17 +941,15 @@ restart:
 			res = -ENOTCONN;
 			goto exit;
 		}
-		if (flags & MSG_DONTWAIT) {
-			res = -EWOULDBLOCK;
+		if (timeout <= 0L) {
+			res = timeout ? timeout : -EWOULDBLOCK;
 			goto exit;
 		}
 		release_sock(sk);
-		res = wait_event_interruptible(*sk_sleep(sk),
-			(!skb_queue_empty(&sk->sk_receive_queue) ||
-			 (sock->state == SS_DISCONNECTING)));
+		timeout = wait_event_interruptible_timeout(*sk_sleep(sk),
+							   tipc_rx_ready(sock),
+							   timeout);
 		lock_sock(sk);
-		if (res)
-			goto exit;
 	}
 
 	/* Look at first message in receive queue */
@@ -1034,6 +1037,7 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
+	long timeout;
 	unsigned int sz;
 	int sz_to_copy, target, needed;
 	int sz_copied = 0;
@@ -1054,7 +1058,7 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 	}
 
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, buf_len);
-
+	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
@@ -1064,17 +1068,15 @@ restart:
 			res = -ENOTCONN;
 			goto exit;
 		}
-		if (flags & MSG_DONTWAIT) {
-			res = -EWOULDBLOCK;
+		if (timeout <= 0L) {
+			res = timeout ? timeout : -EWOULDBLOCK;
 			goto exit;
 		}
 		release_sock(sk);
-		res = wait_event_interruptible(*sk_sleep(sk),
-			(!skb_queue_empty(&sk->sk_receive_queue) ||
-			 (sock->state == SS_DISCONNECTING)));
+		timeout = wait_event_interruptible_timeout(*sk_sleep(sk),
+							   tipc_rx_ready(sock),
+							   timeout);
 		lock_sock(sk);
-		if (res)
-			goto exit;
 	}
 
 	/* Look at first message in receive queue */
-- 
1.7.3.3

