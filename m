From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/14] tipc: correct problems with misleading flags returned using poll()
Date: Tue, 17 Aug 2010 17:00:06 -0400
Message-ID: <1282078816-11844-5-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57120 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab0HQVAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:23 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Prevent TIPC from incorrectly setting returned flags to poll()
in the following cases:

- an unconnected socket no longer indicates that it is always readable

- an unconnected, connecting, or listening socket no longer indicates
  that it is always writable

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   61 ++++++++++++++++++++++++++++++++++------------------
 1 files changed, 40 insertions(+), 21 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b89c7b1..7b81fdd 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -429,36 +429,55 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
  * to handle any preventable race conditions, so TIPC will do the same ...
  *
  * TIPC sets the returned events as follows:
- * a) POLLRDNORM and POLLIN are set if the socket's receive queue is non-empty
- *    or if a connection-oriented socket is does not have an active connection
- *    (i.e. a read operation will not block).
- * b) POLLOUT is set except when a socket's connection has been terminated
- *    (i.e. a write operation will not block).
- * c) POLLHUP is set when a socket's connection has been terminated.
- *
- * IMPORTANT: The fact that a read or write operation will not block does NOT
- * imply that the operation will succeed!
+ *
+ * socket state		flags set
+ * ------------		---------
+ * unconnected		no read flags
+ *			no write flags
+ *
+ * connecting		POLLIN/POLLRDNORM if ACK/NACK in rx queue
+ *			no write flags
+ *
+ * connected		POLLIN/POLLRDNORM if data in rx queue
+ *			POLLOUT if port is not congested
+ *
+ * disconnecting	POLLIN/POLLRDNORM/POLLHUP
+ *			no write flags
+ *
+ * listening		POLLIN if SYN in rx queue
+ *			no write flags
+ *
+ * ready		POLLIN/POLLRDNORM if data in rx queue
+ * [connectionless]	POLLOUT (since port cannot be congested)
+ *
+ * IMPORTANT: The fact that a read or write operation is indicated does NOT
+ * imply that the operation will succeed, merely that it should be performed
+ * and will not block.
  */
 
 static unsigned int poll(struct file *file, struct socket *sock,
 			 poll_table *wait)
 {
 	struct sock *sk = sock->sk;
-	u32 mask;
+	u32 mask = 0;
 
 	poll_wait(file, sk_sleep(sk), wait);
 
-	if (!skb_queue_empty(&sk->sk_receive_queue) ||
-	    (sock->state == SS_UNCONNECTED) ||
-	    (sock->state == SS_DISCONNECTING))
-		mask = (POLLRDNORM | POLLIN);
-	else
-		mask = 0;
-
-	if (sock->state == SS_DISCONNECTING)
-		mask |= POLLHUP;
-	else
-		mask |= POLLOUT;
+	switch ((int)sock->state) {
+	case SS_READY:
+	case SS_CONNECTED:
+		if (!tipc_sk_port(sk)->congested)
+			mask |= POLLOUT;
+		/* fall thru' */
+	case SS_CONNECTING:
+	case SS_LISTENING:
+		if (!skb_queue_empty(&sk->sk_receive_queue))
+			mask |= (POLLIN | POLLRDNORM);
+		break;
+	case SS_DISCONNECTING:
+		mask = (POLLIN | POLLRDNORM | POLLHUP);
+		break;
+	}
 
 	return mask;
 }
-- 
1.7.2.1

