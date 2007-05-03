From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 3/16][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Thu, 03 May 2007 00:28:50 -0700
Message-ID: <1178177330.4909.67.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2220 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030944AbXECGls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:41:48 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add 40-bit DMA workaround for 5708.

The internal PCIE-to-PCIX bridge of the 5708 has the same 40-bit DMA
limitation as some of the tg3 chips.  Set dma_mask and persistent DMA
mask to 40-bit to workaround.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6d05397..679ee66 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5711,6 +5711,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	unsigned long mem_len;
 	int rc;
 	u32 reg;
+	u64 dma_mask, persist_dma_mask;
 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -5749,21 +5750,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_release;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_64BIT_MASK) == 0) {
-		bp->flags |= USING_DAC_FLAG;
-		if (pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) != 0) {
-			dev_err(&pdev->dev,
-				"pci_set_consistent_dma_mask failed, aborting.\n");
-			rc = -EIO;
-			goto err_out_release;
-		}
-	}
-	else if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0) {
-		dev_err(&pdev->dev, "System does not support DMA, aborting.\n");
-		rc = -EIO;
-		goto err_out_release;
-	}
-
 	bp->dev = dev;
 	bp->pdev = pdev;
 
@@ -5805,6 +5791,26 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		}
 	}
 
+	/* 5708 cannot support DMA addresses > 40-bit.  */
+	if (CHIP_NUM(bp) == CHIP_NUM_5708)
+		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
+	else
+		persist_dma_mask = dma_mask = DMA_64BIT_MASK;
+
+	/* Configure DMA attributes. */
+	if (pci_set_dma_mask(pdev, dma_mask) == 0) {
+		dev->features |= NETIF_F_HIGHDMA;
+		rc = pci_set_consistent_dma_mask(pdev, persist_dma_mask);
+		if (rc) {
+			dev_err(&pdev->dev,
+				"pci_set_consistent_dma_mask failed, aborting.\n");
+			goto err_out_unmap;
+		}
+	} else if ((rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) != 0) {
+		dev_err(&pdev->dev, "System does not support DMA, aborting.\n");
+		goto err_out_unmap;
+	}
+
 	/* Get bus information. */
 	reg = REG_RD(bp, BNX2_PCICFG_MISC_STATUS);
 	if (reg & BNX2_PCICFG_MISC_STATUS_PCIX_DET) {
@@ -6114,8 +6120,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	printk("\n");
 
 	dev->features |= NETIF_F_SG;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_IP_CSUM;
 #ifdef BCM_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 878eee5..8e7b29a 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6433,7 +6433,6 @@ struct bnx2 {
 #define PCI_32BIT_FLAG			2
 #define ONE_TDMA_FLAG			4	/* no longer used */
 #define NO_WOL_FLAG			8
-#define USING_DAC_FLAG			0x10
 #define USING_MSI_FLAG			0x20
 #define ASF_ENABLE_FLAG			0x40
 


