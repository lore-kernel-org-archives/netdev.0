From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 01/11] netlink: add symbolic value for congested state
Date: Mon, 20 Aug 2012 08:18:42 +0200
Message-ID: <1345443532-3707-2-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5463969..1bdfa52 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -89,6 +89,10 @@ struct listeners {
 	unsigned long		masks[0];
 };
 
+/* state bits */
+#define NETLINK_CONGESTED	0x0
+
+/* flags */
 #define NETLINK_KERNEL_SOCKET	0x1
 #define NETLINK_RECV_PKTINFO	0x2
 #define NETLINK_BROADCAST_SEND_ERROR	0x4
@@ -762,7 +766,7 @@ static void netlink_overrun(struct sock *sk)
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
-		if (!test_and_set_bit(0, &nlk_sk(sk)->state)) {
+		if (!test_and_set_bit(NETLINK_CONGESTED, &nlk_sk(sk)->state)) {
 			sk->sk_err = ENOBUFS;
 			sk->sk_error_report(sk);
 		}
@@ -823,7 +827,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 	nlk = nlk_sk(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    test_bit(0, &nlk->state)) {
+	    test_bit(NETLINK_CONGESTED, &nlk->state)) {
 		DECLARE_WAITQUEUE(wait, current);
 		if (!*timeo) {
 			if (!ssk || netlink_is_kernel(ssk))
@@ -837,7 +841,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		add_wait_queue(&nlk->wait, &wait);
 
 		if ((atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-		     test_bit(0, &nlk->state)) &&
+		     test_bit(NETLINK_CONGESTED, &nlk->state)) &&
 		    !sock_flag(sk, SOCK_DEAD))
 			*timeo = schedule_timeout(*timeo);
 
@@ -907,8 +911,8 @@ static void netlink_rcv_wake(struct sock *sk)
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (skb_queue_empty(&sk->sk_receive_queue))
-		clear_bit(0, &nlk->state);
-	if (!test_bit(0, &nlk->state))
+		clear_bit(NETLINK_CONGESTED, &nlk->state);
+	if (!test_bit(NETLINK_CONGESTED, &nlk->state))
 		wake_up_interruptible(&nlk->wait);
 }
 
@@ -990,7 +994,7 @@ static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
-	    !test_bit(0, &nlk->state)) {
+	    !test_bit(NETLINK_CONGESTED, &nlk->state)) {
 		skb_set_owner_r(skb, sk);
 		__netlink_sendskb(sk, skb);
 		return atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1);
@@ -1270,7 +1274,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 	case NETLINK_NO_ENOBUFS:
 		if (val) {
 			nlk->flags |= NETLINK_RECV_NO_ENOBUFS;
-			clear_bit(0, &nlk->state);
+			clear_bit(NETLINK_CONGESTED, &nlk->state);
 			wake_up_interruptible(&nlk->wait);
 		} else {
 			nlk->flags &= ~NETLINK_RECV_NO_ENOBUFS;
-- 
1.7.7.6

