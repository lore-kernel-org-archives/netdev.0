From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 2/6] net: mvpp2: Enable proper PHY polling and fix port functionality
Date: Mon, 21 Jul 2014 13:48:12 -0300
Message-ID: <1405961296-5846-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>,
	David Miller <davem@davemloft.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55254 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932679AbaGUQt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 12:49:27 -0400
In-Reply-To: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcin Wojtas <mw@semihalf.com>

Currently, the network interfaces that are not configured by the bootloader
(using e.g. tftp or ping) can detect the link status but are unable to
transmit data.

The network controller has a functionality that allows the hardware to
continuously poll the PHY and directly update the MAC configuration accordingly
(speed, duplex, etc.). However, this doesn't work well with phylib's
software-based polling and updating MAC configuration in the driver's callback.

This commit fixes this issue by:

  1. Setting MVPP2_PHY_AN_STOP_SMI0_MASK in MVPP2_PHY_AN_CFG0_REG in
     mvpp2_init(), which disables the harware polling feature.

  2. Disabling MVPP2_GMAC_PCS_ENABLE_MASK bit in MVPP2_GMAC_CTRL_2_REG in
     mvpp2_port_mii_set() for port types other than SGMII.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 40 ++++++++++++++++++++++++++++--------
 1 file changed, 32 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 8eac438..aa139df 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -248,6 +248,8 @@
 /* LMS registers */
 #define MVPP2_SRC_ADDR_MIDDLE			0x24
 #define MVPP2_SRC_ADDR_HIGH			0x28
+#define MVPP2_PHY_AN_CFG0_REG			0x34
+#define     MVPP2_PHY_AN_STOP_SMI0_MASK		BIT(7)
 #define MVPP2_MIB_COUNTERS_BASE(port)		(0x1000 + ((port) >> 1) * \
 						0x400 + (port) * 0x400)
 #define     MVPP2_MIB_LATE_COLLISION		0x7c
@@ -278,6 +280,7 @@
 #define      MVPP2_GMAC_CONFIG_MII_SPEED	BIT(5)
 #define      MVPP2_GMAC_CONFIG_GMII_SPEED	BIT(6)
 #define      MVPP2_GMAC_AN_SPEED_EN		BIT(7)
+#define      MVPP2_GMAC_FC_ADV_EN		BIT(9)
 #define      MVPP2_GMAC_CONFIG_FULL_DUPLEX	BIT(12)
 #define      MVPP2_GMAC_AN_DUPLEX_EN		BIT(13)
 #define MVPP2_GMAC_PORT_FIFO_CFG_1_REG		0x1c
@@ -3809,16 +3812,30 @@ static void mvpp2_interrupts_unmask(void *arg)
 
 static void mvpp2_port_mii_set(struct mvpp2_port *port)
 {
-	u32 reg, val = 0;
+	u32 val;
 
-	if (port->phy_interface == PHY_INTERFACE_MODE_SGMII)
-		val = MVPP2_GMAC_PCS_ENABLE_MASK |
-		      MVPP2_GMAC_INBAND_AN_MASK;
-	else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII)
-		val = MVPP2_GMAC_PORT_RGMII_MASK;
+	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
+
+	switch (port->phy_interface) {
+	case PHY_INTERFACE_MODE_SGMII:
+		val |= MVPP2_GMAC_INBAND_AN_MASK;
+		break;
+	case PHY_INTERFACE_MODE_RGMII:
+		val |= MVPP2_GMAC_PORT_RGMII_MASK;
+	default:
+		val &= ~MVPP2_GMAC_PCS_ENABLE_MASK;
+	}
+
+	writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
+}
 
-	reg = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
-	writel(reg | val, port->base + MVPP2_GMAC_CTRL_2_REG);
+static void mvpp2_port_fc_adv_enable(struct mvpp2_port *port)
+{
+	u32 val;
+
+	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+	val |= MVPP2_GMAC_FC_ADV_EN;
+	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
 }
 
 static void mvpp2_port_enable(struct mvpp2_port *port)
@@ -5877,6 +5894,7 @@ static void mvpp2_port_power_up(struct mvpp2_port *port)
 {
 	mvpp2_port_mii_set(port);
 	mvpp2_port_periodic_xon_disable(port);
+	mvpp2_port_fc_adv_enable(port);
 	mvpp2_port_reset(port);
 }
 
@@ -6198,6 +6216,7 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 {
 	const struct mbus_dram_target_info *dram_target_info;
 	int err, i;
+	u32 val;
 
 	/* Checks for hardware constraints */
 	if (rxq_number % 4 || (rxq_number > MVPP2_MAX_RXQ) ||
@@ -6211,6 +6230,11 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	if (dram_target_info)
 		mvpp2_conf_mbus_windows(dram_target_info, priv);
 
+	/* Disable HW PHY polling */
+	val = readl(priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
+	val |= MVPP2_PHY_AN_STOP_SMI0_MASK;
+	writel(val, priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
+
 	/* Allocate and initialize aggregated TXQs */
 	priv->aggr_txqs = devm_kcalloc(&pdev->dev, num_present_cpus(),
 				       sizeof(struct mvpp2_tx_queue),
-- 
2.0.1
