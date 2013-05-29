From: sean.hefty@intel.com
Subject: [PATCH v5 08/28] rdma/cm: Add helper functions to return id address information
Date: Wed, 29 May 2013 10:09:14 -0700
Message-ID: <1369847374-12176-9-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
To: roland@purestorage.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18285 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759565Ab3E2RJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:09:50 -0400
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Hefty <sean.hefty@intel.com>

Provide inline helpers to extract source and destination address
data from the rdma_cm_id.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/cma.c |  138 +++++++++++++++++++++--------------------
 1 files changed, 71 insertions(+), 67 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 46a9b5c..61454d3e 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -311,6 +311,21 @@ static void cma_release_dev(struct rdma_id_private *id_priv)
 	mutex_unlock(&lock);
 }
 
+static inline struct sockaddr *cma_src_addr(struct rdma_id_private *id_priv)
+{
+	return (struct sockaddr *) &id_priv->id.route.addr.src_addr;
+}
+
+static inline struct sockaddr *cma_dst_addr(struct rdma_id_private *id_priv)
+{
+	return (struct sockaddr *) &id_priv->id.route.addr.dst_addr;
+}
+
+static inline unsigned short cma_family(struct rdma_id_private *id_priv)
+{
+	return id_priv->id.route.addr.src_addr.ss_family;
+}
+
 static int cma_set_qkey(struct rdma_id_private *id_priv)
 {
 	struct ib_sa_mcmember_rec rec;
@@ -900,8 +915,7 @@ static void cma_cancel_operation(struct rdma_id_private *id_priv,
 		cma_cancel_route(id_priv);
 		break;
 	case RDMA_CM_LISTEN:
-		if (cma_any_addr((struct sockaddr *) &id_priv->id.route.addr.src_addr)
-				&& !id_priv->cma_dev)
+		if (cma_any_addr(cma_src_addr(id_priv)) && !id_priv->cma_dev)
 			cma_cancel_listens(id_priv);
 		break;
 	default:
@@ -1138,6 +1152,7 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 	if (IS_ERR(id))
 		return NULL;
 
+	id_priv = container_of(id, struct rdma_id_private, id);
 	cma_save_net_info(&id->route.addr, &listen_id->route.addr,
 			  ip_ver, port, src, dst);
 
@@ -1152,19 +1167,17 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 	if (rt->num_paths == 2)
 		rt->path_rec[1] = *ib_event->param.req_rcvd.alternate_path;
 
-	if (cma_any_addr((struct sockaddr *) &rt->addr.src_addr)) {
+	if (cma_any_addr(cma_src_addr(id_priv))) {
 		rt->addr.dev_addr.dev_type = ARPHRD_INFINIBAND;
 		rdma_addr_set_sgid(&rt->addr.dev_addr, &rt->path_rec[0].sgid);
 		ib_addr_set_pkey(&rt->addr.dev_addr, be16_to_cpu(rt->path_rec[0].pkey));
 	} else {
-		ret = cma_translate_addr((struct sockaddr *) &rt->addr.src_addr,
-					 &rt->addr.dev_addr);
+		ret = cma_translate_addr(cma_src_addr(id_priv), &rt->addr.dev_addr);
 		if (ret)
 			goto err;
 	}
 	rdma_addr_set_dgid(&rt->addr.dev_addr, &rt->path_rec[0].dgid);
 
-	id_priv = container_of(id, struct rdma_id_private, id);
 	id_priv->state = RDMA_CM_CONNECT;
 	return id_priv;
 
@@ -1188,7 +1201,7 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 	if (IS_ERR(id))
 		return NULL;
 
-
+	id_priv = container_of(id, struct rdma_id_private, id);
 	if (cma_get_net_info(ib_event->private_data, listen_id->ps,
 			     &ip_ver, &port, &src, &dst))
 		goto err;
@@ -1197,13 +1210,11 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 			  ip_ver, port, src, dst);
 
 	if (!cma_any_addr((struct sockaddr *) &id->route.addr.src_addr)) {
-		ret = cma_translate_addr((struct sockaddr *) &id->route.addr.src_addr,
-					 &id->route.addr.dev_addr);
+		ret = cma_translate_addr(cma_src_addr(id_priv), &id->route.addr.dev_addr);
 		if (ret)
 			goto err;
 	}
 
-	id_priv = container_of(id, struct rdma_id_private, id);
 	id_priv->state = RDMA_CM_CONNECT;
 	return id_priv;
 err:
@@ -1386,9 +1397,9 @@ static int cma_iw_handler(struct iw_cm_id *iw_id, struct iw_cm_event *iw_event)
 		event.event = RDMA_CM_EVENT_DISCONNECTED;
 		break;
 	case IW_CM_EVENT_CONNECT_REPLY:
-		sin = (struct sockaddr_in *) &id_priv->id.route.addr.src_addr;
+		sin = (struct sockaddr_in *) cma_src_addr(id_priv);
 		*sin = iw_event->local_addr;
-		sin = (struct sockaddr_in *) &id_priv->id.route.addr.dst_addr;
+		sin = (struct sockaddr_in *) cma_dst_addr(id_priv);
 		*sin = iw_event->remote_addr;
 		switch (iw_event->status) {
 		case 0:
@@ -1486,9 +1497,9 @@ static int iw_conn_req_handler(struct iw_cm_id *cm_id,
 	cm_id->context = conn_id;
 	cm_id->cm_handler = cma_iw_handler;
 
-	sin = (struct sockaddr_in *) &new_cm_id->route.addr.src_addr;
+	sin = (struct sockaddr_in *) cma_src_addr(conn_id);
 	*sin = iw_event->local_addr;
-	sin = (struct sockaddr_in *) &new_cm_id->route.addr.dst_addr;
+	sin = (struct sockaddr_in *) cma_dst_addr(conn_id);
 	*sin = iw_event->remote_addr;
 
 	ret = ib_query_device(conn_id->id.device, &attr);
@@ -1545,7 +1556,7 @@ static int cma_ib_listen(struct rdma_id_private *id_priv)
 
 	id_priv->cm_id.ib = id;
 
-	addr = (struct sockaddr *) &id_priv->id.route.addr.src_addr;
+	addr = cma_src_addr(id_priv);
 	svc_id = cma_get_service_id(id_priv->id.ps, addr);
 	if (cma_any_addr(addr) && !id_priv->afonly)
 		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0, NULL);
@@ -1576,7 +1587,7 @@ static int cma_iw_listen(struct rdma_id_private *id_priv, int backlog)
 
 	id_priv->cm_id.iw = id;
 
-	sin = (struct sockaddr_in *) &id_priv->id.route.addr.src_addr;
+	sin = (struct sockaddr_in *) cma_src_addr(id_priv);
 	id_priv->cm_id.iw->local_addr = *sin;
 
 	ret = iw_cm_listen(id_priv->cm_id.iw, backlog);
@@ -1614,8 +1625,8 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 	dev_id_priv = container_of(id, struct rdma_id_private, id);
 
 	dev_id_priv->state = RDMA_CM_ADDR_BOUND;
-	memcpy(&id->route.addr.src_addr, &id_priv->id.route.addr.src_addr,
-	       rdma_addr_size((struct sockaddr *) &id_priv->id.route.addr.src_addr));
+	memcpy(cma_src_addr(dev_id_priv), cma_src_addr(id_priv),
+	       rdma_addr_size(cma_src_addr(id_priv)));
 
 	cma_attach_to_dev(dev_id_priv, cma_dev);
 	list_add_tail(&dev_id_priv->listen_list, &id_priv->listen_list);
@@ -1673,29 +1684,28 @@ static void cma_query_handler(int status, struct ib_sa_path_rec *path_rec,
 static int cma_query_ib_route(struct rdma_id_private *id_priv, int timeout_ms,
 			      struct cma_work *work)
 {
-	struct rdma_addr *addr = &id_priv->id.route.addr;
+	struct rdma_dev_addr *dev_addr = &id_priv->id.route.addr.dev_addr;
 	struct ib_sa_path_rec path_rec;
 	ib_sa_comp_mask comp_mask;
 	struct sockaddr_in6 *sin6;
 
 	memset(&path_rec, 0, sizeof path_rec);
-	rdma_addr_get_sgid(&addr->dev_addr, &path_rec.sgid);
-	rdma_addr_get_dgid(&addr->dev_addr, &path_rec.dgid);
-	path_rec.pkey = cpu_to_be16(ib_addr_get_pkey(&addr->dev_addr));
+	rdma_addr_get_sgid(dev_addr, &path_rec.sgid);
+	rdma_addr_get_dgid(dev_addr, &path_rec.dgid);
+	path_rec.pkey = cpu_to_be16(ib_addr_get_pkey(dev_addr));
 	path_rec.numb_path = 1;
 	path_rec.reversible = 1;
-	path_rec.service_id = cma_get_service_id(id_priv->id.ps,
-							(struct sockaddr *) &addr->dst_addr);
+	path_rec.service_id = cma_get_service_id(id_priv->id.ps, cma_dst_addr(id_priv));
 
 	comp_mask = IB_SA_PATH_REC_DGID | IB_SA_PATH_REC_SGID |
 		    IB_SA_PATH_REC_PKEY | IB_SA_PATH_REC_NUMB_PATH |
 		    IB_SA_PATH_REC_REVERSIBLE | IB_SA_PATH_REC_SERVICE_ID;
 
-	if (addr->src_addr.ss_family == AF_INET) {
+	if (cma_family(id_priv) == AF_INET) {
 		path_rec.qos_class = cpu_to_be16((u16) id_priv->tos);
 		comp_mask |= IB_SA_PATH_REC_QOS_CLASS;
 	} else {
-		sin6 = (struct sockaddr_in6 *) &addr->src_addr;
+		sin6 = (struct sockaddr_in6 *) cma_src_addr(id_priv);
 		path_rec.traffic_class = (u8) (be32_to_cpu(sin6->sin6_flowinfo) >> 20);
 		comp_mask |= IB_SA_PATH_REC_TRAFFIC_CLASS;
 	}
@@ -2009,7 +2019,7 @@ port_found:
 	ib_addr_set_pkey(&id_priv->id.route.addr.dev_addr, pkey);
 	id_priv->id.port_num = p;
 	cma_attach_to_dev(id_priv, cma_dev);
-	cma_set_loopback((struct sockaddr *) &id_priv->id.route.addr.src_addr);
+	cma_set_loopback(cma_src_addr(id_priv));
 out:
 	mutex_unlock(&lock);
 	return ret;
@@ -2037,8 +2047,7 @@ static void addr_handler(int status, struct sockaddr *src_addr,
 		event.event = RDMA_CM_EVENT_ADDR_ERROR;
 		event.status = status;
 	} else {
-		memcpy(&id_priv->id.route.addr.src_addr, src_addr,
-		       rdma_addr_size(src_addr));
+		memcpy(cma_src_addr(id_priv), src_addr, rdma_addr_size(src_addr));
 		event.event = RDMA_CM_EVENT_ADDR_RESOLVED;
 	}
 
@@ -2115,11 +2124,11 @@ int rdma_resolve_addr(struct rdma_cm_id *id, struct sockaddr *src_addr,
 		return -EINVAL;
 
 	atomic_inc(&id_priv->refcount);
-	memcpy(&id->route.addr.dst_addr, dst_addr, rdma_addr_size(dst_addr));
+	memcpy(cma_dst_addr(id_priv), dst_addr, rdma_addr_size(dst_addr));
 	if (cma_any_addr(dst_addr))
 		ret = cma_resolve_loopback(id_priv);
 	else
-		ret = rdma_resolve_ip(&addr_client, (struct sockaddr *) &id->route.addr.src_addr,
+		ret = rdma_resolve_ip(&addr_client, cma_src_addr(id_priv),
 				      dst_addr, &id->route.addr.dev_addr,
 				      timeout_ms, addr_handler, id_priv);
 	if (ret)
@@ -2180,7 +2189,7 @@ static void cma_bind_port(struct rdma_bind_list *bind_list,
 	u64 sid, mask;
 	__be16 port;
 
-	addr = (struct sockaddr *) &id_priv->id.route.addr.src_addr;
+	addr = cma_src_addr(id_priv);
 	port = htons(bind_list->port);
 
 	switch (addr->sa_family) {
@@ -2268,7 +2277,7 @@ static int cma_check_port(struct rdma_bind_list *bind_list,
 	struct rdma_id_private *cur_id;
 	struct sockaddr *addr, *cur_addr;
 
-	addr = (struct sockaddr *) &id_priv->id.route.addr.src_addr;
+	addr = cma_src_addr(id_priv);
 	hlist_for_each_entry(cur_id, &bind_list->owners, node) {
 		if (id_priv == cur_id)
 			continue;
@@ -2277,7 +2286,7 @@ static int cma_check_port(struct rdma_bind_list *bind_list,
 		    cur_id->reuseaddr)
 			continue;
 
-		cur_addr = (struct sockaddr *) &cur_id->id.route.addr.src_addr;
+		cur_addr = cma_src_addr(cur_id);
 		if (id_priv->afonly && cur_id->afonly &&
 		    (addr->sa_family != cur_addr->sa_family))
 			continue;
@@ -2297,7 +2306,7 @@ static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
 	unsigned short snum;
 	int ret;
 
-	snum = ntohs(cma_port((struct sockaddr *) &id_priv->id.route.addr.src_addr));
+	snum = ntohs(cma_port(cma_src_addr(id_priv)));
 	if (snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
@@ -2348,7 +2357,7 @@ static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
 	struct sockaddr_ib *sib;
 	u64 sid_ps, mask, sid;
 
-	sib = (struct sockaddr_ib *) &id_priv->id.route.addr.src_addr;
+	sib = (struct sockaddr_ib *) cma_src_addr(id_priv);
 	mask = be64_to_cpu(sib->sib_sid_mask) & RDMA_IB_IP_PS_MASK;
 	sid = be64_to_cpu(sib->sib_sid) & mask;
 
@@ -2378,7 +2387,7 @@ static int cma_get_port(struct rdma_id_private *id_priv)
 	struct idr *ps;
 	int ret;
 
-	if (id_priv->id.route.addr.src_addr.ss_family != AF_IB)
+	if (cma_family(id_priv) != AF_IB)
 		ps = cma_select_inet_ps(id_priv);
 	else
 		ps = cma_select_ib_ps(id_priv);
@@ -2386,7 +2395,7 @@ static int cma_get_port(struct rdma_id_private *id_priv)
 		return -EPROTONOSUPPORT;
 
 	mutex_lock(&lock);
-	if (cma_any_port((struct sockaddr *) &id_priv->id.route.addr.src_addr))
+	if (cma_any_port(cma_src_addr(id_priv)))
 		ret = cma_alloc_any_port(ps, id_priv);
 	else
 		ret = cma_use_port(ps, id_priv);
@@ -2421,8 +2430,8 @@ int rdma_listen(struct rdma_cm_id *id, int backlog)
 
 	id_priv = container_of(id, struct rdma_id_private, id);
 	if (id_priv->state == RDMA_CM_IDLE) {
-		((struct sockaddr *) &id->route.addr.src_addr)->sa_family = AF_INET;
-		ret = rdma_bind_addr(id, (struct sockaddr *) &id->route.addr.src_addr);
+		id->route.addr.src_addr.ss_family = AF_INET;
+		ret = rdma_bind_addr(id, cma_src_addr(id_priv));
 		if (ret)
 			return ret;
 	}
@@ -2491,7 +2500,7 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
 			goto err1;
 	}
 
-	memcpy(&id->route.addr.src_addr, addr, rdma_addr_size(addr));
+	memcpy(cma_src_addr(id_priv), addr, rdma_addr_size(addr));
 	if (!(id_priv->options & (1 << CMA_OPTION_AFONLY))) {
 		if (addr->sa_family == AF_INET)
 			id_priv->afonly = 1;
@@ -2514,19 +2523,18 @@ err1:
 }
 EXPORT_SYMBOL(rdma_bind_addr);
 
-static int cma_format_hdr(void *hdr, enum rdma_port_space ps,
-			  struct rdma_route *route)
+static int cma_format_hdr(void *hdr, struct rdma_id_private *id_priv)
 {
 	struct cma_hdr *cma_hdr;
 	struct sdp_hh *sdp_hdr;
 
-	if (route->addr.src_addr.ss_family == AF_INET) {
+	if (cma_family(id_priv) == AF_INET) {
 		struct sockaddr_in *src4, *dst4;
 
-		src4 = (struct sockaddr_in *) &route->addr.src_addr;
-		dst4 = (struct sockaddr_in *) &route->addr.dst_addr;
+		src4 = (struct sockaddr_in *) cma_src_addr(id_priv);
+		dst4 = (struct sockaddr_in *) cma_dst_addr(id_priv);
 
-		switch (ps) {
+		switch (id_priv->id.ps) {
 		case RDMA_PS_SDP:
 			sdp_hdr = hdr;
 			if (sdp_get_majv(sdp_hdr->sdp_version) != SDP_MAJ_VERSION)
@@ -2548,10 +2556,10 @@ static int cma_format_hdr(void *hdr, enum rdma_port_space ps,
 	} else {
 		struct sockaddr_in6 *src6, *dst6;
 
-		src6 = (struct sockaddr_in6 *) &route->addr.src_addr;
-		dst6 = (struct sockaddr_in6 *) &route->addr.dst_addr;
+		src6 = (struct sockaddr_in6 *) cma_src_addr(id_priv);
+		dst6 = (struct sockaddr_in6 *) cma_dst_addr(id_priv);
 
-		switch (ps) {
+		switch (id_priv->id.ps) {
 		case RDMA_PS_SDP:
 			sdp_hdr = hdr;
 			if (sdp_get_majv(sdp_hdr->sdp_version) != SDP_MAJ_VERSION)
@@ -2642,7 +2650,6 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 			      struct rdma_conn_param *conn_param)
 {
 	struct ib_cm_sidr_req_param req;
-	struct rdma_route *route;
 	struct ib_cm_id	*id;
 	int ret;
 
@@ -2659,8 +2666,7 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 		memcpy((void *) req.private_data + sizeof(struct cma_hdr),
 		       conn_param->private_data, conn_param->private_data_len);
 
-	route = &id_priv->id.route;
-	ret = cma_format_hdr((void *) req.private_data, id_priv->id.ps, route);
+	ret = cma_format_hdr((void *) req.private_data, id_priv);
 	if (ret)
 		goto out;
 
@@ -2672,9 +2678,8 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 	}
 	id_priv->cm_id.ib = id;
 
-	req.path = route->path_rec;
-	req.service_id = cma_get_service_id(id_priv->id.ps,
-					    (struct sockaddr *) &route->addr.dst_addr);
+	req.path = id_priv->id.route.path_rec;
+	req.service_id = cma_get_service_id(id_priv->id.ps, cma_dst_addr(id_priv));
 	req.timeout_ms = 1 << (CMA_CM_RESPONSE_TIMEOUT - 8);
 	req.max_cm_retries = CMA_MAX_CM_RETRIES;
 
@@ -2719,7 +2724,7 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 	id_priv->cm_id.ib = id;
 
 	route = &id_priv->id.route;
-	ret = cma_format_hdr(private_data, id_priv->id.ps, route);
+	ret = cma_format_hdr(private_data, id_priv);
 	if (ret)
 		goto out;
 	req.private_data = private_data;
@@ -2728,8 +2733,7 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 	if (route->num_paths == 2)
 		req.alternate_path = &route->path_rec[1];
 
-	req.service_id = cma_get_service_id(id_priv->id.ps,
-					    (struct sockaddr *) &route->addr.dst_addr);
+	req.service_id = cma_get_service_id(id_priv->id.ps, cma_dst_addr(id_priv));
 	req.qp_num = id_priv->qp_num;
 	req.qp_type = id_priv->id.qp_type;
 	req.starting_psn = id_priv->seq_num;
@@ -2768,10 +2772,10 @@ static int cma_connect_iw(struct rdma_id_private *id_priv,
 
 	id_priv->cm_id.iw = cm_id;
 
-	sin = (struct sockaddr_in*) &id_priv->id.route.addr.src_addr;
+	sin = (struct sockaddr_in *) cma_src_addr(id_priv);
 	cm_id->local_addr = *sin;
 
-	sin = (struct sockaddr_in*) &id_priv->id.route.addr.dst_addr;
+	sin = (struct sockaddr_in *) cma_dst_addr(id_priv);
 	cm_id->remote_addr = *sin;
 
 	ret = cma_modify_qp_rtr(id_priv, conn_param);
@@ -3536,29 +3540,29 @@ static int cma_get_id_stats(struct sk_buff *skb, struct netlink_callback *cb)
 			id_stats->bound_dev_if =
 				id->route.addr.dev_addr.bound_dev_if;
 
-			if (id->route.addr.src_addr.ss_family == AF_INET) {
+			if (cma_family(id_priv) == AF_INET) {
 				if (ibnl_put_attr(skb, nlh,
 						  sizeof(struct sockaddr_in),
-						  &id->route.addr.src_addr,
+						  cma_src_addr(id_priv),
 						  RDMA_NL_RDMA_CM_ATTR_SRC_ADDR)) {
 					goto out;
 				}
 				if (ibnl_put_attr(skb, nlh,
 						  sizeof(struct sockaddr_in),
-						  &id->route.addr.dst_addr,
+						  cma_dst_addr(id_priv),
 						  RDMA_NL_RDMA_CM_ATTR_DST_ADDR)) {
 					goto out;
 				}
-			} else if (id->route.addr.src_addr.ss_family == AF_INET6) {
+			} else if (cma_family(id_priv) == AF_INET6) {
 				if (ibnl_put_attr(skb, nlh,
 						  sizeof(struct sockaddr_in6),
-						  &id->route.addr.src_addr,
+						  cma_src_addr(id_priv),
 						  RDMA_NL_RDMA_CM_ATTR_SRC_ADDR)) {
 					goto out;
 				}
 				if (ibnl_put_attr(skb, nlh,
 						  sizeof(struct sockaddr_in6),
-						  &id->route.addr.dst_addr,
+						  cma_dst_addr(id_priv),
 						  RDMA_NL_RDMA_CM_ATTR_DST_ADDR)) {
 					goto out;
 				}
-- 
1.7.3
