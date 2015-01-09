From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 14/16] tipc: make subscriber
	server support net namespace
Date: Fri, 9 Jan 2015 15:27:11 +0800
Message-ID: <1420788433-17960-15-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC establishes one subscriber server which allows users to subscribe
their interesting name service status. After tipc supports namespace,
one dedicated tipc stack instance is created for each namespace, and
each instance can be deemed as one independent TIPC node. As a result,
subscriber server must be built for each namespace.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/core.c   |   24 ++++++-------
 net/tipc/core.h   |    4 +++
 net/tipc/server.c |    2 +-
 net/tipc/server.h |    4 ++-
 net/tipc/socket.c |    4 +--
 net/tipc/socket.h |    2 +-
 net/tipc/subscr.c |  104 +++++++++++++++++++++++++++++++----------------------
 net/tipc/subscr.h |    7 ++--
 8 files changed, 86 insertions(+), 65 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 7c09670..4a8b795 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -68,8 +68,14 @@ static int __net_init tipc_init_net(struct net *net)
 	err = tipc_nametbl_init(net);
 	if (err)
 		goto out_nametbl;
+
+	err = tipc_subscr_start(net);
+	if (err)
+		goto out_subscr;
 	return 0;
 
+out_subscr:
+	tipc_nametbl_stop(net);
 out_nametbl:
 	tipc_sk_rht_destroy(net);
 out_sk_rht:
@@ -78,6 +84,7 @@ out_sk_rht:
 
 static void __net_exit tipc_exit_net(struct net *net)
 {
+	tipc_subscr_stop(net);
 	tipc_net_stop(net);
 	tipc_nametbl_stop(net);
 	tipc_sk_rht_destroy(net);
@@ -104,10 +111,6 @@ static int __init tipc_init(void)
 
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
 
-	err = register_pernet_subsys(&tipc_net_ops);
-	if (err)
-		goto out_pernet;
-
 	err = tipc_netlink_start();
 	if (err)
 		goto out_netlink;
@@ -120,9 +123,9 @@ static int __init tipc_init(void)
 	if (err)
 		goto out_sysctl;
 
-	err = tipc_subscr_start();
+	err = register_pernet_subsys(&tipc_net_ops);
 	if (err)
-		goto out_subscr;
+		goto out_pernet;
 
 	err = tipc_bearer_setup();
 	if (err)
@@ -131,28 +134,25 @@ static int __init tipc_init(void)
 	pr_info("Started in single node mode\n");
 	return 0;
 out_bearer:
-	tipc_subscr_stop();
-out_subscr:
+	unregister_pernet_subsys(&tipc_net_ops);
+out_pernet:
 	tipc_unregister_sysctl();
 out_sysctl:
 	tipc_socket_stop();
 out_socket:
 	tipc_netlink_stop();
 out_netlink:
-	unregister_pernet_subsys(&tipc_net_ops);
-out_pernet:
 	pr_err("Unable to start in single node mode\n");
 	return err;
 }
 
 static void __exit tipc_exit(void)
 {
-	unregister_pernet_subsys(&tipc_net_ops);
 	tipc_bearer_cleanup();
 	tipc_netlink_stop();
-	tipc_subscr_stop();
 	tipc_socket_stop();
 	tipc_unregister_sysctl();
+	unregister_pernet_subsys(&tipc_net_ops);
 
 	pr_info("Deactivated\n");
 }
diff --git a/net/tipc/core.h b/net/tipc/core.h
index afabf39..639f562 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -106,6 +106,10 @@ struct tipc_net {
 	/* Name table */
 	spinlock_t nametbl_lock;
 	struct name_table *nametbl;
+
+	/* Topology subscription server */
+	struct tipc_server *topsrv;
+	atomic_t subscription_count;
 };
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/tipc/server.c b/net/tipc/server.c
index b5bdaf7..eadd4ed 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -309,7 +309,7 @@ static struct socket *tipc_create_listen_sock(struct tipc_conn *con)
 	struct socket *sock = NULL;
 	int ret;
 
-	ret = tipc_sock_create_local(s->type, &sock);
+	ret = tipc_sock_create_local(s->net, s->type, &sock);
 	if (ret < 0)
 		return NULL;
 	ret = kernel_setsockopt(sock, SOL_TIPC, TIPC_IMPORTANCE,
diff --git a/net/tipc/server.h b/net/tipc/server.h
index 9c979a0..9015fae 100644
--- a/net/tipc/server.h
+++ b/net/tipc/server.h
@@ -47,6 +47,7 @@
  * @conn_idr: identifier set of connection
  * @idr_lock: protect the connection identifier set
  * @idr_in_use: amount of allocated identifier entry
+ * @net: network namspace instance
  * @rcvbuf_cache: memory cache of server receive buffer
  * @rcv_wq: receive workqueue
  * @send_wq: send workqueue
@@ -63,6 +64,7 @@ struct tipc_server {
 	struct idr conn_idr;
 	spinlock_t idr_lock;
 	int idr_in_use;
+	struct net *net;
 	struct kmem_cache *rcvbuf_cache;
 	struct workqueue_struct *rcv_wq;
 	struct workqueue_struct *send_wq;
@@ -73,7 +75,7 @@ struct tipc_server {
 				  struct sockaddr_tipc *addr, void *usr_data,
 				  void *buf, size_t len);
 	struct sockaddr_tipc *saddr;
-	const char name[TIPC_SERVER_NAME_LEN];
+	char name[TIPC_SERVER_NAME_LEN];
 	int imp;
 	int type;
 };
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9b8470e..2cec496 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -388,7 +388,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
  *
  * Returns 0 on success, errno otherwise
  */
-int tipc_sock_create_local(int type, struct socket **res)
+int tipc_sock_create_local(struct net *net, int type, struct socket **res)
 {
 	int rc;
 
@@ -397,7 +397,7 @@ int tipc_sock_create_local(int type, struct socket **res)
 		pr_err("Failed to create kernel socket\n");
 		return rc;
 	}
-	tipc_sk_create(&init_net, *res, 0, 1);
+	tipc_sk_create(net, *res, 0, 1);
 
 	return 0;
 }
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index c15c4e1..f56c3fd 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -45,7 +45,7 @@
 
 int tipc_socket_init(void);
 void tipc_socket_stop(void);
-int tipc_sock_create_local(int type, struct socket **res);
+int tipc_sock_create_local(struct net *net, int type, struct socket **res);
 void tipc_sock_release_local(struct socket *sock);
 int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
 			   int flags);
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index b71dbc0..72c339e 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -50,34 +50,6 @@ struct tipc_subscriber {
 	struct list_head subscription_list;
 };
 
-static void subscr_conn_msg_event(struct net *net, int conid,
-				  struct sockaddr_tipc *addr, void *usr_data,
-				  void *buf, size_t len);
-static void *subscr_named_msg_event(int conid);
-static void subscr_conn_shutdown_event(int conid, void *usr_data);
-
-static atomic_t subscription_count = ATOMIC_INIT(0);
-
-static struct sockaddr_tipc topsrv_addr __read_mostly = {
-	.family			= AF_TIPC,
-	.addrtype		= TIPC_ADDR_NAMESEQ,
-	.addr.nameseq.type	= TIPC_TOP_SRV,
-	.addr.nameseq.lower	= TIPC_TOP_SRV,
-	.addr.nameseq.upper	= TIPC_TOP_SRV,
-	.scope			= TIPC_NODE_SCOPE
-};
-
-static struct tipc_server topsrv __read_mostly = {
-	.saddr			= &topsrv_addr,
-	.imp			= TIPC_CRITICAL_IMPORTANCE,
-	.type			= SOCK_SEQPACKET,
-	.max_rcvbuf_size	= sizeof(struct tipc_subscr),
-	.name			= "topology_server",
-	.tipc_conn_recvmsg	= subscr_conn_msg_event,
-	.tipc_conn_new		= subscr_named_msg_event,
-	.tipc_conn_shutdown	= subscr_conn_shutdown_event,
-};
-
 /**
  * htohl - convert value to endianness used by destination
  * @in: value to convert
@@ -94,6 +66,7 @@ static void subscr_send_event(struct tipc_subscription *sub, u32 found_lower,
 			      u32 found_upper, u32 event, u32 port_ref,
 			      u32 node)
 {
+	struct tipc_net *tn = net_generic(sub->net, tipc_net_id);
 	struct tipc_subscriber *subscriber = sub->subscriber;
 	struct kvec msg_sect;
 
@@ -104,8 +77,8 @@ static void subscr_send_event(struct tipc_subscription *sub, u32 found_lower,
 	sub->evt.found_upper = htohl(found_upper, sub->swap);
 	sub->evt.port.ref = htohl(port_ref, sub->swap);
 	sub->evt.port.node = htohl(node, sub->swap);
-	tipc_conn_sendmsg(&topsrv, subscriber->conid, NULL, msg_sect.iov_base,
-			  msg_sect.iov_len);
+	tipc_conn_sendmsg(tn->topsrv, subscriber->conid, NULL,
+			  msg_sect.iov_base, msg_sect.iov_len);
 }
 
 /**
@@ -146,6 +119,7 @@ static void subscr_timeout(unsigned long data)
 {
 	struct tipc_subscription *sub = (struct tipc_subscription *)data;
 	struct tipc_subscriber *subscriber = sub->subscriber;
+	struct tipc_net *tn = net_generic(sub->net, tipc_net_id);
 
 	/* The spin lock per subscriber is used to protect its members */
 	spin_lock_bh(&subscriber->lock);
@@ -170,7 +144,7 @@ static void subscr_timeout(unsigned long data)
 
 	/* Now destroy subscription */
 	kfree(sub);
-	atomic_dec(&subscription_count);
+	atomic_dec(&tn->subscription_count);
 }
 
 /**
@@ -180,10 +154,12 @@ static void subscr_timeout(unsigned long data)
  */
 static void subscr_del(struct tipc_subscription *sub)
 {
+	struct tipc_net *tn = net_generic(sub->net, tipc_net_id);
+
 	tipc_nametbl_unsubscribe(sub);
 	list_del(&sub->subscription_list);
 	kfree(sub);
-	atomic_dec(&subscription_count);
+	atomic_dec(&tn->subscription_count);
 }
 
 /**
@@ -191,9 +167,12 @@ static void subscr_del(struct tipc_subscription *sub)
  *
  * Note: Must call it in process context since it might sleep.
  */
-static void subscr_terminate(struct tipc_subscriber *subscriber)
+static void subscr_terminate(struct tipc_subscription *sub)
 {
-	tipc_conn_terminate(&topsrv, subscriber->conid);
+	struct tipc_subscriber *subscriber = sub->subscriber;
+	struct tipc_net *tn = net_generic(sub->net, tipc_net_id);
+
+	tipc_conn_terminate(tn->topsrv, subscriber->conid);
 }
 
 static void subscr_release(struct tipc_subscriber *subscriber)
@@ -263,7 +242,9 @@ static void subscr_cancel(struct tipc_subscr *s,
  */
 static int subscr_subscribe(struct net *net, struct tipc_subscr *s,
 			    struct tipc_subscriber *subscriber,
-			    struct tipc_subscription **sub_p) {
+			    struct tipc_subscription **sub_p)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_subscription *sub;
 	int swap;
 
@@ -278,7 +259,7 @@ static int subscr_subscribe(struct net *net, struct tipc_subscr *s,
 	}
 
 	/* Refuse subscription if global limit exceeded */
-	if (atomic_read(&subscription_count) >= TIPC_MAX_SUBSCRIPTIONS) {
+	if (atomic_read(&tn->subscription_count) >= TIPC_MAX_SUBSCRIPTIONS) {
 		pr_warn("Subscription rejected, limit reached (%u)\n",
 			TIPC_MAX_SUBSCRIPTIONS);
 		return -EINVAL;
@@ -309,7 +290,7 @@ static int subscr_subscribe(struct net *net, struct tipc_subscr *s,
 	sub->subscriber = subscriber;
 	sub->swap = swap;
 	memcpy(&sub->evt.s, s, sizeof(struct tipc_subscr));
-	atomic_inc(&subscription_count);
+	atomic_inc(&tn->subscription_count);
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
 		setup_timer(&sub->timer, subscr_timeout, (unsigned long)sub);
 		mod_timer(&sub->timer, jiffies + sub->timeout);
@@ -336,7 +317,7 @@ static void subscr_conn_msg_event(struct net *net, int conid,
 	if (subscr_subscribe(net, (struct tipc_subscr *)buf, subscriber,
 			     &sub) < 0) {
 		spin_unlock_bh(&subscriber->lock);
-		subscr_terminate(subscriber);
+		subscr_terminate(sub);
 		return;
 	}
 	if (sub)
@@ -344,7 +325,6 @@ static void subscr_conn_msg_event(struct net *net, int conid,
 	spin_unlock_bh(&subscriber->lock);
 }
 
-
 /* Handle one request to establish a new subscriber */
 static void *subscr_named_msg_event(int conid)
 {
@@ -363,12 +343,50 @@ static void *subscr_named_msg_event(int conid)
 	return (void *)subscriber;
 }
 
-int tipc_subscr_start(void)
+int tipc_subscr_start(struct net *net)
 {
-	return tipc_server_start(&topsrv);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	const char name[] = "topology_server";
+	struct tipc_server *topsrv;
+	struct sockaddr_tipc *saddr;
+
+	saddr = kzalloc(sizeof(*saddr), GFP_ATOMIC);
+	if (!saddr)
+		return -ENOMEM;
+	saddr->family			= AF_TIPC;
+	saddr->addrtype			= TIPC_ADDR_NAMESEQ;
+	saddr->addr.nameseq.type	= TIPC_TOP_SRV;
+	saddr->addr.nameseq.lower	= TIPC_TOP_SRV;
+	saddr->addr.nameseq.upper	= TIPC_TOP_SRV;
+	saddr->scope			= TIPC_NODE_SCOPE;
+
+	topsrv = kzalloc(sizeof(*topsrv), GFP_ATOMIC);
+	if (!topsrv) {
+		kfree(saddr);
+		return -ENOMEM;
+	}
+	topsrv->net			= net;
+	topsrv->saddr			= saddr;
+	topsrv->imp			= TIPC_CRITICAL_IMPORTANCE;
+	topsrv->type			= SOCK_SEQPACKET;
+	topsrv->max_rcvbuf_size		= sizeof(struct tipc_subscr);
+	topsrv->tipc_conn_recvmsg	= subscr_conn_msg_event;
+	topsrv->tipc_conn_new		= subscr_named_msg_event;
+	topsrv->tipc_conn_shutdown	= subscr_conn_shutdown_event;
+
+	strncpy(topsrv->name, name, strlen(name) + 1);
+	tn->topsrv = topsrv;
+	atomic_set(&tn->subscription_count, 0);
+
+	return tipc_server_start(topsrv);
 }
 
-void tipc_subscr_stop(void)
+void tipc_subscr_stop(struct net *net)
 {
-	tipc_server_stop(&topsrv);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_server *topsrv = tn->topsrv;
+
+	tipc_server_stop(topsrv);
+	kfree(topsrv->saddr);
+	kfree(topsrv);
 }
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 670f570..33488bd 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -74,13 +74,10 @@ struct tipc_subscription {
 
 int tipc_subscr_overlap(struct tipc_subscription *sub, u32 found_lower,
 			u32 found_upper);
-
 void tipc_subscr_report_overlap(struct tipc_subscription *sub, u32 found_lower,
 				u32 found_upper, u32 event, u32 port_ref,
 				u32 node, int must);
-
-int tipc_subscr_start(void);
-
-void tipc_subscr_stop(void);
+int tipc_subscr_start(struct net *net);
+void tipc_subscr_stop(struct net *net);
 
 #endif
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
