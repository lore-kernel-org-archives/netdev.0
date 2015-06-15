From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 10/11] IB/cma: Share ib_cm_ids between rdma_cm_ids
Date: Mon, 15 Jun 2015 11:47:15 +0300
Message-ID: <1434358036-15526-11-git-send-email-haggaie@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use ib_cm_id_create_and_listen to create listening IB CM IDs or share
existing ones if needed. When given a request on a specific CM ID, the code
now matches the request to the RDMA CM ID based on the request parameters,
so it no longer needs to rely on the ib_cm's private data matching
capabilities.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c | 60 ++++---------------------------------------
 1 file changed, 5 insertions(+), 55 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 74e562ec5b93..c6d5fa7ab64a 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1722,42 +1722,6 @@ __be64 rdma_get_service_id(struct rdma_cm_id *id, struct sockaddr *addr)
 }
 EXPORT_SYMBOL(rdma_get_service_id);
 
-static void cma_set_compare_data(enum rdma_port_space ps, struct sockaddr *addr,
-				 struct ib_cm_compare_data *compare)
-{
-	struct cma_hdr *cma_data, *cma_mask;
-	__be32 ip4_addr;
-	struct in6_addr ip6_addr;
-
-	memset(compare, 0, sizeof *compare);
-	cma_data = (void *) compare->data;
-	cma_mask = (void *) compare->mask;
-
-	switch (addr->sa_family) {
-	case AF_INET:
-		ip4_addr = ((struct sockaddr_in *) addr)->sin_addr.s_addr;
-		cma_set_ip_ver(cma_data, 4);
-		cma_set_ip_ver(cma_mask, 0xF);
-		if (!cma_any_addr(addr)) {
-			cma_data->dst_addr.ip4.addr = ip4_addr;
-			cma_mask->dst_addr.ip4.addr = htonl(~0);
-		}
-		break;
-	case AF_INET6:
-		ip6_addr = ((struct sockaddr_in6 *) addr)->sin6_addr;
-		cma_set_ip_ver(cma_data, 6);
-		cma_set_ip_ver(cma_mask, 0xF);
-		if (!cma_any_addr(addr)) {
-			cma_data->dst_addr.ip6 = ip6_addr;
-			memset(&cma_mask->dst_addr.ip6, 0xFF,
-			       sizeof cma_mask->dst_addr.ip6);
-		}
-		break;
-	default:
-		break;
-	}
-}
-
 static int cma_iw_handler(struct iw_cm_id *iw_id, struct iw_cm_event *iw_event)
 {
 	struct rdma_id_private *id_priv = iw_id->context;
@@ -1911,33 +1875,19 @@ out:
 
 static int cma_ib_listen(struct rdma_id_private *id_priv)
 {
-	struct ib_cm_compare_data compare_data;
 	struct sockaddr *addr;
 	struct ib_cm_id	*id;
 	__be64 svc_id;
-	int ret;
 
-	id = ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv);
+	addr = cma_src_addr(id_priv);
+	svc_id = rdma_get_service_id(&id_priv->id, addr);
+	id = ib_cm_id_create_and_listen(id_priv->id.device, cma_req_handler,
+					svc_id, 0);
 	if (IS_ERR(id))
 		return PTR_ERR(id);
-
 	id_priv->cm_id.ib = id;
 
-	addr = cma_src_addr(id_priv);
-	svc_id = rdma_get_service_id(&id_priv->id, addr);
-	if (cma_any_addr(addr) && !id_priv->afonly)
-		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0, NULL);
-	else {
-		cma_set_compare_data(id_priv->id.ps, addr, &compare_data);
-		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0, &compare_data);
-	}
-
-	if (ret) {
-		ib_destroy_cm_id(id_priv->cm_id.ib);
-		id_priv->cm_id.ib = NULL;
-	}
-
-	return ret;
+	return 0;
 }
 
 static int cma_iw_listen(struct rdma_id_private *id_priv, int backlog)
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
