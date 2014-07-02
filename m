From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 5/5] amd-xgbe: Base AXI DMA cache settings on device
 tree
Date: Wed, 2 Jul 2014 13:04:57 -0500
Message-ID: <20140702180457.14996.40621.stgit@tlendack-t1.amdoffice.net>
References: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0188.outbound.protection.outlook.com ([207.46.163.188]:7702
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757396AbaGBSFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 14:05:05 -0400
In-Reply-To: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default cache operations for ARM64 were changed during 3.15.
To use coherent operations a "dma-coherent" device tree property
is required.  If that property is not present in the device tree
node then the non-coherent operations are assigned for the device.

Add support to the amd-xgbe driver to assign the AXI DMA cache settings
based on whether the "dma-coherent" property is present in the device
node.  If present, use settings that work with the caches.  If not
present, use settings that do not look at the caches.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |   28 ++++++++++++++--------------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |   10 ++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h      |   17 +++++++++++++----
 3 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index d6a45ce..699cff5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1455,23 +1455,23 @@ static void xgbe_config_dma_cache(struct xgbe_prv_data *pdata)
 	unsigned int arcache, awcache;
 
 	arcache = 0;
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRC, XGBE_DMA_ARCACHE);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRD, XGBE_DMA_ARDOMAIN);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TEC, XGBE_DMA_ARCACHE);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TED, XGBE_DMA_ARDOMAIN);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THC, XGBE_DMA_ARCACHE);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THD, XGBE_DMA_ARDOMAIN);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRC, pdata->arcache);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRD, pdata->axdomain);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TEC, pdata->arcache);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TED, pdata->axdomain);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THC, pdata->arcache);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THD, pdata->axdomain);
 	XGMAC_IOWRITE(pdata, DMA_AXIARCR, arcache);
 
 	awcache = 0;
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWC, XGBE_DMA_AWCACHE);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWD, XGBE_DMA_AWDOMAIN);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPC, XGBE_DMA_AWCACHE);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPD, XGBE_DMA_AWDOMAIN);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHC, XGBE_DMA_AWCACHE);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHD, XGBE_DMA_AWDOMAIN);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDC, XGBE_DMA_AWCACHE);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDD, XGBE_DMA_AWDOMAIN);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWC, pdata->awcache);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWD, pdata->axdomain);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPC, pdata->awcache);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPD, pdata->axdomain);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHC, pdata->awcache);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHD, pdata->axdomain);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDC, pdata->awcache);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDD, pdata->axdomain);
 	XGMAC_IOWRITE(pdata, DMA_AXIAWCR, awcache);
 }
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index b411ac5..d5a4f76 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -297,6 +297,16 @@ static int xgbe_probe(struct platform_device *pdev)
 	*(dev->dma_mask) = DMA_BIT_MASK(40);
 	dev->coherent_dma_mask = DMA_BIT_MASK(40);
 
+	if (of_property_read_bool(dev->of_node, "dma-coherent")) {
+		pdata->axdomain = XGBE_DMA_OS_AXDOMAIN;
+		pdata->arcache = XGBE_DMA_OS_ARCACHE;
+		pdata->awcache = XGBE_DMA_OS_AWCACHE;
+	} else {
+		pdata->axdomain = XGBE_DMA_SYS_AXDOMAIN;
+		pdata->arcache = XGBE_DMA_SYS_ARCACHE;
+		pdata->awcache = XGBE_DMA_SYS_AWCACHE;
+	}
+
 	ret = platform_get_irq(pdev, 0);
 	if (ret < 0) {
 		dev_err(dev, "platform_get_irq failed\n");
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index eef8ea1..9e24b29 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -143,10 +143,14 @@
 #define XGBE_MAX_DMA_CHANNELS	16
 
 /* DMA cache settings - Outer sharable, write-back, write-allocate */
-#define XGBE_DMA_ARDOMAIN	0x2
-#define XGBE_DMA_ARCACHE	0xb
-#define XGBE_DMA_AWDOMAIN	0x2
-#define XGBE_DMA_AWCACHE	0xf
+#define XGBE_DMA_OS_AXDOMAIN	0x2
+#define XGBE_DMA_OS_ARCACHE	0xb
+#define XGBE_DMA_OS_AWCACHE	0xf
+
+/* DMA cache settings - System, no caches used */
+#define XGBE_DMA_SYS_AXDOMAIN	0x3
+#define XGBE_DMA_SYS_ARCACHE	0x0
+#define XGBE_DMA_SYS_AWCACHE	0x0
 
 #define XGBE_DMA_INTERRUPT_MASK	0x31c7
 
@@ -536,6 +540,11 @@ struct xgbe_prv_data {
 	struct xgbe_hw_if hw_if;
 	struct xgbe_desc_if desc_if;
 
+	/* AXI DMA settings */
+	unsigned int axdomain;
+	unsigned int arcache;
+	unsigned int awcache;
+
 	/* Rings for Tx/Rx on a DMA channel */
 	struct xgbe_channel *channel;
 	unsigned int channel_count;
