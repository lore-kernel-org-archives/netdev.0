From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 4/7 net-2.6.26] [TIPC]: Correct "off by 1" error in socket queue limit enforcement
Date: Mon, 14 Apr 2008 17:16:31 -0400
Message-ID: <1208207794-2229-5-git-send-email-allan.stephens@windriver.com>
References: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55778 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762644AbYDNVSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:25 -0400
In-Reply-To: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug that allowed TIPC to queue 1 more message
than allowed by the socket receive queue threshold limits.  The
patch also improves the threshold code's logic and naming to help
prevent this sort of error from recurring in the future.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ead22e5..4c83aba 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1079,15 +1079,15 @@ exit:
 }
 
 /**
- * queue_overloaded - test if queue overload condition exists
+ * rx_queue_full - determine if receive queue can accept another message
+ * @msg: message to be added to queue
  * @queue_size: current size of queue
  * @base: nominal maximum size of queue
- * @msg: message to be added to queue
  *
- * Returns 1 if queue is currently overloaded, 0 otherwise
+ * Returns 1 if queue is unable to accept message, 0 otherwise
  */
 
-static int queue_overloaded(u32 queue_size, u32 base, struct tipc_msg *msg)
+static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
 {
 	u32 threshold;
 	u32 imp = msg_importance(msg);
@@ -1104,7 +1104,7 @@ static int queue_overloaded(u32 queue_size, u32 base, struct tipc_msg *msg)
 	if (msg_connected(msg))
 		threshold *= 4;
 
-	return (queue_size > threshold);
+	return (queue_size >= threshold);
 }
 
 /**
@@ -1189,16 +1189,14 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 
 	/* Reject message if there isn't room to queue it */
 
-	if (unlikely((u32)atomic_read(&tipc_queue_size) >
-		     OVERLOAD_LIMIT_BASE)) {
-		if (queue_overloaded(atomic_read(&tipc_queue_size),
-				     OVERLOAD_LIMIT_BASE, msg))
+	recv_q_len = (u32)atomic_read(&tipc_queue_size);
+	if (unlikely(recv_q_len >= OVERLOAD_LIMIT_BASE)) {
+		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE))
 			return TIPC_ERR_OVERLOAD;
 	}
 	recv_q_len = skb_queue_len(&tsock->sk.sk_receive_queue);
-	if (unlikely(recv_q_len > (OVERLOAD_LIMIT_BASE / 2))) {
-		if (queue_overloaded(recv_q_len,
-				     OVERLOAD_LIMIT_BASE / 2, msg))
+	if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
+		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE / 2))
 			return TIPC_ERR_OVERLOAD;
 	}
 
-- 
1.5.3.2

