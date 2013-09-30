From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 3/3] net: calxedaxgmac: determine number of address filters at runtime
Date: Mon, 30 Sep 2013 15:12:17 -0500
Message-ID: <1380571937-23439-4-git-send-email-robherring2@gmail.com>
References: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Cc: Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Highbank and Midway xgmac h/w have different number of MAC address filter
registers with 7 and 31, respectively. Highbank has been wrong, so fix it
and detect the number of filter registers at run-time. Unfortunately,
the version register is the same on both SOCs, so simply test if write to
the last filter register will take a value. It always reads as 0 if not.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 35da09b..48f5288 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -106,7 +106,6 @@
 #define XGMAC_DMA_HW_FEATURE	0x00000f58	/* Enabled Hardware Features */
 
 #define XGMAC_ADDR_AE		0x80000000
-#define XGMAC_MAX_FILTER_ADDR	31
 
 /* PMT Control and Status */
 #define XGMAC_PMT_POINTER_RESET	0x80000000
@@ -384,6 +383,7 @@ struct xgmac_priv {
 	struct device *device;
 	struct napi_struct napi;
 
+	int max_macs;
 	struct xgmac_extra_stats xstats;
 
 	spinlock_t stats_lock;
@@ -1296,7 +1296,7 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 
 	memset(hash_filter, 0, sizeof(hash_filter));
 
-	if (netdev_uc_count(dev) > XGMAC_MAX_FILTER_ADDR) {
+	if (netdev_uc_count(dev) > priv->max_macs) {
 		use_hash = true;
 		value |= XGMAC_FRAME_FILTER_HUC | XGMAC_FRAME_FILTER_HPF;
 	}
@@ -1319,7 +1319,7 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 		goto out;
 	}
 
-	if ((netdev_mc_count(dev) + reg - 1) > XGMAC_MAX_FILTER_ADDR) {
+	if ((netdev_mc_count(dev) + reg - 1) > priv->max_macs) {
 		use_hash = true;
 		value |= XGMAC_FRAME_FILTER_HMC | XGMAC_FRAME_FILTER_HPF;
 	} else {
@@ -1340,7 +1340,7 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	}
 
 out:
-	for (i = reg; i <= XGMAC_MAX_FILTER_ADDR; i++)
+	for (i = reg; i <= priv->max_macs; i++)
 		xgmac_set_mac_addr(ioaddr, NULL, i);
 	for (i = 0; i < XGMAC_NUM_HASH; i++)
 		writel(hash_filter[i], ioaddr + XGMAC_HASH(i));
@@ -1759,6 +1759,13 @@ static int xgmac_probe(struct platform_device *pdev)
 	uid = readl(priv->base + XGMAC_VERSION);
 	netdev_info(ndev, "h/w version is 0x%x\n", uid);
 
+	/* Figure out how many valid mac address filter registers we have */
+	writel(1, priv->base + XGMAC_ADDR_HIGH(31));
+	if (readl(priv->base + XGMAC_ADDR_HIGH(31)) == 1)
+		priv->max_macs = 31;
+	else
+		priv->max_macs = 7;
+
 	writel(0, priv->base + XGMAC_DMA_INTR_ENA);
 	ndev->irq = platform_get_irq(pdev, 0);
 	if (ndev->irq == -ENXIO) {
-- 
1.8.1.2
