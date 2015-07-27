From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: netns refcnt leak for kernel accept sock
Date: Mon, 27 Jul 2015 19:57:58 +0200
Message-ID: <20150727175758.GG16447@oracle.com>
References: <20150727142146.GC16447@oracle.com>
 <87h9op5wj8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	sowmini.varadhan@oracle.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48264 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbG0R6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 13:58:08 -0400
Content-Disposition: inline
In-Reply-To: <87h9op5wj8.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (07/27/15 12:40), ebiederm@xmission.com wrote:
> sock_create_kern and friends are specialied interfaces for special
> purposes.  At a quick read through I don't think we have a single in
> tree user doing with them what you are trying to do.

That doesnt change the fact that the architecture is questionable.
and my description should make it quite clear why this is so.

> 
> Without seeing code using the interfaces in the way are trying to use
> them I do not have enough information to comment intelligently.

Ok, here you go.

I'm still testing it, but there's enough there for you to see the bug
quite clearly.

Enjoy. I think my other mail had better "information to comment intelligently"
but ymmv.

--Sowmini

diff --git a/net/core/sock.c b/net/core/sock.c
index 08f16db..371d1b7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1497,7 +1497,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		sock_copy(newsk, sk);
 
 		/* SANITY */
-		get_net(sock_net(newsk));
+		if (likely(newsk->sk_net_refcnt))
+			get_net(sock_net(newsk));
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
diff --git a/net/rds/bind.c b/net/rds/bind.c
index 4ebd29c..dd666fb 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -185,7 +185,8 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		ret = 0;
 		goto out;
 	}
-	trans = rds_trans_get_preferred(sin->sin_addr.s_addr);
+	trans = rds_trans_get_preferred(sock_net(sock->sk),
+					sin->sin_addr.s_addr);
 	if (!trans) {
 		ret = -EADDRNOTAVAIL;
 		rds_remove_bound(rs);
diff --git a/net/rds/connection.c b/net/rds/connection.c
index da6da57..273fa6c 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -117,7 +117,8 @@ static void rds_conn_reset(struct rds_connection *conn)
  * For now they are not garbage collected once they're created.  They
  * are torn down as the module is removed, if ever.
  */
-static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
+static struct rds_connection *__rds_conn_create(struct net *net,
+				       __be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp,
 				       int is_outgoing)
 {
@@ -157,7 +158,7 @@ new_conn:
 	conn->c_faddr = faddr;
 	spin_lock_init(&conn->c_lock);
 	conn->c_next_tx_seq = 1;
-
+	write_pnet(&conn->c_net, net);
 	init_waitqueue_head(&conn->c_waitq);
 	INIT_LIST_HEAD(&conn->c_send_queue);
 	INIT_LIST_HEAD(&conn->c_retrans);
@@ -174,7 +175,7 @@ new_conn:
 	 * can bind to the destination address then we'd rather the messages
 	 * flow through loopback rather than either transport.
 	 */
-	loop_trans = rds_trans_get_preferred(faddr);
+	loop_trans = rds_trans_get_preferred(net, faddr);
 	if (loop_trans) {
 		rds_trans_put(loop_trans);
 		conn->c_loopback = 1;
@@ -260,17 +261,19 @@ out:
 	return conn;
 }
 
-struct rds_connection *rds_conn_create(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create(struct net *net,
+				       __be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp)
 {
-	return __rds_conn_create(laddr, faddr, trans, gfp, 0);
+	return __rds_conn_create(net, laddr, faddr, trans, gfp, 0);
 }
 EXPORT_SYMBOL_GPL(rds_conn_create);
 
-struct rds_connection *rds_conn_create_outgoing(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create_outgoing(struct net *net,
+				       __be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp)
 {
-	return __rds_conn_create(laddr, faddr, trans, gfp, 1);
+	return __rds_conn_create(net, laddr, faddr, trans, gfp, 1);
 }
 EXPORT_SYMBOL_GPL(rds_conn_create_outgoing);
 
diff --git a/net/rds/ib.c b/net/rds/ib.c
index ba2dffe..1381422 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -317,7 +317,7 @@ static void rds_ib_ic_info(struct socket *sock, unsigned int len,
  * allowed to influence which paths have priority.  We could call userspace
  * asserting this policy "routing".
  */
-static int rds_ib_laddr_check(__be32 addr)
+static int rds_ib_laddr_check(struct net *net, __be32 addr)
 {
 	int ret;
 	struct rdma_cm_id *cm_id;
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 0da2a45..c38d8a0 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -448,8 +448,8 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
 		 (unsigned long long)be64_to_cpu(lguid),
 		 (unsigned long long)be64_to_cpu(fguid));
 
-	conn = rds_conn_create(dp->dp_daddr, dp->dp_saddr, &rds_ib_transport,
-			       GFP_KERNEL);
+	conn = rds_conn_create(&init_net, dp->dp_daddr, dp->dp_saddr,
+			       &rds_ib_transport, GFP_KERNEL);
 	if (IS_ERR(conn)) {
 		rdsdebug("rds_conn_create failed (%ld)\n", PTR_ERR(conn));
 		conn = NULL;
diff --git a/net/rds/iw.c b/net/rds/iw.c
index 5899356..5d5a9d2 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -218,7 +218,7 @@ static void rds_iw_ic_info(struct socket *sock, unsigned int len,
  * allowed to influence which paths have priority.  We could call userspace
  * asserting this policy "routing".
  */
-static int rds_iw_laddr_check(__be32 addr)
+static int rds_iw_laddr_check(struct net *net, __be32 addr)
 {
 	int ret;
 	struct rdma_cm_id *cm_id;
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 8f486fa..4ea55a3 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -398,8 +398,8 @@ int rds_iw_cm_handle_connect(struct rdma_cm_id *cm_id,
 		 &dp->dp_saddr, &dp->dp_daddr,
 		 RDS_PROTOCOL_MAJOR(version), RDS_PROTOCOL_MINOR(version));
 
-	conn = rds_conn_create(dp->dp_daddr, dp->dp_saddr, &rds_iw_transport,
-			       GFP_KERNEL);
+	conn = rds_conn_create(&init_net, dp->dp_daddr, dp->dp_saddr,
+			       &rds_iw_transport, GFP_KERNEL);
 	if (IS_ERR(conn)) {
 		rdsdebug("rds_conn_create failed (%ld)\n", PTR_ERR(conn));
 		conn = NULL;
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 2260c1e..8c7e018 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -128,6 +128,7 @@ struct rds_connection {
 
 	/* Protocol version */
 	unsigned int		c_version;
+	possible_net_t		c_net;
 };
 
 #define RDS_FLAG_CONG_BITMAP	0x01
@@ -417,7 +418,7 @@ struct rds_transport {
 	unsigned int		t_prefer_loopback:1;
 	unsigned int		t_type;
 
-	int (*laddr_check)(__be32 addr);
+	int (*laddr_check)(struct net *net, __be32 addr);
 	int (*conn_alloc)(struct rds_connection *conn, gfp_t gfp);
 	void (*conn_free)(void *data);
 	int (*conn_connect)(struct rds_connection *conn);
@@ -608,9 +609,11 @@ struct rds_message *rds_cong_update_alloc(struct rds_connection *conn);
 /* conn.c */
 int rds_conn_init(void);
 void rds_conn_exit(void);
-struct rds_connection *rds_conn_create(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create(struct net *net,
+				       __be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp);
-struct rds_connection *rds_conn_create_outgoing(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create_outgoing(struct net *net,
+			       __be32 laddr, __be32 faddr,
 			       struct rds_transport *trans, gfp_t gfp);
 void rds_conn_shutdown(struct rds_connection *conn);
 void rds_conn_destroy(struct rds_connection *conn);
@@ -795,7 +798,7 @@ void rds_connect_complete(struct rds_connection *conn);
 /* transport.c */
 int rds_trans_register(struct rds_transport *trans);
 void rds_trans_unregister(struct rds_transport *trans);
-struct rds_transport *rds_trans_get_preferred(__be32 addr);
+struct rds_transport *rds_trans_get_preferred(struct net *net, __be32 addr);
 void rds_trans_put(struct rds_transport *trans);
 unsigned int rds_trans_stats_info_copy(struct rds_info_iterator *iter,
 				       unsigned int avail);
diff --git a/net/rds/send.c b/net/rds/send.c
index e9430f5..b9c5cae 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1023,7 +1023,8 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	if (rs->rs_conn && rs->rs_conn->c_faddr == daddr)
 		conn = rs->rs_conn;
 	else {
-		conn = rds_conn_create_outgoing(rs->rs_bound_addr, daddr,
+		conn = rds_conn_create_outgoing(sock_net(sock->sk),
+					rs->rs_bound_addr, daddr,
 					rs->rs_transport,
 					sock->sk->sk_allocation);
 		if (IS_ERR(conn)) {
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index edac9ef..d85f9a0 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -35,6 +35,8 @@
 #include <linux/in.h>
 #include <linux/module.h>
 #include <net/tcp.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #include "rds.h"
 #include "tcp.h"
@@ -189,9 +191,9 @@ out:
 	spin_unlock_irqrestore(&rds_tcp_tc_list_lock, flags);
 }
 
-static int rds_tcp_laddr_check(__be32 addr)
+static int rds_tcp_laddr_check(struct net *net, __be32 addr)
 {
-	if (inet_addr_type(&init_net, addr) == RTN_LOCAL)
+	if (inet_addr_type(net, addr) == RTN_LOCAL)
 		return 0;
 	return -EADDRNOTAVAIL;
 }
@@ -250,16 +252,7 @@ static void rds_tcp_destroy_conns(void)
 	}
 }
 
-static void rds_tcp_exit(void)
-{
-	rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
-	rds_tcp_listen_stop();
-	rds_tcp_destroy_conns();
-	rds_trans_unregister(&rds_tcp_transport);
-	rds_tcp_recv_exit();
-	kmem_cache_destroy(rds_tcp_conn_slab);
-}
-module_exit(rds_tcp_exit);
+static void rds_tcp_exit(void);
 
 struct rds_transport rds_tcp_transport = {
 	.laddr_check		= rds_tcp_laddr_check,
@@ -281,6 +274,72 @@ struct rds_transport rds_tcp_transport = {
 	.t_prefer_loopback	= 1,
 };
 
+static int rds_tcp_netid;
+
+/* per-network namespace private data for this module */
+struct rds_tcp_net {
+	struct socket *rds_tcp_listen_sock;
+	struct work_struct rds_tcp_accept_w;
+};
+
+static void rds_tcp_accept_worker(struct work_struct *work)
+{
+	struct rds_tcp_net *rtn = container_of(work,
+					       struct rds_tcp_net,
+					       rds_tcp_accept_w);
+
+	while (rds_tcp_accept_one(rtn->rds_tcp_listen_sock) == 0)
+		cond_resched();
+}
+
+void rds_tcp_accept_work(struct sock *sk)
+{
+	struct net *net = sock_net(sk);
+	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+
+	queue_work(rds_wq, &rtn->rds_tcp_accept_w);
+}
+
+static __net_init int rds_tcp_init_net(struct net *net)
+{
+	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+
+	rtn->rds_tcp_listen_sock = rds_tcp_listen_init(net);
+	if (!rtn->rds_tcp_listen_sock) {
+		pr_warn("could not set up listen sock\n");
+		return -EAFNOSUPPORT;
+	}
+	INIT_WORK(&rtn->rds_tcp_accept_w, rds_tcp_accept_worker);
+	return 0;
+}
+
+static void __net_exit rds_tcp_exit_net(struct net *net)
+{
+	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+
+	flush_work(&rtn->rds_tcp_accept_w);
+	rds_tcp_listen_stop(rtn->rds_tcp_listen_sock);
+	rtn->rds_tcp_listen_sock = NULL;
+}
+
+static struct pernet_operations rds_tcp_net_ops = {
+	.init = rds_tcp_init_net,
+	.exit = rds_tcp_exit_net,
+	.id = &rds_tcp_netid,
+	.size = sizeof(struct rds_tcp_net),
+};
+
+static void rds_tcp_exit(void)
+{
+	rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
+	unregister_pernet_subsys(&rds_tcp_net_ops);
+	rds_tcp_destroy_conns();
+	rds_trans_unregister(&rds_tcp_transport);
+	rds_tcp_recv_exit();
+	kmem_cache_destroy(rds_tcp_conn_slab);
+}
+module_exit(rds_tcp_exit);
+
 static int rds_tcp_init(void)
 {
 	int ret;
@@ -293,6 +352,10 @@ static int rds_tcp_init(void)
 		goto out;
 	}
 
+	ret = register_pernet_subsys(&rds_tcp_net_ops);
+	if (ret)
+		goto out_slab;
+
 	ret = rds_tcp_recv_init();
 	if (ret)
 		goto out_slab;
@@ -301,19 +364,14 @@ static int rds_tcp_init(void)
 	if (ret)
 		goto out_recv;
 
-	ret = rds_tcp_listen_init();
-	if (ret)
-		goto out_register;
-
 	rds_info_register_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
 
 	goto out;
 
-out_register:
-	rds_trans_unregister(&rds_tcp_transport);
 out_recv:
 	rds_tcp_recv_exit();
 out_slab:
+	unregister_pernet_subsys(&rds_tcp_net_ops);
 	kmem_cache_destroy(rds_tcp_conn_slab);
 out:
 	return ret;
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 0dbdd37..f299a85 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -52,6 +52,7 @@ u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc);
 u32 rds_tcp_snd_una(struct rds_tcp_connection *tc);
 u64 rds_tcp_map_seq(struct rds_tcp_connection *tc, u32 seq);
 extern struct rds_transport rds_tcp_transport;
+void rds_tcp_accept_work(struct sock *sk);
 
 /* tcp_connect.c */
 int rds_tcp_conn_connect(struct rds_connection *conn);
@@ -59,9 +60,10 @@ void rds_tcp_conn_shutdown(struct rds_connection *conn);
 void rds_tcp_state_change(struct sock *sk);
 
 /* tcp_listen.c */
-int rds_tcp_listen_init(void);
-void rds_tcp_listen_stop(void);
+struct socket *rds_tcp_listen_init(struct net *);
+void rds_tcp_listen_stop(struct socket *);
 void rds_tcp_listen_data_ready(struct sock *sk);
+int rds_tcp_accept_one(struct socket *sock);
 
 /* tcp_recv.c */
 int rds_tcp_recv_init(void);
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 973109c..54a4609 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -79,7 +79,8 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	struct sockaddr_in src, dest;
 	int ret;
 
-	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	ret = sock_create_kern(read_pnet(&conn->c_net), PF_INET,
+			       SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (ret < 0)
 		goto out;
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 0da49e3..1be6584 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -38,13 +38,6 @@
 #include "rds.h"
 #include "tcp.h"
 
-/*
- * cheesy, but simple..
- */
-static void rds_tcp_accept_worker(struct work_struct *work);
-static DECLARE_WORK(rds_tcp_listen_work, rds_tcp_accept_worker);
-static struct socket *rds_tcp_listen_sock;
-
 static int rds_tcp_keepalive(struct socket *sock)
 {
 	/* values below based on xs_udp_default_timeout */
@@ -77,7 +70,7 @@ bail:
 	return ret;
 }
 
-static int rds_tcp_accept_one(struct socket *sock)
+int rds_tcp_accept_one(struct socket *sock)
 {
 	struct socket *new_sock = NULL;
 	struct rds_connection *conn;
@@ -85,8 +78,9 @@ static int rds_tcp_accept_one(struct socket *sock)
 	struct inet_sock *inet;
 	struct rds_tcp_connection *rs_tcp;
 
-	ret = sock_create_lite(sock->sk->sk_family, sock->sk->sk_type,
-			       sock->sk->sk_protocol, &new_sock);
+	ret = sock_create_kern(sock_net(sock->sk), sock->sk->sk_family,
+			       sock->sk->sk_type, sock->sk->sk_protocol,
+			       &new_sock);
 	if (ret)
 		goto out;
 
@@ -108,7 +102,8 @@ static int rds_tcp_accept_one(struct socket *sock)
 		 &inet->inet_saddr, ntohs(inet->inet_sport),
 		 &inet->inet_daddr, ntohs(inet->inet_dport));
 
-	conn = rds_conn_create(inet->inet_saddr, inet->inet_daddr,
+	conn = rds_conn_create(sock_net(sock->sk),
+			       inet->inet_saddr, inet->inet_daddr,
 			       &rds_tcp_transport, GFP_KERNEL);
 	if (IS_ERR(conn)) {
 		ret = PTR_ERR(conn);
@@ -148,12 +143,6 @@ out:
 	return ret;
 }
 
-static void rds_tcp_accept_worker(struct work_struct *work)
-{
-	while (rds_tcp_accept_one(rds_tcp_listen_sock) == 0)
-		cond_resched();
-}
-
 void rds_tcp_listen_data_ready(struct sock *sk)
 {
 	void (*ready)(struct sock *sk);
@@ -174,20 +163,20 @@ void rds_tcp_listen_data_ready(struct sock *sk)
 	 * socket
 	 */
 	if (sk->sk_state == TCP_LISTEN)
-		queue_work(rds_wq, &rds_tcp_listen_work);
+		rds_tcp_accept_work(sk);
 
 out:
 	read_unlock(&sk->sk_callback_lock);
 	ready(sk);
 }
 
-int rds_tcp_listen_init(void)
+struct socket *rds_tcp_listen_init(struct net *net)
 {
 	struct sockaddr_in sin;
 	struct socket *sock = NULL;
 	int ret;
 
-	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	ret = sock_create_kern(net, PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (ret < 0)
 		goto out;
 
@@ -211,17 +200,15 @@ int rds_tcp_listen_init(void)
 	if (ret < 0)
 		goto out;
 
-	rds_tcp_listen_sock = sock;
-	sock = NULL;
+	return sock;
 out:
 	if (sock)
 		sock_release(sock);
-	return ret;
+	return NULL;
 }
 
-void rds_tcp_listen_stop(void)
+void rds_tcp_listen_stop(struct socket *sock)
 {
-	struct socket *sock = rds_tcp_listen_sock;
 	struct sock *sk;
 
 	if (!sock)
@@ -242,5 +229,4 @@ void rds_tcp_listen_stop(void)
 	/* wait for accepts to stop and close the socket */
 	flush_workqueue(rds_wq);
 	sock_release(sock);
-	rds_tcp_listen_sock = NULL;
 }
diff --git a/net/rds/transport.c b/net/rds/transport.c
index 83498e1..f3afd1d 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -77,7 +77,7 @@ void rds_trans_put(struct rds_transport *trans)
 		module_put(trans->t_owner);
 }
 
-struct rds_transport *rds_trans_get_preferred(__be32 addr)
+struct rds_transport *rds_trans_get_preferred(struct net *net, __be32 addr)
 {
 	struct rds_transport *ret = NULL;
 	struct rds_transport *trans;
@@ -90,7 +90,7 @@ struct rds_transport *rds_trans_get_preferred(__be32 addr)
 	for (i = 0; i < RDS_TRANS_COUNT; i++) {
 		trans = transports[i];
 
-		if (trans && (trans->laddr_check(addr) == 0) &&
+		if (trans && (trans->laddr_check(net, addr) == 0) &&
 		    (!trans->t_owner || try_module_get(trans->t_owner))) {
 			ret = trans;
 			break;
