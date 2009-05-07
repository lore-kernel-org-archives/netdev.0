From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] remove DMA_nBIT_MASK macro
Date: Thu, 7 May 2009 14:14:16 +0900
Message-ID: <20090507141114M.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:58718 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbZEGFPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 01:15:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We replaced all DMA_nBIT_MASK macros with DMA_BIT_MASK(n) but why do
we still keep DMA_nBIT_MASK macros in include/linux/dma-mapping.h?

As long as these macros exist, people use them. The current git has
two users and linux-next have other users.

Is it better to remove DMA_nBIT_MASK macros completely now?

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] remove DMA_nBIT_MASK macros

This removes DMA_nBIT_MASK macros in dma-mapping.h so that we will not
have any new users.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/arm/mach-davinci/board-dm644x-evm.c |    4 ++--
 drivers/net/igbvf/netdev.c               |   13 +++++++------
 include/linux/dma-mapping.h              |   19 -------------------
 3 files changed, 9 insertions(+), 27 deletions(-)

diff --git a/arch/arm/mach-davinci/board-dm644x-evm.c b/arch/arm/mach-davinci/board-dm644x-evm.c
index c039674..b2e7f9c 100644
--- a/arch/arm/mach-davinci/board-dm644x-evm.c
+++ b/arch/arm/mach-davinci/board-dm644x-evm.c
@@ -211,7 +211,7 @@ static struct resource ide_resources[] = {
 	},
 };
 
-static u64 ide_dma_mask = DMA_32BIT_MASK;
+static u64 ide_dma_mask = DMA_BIT_MASK(32);
 
 static struct platform_device ide_dev = {
 	.name           = "palm_bk3710",
@@ -220,7 +220,7 @@ static struct platform_device ide_dev = {
 	.num_resources  = ARRAY_SIZE(ide_resources),
 	.dev = {
 		.dma_mask		= &ide_dma_mask,
-		.coherent_dma_mask      = DMA_32BIT_MASK,
+		.coherent_dma_mask      = DMA_BIT_MASK(32),
 	},
 };
 
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index b774666..c084d3b 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1279,7 +1279,7 @@ static void igbvf_configure_tx(struct igbvf_adapter *adapter)
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	ew32(TDLEN(0), tx_ring->count * sizeof(union e1000_adv_tx_desc));
 	tdba = tx_ring->dma;
-	ew32(TDBAL(0), (tdba & DMA_32BIT_MASK));
+	ew32(TDBAL(0), (tdba & DMA_BIT_MASK(32)));
 	ew32(TDBAH(0), (tdba >> 32));
 	ew32(TDH(0), 0);
 	ew32(TDT(0), 0);
@@ -1365,7 +1365,7 @@ static void igbvf_configure_rx(struct igbvf_adapter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
 	rdba = rx_ring->dma;
-	ew32(RDBAL(0), (rdba & DMA_32BIT_MASK));
+	ew32(RDBAL(0), (rdba & DMA_BIT_MASK(32)));
 	ew32(RDBAH(0), (rdba >> 32));
 	ew32(RDLEN(0), rx_ring->count * sizeof(union e1000_adv_rx_desc));
 	rx_ring->head = E1000_RDH(0);
@@ -2637,15 +2637,16 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 		return err;
 
 	pci_using_dac = 0;
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (!err)
 			pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			err = pci_set_consistent_dma_mask(pdev,
+							  DMA_BIT_MASK(32));
 			if (err) {
 				dev_err(&pdev->dev, "No usable DMA "
 				        "configuration, aborting\n");
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 8083b6a..f56e607 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -63,25 +63,6 @@ struct dma_map_ops {
 
 #define DMA_BIT_MASK(n)	(((n) == 64) ? ~0ULL : ((1ULL<<(n))-1))
 
-/*
- * NOTE: do not use the below macros in new code and do not add new definitions
- * here.
- *
- * Instead, just open-code DMA_BIT_MASK(n) within your driver
- */
-#define DMA_64BIT_MASK	DMA_BIT_MASK(64)
-#define DMA_48BIT_MASK	DMA_BIT_MASK(48)
-#define DMA_47BIT_MASK	DMA_BIT_MASK(47)
-#define DMA_40BIT_MASK	DMA_BIT_MASK(40)
-#define DMA_39BIT_MASK	DMA_BIT_MASK(39)
-#define DMA_35BIT_MASK	DMA_BIT_MASK(35)
-#define DMA_32BIT_MASK	DMA_BIT_MASK(32)
-#define DMA_31BIT_MASK	DMA_BIT_MASK(31)
-#define DMA_30BIT_MASK	DMA_BIT_MASK(30)
-#define DMA_29BIT_MASK	DMA_BIT_MASK(29)
-#define DMA_28BIT_MASK	DMA_BIT_MASK(28)
-#define DMA_24BIT_MASK	DMA_BIT_MASK(24)
-
 #define DMA_MASK_NONE	0x0ULL
 
 static inline int valid_dma_direction(int dma_direction)
-- 
1.6.0.6

