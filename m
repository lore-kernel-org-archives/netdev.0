From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 41/44] powerpc/cell: clean up fixed mapping dma_ops initialization
Date: Thu,  8 Jun 2017 15:26:06 +0200
Message-ID: <20170608132609.32662-42-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By the time cell_pci_dma_dev_setup calls cell_dma_dev_setup no device can
have the fixed map_ops set yet as it's only set by the set_dma_mask
method.  So move the setup for the fixed case to be only called in that
place instead of indirecting through cell_dma_dev_setup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/platforms/cell/iommu.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 948086e33a0c..497bfbdbd967 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -663,14 +663,9 @@ static const struct dma_map_ops dma_iommu_fixed_ops = {
 	.mapping_error	= dma_iommu_mapping_error,
 };
 
-static void cell_dma_dev_setup_fixed(struct device *dev);
-
 static void cell_dma_dev_setup(struct device *dev)
 {
-	/* Order is important here, these are not mutually exclusive */
-	if (get_dma_ops(dev) == &dma_iommu_fixed_ops)
-		cell_dma_dev_setup_fixed(dev);
-	else if (get_pci_dma_ops() == &dma_iommu_ops)
+	if (get_pci_dma_ops() == &dma_iommu_ops)
 		set_iommu_table_base(dev, cell_get_iommu_table(dev));
 	else if (get_pci_dma_ops() == &dma_direct_ops)
 		set_dma_offset(dev, cell_dma_direct_offset);
@@ -963,32 +958,24 @@ static int dma_set_mask_and_switch(struct device *dev, u64 dma_mask)
 		return -EIO;
 
 	if (dma_mask == DMA_BIT_MASK(64) &&
-		cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR)
-	{
+	    cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR) {
+		u64 addr = cell_iommu_get_fixed_address(dev) +
+			dma_iommu_fixed_base;
 		dev_dbg(dev, "iommu: 64-bit OK, using fixed ops\n");
+		dev_dbg(dev, "iommu: fixed addr = %llx\n", addr);
 		set_dma_ops(dev, &dma_iommu_fixed_ops);
+		set_dma_offset(dev, addr);
 	} else {
 		dev_dbg(dev, "iommu: not 64-bit, using default ops\n");
 		set_dma_ops(dev, get_pci_dma_ops());
+		cell_dma_dev_setup(dev);
 	}
 
-	cell_dma_dev_setup(dev);
-
 	*dev->dma_mask = dma_mask;
 
 	return 0;
 }
 
-static void cell_dma_dev_setup_fixed(struct device *dev)
-{
-	u64 addr;
-
-	addr = cell_iommu_get_fixed_address(dev) + dma_iommu_fixed_base;
-	set_dma_offset(dev, addr);
-
-	dev_dbg(dev, "iommu: fixed addr = %llx\n", addr);
-}
-
 static void insert_16M_pte(unsigned long addr, unsigned long *ptab,
 			   unsigned long base_pte)
 {
-- 
2.11.0
