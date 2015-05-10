From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v3 for-next 11/13] IB/cma: Share CM IDs between namespaces
Date: Sun, 10 May 2015 13:26:42 +0300
Message-ID: <1431253604-9214-12-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:49380 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752552AbbEJK1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 06:27:38 -0400
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ib_cm_id_create_and_listen to create listening IB CM IDs or share
existing ones if needed. When given a request on a specific CM ID, the code
now needs to find the namespace matching the request, and find the RDMA CM
ID based on the namespace and the request parameters, instead of using the
context field of ib_cm_id as was previously done.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
---
 drivers/infiniband/core/cma.c | 142 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 118 insertions(+), 24 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 6538d208a97d..9c72cdde44b5 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1012,6 +1012,112 @@ static int cma_save_net_info(struct sockaddr *src_addr,
 	return cma_save_ip_info(src_addr, dst_addr, ib_event, service_id);
 }
 
+struct cma_req_info {
+	struct ib_device *device;
+	int port;
+	__be64 service_id;
+	u16 pkey;
+};
+
+static int cma_save_req_info(struct ib_cm_event *ib_event,
+			     struct cma_req_info *req)
+{
+	struct ib_cm_req_event_param *req_param = &ib_event->param.req_rcvd;
+	struct ib_cm_sidr_req_event_param *sidr_param =
+		&ib_event->param.sidr_req_rcvd;
+
+	switch (ib_event->event) {
+	case IB_CM_REQ_RECEIVED:
+		req->device	= req_param->listen_id->device;
+		req->port	= req_param->port;
+		req->service_id	= req_param->primary_path->service_id;
+		req->pkey	= be16_to_cpu(req_param->primary_path->pkey);
+		break;
+	case IB_CM_SIDR_REQ_RECEIVED:
+		req->device	= sidr_param->listen_id->device;
+		req->port	= sidr_param->port;
+		req->service_id	= sidr_param->service_id;
+		req->pkey	= sidr_param->pkey;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static struct net *cma_get_net_ns(struct ib_cm_event *ib_event,
+				  struct cma_req_info *req)
+{
+	struct sockaddr_storage addr_storage;
+	struct sockaddr *listen_addr;
+	int err = 0;
+
+	listen_addr = (struct sockaddr *)&addr_storage;
+	err = cma_save_ip_info(listen_addr, NULL, ib_event, req->service_id);
+	if (err)
+		return ERR_PTR(err);
+
+	return ib_get_net_ns_by_port_pkey_ip(req->device, req->port,
+					     req->pkey, listen_addr);
+}
+
+static enum rdma_port_space rdma_ps_from_service_id(__be64 service_id)
+{
+	return (be64_to_cpu(service_id) >> 16) & 0xffff;
+}
+
+static struct rdma_id_private *cma_find_listener(
+		struct rdma_bind_list *bind_list,
+		struct ib_cm_id *cm_id,
+		struct ib_cm_event *ib_event)
+{
+	struct rdma_id_private *id_priv, *id_priv_dev;
+
+	if (!bind_list)
+		return ERR_PTR(-EINVAL);
+
+	hlist_for_each_entry(id_priv, &bind_list->owners, node) {
+		if (!cm_compare_private_data(ib_event->private_data,
+					     &id_priv->compare_data)) {
+			if (id_priv->id.device == cm_id->device)
+				return id_priv;
+			list_for_each_entry(id_priv_dev,
+					    &id_priv->listen_list,
+					    listen_list) {
+				if (id_priv_dev->id.device == cm_id->device)
+					return id_priv_dev;
+			}
+		}
+	}
+
+	return ERR_PTR(-EINVAL);
+}
+
+static struct rdma_id_private *cma_id_from_event(struct ib_cm_id *cm_id,
+						 struct ib_cm_event *ib_event)
+{
+	struct cma_req_info req;
+	struct net *net;
+	struct rdma_bind_list *bind_list;
+	struct rdma_id_private *id_priv;
+	int err;
+
+	err = cma_save_req_info(ib_event, &req);
+	if (err)
+		return ERR_PTR(err);
+
+	net = cma_get_net_ns(ib_event, &req);
+	if (IS_ERR(net))
+		return ERR_PTR(PTR_ERR(net));
+
+	bind_list = cma_ps_find(net, rdma_ps_from_service_id(req.service_id),
+				cma_port_from_service_id(req.service_id));
+	id_priv = cma_find_listener(bind_list, cm_id, ib_event);
+	put_net(net);
+	return id_priv;
+}
+
 static inline int cma_user_data_offset(struct rdma_id_private *id_priv)
 {
 	return cma_family(id_priv) == AF_IB ? 0 : sizeof(struct cma_hdr);
@@ -1121,7 +1227,7 @@ void rdma_destroy_id(struct rdma_cm_id *id)
 	if (id_priv->cma_dev) {
 		if (cap_ib_cm(id_priv->id.device, 1)) {
 			if (id_priv->cm_id.ib)
-				ib_destroy_cm_id(id_priv->cm_id.ib);
+				ib_cm_id_put(id_priv->cm_id.ib);
 		} else if (cap_iw_cm(id_priv->id.device, 1)) {
 			if (id_priv->cm_id.iw)
 				iw_destroy_cm_id(id_priv->cm_id.iw);
@@ -1371,10 +1477,9 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 	struct rdma_cm_event event;
 	int offset, ret;
 
-	listen_id = cm_id->context;
-	if (cm_compare_private_data(ib_event->private_data,
-				    &listen_id->compare_data))
-		return -EINVAL;
+	listen_id = cma_id_from_event(cm_id, ib_event);
+	if (IS_ERR(listen_id))
+		return PTR_ERR(listen_id);
 
 	if (!cma_check_req_qp_type(&listen_id->id, ib_event))
 		return -EINVAL;
@@ -1648,27 +1753,16 @@ static int cma_ib_listen(struct rdma_id_private *id_priv)
 	__be64 svc_id;
 	int ret;
 
-	id = ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv);
-	if (IS_ERR(id))
-		return PTR_ERR(id);
-
-	id_priv->cm_id.ib = id;
-
 	addr = cma_src_addr(id_priv);
 	svc_id = rdma_get_service_id(&id_priv->id, addr);
-	if (cma_any_addr(addr) && !id_priv->afonly)
-		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0, NULL);
-	else {
+	if (!cma_any_addr(addr) || id_priv->afonly)
 		cma_set_compare_data(id_priv->id.ps, addr,
 				     &id_priv->compare_data);
-		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0,
-				   &id_priv->compare_data);
-	}
-
-	if (ret) {
-		ib_destroy_cm_id(id_priv->cm_id.ib);
-		id_priv->cm_id.ib = NULL;
-	}
+	id = ib_cm_id_create_and_listen(id_priv->id.device, cma_req_handler,
+					svc_id, 0);
+	if (IS_ERR(id))
+		return PTR_ERR(id);
+	id_priv->cm_id.ib = id;
 
 	return ret;
 }
@@ -2827,7 +2921,7 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 
 	ret = ib_send_cm_sidr_req(id_priv->cm_id.ib, &req);
 	if (ret) {
-		ib_destroy_cm_id(id_priv->cm_id.ib);
+		ib_cm_id_put(id_priv->cm_id.ib);
 		id_priv->cm_id.ib = NULL;
 	}
 out:
@@ -2898,7 +2992,7 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 	ret = ib_send_cm_req(id_priv->cm_id.ib, &req);
 out:
 	if (ret && !IS_ERR(id)) {
-		ib_destroy_cm_id(id);
+		ib_cm_id_put(id);
 		id_priv->cm_id.ib = NULL;
 	}
 
-- 
1.7.11.2
