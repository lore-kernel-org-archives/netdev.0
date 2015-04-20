From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v2 07/11] IB/cm: Add network namespace support
Date: Mon, 20 Apr 2015 12:03:38 +0300
Message-ID: <1429520622-10303-8-git-send-email-haggaie@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Cc: Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>,
	Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:44688 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754226AbbDTJFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 05:05:14 -0400
In-Reply-To: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Add namespace support to the IB-CM layer.

- Each CM-ID now has a network namespace it is associated with, assigned at
  creation. This namespace is used as needed during subsequent action on the
  CM-ID or related objects.

- All of the relevant calls to ib_addr and ib_core were updated to use the
  namespace from the CM-ID. External APIs were extended as needed to allow
  specifying the namespace where relevant.

- The listening service ID table is now also indexed by the CM-ID namespace.

- For incoming connection requests, we use the connection parameters to select
  namespace. The namespace is matched when looking for listening service ID.

To preserve current behavior pass init_net to ib_cm wherever network namespace
function parameters were added.

The ib_cm_create_id interface now takes a reference to the relevant network
namespace. CM-IDs created by accepting a connection for a listening CM-ID will
also take a reference to the namespace. When the ID is destroyed, the
namespace reference is released.

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
---
 drivers/infiniband/core/cm.c            | 124 ++++++++++++++++++++++++--------
 drivers/infiniband/core/cma.c           |   8 ++-
 drivers/infiniband/core/ucm.c           |   3 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |  21 +++++-
 drivers/infiniband/ulp/srp/ib_srp.c     |   2 +-
 drivers/infiniband/ulp/srpt/ib_srpt.c   |   2 +-
 include/rdma/ib_cm.h                    |   7 +-
 7 files changed, 130 insertions(+), 37 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index efc5cffb675a..75c6ac9a4aee 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -241,6 +241,8 @@ struct cm_id_private {
 	u8 service_timeout;
 	u8 target_ack_delay;
 
+	struct net *net; /* A network namespace that the ID belongs to */
+
 	struct list_head work_list;
 	atomic_t work_count;
 };
@@ -347,12 +349,13 @@ static void cm_set_private_data(struct cm_id_private *cm_id_priv,
 }
 
 static void cm_init_av_for_response(struct cm_port *port, struct ib_wc *wc,
-				    struct ib_grh *grh, struct cm_av *av)
+				    struct ib_grh *grh, struct cm_av *av,
+				    struct net *net)
 {
 	av->port = port;
 	av->pkey_index = wc->pkey_index;
 	ib_init_ah_from_wc(port->cm_dev->ib_device, port->port_num, wc,
-			   grh, &av->ah_attr, &init_net);
+			   grh, &av->ah_attr, net);
 }
 
 static int cm_init_av_by_path(struct ib_sa_path_rec *path, struct cm_av *av)
@@ -521,10 +524,15 @@ static struct cm_id_private * cm_insert_listen(struct cm_id_private *cm_id_priv)
 		if ((cur_cm_id_priv->id.service_mask & service_id) ==
 		    (service_mask & cur_cm_id_priv->id.service_id) &&
 		    (cm_id_priv->id.device == cur_cm_id_priv->id.device) &&
-		    !data_cmp)
+		    !data_cmp &&
+		    net_eq(cm_id_priv->net, cur_cm_id_priv->net))
 			return cur_cm_id_priv;
 
-		if (cm_id_priv->id.device < cur_cm_id_priv->id.device)
+		if (cm_id_priv->net < cur_cm_id_priv->net)
+			link = &(*link)->rb_left;
+		else if (cm_id_priv->net > cur_cm_id_priv->net)
+			link = &(*link)->rb_right;
+		else if	(cm_id_priv->id.device < cur_cm_id_priv->id.device)
 			link = &(*link)->rb_left;
 		else if (cm_id_priv->id.device > cur_cm_id_priv->id.device)
 			link = &(*link)->rb_right;
@@ -544,7 +552,8 @@ static struct cm_id_private * cm_insert_listen(struct cm_id_private *cm_id_priv)
 
 static struct cm_id_private * cm_find_listen(struct ib_device *device,
 					     __be64 service_id,
-					     u8 *private_data)
+					     u8 *private_data,
+					     struct net *net)
 {
 	struct rb_node *node = cm.listen_service_table.rb_node;
 	struct cm_id_private *cm_id_priv;
@@ -556,10 +565,14 @@ static struct cm_id_private * cm_find_listen(struct ib_device *device,
 						   cm_id_priv->compare_data);
 		if ((cm_id_priv->id.service_mask & service_id) ==
 		     cm_id_priv->id.service_id &&
-		    (cm_id_priv->id.device == device) && !data_cmp)
+		    (cm_id_priv->id.device == device) && !data_cmp &&
+		    net_eq(cm_id_priv->net, net))
 			return cm_id_priv;
-
-		if (device < cm_id_priv->id.device)
+		if (net < cm_id_priv->net)
+			node = node->rb_left;
+		else if (net > cm_id_priv->net)
+			node = node->rb_right;
+		else if (device < cm_id_priv->id.device)
 			node = node->rb_left;
 		else if (device > cm_id_priv->id.device)
 			node = node->rb_right;
@@ -857,7 +870,8 @@ EXPORT_SYMBOL(cm_save_net_info);
 
 struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
 				 ib_cm_handler cm_handler,
-				 void *context)
+				 void *context,
+				 struct net *net)
 {
 	struct cm_id_private *cm_id_priv;
 	int ret;
@@ -875,6 +889,8 @@ struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
 	if (ret)
 		goto error;
 
+	cm_id_priv->net = get_net(net);
+
 	spin_lock_init(&cm_id_priv->lock);
 	init_completion(&cm_id_priv->comp);
 	INIT_LIST_HEAD(&cm_id_priv->work_list);
@@ -1078,6 +1094,7 @@ retest:
 		cm_free_work(work);
 	kfree(cm_id_priv->compare_data);
 	kfree(cm_id_priv->private_data);
+	put_net(cm_id_priv->net);
 	kfree(cm_id_priv);
 }
 
@@ -1597,7 +1614,8 @@ free:	cm_free_msg(msg);
 }
 
 static struct cm_id_private * cm_match_req(struct cm_work *work,
-					   struct cm_id_private *cm_id_priv)
+					   struct cm_id_private *cm_id_priv,
+					   struct net *net)
 {
 	struct cm_id_private *listen_cm_id_priv, *cur_cm_id_priv;
 	struct cm_timewait_info *timewait_info;
@@ -1633,7 +1651,8 @@ static struct cm_id_private * cm_match_req(struct cm_work *work,
 	/* Find matching listen request. */
 	listen_cm_id_priv = cm_find_listen(cm_id_priv->id.device,
 					   req_msg->service_id,
-					   req_msg->private_data);
+					   req_msg->private_data,
+					   net);
 	if (!listen_cm_id_priv) {
 		cm_cleanup_timewait(cm_id_priv->timewait_info);
 		spin_unlock_irq(&cm.lock);
@@ -1679,24 +1698,58 @@ static void cm_process_routed_req(struct cm_req_msg *req_msg, struct ib_wc *wc)
 	}
 }
 
+static int cm_is_cma_service_id(__be64 service_id)
+{
+	return (IB_CMA_SERVICE_ID_MASK & service_id) == IB_CMA_SERVICE_ID;
+}
+
+static struct net *cm_get_net_ns(struct cm_work *work, __be64 service_id,
+				 __be16 pkey)
+{
+	struct sockaddr_storage addr_storage;
+	struct sockaddr *listen_addr;
+
+	if (cm_is_cma_service_id(service_id)) {
+		listen_addr = (struct sockaddr *)&addr_storage;
+		cm_save_ip_info(listen_addr, NULL, work);
+	} else {
+		/* On RoCE we could extend this branch to determine the
+		 * destination IP from the incoming packet headers, and add
+		 * support for services that are not RDMA IP CM compliant. */
+		listen_addr = NULL;
+	}
+
+	return ib_get_net_ns_by_port_pkey_ip(work->port->cm_dev->ib_device,
+					     work->port->port_num,
+					     be16_to_cpu(pkey),
+					     listen_addr);
+}
 static int cm_req_handler(struct cm_work *work)
 {
 	struct ib_cm_id *cm_id;
 	struct cm_id_private *cm_id_priv, *listen_cm_id_priv;
 	struct cm_req_msg *req_msg;
+	struct net *net;
 	int ret;
 
 	req_msg = (struct cm_req_msg *)work->mad_recv_wc->recv_buf.mad;
+	work->cm_event.private_data = req_msg->private_data;
 
-	cm_id = ib_create_cm_id(work->port->cm_dev->ib_device, NULL, NULL);
-	if (IS_ERR(cm_id))
-		return PTR_ERR(cm_id);
+	net = cm_get_net_ns(work, req_msg->service_id, req_msg->pkey);
+
+	cm_id = ib_create_cm_id(work->port->cm_dev->ib_device, NULL, NULL, net);
+	/* cm_id took a reference to net, so no need to hold it anymore */
+	put_net(net);
+	if (IS_ERR(cm_id)) {
+		ret = PTR_ERR(cm_id);
+		goto out;
+	}
 
 	cm_id_priv = container_of(cm_id, struct cm_id_private, id);
 	cm_id_priv->id.remote_id = req_msg->local_comm_id;
 	cm_init_av_for_response(work->port, work->mad_recv_wc->wc,
 				work->mad_recv_wc->recv_buf.grh,
-				&cm_id_priv->av);
+				&cm_id_priv->av, net);
 	cm_id_priv->timewait_info = cm_create_timewait_info(cm_id_priv->
 							    id.local_id);
 	if (IS_ERR(cm_id_priv->timewait_info)) {
@@ -1707,7 +1760,7 @@ static int cm_req_handler(struct cm_work *work)
 	cm_id_priv->timewait_info->remote_ca_guid = req_msg->local_ca_guid;
 	cm_id_priv->timewait_info->remote_qpn = cm_req_get_local_qpn(req_msg);
 
-	listen_cm_id_priv = cm_match_req(work, cm_id_priv);
+	listen_cm_id_priv = cm_match_req(work, cm_id_priv, net);
 	if (!listen_cm_id_priv) {
 		ret = -EINVAL;
 		kfree(cm_id_priv->timewait_info);
@@ -1766,6 +1819,7 @@ rejected:
 	cm_deref_id(listen_cm_id_priv);
 destroy:
 	ib_destroy_cm_id(cm_id);
+out:
 	return ret;
 }
 
@@ -2900,7 +2954,7 @@ static int cm_lap_handler(struct cm_work *work)
 	cm_id_priv->tid = lap_msg->hdr.tid;
 	cm_init_av_for_response(work->port, work->mad_recv_wc->wc,
 				work->mad_recv_wc->recv_buf.grh,
-				&cm_id_priv->av);
+				&cm_id_priv->av, cm_id_priv->net);
 	cm_init_av_by_path(param->alternate_path, &cm_id_priv->alt_av);
 	ret = atomic_inc_and_test(&cm_id_priv->work_count);
 	if (!ret)
@@ -3150,21 +3204,31 @@ static int cm_sidr_req_handler(struct cm_work *work)
 	struct cm_id_private *cm_id_priv, *cur_cm_id_priv;
 	struct cm_sidr_req_msg *sidr_req_msg;
 	struct ib_wc *wc;
+	struct net *net;
+	int retval;
+
+	sidr_req_msg = (struct cm_sidr_req_msg *)
+				work->mad_recv_wc->recv_buf.mad;
+	work->cm_event.private_data = sidr_req_msg->private_data;
+
+	net = cm_get_net_ns(work, sidr_req_msg->service_id, sidr_req_msg->pkey);
 
-	cm_id = ib_create_cm_id(work->port->cm_dev->ib_device, NULL, NULL);
-	if (IS_ERR(cm_id))
-		return PTR_ERR(cm_id);
+	cm_id = ib_create_cm_id(work->port->cm_dev->ib_device, NULL, NULL, net);
+	/* cm_id took a reference to net, so no need to hold it anymore */
+	put_net(net);
+	if (IS_ERR(cm_id)) {
+		retval = PTR_ERR(cm_id);
+		goto out;
+	}
 	cm_id_priv = container_of(cm_id, struct cm_id_private, id);
 
 	/* Record SGID/SLID and request ID for lookup. */
-	sidr_req_msg = (struct cm_sidr_req_msg *)
-				work->mad_recv_wc->recv_buf.mad;
 	wc = work->mad_recv_wc->wc;
 	cm_id_priv->av.dgid.global.subnet_prefix = cpu_to_be64(wc->slid);
 	cm_id_priv->av.dgid.global.interface_id = 0;
 	cm_init_av_for_response(work->port, work->mad_recv_wc->wc,
 				work->mad_recv_wc->recv_buf.grh,
-				&cm_id_priv->av);
+				&cm_id_priv->av, net);
 	cm_id_priv->id.remote_id = sidr_req_msg->request_id;
 	cm_id_priv->tid = sidr_req_msg->hdr.tid;
 	atomic_inc(&cm_id_priv->work_count);
@@ -3175,16 +3239,19 @@ static int cm_sidr_req_handler(struct cm_work *work)
 		spin_unlock_irq(&cm.lock);
 		atomic_long_inc(&work->port->counter_group[CM_RECV_DUPLICATES].
 				counter[CM_SIDR_REQ_COUNTER]);
-		goto out; /* Duplicate message. */
+		retval = -EINVAL; /* Duplicate message. */
+		goto out_id;
 	}
 	cm_id_priv->id.state = IB_CM_SIDR_REQ_RCVD;
 	cur_cm_id_priv = cm_find_listen(cm_id->device,
 					sidr_req_msg->service_id,
-					sidr_req_msg->private_data);
+					sidr_req_msg->private_data,
+					net);
 	if (!cur_cm_id_priv) {
 		spin_unlock_irq(&cm.lock);
 		cm_reject_sidr_req(cm_id_priv, IB_SIDR_UNSUPPORTED);
-		goto out; /* No match. */
+		retval = -EINVAL; /* No match. */
+		goto out_id;
 	}
 	atomic_inc(&cur_cm_id_priv->refcount);
 	atomic_inc(&cm_id_priv->refcount);
@@ -3199,9 +3266,10 @@ static int cm_sidr_req_handler(struct cm_work *work)
 	cm_process_work(cm_id_priv, work);
 	cm_deref_id(cur_cm_id_priv);
 	return 0;
-out:
+out_id:
 	ib_destroy_cm_id(&cm_id_priv->id);
-	return -EINVAL;
+out:
+	return retval;
 }
 
 static void cm_format_sidr_rep(struct cm_sidr_rep_msg *sidr_rep_msg,
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 9f6faeb1de5f..1ce84a03c883 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1456,7 +1456,8 @@ static int cma_ib_listen(struct rdma_id_private *id_priv)
 	__be64 svc_id;
 	int ret;
 
-	id = ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv);
+	id = ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv,
+			     &init_net);
 	if (IS_ERR(id))
 		return PTR_ERR(id);
 
@@ -2606,7 +2607,7 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 	}
 
 	id = ib_create_cm_id(id_priv->id.device, cma_sidr_rep_handler,
-			     id_priv);
+			     id_priv, &init_net);
 	if (IS_ERR(id)) {
 		ret = PTR_ERR(id);
 		goto out;
@@ -2655,7 +2656,8 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 		memcpy(private_data + offset, conn_param->private_data,
 		       conn_param->private_data_len);
 
-	id = ib_create_cm_id(id_priv->id.device, cma_ib_handler, id_priv);
+	id = ib_create_cm_id(id_priv->id.device, cma_ib_handler, id_priv,
+			     &init_net);
 	if (IS_ERR(id)) {
 		ret = PTR_ERR(id);
 		goto out;
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index f2f63933e8a9..9604ab068984 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -489,7 +489,8 @@ static ssize_t ib_ucm_create_id(struct ib_ucm_file *file,
 
 	ctx->uid = cmd.uid;
 	ctx->cm_id = ib_create_cm_id(file->device->ib_dev,
-				     ib_ucm_event_handler, ctx);
+				     ib_ucm_event_handler, ctx,
+				     &init_net);
 	if (IS_ERR(ctx->cm_id)) {
 		result = PTR_ERR(ctx->cm_id);
 		goto err1;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 56959adb6c7d..65dbe4523bf5 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -846,7 +846,15 @@ int ipoib_cm_dev_open(struct net_device *dev)
 	if (!IPOIB_CM_SUPPORTED(dev->dev_addr))
 		return 0;
 
-	priv->cm.id = ib_create_cm_id(priv->ca, ipoib_cm_rx_handler, dev);
+	/*
+	 * The IPoIB CM ID should always be in the init_net namespace.
+	 * It is using a service ID which is not in the RDMA IP CM
+	 * range.  Furthermore, it is guaranteed that this service ID
+	 * will be unique in the machine, as it is based on the UD QP
+	 * number.
+	 */
+	priv->cm.id = ib_create_cm_id(priv->ca, ipoib_cm_rx_handler, dev,
+				      &init_net);
 	if (IS_ERR(priv->cm.id)) {
 		printk(KERN_WARNING "%s: failed to create CM ID\n", priv->ca->name);
 		ret = PTR_ERR(priv->cm.id);
@@ -1130,7 +1138,16 @@ static int ipoib_cm_tx_init(struct ipoib_cm_tx *p, u32 qpn,
 		goto err_qp;
 	}
 
-	p->id = ib_create_cm_id(priv->ca, ipoib_cm_tx_handler, p);
+	/*
+	 * The IPoIB CM ID should always be in the init_net namespace.
+	 *
+	 * The target for connection is specified by an explicit GID,
+	 * which is machine global and not specific for the namespace
+	 * the device resides at. The service ID is also guaranteed to
+	 * be per machine unique, and therefore init_net is the right
+	 * namespace.
+	 */
+	p->id = ib_create_cm_id(priv->ca, ipoib_cm_tx_handler, p, &init_net);
 	if (IS_ERR(p->id)) {
 		ret = PTR_ERR(p->id);
 		ipoib_warn(priv, "failed to create tx cm id: %d\n", ret);
diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index 918814cd0f80..b9b5c3f9ce11 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -295,7 +295,7 @@ static int srp_new_cm_id(struct srp_rdma_ch *ch)
 	struct ib_cm_id *new_cm_id;
 
 	new_cm_id = ib_create_cm_id(target->srp_host->srp_dev->dev,
-				    srp_cm_handler, ch);
+				    srp_cm_handler, ch, &init_net);
 	if (IS_ERR(new_cm_id))
 		return PTR_ERR(new_cm_id);
 
diff --git a/drivers/infiniband/ulp/srpt/ib_srpt.c b/drivers/infiniband/ulp/srpt/ib_srpt.c
index a95e7d51cd8b..5b1a48052d35 100644
--- a/drivers/infiniband/ulp/srpt/ib_srpt.c
+++ b/drivers/infiniband/ulp/srpt/ib_srpt.c
@@ -3242,7 +3242,7 @@ static void srpt_add_one(struct ib_device *device)
 	if (!srpt_service_guid)
 		srpt_service_guid = be64_to_cpu(device->node_guid);
 
-	sdev->cm_id = ib_create_cm_id(device, srpt_cm_handler, sdev);
+	sdev->cm_id = ib_create_cm_id(device, srpt_cm_handler, sdev, &init_net);
 	if (IS_ERR(sdev->cm_id))
 		goto err_srq;
 
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 0e49933c7b2a..a22ffa370fb3 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -369,13 +369,18 @@ struct ib_cm_id {
  * @cm_handler: Callback invoked to notify the user of CM events.
  * @context: User specified context associated with the communication
  *   identifier.
+ * @net: Network namespace associated with the cm_id.
  *
  * Communication identifiers are used to track connection states, service
  * ID resolution requests, and listen requests.
+ *
+ * The created CM ID will hold a reference on the network namespace until its
+ * destruction.
  */
 struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
 				 ib_cm_handler cm_handler,
-				 void *context);
+				 void *context,
+				 struct net *net);
 
 /**
  * ib_destroy_cm_id - Destroy a connection identifier.
-- 
1.7.11.2
