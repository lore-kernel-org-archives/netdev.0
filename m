From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 6/7] netlink: rename private flags and states
Date: Thu,  7 May 2015 11:02:52 +0200
Message-ID: <1430989373-4515-7-git-send-email-nicolas.dichtel@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: tgraf@suug.ch, davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43512 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbEGJDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 05:03:06 -0400
In-Reply-To: <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These flags and states have the same prefix (NETLINK_) that netlink socket
options. To avoid confusion and to be able to name a flag like a socket
option, let's use an other prefix: NETLINK_[S|F]_.

Note: a comment has been fixed, it was talking about
NETLINK_RECV_NO_ENOBUFS socket option instead of NETLINK_NO_ENOBUFS.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: new in this series

 net/netlink/af_netlink.c | 59 ++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 29 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbdcb9b4..bf7f56d7a9aa 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -76,17 +76,17 @@ struct listeners {
 };
 
 /* state bits */
-#define NETLINK_CONGESTED	0x0
+#define NETLINK_S_CONGESTED		0x0
 
 /* flags */
-#define NETLINK_KERNEL_SOCKET	0x1
-#define NETLINK_RECV_PKTINFO	0x2
-#define NETLINK_BROADCAST_SEND_ERROR	0x4
-#define NETLINK_RECV_NO_ENOBUFS	0x8
+#define NETLINK_F_KERNEL_SOCKET		0x1
+#define NETLINK_F_RECV_PKTINFO		0x2
+#define NETLINK_F_BROADCAST_SEND_ERROR	0x4
+#define NETLINK_F_RECV_NO_ENOBUFS	0x8
 
 static inline int netlink_is_kernel(struct sock *sk)
 {
-	return nlk_sk(sk)->flags & NETLINK_KERNEL_SOCKET;
+	return nlk_sk(sk)->flags & NETLINK_F_KERNEL_SOCKET;
 }
 
 struct netlink_table *nl_table;
@@ -256,8 +256,9 @@ static void netlink_overrun(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
-	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
-		if (!test_and_set_bit(NETLINK_CONGESTED, &nlk_sk(sk)->state)) {
+	if (!(nlk->flags & NETLINK_F_RECV_NO_ENOBUFS)) {
+		if (!test_and_set_bit(NETLINK_S_CONGESTED,
+				      &nlk_sk(sk)->state)) {
 			sk->sk_err = ENOBUFS;
 			sk->sk_error_report(sk);
 		}
@@ -270,8 +271,8 @@ static void netlink_rcv_wake(struct sock *sk)
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (skb_queue_empty(&sk->sk_receive_queue))
-		clear_bit(NETLINK_CONGESTED, &nlk->state);
-	if (!test_bit(NETLINK_CONGESTED, &nlk->state))
+		clear_bit(NETLINK_S_CONGESTED, &nlk->state);
+	if (!test_bit(NETLINK_S_CONGESTED, &nlk->state))
 		wake_up_interruptible(&nlk->wait);
 }
 
@@ -1656,7 +1657,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 	nlk = nlk_sk(sk);
 
 	if ((atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	     test_bit(NETLINK_CONGESTED, &nlk->state)) &&
+	     test_bit(NETLINK_S_CONGESTED, &nlk->state)) &&
 	    !netlink_skb_is_mmaped(skb)) {
 		DECLARE_WAITQUEUE(wait, current);
 		if (!*timeo) {
@@ -1671,7 +1672,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		add_wait_queue(&nlk->wait, &wait);
 
 		if ((atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-		     test_bit(NETLINK_CONGESTED, &nlk->state)) &&
+		     test_bit(NETLINK_S_CONGESTED, &nlk->state)) &&
 		    !sock_flag(sk, SOCK_DEAD))
 			*timeo = schedule_timeout(*timeo);
 
@@ -1895,7 +1896,7 @@ static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
-	    !test_bit(NETLINK_CONGESTED, &nlk->state)) {
+	    !test_bit(NETLINK_S_CONGESTED, &nlk->state)) {
 		netlink_skb_set_owner_r(skb, sk);
 		__netlink_sendskb(sk, skb);
 		return atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1);
@@ -1956,7 +1957,7 @@ static void do_one_broadcast(struct sock *sk,
 		netlink_overrun(sk);
 		/* Clone failed. Notify ALL listeners. */
 		p->failure = 1;
-		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
+		if (nlk->flags & NETLINK_F_BROADCAST_SEND_ERROR)
 			p->delivery_failure = 1;
 	} else if (p->tx_filter && p->tx_filter(sk, p->skb2, p->tx_data)) {
 		kfree_skb(p->skb2);
@@ -1966,7 +1967,7 @@ static void do_one_broadcast(struct sock *sk,
 		p->skb2 = NULL;
 	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
 		netlink_overrun(sk);
-		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
+		if (nlk->flags & NETLINK_F_BROADCAST_SEND_ERROR)
 			p->delivery_failure = 1;
 	} else {
 		p->congested |= val;
@@ -2057,7 +2058,7 @@ static int do_one_set_err(struct sock *sk, struct netlink_set_err_data *p)
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
-	if (p->code == ENOBUFS && nlk->flags & NETLINK_RECV_NO_ENOBUFS) {
+	if (p->code == ENOBUFS && nlk->flags & NETLINK_F_RECV_NO_ENOBUFS) {
 		ret = 1;
 		goto out;
 	}
@@ -2076,7 +2077,7 @@ out:
  * @code: error code, must be negative (as usual in kernelspace)
  *
  * This function returns the number of broadcast listeners that have set the
- * NETLINK_RECV_NO_ENOBUFS socket option.
+ * NETLINK_NO_ENOBUFS socket option.
  */
 int netlink_set_err(struct sock *ssk, u32 portid, u32 group, int code)
 {
@@ -2136,9 +2137,9 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 	switch (optname) {
 	case NETLINK_PKTINFO:
 		if (val)
-			nlk->flags |= NETLINK_RECV_PKTINFO;
+			nlk->flags |= NETLINK_F_RECV_PKTINFO;
 		else
-			nlk->flags &= ~NETLINK_RECV_PKTINFO;
+			nlk->flags &= ~NETLINK_F_RECV_PKTINFO;
 		err = 0;
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
@@ -2167,18 +2168,18 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 	}
 	case NETLINK_BROADCAST_ERROR:
 		if (val)
-			nlk->flags |= NETLINK_BROADCAST_SEND_ERROR;
+			nlk->flags |= NETLINK_F_BROADCAST_SEND_ERROR;
 		else
-			nlk->flags &= ~NETLINK_BROADCAST_SEND_ERROR;
+			nlk->flags &= ~NETLINK_F_BROADCAST_SEND_ERROR;
 		err = 0;
 		break;
 	case NETLINK_NO_ENOBUFS:
 		if (val) {
-			nlk->flags |= NETLINK_RECV_NO_ENOBUFS;
-			clear_bit(NETLINK_CONGESTED, &nlk->state);
+			nlk->flags |= NETLINK_F_RECV_NO_ENOBUFS;
+			clear_bit(NETLINK_S_CONGESTED, &nlk->state);
 			wake_up_interruptible(&nlk->wait);
 		} else {
-			nlk->flags &= ~NETLINK_RECV_NO_ENOBUFS;
+			nlk->flags &= ~NETLINK_F_RECV_NO_ENOBUFS;
 		}
 		err = 0;
 		break;
@@ -2227,7 +2228,7 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 		if (len < sizeof(int))
 			return -EINVAL;
 		len = sizeof(int);
-		val = nlk->flags & NETLINK_RECV_PKTINFO ? 1 : 0;
+		val = nlk->flags & NETLINK_F_RECV_PKTINFO ? 1 : 0;
 		if (put_user(len, optlen) ||
 		    put_user(val, optval))
 			return -EFAULT;
@@ -2237,7 +2238,7 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 		if (len < sizeof(int))
 			return -EINVAL;
 		len = sizeof(int);
-		val = nlk->flags & NETLINK_BROADCAST_SEND_ERROR ? 1 : 0;
+		val = nlk->flags & NETLINK_F_BROADCAST_SEND_ERROR ? 1 : 0;
 		if (put_user(len, optlen) ||
 		    put_user(val, optval))
 			return -EFAULT;
@@ -2247,7 +2248,7 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 		if (len < sizeof(int))
 			return -EINVAL;
 		len = sizeof(int);
-		val = nlk->flags & NETLINK_RECV_NO_ENOBUFS ? 1 : 0;
+		val = nlk->flags & NETLINK_F_RECV_NO_ENOBUFS ? 1 : 0;
 		if (put_user(len, optlen) ||
 		    put_user(val, optval))
 			return -EFAULT;
@@ -2418,7 +2419,7 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		msg->msg_namelen = sizeof(*addr);
 	}
 
-	if (nlk->flags & NETLINK_RECV_PKTINFO)
+	if (nlk->flags & NETLINK_F_RECV_PKTINFO)
 		netlink_cmsg_recv_pktinfo(msg, skb);
 
 	memset(&scm, 0, sizeof(scm));
@@ -2502,7 +2503,7 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 		goto out_sock_release;
 
 	nlk = nlk_sk(sk);
-	nlk->flags |= NETLINK_KERNEL_SOCKET;
+	nlk->flags |= NETLINK_F_KERNEL_SOCKET;
 
 	netlink_table_grab();
 	if (!nl_table[unit].registered) {
-- 
2.2.2
