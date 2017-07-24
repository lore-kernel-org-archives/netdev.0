From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 06/18] net: mvpp2: initialize the XLG MAC when using a port
Date: Mon, 24 Jul 2017 15:48:36 +0200
Message-ID: <20170724134848.19330-7-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47360 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755778AbdGXNuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:04 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a routine to initialize the XLG MAC at the port level when
using a port and the XAUI/10GKR interface mode. This wasn't done until
this commit, and the mvpp2 driver was relying on the bootloader/firmware
initialization. This doesn't mean everything is configured in the mvpp2
driver now, but it helps reducing the gap.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 2573b0c27300..b3601561bbae 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -354,6 +354,7 @@
 #define MVPP22_XLG_CTRL0_REG			0x100
 #define     MVPP22_XLG_CTRL0_PORT_EN		BIT(0)
 #define     MVPP22_XLG_CTRL0_MAC_RESET_DIS	BIT(1)
+#define     MVPP22_XLG_CTRL0_RX_FLOW_CTRL_EN	BIT(7)
 #define     MVPP22_XLG_CTRL0_MIB_CNT_DIS	BIT(14)
 
 #define MVPP22_XLG_CTRL3_REG			0x11c
@@ -361,6 +362,11 @@
 #define     MVPP22_XLG_CTRL3_MACMODESELECT_GMAC	(0 << 13)
 #define     MVPP22_XLG_CTRL3_MACMODESELECT_10G	(1 << 13)
 
+#define MVPP22_XLG_CTRL4_REG			0x184
+#define     MVPP22_XLG_CTRL4_FWD_FC		BIT(5)
+#define     MVPP22_XLG_CTRL4_FWD_PFC		BIT(6)
+#define     MVPP22_XLG_CTRL4_MACMODSELECT_GMAC	BIT(12)
+
 /* SMI registers. PPv2.2 only, relative to priv->iface_base. */
 #define MVPP22_SMI_MISC_CFG_REG			0x1204
 #define     MVPP22_SMI_POLLING_EN		BIT(10)
@@ -4257,6 +4263,18 @@ static void mvpp2_port_mii_gmac_configure(struct mvpp2_port *port)
 	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
 }
 
+static void mvpp2_port_mii_xlg_configure(struct mvpp2_port *port)
+{
+	u32 val = readl(port->base + MVPP22_XLG_CTRL0_REG);
+	val |= MVPP22_XLG_CTRL0_RX_FLOW_CTRL_EN;
+	writel(val, port->base + MVPP22_XLG_CTRL0_REG);
+
+	val = readl(port->base + MVPP22_XLG_CTRL4_REG);
+	val &= ~MVPP22_XLG_CTRL4_MACMODSELECT_GMAC;
+	val |= MVPP22_XLG_CTRL4_FWD_FC | MVPP22_XLG_CTRL4_FWD_PFC;
+	writel(val, port->base + MVPP22_XLG_CTRL4_REG);
+}
+
 static void mvpp22_port_mii_set(struct mvpp2_port *port)
 {
 	u32 val;
@@ -4284,6 +4302,8 @@ static void mvpp2_port_mii_set(struct mvpp2_port *port)
 	if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
 	    port->phy_interface == PHY_INTERFACE_MODE_SGMII)
 		mvpp2_port_mii_gmac_configure(port);
+	else if (port->phy_interface == PHY_INTERFACE_MODE_10GKR)
+		mvpp2_port_mii_xlg_configure(port);
 }
 
 static void mvpp2_port_fc_adv_enable(struct mvpp2_port *port)
-- 
2.13.3
