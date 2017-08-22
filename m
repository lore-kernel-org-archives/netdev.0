From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 04/10] net: mvpp2: initialize the GMAC when using a port
Date: Tue, 22 Aug 2017 19:08:24 +0200
Message-ID: <20170822170830.32413-5-antoine.tenart@free-electrons.com>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38557 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751486AbdHVRIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:08:49 -0400
In-Reply-To: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a routine to initialize the GMAC at the port level when using
a port. This wasn't done until this commit, and the mvpp2 driver was
relying on the bootloader/firmware initialization. This doesn't mean
everything is configured in the mvpp2 driver now, but it helps reducing
the gap.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Tested-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 123 ++++++++++++++++++++++++++++-------
 1 file changed, 98 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 087eb793ab4d..2ab7366ac90f 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -315,6 +315,7 @@
 /* Per-port registers */
 #define MVPP2_GMAC_CTRL_0_REG			0x0
 #define     MVPP2_GMAC_PORT_EN_MASK		BIT(0)
+#define     MVPP2_GMAC_PORT_TYPE_MASK		BIT(1)
 #define     MVPP2_GMAC_MAX_RX_SIZE_OFFS		2
 #define     MVPP2_GMAC_MAX_RX_SIZE_MASK		0x7ffc
 #define     MVPP2_GMAC_MIB_CNTR_EN_MASK		BIT(15)
@@ -326,16 +327,21 @@
 #define     MVPP2_GMAC_SA_LOW_OFFS		7
 #define MVPP2_GMAC_CTRL_2_REG			0x8
 #define     MVPP2_GMAC_INBAND_AN_MASK		BIT(0)
+#define     MVPP2_GMAC_FLOW_CTRL_MASK		GENMASK(2, 1)
 #define     MVPP2_GMAC_PCS_ENABLE_MASK		BIT(3)
 #define     MVPP2_GMAC_PORT_RGMII_MASK		BIT(4)
+#define     MVPP2_GMAC_DISABLE_PADDING		BIT(5)
 #define     MVPP2_GMAC_PORT_RESET_MASK		BIT(6)
 #define MVPP2_GMAC_AUTONEG_CONFIG		0xc
 #define     MVPP2_GMAC_FORCE_LINK_DOWN		BIT(0)
 #define     MVPP2_GMAC_FORCE_LINK_PASS		BIT(1)
+#define     MVPP2_GMAC_IN_BAND_AUTONEG		BIT(2)
+#define     MVPP2_GMAC_IN_BAND_AUTONEG_BYPASS	BIT(3)
 #define     MVPP2_GMAC_CONFIG_MII_SPEED	BIT(5)
 #define     MVPP2_GMAC_CONFIG_GMII_SPEED	BIT(6)
 #define     MVPP2_GMAC_AN_SPEED_EN		BIT(7)
 #define     MVPP2_GMAC_FC_ADV_EN		BIT(9)
+#define     MVPP2_GMAC_FLOW_CTRL_AUTONEG	BIT(11)
 #define     MVPP2_GMAC_CONFIG_FULL_DUPLEX	BIT(12)
 #define     MVPP2_GMAC_AN_DUPLEX_EN		BIT(13)
 #define MVPP2_GMAC_PORT_FIFO_CFG_1_REG		0x1c
@@ -4245,6 +4251,92 @@ mvpp2_shared_interrupt_mask_unmask(struct mvpp2_port *port, bool mask)
 
 /* Port configuration routines */
 
+static void mvpp2_port_mii_gmac_configure_mode(struct mvpp2_port *port)
+{
+	u32 val;
+
+	if (port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
+		val = readl(port->base + MVPP22_GMAC_CTRL_4_REG);
+		val |= MVPP22_CTRL4_SYNC_BYPASS_DIS | MVPP22_CTRL4_DP_CLK_SEL |
+		       MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE;
+		val &= ~MVPP22_CTRL4_EXT_PIN_GMII_SEL;
+		writel(val, port->base + MVPP22_GMAC_CTRL_4_REG);
+
+		val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
+		val |= MVPP2_GMAC_DISABLE_PADDING;
+		val &= ~MVPP2_GMAC_FLOW_CTRL_MASK;
+		writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
+	} else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
+		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
+		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
+		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+		val = readl(port->base + MVPP22_GMAC_CTRL_4_REG);
+		val |= MVPP22_CTRL4_EXT_PIN_GMII_SEL |
+		       MVPP22_CTRL4_SYNC_BYPASS_DIS |
+		       MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE;
+		val &= ~MVPP22_CTRL4_DP_CLK_SEL;
+		writel(val, port->base + MVPP22_GMAC_CTRL_4_REG);
+
+		val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
+		val &= ~MVPP2_GMAC_DISABLE_PADDING;
+		writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
+	}
+
+	/* The port is connected to a copper PHY */
+	val = readl(port->base + MVPP2_GMAC_CTRL_0_REG);
+	val &= ~MVPP2_GMAC_PORT_TYPE_MASK;
+	writel(val, port->base + MVPP2_GMAC_CTRL_0_REG);
+
+	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+	val |= MVPP2_GMAC_IN_BAND_AUTONEG_BYPASS |
+	       MVPP2_GMAC_AN_SPEED_EN | MVPP2_GMAC_FLOW_CTRL_AUTONEG |
+	       MVPP2_GMAC_AN_DUPLEX_EN;
+	if (port->phy_interface == PHY_INTERFACE_MODE_SGMII)
+		val |= MVPP2_GMAC_IN_BAND_AUTONEG;
+	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+}
+
+static void mvpp2_port_mii_gmac_configure(struct mvpp2_port *port)
+{
+	u32 val;
+
+	/* Force link down */
+	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+	val &= ~MVPP2_GMAC_FORCE_LINK_PASS;
+	val |= MVPP2_GMAC_FORCE_LINK_DOWN;
+	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+
+	/* Set the GMAC in a reset state */
+	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
+	val |= MVPP2_GMAC_PORT_RESET_MASK;
+	writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
+
+	/* Configure the PCS and in-band AN */
+	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
+	if (port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
+	        val |= MVPP2_GMAC_INBAND_AN_MASK | MVPP2_GMAC_PCS_ENABLE_MASK;
+	} else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
+		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
+		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
+		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+		val &= ~MVPP2_GMAC_PCS_ENABLE_MASK;
+		val |= MVPP2_GMAC_PORT_RGMII_MASK;
+	}
+	writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
+
+	mvpp2_port_mii_gmac_configure_mode(port);
+
+	/* Unset the GMAC reset state */
+	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
+	val &= ~MVPP2_GMAC_PORT_RESET_MASK;
+	writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
+
+	/* Stop forcing link down */
+	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+	val &= ~MVPP2_GMAC_FORCE_LINK_DOWN;
+	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+}
+
 static void mvpp22_port_mii_set(struct mvpp2_port *port)
 {
 	u32 val;
@@ -4262,38 +4354,19 @@ static void mvpp22_port_mii_set(struct mvpp2_port *port)
 
 		writel(val, port->base + MVPP22_XLG_CTRL3_REG);
 	}
-
-	val = readl(port->base + MVPP22_GMAC_CTRL_4_REG);
-	if (port->phy_interface == PHY_INTERFACE_MODE_RGMII)
-		val |= MVPP22_CTRL4_EXT_PIN_GMII_SEL;
-	else
-		val &= ~MVPP22_CTRL4_EXT_PIN_GMII_SEL;
-	val &= ~MVPP22_CTRL4_DP_CLK_SEL;
-	val |= MVPP22_CTRL4_SYNC_BYPASS_DIS;
-	val |= MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE;
-	writel(val, port->base + MVPP22_GMAC_CTRL_4_REG);
 }
 
 static void mvpp2_port_mii_set(struct mvpp2_port *port)
 {
-	u32 val;
-
 	if (port->priv->hw_version == MVPP22)
 		mvpp22_port_mii_set(port);
 
-	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
-
-	switch (port->phy_interface) {
-	case PHY_INTERFACE_MODE_SGMII:
-		val |= MVPP2_GMAC_INBAND_AN_MASK;
-		break;
-	case PHY_INTERFACE_MODE_RGMII:
-		val |= MVPP2_GMAC_PORT_RGMII_MASK;
-	default:
-		val &= ~MVPP2_GMAC_PCS_ENABLE_MASK;
-	}
-
-	writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
+	if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
+	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
+	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
+	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID ||
+	    port->phy_interface == PHY_INTERFACE_MODE_SGMII)
+		mvpp2_port_mii_gmac_configure(port);
 }
 
 static void mvpp2_port_fc_adv_enable(struct mvpp2_port *port)
-- 
2.13.5
