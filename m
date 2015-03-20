From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v3 6/9] amd-xgbe: Set DMA mask based on hardware
 register value
Date: Fri, 20 Mar 2015 11:50:22 -0500
Message-ID: <20150320165022.13799.61146.stgit@tlendack-t1.amdoffice.net>
References: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0146.outbound.protection.outlook.com ([157.56.110.146]:45888
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752036AbbCTQua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 12:50:30 -0400
In-Reply-To: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware supplies a value that indicates the DMA range that it
is capable of using. Use this value rather than hard-coding it in
the driver.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    2 ++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |   16 ++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c   |   19 ++++++++++---------
 drivers/net/ethernet/amd/xgbe/xgbe.h        |    1 +
 4 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 29a0927..34c28aa 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -365,6 +365,8 @@
 #define MAC_HWF0R_TXCOESEL_WIDTH	1
 #define MAC_HWF0R_VLHASH_INDEX		4
 #define MAC_HWF0R_VLHASH_WIDTH		1
+#define MAC_HWF1R_ADDR64_INDEX		14
+#define MAC_HWF1R_ADDR64_WIDTH		2
 #define MAC_HWF1R_ADVTHWORD_INDEX	13
 #define MAC_HWF1R_ADVTHWORD_WIDTH	1
 #define MAC_HWF1R_DBGMEMA_INDEX		19
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 8635c94..ef4625e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -519,6 +519,7 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 						RXFIFOSIZE);
 	hw_feat->tx_fifo_size  = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
 						TXFIFOSIZE);
+	hw_feat->dma_width     = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, ADDR64);
 	hw_feat->dcb           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, DCBEN);
 	hw_feat->sph           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, SPHEN);
 	hw_feat->tso           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, TSOEN);
@@ -553,6 +554,21 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 		break;
 	}
 
+	/* Translate the address width setting into actual number */
+	switch (hw_feat->dma_width) {
+	case 0:
+		hw_feat->dma_width = 32;
+		break;
+	case 1:
+		hw_feat->dma_width = 40;
+		break;
+	case 2:
+		hw_feat->dma_width = 48;
+		break;
+	default:
+		hw_feat->dma_width = 32;
+	}
+
 	/* The Queue, Channel and TC counts are zero based so increment them
 	 * to get the actual number
 	 */
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 32dd651..2e4c22d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -374,15 +374,6 @@ static int xgbe_probe(struct platform_device *pdev)
 		pdata->awcache = XGBE_DMA_SYS_AWCACHE;
 	}
 
-	/* Set the DMA mask */
-	if (!dev->dma_mask)
-		dev->dma_mask = &dev->coherent_dma_mask;
-	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(40));
-	if (ret) {
-		dev_err(dev, "dma_set_mask_and_coherent failed\n");
-		goto err_io;
-	}
-
 	/* Get the device interrupt */
 	ret = platform_get_irq(pdev, 0);
 	if (ret < 0) {
@@ -409,6 +400,16 @@ static int xgbe_probe(struct platform_device *pdev)
 	/* Set default configuration data */
 	xgbe_default_config(pdata);
 
+	/* Set the DMA mask */
+	if (!dev->dma_mask)
+		dev->dma_mask = &dev->coherent_dma_mask;
+	ret = dma_set_mask_and_coherent(dev,
+					DMA_BIT_MASK(pdata->hw_feat.dma_width));
+	if (ret) {
+		dev_err(dev, "dma_set_mask_and_coherent failed\n");
+		goto err_io;
+	}
+
 	/* Calculate the number of Tx and Rx rings to be created
 	 *  -Tx (DMA) Channels map 1-to-1 to Tx Queues so set
 	 *   the number of Tx queues to the number of Tx channels
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 1eea3e5..bfe11fb 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -632,6 +632,7 @@ struct xgbe_hw_features {
 	unsigned int rx_fifo_size;	/* MTL Receive FIFO Size */
 	unsigned int tx_fifo_size;	/* MTL Transmit FIFO Size */
 	unsigned int adv_ts_hi;		/* Advance Timestamping High Word */
+	unsigned int dma_width;		/* DMA width */
 	unsigned int dcb;		/* DCB Feature */
 	unsigned int sph;		/* Split Header Feature */
 	unsigned int tso;		/* TCP Segmentation Offload */
