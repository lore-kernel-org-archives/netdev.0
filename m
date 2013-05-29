From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 12/28] rdma/cm: Add support for AF_IB to rdma_resolve_route
Date: Wed, 29 May 2013 10:09:18 -0700
Message-ID: <1369847374-12176-13-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Allow rdma_resolve_route to handle the case where the user
specified the source and destination addresses using AF_IB.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 2b5dfee..f54169b 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1743,6 +1743,7 @@ static int cma_query_ib_route(struct rdma_id_private *id_priv, int timeout_ms,
 	struct ib_sa_path_rec path_rec;
 	ib_sa_comp_mask comp_mask;
 	struct sockaddr_in6 *sin6;
+	struct sockaddr_ib *sib;
 
 	memset(&path_rec, 0, sizeof path_rec);
 	rdma_addr_get_sgid(dev_addr, &path_rec.sgid);
@@ -1756,13 +1757,21 @@ static int cma_query_ib_route(struct rdma_id_private *id_priv, int timeout_ms,
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
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
