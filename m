From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCHv6 01/10] ib_core: Refine device personality from node
 type to port type
Date: Mon, 16 Nov 2009 17:53:12 +0200
Message-ID: <20091116155312.GB2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ewg <ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/ewg>
List-Post: <mailto:ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
List-Help: <mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=subscribe>
Sender: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
Errors-To: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
List-Id: netdev.vger.kernel.org

As a preparation to devices that, in general, support a different transport
protocol for each port, specifically RDMAoE, this patch defines a transport
type for each of a device's ports. As a result, rdma_node_get_transport() has
been unexported and is used internally by the implementation of the new API,
rdma_port_get_transport(), which gives the transport protocol of the queried
port. rdma_is_transport_supported() is also added to be used for verifying if a
given device supports a given protocol on any of its ports. All references to
rdma_node_get_transport() are changed to use the new APIs. Also, ib_port_attr
is extended to contain enum rdma_transport_type.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/core/cm.c              |   25 +++++++++----
 drivers/infiniband/core/cma.c             |   54 +++++++++++++++--------------
 drivers/infiniband/core/mad.c             |   49 ++++++++++++++++---------
 drivers/infiniband/core/multicast.c       |    4 +-
 drivers/infiniband/core/sa_query.c        |   39 +++++++++++++--------
 drivers/infiniband/core/ucm.c             |    8 +++-
 drivers/infiniband/core/ucma.c            |    2 +-
 drivers/infiniband/core/user_mad.c        |    6 +++-
 drivers/infiniband/core/verbs.c           |   25 ++++++++++++-
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   12 +++---
 include/rdma/ib_verbs.h                   |   11 ++++--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    3 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c  |    2 +-
 13 files changed, 153 insertions(+), 87 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 5130fc5..d082f59 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -3678,8 +3678,9 @@ static void cm_add_one(struct ib_device *ib_device)
 	unsigned long flags;
 	int ret;
 	u8 i;
+	enum rdma_transport_type tt;
 
-	if (rdma_node_get_transport(ib_device->node_type) != RDMA_TRANSPORT_IB)
+	if (!rdma_is_transport_supported(ib_device, RDMA_TRANSPORT_IB))
 		return;
 
 	cm_dev = kzalloc(sizeof(*cm_dev) + sizeof(*port) *
@@ -3700,6 +3701,10 @@ static void cm_add_one(struct ib_device *ib_device)
 
 	set_bit(IB_MGMT_METHOD_SEND, reg_req.method_mask);
 	for (i = 1; i <= ib_device->phys_port_cnt; i++) {
+		tt = rdma_port_get_transport(ib_device, i);
+		if (tt != RDMA_TRANSPORT_IB)
+			continue;
+
 		port = kzalloc(sizeof *port, GFP_KERNEL);
 		if (!port)
 			goto error1;
@@ -3742,9 +3747,11 @@ error1:
 	port_modify.clr_port_cap_mask = IB_PORT_CM_SUP;
 	while (--i) {
 		port = cm_dev->port[i-1];
-		ib_modify_port(ib_device, port->port_num, 0, &port_modify);
-		ib_unregister_mad_agent(port->mad_agent);
-		cm_remove_port_fs(port);
+		if (port) {
+			ib_modify_port(ib_device, port->port_num, 0, &port_modify);
+			ib_unregister_mad_agent(port->mad_agent);
+			cm_remove_port_fs(port);
+		}
 	}
 	device_unregister(cm_dev->device);
 	kfree(cm_dev);
@@ -3770,10 +3777,12 @@ static void cm_remove_one(struct ib_device *ib_device)
 
 	for (i = 1; i <= ib_device->phys_port_cnt; i++) {
 		port = cm_dev->port[i-1];
-		ib_modify_port(ib_device, port->port_num, 0, &port_modify);
-		ib_unregister_mad_agent(port->mad_agent);
-		flush_workqueue(cm.wq);
-		cm_remove_port_fs(port);
+		if (port) {
+			ib_modify_port(ib_device, port->port_num, 0, &port_modify);
+			ib_unregister_mad_agent(port->mad_agent);
+			flush_workqueue(cm.wq);
+			cm_remove_port_fs(port);
+		}
 	}
 	device_unregister(cm_dev->device);
 	kfree(cm_dev);
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 0753178..8dc3472 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -329,24 +329,26 @@ static int cma_acquire_dev(struct rdma_id_private *id_priv)
 	struct cma_device *cma_dev;
 	union ib_gid gid;
 	int ret = -ENODEV;
-
-	switch (rdma_node_get_transport(dev_addr->dev_type)) {
-	case RDMA_TRANSPORT_IB:
-		ib_addr_get_sgid(dev_addr, &gid);
-		break;
-	case RDMA_TRANSPORT_IWARP:
-		iw_addr_get_sgid(dev_addr, &gid);
-		break;
-	default:
-		return -ENODEV;
-	}
+	int port;
 
 	list_for_each_entry(cma_dev, &dev_list, list) {
-		ret = ib_find_cached_gid(cma_dev->device, &gid,
-					 &id_priv->id.port_num, NULL);
-		if (!ret) {
-			cma_attach_to_dev(id_priv, cma_dev);
-			break;
+		for (port = 1; port <= cma_dev->device->phys_port_cnt; ++port) {
+			switch (rdma_port_get_transport(cma_dev->device, port)) {
+			case RDMA_TRANSPORT_IB:
+				ib_addr_get_sgid(dev_addr, &gid);
+				break;
+			case RDMA_TRANSPORT_IWARP:
+				iw_addr_get_sgid(dev_addr, &gid);
+				break;
+			default:
+				return -ENODEV;
+			}
+			ret = ib_find_cached_gid(cma_dev->device, &gid,
+						 &id_priv->id.port_num, NULL);
+			if (!ret) {
+				cma_attach_to_dev(id_priv, cma_dev);
+				return ret;
+			}
 		}
 	}
 	return ret;
@@ -597,7 +599,7 @@ int rdma_init_qp_attr(struct rdma_cm_id *id, struct ib_qp_attr *qp_attr,
 	int ret = 0;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
-	switch (rdma_node_get_transport(id_priv->id.device->node_type)) {
+	switch (rdma_port_get_transport(id_priv->id.device, id_priv->id.port_num)) {
 	case RDMA_TRANSPORT_IB:
 		if (!id_priv->cm_id.ib || cma_is_ud_ps(id_priv->id.ps))
 			ret = cma_ib_init_qp_attr(id_priv, qp_attr, qp_attr_mask);
@@ -747,7 +749,7 @@ static inline int cma_user_data_offset(enum rdma_port_space ps)
 
 static void cma_cancel_route(struct rdma_id_private *id_priv)
 {
-	switch (rdma_node_get_transport(id_priv->id.device->node_type)) {
+	switch (rdma_port_get_transport(id_priv->id.device, id_priv->id.port_num)) {
 	case RDMA_TRANSPORT_IB:
 		if (id_priv->query)
 			ib_sa_cancel_query(id_priv->query_id, id_priv->query);
@@ -843,7 +845,7 @@ void rdma_destroy_id(struct rdma_cm_id *id)
 	mutex_lock(&lock);
 	if (id_priv->cma_dev) {
 		mutex_unlock(&lock);
-		switch (rdma_node_get_transport(id->device->node_type)) {
+		switch (rdma_port_get_transport(id_priv->id.device, id_priv->id.port_num)) {
 		case RDMA_TRANSPORT_IB:
 			if (id_priv->cm_id.ib && !IS_ERR(id_priv->cm_id.ib))
 				ib_destroy_cm_id(id_priv->cm_id.ib);
@@ -1500,7 +1502,7 @@ int rdma_listen(struct rdma_cm_id *id, int backlog)
 
 	id_priv->backlog = backlog;
 	if (id->device) {
-		switch (rdma_node_get_transport(id->device->node_type)) {
+		switch (rdma_port_get_transport(id->device, id->port_num)) {
 		case RDMA_TRANSPORT_IB:
 			ret = cma_ib_listen(id_priv);
 			if (ret)
@@ -1727,7 +1729,7 @@ int rdma_resolve_route(struct rdma_cm_id *id, int timeout_ms)
 		return -EINVAL;
 
 	atomic_inc(&id_priv->refcount);
-	switch (rdma_node_get_transport(id->device->node_type)) {
+	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
 		ret = cma_resolve_ib_route(id_priv, timeout_ms);
 		break;
@@ -2407,7 +2409,7 @@ int rdma_connect(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 		id_priv->srq = conn_param->srq;
 	}
 
-	switch (rdma_node_get_transport(id->device->node_type)) {
+	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
 		if (cma_is_ud_ps(id->ps))
 			ret = cma_resolve_ib_udp(id_priv, conn_param);
@@ -2520,7 +2522,7 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 		id_priv->srq = conn_param->srq;
 	}
 
-	switch (rdma_node_get_transport(id->device->node_type)) {
+	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
 		if (cma_is_ud_ps(id->ps))
 			ret = cma_send_sidr_rep(id_priv, IB_SIDR_SUCCESS,
@@ -2581,7 +2583,7 @@ int rdma_reject(struct rdma_cm_id *id, const void *private_data,
 	if (!cma_has_cm_dev(id_priv))
 		return -EINVAL;
 
-	switch (rdma_node_get_transport(id->device->node_type)) {
+	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
 		if (cma_is_ud_ps(id->ps))
 			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT,
@@ -2612,7 +2614,7 @@ int rdma_disconnect(struct rdma_cm_id *id)
 	if (!cma_has_cm_dev(id_priv))
 		return -EINVAL;
 
-	switch (rdma_node_get_transport(id->device->node_type)) {
+	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
 		ret = cma_modify_qp_err(id_priv);
 		if (ret)
@@ -2764,7 +2766,7 @@ int rdma_join_multicast(struct rdma_cm_id *id, struct sockaddr *addr,
 	list_add(&mc->list, &id_priv->mc_list);
 	spin_unlock(&id_priv->lock);
 
-	switch (rdma_node_get_transport(id->device->node_type)) {
+	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
 		ret = cma_join_ib_multicast(id_priv, mc);
 		break;
diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index 7522008..28a47a8 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -2913,8 +2913,9 @@ static int ib_mad_port_close(struct ib_device *device, int port_num)
 static void ib_mad_init_device(struct ib_device *device)
 {
 	int start, end, i;
+	enum rdma_transport_type tt;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
+	if (!rdma_is_transport_supported(device, RDMA_TRANSPORT_IB))
 		return;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH) {
@@ -2926,6 +2927,10 @@ static void ib_mad_init_device(struct ib_device *device)
 	}
 
 	for (i = start; i <= end; i++) {
+		tt = rdma_port_get_transport(device, i);
+		if (tt != RDMA_TRANSPORT_IB)
+			continue;
+
 		if (ib_mad_port_open(device, i)) {
 			printk(KERN_ERR PFX "Couldn't open %s port %d\n",
 			       device->name, i);
@@ -2941,21 +2946,25 @@ static void ib_mad_init_device(struct ib_device *device)
 	return;
 
 error_agent:
-	if (ib_mad_port_close(device, i))
-		printk(KERN_ERR PFX "Couldn't close %s port %d\n",
-		       device->name, i);
+	tt = rdma_port_get_transport(device, i);
+	if (tt == RDMA_TRANSPORT_IB || tt == RDMA_TRANSPORT_RDMAOE)
+		if (ib_mad_port_close(device, i))
+			printk(KERN_ERR PFX "Couldn't close %s port %d\n",
+			       device->name, i);
 
 error:
 	i--;
 
 	while (i >= start) {
-		if (ib_agent_port_close(device, i))
-			printk(KERN_ERR PFX "Couldn't close %s port %d "
-			       "for agents\n",
-			       device->name, i);
-		if (ib_mad_port_close(device, i))
-			printk(KERN_ERR PFX "Couldn't close %s port %d\n",
-			       device->name, i);
+		if (rdma_port_get_transport(device, i) == RDMA_TRANSPORT_IB) {
+			if (ib_agent_port_close(device, i))
+				printk(KERN_ERR PFX "Couldn't close %s port %d "
+				       "for agents\n",
+				       device->name, i);
+			if (ib_mad_port_close(device, i))
+				printk(KERN_ERR PFX "Couldn't close %s port %d\n",
+				       device->name, i);
+		}
 		i--;
 	}
 }
@@ -2963,6 +2972,7 @@ error:
 static void ib_mad_remove_device(struct ib_device *device)
 {
 	int i, num_ports, cur_port;
+	enum rdma_transport_type tt;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH) {
 		num_ports = 1;
@@ -2972,13 +2982,16 @@ static void ib_mad_remove_device(struct ib_device *device)
 		cur_port = 1;
 	}
 	for (i = 0; i < num_ports; i++, cur_port++) {
-		if (ib_agent_port_close(device, cur_port))
-			printk(KERN_ERR PFX "Couldn't close %s port %d "
-			       "for agents\n",
-			       device->name, cur_port);
-		if (ib_mad_port_close(device, cur_port))
-			printk(KERN_ERR PFX "Couldn't close %s port %d\n",
-			       device->name, cur_port);
+		tt = rdma_port_get_transport(device, i);
+		if (tt == RDMA_TRANSPORT_IB) {
+			if (ib_agent_port_close(device, cur_port))
+				printk(KERN_ERR PFX "Couldn't close %s port %d "
+				       "for agents\n",
+				       device->name, cur_port);
+			if (ib_mad_port_close(device, cur_port))
+				printk(KERN_ERR PFX "Couldn't close %s port %d\n",
+				       device->name, cur_port);
+		}
 	}
 }
 
diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
index 8d82ba1..7d9887d 100644
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -796,10 +796,10 @@ static void mcast_add_one(struct ib_device *device)
 	struct mcast_port *port;
 	int i;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
+	if (!rdma_is_transport_supported(device, RDMA_TRANSPORT_IB))
 		return;
 
-	dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
+	dev = kzalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
 		      GFP_KERNEL);
 	if (!dev)
 		return;
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 7e1ffd8..18b09c4 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -416,14 +416,16 @@ static void ib_sa_event(struct ib_event_handler *handler, struct ib_event *event
 		struct ib_sa_port *port =
 			&sa_dev->port[event->element.port_num - sa_dev->start_port];
 
-		spin_lock_irqsave(&port->ah_lock, flags);
-		if (port->sm_ah)
-			kref_put(&port->sm_ah->ref, free_sm_ah);
-		port->sm_ah = NULL;
-		spin_unlock_irqrestore(&port->ah_lock, flags);
-
-		schedule_work(&sa_dev->port[event->element.port_num -
-					    sa_dev->start_port].update_task);
+		if (rdma_port_get_transport(handler->device, port->port_num) == RDMA_TRANSPORT_IB) {
+			spin_lock_irqsave(&port->ah_lock, flags);
+			if (port->sm_ah)
+				kref_put(&port->sm_ah->ref, free_sm_ah);
+			port->sm_ah = NULL;
+			spin_unlock_irqrestore(&port->ah_lock, flags);
+
+			schedule_work(&sa_dev->port[event->element.port_num -
+						    sa_dev->start_port].update_task);
+		}
 	}
 }
 
@@ -997,7 +999,7 @@ static void ib_sa_add_one(struct ib_device *device)
 	struct ib_sa_device *sa_dev;
 	int s, e, i;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
+	if (!rdma_is_transport_supported(device, RDMA_TRANSPORT_IB))
 		return;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH)
@@ -1007,7 +1009,7 @@ static void ib_sa_add_one(struct ib_device *device)
 		e = device->phys_port_cnt;
 	}
 
-	sa_dev = kmalloc(sizeof *sa_dev +
+	sa_dev = kzalloc(sizeof *sa_dev +
 			 (e - s + 1) * sizeof (struct ib_sa_port),
 			 GFP_KERNEL);
 	if (!sa_dev)
@@ -1017,6 +1019,9 @@ static void ib_sa_add_one(struct ib_device *device)
 	sa_dev->end_port   = e;
 
 	for (i = 0; i <= e - s; ++i) {
+		if (rdma_port_get_transport(device, i + 1) != RDMA_TRANSPORT_IB)
+			continue;
+
 		sa_dev->port[i].sm_ah    = NULL;
 		sa_dev->port[i].port_num = i + s;
 		spin_lock_init(&sa_dev->port[i].ah_lock);
@@ -1045,13 +1050,15 @@ static void ib_sa_add_one(struct ib_device *device)
 		goto err;
 
 	for (i = 0; i <= e - s; ++i)
-		update_sm_ah(&sa_dev->port[i].update_task);
+		if (rdma_port_get_transport(device, i + 1) == RDMA_TRANSPORT_IB)
+			update_sm_ah(&sa_dev->port[i].update_task);
 
 	return;
 
 err:
 	while (--i >= 0)
-		ib_unregister_mad_agent(sa_dev->port[i].agent);
+		if (rdma_port_get_transport(device, i + 1) == RDMA_TRANSPORT_IB)
+			ib_unregister_mad_agent(sa_dev->port[i].agent);
 
 	kfree(sa_dev);
 
@@ -1071,9 +1078,11 @@ static void ib_sa_remove_one(struct ib_device *device)
 	flush_scheduled_work();
 
 	for (i = 0; i <= sa_dev->end_port - sa_dev->start_port; ++i) {
-		ib_unregister_mad_agent(sa_dev->port[i].agent);
-		if (sa_dev->port[i].sm_ah)
-			kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
+		if (rdma_port_get_transport(device, i + 1) == RDMA_TRANSPORT_IB) {
+			ib_unregister_mad_agent(sa_dev->port[i].agent);
+			if (sa_dev->port[i].sm_ah)
+				kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
+		}
 	}
 
 	kfree(sa_dev);
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index f504c9b..43700b4 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -1240,11 +1240,15 @@ static DEVICE_ATTR(ibdev, S_IRUGO, show_ibdev, NULL);
 static void ib_ucm_add_one(struct ib_device *device)
 {
 	struct ib_ucm_device *ucm_dev;
+	int i;
 
-	if (!device->alloc_ucontext ||
-	    rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
+	if (!device->alloc_ucontext)
 		return;
 
+	for (i = 1; i <= device->phys_port_cnt; ++i)
+		if (rdma_port_get_transport(device, i) != RDMA_TRANSPORT_IB)
+			return;
+
 	ucm_dev = kzalloc(sizeof *ucm_dev, GFP_KERNEL);
 	if (!ucm_dev)
 		return;
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index f1cbd26..fd831fd 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -616,7 +616,7 @@ static ssize_t ucma_query_route(struct ucma_file *file,
 
 	resp.node_guid = (__force __u64) ctx->cm_id->device->node_guid;
 	resp.port_num = ctx->cm_id->port_num;
-	switch (rdma_node_get_transport(ctx->cm_id->device->node_type)) {
+	switch (rdma_port_get_transport(ctx->cm_id->device, ctx->cm_id->port_num)) {
 	case RDMA_TRANSPORT_IB:
 		ucma_copy_ib_route(&resp, &ctx->cm_id->route);
 		break;
diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
index 7de0296..6d6795d 100644
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -1114,7 +1114,7 @@ static void ib_umad_add_one(struct ib_device *device)
 	struct ib_umad_device *umad_dev;
 	int s, e, i;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
+	if (!rdma_is_transport_supported(device, RDMA_TRANSPORT_IB))
 		return;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH)
@@ -1124,6 +1124,10 @@ static void ib_umad_add_one(struct ib_device *device)
 		e = device->phys_port_cnt;
 	}
 
+	for (i = s; i <= e; ++i)
+		if (rdma_port_get_transport(device, i) != RDMA_TRANSPORT_IB)
+			return;
+
 	umad_dev = kzalloc(sizeof *umad_dev +
 			   (e - s + 1) * sizeof (struct ib_umad_port),
 			   GFP_KERNEL);
diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index a7da9be..d81e217 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -77,7 +77,7 @@ enum ib_rate mult_to_ib_rate(int mult)
 }
 EXPORT_SYMBOL(mult_to_ib_rate);
 
-enum rdma_transport_type
+static enum rdma_transport_type
 rdma_node_get_transport(enum rdma_node_type node_type)
 {
 	switch (node_type) {
@@ -92,7 +92,28 @@ rdma_node_get_transport(enum rdma_node_type node_type)
 		return 0;
 	}
 }
-EXPORT_SYMBOL(rdma_node_get_transport);
+
+enum rdma_transport_type rdma_port_get_transport(struct ib_device *device,
+						 u8 port_num)
+{
+	return device->get_port_transport ?
+		device->get_port_transport(device, port_num) :
+		rdma_node_get_transport(device->node_type);
+}
+EXPORT_SYMBOL(rdma_port_get_transport);
+
+int rdma_is_transport_supported(struct ib_device *device,
+				enum rdma_transport_type transport)
+{
+	int i;
+
+	for (i = 1; i <= device->phys_port_cnt; ++i)
+		if (rdma_port_get_transport(device, i) == transport)
+			return 1;
+
+	return 0;
+}
+EXPORT_SYMBOL(rdma_is_transport_supported);
 
 /* Protection domains */
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 2bf5116..de89e80 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1343,9 +1343,6 @@ static void ipoib_add_one(struct ib_device *device)
 	struct ipoib_dev_priv *priv;
 	int s, e, p;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	dev_list = kmalloc(sizeof *dev_list, GFP_KERNEL);
 	if (!dev_list)
 		return;
@@ -1361,6 +1358,9 @@ static void ipoib_add_one(struct ib_device *device)
 	}
 
 	for (p = s; p <= e; ++p) {
+		if (rdma_port_get_transport(device, p) != RDMA_TRANSPORT_IB)
+			continue;
+
 		dev = ipoib_add_port("ib%d", device, p);
 		if (!IS_ERR(dev)) {
 			priv = netdev_priv(dev);
@@ -1376,12 +1376,12 @@ static void ipoib_remove_one(struct ib_device *device)
 	struct ipoib_dev_priv *priv, *tmp;
 	struct list_head *dev_list;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	dev_list = ib_get_client_data(device, &ipoib_client);
 
 	list_for_each_entry_safe(priv, tmp, dev_list, list) {
+		if (rdma_port_get_transport(device, priv->port) != RDMA_TRANSPORT_IB)
+			continue;
+
 		ib_unregister_event_handler(&priv->event_handler);
 
 		rtnl_lock();
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index c179318..4cf42f3 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -72,9 +72,6 @@ enum rdma_transport_type {
 	RDMA_TRANSPORT_IWARP
 };
 
-enum rdma_transport_type
-rdma_node_get_transport(enum rdma_node_type node_type) __attribute_const__;
-
 enum ib_device_cap_flags {
 	IB_DEVICE_RESIZE_MAX_WR		= 1,
 	IB_DEVICE_BAD_PKEY_CNTR		= (1<<1),
@@ -298,6 +295,7 @@ struct ib_port_attr {
 	u8			active_width;
 	u8			active_speed;
 	u8                      phys_state;
+	enum rdma_transport_type	transport;
 };
 
 enum ib_device_modify_flags {
@@ -1003,6 +1001,8 @@ struct ib_device {
 	int		           (*query_port)(struct ib_device *device,
 						 u8 port_num,
 						 struct ib_port_attr *port_attr);
+	enum rdma_transport_type   (*get_port_transport)(struct ib_device *device,
+							 u8 port_num);
 	int		           (*query_gid)(struct ib_device *device,
 						u8 port_num, int index,
 						union ib_gid *gid);
@@ -1213,6 +1213,11 @@ int ib_query_device(struct ib_device *device,
 int ib_query_port(struct ib_device *device,
 		  u8 port_num, struct ib_port_attr *port_attr);
 
+enum rdma_transport_type rdma_port_get_transport(struct ib_device *device,
+						 u8 port_num);
+int rdma_is_transport_supported(struct ib_device *device,
+				enum rdma_transport_type transport);
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 9e88438..1131c74 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -338,8 +338,7 @@ static int rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
 static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
 {
 	if ((RDMA_TRANSPORT_IWARP ==
-	     rdma_node_get_transport(xprt->sc_cm_id->
-				     device->node_type))
+	     rdma_port_get_transport(xprt->sc_cm_id->device, xprt->sc_cm_id->port_num))
 	    && sge_count > 1)
 		return 1;
 	else
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 3fa5751..4e286f7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -977,7 +977,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	/*
 	 * Determine if a DMA MR is required and if so, what privs are required
 	 */
-	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
+	switch (rdma_port_get_transport(newxprt->sc_cm_id->device, newxprt->sc_cm_id->port_num)) {
 	case RDMA_TRANSPORT_IWARP:
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
 		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
-- 
1.6.5.2
