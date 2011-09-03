From: kaber@trash.net
Subject: [PATCH 01/11] netlink: add symbolic value for congested state
Date: Sat,  3 Sep 2011 19:26:01 +0200
Message-ID: <1315070771-18576-2-git-send-email-kaber@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56159 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348Ab1ICR0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 13:26:19 -0400
In-Reply-To: <1315070771-18576-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0a4db02..fc63ca5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -88,6 +88,10 @@ struct listeners {
 	unsigned long		masks[0];
 };
 
+/* state bits */
+#define NETLINK_CONGESTED	0x0
+
+/* flags */
 #define NETLINK_KERNEL_SOCKET	0x1
 #define NETLINK_RECV_PKTINFO	0x2
 #define NETLINK_BROADCAST_SEND_ERROR	0x4
@@ -737,7 +741,7 @@ static void netlink_overrun(struct sock *sk)
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
-		if (!test_and_set_bit(0, &nlk_sk(sk)->state)) {
+		if (!test_and_set_bit(NETLINK_CONGESTED, &nlk_sk(sk)->state)) {
 			sk->sk_err = ENOBUFS;
 			sk->sk_error_report(sk);
 		}
@@ -798,7 +802,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 	nlk = nlk_sk(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    test_bit(0, &nlk->state)) {
+	    test_bit(NETLINK_CONGESTED, &nlk->state)) {
 		DECLARE_WAITQUEUE(wait, current);
 		if (!*timeo) {
 			if (!ssk || netlink_is_kernel(ssk))
@@ -812,7 +816,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		add_wait_queue(&nlk->wait, &wait);
 
 		if ((atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-		     test_bit(0, &nlk->state)) &&
+		     test_bit(NETLINK_CONGESTED, &nlk->state)) &&
 		    !sock_flag(sk, SOCK_DEAD))
 			*timeo = schedule_timeout(*timeo);
 
@@ -876,8 +880,8 @@ static inline void netlink_rcv_wake(struct sock *sk)
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (skb_queue_empty(&sk->sk_receive_queue))
-		clear_bit(0, &nlk->state);
-	if (!test_bit(0, &nlk->state))
+		clear_bit(NETLINK_CONGESTED, &nlk->state);
+	if (!test_bit(NETLINK_CONGESTED, &nlk->state))
 		wake_up_interruptible(&nlk->wait);
 }
 
@@ -958,7 +962,7 @@ static inline int netlink_broadcast_deliver(struct sock *sk,
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
-	    !test_bit(0, &nlk->state)) {
+	    !test_bit(NETLINK_CONGESTED, &nlk->state)) {
 		skb_set_owner_r(skb, sk);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);
@@ -1236,7 +1240,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 	case NETLINK_NO_ENOBUFS:
 		if (val) {
 			nlk->flags |= NETLINK_RECV_NO_ENOBUFS;
-			clear_bit(0, &nlk->state);
+			clear_bit(NETLINK_CONGESTED, &nlk->state);
 			wake_up_interruptible(&nlk->wait);
 		} else
 			nlk->flags &= ~NETLINK_RECV_NO_ENOBUFS;
-- 
1.7.4.4
