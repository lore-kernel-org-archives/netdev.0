From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-2.6.26] [TIPC]: Cosmetic cleanup of TIPC polling logic
Date: Wed, 26 Mar 2008 17:02:39 -0400
Message-ID: <1206565359-14538-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56262 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140AbYCZVUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 17:20:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates an unnecessary poll-related routine
by merging it into TIPC's main polling routine, and updates
the comments associated with this code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |   78 ++++++++++++++++++++++++----------------------------
 1 files changed, 36 insertions(+), 42 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ae45df0..1b5fb61 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -102,44 +102,6 @@ static void sock_unlock(struct tipc_sock* tsock)
 }
 
 /**
- * pollmask - determine the current set of poll() events for a socket
- * @sock: socket structure
- *
- * TIPC sets the returned events as follows:
- * a) POLLRDNORM and POLLIN are set if the socket's receive queue is non-empty
- *    or if a connection-oriented socket is does not have an active connection
- *    (i.e. a read operation will not block).
- * b) POLLOUT is set except when a socket's connection has been terminated
- *    (i.e. a write operation will not block).
- * c) POLLHUP is set when a socket's connection has been terminated.
- *
- * IMPORTANT: The fact that a read or write operation will not block does NOT
- * imply that the operation will succeed!
- *
- * Returns pollmask value
- */
-
-static u32 pollmask(struct socket *sock)
-{
-	u32 mask;
-
-	if ((skb_queue_len(&sock->sk->sk_receive_queue) != 0) ||
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
-
-	return mask;
-}
-
-
-/**
  * advance_queue - discard first buffer in queue
  * @tsock: TIPC socket
  */
@@ -390,15 +352,47 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
  * @sock: socket for which to calculate the poll bits
  * @wait: ???
  *
- * Returns the pollmask
+ * Returns pollmask value
+ *
+ * COMMENTARY:
+ * It appears that the usual socket locking mechanisms are not useful here
+ * since the pollmask info is potentially out-of-date the moment this routine
+ * exits.  TCP and other protocols seem to rely on higher level poll routines
+ * to handle any preventable race conditions, so TIPC will do the same ...
+ *
+ * TIPC sets the returned events as follows:
+ * a) POLLRDNORM and POLLIN are set if the socket's receive queue is non-empty
+ *    or if a connection-oriented socket is does not have an active connection
+ *    (i.e. a read operation will not block).
+ * b) POLLOUT is set except when a socket's connection has been terminated
+ *    (i.e. a write operation will not block).
+ * c) POLLHUP is set when a socket's connection has been terminated.
+ *
+ * IMPORTANT: The fact that a read or write operation will not block does NOT
+ * imply that the operation will succeed!
  */
 
 static unsigned int poll(struct file *file, struct socket *sock,
 			 poll_table *wait)
 {
-	poll_wait(file, sock->sk->sk_sleep, wait);
-	/* NEED LOCK HERE? */
-	return pollmask(sock);
+	struct sock *sk = sock->sk;
+	u32 mask;
+
+	poll_wait(file, sk->sk_sleep, wait);
+
+	if (!skb_queue_empty(&sk->sk_receive_queue) ||
+	    (sock->state == SS_UNCONNECTED) ||
+	    (sock->state == SS_DISCONNECTING))
+		mask = (POLLRDNORM | POLLIN);
+	else
+		mask = 0;
+
+	if (sock->state == SS_DISCONNECTING)
+		mask |= POLLHUP;
+	else
+		mask |= POLLOUT;
+
+	return mask;
 }
 
 /**
-- 
1.5.3.2

