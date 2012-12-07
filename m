From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/10] tipc: sk_recv_queue size check only for connectionless sockets
Date: Fri, 7 Dec 2012 09:28:11 -0500
Message-ID: <1354890498-6448-4-git-send-email-paul.gortmaker@windriver.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62562 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030741Ab2LGO2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:28:34 -0500
In-Reply-To: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

The sk_receive_queue limit control is currently performed for
all arriving messages, disregarding socket and message type.
But for connected sockets this check is redundant, since the protocol
flow control already makes queue overflow impossible.

We move the sk_receive_queue limit control so that it is only performed
for connectionless sockets, i.e. SOCK_RDM and SOCK_DGRAM type sockets.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index a059ed0..4d6a448 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1188,9 +1188,6 @@ static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
 	else
 		return 0;
 
-	if (msg_connected(msg))
-		threshold *= 4;
-
 	return queue_size >= threshold;
 }
 
@@ -1219,6 +1216,15 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	if (sock->state == SS_READY) {
 		if (msg_connected(msg))
 			return TIPC_ERR_NO_PORT;
+		/* Reject SOCK_DGRAM and SOCK_RDM messages if there isn't room
+		 * to queue it.
+		 */
+		recv_q_len = skb_queue_len(&sk->sk_receive_queue);
+		if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
+			if (rx_queue_full(msg, recv_q_len,
+			    OVERLOAD_LIMIT_BASE / 2))
+				return TIPC_ERR_OVERLOAD;
+		}
 	} else {
 		if (msg_mcast(msg))
 			return TIPC_ERR_NO_PORT;
@@ -1240,13 +1246,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 		}
 	}
 
-	/* Reject message if there isn't room to queue it */
-	recv_q_len = skb_queue_len(&sk->sk_receive_queue);
-	if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
-		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE / 2))
-			return TIPC_ERR_OVERLOAD;
-	}
-
 	/* Enqueue message (finally!) */
 	TIPC_SKB_CB(buf)->handle = 0;
 	atomic_inc(&tipc_queue_size);
-- 
1.7.12.1
