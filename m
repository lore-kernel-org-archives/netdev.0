From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 4/11 RESEND] cxgb3 - Expose HW memory page info
Date: Tue, 21 Aug 2007 20:49:21 -0700
Message-ID: <20070822034921.9314.29368.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:21552 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756794AbXHVDtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 23:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

A HW issue requires limiting the receive window size
to 23 pages of internal memory.
These pages can be configured to different sizes,
thus the RDMA driver needs to know the
page size to enforce the upper limit.

Also assign explicit enum values.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_ctl_defs.h |   52 +++++++++++++++++++++---------------
 drivers/net/cxgb3/cxgb3_offload.c  |    7 +++++
 2 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxgb3_ctl_defs.h
index 2095dda..6c4f320 100644
--- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
+++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
@@ -33,27 +33,29 @@
 #define _CXGB3_OFFLOAD_CTL_DEFS_H
 
 enum {
-	GET_MAX_OUTSTANDING_WR,
-	GET_TX_MAX_CHUNK,
-	GET_TID_RANGE,
-	GET_STID_RANGE,
-	GET_RTBL_RANGE,
-	GET_L2T_CAPACITY,
-	GET_MTUS,
-	GET_WR_LEN,
-	GET_IFF_FROM_MAC,
-	GET_DDP_PARAMS,
-	GET_PORTS,
-
-	ULP_ISCSI_GET_PARAMS,
-	ULP_ISCSI_SET_PARAMS,
-
-	RDMA_GET_PARAMS,
-	RDMA_CQ_OP,
-	RDMA_CQ_SETUP,
-	RDMA_CQ_DISABLE,
-	RDMA_CTRL_QP_SETUP,
-	RDMA_GET_MEM,
+	GET_MAX_OUTSTANDING_WR 	= 0,
+	GET_TX_MAX_CHUNK	= 1,
+	GET_TID_RANGE		= 2,
+	GET_STID_RANGE		= 3,
+	GET_RTBL_RANGE		= 4,
+	GET_L2T_CAPACITY	= 5,
+	GET_MTUS		= 6,
+	GET_WR_LEN		= 7,
+	GET_IFF_FROM_MAC	= 8,
+	GET_DDP_PARAMS		= 9,
+	GET_PORTS		= 10,
+
+	ULP_ISCSI_GET_PARAMS	= 11,
+	ULP_ISCSI_SET_PARAMS	= 12,
+
+	RDMA_GET_PARAMS		= 13,
+	RDMA_CQ_OP		= 14,
+	RDMA_CQ_SETUP		= 15,
+	RDMA_CQ_DISABLE		= 16,
+	RDMA_CTRL_QP_SETUP	= 17,
+	RDMA_GET_MEM		= 18,
+
+	GET_RX_PAGE_INFO	= 50,
 };
 
 /*
@@ -161,4 +163,12 @@ struct rdma_ctrlqp_setup {
 	unsigned long long base_addr;
 	unsigned int size;
 };
+
+/*
+ * Offload TX/RX page information.
+ */
+struct ofld_page_info {
+	unsigned int page_size;  /* Page size, should be a power of 2 */
+	unsigned int num;        /* Number of pages */
+};
 #endif				/* _CXGB3_OFFLOAD_CTL_DEFS_H */
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index e620ed4..522c1be 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -317,6 +317,8 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
 	struct iff_mac *iffmacp;
 	struct ddp_params *ddpp;
 	struct adap_ports *ports;
+	struct ofld_page_info *rx_page_info;
+	struct tp_params *tp = &adapter->params.tp;
 	int i;
 
 	switch (req) {
@@ -382,6 +384,11 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
 		if (!offload_running(adapter))
 			return -EAGAIN;
 		return cxgb_rdma_ctl(adapter, req, data);
+	case GET_RX_PAGE_INFO:
+		rx_page_info = data;
+		rx_page_info->page_size = tp->rx_pg_size;
+		rx_page_info->num = tp->rx_num_pgs;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
