From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH v2 4/4] net: macb: Add gmii2rgmii phy converter support
Date: Mon, 4 Jul 2016 14:34:44 +0530
Message-ID: <1467623084-15471-5-git-send-email-appanad@xilinx.com>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<punnaia@xilinx.com>, <nicolas.ferre@atmel.com>,
	<f.fainelli@gmail.com>, <andrew@lunn.ch>, <anirudh@xilinx.com>,
	<harinik@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for gmii2rgmii phy converter in the macb driver.

The GMII to RGMII IP core provides the Reduced Gigabit Media
Independent Interface (RGMII) between Ethernet physical media
Devices and the Gigabit Ethernet controller. This core can
Switch dynamically between the three different speed modes of
Operation by configuring the converter register through mdio write.

MDIO interface is used to set operating speed of Ethernet MAC.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v2:
---> Moved header file define xilinx_gmii2rgmii.h to macb.c file
as suggested by the Nicolas.
---> Updated the commit meassage as suggested by the Nicolas.
---> Fixed minor coding comments as suggested by the Nicolas.

 drivers/net/ethernet/cadence/macb.c | 21 +++++++++++++++++++++
 drivers/net/ethernet/cadence/macb.h |  1 +
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index cb07d95..b900eb4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -32,6 +32,7 @@
 #include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
+#include <linux/xilinx_gmii2rgmii.h>
 
 #include "macb.h"
 
@@ -257,6 +258,14 @@ static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	return 0;
 }
 
+static inline void macb_hw_fix_mac_speed(struct macb *bp,
+					 struct phy_device *phydev)
+{
+	if (bp->converter_phy.fix_mac_speed)
+		bp->converter_phy.fix_mac_speed(&bp->converter_phy,
+						phydev->speed);
+}
+
 /**
  * macb_set_tx_clk() - Set a clock to a new frequency
  * @clk		Pointer to the clock to change
@@ -329,6 +338,7 @@ static void macb_handle_link_change(struct net_device *dev)
 				reg |= GEM_BIT(GBE);
 
 			macb_or_gem_writel(bp, NCFGR, reg);
+			macb_hw_fix_mac_speed(bp, phydev);
 
 			bp->speed = phydev->speed;
 			bp->duplex = phydev->duplex;
@@ -2886,6 +2896,7 @@ static int macb_probe(struct platform_device *pdev)
 	int (*init)(struct platform_device *) = macb_init;
 	struct device_node *np = pdev->dev.of_node;
 	struct device_node *phy_node;
+	struct device_node *child_node, *np1;
 	const struct macb_config *macb_config = NULL;
 	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
 	unsigned int queue_mask, num_queues;
@@ -3011,6 +3022,16 @@ static int macb_probe(struct platform_device *pdev)
 		goto err_out_free_netdev;
 
 	phydev = bp->phy_dev;
+	child_node = of_get_next_child(np, NULL);
+	for_each_child_of_node(child_node, np1) {
+		if (of_device_is_compatible(np1, "xlnx,gmiitorgmii")) {
+			bp->converter_phy.dev = dev;
+			bp->converter_phy.mii_bus = bp->mii_bus;
+			bp->converter_phy.mdio_write = macb_mdio_write;
+			bp->converter_phy.platform_data = bp->pdev->dev.of_node;
+			gmii2rgmii_phyprobe(&bp->converter_phy);
+		}
+	}
 
 	netif_carrier_off(dev);
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8a13824..414005c 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -846,6 +846,7 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+	struct	gmii2rgmii	converter_phy;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
2.1.2
