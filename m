From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next] net: mvpp2: enable basic 10G support
Date: Mon, 12 Jun 2017 16:01:39 +0200
Message-ID: <20170612140139.31377-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        stefanc@marvell.com, mw@semihalf.com, linux@armlinux.org.uk,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:50522 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751954AbdFLOCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 10:02:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On GOP port 0 two MAC modes are available: GMAC and XLG. The XLG MAC is
used for 10G connectivity. This patch adds a basic 10G support by
allowing to use the XLG MAC on port 0 and by reworking the
port_enable/disable functions so that the XLG MAC is configured when
using 10G.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 49 ++++++++++++++++++++++++++++++------
 1 file changed, 41 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 33c901622ed5..ca4b55c60682 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -345,9 +345,15 @@
 /* Per-port XGMAC registers. PPv2.2 only, only for GOP port 0,
  * relative to port->base.
  */
+#define MVPP22_XLG_CTRL0_REG			0x100
+#define      MVPP22_XLG_CTRL0_PORT_EN		BIT(0)
+#define      MVPP22_XLG_CTRL0_MAC_RESET_DIS	BIT(1)
+#define      MVPP22_XLG_CTRL0_MIB_CNT_DIS	BIT(14)
+
 #define MVPP22_XLG_CTRL3_REG			0x11c
 #define      MVPP22_XLG_CTRL3_MACMODESELECT_MASK	(7 << 13)
 #define      MVPP22_XLG_CTRL3_MACMODESELECT_GMAC	(0 << 13)
+#define      MVPP22_XLG_CTRL3_MACMODESELECT_10G		(1 << 13)
 
 /* SMI registers. PPv2.2 only, relative to priv->iface_base. */
 #define MVPP22_SMI_MISC_CFG_REG			0x1204
@@ -4186,7 +4192,13 @@ static void mvpp22_port_mii_set(struct mvpp2_port *port)
 	if (port->gop_id == 0) {
 		val = readl(port->base + MVPP22_XLG_CTRL3_REG);
 		val &= ~MVPP22_XLG_CTRL3_MACMODESELECT_MASK;
-		val |= MVPP22_XLG_CTRL3_MACMODESELECT_GMAC;
+
+		if (port->phy_interface == PHY_INTERFACE_MODE_XAUI ||
+		    port->phy_interface == PHY_INTERFACE_MODE_10GKR)
+			val |= MVPP22_XLG_CTRL3_MACMODESELECT_10G;
+		else
+			val |= MVPP22_XLG_CTRL3_MACMODESELECT_GMAC;
+
 		writel(val, port->base + MVPP22_XLG_CTRL3_REG);
 	}
 
@@ -4236,19 +4248,40 @@ static void mvpp2_port_enable(struct mvpp2_port *port)
 {
 	u32 val;
 
-	val = readl(port->base + MVPP2_GMAC_CTRL_0_REG);
-	val |= MVPP2_GMAC_PORT_EN_MASK;
-	val |= MVPP2_GMAC_MIB_CNTR_EN_MASK;
-	writel(val, port->base + MVPP2_GMAC_CTRL_0_REG);
+	/* Only GOP port 0 has an XLG MAC */
+	if (port->gop_id == 0 &&
+	    (port->phy_interface == PHY_INTERFACE_MODE_XAUI ||
+	     port->phy_interface == PHY_INTERFACE_MODE_10GKR)) {
+		val = readl(port->base + MVPP22_XLG_CTRL0_REG);
+		val |= MVPP22_XLG_CTRL0_PORT_EN |
+		       MVPP22_XLG_CTRL0_MAC_RESET_DIS;
+		val &= ~MVPP22_XLG_CTRL0_MIB_CNT_DIS;
+		writel(val, port->base + MVPP22_XLG_CTRL0_REG);
+	} else {
+		val = readl(port->base + MVPP2_GMAC_CTRL_0_REG);
+		val |= MVPP2_GMAC_PORT_EN_MASK;
+		val |= MVPP2_GMAC_MIB_CNTR_EN_MASK;
+		writel(val, port->base + MVPP2_GMAC_CTRL_0_REG);
+	}
 }
 
 static void mvpp2_port_disable(struct mvpp2_port *port)
 {
 	u32 val;
 
-	val = readl(port->base + MVPP2_GMAC_CTRL_0_REG);
-	val &= ~(MVPP2_GMAC_PORT_EN_MASK);
-	writel(val, port->base + MVPP2_GMAC_CTRL_0_REG);
+	/* Only GOP port 0 has an XLG MAC */
+	if (port->gop_id == 0 &&
+	    (port->phy_interface == PHY_INTERFACE_MODE_XAUI ||
+	     port->phy_interface == PHY_INTERFACE_MODE_10GKR)) {
+		val = readl(port->base + MVPP22_XLG_CTRL0_REG);
+		val &= ~(MVPP22_XLG_CTRL0_PORT_EN |
+			 MVPP22_XLG_CTRL0_MAC_RESET_DIS);
+		writel(val, port->base + MVPP22_XLG_CTRL0_REG);
+	} else {
+		val = readl(port->base + MVPP2_GMAC_CTRL_0_REG);
+		val &= ~(MVPP2_GMAC_PORT_EN_MASK);
+		writel(val, port->base + MVPP2_GMAC_CTRL_0_REG);
+	}
 }
 
 /* Set IEEE 802.3x Flow Control Xon Packet Transmission Mode */
-- 
2.9.4
