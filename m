From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv6 net-next 30/31] iw_cxgb4: Max fastreg depth depends on DSGL support
Date: Wed, 12 Mar 2014 21:20:45 +0530
Message-ID: <1394639446-6504-31-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6614 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755398AbaCLQAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 12:00:39 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

The max depth of a fastreg mr depends on  whether the device supports DSGL or not.  So
compute it dynamically based on the device support and the module use_dsgl option.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/provider.c | 2 +-
 drivers/infiniband/hw/cxgb4/qp.c       | 3 ++-
 drivers/infiniband/hw/cxgb4/t4.h       | 9 ++++++++-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index d1565a4..9e1a409 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -327,7 +327,7 @@ static int c4iw_query_device(struct ib_device *ibdev,
 	props->max_mr = c4iw_num_stags(&dev->rdev);
 	props->max_pd = T4_MAX_NUM_PD;
 	props->local_ca_ack_delay = 0;
-	props->max_fast_reg_page_list_len = T4_MAX_FR_DEPTH;
+	props->max_fast_reg_page_list_len = t4_max_fr_depth(use_dsgl);
 
 	return 0;
 }
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index dfe37fc..9f9cdc5 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -560,7 +560,8 @@ static int build_fastreg(struct t4_sq *sq, union t4_wr *wqe,
 	int pbllen = roundup(wr->wr.fast_reg.page_list_len * sizeof(u64), 32);
 	int rem;
 
-	if (wr->wr.fast_reg.page_list_len > T4_MAX_FR_DEPTH)
+	if (wr->wr.fast_reg.page_list_len >
+	    t4_max_fr_depth(use_dsgl))
 		return -EINVAL;
 
 	wqe->fr.qpbinde_to_dcacpu = 0;
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index ace3154..1543d6b 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -84,7 +84,14 @@ struct t4_status_page {
 			sizeof(struct fw_ri_isgl)) / sizeof(struct fw_ri_sge))
 #define T4_MAX_FR_IMMD ((T4_SQ_NUM_BYTES - sizeof(struct fw_ri_fr_nsmr_wr) - \
 			sizeof(struct fw_ri_immd)) & ~31UL)
-#define T4_MAX_FR_DEPTH (1024 / sizeof(u64))
+#define T4_MAX_FR_IMMD_DEPTH (T4_MAX_FR_IMMD / sizeof(u64))
+#define T4_MAX_FR_DSGL 1024
+#define T4_MAX_FR_DSGL_DEPTH (T4_MAX_FR_DSGL / sizeof(u64))
+
+static inline int t4_max_fr_depth(int use_dsgl)
+{
+	return use_dsgl ? T4_MAX_FR_DSGL_DEPTH : T4_MAX_FR_IMMD_DEPTH;
+}
 
 #define T4_RQ_NUM_SLOTS 2
 #define T4_RQ_NUM_BYTES (T4_EQ_ENTRY_SIZE * T4_RQ_NUM_SLOTS)
-- 
1.8.4
