From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: add __rcu annotations to sk_wq and wq
Date: Fri, 18 Feb 2011 14:26:36 +0100
Message-ID: <1298035596.6201.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38966 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1BRN0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 08:26:41 -0500
Received: by fxm20 with SMTP id 20so3764353fxm.19
        for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 05:26:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add proper RCU annotations/verbs to sk_wq and wq members

Fix __sctp_write_space() sk_sleep() abuse (and sock->wq access)

Fix sunrpc sk_sleep() abuse too

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/net.h  |    3 ++-
 include/net/sock.h   |    7 ++++---
 net/sctp/socket.c    |    9 +++++----
 net/socket.c         |   23 ++++++++++++++---------
 net/sunrpc/svcsock.c |   32 ++++++++++++++++++++------------
 net/unix/af_unix.c   |    2 +-
 6 files changed, 46 insertions(+), 30 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 16faa13..94de83c 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -118,6 +118,7 @@ enum sock_shutdown_cmd {
 };
 
 struct socket_wq {
+	/* Note: wait MUST be first field of socket_wq */
 	wait_queue_head_t	wait;
 	struct fasync_struct	*fasync_list;
 	struct rcu_head		rcu;
@@ -142,7 +143,7 @@ struct socket {
 
 	unsigned long		flags;
 
-	struct socket_wq	*wq;
+	struct socket_wq __rcu	*wq;
 
 	struct file		*file;
 	struct sock		*sk;
diff --git a/include/net/sock.h b/include/net/sock.h
index e3893a2..da0534d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -281,7 +281,7 @@ struct sock {
 	int			sk_rcvbuf;
 
 	struct sk_filter __rcu	*sk_filter;
-	struct socket_wq	*sk_wq;
+	struct socket_wq __rcu	*sk_wq;
 
 #ifdef CONFIG_NET_DMA
 	struct sk_buff_head	sk_async_wait_queue;
@@ -1266,7 +1266,8 @@ static inline void sk_set_socket(struct sock *sk, struct socket *sock)
 
 static inline wait_queue_head_t *sk_sleep(struct sock *sk)
 {
-	return &sk->sk_wq->wait;
+	BUILD_BUG_ON(offsetof(struct socket_wq, wait) != 0);
+	return &rcu_dereference_raw(sk->sk_wq)->wait;
 }
 /* Detach socket from process context.
  * Announce socket dead, detach it from wait queue and inode.
@@ -1287,7 +1288,7 @@ static inline void sock_orphan(struct sock *sk)
 static inline void sock_graft(struct sock *sk, struct socket *parent)
 {
 	write_lock_bh(&sk->sk_callback_lock);
-	rcu_assign_pointer(sk->sk_wq, parent->wq);
+	sk->sk_wq = parent->wq;
 	parent->sk = sk;
 	sk_set_socket(sk, parent);
 	security_sock_graft(sk, parent);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 8e02550..b53b2eb 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6102,15 +6102,16 @@ static void __sctp_write_space(struct sctp_association *asoc)
 			wake_up_interruptible(&asoc->wait);
 
 		if (sctp_writeable(sk)) {
-			if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-				wake_up_interruptible(sk_sleep(sk));
+			wait_queue_head_t *wq = sk_sleep(sk);
+
+			if (wq && waitqueue_active(wq))
+				wake_up_interruptible(wq);
 
 			/* Note that we try to include the Async I/O support
 			 * here by modeling from the current TCP/UDP code.
 			 * We have not tested with it yet.
 			 */
-			if (sock->wq->fasync_list &&
-			    !(sk->sk_shutdown & SEND_SHUTDOWN))
+			if (!(sk->sk_shutdown & SEND_SHUTDOWN))
 				sock_wake_async(sock,
 						SOCK_WAKE_SPACE, POLL_OUT);
 		}
diff --git a/net/socket.c b/net/socket.c
index ac2219f..9fa1e3b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -240,17 +240,19 @@ static struct kmem_cache *sock_inode_cachep __read_mostly;
 static struct inode *sock_alloc_inode(struct super_block *sb)
 {
 	struct socket_alloc *ei;
+	struct socket_wq *wq;
 
 	ei = kmem_cache_alloc(sock_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
-	ei->socket.wq = kmalloc(sizeof(struct socket_wq), GFP_KERNEL);
-	if (!ei->socket.wq) {
+	wq = kmalloc(sizeof(*wq), GFP_KERNEL);
+	if (!wq) {
 		kmem_cache_free(sock_inode_cachep, ei);
 		return NULL;
 	}
-	init_waitqueue_head(&ei->socket.wq->wait);
-	ei->socket.wq->fasync_list = NULL;
+	init_waitqueue_head(&wq->wait);
+	wq->fasync_list = NULL;
+	RCU_INIT_POINTER(ei->socket.wq, wq);
 
 	ei->socket.state = SS_UNCONNECTED;
 	ei->socket.flags = 0;
@@ -273,9 +275,11 @@ static void wq_free_rcu(struct rcu_head *head)
 static void sock_destroy_inode(struct inode *inode)
 {
 	struct socket_alloc *ei;
+	struct socket_wq *wq;
 
 	ei = container_of(inode, struct socket_alloc, vfs_inode);
-	call_rcu(&ei->socket.wq->rcu, wq_free_rcu);
+	wq = rcu_dereference_protected(ei->socket.wq, 1);
+	call_rcu(&wq->rcu, wq_free_rcu);
 	kmem_cache_free(sock_inode_cachep, ei);
 }
 
@@ -524,7 +528,7 @@ void sock_release(struct socket *sock)
 		module_put(owner);
 	}
 
-	if (sock->wq->fasync_list)
+	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
 
 	percpu_sub(sockets_in_use, 1);
@@ -1108,15 +1112,16 @@ static int sock_fasync(int fd, struct file *filp, int on)
 {
 	struct socket *sock = filp->private_data;
 	struct sock *sk = sock->sk;
+	struct socket_wq *wq;
 
 	if (sk == NULL)
 		return -EINVAL;
 
 	lock_sock(sk);
+	wq = rcu_dereference_protected(sock->wq, sock_owned_by_user(sk));
+	fasync_helper(fd, filp, on, &wq->fasync_list);
 
-	fasync_helper(fd, filp, on, &sock->wq->fasync_list);
-
-	if (!sock->wq->fasync_list)
+	if (!wq->fasync_list)
 		sock_reset_flag(sk, SOCK_FASYNC);
 	else
 		sock_set_flag(sk, SOCK_FASYNC);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7bd3bbb..76425d2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -420,6 +420,7 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 static void svc_udp_data_ready(struct sock *sk, int count)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
+	wait_queue_head_t *wq = sk_sleep(sk);
 
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), count=%d, busy=%d\n",
@@ -428,8 +429,8 @@ static void svc_udp_data_ready(struct sock *sk, int count)
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible(sk_sleep(sk));
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible(wq);
 }
 
 /*
@@ -438,6 +439,7 @@ static void svc_udp_data_ready(struct sock *sk, int count)
 static void svc_write_space(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)(sk->sk_user_data);
+	wait_queue_head_t *wq = sk_sleep(sk);
 
 	if (svsk) {
 		dprintk("svc: socket %p(inet %p), write_space busy=%d\n",
@@ -445,10 +447,10 @@ static void svc_write_space(struct sock *sk)
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk))) {
+	if (wq && waitqueue_active(wq)) {
 		dprintk("RPC svc_write_space: someone sleeping on %p\n",
 		       svsk);
-		wake_up_interruptible(sk_sleep(sk));
+		wake_up_interruptible(wq);
 	}
 }
 
@@ -739,6 +741,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 static void svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
+	wait_queue_head_t *wq;
 
 	dprintk("svc: socket %p TCP (listen) state change %d\n",
 		sk, sk->sk_state);
@@ -761,8 +764,9 @@ static void svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
 			printk("svc: socket %p: no user data\n", sk);
 	}
 
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible_all(sk_sleep(sk));
+	wq = sk_sleep(sk);
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible_all(wq);
 }
 
 /*
@@ -771,6 +775,7 @@ static void svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
 static void svc_tcp_state_change(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
+	wait_queue_head_t *wq = sk_sleep(sk);
 
 	dprintk("svc: socket %p TCP (connected) state change %d (svsk %p)\n",
 		sk, sk->sk_state, sk->sk_user_data);
@@ -781,13 +786,14 @@ static void svc_tcp_state_change(struct sock *sk)
 		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible_all(sk_sleep(sk));
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible_all(wq);
 }
 
 static void svc_tcp_data_ready(struct sock *sk, int count)
 {
 	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
+	wait_queue_head_t *wq = sk_sleep(sk);
 
 	dprintk("svc: socket %p TCP data ready (svsk %p)\n",
 		sk, sk->sk_user_data);
@@ -795,8 +801,8 @@ static void svc_tcp_data_ready(struct sock *sk, int count)
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible(sk_sleep(sk));
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible(wq);
 }
 
 /*
@@ -1531,6 +1537,7 @@ static void svc_sock_detach(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 	struct sock *sk = svsk->sk_sk;
+	wait_queue_head_t *wq;
 
 	dprintk("svc: svc_sock_detach(%p)\n", svsk);
 
@@ -1539,8 +1546,9 @@ static void svc_sock_detach(struct svc_xprt *xprt)
 	sk->sk_data_ready = svsk->sk_odata;
 	sk->sk_write_space = svsk->sk_owspace;
 
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible(sk_sleep(sk));
+	wq = sk_sleep(sk);
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible(wq);
 }
 
 /*
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d8d98d5..217fb7f 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1171,7 +1171,7 @@ restart:
 	newsk->sk_type		= sk->sk_type;
 	init_peercred(newsk);
 	newu = unix_sk(newsk);
-	newsk->sk_wq		= &newu->peer_wq;
+	RCU_INIT_POINTER(newsk->sk_wq, &newu->peer_wq);
 	otheru = unix_sk(other);
 
 	/* copy address information from listening to new sock*/


