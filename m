From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 16/22] RDMA/cxgb4: Map pbl buffers for dma if using DSGL.
Date: Thu, 14 Mar 2013 20:39:02 +0530
Message-ID: <1363273748-25330-17-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/infiniband/hw/cxgb4/mem.c |   29 +++++++++++++++++++++++------
 1 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index 33db9ee..4cb8eb2 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -51,7 +51,7 @@ module_param(inline_threshold, int, 0644);
 MODULE_PARM_DESC(inline_threshold, "inline vs dsgl threshold (default=128)");
 
 static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
-				       u32 len, void *data, int wait)
+				       u32 len, dma_addr_t data, int wait)
 {
 	struct sk_buff *skb;
 	struct ulp_mem_io *req;
@@ -88,7 +88,7 @@ static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
 	sgl->cmd_nsge = cpu_to_be32(ULPTX_CMD(ULP_TX_SC_DSGL) |
 				    ULPTX_NSGE(1));
 	sgl->len0 = cpu_to_be32(len);
-	sgl->addr0 = cpu_to_be64(virt_to_phys(data));
+	sgl->addr0 = cpu_to_be64(data);
 
 	ret = c4iw_ofld_send(rdev, skb);
 	if (ret)
@@ -178,6 +178,13 @@ int _c4iw_write_mem_dma(struct c4iw_rdev *rdev, u32 addr, u32 len, void *data)
 	u32 remain = len;
 	u32 dmalen;
 	int ret = 0;
+	dma_addr_t daddr;
+	dma_addr_t save;
+
+	daddr = dma_map_single(&rdev->lldi.pdev->dev, data, len, DMA_TO_DEVICE);
+	if (dma_mapping_error(&rdev->lldi.pdev->dev, daddr))
+		return -1;
+	save = daddr;
 
 	while (remain > inline_threshold) {
 		if (remain < T4_ULPTX_MAX_DMA) {
@@ -188,16 +195,18 @@ int _c4iw_write_mem_dma(struct c4iw_rdev *rdev, u32 addr, u32 len, void *data)
 		} else
 			dmalen = T4_ULPTX_MAX_DMA;
 		remain -= dmalen;
-		ret = _c4iw_write_mem_dma_aligned(rdev, addr, dmalen, data,
+		ret = _c4iw_write_mem_dma_aligned(rdev, addr, dmalen, daddr,
 						 !remain);
 		if (ret)
 			goto out;
 		addr += dmalen >> 5;
 		data += dmalen;
+		daddr += dmalen;
 	}
 	if (remain)
 		ret = _c4iw_write_mem_inline(rdev, addr, remain, data);
 out:
+	dma_unmap_single(&rdev->lldi.pdev->dev, save, len, DMA_TO_DEVICE);
 	return ret;
 }
 
@@ -209,9 +218,17 @@ static int write_adapter_mem(struct c4iw_rdev *rdev, u32 addr, u32 len,
 			     void *data)
 {
 	if (is_t5(rdev->lldi.adapter_type) && use_dsgl) {
-		if (len > inline_threshold)
-			return _c4iw_write_mem_dma(rdev, addr, len, data);
-		else
+		if (len > inline_threshold) {
+			if (_c4iw_write_mem_dma(rdev, addr, len, data)) {
+				printk_ratelimited(KERN_WARNING
+						   "%s: dma map"
+						   " failure (non fatal)\n",
+						   pci_name(rdev->lldi.pdev));
+				return _c4iw_write_mem_inline(rdev, addr, len,
+							      data);
+			} else
+				return 0;
+		} else
 			return _c4iw_write_mem_inline(rdev, addr, len, data);
 	} else
 		return _c4iw_write_mem_inline(rdev, addr, len, data);
-- 
1.7.1

