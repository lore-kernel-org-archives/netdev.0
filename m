From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v4 1/2] RDS: TCP: Add sysctl tunables for sndbuf/rcvbuf on rds-tcp socket
Date: Wed, 16 Mar 2016 11:38:12 -0700
Message-ID: <ff418859d65dbe7155a631fd36051fd8bbe24e97.1458152608.git.sowmini.varadhan@oracle.com>
References: <cover.1458152608.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
	santosh.shilimkar@oracle.com, hannes@stressinduktion.org,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24157 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934328AbcCPSim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 14:38:42 -0400
In-Reply-To: <cover.1458152608.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1458152608.git.sowmini.varadhan@oracle.com>
References: <cover.1458152608.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add per-net sysctl tunables to set the size of sndbuf and
rcvbuf on the kernel tcp socket.

The tunables are added at /proc/sys/net/rds/tcp/rds_tcp_sndbuf
and /proc/sys/net/rds/tcp/rds_tcp_rcvbuf.

These values must be set before accept() or connect(),
and there may be an arbitrary number of existing rds-tcp
sockets when the tunable is modified. To make sure that all
connections in the netns pick up the same value for the tunable,
we reset existing rds-tcp connections in the netns, so that
they can reconnect with the new parameters.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2; use sysctl instead of module param. Tunabes are now per netns,
    and can be dynamically modified without restarting all namespaces.
v3: review comments from Santosh Shilimkar. Sockbuf size comments from
    Eric Dumazet
v4: review comments from Hannes Sowa

 net/rds/tcp.c |  145 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 135 insertions(+), 10 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index ad60299..3802785 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -54,6 +54,35 @@ static struct kmem_cache *rds_tcp_conn_slab;
 
 #define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
 
+static int rds_tcp_skbuf_handler(struct ctl_table *ctl, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *fpos);
+
+int rds_tcp_min_sndbuf = SOCK_MIN_SNDBUF;
+int rds_tcp_min_rcvbuf = SOCK_MIN_RCVBUF;
+
+static struct ctl_table rds_tcp_sysctl_table[] = {
+#define	RDS_TCP_SNDBUF	0
+	{
+		.procname       = "rds_tcp_sndbuf",
+		/* data is per-net pointer */
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = rds_tcp_skbuf_handler,
+		.extra1		= &rds_tcp_min_sndbuf,
+	},
+#define	RDS_TCP_RCVBUF	1
+	{
+		.procname       = "rds_tcp_rcvbuf",
+		/* data is per-net pointer */
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = rds_tcp_skbuf_handler,
+		.extra1		= &rds_tcp_min_rcvbuf,
+	},
+	{ }
+};
+
 /* doing it this way avoids calling tcp_sk() */
 void rds_tcp_nonagle(struct socket *sock)
 {
@@ -66,15 +95,6 @@ void rds_tcp_nonagle(struct socket *sock)
 	set_fs(oldfs);
 }
 
-/* All module specific customizations to the RDS-TCP socket should be done in
- * rds_tcp_tune() and applied after socket creation. In general these
- * customizations should be tunable via module_param()
- */
-void rds_tcp_tune(struct socket *sock)
-{
-	rds_tcp_nonagle(sock);
-}
-
 u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc)
 {
 	return tcp_sk(tc->t_sock->sk)->snd_nxt;
@@ -272,8 +292,34 @@ static int rds_tcp_netid;
 struct rds_tcp_net {
 	struct socket *rds_tcp_listen_sock;
 	struct work_struct rds_tcp_accept_w;
+	struct ctl_table_header *rds_tcp_sysctl;
+	struct ctl_table *ctl_table;
+	int sndbuf_size;
+	int rcvbuf_size;
 };
 
+/* All module specific customizations to the RDS-TCP socket should be done in
+ * rds_tcp_tune() and applied after socket creation.
+ */
+void rds_tcp_tune(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
+	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+
+	rds_tcp_nonagle(sock);
+	lock_sock(sk);
+	if (rtn->sndbuf_size > 0) {
+		sk->sk_sndbuf = rtn->sndbuf_size;
+		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
+	}
+	if (rtn->rcvbuf_size > 0) {
+		sk->sk_sndbuf = rtn->rcvbuf_size;
+		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
+	}
+	release_sock(sk);
+}
+
 static void rds_tcp_accept_worker(struct work_struct *work)
 {
 	struct rds_tcp_net *rtn = container_of(work,
@@ -295,20 +341,60 @@ void rds_tcp_accept_work(struct sock *sk)
 static __net_init int rds_tcp_init_net(struct net *net)
 {
 	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+	struct ctl_table *tbl;
+	int err = 0;
 
+	memset(rtn, 0, sizeof(*rtn));
+
+	/* {snd, rcv}buf_size default to 0, which implies we let the
+	 * stack pick the value, and permit auto-tuning of buffer size.
+	 */
+	if (net == &init_net) {
+		tbl = rds_tcp_sysctl_table;
+	} else {
+		tbl = kmemdup(rds_tcp_sysctl_table,
+			      sizeof(rds_tcp_sysctl_table), GFP_KERNEL);
+		if (!tbl) {
+			pr_warn("could not set allocate syctl table\n");
+			return -ENOMEM;
+		}
+		rtn->ctl_table = tbl;
+	}
+	tbl[RDS_TCP_SNDBUF].data = &rtn->sndbuf_size;
+	tbl[RDS_TCP_RCVBUF].data = &rtn->rcvbuf_size;
+	rtn->rds_tcp_sysctl = register_net_sysctl(net, "net/rds/tcp", tbl);
+	if (!rtn->rds_tcp_sysctl) {
+		pr_warn("could not register sysctl\n");
+		err = -ENOMEM;
+		goto fail;
+	}
 	rtn->rds_tcp_listen_sock = rds_tcp_listen_init(net);
 	if (!rtn->rds_tcp_listen_sock) {
 		pr_warn("could not set up listen sock\n");
-		return -EAFNOSUPPORT;
+		unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
+		rtn->rds_tcp_sysctl = NULL;
+		err = -EAFNOSUPPORT;
+		goto fail;
 	}
 	INIT_WORK(&rtn->rds_tcp_accept_w, rds_tcp_accept_worker);
 	return 0;
+
+fail:
+	if (net != &init_net)
+		kfree(tbl);
+	return err;
 }
 
 static void __net_exit rds_tcp_exit_net(struct net *net)
 {
 	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
 
+	if (rtn->rds_tcp_sysctl)
+		unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
+
+	if (net != &init_net && rtn->ctl_table)
+		kfree(rtn->ctl_table);
+
 	/* If rds_tcp_exit_net() is called as a result of netns deletion,
 	 * the rds_tcp_kill_sock() device notifier would already have cleaned
 	 * up the listen socket, thus there is no work to do in this function.
@@ -383,6 +469,45 @@ static struct notifier_block rds_tcp_dev_notifier = {
 	.priority = -10, /* must be called after other network notifiers */
 };
 
+/* when sysctl is used to modify some kernel socket parameters,this
+ * function  resets the RDS connections in that netns  so that we can
+ * restart with new parameters.  The assumption is that such reset
+ * events are few and far-between.
+ */
+static void rds_tcp_sysctl_reset(struct net *net)
+{
+	struct rds_tcp_connection *tc, *_tc;
+
+	spin_lock_irq(&rds_tcp_conn_lock);
+	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
+		struct net *c_net = read_pnet(&tc->conn->c_net);
+
+		if (net != c_net || !tc->t_sock)
+			continue;
+
+		rds_conn_drop(tc->conn); /* reconnect with new parameters */
+	}
+	spin_unlock_irq(&rds_tcp_conn_lock);
+}
+
+static int rds_tcp_skbuf_handler(struct ctl_table *ctl, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *fpos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int err;
+
+	err = proc_dointvec_minmax(ctl, write, buffer, lenp, fpos);
+	if (err < 0) {
+		pr_warn("Invalid input. Must be >= %d\n",
+			*(int *)(ctl->extra1));
+		return err;
+	}
+	if (write)
+		rds_tcp_sysctl_reset(net);
+	return 0;
+}
+
 static void rds_tcp_exit(void)
 {
 	rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
-- 
1.7.1
