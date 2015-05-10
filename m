From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v3 for-next 09/13] IB/cma: Add compare_data checks to the RDMA CM module
Date: Sun, 10 May 2015 13:26:40 +0300
Message-ID: <1431253604-9214-10-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:49409 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752552AbbEJK1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 06:27:47 -0400
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously RDMA CM relied on the CM module to check the incoming requests
against "compare data" struct to dispatch events for different RDMA CM IDs
based on the request parameters (IP address, address family, etc.). With
namespace support, multiple namespaces in RDMA CM will need to share a
single CM ID. Such an ID cannot be associated with a specific compare data,
because that could create conflicts with other namespaces.

The patch adds checks to verify that incoming requests match their RDMA CM
ID destination inside the RDMA CM module itself.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/infiniband/core/cm.c  |  5 +++--
 drivers/infiniband/core/cma.c | 12 +++++++++---
 include/rdma/ib_cm.h          |  3 +++
 3 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index fc33fb215e55..d023639a9f75 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -459,8 +459,8 @@ static int cm_compare_data(struct ib_cm_compare_data *src_data,
 	return memcmp(src, dst, sizeof(src));
 }
 
-static int cm_compare_private_data(u32 *private_data,
-				   struct ib_cm_compare_data *dst_data)
+int cm_compare_private_data(u32 *private_data,
+			    struct ib_cm_compare_data *dst_data)
 {
 	u32 src[IB_CM_COMPARE_SIZE];
 
@@ -470,6 +470,7 @@ static int cm_compare_private_data(u32 *private_data,
 	cm_mask_copy(src, private_data, dst_data->mask);
 	return memcmp(src, dst_data->data, sizeof(src));
 }
+EXPORT_SYMBOL(cm_compare_private_data);
 
 /*
  * Trivial helpers to strip endian annotation and compare; the
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index b5d3321e613e..1f591458b4de 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -146,6 +146,7 @@ struct rdma_id_private {
 	u8			tos;
 	u8			reuseaddr;
 	u8			afonly;
+	struct ib_cm_compare_data compare_data;
 };
 
 struct cma_multicast {
@@ -1319,6 +1320,10 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 	int offset, ret;
 
 	listen_id = cm_id->context;
+	if (cm_compare_private_data(ib_event->private_data,
+				    &listen_id->compare_data))
+		return -EINVAL;
+
 	if (!cma_check_req_qp_type(&listen_id->id, ib_event))
 		return -EINVAL;
 
@@ -1586,7 +1591,6 @@ out:
 
 static int cma_ib_listen(struct rdma_id_private *id_priv)
 {
-	struct ib_cm_compare_data compare_data;
 	struct sockaddr *addr;
 	struct ib_cm_id	*id;
 	__be64 svc_id;
@@ -1603,8 +1607,10 @@ static int cma_ib_listen(struct rdma_id_private *id_priv)
 	if (cma_any_addr(addr) && !id_priv->afonly)
 		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0, NULL);
 	else {
-		cma_set_compare_data(id_priv->id.ps, addr, &compare_data);
-		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0, &compare_data);
+		cma_set_compare_data(id_priv->id.ps, addr,
+				     &id_priv->compare_data);
+		ret = ib_cm_listen(id_priv->cm_id.ib, svc_id, 0,
+				   &id_priv->compare_data);
 	}
 
 	if (ret) {
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 17e072d1677c..4c767b5daf50 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -347,6 +347,9 @@ struct ib_cm_compare_data {
 	u32  mask[IB_CM_COMPARE_SIZE];
 };
 
+int cm_compare_private_data(u32 *private_data,
+			    struct ib_cm_compare_data *dst_data);
+
 /**
  * ib_cm_listen - Initiates listening on the specified service ID for
  *   connection and service ID resolution requests.
-- 
1.7.11.2
