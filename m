From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/3] tipc: eliminate duplicated discard_rx_queue routine
Date: Fri, 15 Feb 2013 17:57:45 -0500
Message-ID: <1360969067-29956-2-git-send-email-paul.gortmaker@windriver.com>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38737 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab3BOW6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 17:58:32 -0500
In-Reply-To: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

The tipc function discard_rx_queue() is just a duplicated
implementation of __skb_queue_purge().  Remove the former
and directly invoke __skb_queue_purge().

In doing so, the underscores convey to the code reader, more
information about the current locking state that is assumed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9b4e483..f6ceecd 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -129,19 +129,6 @@ static void advance_rx_queue(struct sock *sk)
 }
 
 /**
- * discard_rx_queue - discard all buffers in socket receive queue
- *
- * Caller must hold socket lock
- */
-static void discard_rx_queue(struct sock *sk)
-{
-	struct sk_buff *buf;
-
-	while ((buf = __skb_dequeue(&sk->sk_receive_queue)))
-		kfree_skb(buf);
-}
-
-/**
  * reject_rx_queue - reject all buffers in socket receive queue
  *
  * Caller must hold socket lock
@@ -292,7 +279,7 @@ static int release(struct socket *sock)
 	res = tipc_deleteport(tport->ref);
 
 	/* Discard any remaining (connection-based) messages in receive queue */
-	discard_rx_queue(sk);
+	__skb_queue_purge(&sk->sk_receive_queue);
 
 	/* Reject any messages that accumulated in backlog queue */
 	sock->state = SS_DISCONNECTING;
@@ -1637,7 +1624,7 @@ restart:
 	case SS_DISCONNECTING:
 
 		/* Discard any unreceived messages */
-		discard_rx_queue(sk);
+		__skb_queue_purge(&sk->sk_receive_queue);
 
 		/* Wake up anyone sleeping in poll */
 		sk->sk_state_change(sk);
-- 
1.8.1.2
