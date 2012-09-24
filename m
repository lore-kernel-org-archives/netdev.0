From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 11/26 v3] rdma/cm: Add support for AF_IB to
 rdma_resolve_route
Date: Mon, 24 Sep 2012 23:55:32 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0F1@ORSMSX101.amr.corp.intel.com>
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

Allow rdma_resolve_route to handle the case where the user
specified the source and destination addresses using AF_IB.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 9d37c2f..cd4e197 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1733,6 +1733,7 @@ static int cma_query_ib_route(struct rdma_id_private *id_priv, int timeout_ms,
 	struct ib_sa_path_rec path_rec;
 	ib_sa_comp_mask comp_mask;
 	struct sockaddr_in6 *sin6;
+	struct sockaddr_ib *sib;
 
 	memset(&path_rec, 0, sizeof path_rec);
 	rdma_addr_get_sgid(dev_addr, &path_rec.sgid);
@@ -1746,13 +1747,21 @@ static int cma_query_ib_route(struct rdma_id_private *id_priv, int timeout_ms,
 		    IB_SA_PATH_REC_PKEY | IB_SA_PATH_REC_NUMB_PATH |
 		    IB_SA_PATH_REC_REVERSIBLE | IB_SA_PATH_REC_SERVICE_ID;
 
-	if (cma_family(id_priv) == AF_INET) {
+	switch (cma_family(id_priv)) {
+	case AF_INET:
 		path_rec.qos_class = cpu_to_be16((u16) id_priv->tos);
 		comp_mask |= IB_SA_PATH_REC_QOS_CLASS;
-	} else {
+		break;
+	case AF_INET6:
 		sin6 = (struct sockaddr_in6 *) cma_src_addr(id_priv);
 		path_rec.traffic_class = (u8) (be32_to_cpu(sin6->sin6_flowinfo) >> 20);
 		comp_mask |= IB_SA_PATH_REC_TRAFFIC_CLASS;
+		break;
+	case AF_IB:
+		sib = (struct sockaddr_ib *) cma_src_addr(id_priv);
+		path_rec.traffic_class = (u8) (be32_to_cpu(sib->sib_flowinfo) >> 20);
+		comp_mask |= IB_SA_PATH_REC_TRAFFIC_CLASS;
+		break;
 	}
 
 	id_priv->query_id = ib_sa_path_rec_get(&sa_client, id_priv->id.device,


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
