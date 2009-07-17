From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 12/15] RDS/IB: Always use PAGE_SIZE for FMR page size
Date: Fri, 17 Jul 2009 16:13:33 -0700
Message-ID: <1247872416-17834-13-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:47252 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756971AbZGRCpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 22:45:17 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6I2kqm7023603
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 18 Jul 2009 02:46:54 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While FMRs allow significant flexibility in what size of pages they can use,
we really just want FMR pages to match CPU page size. Roland says we can
count on this always being supported, so this simplifies things.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.c      |    3 ---
 net/rds/ib.h      |    3 ---
 net/rds/ib_rdma.c |   12 ++++++------
 3 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 27abdd3..868559a 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -85,9 +85,6 @@ void rds_ib_add_one(struct ib_device *device)
 	rds_ibdev->max_wrs = dev_attr->max_qp_wr;
 	rds_ibdev->max_sge = min(dev_attr->max_sge, RDS_IB_MAX_SGE);
 
-	rds_ibdev->fmr_page_shift = max(9, ffs(dev_attr->page_size_cap) - 1);
-	rds_ibdev->fmr_page_size  = 1 << rds_ibdev->fmr_page_shift;
-	rds_ibdev->fmr_page_mask  = ~((u64) rds_ibdev->fmr_page_size - 1);
 	rds_ibdev->fmr_max_remaps = dev_attr->max_map_per_fmr?: 32;
 	rds_ibdev->max_fmrs = dev_attr->max_fmr ?
 			min_t(unsigned int, dev_attr->max_fmr, fmr_pool_size) :
diff --git a/net/rds/ib.h b/net/rds/ib.h
index c0de7af..1378b85 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -159,9 +159,6 @@ struct rds_ib_device {
 	struct ib_pd		*pd;
 	struct ib_mr		*mr;
 	struct rds_ib_mr_pool	*mr_pool;
-	int			fmr_page_shift;
-	int			fmr_page_size;
-	u64			fmr_page_mask;
 	unsigned int		fmr_max_remaps;
 	unsigned int		max_fmrs;
 	int			max_sge;
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 81033af..ef3ab5b 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -211,7 +211,7 @@ struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev)
 
 	pool->fmr_attr.max_pages = fmr_message_size;
 	pool->fmr_attr.max_maps = rds_ibdev->fmr_max_remaps;
-	pool->fmr_attr.page_shift = rds_ibdev->fmr_page_shift;
+	pool->fmr_attr.page_shift = PAGE_SHIFT;
 	pool->max_free_pinned = rds_ibdev->max_fmrs * fmr_message_size / 4;
 
 	/* We never allow more than max_items MRs to be allocated.
@@ -349,13 +349,13 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibm
 		unsigned int dma_len = ib_sg_dma_len(dev, &scat[i]);
 		u64 dma_addr = ib_sg_dma_address(dev, &scat[i]);
 
-		if (dma_addr & ~rds_ibdev->fmr_page_mask) {
+		if (dma_addr & ~PAGE_MASK) {
 			if (i > 0)
 				return -EINVAL;
 			else
 				++page_cnt;
 		}
-		if ((dma_addr + dma_len) & ~rds_ibdev->fmr_page_mask) {
+		if ((dma_addr + dma_len) & ~PAGE_MASK) {
 			if (i < sg_dma_len - 1)
 				return -EINVAL;
 			else
@@ -365,7 +365,7 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibm
 		len += dma_len;
 	}
 
-	page_cnt += len >> rds_ibdev->fmr_page_shift;
+	page_cnt += len >> PAGE_SHIFT;
 	if (page_cnt > fmr_message_size)
 		return -EINVAL;
 
@@ -378,9 +378,9 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibm
 		unsigned int dma_len = ib_sg_dma_len(dev, &scat[i]);
 		u64 dma_addr = ib_sg_dma_address(dev, &scat[i]);
 
-		for (j = 0; j < dma_len; j += rds_ibdev->fmr_page_size)
+		for (j = 0; j < dma_len; j += PAGE_SIZE)
 			dma_pages[page_cnt++] =
-				(dma_addr & rds_ibdev->fmr_page_mask) + j;
+				(dma_addr & PAGE_MASK) + j;
 	}
 
 	ret = ib_map_phys_fmr(ibmr->fmr,
-- 
1.6.0.4

