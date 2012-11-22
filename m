From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/9] tipc: wake up all waiting threads at socket shutdown
Date: Thu, 22 Nov 2012 15:59:48 -0500
Message-ID: <1353617994-3962-4-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ying Xue <ying.xue@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43150 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756260Ab2KVVAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:08 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When a socket is shut down, we should wake up all thread sleeping on
it, instead of just one of them. Otherwise, when several threads are
polling the same socket, and one of them does shutdown(), the
remaining threads may end up sleeping forever.

Also, to align socket usage with common practice in other stacks, we
use one of the common socket callback handlers, sk_state_change(),
to wake up pending users. This is similar to the usage in e.g.
inet_shutdown(). [net/ipv4/af_inet.c].

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 59adc76..1a720c8 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1595,10 +1595,11 @@ restart:
 
 	case SS_DISCONNECTING:
 
-		/* Discard any unreceived messages; wake up sleeping tasks */
+		/* Discard any unreceived messages */
 		discard_rx_queue(sk);
-		if (waitqueue_active(sk_sleep(sk)))
-			wake_up_interruptible(sk_sleep(sk));
+
+		/* Wake up anyone sleeping in poll */
+		sk->sk_state_change(sk);
 		res = 0;
 		break;
 
-- 
1.7.12.1
