From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 13/15] RDS/IW: Remove page_shift variable from iwarp transport
Date: Fri, 17 Jul 2009 16:13:34 -0700
Message-ID: <1247872416-17834-14-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:39314 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758081AbZGRAOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 20:14:55 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6I0EUt6031073
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 18 Jul 2009 00:14:31 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing code treated page_shift as a variable, when in fact we
always want to have the fastreg page size be the same as the arch's
page size -- and it is, so this doesn't need to be a variable.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/iw.c      |    2 --
 net/rds/iw.h      |    1 -
 net/rds/iw_rdma.c |   28 ++++++++++------------------
 net/rds/iw_send.c |    2 +-
 4 files changed, 11 insertions(+), 22 deletions(-)

diff --git a/net/rds/iw.c b/net/rds/iw.c
index d16e1cb..2e6b495 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -83,8 +83,6 @@ void rds_iw_add_one(struct ib_device *device)
 	rds_iwdev->max_wrs = dev_attr->max_qp_wr;
 	rds_iwdev->max_sge = min(dev_attr->max_sge, RDS_IW_MAX_SGE);
 
-	rds_iwdev->page_shift = max(PAGE_SHIFT, ffs(dev_attr->page_size_cap) - 1);
-
 	rds_iwdev->dev = device;
 	rds_iwdev->pd = ib_alloc_pd(device);
 	if (IS_ERR(rds_iwdev->pd))
diff --git a/net/rds/iw.h b/net/rds/iw.h
index 0715dde..dd72b62 100644
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -181,7 +181,6 @@ struct rds_iw_device {
 	struct ib_pd		*pd;
 	struct ib_mr		*mr;
 	struct rds_iw_mr_pool	*mr_pool;
-	int			page_shift;
 	int			max_sge;
 	unsigned int		max_wrs;
 	unsigned int		dma_local_lkey:1;
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index dcdb37d..de4a1b1 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -263,18 +263,12 @@ static void rds_iw_set_scatterlist(struct rds_iw_scatterlist *sg,
 }
 
 static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
-			struct rds_iw_scatterlist *sg,
-			unsigned int dma_page_shift)
+			struct rds_iw_scatterlist *sg)
 {
 	struct ib_device *dev = rds_iwdev->dev;
 	u64 *dma_pages = NULL;
-	u64 dma_mask;
-	unsigned int dma_page_size;
 	int i, j, ret;
 
-	dma_page_size = 1 << dma_page_shift;
-	dma_mask = dma_page_size - 1;
-
 	WARN_ON(sg->dma_len);
 
 	sg->dma_len = ib_dma_map_sg(dev, sg->list, sg->len, DMA_BIDIRECTIONAL);
@@ -295,18 +289,18 @@ static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
 		sg->bytes += dma_len;
 
 		end_addr = dma_addr + dma_len;
-		if (dma_addr & dma_mask) {
+		if (dma_addr & PAGE_MASK) {
 			if (i > 0)
 				goto out_unmap;
-			dma_addr &= ~dma_mask;
+			dma_addr &= ~PAGE_MASK;
 		}
-		if (end_addr & dma_mask) {
+		if (end_addr & PAGE_MASK) {
 			if (i < sg->dma_len - 1)
 				goto out_unmap;
-			end_addr = (end_addr + dma_mask) & ~dma_mask;
+			end_addr = (end_addr + PAGE_MASK) & ~PAGE_MASK;
 		}
 
-		sg->dma_npages += (end_addr - dma_addr) >> dma_page_shift;
+		sg->dma_npages += (end_addr - dma_addr) >> PAGE_SHIFT;
 	}
 
 	/* Now gather the dma addrs into one list */
@@ -325,8 +319,8 @@ static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
 		u64 end_addr;
 
 		end_addr = dma_addr + dma_len;
-		dma_addr &= ~dma_mask;
-		for (; dma_addr < end_addr; dma_addr += dma_page_size)
+		dma_addr &= ~PAGE_MASK;
+		for (; dma_addr < end_addr; dma_addr += PAGE_SIZE)
 			dma_pages[j++] = dma_addr;
 		BUG_ON(j > sg->dma_npages);
 	}
@@ -727,7 +721,7 @@ static int rds_iw_rdma_build_fastreg(struct rds_iw_mapping *mapping)
 	f_wr.wr.fast_reg.rkey = mapping->m_rkey;
 	f_wr.wr.fast_reg.page_list = ibmr->page_list;
 	f_wr.wr.fast_reg.page_list_len = mapping->m_sg.dma_len;
-	f_wr.wr.fast_reg.page_shift = ibmr->device->page_shift;
+	f_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	f_wr.wr.fast_reg.access_flags = IB_ACCESS_LOCAL_WRITE |
 				IB_ACCESS_REMOTE_READ |
 				IB_ACCESS_REMOTE_WRITE;
@@ -780,9 +774,7 @@ static int rds_iw_map_fastreg(struct rds_iw_mr_pool *pool,
 
 	rds_iw_set_scatterlist(&mapping->m_sg, sg, sg_len);
 
-	dma_pages = rds_iw_map_scatterlist(rds_iwdev,
-				&mapping->m_sg,
-				rds_iwdev->page_shift);
+	dma_pages = rds_iw_map_scatterlist(rds_iwdev, &mapping->m_sg);
 	if (IS_ERR(dma_pages)) {
 		ret = PTR_ERR(dma_pages);
 		dma_pages = NULL;
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 44a6a05..1f5abe3 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -779,7 +779,7 @@ static void rds_iw_build_send_fastreg(struct rds_iw_device *rds_iwdev, struct rd
 	send->s_wr.wr.fast_reg.rkey = send->s_mr->rkey;
 	send->s_wr.wr.fast_reg.page_list = send->s_page_list;
 	send->s_wr.wr.fast_reg.page_list_len = nent;
-	send->s_wr.wr.fast_reg.page_shift = rds_iwdev->page_shift;
+	send->s_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	send->s_wr.wr.fast_reg.access_flags = IB_ACCESS_REMOTE_WRITE;
 	send->s_wr.wr.fast_reg.iova_start = sg_addr;
 
-- 
1.6.0.4

