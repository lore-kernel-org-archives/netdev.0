From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH 2/2] net: macb: Add gmii2rgmii phy converter support
Date: Fri, 1 Jul 2016 11:50:12 +0530
Message-ID: <1467354012-7364-3-git-send-email-appanad@xilinx.com>
References: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <appanad@xilinx.com>, <michal.simek@xilinx.com>,
	<nicolas.ferre@atmel.com>, <punnaia@xilinx.com>,
	<anirudh@xilinx.com>, <harinik@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for gmii2rgmii phy converter
in the macb driver.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c |   21 ++++++++++++++++++++-
 drivers/net/ethernet/cadence/macb.h |    3 +++
 2 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index cb07d95..de0ad71 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -257,6 +257,14 @@ static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	return 0;
 }
 
+static inline void macb_hw_fix_mac_speed(struct macb *bp,
+					 struct phy_device *phydev)
+{
+	if (likely(bp->converter_phy.fix_mac_speed))
+		bp->converter_phy.fix_mac_speed(&bp->converter_phy,
+						phydev->speed);
+}
+
 /**
  * macb_set_tx_clk() - Set a clock to a new frequency
  * @clk		Pointer to the clock to change
@@ -329,6 +337,7 @@ static void macb_handle_link_change(struct net_device *dev)
 				reg |= GEM_BIT(GBE);
 
 			macb_or_gem_writel(bp, NCFGR, reg);
+			macb_hw_fix_mac_speed(bp, phydev);
 
 			bp->speed = phydev->speed;
 			bp->duplex = phydev->duplex;
@@ -2884,7 +2893,7 @@ static int macb_probe(struct platform_device *pdev)
 			struct clk **, struct clk **)
 					      = macb_clk_init;
 	int (*init)(struct platform_device *) = macb_init;
-	struct device_node *np = pdev->dev.of_node;
+	struct device_node *np = pdev->dev.of_node, *np1, *np11;
 	struct device_node *phy_node;
 	const struct macb_config *macb_config = NULL;
 	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
@@ -3011,6 +3020,16 @@ static int macb_probe(struct platform_device *pdev)
 		goto err_out_free_netdev;
 
 	phydev = bp->phy_dev;
+	np1 = of_get_next_child(np, NULL);
+	for_each_child_of_node(np1, np11) {
+		if (of_device_is_compatible(np11, "xlnx,gmiitorgmii")) {
+			bp->converter_phy.dev = dev;
+			bp->converter_phy.mii_bus = bp->mii_bus;
+			bp->converter_phy.mdio_write = macb_mdio_write;
+			bp->converter_phy.platform_data = bp->pdev->dev.of_node;
+			gmii2rgmii_phyprobe(&bp->converter_phy);
+		}
+	}
 
 	netif_carrier_off(dev);
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8a13824..735bce2 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -10,6 +10,8 @@
 #ifndef _MACB_H
 #define _MACB_H
 
+#include <linux/xilinx_gmii2rgmii.h>
+
 #define MACB_GREGS_NBR 16
 #define MACB_GREGS_VERSION 2
 #define MACB_MAX_QUEUES 8
@@ -846,6 +848,7 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+	struct	gmii2rgmii	converter_phy;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
1.7.1
