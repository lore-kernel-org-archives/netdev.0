From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH 3/3] phylib: shared interrupts support for Marvell 88E1121R PHY
Date: Mon, 16 Feb 2009 21:53:51 +0100
Message-ID: <1234817631-7981-3-git-send-email-agust@denx.de>
References: <>
 <1234817631-7981-1-git-send-email-agust@denx.de>
 <1234817631-7981-2-git-send-email-agust@denx.de>
Cc: Anatolij Gustschin <agust@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:45224 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbZBPUx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 15:53:56 -0500
In-Reply-To: <1234817631-7981-2-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If this PHY is hardware-configured for shared MDC/MDIO,
P0_INT pin will indicate interrupts for both ports.
This patch extends 88E1121R code for handling interrupt
events over shared interrupt pin.

Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/phy/marvell.c |   86 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 1d282b0..64f22b9 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -74,6 +74,7 @@
 #define MII_88E1121_PHY_LED_DEF		0x0030
 
 #define MII_88E1121_PHY_PAGE		22
+#define MII_88E1121_PHY_GLOBAL_IRQS	23
 
 #define MII_M1011_PHY_STATUS		0x11
 #define MII_M1011_PHY_STATUS_1000	0x8000
@@ -88,6 +89,10 @@ MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
 
+struct m88e1121_priv {
+	unsigned long irq_map;
+} m88e1121_drv_data;
+
 static int marvell_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -257,6 +262,36 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int m88e1121_config_init(struct phy_device *phydev)
+{
+	struct m88e1121_priv *priv;
+	struct mii_bus *bus = phydev->bus;
+	int err;
+
+	/* Disable interrupts */
+	err = phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+	if (err < 0)
+		return err;
+
+	/* Clear interrupts */
+	err = phy_read(phydev, MII_M1011_IEVENT);
+	if (err < 0)
+		return err;
+
+	priv = &m88e1121_drv_data;
+	phydev->priv = priv;
+
+	if (phydev->drv->flags & PHY_HAS_INTERRUPT)
+		set_bit(phydev->addr, &priv->irq_map);
+
+	if ((bus->irq[0] != -1) && (bus->irq[1] != -1)
+	    && (bus->irq[0] == bus->irq[1])) {
+		phydev->drv->flags |= PHY_INTERRUPTS_SHARED;
+	}
+
+	return 0;
+}
+
 static int m88e1145_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -406,6 +441,54 @@ static int marvell_read_status(struct phy_device *phydev)
 	return 0;
 }
 
+static int m88e1121_interrupt_src(struct phy_device *phydev)
+{
+	struct m88e1121_priv *priv = phydev->priv;
+	struct mii_bus *bus = phydev->bus;
+	int src, port = -1;
+
+	src = phy_read(phydev, MII_88E1121_PHY_GLOBAL_IRQS);
+	if (src < 0)
+		return src;
+
+	if (src & 1)
+		port = 0;
+	else if (src & 2)
+		port = 1;
+
+	if (port != -1 && phydev->addr != port
+	    && !(priv->irq_map & (1 << port))
+	    && bus->phy_map[port]) {
+		/*
+		 * Interrupt not for this port and
+		 * interface is down, so we disable
+		 * this interrupt and ack it.
+		 */
+		BUG_ON(in_interrupt());
+
+		mutex_lock(&bus->mdio_lock);
+		/* Disable the interrupts */
+		src = bus->write(bus, bus->phy_map[port]->addr,
+				 MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+
+		/* Clear the interrupts */
+		src = bus->read(bus, bus->phy_map[port]->addr,
+				MII_M1011_IEVENT);
+		mutex_unlock(&bus->mdio_lock);
+		if (src < 0)
+			return src;
+	}
+
+	return port;
+}
+
+static void m88e1121_remove(struct phy_device *phydev)
+{
+	struct m88e1121_priv *priv = phydev->priv;
+
+	clear_bit(phydev->addr, &priv->irq_map);
+}
+
 static struct phy_driver marvell_drivers[] = {
 	{
 		.phy_id = 0x01410c60,
@@ -451,10 +534,13 @@ static struct phy_driver marvell_drivers[] = {
 		.name = "Marvell 88E1121R",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1121_config_init,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
+		.interrupt_src = &m88e1121_interrupt_src,
 		.config_intr = &marvell_config_intr,
+		.remove = &m88e1121_remove,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-- 
1.5.4.3

