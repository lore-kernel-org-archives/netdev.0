From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/5] af_unix: Move CINQ/COUTQ code to helpers
Date: Thu, 29 Dec 2011 18:14:30 +0400
Message-ID: <4EFC75C6.8020801@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28707 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab1L2OOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 09:14:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tcp diag reports rqlen and wqlen values similar to how
the CINQ/COUTQ iotcls do. To make unix diag report these values 
in the same way move the respective code into helpers.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/net/af_unix.h |    3 ++
 net/unix/af_unix.c    |   59 +++++++++++++++++++++++++++++-------------------
 2 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 63b1781..5a4e29b 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -66,6 +66,9 @@ struct unix_sock {
 
 #define peer_wait peer_wq.wait
 
+long unix_inq_len(struct sock *sk);
+long unix_outq_len(struct sock *sk);
+
 #ifdef CONFIG_SYSCTL
 extern int unix_sysctl_register(struct net *net);
 extern void unix_sysctl_unregister(struct net *net);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e1b9358..f7ee7db 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2065,6 +2065,36 @@ static int unix_shutdown(struct socket *sock, int mode)
 	return 0;
 }
 
+long unix_inq_len(struct sock *sk)
+{
+	struct sk_buff *skb;
+	long amount = 0;
+
+	if (sk->sk_state == TCP_LISTEN)
+		return -EINVAL;
+
+	spin_lock(&sk->sk_receive_queue.lock);
+	if (sk->sk_type == SOCK_STREAM ||
+			sk->sk_type == SOCK_SEQPACKET) {
+		skb_queue_walk(&sk->sk_receive_queue, skb)
+			amount += skb->len;
+	} else {
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb)
+			amount = skb->len;
+	}
+	spin_unlock(&sk->sk_receive_queue.lock);
+
+	return amount;
+}
+EXPORT_SYMBOL_GPL(unix_inq_len);
+
+long unix_outq_len(struct sock *sk)
+{
+	return sk_wmem_alloc_get(sk);
+}
+EXPORT_SYMBOL_GPL(unix_outq_len);
+
 static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
@@ -2073,33 +2103,16 @@ static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	switch (cmd) {
 	case SIOCOUTQ:
-		amount = sk_wmem_alloc_get(sk);
+		amount = unix_outq_len(sk);
 		err = put_user(amount, (int __user *)arg);
 		break;
 	case SIOCINQ:
-		{
-			struct sk_buff *skb;
-
-			if (sk->sk_state == TCP_LISTEN) {
-				err = -EINVAL;
-				break;
-			}
-
-			spin_lock(&sk->sk_receive_queue.lock);
-			if (sk->sk_type == SOCK_STREAM ||
-			    sk->sk_type == SOCK_SEQPACKET) {
-				skb_queue_walk(&sk->sk_receive_queue, skb)
-					amount += skb->len;
-			} else {
-				skb = skb_peek(&sk->sk_receive_queue);
-				if (skb)
-					amount = skb->len;
-			}
-			spin_unlock(&sk->sk_receive_queue.lock);
+		amount = unix_inq_len(sk);
+		if (amount < 0)
+			err = amount;
+		else
 			err = put_user(amount, (int __user *)arg);
-			break;
-		}
-
+		break;
 	default:
 		err = -ENOIOCTLCMD;
 		break;
-- 
1.5.5.6
