From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: poll() optimizations
Date: Mon, 06 Sep 2010 23:13:50 +0200
Message-ID: <1283807630.2585.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56709 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab0IFVNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 17:13:55 -0400
Received: by wwj40 with SMTP id 40so7090838wwj.1
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 14:13:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to test twice sk->sk_shutdown & RCV_SHUTDOWN

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/bluetooth/af_bluetooth.c |    5 ++---
 net/core/datagram.c          |    5 ++---
 net/sctp/socket.c            |    5 ++---
 net/unix/af_unix.c           |    5 ++---
 4 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 421c45b..ed0f22f 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -297,13 +297,12 @@ unsigned int bt_sock_poll(struct file * file, struct socket *sock, poll_table *w
 		mask |= POLLERR;
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
-		mask |= POLLRDHUP;
+		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
 		mask |= POLLHUP;
 
-	if (!skb_queue_empty(&sk->sk_receive_queue) ||
-			(sk->sk_shutdown & RCV_SHUTDOWN))
+	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sk->sk_state == BT_CLOSED)
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 251997a..4df1b7a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -746,13 +746,12 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR;
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
-		mask |= POLLRDHUP;
+		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
 		mask |= POLLHUP;
 
 	/* readable? */
-	if (!skb_queue_empty(&sk->sk_receive_queue) ||
-	    (sk->sk_shutdown & RCV_SHUTDOWN))
+	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
 
 	/* Connection-based need to check for termination and startup */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f4bec27..cf6dcc9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5707,13 +5707,12 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR;
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
-		mask |= POLLRDHUP;
+		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
 		mask |= POLLHUP;
 
 	/* Is it readable?  Reconsider this code with TCP-style support.  */
-	if (!skb_queue_empty(&sk->sk_receive_queue) ||
-	    (sk->sk_shutdown & RCV_SHUTDOWN))
+	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
 
 	/* The association is either gone or not ready.  */
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4414a18..9077b4e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2024,11 +2024,10 @@ static unsigned int unix_poll(struct file *file, struct socket *sock, poll_table
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
 		mask |= POLLHUP;
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
-		mask |= POLLRDHUP;
+		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 
 	/* readable? */
-	if (!skb_queue_empty(&sk->sk_receive_queue) ||
-	    (sk->sk_shutdown & RCV_SHUTDOWN))
+	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
 
 	/* Connection-based need to check for termination and startup */


