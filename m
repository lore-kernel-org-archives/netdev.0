From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH 08/11] IB/cma: Add net_dev and private data checks to RDMA CM
Date: Mon, 15 Jun 2015 11:47:13 +0300
Message-ID: <1434358036-15526-9-git-send-email-haggaie@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41462 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753987AbbFOIsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 04:48:14 -0400
In-Reply-To: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of relying on a the ib_cm module to check an incoming CM request's
private data header, add these checks to the RDMA CM module. This allows a
following patch to to clean up the ib_cm interface and remove the code that
looks into the private headers. It will also allow supporting namespaces in
RDMA CM by making these checks namespace aware later on.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/infiniband/core/cma.c | 170 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 168 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index bb90d462f819..a43bbd57400c 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -300,7 +300,7 @@ static enum rdma_cm_state cma_exch(struct rdma_id_private *id_priv,
 	return old;
 }
 
-static inline u8 cma_get_ip_ver(struct cma_hdr *hdr)
+static inline u8 cma_get_ip_ver(const struct cma_hdr *hdr)
 {
 	return hdr->ip_version >> 4;
 }
@@ -1024,6 +1024,169 @@ static int cma_save_net_info(struct sockaddr *src_addr,
 	return cma_save_ip_info(src_addr, dst_addr, ib_event, service_id);
 }
 
+struct cma_req_info {
+	struct ib_device *device;
+	int port;
+	const union ib_gid *local_gid;
+	__be64 service_id;
+	u16 pkey;
+};
+
+static int cma_save_req_info(const struct ib_cm_event *ib_event,
+			     struct cma_req_info *req)
+{
+	const struct ib_cm_req_event_param *req_param =
+		&ib_event->param.req_rcvd;
+	const struct ib_cm_sidr_req_event_param *sidr_param =
+		&ib_event->param.sidr_req_rcvd;
+
+	switch (ib_event->event) {
+	case IB_CM_REQ_RECEIVED:
+		req->device	= req_param->listen_id->device;
+		req->port	= req_param->port;
+		req->local_gid	= &req_param->primary_path->sgid;
+		req->service_id	= req_param->primary_path->service_id;
+		req->pkey	= be16_to_cpu(req_param->primary_path->pkey);
+		break;
+	case IB_CM_SIDR_REQ_RECEIVED:
+		req->device	= sidr_param->listen_id->device;
+		req->port	= sidr_param->port;
+		req->local_gid	= sidr_param->grh ? &sidr_param->dgid : NULL;
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
+static struct net_device *cma_get_net_dev(struct ib_cm_event *ib_event,
+					  const struct cma_req_info *req)
+{
+	struct sockaddr_storage listen_addr_storage;
+	struct sockaddr *listen_addr = (struct sockaddr *)&listen_addr_storage;
+	struct net_device *net_dev;
+	int err;
+
+	err = cma_save_ip_info(listen_addr, NULL, ib_event, req->service_id);
+	if (err)
+		return ERR_PTR(err);
+
+	net_dev = ib_get_net_dev_by_params(req->device, req->port, req->pkey,
+					   req->local_gid, listen_addr);
+	if (!net_dev)
+		return ERR_PTR(-ENODEV);
+
+	return net_dev;
+}
+
+static enum rdma_port_space rdma_ps_from_service_id(__be64 service_id)
+{
+	return (be64_to_cpu(service_id) >> 16) & 0xffff;
+}
+
+static bool cma_match_private_data(struct rdma_id_private *id_priv,
+				   const struct cma_hdr *hdr)
+{
+	struct sockaddr *addr = cma_src_addr(id_priv);
+	__be32 ip4_addr;
+	struct in6_addr ip6_addr;
+
+	if (cma_any_addr(addr) && !id_priv->afonly)
+		return true;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		ip4_addr = ((struct sockaddr_in *)addr)->sin_addr.s_addr;
+		if (cma_get_ip_ver(hdr) != 4)
+			return false;
+		if (!cma_any_addr(addr) &&
+		    hdr->dst_addr.ip4.addr != ip4_addr)
+			return false;
+		break;
+	case AF_INET6:
+		ip6_addr = ((struct sockaddr_in6 *)addr)->sin6_addr;
+		if (cma_get_ip_ver(hdr) != 6)
+			return false;
+		if (!cma_any_addr(addr) &&
+		    memcmp(&hdr->dst_addr.ip6, &ip6_addr, sizeof(ip6_addr)))
+			return false;
+		break;
+	default:
+		return false;
+	}
+
+	return true;
+}
+
+static bool cma_match_net_dev(const struct rdma_id_private *id_priv,
+			      const struct net_device *net_dev)
+{
+	const struct rdma_dev_addr *addr = &id_priv->id.route.addr.dev_addr;
+
+	return !addr->bound_dev_if ||
+	       (net_eq(dev_net(net_dev), &init_net) &&
+		addr->bound_dev_if == net_dev->ifindex);
+}
+
+static struct rdma_id_private *cma_find_listener(
+		const struct rdma_bind_list *bind_list,
+		const struct ib_cm_id *cm_id,
+		const struct ib_cm_event *ib_event,
+		const struct cma_req_info *req,
+		const struct net_device *net_dev)
+{
+	struct rdma_id_private *id_priv, *id_priv_dev;
+
+	if (!bind_list)
+		return ERR_PTR(-EINVAL);
+
+	hlist_for_each_entry(id_priv, &bind_list->owners, node) {
+		if (cma_match_private_data(id_priv, ib_event->private_data)) {
+			if (id_priv->id.device == cm_id->device &&
+			    cma_match_net_dev(id_priv, net_dev))
+				return id_priv;
+			list_for_each_entry(id_priv_dev,
+					    &id_priv->listen_list,
+					    listen_list) {
+				if (id_priv_dev->id.device == cm_id->device &&
+				    cma_match_net_dev(id_priv_dev, net_dev))
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
+	struct rdma_bind_list *bind_list;
+	struct rdma_id_private *id_priv;
+	struct net_device *net_dev;
+	int err;
+
+	err = cma_save_req_info(ib_event, &req);
+	if (err)
+		return ERR_PTR(err);
+
+	net_dev = cma_get_net_dev(ib_event, &req);
+	if (IS_ERR(net_dev))
+		return ERR_PTR(PTR_ERR(net_dev));
+
+	bind_list = cma_ps_find(rdma_ps_from_service_id(req.service_id),
+				cma_port_from_service_id(req.service_id));
+	id_priv = cma_find_listener(bind_list, cm_id, ib_event, &req, net_dev);
+
+	dev_put(net_dev);
+
+	return id_priv;
+}
+
 static inline int cma_user_data_offset(struct rdma_id_private *id_priv)
 {
 	return cma_family(id_priv) == AF_IB ? 0 : sizeof(struct cma_hdr);
@@ -1383,7 +1546,10 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 	struct rdma_cm_event event;
 	int offset, ret;
 
-	listen_id = cm_id->context;
+	listen_id = cma_id_from_event(cm_id, ib_event);
+	if (IS_ERR(listen_id))
+		return PTR_ERR(listen_id);
+
 	if (!cma_check_req_qp_type(&listen_id->id, ib_event))
 		return -EINVAL;
 
-- 
1.7.11.2
