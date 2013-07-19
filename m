From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/2] Provide a generic socket error queue delivery method for Tx time stamps.
Date: Fri, 19 Jul 2013 19:40:09 +0200
Message-ID: <9d6cea3f2ac73f0bf174a8f9d57ea13375fb1790.1374254758.git.richardcochran@gmail.com>
References: <cover.1374254757.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50872 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab3GSRkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 13:40:25 -0400
Received: by mail-ee0-f46.google.com with SMTP id d41so2509989eek.5
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 10:40:24 -0700 (PDT)
In-Reply-To: <cover.1374254757.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the private error queue delivery function from the
af_packet code to the core socket method. In this way, network layers
only needing the error queue for transmit time stamping can share common
code.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 include/net/sock.h     |    2 ++
 net/core/sock.c        |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c |   48 ++----------------------------------------------
 3 files changed, 51 insertions(+), 46 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 95a5a2c..e0473f6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2249,6 +2249,8 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
+extern int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
+			      int level, int type);
 
 /*
  *	Enable debug/info messages
diff --git a/net/core/sock.c b/net/core/sock.c
index 548d716..85e8de1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -93,6 +93,7 @@
 
 #include <linux/capability.h>
 #include <linux/errno.h>
+#include <linux/errqueue.h>
 #include <linux/types.h>
 #include <linux/socket.h>
 #include <linux/in.h>
@@ -2425,6 +2426,52 @@ void sock_enable_timestamp(struct sock *sk, int flag)
 	}
 }
 
+int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
+		       int level, int type)
+{
+	struct sock_exterr_skb *serr;
+	struct sk_buff *skb, *skb2;
+	int copied, err;
+
+	err = -EAGAIN;
+	skb = skb_dequeue(&sk->sk_error_queue);
+	if (skb == NULL)
+		goto out;
+
+	copied = skb->len;
+	if (copied > len) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto out_free_skb;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	serr = SKB_EXT_ERR(skb);
+	put_cmsg(msg, level, type, sizeof(serr->ee), &serr->ee);
+
+	msg->msg_flags |= MSG_ERRQUEUE;
+	err = copied;
+
+	/* Reset and regenerate socket error */
+	spin_lock_bh(&sk->sk_error_queue.lock);
+	sk->sk_err = 0;
+	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
+		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
+		spin_unlock_bh(&sk->sk_error_queue.lock);
+		sk->sk_error_report(sk);
+	} else
+		spin_unlock_bh(&sk->sk_error_queue.lock);
+
+out_free_skb:
+	kfree_skb(skb);
+out:
+	return err;
+}
+EXPORT_SYMBOL(sock_recv_errqueue);
+
 /*
  *	Get a socket option on an socket.
  *
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4b66c75..4cb28a7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2638,51 +2638,6 @@ out:
 	return err;
 }
 
-static int packet_recv_error(struct sock *sk, struct msghdr *msg, int len)
-{
-	struct sock_exterr_skb *serr;
-	struct sk_buff *skb, *skb2;
-	int copied, err;
-
-	err = -EAGAIN;
-	skb = skb_dequeue(&sk->sk_error_queue);
-	if (skb == NULL)
-		goto out;
-
-	copied = skb->len;
-	if (copied > len) {
-		msg->msg_flags |= MSG_TRUNC;
-		copied = len;
-	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
-	if (err)
-		goto out_free_skb;
-
-	sock_recv_timestamp(msg, sk, skb);
-
-	serr = SKB_EXT_ERR(skb);
-	put_cmsg(msg, SOL_PACKET, PACKET_TX_TIMESTAMP,
-		 sizeof(serr->ee), &serr->ee);
-
-	msg->msg_flags |= MSG_ERRQUEUE;
-	err = copied;
-
-	/* Reset and regenerate socket error */
-	spin_lock_bh(&sk->sk_error_queue.lock);
-	sk->sk_err = 0;
-	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
-		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-		sk->sk_error_report(sk);
-	} else
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-
-out_free_skb:
-	kfree_skb(skb);
-out:
-	return err;
-}
-
 /*
  *	Pull a packet from our receive queue and hand it to the user.
  *	If necessary we block.
@@ -2708,7 +2663,8 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 #endif
 
 	if (flags & MSG_ERRQUEUE) {
-		err = packet_recv_error(sk, msg, len);
+		err = sock_recv_errqueue(sk, msg, len,
+					 SOL_PACKET, PACKET_TX_TIMESTAMP);
 		goto out;
 	}
 
-- 
1.7.10.4
