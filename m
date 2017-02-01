From: Lukasz Majewski <lukma@denx.de>
Subject: [PATCH] net: phy: dp83867: Port mirroring support in the DP83867 TI's PHY driver
Date: Wed,  1 Feb 2017 15:43:35 +0100
Message-ID: <1485960215-5148-1-git-send-email-lukma@denx.de>
Cc: devicetree@vger.kernel.org, Lukasz Majewski <lukma@denx.de>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for enabling or disabling the port mirroring
feature of the DP83867 TI's PHY device.

One use case is when bootstrap configuration enables this feature (because
of e.g. LED wiring) so then one needs to disable it in software
(u-boot/Linux).

Signed-off-by: Lukasz Majewski <lukma@denx.de>
---
 .../devicetree/bindings/net/ti,dp83867.txt         |  4 +++
 drivers/net/phy/dp83867.c                          | 40 ++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
index afe9630..d1be241 100644
--- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
+++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
@@ -18,6 +18,10 @@ Optional property:
 	- ti,max-output-impedance - MAC Interface Impedance control to set
 				    the programmable output impedance to
 				    maximum value (70 ohms).
+	- ti,port-mirroring - Set port mirroring. It is possible to overwrite -
+			      enable (by setting <1>) or disable
+			      (by setting <0>) the port mirroring feature set
+			      by bootstrap initial reading.
 
 Note: ti,min-output-impedance and ti,max-output-impedance are mutually
       exclusive. When both properties are present ti,max-output-impedance
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index ca1b462..98948bd 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -32,6 +32,7 @@
 #define DP83867_CFG3		0x1e
 
 /* Extended Registers */
+#define DP83867_CFG4            0x0031
 #define DP83867_RGMIICTL	0x0032
 #define DP83867_RGMIIDCTL	0x0086
 #define DP83867_IO_MUX_CFG	0x0170
@@ -70,11 +71,20 @@
 #define DP83867_IO_MUX_CFG_IO_IMPEDANCE_MAX	0x0
 #define DP83867_IO_MUX_CFG_IO_IMPEDANCE_MIN	0x1f
 
+/* CFG4 bits */
+#define DP83867_CFG4_PORT_MIRROR_EN              BIT(0)
+
+enum {
+	DP83867_PORT_MIRROING_EN = 1,
+	DP83867_PORT_MIRROING_DIS,
+};
+
 struct dp83867_private {
 	int rx_id_delay;
 	int tx_id_delay;
 	int fifo_depth;
 	int io_impedance;
+	int port_mirroring;
 };
 
 static int dp83867_ack_interrupt(struct phy_device *phydev)
@@ -111,6 +121,24 @@ static int dp83867_config_intr(struct phy_device *phydev)
 	return phy_write(phydev, MII_DP83867_MICR, micr_status);
 }
 
+static int dp83867_config_port_mirroring(struct phy_device *phydev)
+{
+	struct dp83867_private *dp83867 =
+		(struct dp83867_private *)phydev->priv;
+	u16 val;
+
+	val = phy_read_mmd_indirect(phydev, DP83867_CFG4, DP83867_DEVADDR);
+
+	if (dp83867->port_mirroring == DP83867_PORT_MIRROING_EN)
+		val |= DP83867_CFG4_PORT_MIRROR_EN;
+	else
+		val &= ~DP83867_CFG4_PORT_MIRROR_EN;
+
+	phy_write_mmd_indirect(phydev, DP83867_CFG4, DP83867_DEVADDR, val);
+
+	return 0;
+}
+
 #ifdef CONFIG_OF_MDIO
 static int dp83867_of_init(struct phy_device *phydev)
 {
@@ -118,6 +146,7 @@ static int dp83867_of_init(struct phy_device *phydev)
 	struct device *dev = &phydev->mdio.dev;
 	struct device_node *of_node = dev->of_node;
 	int ret;
+	u32 v;
 
 	if (!of_node)
 		return -ENODEV;
@@ -144,6 +173,14 @@ static int dp83867_of_init(struct phy_device *phydev)
 	     phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID))
 		return ret;
 
+	ret = of_property_read_u32(of_node, "ti,port-mirroring", &v);
+	if (!ret) {
+		if (v)
+			dp83867->port_mirroring = DP83867_PORT_MIRROING_EN;
+		else
+			dp83867->port_mirroring = DP83867_PORT_MIRROING_DIS;
+	}
+
 	return of_property_read_u32(of_node, "ti,fifo-depth",
 				   &dp83867->fifo_depth);
 }
@@ -228,6 +265,9 @@ static int dp83867_config_init(struct phy_device *phydev)
 		phy_write(phydev, DP83867_CFG3, val);
 	}
 
+	if (dp83867->port_mirroring)
+		dp83867_config_port_mirroring(phydev);
+
 	return 0;
 }
 
-- 
2.1.4
