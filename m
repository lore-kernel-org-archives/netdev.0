From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: [PATCH v3] net: axienet: add support for standard phy-mode binding
Date: Mon, 17 Jul 2017 09:12:28 +0200
Message-ID: <20170717071228.22585-1-alvaro.gamez@hazent.com>
Cc: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keep supporting proprietary "xlnx,phy-type" attribute and add support for
MII connectivity to the PHY.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
---

Changes from v2:
  * Replaced u32 phy_mode -> phy_interface_t phy_mode
  * Fix bug we introduced PHY_INTERFACE_MODE_RGMII -> PHY_INTERFACE_MODE_RGMII_ID


 .../devicetree/bindings/net/xilinx_axienet.txt     | 55 ++++++++++++++++++++++
 drivers/net/ethernet/xilinx/xilinx_axienet.h       |  4 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  | 48 ++++++++++++++-----
 3 files changed, 93 insertions(+), 14 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/xilinx_axienet.txt

diff --git a/Documentation/devicetree/bindings/net/xilinx_axienet.txt b/Documentation/devicetree/bindings/net/xilinx_axienet.txt
new file mode 100644
index 000000000000..38f9ec076743
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/xilinx_axienet.txt
@@ -0,0 +1,55 @@
+XILINX AXI ETHERNET Device Tree Bindings
+--------------------------------------------------------
+
+Also called  AXI 1G/2.5G Ethernet Subsystem, the xilinx axi ethernet IP core
+provides connectivity to an external ethernet PHY supporting different
+interfaces: MII, GMII, RGMII, SGMII, 1000BaseX. It also includes two
+segments of memory for buffering TX and RX, as well as the capability of
+offloading TX/RX checksum calculation off the processor.
+
+Management configuration is done through the AXI interface, while payload is
+sent and received through means of an AXI DMA controller. This driver
+includes the DMA driver code, so this driver is incompatible with AXI DMA
+driver.
+
+For more details about mdio please refer phy.txt file in the same directory.
+
+Required properties:
+- compatible	: Must be one of "xlnx,axi-ethernet-1.00.a",
+		  "xlnx,axi-ethernet-1.01.a", "xlnx,axi-ethernet-2.01.a"
+- reg		: Address and length of the IO space.
+- interrupts	: Should be a list of two interrupt, TX and RX.
+- phy-handle	: Should point to the external phy device.
+		  See ethernet.txt file in the same directory.
+- xlnx,rxmem	: Set to allocated memory buffer for Rx/Tx in the hardware
+
+Optional properties:
+- phy-mode	: See ethernet.txt
+- xlnx,phy-type	: Deprecated, do not use, but still accepted in preference
+		  to phy-mode.
+- xlnx,txcsum	: 0 or empty for disabling TX checksum offload,
+		  1 to enable partial TX checksum offload,
+		  2 to enable full TX checksum offload
+- xlnx,rxcsum	: Same values as xlnx,txcsum but for RX checksum offload
+
+Example:
+	axi_ethernet_eth: ethernet@40c00000 {
+		compatible = "xlnx,axi-ethernet-1.00.a";
+		device_type = "network";
+		interrupt-parent = <&microblaze_0_axi_intc>;
+		interrupts = <2 0>;
+		phy-mode = "mii";
+		reg = <0x40c00000 0x40000>;
+		xlnx,rxcsum = <0x2>;
+		xlnx,rxmem = <0x800>;
+		xlnx,txcsum = <0x2>;
+		phy-handle = <&phy0>;
+		axi_ethernetlite_0_mdio: mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			phy0: phy@0 {
+				device_type = "ethernet-phy";
+				reg = <1>;
+			};
+		};
+	};
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
index af27f7d1cbf3..5ef626331f85 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -389,7 +389,7 @@ struct axidma_bd {
  * @dma_err_tasklet: Tasklet structure to process Axi DMA errors
  * @tx_irq:	Axidma TX IRQ number
  * @rx_irq:	Axidma RX IRQ number
- * @phy_type:	Phy type to identify between MII/GMII/RGMII/SGMII/1000 Base-X
+ * @phy_mode:	Phy type to identify between MII/GMII/RGMII/SGMII/1000 Base-X
  * @options:	AxiEthernet option word
  * @last_link:	Phy link state in which the PHY was negotiated earlier
  * @features:	Stores the extended features supported by the axienet hw
@@ -432,7 +432,7 @@ struct axienet_local {
 
 	int tx_irq;
 	int rx_irq;
-	u32 phy_type;
+	phy_interface_t phy_mode;
 
 	u32 options;			/* Current options word */
 	u32 last_link;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 33c595f4691d..e74e1e897864 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -531,11 +531,11 @@ static void axienet_adjust_link(struct net_device *ndev)
 	link_state = phy->speed | (phy->duplex << 1) | phy->link;
 	if (lp->last_link != link_state) {
 		if ((phy->speed == SPEED_10) || (phy->speed == SPEED_100)) {
-			if (lp->phy_type == XAE_PHY_TYPE_1000BASE_X)
+			if (lp->phy_mode == PHY_INTERFACE_MODE_1000BASEX)
 				setspeed = 0;
 		} else {
 			if ((phy->speed == SPEED_1000) &&
-			    (lp->phy_type == XAE_PHY_TYPE_MII))
+			    (lp->phy_mode == PHY_INTERFACE_MODE_MII))
 				setspeed = 0;
 		}
 
@@ -935,15 +935,8 @@ static int axienet_open(struct net_device *ndev)
 		return ret;
 
 	if (lp->phy_node) {
-		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
-			phydev = of_phy_connect(lp->ndev, lp->phy_node,
-						axienet_adjust_link, 0,
-						PHY_INTERFACE_MODE_GMII);
-		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
-			phydev = of_phy_connect(lp->ndev, lp->phy_node,
-						axienet_adjust_link, 0,
-						PHY_INTERFACE_MODE_RGMII_ID);
-		}
+		phydev = of_phy_connect(lp->ndev, lp->phy_node,
+					axienet_adjust_link, 0, lp->phy_mode);
 
 		if (!phydev)
 			dev_err(lp->dev, "of_phy_connect() failed\n");
@@ -1539,7 +1532,38 @@ static int axienet_probe(struct platform_device *pdev)
 	 * the device-tree and accordingly set flags.
 	 */
 	of_property_read_u32(pdev->dev.of_node, "xlnx,rxmem", &lp->rxmem);
-	of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type);
+
+	/* Start with the proprietary, and broken phy_type */
+	ret = of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &value);
+	if (!ret) {
+		netdev_warn(ndev, "Please upgrade your device tree binary blob to use phy-mode");
+		switch (value) {
+		case XAE_PHY_TYPE_MII:
+			lp->phy_mode = PHY_INTERFACE_MODE_MII;
+			break;
+		case XAE_PHY_TYPE_GMII:
+			lp->phy_mode = PHY_INTERFACE_MODE_GMII;
+			break;
+		case XAE_PHY_TYPE_RGMII_2_0:
+			lp->phy_mode = PHY_INTERFACE_MODE_RGMII_ID;
+			break;
+		case XAE_PHY_TYPE_SGMII:
+			lp->phy_mode = PHY_INTERFACE_MODE_SGMII;
+			break;
+		case XAE_PHY_TYPE_1000BASE_X:
+			lp->phy_mode = PHY_INTERFACE_MODE_1000BASEX;
+			break;
+		default:
+			ret = -EINVAL;
+			goto free_netdev;
+		}
+	} else {
+		lp->phy_mode = of_get_phy_mode(pdev->dev.of_node);
+		if (lp->phy_mode < 0) {
+			ret = -EINVAL;
+			goto free_netdev;
+		}
+	}
 
 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
 	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
-- 
2.11.0
