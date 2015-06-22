From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v1 10/12] IB/cma: use found net_dev for passive connections
Date: Mon, 22 Jun 2015 15:42:39 +0300
Message-ID: <1434976961-27424-11-git-send-email-haggaie@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434976961-27424-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When receiving a new connection in cma_req_handler, we actually already
know the net_dev that is used for the connection's creation. Instead of
calling cma_translate_addr to resolve the new connection id's source
address, just use the net_dev that was found.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c | 64 ++++++++++++++++++++++---------------------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 759697d6e627..729511d3ec64 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1251,27 +1251,25 @@ static struct rdma_id_private *cma_find_listener(
 }
 
 static struct rdma_id_private *cma_id_from_event(struct ib_cm_id *cm_id,
-						 struct ib_cm_event *ib_event)
+						 struct ib_cm_event *ib_event,
+						 struct net_device **net_dev)
 {
 	struct cma_req_info req;
 	struct rdma_bind_list *bind_list;
 	struct rdma_id_private *id_priv;
-	struct net_device *net_dev;
 	int err;
 
 	err = cma_save_req_info(ib_event, &req);
 	if (err)
 		return ERR_PTR(err);
 
-	net_dev = cma_get_net_dev(ib_event, &req);
-	if (IS_ERR(net_dev))
-		return ERR_PTR(PTR_ERR(net_dev));
+	*net_dev = cma_get_net_dev(ib_event, &req);
+	if (IS_ERR(*net_dev))
+		return ERR_PTR(PTR_ERR(*net_dev));
 
 	bind_list = cma_ps_find(rdma_ps_from_service_id(req.service_id),
 				cma_port_from_service_id(req.service_id));
-	id_priv = cma_find_listener(bind_list, cm_id, ib_event, &req, net_dev);
-
-	dev_put(net_dev);
+	id_priv = cma_find_listener(bind_list, cm_id, ib_event, &req, *net_dev);
 
 	return id_priv;
 }
@@ -1521,7 +1519,8 @@ out:
 }
 
 static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
-					       struct ib_cm_event *ib_event)
+					       struct ib_cm_event *ib_event,
+					       struct net_device *net_dev)
 {
 	struct rdma_id_private *id_priv;
 	struct rdma_cm_id *id;
@@ -1553,15 +1552,9 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 	if (rt->num_paths == 2)
 		rt->path_rec[1] = *ib_event->param.req_rcvd.alternate_path;
 
-	if (cma_any_addr(cma_src_addr(id_priv))) {
-		rt->addr.dev_addr.dev_type = ARPHRD_INFINIBAND;
-		rdma_addr_set_sgid(&rt->addr.dev_addr, &rt->path_rec[0].sgid);
-		ib_addr_set_pkey(&rt->addr.dev_addr, be16_to_cpu(rt->path_rec[0].pkey));
-	} else {
-		ret = cma_translate_addr(cma_src_addr(id_priv), &rt->addr.dev_addr);
-		if (ret)
-			goto err;
-	}
+	ret = rdma_copy_addr(&rt->addr.dev_addr, net_dev, NULL);
+	if (ret)
+		goto err;
 	rdma_addr_set_dgid(&rt->addr.dev_addr, &rt->path_rec[0].dgid);
 
 	id_priv->state = RDMA_CM_CONNECT;
@@ -1573,7 +1566,8 @@ err:
 }
 
 static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
-					      struct ib_cm_event *ib_event)
+					      struct ib_cm_event *ib_event,
+					      struct net_device *net_dev)
 {
 	struct rdma_id_private *id_priv;
 	struct rdma_cm_id *id;
@@ -1592,11 +1586,9 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 			      ib_event->param.sidr_req_rcvd.service_id))
 		goto err;
 
-	if (!cma_any_addr((struct sockaddr *) &id->route.addr.src_addr)) {
-		ret = cma_translate_addr(cma_src_addr(id_priv), &id->route.addr.dev_addr);
-		if (ret)
-			goto err;
-	}
+	ret = rdma_copy_addr(&id->route.addr.dev_addr, net_dev, NULL);
+	if (ret)
+		goto err;
 
 	id_priv->state = RDMA_CM_CONNECT;
 	return id_priv;
@@ -1633,28 +1625,33 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 {
 	struct rdma_id_private *listen_id, *conn_id;
 	struct rdma_cm_event event;
+	struct net_device *net_dev;
 	int offset, ret;
 
-	listen_id = cma_id_from_event(cm_id, ib_event);
+	listen_id = cma_id_from_event(cm_id, ib_event, &net_dev);
 	if (IS_ERR(listen_id))
 		return PTR_ERR(listen_id);
 
-	if (!cma_check_req_qp_type(&listen_id->id, ib_event))
-		return -EINVAL;
+	if (!cma_check_req_qp_type(&listen_id->id, ib_event)) {
+		ret = -EINVAL;
+		goto net_dev_put;
+	}
 
-	if (cma_disable_callback(listen_id, RDMA_CM_LISTEN))
-		return -ECONNABORTED;
+	if (cma_disable_callback(listen_id, RDMA_CM_LISTEN)) {
+		ret = -ECONNABORTED;
+		goto net_dev_put;
+	}
 
 	memset(&event, 0, sizeof event);
 	offset = cma_user_data_offset(listen_id);
 	event.event = RDMA_CM_EVENT_CONNECT_REQUEST;
 	if (ib_event->event == IB_CM_SIDR_REQ_RECEIVED) {
-		conn_id = cma_new_udp_id(&listen_id->id, ib_event);
+		conn_id = cma_new_udp_id(&listen_id->id, ib_event, net_dev);
 		event.param.ud.private_data = ib_event->private_data + offset;
 		event.param.ud.private_data_len =
 				IB_CM_SIDR_REQ_PRIVATE_DATA_SIZE - offset;
 	} else {
-		conn_id = cma_new_conn_id(&listen_id->id, ib_event);
+		conn_id = cma_new_conn_id(&listen_id->id, ib_event, net_dev);
 		cma_set_req_event_data(&event, &ib_event->param.req_rcvd,
 				       ib_event->private_data, offset);
 	}
@@ -1692,6 +1689,7 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 	mutex_unlock(&conn_id->handler_mutex);
 	mutex_unlock(&listen_id->handler_mutex);
 	cma_deref_id(conn_id);
+	dev_put(net_dev);
 	return 0;
 
 err3:
@@ -1705,6 +1703,10 @@ err1:
 	mutex_unlock(&listen_id->handler_mutex);
 	if (conn_id)
 		rdma_destroy_id(&conn_id->id);
+
+net_dev_put:
+	dev_put(net_dev);
+
 	return ret;
 }
 
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
