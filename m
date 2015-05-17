From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v4 for-next 11/12] IB/cma: Add support for network namespaces
Date: Sun, 17 May 2015 08:51:07 +0300
Message-ID: <1431841868-28063-12-git-send-email-haggaie@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:34509 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751896AbbEQFwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 01:52:32 -0400
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Add support for network namespaces in the ib_cma module. This is
accomplished by:

1. Adding network namespace parameter for rdma_create_id. This parameter is
   used to populate the network namespace field in rdma_id_private.
   rdma_create_id keeps a reference on the network namespace.
2. Using the network namespace from the rdma_id instead of init_net inside
   of ib_cma, when listening on an ID and when looking for an ID for an
   incoming request.
3. Decrementing the reference count for the appropriate network namespace
   when calling rdma_destroy_id.

In order to preserve the current behavior init_net is passed when calling
from other modules.

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
---
 drivers/infiniband/core/cma.c                      | 42 +++++++++++++---------
 drivers/infiniband/core/ucma.c                     |  3 +-
 drivers/infiniband/ulp/iser/iser_verbs.c           |  2 +-
 drivers/infiniband/ulp/isert/ib_isert.c            |  2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  4 ++-
 include/rdma/rdma_cm.h                             |  6 +++-
 net/9p/trans_rdma.c                                |  4 +--
 net/rds/ib.c                                       |  2 +-
 net/rds/ib_cm.c                                    |  2 +-
 net/rds/iw.c                                       |  2 +-
 net/rds/iw_cm.c                                    |  2 +-
 net/rds/rdma_transport.c                           |  4 +--
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |  4 +--
 net/sunrpc/xprtrdma/verbs.c                        |  3 +-
 14 files changed, 50 insertions(+), 32 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index e5d389ffa497..da4b48537111 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -553,7 +553,8 @@ static int cma_disable_callback(struct rdma_id_private *id_priv,
 	return 0;
 }
 
-struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
+struct rdma_cm_id *rdma_create_id(struct net *net,
+				  rdma_cm_event_handler event_handler,
 				  void *context, enum rdma_port_space ps,
 				  enum ib_qp_type qp_type)
 {
@@ -577,7 +578,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 	INIT_LIST_HEAD(&id_priv->listen_list);
 	INIT_LIST_HEAD(&id_priv->mc_list);
 	get_random_bytes(&id_priv->seq_num, sizeof id_priv->seq_num);
-	id_priv->id.route.addr.dev_addr.net = &init_net;
+	id_priv->id.route.addr.dev_addr.net = get_net(net);
 
 	return &id_priv->id;
 }
@@ -1178,6 +1179,7 @@ static void cma_cancel_operation(struct rdma_id_private *id_priv,
 static void cma_release_port(struct rdma_id_private *id_priv)
 {
 	struct rdma_bind_list *bind_list = id_priv->bind_list;
+	struct net *net = id_priv->id.route.addr.dev_addr.net;
 
 	if (!bind_list)
 		return;
@@ -1185,7 +1187,7 @@ static void cma_release_port(struct rdma_id_private *id_priv)
 	mutex_lock(&lock);
 	hlist_del(&id_priv->node);
 	if (hlist_empty(&bind_list->owners)) {
-		cma_ps_remove(&init_net, bind_list->ps, bind_list->port);
+		cma_ps_remove(net, bind_list->ps, bind_list->port);
 		kfree(bind_list);
 	}
 	mutex_unlock(&lock);
@@ -1244,6 +1246,7 @@ void rdma_destroy_id(struct rdma_cm_id *id)
 		cma_deref_id(id_priv->id.context);
 
 	kfree(id_priv->id.route.path_rec);
+	put_net(id_priv->id.route.addr.dev_addr.net);
 	kfree(id_priv);
 }
 EXPORT_SYMBOL(rdma_destroy_id);
@@ -1373,7 +1376,8 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 		      ib_event->param.req_rcvd.primary_path->service_id;
 	int ret;
 
-	id = rdma_create_id(listen_id->event_handler, listen_id->context,
+	id = rdma_create_id(listen_id->route.addr.dev_addr.net,
+			    listen_id->event_handler, listen_id->context,
 			    listen_id->ps, ib_event->param.req_rcvd.qp_type);
 	if (IS_ERR(id))
 		return NULL;
@@ -1419,9 +1423,10 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 {
 	struct rdma_id_private *id_priv;
 	struct rdma_cm_id *id;
+	struct net *net = listen_id->route.addr.dev_addr.net;
 	int ret;
 
-	id = rdma_create_id(listen_id->event_handler, listen_id->context,
+	id = rdma_create_id(net, listen_id->event_handler, listen_id->context,
 			    listen_id->ps, IB_QPT_UD);
 	if (IS_ERR(id))
 		return NULL;
@@ -1676,7 +1681,8 @@ static int iw_conn_req_handler(struct iw_cm_id *cm_id,
 		return -ECONNABORTED;
 
 	/* Create a new RDMA id for the new IW CM ID */
-	new_cm_id = rdma_create_id(listen_id->id.event_handler,
+	new_cm_id = rdma_create_id(listen_id->id.route.addr.dev_addr.net,
+				   listen_id->id.event_handler,
 				   listen_id->id.context,
 				   RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(new_cm_id)) {
@@ -1808,12 +1814,13 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 {
 	struct rdma_id_private *dev_id_priv;
 	struct rdma_cm_id *id;
+	struct net *net = id_priv->id.route.addr.dev_addr.net;
 	int ret;
 
 	if (cma_family(id_priv) == AF_IB && !rdma_cap_ib_cm(cma_dev->device, 1))
 		return;
 
-	id = rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
+	id = rdma_create_id(net, cma_listen_handler, id_priv, id_priv->id.ps,
 			    id_priv->id.qp_type);
 	if (IS_ERR(id))
 		return;
@@ -2483,7 +2490,8 @@ static int cma_alloc_port(enum rdma_port_space ps,
 	if (!bind_list)
 		return -ENOMEM;
 
-	ret = cma_ps_alloc(&init_net, ps, bind_list, snum);
+	ret = cma_ps_alloc(id_priv->id.route.addr.dev_addr.net, ps, bind_list,
+			   snum);
 	if (ret < 0)
 		goto err;
 
@@ -2502,13 +2510,14 @@ static int cma_alloc_any_port(enum rdma_port_space ps,
 	static unsigned int last_used_port;
 	int low, high, remaining;
 	unsigned int rover;
+	struct net *net = id_priv->id.route.addr.dev_addr.net;
 
-	inet_get_local_port_range(&init_net, &low, &high);
+	inet_get_local_port_range(net, &low, &high);
 	remaining = (high - low) + 1;
 	rover = prandom_u32() % remaining + low;
 retry:
 	if (last_used_port != rover &&
-	    !cma_ps_find(&init_net, ps, (unsigned short)rover)) {
+	    !cma_ps_find(net, ps, (unsigned short)rover)) {
 		int ret = cma_alloc_port(ps, id_priv, rover);
 		/*
 		 * Remember previously used port number in order to avoid
@@ -2574,7 +2583,7 @@ static int cma_use_port(enum rdma_port_space ps,
 	if (snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
-	bind_list = cma_ps_find(&init_net, ps, snum);
+	bind_list = cma_ps_find(id_priv->id.route.addr.dev_addr.net, ps, snum);
 	if (!bind_list) {
 		ret = cma_alloc_port(ps, id_priv, snum);
 	} else {
@@ -2766,8 +2775,11 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
 		if (addr->sa_family == AF_INET)
 			id_priv->afonly = 1;
 #if IS_ENABLED(CONFIG_IPV6)
-		else if (addr->sa_family == AF_INET6)
-			id_priv->afonly = init_net.ipv6.sysctl.bindv6only;
+		else if (addr->sa_family == AF_INET6) {
+			struct net *net = id_priv->id.route.addr.dev_addr.net;
+
+			id_priv->afonly = net->ipv6.sysctl.bindv6only;
+		}
 #endif
 	}
 	ret = cma_get_port(id_priv);
@@ -3571,6 +3583,7 @@ static int cma_netdev_change(struct net_device *ndev, struct rdma_id_private *id
 	dev_addr = &id_priv->id.route.addr.dev_addr;
 
 	if ((dev_addr->bound_dev_if == ndev->ifindex) &&
+	    (net_eq(dev_net(ndev), dev_addr->net)) &&
 	    memcmp(dev_addr->src_dev_addr, ndev->dev_addr, ndev->addr_len)) {
 		printk(KERN_INFO "RDMA CM addr change for ndev %s used by id %p\n",
 		       ndev->name, &id_priv->id);
@@ -3596,9 +3609,6 @@ static int cma_netdev_callback(struct notifier_block *self, unsigned long event,
 	struct rdma_id_private *id_priv;
 	int ret = NOTIFY_DONE;
 
-	if (dev_net(ndev) != &init_net)
-		return NOTIFY_DONE;
-
 	if (event != NETDEV_BONDING_FAILOVER)
 		return NOTIFY_DONE;
 
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index d42b816c781f..44670ad5ba10 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -391,7 +391,8 @@ static ssize_t ucma_create_id(struct ucma_file *file, const char __user *inbuf,
 		return -ENOMEM;
 
 	ctx->uid = cmd.uid;
-	ctx->cm_id = rdma_create_id(ucma_event_handler, ctx, cmd.ps, qp_type);
+	ctx->cm_id = rdma_create_id(&init_net, ucma_event_handler, ctx, cmd.ps,
+				    qp_type);
 	if (IS_ERR(ctx->cm_id)) {
 		ret = PTR_ERR(ctx->cm_id);
 		goto err1;
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index cc2dd35ffbc0..5517333738a8 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -960,7 +960,7 @@ int iser_connect(struct iser_conn   *iser_conn,
 	ib_conn->beacon.wr_id = ISER_BEACON_WRID;
 	ib_conn->beacon.opcode = IB_WR_SEND;
 
-	ib_conn->cma_id = rdma_create_id(iser_cma_handler,
+	ib_conn->cma_id = rdma_create_id(&init_net, iser_cma_handler,
 					 (void *)iser_conn,
 					 RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(ib_conn->cma_id)) {
diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 327529ee85eb..746d05ef2cea 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -3043,7 +3043,7 @@ isert_setup_id(struct isert_np *isert_np)
 	sa = (struct sockaddr *)&np->np_sockaddr;
 	isert_dbg("ksockaddr: %p, sa: %p\n", &np->np_sockaddr, sa);
 
-	id = rdma_create_id(isert_cma_handler, isert_np,
+	id = rdma_create_id(&init_net, isert_cma_handler, isert_np,
 			    RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(id)) {
 		isert_err("rdma_create_id() failed: %ld\n", PTR_ERR(id));
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index cd664d025f41..f4aab7485a84 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -125,7 +125,9 @@ extern kib_tunables_t  kiblnd_tunables;
 				     IBLND_CREDIT_HIGHWATER_V1 : \
 				     *kiblnd_tunables.kib_peercredits_hiw) /* when eagerly to return credits */
 
-#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(cb, dev, ps, qpt)
+#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(&init_net, \
+							       cb, dev, \
+							       ps, qpt)
 
 static inline int
 kiblnd_concurrent_sends_v1(void)
diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
index 1ed2088dc9f5..f45566f8dc1a 100644
--- a/include/rdma/rdma_cm.h
+++ b/include/rdma/rdma_cm.h
@@ -158,13 +158,17 @@ struct rdma_cm_id {
 /**
  * rdma_create_id - Create an RDMA identifier.
  *
+ * @net: The network namespace in which to create the new id.
  * @event_handler: User callback invoked to report events associated with the
  *   returned rdma_id.
  * @context: User specified context associated with the id.
  * @ps: RDMA port space.
  * @qp_type: type of queue pair associated with the id.
+ *
+ * The id holds a reference on the network namespace until it is destroyed.
  */
-struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
+struct rdma_cm_id *rdma_create_id(struct net *net,
+				  rdma_cm_event_handler event_handler,
 				  void *context, enum rdma_port_space ps,
 				  enum ib_qp_type qp_type);
 
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 3533d2a53ab6..8bc3b5cbedf1 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -660,8 +660,8 @@ rdma_create_trans(struct p9_client *client, const char *addr, char *args)
 		return -ENOMEM;
 
 	/* Create the RDMA CM ID */
-	rdma->cm_id = rdma_create_id(p9_cm_event_handler, client, RDMA_PS_TCP,
-				     IB_QPT_RC);
+	rdma->cm_id = rdma_create_id(&init_net, p9_cm_event_handler, client,
+				     RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(rdma->cm_id))
 		goto error;
 
diff --git a/net/rds/ib.c b/net/rds/ib.c
index ba2dffeff608..c68e7b606975 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -326,7 +326,7 @@ static int rds_ib_laddr_check(__be32 addr)
 	/* Create a CMA ID and try to bind it. This catches both
 	 * IB and iWARP capable NICs.
 	 */
-	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
+	cm_id = rdma_create_id(&init_net, NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(cm_id))
 		return PTR_ERR(cm_id);
 
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 31b74f5e61ad..0640f66d5d9e 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -583,7 +583,7 @@ int rds_ib_conn_connect(struct rds_connection *conn)
 
 	/* XXX I wonder what affect the port space has */
 	/* delegate cm event handler to rdma_transport */
-	ic->i_cm_id = rdma_create_id(rds_rdma_cm_event_handler, conn,
+	ic->i_cm_id = rdma_create_id(&init_net, rds_rdma_cm_event_handler, conn,
 				     RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(ic->i_cm_id)) {
 		ret = PTR_ERR(ic->i_cm_id);
diff --git a/net/rds/iw.c b/net/rds/iw.c
index 589935661d66..230da79e62a1 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -227,7 +227,7 @@ static int rds_iw_laddr_check(__be32 addr)
 	/* Create a CMA ID and try to bind it. This catches both
 	 * IB and iWARP capable NICs.
 	 */
-	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
+	cm_id = rdma_create_id(&init_net, NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(cm_id))
 		return PTR_ERR(cm_id);
 
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index a6c2bea9f8f9..5c18819f13fc 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -520,7 +520,7 @@ int rds_iw_conn_connect(struct rds_connection *conn)
 
 	/* XXX I wonder what affect the port space has */
 	/* delegate cm event handler to rdma_transport */
-	ic->i_cm_id = rdma_create_id(rds_rdma_cm_event_handler, conn,
+	ic->i_cm_id = rdma_create_id(&init_net, rds_rdma_cm_event_handler, conn,
 				     RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(ic->i_cm_id)) {
 		ret = PTR_ERR(ic->i_cm_id);
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 6cd9d1deafc3..0c88f24aed85 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -159,8 +159,8 @@ static int rds_rdma_listen_init(void)
 	struct rdma_cm_id *cm_id;
 	int ret;
 
-	cm_id = rdma_create_id(rds_rdma_cm_event_handler, NULL, RDMA_PS_TCP,
-			       IB_QPT_RC);
+	cm_id = rdma_create_id(&init_net, rds_rdma_cm_event_handler, NULL,
+			       RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(cm_id)) {
 		ret = PTR_ERR(cm_id);
 		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 3df8320c6efe..6d5c61c2b381 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -704,8 +704,8 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	if (!cma_xprt)
 		return ERR_PTR(-ENOMEM);
 
-	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP,
-				   IB_QPT_RC);
+	listen_id = rdma_create_id(&init_net, rdma_listen_handler, cma_xprt,
+				   RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(listen_id)) {
 		ret = PTR_ERR(listen_id);
 		dprintk("svcrdma: rdma_create_id failed = %d\n", ret);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4870d272e006..12d225359e8d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -509,7 +509,8 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 
 	init_completion(&ia->ri_done);
 
-	id = rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP, IB_QPT_RC);
+	id = rdma_create_id(&init_net, rpcrdma_conn_upcall, xprt, RDMA_PS_TCP,
+			    IB_QPT_RC);
 	if (IS_ERR(id)) {
 		rc = PTR_ERR(id);
 		dprintk("RPC:       %s: rdma_create_id() failed %i\n",
-- 
1.7.11.2
