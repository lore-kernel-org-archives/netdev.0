From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] remove unused netlink NL_EMULATE_DEV code
Date: Fri, 18 Mar 2005 15:36:37 -0800
Message-ID: <20050318233637.GS5389@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Now that netlink_attach() has been removed, the NL_EMULATE_DEV handler
functions can't ever be set.  So let's rip them out too, because what's
left behind can't be used at all.

Signed-off-by: Chris Wright <chrisw@osdl.org>

 net/netlink/af_netlink.c |   24 +-----------------------
 1 files changed, 1 insertion(+), 23 deletions(-)

===== net/netlink/af_netlink.c 1.71 vs edited =====
--- 1.71/net/netlink/af_netlink.c	2005-03-14 21:27:59 -08:00
+++ edited/net/netlink/af_netlink.c	2005-03-18 11:57:32 -08:00
@@ -55,10 +55,6 @@
 
 #define Nprintk(a...)
 
-#if defined(CONFIG_NETLINK_DEV) || defined(CONFIG_NETLINK_DEV_MODULE)
-#define NL_EMULATE_DEV
-#endif
-
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
 	struct sock		sk;
@@ -67,7 +63,6 @@ struct netlink_sock {
 	u32			dst_pid;
 	unsigned int		dst_groups;
 	unsigned long		state;
-	int			(*handler)(int unit, struct sk_buff *skb);
 	wait_queue_head_t	wait;
 	struct netlink_callback	*cb;
 	spinlock_t		cb_lock;
@@ -593,10 +588,6 @@ int netlink_attachskb(struct sock *sk, s
 
 	nlk = nlk_sk(sk);
 
-#ifdef NL_EMULATE_DEV
-	if (nlk->handler)
-		return 0;
-#endif
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
 	    test_bit(0, &nlk->state)) {
 		DECLARE_WAITQUEUE(wait, current);
@@ -636,14 +627,6 @@ int netlink_sendskb(struct sock *sk, str
 	int len = skb->len;
 
 	nlk = nlk_sk(sk);
-#ifdef NL_EMULATE_DEV
-	if (nlk->handler) {
-		skb_orphan(skb);
-		len = nlk->handler(protocol, skb);
-		sock_put(sk);
-		return len;
-	}
-#endif
 
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk, len);
@@ -708,12 +691,7 @@ retry:
 static __inline__ int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
-#ifdef NL_EMULATE_DEV
-	if (nlk->handler) {
-		nlk->handler(sk->sk_protocol, skb);
-		return 0;
-	} else
-#endif
+
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 	    !test_bit(0, &nlk->state)) {
 		skb_set_owner_r(skb, sk);
