From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH v1 08/10] IB/cma: Add support for network namespaces
Date: Wed, 11 Feb 2015 17:06:42 +0200
Message-ID: <1423667204-8807-9-git-send-email-raindel@mellanox.com>
References: <1423667204-8807-1-git-send-email-raindel@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.com, guysh@mellanox.com, haggaie@mellanox.com,
	yotamke@mellanox.com, raindel@mellanox.com
To: roland@kernel.org, sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53766 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753216AbbBKPLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2015 10:11:45 -0500
In-Reply-To: <1423667204-8807-1-git-send-email-raindel@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Add support for network namespaces in the ib_cma module. This is
accomplished by:

1. Adding network namespace parameter for rdma_create_id. This parameter is used
   to populate the network namespace field in rdma_id_private. rdma_create_id
   keeps a reference on the network namespace.
2. Using the network namespace from the rdma_id instead of init_net inside of
   ib_cma.
3. Decrementing the reference count for the appropriate network namespace when
   calling rdma_destroy_id.

In order to preserve the current behavior init_net is passed when calling from
other modules.

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>

---
 drivers/infiniband/core/cma.c                      | 52 +++++++++++++---------
 drivers/infiniband/core/ucma.c                     |  3 +-
 drivers/infiniband/ulp/iser/iser_verbs.c           |  2 +-
 drivers/infiniband/ulp/isert/ib_isert.c            |  2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  4 +-
 include/rdma/rdma_cm.h                             |  6 ++-
 net/9p/trans_rdma.c                                |  2 +-
 net/rds/ib.c                                       |  2 +-
 net/rds/ib_cm.c                                    |  2 +-
 net/rds/iw.c                                       |  2 +-
 net/rds/iw_cm.c                                    |  2 +-
 net/rds/rdma_transport.c                           |  2 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |  2 +-
 net/sunrpc/xprtrdma/verbs.c                        |  3 +-
 14 files changed, 52 insertions(+), 34 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 022b0d0..9ea42fe 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -540,7 +540,8 @@ static int cma_disable_callback(struct rdma_id_private *id_priv,
 
 struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 				  void *context, enum rdma_port_space ps,
-				  enum ib_qp_type qp_type)
+				  enum ib_qp_type qp_type,
+				  struct net *net)
 {
 	struct rdma_id_private *id_priv;
 
@@ -562,7 +563,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 	INIT_LIST_HEAD(&id_priv->listen_list);
 	INIT_LIST_HEAD(&id_priv->mc_list);
 	get_random_bytes(&id_priv->seq_num, sizeof id_priv->seq_num);
-	id_priv->id.route.addr.dev_addr.net = &init_net;
+	id_priv->id.route.addr.dev_addr.net = get_net(net);
 
 	return &id_priv->id;
 }
@@ -689,7 +690,7 @@ static int cma_modify_qp_rtr(struct rdma_id_private *id_priv,
 	    rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_num)
 	    == IB_LINK_LAYER_ETHERNET) {
 		ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL,
-						  &init_net);
+				id_priv->id.route.addr.dev_addr.net);
 
 		if (ret)
 			goto out;
@@ -953,6 +954,7 @@ static void cma_cancel_operation(struct rdma_id_private *id_priv,
 static void cma_release_port(struct rdma_id_private *id_priv)
 {
 	struct rdma_bind_list *bind_list = id_priv->bind_list;
+	struct net *net = id_priv->id.route.addr.dev_addr.net;
 
 	if (!bind_list)
 		return;
@@ -960,7 +962,7 @@ static void cma_release_port(struct rdma_id_private *id_priv)
 	mutex_lock(&lock);
 	hlist_del(&id_priv->node);
 	if (hlist_empty(&bind_list->owners)) {
-		cma_ps_remove(bind_list->ps, &init_net, bind_list->port);
+		cma_ps_remove(bind_list->ps, net, bind_list->port);
 		kfree(bind_list);
 	}
 	mutex_unlock(&lock);
@@ -1029,6 +1031,7 @@ void rdma_destroy_id(struct rdma_cm_id *id)
 		cma_deref_id(id_priv->id.context);
 
 	kfree(id_priv->id.route.path_rec);
+	put_net(id_priv->id.route.addr.dev_addr.net);
 	kfree(id_priv);
 }
 EXPORT_SYMBOL(rdma_destroy_id);
@@ -1156,7 +1159,8 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 	int ret;
 
 	id = rdma_create_id(listen_id->event_handler, listen_id->context,
-			    listen_id->ps, ib_event->param.req_rcvd.qp_type);
+			    listen_id->ps, ib_event->param.req_rcvd.qp_type,
+			    listen_id->route.addr.dev_addr.net);
 	if (IS_ERR(id))
 		return NULL;
 
@@ -1201,10 +1205,11 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 {
 	struct rdma_id_private *id_priv;
 	struct rdma_cm_id *id;
+	struct net *net = listen_id->route.addr.dev_addr.net;
 	int ret;
 
 	id = rdma_create_id(listen_id->event_handler, listen_id->context,
-			    listen_id->ps, IB_QPT_UD);
+			    listen_id->ps, IB_QPT_UD, net);
 	if (IS_ERR(id))
 		return NULL;
 
@@ -1455,7 +1460,8 @@ static int iw_conn_req_handler(struct iw_cm_id *cm_id,
 	/* Create a new RDMA id for the new IW CM ID */
 	new_cm_id = rdma_create_id(listen_id->id.event_handler,
 				   listen_id->id.context,
-				   RDMA_PS_TCP, IB_QPT_RC);
+				   RDMA_PS_TCP, IB_QPT_RC,
+				   listen_id->id.route.addr.dev_addr.net);
 	if (IS_ERR(new_cm_id)) {
 		ret = -ENOMEM;
 		goto out;
@@ -1528,11 +1534,11 @@ static int cma_ib_listen(struct rdma_id_private *id_priv)
 	struct ib_cm_compare_data compare_data;
 	struct sockaddr *addr;
 	struct ib_cm_id	*id;
+	struct net *net = id_priv->id.route.addr.dev_addr.net;
 	__be64 svc_id;
 	int ret;
 
-	id = ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv,
-			     &init_net);
+	id = ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv, net);
 	if (IS_ERR(id))
 		return PTR_ERR(id);
 
@@ -1596,6 +1602,7 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 {
 	struct rdma_id_private *dev_id_priv;
 	struct rdma_cm_id *id;
+	struct net *net = id_priv->id.route.addr.dev_addr.net;
 	int ret;
 
 	if (cma_family(id_priv) == AF_IB &&
@@ -1603,7 +1610,7 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 		return;
 
 	id = rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
-			    id_priv->id.qp_type);
+			    id_priv->id.qp_type, net);
 	if (IS_ERR(id))
 		return;
 
@@ -2283,7 +2290,8 @@ static int cma_alloc_port(struct radix_tree_root *ps,
 	if (!bind_list)
 		return -ENOMEM;
 
-	ret = cma_ps_alloc(ps, &init_net, bind_list, snum);
+	ret = cma_ps_alloc(ps, id_priv->id.route.addr.dev_addr.net, bind_list,
+			   snum);
 	if (ret < 0)
 		goto err;
 
@@ -2302,13 +2310,14 @@ static int cma_alloc_any_port(struct radix_tree_root *ps,
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
-	    !cma_ps_find(ps, &init_net, (unsigned short)rover)) {
+	    !cma_ps_find(ps, net, (unsigned short)rover)) {
 		int ret = cma_alloc_port(ps, id_priv, rover);
 		/*
 		 * Remember previously used port number in order to avoid
@@ -2376,7 +2385,7 @@ static int cma_use_port(struct radix_tree_root *ps,
 	if (snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
-	bind_list = cma_ps_find(ps, &init_net, snum);
+	bind_list = cma_ps_find(ps, id_priv->id.route.addr.dev_addr.net, snum);
 	if (!bind_list) {
 		ret = cma_alloc_port(ps, id_priv, snum);
 	} else {
@@ -2573,8 +2582,11 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
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
@@ -2687,7 +2699,7 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 	}
 
 	id = ib_create_cm_id(id_priv->id.device, cma_sidr_rep_handler,
-			     id_priv, &init_net);
+			     id_priv, id_priv->id.route.addr.dev_addr.net);
 	if (IS_ERR(id)) {
 		ret = PTR_ERR(id);
 		goto out;
@@ -2737,7 +2749,7 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 		       conn_param->private_data_len);
 
 	id = ib_create_cm_id(id_priv->id.device, cma_ib_handler, id_priv,
-			     &init_net);
+			     id_priv->id.route.addr.dev_addr.net);
 	if (IS_ERR(id)) {
 		ret = PTR_ERR(id);
 		goto out;
@@ -3387,6 +3399,7 @@ static int cma_netdev_change(struct net_device *ndev, struct rdma_id_private *id
 	dev_addr = &id_priv->id.route.addr.dev_addr;
 
 	if ((dev_addr->bound_dev_if == ndev->ifindex) &&
+	    (net_eq(dev_net(ndev), dev_addr->net)) &&
 	    memcmp(dev_addr->src_dev_addr, ndev->dev_addr, ndev->addr_len)) {
 		printk(KERN_INFO "RDMA CM addr change for ndev %s used by id %p\n",
 		       ndev->name, &id_priv->id);
@@ -3412,9 +3425,6 @@ static int cma_netdev_callback(struct notifier_block *self, unsigned long event,
 	struct rdma_id_private *id_priv;
 	int ret = NOTIFY_DONE;
 
-	if (dev_net(ndev) != &init_net)
-		return NOTIFY_DONE;
-
 	if (event != NETDEV_BONDING_FAILOVER)
 		return NOTIFY_DONE;
 
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 56a4b7c..de755f2 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -391,7 +391,8 @@ static ssize_t ucma_create_id(struct ucma_file *file, const char __user *inbuf,
 		return -ENOMEM;
 
 	ctx->uid = cmd.uid;
-	ctx->cm_id = rdma_create_id(ucma_event_handler, ctx, cmd.ps, qp_type);
+	ctx->cm_id = rdma_create_id(ucma_event_handler, ctx, cmd.ps, qp_type,
+				    &init_net);
 	if (IS_ERR(ctx->cm_id)) {
 		ret = PTR_ERR(ctx->cm_id);
 		goto err1;
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index 695a270..d4e9c63 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -949,7 +949,7 @@ int iser_connect(struct iser_conn   *iser_conn,
 
 	ib_conn->cma_id = rdma_create_id(iser_cma_handler,
 					 (void *)iser_conn,
-					 RDMA_PS_TCP, IB_QPT_RC);
+					 RDMA_PS_TCP, IB_QPT_RC, &init_net);
 	if (IS_ERR(ib_conn->cma_id)) {
 		err = PTR_ERR(ib_conn->cma_id);
 		iser_err("rdma_create_id failed: %d\n", err);
diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index dafb3c5..44a6fff 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -2960,7 +2960,7 @@ isert_setup_id(struct isert_np *isert_np)
 	isert_dbg("ksockaddr: %p, sa: %p\n", &np->np_sockaddr, sa);
 
 	id = rdma_create_id(isert_cma_handler, isert_np,
-			    RDMA_PS_TCP, IB_QPT_RC);
+			    RDMA_PS_TCP, IB_QPT_RC, &init_net);
 	if (IS_ERR(id)) {
 		isert_err("rdma_create_id() failed: %ld\n", PTR_ERR(id));
 		ret = PTR_ERR(id);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index b02b4ec..128de4e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -125,7 +125,9 @@ extern kib_tunables_t  kiblnd_tunables;
 				     IBLND_CREDIT_HIGHWATER_V1 : \
 				     *kiblnd_tunables.kib_peercredits_hiw) /* when eagerly to return credits */
 
-#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(cb, dev, ps, qpt)
+#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(cb, dev, \
+							       ps, qpt, \
+							       &init_net)
 
 static inline int
 kiblnd_concurrent_sends_v1(void)
diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
index 1ed2088..3953e9c 100644
--- a/include/rdma/rdma_cm.h
+++ b/include/rdma/rdma_cm.h
@@ -163,10 +163,14 @@ struct rdma_cm_id {
  * @context: User specified context associated with the id.
  * @ps: RDMA port space.
  * @qp_type: type of queue pair associated with the id.
+ * @net: The network namespace in which to create the new id.
+ *
+ * The id holds a reference on the network namespace until it is destroyed.
  */
 struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 				  void *context, enum rdma_port_space ps,
-				  enum ib_qp_type qp_type);
+				  enum ib_qp_type qp_type,
+				  struct net *net);
 
 /**
   * rdma_destroy_id - Destroys an RDMA identifier.
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 14ad43b..577fd31 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -635,7 +635,7 @@ rdma_create_trans(struct p9_client *client, const char *addr, char *args)
 
 	/* Create the RDMA CM ID */
 	rdma->cm_id = rdma_create_id(p9_cm_event_handler, client, RDMA_PS_TCP,
-				     IB_QPT_RC);
+				     IB_QPT_RC, &init_net);
 	if (IS_ERR(rdma->cm_id))
 		goto error;
 
diff --git a/net/rds/ib.c b/net/rds/ib.c
index ba2dffe..cc137f5 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -326,7 +326,7 @@ static int rds_ib_laddr_check(__be32 addr)
 	/* Create a CMA ID and try to bind it. This catches both
 	 * IB and iWARP capable NICs.
 	 */
-	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
+	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC, &init_net);
 	if (IS_ERR(cm_id))
 		return PTR_ERR(cm_id);
 
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 31b74f5..d19b912 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -584,7 +584,7 @@ int rds_ib_conn_connect(struct rds_connection *conn)
 	/* XXX I wonder what affect the port space has */
 	/* delegate cm event handler to rdma_transport */
 	ic->i_cm_id = rdma_create_id(rds_rdma_cm_event_handler, conn,
-				     RDMA_PS_TCP, IB_QPT_RC);
+				     RDMA_PS_TCP, IB_QPT_RC, &init_net);
 	if (IS_ERR(ic->i_cm_id)) {
 		ret = PTR_ERR(ic->i_cm_id);
 		ic->i_cm_id = NULL;
diff --git a/net/rds/iw.c b/net/rds/iw.c
index 5899356..8501b73 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -227,7 +227,7 @@ static int rds_iw_laddr_check(__be32 addr)
 	/* Create a CMA ID and try to bind it. This catches both
 	 * IB and iWARP capable NICs.
 	 */
-	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
+	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC, &init_net);
 	if (IS_ERR(cm_id))
 		return PTR_ERR(cm_id);
 
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index a91e1db..e5ee2d56 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -521,7 +521,7 @@ int rds_iw_conn_connect(struct rds_connection *conn)
 	/* XXX I wonder what affect the port space has */
 	/* delegate cm event handler to rdma_transport */
 	ic->i_cm_id = rdma_create_id(rds_rdma_cm_event_handler, conn,
-				     RDMA_PS_TCP, IB_QPT_RC);
+				     RDMA_PS_TCP, IB_QPT_RC, &init_net);
 	if (IS_ERR(ic->i_cm_id)) {
 		ret = PTR_ERR(ic->i_cm_id);
 		ic->i_cm_id = NULL;
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 6cd9d1d..066b60b 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -160,7 +160,7 @@ static int rds_rdma_listen_init(void)
 	int ret;
 
 	cm_id = rdma_create_id(rds_rdma_cm_event_handler, NULL, RDMA_PS_TCP,
-			       IB_QPT_RC);
+			       IB_QPT_RC, &init_net);
 	if (IS_ERR(cm_id)) {
 		ret = PTR_ERR(cm_id);
 		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4e61880..e3b246e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -701,7 +701,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	xprt = &cma_xprt->sc_xprt;
 
 	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP,
-				   IB_QPT_RC);
+				   IB_QPT_RC, &init_net);
 	if (IS_ERR(listen_id)) {
 		ret = PTR_ERR(listen_id);
 		dprintk("svcrdma: rdma_create_id failed = %d\n", ret);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c98e406..f574e77 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -483,7 +483,8 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 
 	init_completion(&ia->ri_done);
 
-	id = rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP, IB_QPT_RC);
+	id = rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP, IB_QPT_RC,
+			    &init_net);
 	if (IS_ERR(id)) {
 		rc = PTR_ERR(id);
 		dprintk("RPC:       %s: rdma_create_id() failed %i\n",
-- 
1.7.11.2
