From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v3 net-next 2/2] RDS-TCP: Support multiple RDS-TCP listen endpoints, one per netns.
Date: Wed,  5 Aug 2015 01:43:26 -0400
Message-ID: <3403f9cfe0aba671c8b08638f94afb035af057b4.1438752224.git.sowmini.varadhan@oracle.com>
References: <cover.1438752224.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	chien.yen@oracle.com, sowmini.varadhan@oracle.com,
	cwang@twopensource.com, dsahern@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27694 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbHEFnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 01:43:49 -0400
In-Reply-To: <cover.1438752224.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1438752224.git.sowmini.varadhan@oracle.com>
References: <cover.1438752224.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register pernet subsys init/stop functions that will set up
and tear down per-net RDS-TCP listen endpoints. Unregister
pernet subusys functions on 'modprobe -r' to clean up these
end points.

Enable keepalive on both accept and connect socket endpoints.
The keepalive timer expiration will ensure that client socket
endpoints will be removed as appropriate from the netns when
an interface is removed from a namespace.

Register a device notifier callback that will clean up all
sockets (and thus avoid the need to wait for keepalive timeout)
when the loopback device is unregistered from the netns indicating
that the netns is getting deleted.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: net_device notifier for synchronous cleanup of sockets.
v3: Cong Wang comments

 net/rds/tcp.c         |  161 ++++++++++++++++++++++++++++++++++++++++++++-----
 net/rds/tcp.h         |    7 ++-
 net/rds/tcp_connect.c |    6 +-
 net/rds/tcp_listen.c  |   38 +++---------
 4 files changed, 162 insertions(+), 50 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 98f5de3..c42b60b 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -35,6 +35,9 @@
 #include <linux/in.h>
 #include <linux/module.h>
 #include <net/tcp.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/tcp.h>
 
 #include "rds.h"
 #include "tcp.h"
@@ -250,16 +253,7 @@ static void rds_tcp_destroy_conns(void)
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
@@ -281,6 +275,136 @@ struct rds_transport rds_tcp_transport = {
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
+	/* If rds_tcp_exit_net() is called as a result of netns deletion,
+	 * the rds_tcp_kill_sock() device notifier would already have cleaned
+	 * up the listen socket, thus there is no work to do in this function.
+	 *
+	 * If rds_tcp_exit_net() is called as a result of module unload,
+	 * i.e., due to rds_tcp_exit() -> unregister_pernet_subsys(), then
+	 * we do need to clean up the listen socket here.
+	 */
+	if (rtn->rds_tcp_listen_sock) {
+		rds_tcp_listen_stop(rtn->rds_tcp_listen_sock);
+		rtn->rds_tcp_listen_sock = NULL;
+		flush_work(&rtn->rds_tcp_accept_w);
+	}
+}
+
+static struct pernet_operations rds_tcp_net_ops = {
+	.init = rds_tcp_init_net,
+	.exit = rds_tcp_exit_net,
+	.id = &rds_tcp_netid,
+	.size = sizeof(struct rds_tcp_net),
+};
+
+static void rds_tcp_kill_sock(struct net *net)
+{
+	struct rds_tcp_connection *tc, *_tc;
+	struct sock *sk;
+	LIST_HEAD(tmp_list);
+	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+
+	rds_tcp_listen_stop(rtn->rds_tcp_listen_sock);
+	rtn->rds_tcp_listen_sock = NULL;
+	flush_work(&rtn->rds_tcp_accept_w);
+	spin_lock_irq(&rds_tcp_conn_lock);
+	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
+		struct net *c_net = read_pnet(&tc->conn->c_net);
+
+		if (net != c_net || !tc->t_sock)
+			continue;
+		list_move_tail(&tc->t_tcp_node, &tmp_list);
+	}
+	spin_unlock_irq(&rds_tcp_conn_lock);
+	list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node) {
+		sk = tc->t_sock->sk;
+		sk->sk_prot->disconnect(sk, 0);
+		tcp_done(sk);
+		if (tc->conn->c_passive)
+			rds_conn_destroy(tc->conn->c_passive);
+		rds_conn_destroy(tc->conn);
+	}
+}
+
+static int rds_tcp_dev_event(struct notifier_block *this,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	/* rds-tcp registers as a pernet subys, so the ->exit will only
+	 * get invoked after network acitivity has quiesced. We need to
+	 * clean up all sockets  to quiesce network activity, and use
+	 * the unregistration of the per-net loopback device as a trigger
+	 * to start that cleanup.
+	 */
+	if (event == NETDEV_UNREGISTER_FINAL &&
+	    dev->ifindex == LOOPBACK_IFINDEX)
+		rds_tcp_kill_sock(dev_net(dev));
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rds_tcp_dev_notifier = {
+	.notifier_call        = rds_tcp_dev_event,
+	.priority = -10, /* must be called after other network notifiers */
+};
+
+static void rds_tcp_exit(void)
+{
+	rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
+	unregister_pernet_subsys(&rds_tcp_net_ops);
+	if (unregister_netdevice_notifier(&rds_tcp_dev_notifier))
+		pr_warn("could not unregister rds_tcp_dev_notifier\n");
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
@@ -293,6 +417,16 @@ static int rds_tcp_init(void)
 		goto out;
 	}
 
+	ret = register_netdevice_notifier(&rds_tcp_dev_notifier);
+	if (ret) {
+		pr_warn("could not register rds_tcp_dev_notifier\n");
+		goto out;
+	}
+
+	ret = register_pernet_subsys(&rds_tcp_net_ops);
+	if (ret)
+		goto out_slab;
+
 	ret = rds_tcp_recv_init();
 	if (ret)
 		goto out_slab;
@@ -301,19 +435,14 @@ static int rds_tcp_init(void)
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
index 0dbdd37..64f873c 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -52,6 +52,7 @@ u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc);
 u32 rds_tcp_snd_una(struct rds_tcp_connection *tc);
 u64 rds_tcp_map_seq(struct rds_tcp_connection *tc, u32 seq);
 extern struct rds_transport rds_tcp_transport;
+void rds_tcp_accept_work(struct sock *sk);
 
 /* tcp_connect.c */
 int rds_tcp_conn_connect(struct rds_connection *conn);
@@ -59,9 +60,11 @@ void rds_tcp_conn_shutdown(struct rds_connection *conn);
 void rds_tcp_state_change(struct sock *sk);
 
 /* tcp_listen.c */
-int rds_tcp_listen_init(void);
-void rds_tcp_listen_stop(void);
+struct socket *rds_tcp_listen_init(struct net *);
+void rds_tcp_listen_stop(struct socket *);
 void rds_tcp_listen_data_ready(struct sock *sk);
+int rds_tcp_accept_one(struct socket *sock);
+int rds_tcp_keepalive(struct socket *sock);
 
 /* tcp_recv.c */
 int rds_tcp_recv_init(void);
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 6473b7b..5cb1687 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -112,10 +112,12 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	rdsdebug("connect to address %pI4 returned %d\n", &conn->c_faddr, ret);
 	if (ret == -EINPROGRESS)
 		ret = 0;
-	if (ret == 0)
+	if (ret == 0) {
+		rds_tcp_keepalive(sock);
 		sock = NULL;
-	else
+	} else {
 		rds_tcp_restore_callbacks(sock, conn->c_transport_data);
+	}
 
 out:
 	if (sock)
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 398ffe5..444d78d 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -38,14 +38,7 @@
 #include "rds.h"
 #include "tcp.h"
 
-/*
- * cheesy, but simple..
- */
-static void rds_tcp_accept_worker(struct work_struct *work);
-static DECLARE_WORK(rds_tcp_listen_work, rds_tcp_accept_worker);
-static struct socket *rds_tcp_listen_sock;
-
-static int rds_tcp_keepalive(struct socket *sock)
+int rds_tcp_keepalive(struct socket *sock)
 {
 	/* values below based on xs_udp_default_timeout */
 	int keepidle = 5; /* send a probe 'keepidle' secs after last data */
@@ -77,7 +70,7 @@ static int rds_tcp_keepalive(struct socket *sock)
 	return ret;
 }
 
-static int rds_tcp_accept_one(struct socket *sock)
+int rds_tcp_accept_one(struct socket *sock)
 {
 	struct socket *new_sock = NULL;
 	struct rds_connection *conn;
@@ -150,12 +143,6 @@ static int rds_tcp_accept_one(struct socket *sock)
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
@@ -176,26 +163,20 @@ void rds_tcp_listen_data_ready(struct sock *sk)
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
 
-	/* MUST call sock_create_kern directly so that we avoid get_net()
-	 * in sk_alloc(). Doing a get_net() will result in cleanup_net()
-	 * never getting invoked, which will leave sock and other things
-	 * in limbo.
-	 */
-	ret = sock_create_kern(current->nsproxy->net_ns, PF_INET,
-			       SOCK_STREAM, IPPROTO_TCP, &sock);
+	ret = sock_create_kern(net, PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (ret < 0)
 		goto out;
 
@@ -219,17 +200,15 @@ int rds_tcp_listen_init(void)
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
@@ -250,5 +229,4 @@ void rds_tcp_listen_stop(void)
 	/* wait for accepts to stop and close the socket */
 	flush_workqueue(rds_wq);
 	sock_release(sock);
-	rds_tcp_listen_sock = NULL;
 }
-- 
1.7.1
