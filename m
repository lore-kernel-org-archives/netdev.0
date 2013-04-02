From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [net-next PATCH] net: fix smatch warnings inside datagram_poll
Date: Tue,  2 Apr 2013 13:34:15 -0700
Message-ID: <20130402203414.24602.6059.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:12147 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760329Ab3DBUe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 16:34:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for commit 1218a2a1d233fd604a41e584163ec291418f8ea8 actually turns out
to be incorrect. This fixes the *_poll functions to work properly. The old code
results in "mask |= POLLPRI" instead of what was intended, due to incorrect
assumption about operator precedence.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 net/bluetooth/af_bluetooth.c |    2 +-
 net/core/datagram.c          |    2 +-
 net/iucv/af_iucv.c           |    2 +-
 net/nfc/llcp/sock.c          |    2 +-
 net/unix/af_unix.c           |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 409902f..fea778e 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -423,7 +423,7 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock,
 
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR |
-			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 36da5b6..ebba65d 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -750,7 +750,7 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 	/* exceptional events? */
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR |
-			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index f0550a3..7dfb9ed 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1462,7 +1462,7 @@ unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR |
-			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP;
diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 2d55e8a..6b32544 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -522,7 +522,7 @@ static unsigned int llcp_sock_poll(struct file *file, struct socket *sock,
 
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR |
-			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 2d2ccf8..b0dc7c2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2198,7 +2198,7 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	/* exceptional events? */
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR |
-			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
