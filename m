From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 3/5] driver/net: enic: Try DMA 64 first, then failover to DMA
Date: Wed,  4 Sep 2013 11:17:16 +0530
Message-ID: <1378273638-7780-4-git-send-email-govindarajulu90@gmail.com>
References: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Cc: benve@cisco.com, ssujith@cisco.com, nistrive@cisco.com,
	umalhi@cisco.com,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In servers with more than 1.1 TB of RAM, the existing 40/32 bit DMA
could cause failure as the DMA-able address could go outside the range
addressable using 40/32 bits.

The following patch first tried 64 bit DMA if possible, failover to 32
bit.

Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 93898ba..7b756cf9 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2080,11 +2080,11 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_master(pdev);
 
 	/* Query PCI controller on system for DMA addressing
-	 * limitation for the device.  Try 40-bit first, and
+	 * limitation for the device.  Try 64-bit first, and
 	 * fail to 32-bit.
 	 */
 
-	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(40));
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err) {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
@@ -2098,10 +2098,10 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			goto err_out_release_regions;
 		}
 	} else {
-		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(40));
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err) {
 			dev_err(dev, "Unable to obtain %u-bit DMA "
-				"for consistent allocations, aborting\n", 40);
+				"for consistent allocations, aborting\n", 64);
 			goto err_out_release_regions;
 		}
 		using_dac = 1;
-- 
1.8.4
