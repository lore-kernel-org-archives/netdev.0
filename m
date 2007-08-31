From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK]: Avoid pointer in netlink_run_queue
Date: Fri, 31 Aug 2007 20:09:30 +0800
Message-ID: <20070831120930.GA29914@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1780 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964905AbXHaMJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 08:09:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NETLINK]: Avoid pointer in netlink_run_queue

I was looking at Patrick's fix to inet_diag and it occured
to me that we're using a pointer argument to return values
unnecessarily in netlink_run_queue.  Changing it to return
the value will allow the compiler to generate better code
since the value won't have to be memory-backed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/netlink.h b/include/net/netlink.h
index d7b824b..48071fa 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -220,7 +220,7 @@ struct nl_info {
 	u32			pid;
 };
 
-extern void		netlink_run_queue(struct sock *sk, unsigned int *qlen,
+extern unsigned int	netlink_run_queue(struct sock *sk, unsigned int qlen,
 					  int (*cb)(struct sk_buff *,
 						    struct nlmsghdr *));
 extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4756d58..15d13d9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1261,7 +1261,7 @@ static void rtnetlink_rcv(struct sock *sk, int len)
 
 	do {
 		mutex_lock(&rtnl_mutex);
-		netlink_run_queue(sk, &qlen, &rtnetlink_rcv_msg);
+		qlen = netlink_run_queue(sk, qlen, &rtnetlink_rcv_msg);
 		mutex_unlock(&rtnl_mutex);
 
 		netdev_run_todo();
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index dbeacd8..9cbc45e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -841,7 +841,7 @@ static void inet_diag_rcv(struct sock *sk, int len)
 	unsigned int qlen = 0;
 
 	do {
-		netlink_run_queue(sk, &qlen, &inet_diag_rcv_msg);
+		qlen = netlink_run_queue(sk, qlen, &inet_diag_rcv_msg);
 	} while (qlen);
 }
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 8797e69..25cb779 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -248,7 +248,7 @@ static void nfnetlink_rcv(struct sock *sk, int len)
 	do {
 		if (nfnl_trylock())
 			return;
-		netlink_run_queue(sk, &qlen, nfnetlink_rcv_msg);
+		qlen = netlink_run_queue(sk, qlen, nfnetlink_rcv_msg);
 		__nfnl_unlock();
 	} while (qlen);
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5681ce3..a9d1557 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1609,7 +1609,7 @@ skip:
 /**
  * nelink_run_queue - Process netlink receive queue.
  * @sk: Netlink socket containing the queue
- * @qlen: Place to store queue length upon entry
+ * @qlen: Initial queue length
  * @cb: Callback function invoked for each netlink message found
  *
  * Processes as much as there was in the queue upon entry and invokes
@@ -1619,35 +1619,37 @@ skip:
  * returns with a qlen != 0.
  *
  * qlen must be initialized to 0 before the initial entry, afterwards
- * the function may be called repeatedly until qlen reaches 0.
+ * the function may be called repeatedly until the returned qlen is 0.
  *
  * The callback function may return -EINTR to signal that processing
  * of netlink messages shall be interrupted. In this case the message
  * currently being processed will NOT be requeued onto the receive
  * queue.
  */
-void netlink_run_queue(struct sock *sk, unsigned int *qlen,
-		       int (*cb)(struct sk_buff *, struct nlmsghdr *))
+unsigned int netlink_run_queue(struct sock *sk, unsigned int qlen,
+			       int (*cb)(struct sk_buff *, struct nlmsghdr *))
 {
 	struct sk_buff *skb;
 
-	if (!*qlen || *qlen > skb_queue_len(&sk->sk_receive_queue))
-		*qlen = skb_queue_len(&sk->sk_receive_queue);
+	if (!qlen || qlen > skb_queue_len(&sk->sk_receive_queue))
+		qlen = skb_queue_len(&sk->sk_receive_queue);
 
-	for (; *qlen; (*qlen)--) {
+	for (; qlen; qlen--) {
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (netlink_rcv_skb(skb, cb)) {
 			if (skb->len)
 				skb_queue_head(&sk->sk_receive_queue, skb);
 			else {
 				kfree_skb(skb);
-				(*qlen)--;
+				qlen--;
 			}
 			break;
 		}
 
 		kfree_skb(skb);
 	}
+
+	return qlen;
 }
 
 /**
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 8c11ca4..d70d10d 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -485,7 +485,7 @@ static void genl_rcv(struct sock *sk, int len)
 	do {
 		if (genl_trylock())
 			return;
-		netlink_run_queue(sk, &qlen, genl_rcv_msg);
+		qlen = netlink_run_queue(sk, qlen, genl_rcv_msg);
 		genl_unlock();
 	} while (qlen && genl_sock && genl_sock->sk_receive_queue.qlen);
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 61339e1..6377cc0 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2033,7 +2033,7 @@ static void xfrm_netlink_rcv(struct sock *sk, int len)
 
 	do {
 		mutex_lock(&xfrm_cfg_mutex);
-		netlink_run_queue(sk, &qlen, &xfrm_user_rcv_msg);
+		qlen = netlink_run_queue(sk, qlen, &xfrm_user_rcv_msg);
 		mutex_unlock(&xfrm_cfg_mutex);
 
 	} while (qlen);
