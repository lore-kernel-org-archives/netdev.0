From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: sxgbe: sw reset moved to probe function
Date: Tue, 29 Apr 2014 13:15:15 +0900
Message-ID: <001b01cf6361$9f4b6650$dde232f0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, vipul.pandya@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch moves sw reset to probe function because
sw reset is needed early stage before open function.

Signed-off-by: Byungho An <bh74.an@samsung.net>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c  |   13 -------------
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |   22 ++++++++++++++++++++++
 2 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
index 4d989ff..bb9b5b8 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
@@ -23,21 +23,8 @@
 /* DMA core initialization */
 static int sxgbe_dma_init(void __iomem *ioaddr, int fix_burst, int burst_map)
 {
-	int retry_count = 10;
 	u32 reg_val;
 
-	/* reset the DMA */
-	writel(SXGBE_DMA_SOFT_RESET, ioaddr + SXGBE_DMA_MODE_REG);
-	while (retry_count--) {
-		if (!(readl(ioaddr + SXGBE_DMA_MODE_REG) &
-		      SXGBE_DMA_SOFT_RESET))
-			break;
-		mdelay(10);
-	}
-
-	if (retry_count < 0)
-		return -EBUSY;
-
 	reg_val = readl(ioaddr + SXGBE_DMA_SYSBUS_MODE_REG);
 
 	/* if fix_burst = 0, Set UNDEF = 1 of DMA_Sys_Mode Register.
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 27e8c82..6ad7b3a 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -2070,6 +2070,24 @@ static int sxgbe_hw_init(struct sxgbe_priv_data * const priv)
 	return 0;
 }
 
+static int sxgbe_sw_reset(void __iomem *addr)
+{
+	int retry_count = 10;
+
+	writel(SXGBE_DMA_SOFT_RESET, addr + SXGBE_DMA_MODE_REG);
+	while (retry_count--) {
+		if (!(readl(addr + SXGBE_DMA_MODE_REG) &
+		      SXGBE_DMA_SOFT_RESET))
+			break;
+		mdelay(10);
+	}
+
+	if (retry_count < 0)
+		return -EBUSY;
+
+	return 0;
+}
+
 /**
  * sxgbe_drv_probe
  * @device: device pointer
@@ -2102,6 +2120,10 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	priv->plat = plat_dat;
 	priv->ioaddr = addr;
 
+	ret = sxgbe_sw_reset(priv->ioaddr);
+	if (ret)
+		goto error_free_netdev;
+
 	/* Verify driver arguments */
 	sxgbe_verify_args();
 
-- 
1.7.10.4
