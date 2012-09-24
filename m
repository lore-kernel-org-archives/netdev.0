From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 19/26 v3] rdma/cm: Export cma_get_service_id
Date: Mon, 24 Sep 2012 23:55:35 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F138@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Allow the rdma_ucm to query the IB service ID formed or
allocated by the rdma_cm by exporting the cma_get_service_id
functionality.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |   13 +++++++------
 include/rdma/rdma_cm.h        |    7 +++++++
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d7bc654..8f9c05f 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1377,13 +1377,14 @@ err1:
 	return ret;
 }
 
-static __be64 cma_get_service_id(enum rdma_port_space ps, struct sockaddr *addr)
+__be64 rdma_get_service_id(struct rdma_cm_id *id, struct sockaddr *addr)
 {
 	if (addr->sa_family == AF_IB)
 		return ((struct sockaddr_ib *) addr)->sib_sid;
 
-	return cpu_to_be64(((u64)ps << 16) + be16_to_cpu(cma_port(addr)));
+	return cpu_to_be64(((u64)id->ps << 16) + be16_to_cpu(cma_port(addr)));
 }
+EXPORT_SYMBOL(rdma_get_service_id);
 
 static void cma_set_compare_data(enum rdma_port_space ps, struct sockaddr *addr,
 				 struct ib_cm_compare_data *compare)
@@ -1611,7 +1612,7 @@ static int cma_ib_listen(struct rdma_id_private *id_priv)
 	id_priv->cm_id.ib = id;
 
 	addr = cma_src_addr(id_priv);
-	svc_id = cma_get_service_id(id_priv->id.ps, addr);
+	svc_id = rdma_get_service_id(&id_priv->id, addr);
 	if (cma_any_addr(addr))
 		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0, NULL);
 	else {
@@ -1753,7 +1754,7 @@ static int cma_query_ib_route(struct rdma_id_private *id_priv, int timeout_ms,
 	path_rec.pkey = cpu_to_be16(ib_addr_get_pkey(dev_addr));
 	path_rec.numb_path = 1;
 	path_rec.reversible = 1;
-	path_rec.service_id = cma_get_service_id(id_priv->id.ps, cma_dst_addr(id_priv));
+	path_rec.service_id = rdma_get_service_id(&id_priv->id, cma_dst_addr(id_priv));
 
 	comp_mask = IB_SA_PATH_REC_DGID | IB_SA_PATH_REC_SGID |
 		    IB_SA_PATH_REC_PKEY | IB_SA_PATH_REC_NUMB_PATH |
@@ -2767,7 +2768,7 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 	id_priv->cm_id.ib = id;
 
 	req.path = id_priv->id.route.path_rec;
-	req.service_id = cma_get_service_id(id_priv->id.ps, cma_dst_addr(id_priv));
+	req.service_id = rdma_get_service_id(&id_priv->id, cma_dst_addr(id_priv));
 	req.timeout_ms = 1 << (CMA_CM_RESPONSE_TIMEOUT - 8);
 	req.max_cm_retries = CMA_MAX_CM_RETRIES;
 
@@ -2821,7 +2822,7 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 	if (route->num_paths == 2)
 		req.alternate_path = &route->path_rec[1];
 
-	req.service_id = cma_get_service_id(id_priv->id.ps, cma_dst_addr(id_priv));
+	req.service_id = rdma_get_service_id(&id_priv->id, cma_dst_addr(id_priv));
 	req.qp_num = id_priv->qp_num;
 	req.qp_type = id_priv->id.qp_type;
 	req.starting_psn = id_priv->seq_num;
diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
index 0bb190f..e240def 100644
--- a/include/rdma/rdma_cm.h
+++ b/include/rdma/rdma_cm.h
@@ -363,4 +363,11 @@ void rdma_set_service_type(struct rdma_cm_id *id, int tos);
  */
 int rdma_set_reuseaddr(struct rdma_cm_id *id, int reuse);
 
+/**
+ * rdma_get_service_id - Return the IB service ID for a specified address.
+ * @id: Communication identifier associated with the address.
+ * @addr: Address for the service ID.
+ */
+__be64 rdma_get_service_id(struct rdma_cm_id *id, struct sockaddr *addr);
+
 #endif /* RDMA_CM_H */


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
