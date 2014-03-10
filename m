From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 15/31] iw_cxgb4: save the correct map length for fast_reg_page_lists
Date: Mon, 10 Mar 2014 22:38:12 +0530
Message-ID: <1394471308-4304-16-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3813 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754189AbaCJRRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:17:48 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

We cannot save the mapped length using the rdma max_page_list_len field
of the ib_fast_reg_page_list struct because the core code uses it.  This
results in an incorrect unmap of the page list in c4iw_free_fastreg_pbl().

I found this with dma map debugging enabled in the kernel.  The fix is
to save the length in the c4iw_fr_page_list struct.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |  1 +
 drivers/infiniband/hw/cxgb4/mem.c      | 12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 8c32088..b75f8f5 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -375,6 +375,7 @@ struct c4iw_fr_page_list {
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 	dma_addr_t dma_addr;
 	struct c4iw_dev *dev;
+	int pll_len;
 };
 
 static inline struct c4iw_fr_page_list *to_c4iw_fr_page_list(
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index 41b1195..cdaf257 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -903,7 +903,11 @@ struct ib_fast_reg_page_list *c4iw_alloc_fastreg_pbl(struct ib_device *device,
 	dma_unmap_addr_set(c4pl, mapping, dma_addr);
 	c4pl->dma_addr = dma_addr;
 	c4pl->dev = dev;
-	c4pl->ibpl.max_page_list_len = pll_len;
+	c4pl->pll_len = pll_len;
+
+	PDBG("%s c4pl %p pll_len %u page_list %p dma_addr %p\n",
+	     __func__, c4pl, c4pl->pll_len, c4pl->ibpl.page_list,
+	     (void *)c4pl->dma_addr);
 
 	return &c4pl->ibpl;
 }
@@ -912,8 +916,12 @@ void c4iw_free_fastreg_pbl(struct ib_fast_reg_page_list *ibpl)
 {
 	struct c4iw_fr_page_list *c4pl = to_c4iw_fr_page_list(ibpl);
 
+	PDBG("%s c4pl %p pll_len %u page_list %p dma_addr %p\n",
+	     __func__, c4pl, c4pl->pll_len, c4pl->ibpl.page_list,
+	     (void *)c4pl->dma_addr);
+
 	dma_free_coherent(&c4pl->dev->rdev.lldi.pdev->dev,
-			  c4pl->ibpl.max_page_list_len,
+			  c4pl->pll_len,
 			  c4pl->ibpl.page_list, dma_unmap_addr(c4pl, mapping));
 	kfree(c4pl);
 }
-- 
1.8.4
