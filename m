From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCHv3 4/4] rds: ib: unmap the scatter/gather list when error
Date: Mon, 13 Mar 2017 01:43:48 -0400
Message-ID: <1489383828-7699-5-git-send-email-yanjun.zhu@oracle.com>
References: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49945 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbdCMFoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 01:44:13 -0400
In-Reply-To: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When some errors occur, the scatter/gather list mapped to DMA addresses
should be handled.

Cc: Joe Jin <joe.jin@oracle.com>
Cc: Junxiao Bi <junxiao.bi@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 net/rds/ib_fmr.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
index c936b0d..86ef907 100644
--- a/net/rds/ib_fmr.c
+++ b/net/rds/ib_fmr.c
@@ -112,29 +112,39 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev,
 		u64 dma_addr = ib_sg_dma_address(dev, &scat[i]);
 
 		if (dma_addr & ~PAGE_MASK) {
-			if (i > 0)
+			if (i > 0) {
+				ib_dma_unmap_sg(dev, sg, nents,
+						DMA_BIDIRECTIONAL);
 				return -EINVAL;
-			else
+			} else {
 				++page_cnt;
+			}
 		}
 		if ((dma_addr + dma_len) & ~PAGE_MASK) {
-			if (i < sg_dma_len - 1)
+			if (i < sg_dma_len - 1) {
+				ib_dma_unmap_sg(dev, sg, nents,
+						DMA_BIDIRECTIONAL);
 				return -EINVAL;
-			else
+			} else {
 				++page_cnt;
+			}
 		}
 
 		len += dma_len;
 	}
 
 	page_cnt += len >> PAGE_SHIFT;
-	if (page_cnt > ibmr->pool->fmr_attr.max_pages)
+	if (page_cnt > ibmr->pool->fmr_attr.max_pages) {
+		ib_dma_unmap_sg(dev, sg, nents, DMA_BIDIRECTIONAL);
 		return -EINVAL;
+	}
 
 	dma_pages = kmalloc_node(sizeof(u64) * page_cnt, GFP_ATOMIC,
 				 rdsibdev_to_node(rds_ibdev));
-	if (!dma_pages)
+	if (!dma_pages) {
+		ib_dma_unmap_sg(dev, sg, nents, DMA_BIDIRECTIONAL);
 		return -ENOMEM;
+	}
 
 	page_cnt = 0;
 	for (i = 0; i < sg_dma_len; ++i) {
@@ -147,8 +157,10 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev,
 	}
 
 	ret = ib_map_phys_fmr(fmr->fmr, dma_pages, page_cnt, io_addr);
-	if (ret)
+	if (ret) {
+		ib_dma_unmap_sg(dev, sg, nents, DMA_BIDIRECTIONAL);
 		goto out;
+	}
 
 	/* Success - we successfully remapped the MR, so we can
 	 * safely tear down the old mapping.
-- 
2.7.4
