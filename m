From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 1/4] l2tp: put tunnel socket release on a workqueue
Date: Fri,  1 Feb 2013 09:43:00 +0000
Message-ID: <1359711783-4379-2-git-send-email-tparkin@katalix.com>
References: <1359711783-4379-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36156 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756098Ab3BAJnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 04:43:13 -0500
In-Reply-To: <1359711783-4379-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allow l2tp_tunnel_delete to be called from an atomic context, place the
tunnel socket release calls on a workqueue for asynchronous execution.

Tunnel memory is eventually freed in the tunnel socket destructor.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |  103 +++++++++++++++++++++++++++++---------------------
 net/l2tp/l2tp_core.h |    2 +
 2 files changed, 61 insertions(+), 44 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 06389d5..73988c0 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -101,6 +101,7 @@ struct l2tp_skb_cb {
 
 static atomic_t l2tp_tunnel_count;
 static atomic_t l2tp_session_count;
+static struct workqueue_struct *l2tp_wq;
 
 /* per-net private data for this module */
 static unsigned int l2tp_net_id;
@@ -122,7 +123,6 @@ static inline struct l2tp_net *l2tp_pernet(struct net *net)
 	return net_generic(net, l2tp_net_id);
 }
 
-
 /* Tunnel reference counts. Incremented per session that is added to
  * the tunnel.
  */
@@ -1277,6 +1277,7 @@ EXPORT_SYMBOL_GPL(l2tp_xmit_skb);
 static void l2tp_tunnel_destruct(struct sock *sk)
 {
 	struct l2tp_tunnel *tunnel;
+	struct l2tp_net *pn;
 
 	tunnel = sk->sk_user_data;
 	if (tunnel == NULL)
@@ -1284,9 +1285,8 @@ static void l2tp_tunnel_destruct(struct sock *sk)
 
 	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: closing...\n", tunnel->name);
 
-	/* Close all sessions */
-	l2tp_tunnel_closeall(tunnel);
 
+	/* Disable udp encapsulation */
 	switch (tunnel->encap) {
 	case L2TP_ENCAPTYPE_UDP:
 		/* No longer an encapsulation socket. See net/ipv4/udp.c */
@@ -1298,17 +1298,23 @@ static void l2tp_tunnel_destruct(struct sock *sk)
 	}
 
 	/* Remove hooks into tunnel socket */
-	tunnel->sock = NULL;
 	sk->sk_destruct = tunnel->old_sk_destruct;
 	sk->sk_user_data = NULL;
+	tunnel->sock = NULL;
 
-	/* Call the original destructor */
-	if (sk->sk_destruct)
-		(*sk->sk_destruct)(sk);
+	/* Remove the tunnel struct from the tunnel list */
+	pn = l2tp_pernet(tunnel->l2tp_net);
+	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
+	list_del_rcu(&tunnel->list);
+	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
+	atomic_dec(&l2tp_tunnel_count);
 
-	/* We're finished with the socket */
+	l2tp_tunnel_closeall(tunnel);
 	l2tp_tunnel_dec_refcount(tunnel);
 
+	/* Call the original destructor */
+	if (sk->sk_destruct)
+		(*sk->sk_destruct)(sk);
 end:
 	return;
 }
@@ -1382,20 +1388,41 @@ again:
  */
 static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
 {
-	struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
-
 	BUG_ON(atomic_read(&tunnel->ref_count) != 0);
 	BUG_ON(tunnel->sock != NULL);
-
 	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: free...\n", tunnel->name);
-
-	/* Remove from tunnel list */
-	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
-	list_del_rcu(&tunnel->list);
 	kfree_rcu(tunnel, rcu);
-	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
+}
 
-	atomic_dec(&l2tp_tunnel_count);
+/* Workqueue tunnel deletion function */
+static void l2tp_tunnel_del_work(struct work_struct *work)
+{
+	struct l2tp_tunnel *tunnel = NULL;
+	struct socket *sock = NULL;
+	struct sock *sk = NULL;
+
+	tunnel = container_of(work, struct l2tp_tunnel, del_work);
+	sk = l2tp_tunnel_sock_lookup(tunnel);
+	if (!sk)
+		return;
+
+	sock = sk->sk_socket;
+	BUG_ON(!sock);
+
+	/* Force the tunnel socket to close. This will eventually
+	 * cause the tunnel to be deleted via the normal socket close
+	 * mechanisms when userspace closes the tunnel socket.
+	 */
+	inet_shutdown(sock, 2);
+
+	/* If the tunnel's socket was created by the kernel,
+	 * close the socket here since the socket was not
+	 * created by userspace.
+	 */
+	if (sock->file == NULL)
+		inet_release(sock);
+
+	l2tp_tunnel_sock_put(sk);
 }
 
 /* Create a socket for the tunnel, if one isn't set up by
@@ -1657,6 +1684,9 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 
 	sk->sk_allocation = GFP_ATOMIC;
 
+	/* Init delete workqueue struct */
+	INIT_WORK(&tunnel->del_work, l2tp_tunnel_del_work);
+
 	/* Add tunnel to our list */
 	INIT_LIST_HEAD(&tunnel->list);
 	atomic_inc(&l2tp_tunnel_count);
@@ -1688,33 +1718,7 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
  */
 int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
-	int err = -EBADF;
-	struct socket *sock = NULL;
-	struct sock *sk = NULL;
-
-	sk = l2tp_tunnel_sock_lookup(tunnel);
-	if (!sk)
-		goto out;
-
-	sock = sk->sk_socket;
-	BUG_ON(!sock);
-
-	/* Force the tunnel socket to close. This will eventually
-	 * cause the tunnel to be deleted via the normal socket close
-	 * mechanisms when userspace closes the tunnel socket.
-	 */
-	err = inet_shutdown(sock, 2);
-
-	/* If the tunnel's socket was created by the kernel,
-	 * close the socket here since the socket was not
-	 * created by userspace.
-	 */
-	if (sock->file == NULL)
-		err = inet_release(sock);
-
-	l2tp_tunnel_sock_put(sk);
-out:
-	return err;
+	return (false == queue_work(l2tp_wq, &tunnel->del_work));
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
 
@@ -1912,6 +1916,13 @@ static int __init l2tp_init(void)
 	if (rc)
 		goto out;
 
+	l2tp_wq = alloc_workqueue("l2tp", WQ_NON_REENTRANT | WQ_UNBOUND, 0);
+	if (!l2tp_wq) {
+		pr_err("alloc_workqueue failed\n");
+		rc = -ENOMEM;
+		goto out;
+	}
+
 	pr_info("L2TP core driver, %s\n", L2TP_DRV_VERSION);
 
 out:
@@ -1921,6 +1932,10 @@ out:
 static void __exit l2tp_exit(void)
 {
 	unregister_pernet_device(&l2tp_net_ops);
+	if (l2tp_wq) {
+		destroy_workqueue(l2tp_wq);
+		l2tp_wq = NULL;
+	}
 }
 
 module_init(l2tp_init);
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index e62204c..8eb8f1d 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -191,6 +191,8 @@ struct l2tp_tunnel {
 	int			fd;		/* Parent fd, if tunnel socket
 						 * was created by userspace */
 
+	struct work_struct	del_work;
+
 	uint8_t			priv[0];	/* private data */
 };
 
-- 
1.7.9.5
