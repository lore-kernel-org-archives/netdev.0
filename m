From: Michael Stapelberg <michael@stapelberg.de>
Subject: [PATCH net-next 2/2] mv643xx_eth with 88E1318S: support Wake on LAN
Date: Tue, 12 Mar 2013 00:56:45 +0100
Message-ID: <1363046205-17239-2-git-send-email-michael@stapelberg.de>
References: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Michael Stapelberg <michael@stapelberg.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.in.zekjur.net ([79.140.39.194]:49601 "EHLO
	infra.in.zekjur.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3CLAEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 20:04:48 -0400
In-Reply-To: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has been tested on a qnap TS-119P II. Note that enabling WOL with
"ethtool -s eth0 wol g" is not enough; you also need to tell the PIC
microcontroller inside the qnap that WOL should be enabled by sending
0xF2 with qcontrol(1) and you have to disable EUP ("Energy-using
Products", a European power-saving thing) by sending 0xF4.

Signed-off-by: Michael Stapelberg <michael@stapelberg.de>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   32 +++++++
 drivers/net/phy/marvell.c                  |  127 ++++++++++++++++++++++++++++
 2 files changed, 159 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 2914050..64a405e 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -20,6 +20,8 @@
  * Copyright (C) 2007-2008 Marvell Semiconductor
  *			   Lennert Buytenhek <buytenh@marvell.com>
  *
+ * Copyright (C) 2013 Michael Stapelberg <michael@stapelberg.de>
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -1484,6 +1486,34 @@ mv643xx_eth_get_settings_phyless(struct mv643xx_eth_private *mp,
 	return 0;
 }
 
+static void
+mv643xx_eth_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	wol->supported = 0;
+	wol->wolopts = 0;
+	if (mp->phy)
+		phy_ethtool_get_wol(mp->phy, wol);
+}
+
+static int
+mv643xx_eth_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int err;
+
+	if (mp->phy == NULL)
+		return -EOPNOTSUPP;
+
+	err = phy_ethtool_set_wol(mp->phy, wol);
+	/* Given that mv643xx_eth works without the marvell-specific PHY driver,
+	 * this debugging hint is useful to have.
+	 */
+	if (err == -EOPNOTSUPP)
+		netdev_info(dev, "The PHY does not support set_wol, was CONFIG_MARVELL_PHY enabled?\n");
+	return err;
+}
+
 static int
 mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
@@ -1665,6 +1695,8 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
 	.get_sset_count		= mv643xx_eth_get_sset_count,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_wol                = mv643xx_eth_get_wol,
+	.set_wol                = mv643xx_eth_set_wol,
 };
 
 
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 22dec9c..b05ac6e 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -7,6 +7,8 @@
  *
  * Copyright (c) 2004 Freescale Semiconductor, Inc.
  *
+ * Copyright (c) 2013 Michael Stapelberg <michael@stapelberg.de>
+ *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
  * Free Software Foundation;  either version 2 of the  License, or (at your
@@ -80,6 +82,28 @@
 #define MII_88E1318S_PHY_MSCR1_REG	16
 #define MII_88E1318S_PHY_MSCR1_PAD_ODD	BIT(6)
 
+/* Copper Specific Interrupt Enable Register */
+#define MII_88E1318S_PHY_CSIER                              0x12
+/* WOL Event Interrupt Enable */
+#define MII_88E1318S_PHY_CSIER_WOL_EIE                      BIT(7)
+
+/* LED Timer Control Register */
+#define MII_88E1318S_PHY_LED_PAGE                           0x03
+#define MII_88E1318S_PHY_LED_TCR                            0x12
+#define MII_88E1318S_PHY_LED_TCR_FORCE_INT                  BIT(15)
+#define MII_88E1318S_PHY_LED_TCR_INTn_ENABLE                BIT(7)
+#define MII_88E1318S_PHY_LED_TCR_INT_ACTIVE_LOW             BIT(11)
+
+/* Magic Packet MAC address registers */
+#define MII_88E1318S_PHY_MAGIC_PACKET_WORD2                 0x17
+#define MII_88E1318S_PHY_MAGIC_PACKET_WORD1                 0x18
+#define MII_88E1318S_PHY_MAGIC_PACKET_WORD0                 0x19
+
+#define MII_88E1318S_PHY_WOL_PAGE                           0x11
+#define MII_88E1318S_PHY_WOL_CTRL                           0x10
+#define MII_88E1318S_PHY_WOL_CTRL_CLEAR_WOL_STATUS          BIT(12)
+#define MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE BIT(14)
+
 #define MII_88E1121_PHY_LED_CTRL	16
 #define MII_88E1121_PHY_LED_PAGE	3
 #define MII_88E1121_PHY_LED_DEF		0x0030
@@ -696,6 +720,107 @@ static int m88e1121_did_interrupt(struct phy_device *phydev)
 	return 0;
 }
 
+static void m88e1318_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
+{
+	wol->supported = WAKE_MAGIC;
+	wol->wolopts = 0;
+
+	if (phy_write(phydev, MII_MARVELL_PHY_PAGE,
+		MII_88E1318S_PHY_WOL_PAGE) < 0)
+		return;
+
+	if (phy_read(phydev, MII_88E1318S_PHY_WOL_CTRL) &
+		MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE)
+		wol->wolopts |= WAKE_MAGIC;
+
+	if (phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x00) < 0)
+		return;
+}
+
+static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
+{
+	int err, oldpage, temp;
+
+	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+
+	if (wol->wolopts & WAKE_MAGIC) {
+		/* Explicitly switch to page 0x00, just to be sure */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x00);
+		if (err < 0)
+			return err;
+
+		/* Enable the WOL interrupt */
+		temp = phy_read(phydev, MII_88E1318S_PHY_CSIER);
+		temp |= MII_88E1318S_PHY_CSIER_WOL_EIE;
+		err = phy_write(phydev, MII_88E1318S_PHY_CSIER, temp);
+		if (err < 0)
+			return err;
+
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
+				MII_88E1318S_PHY_LED_PAGE);
+		if (err < 0)
+			return err;
+
+		/* Setup LED[2] as interrupt pin (active low) */
+		temp = phy_read(phydev, MII_88E1318S_PHY_LED_TCR);
+		temp &= ~MII_88E1318S_PHY_LED_TCR_FORCE_INT;
+		temp |= MII_88E1318S_PHY_LED_TCR_INTn_ENABLE;
+		temp |= MII_88E1318S_PHY_LED_TCR_INT_ACTIVE_LOW;
+		err = phy_write(phydev, MII_88E1318S_PHY_LED_TCR, temp);
+		if (err < 0)
+			return err;
+
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
+				MII_88E1318S_PHY_WOL_PAGE);
+		if (err < 0)
+			return err;
+
+		/* Store the device address for the magic packet */
+		err = phy_write(phydev, MII_88E1318S_PHY_MAGIC_PACKET_WORD2,
+			  ((phydev->attached_dev->dev_addr[5] << 8) |
+			    phydev->attached_dev->dev_addr[4]));
+		if (err < 0)
+			return err;
+		err = phy_write(phydev, MII_88E1318S_PHY_MAGIC_PACKET_WORD1,
+			  ((phydev->attached_dev->dev_addr[3] << 8) |
+			    phydev->attached_dev->dev_addr[2]));
+		if (err < 0)
+			return err;
+		err = phy_write(phydev, MII_88E1318S_PHY_MAGIC_PACKET_WORD0,
+			  ((phydev->attached_dev->dev_addr[1] << 8) |
+			    phydev->attached_dev->dev_addr[0]));
+		if (err < 0)
+			return err;
+
+		/* Clear WOL status and enable magic packet matching */
+		temp = phy_read(phydev, MII_88E1318S_PHY_WOL_CTRL);
+		temp |= MII_88E1318S_PHY_WOL_CTRL_CLEAR_WOL_STATUS;
+		temp |= MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE;
+		err = phy_write(phydev, MII_88E1318S_PHY_WOL_CTRL, temp);
+		if (err < 0)
+			return err;
+	} else {
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
+				MII_88E1318S_PHY_WOL_PAGE);
+		if (err < 0)
+			return err;
+
+		/* Clear WOL status and disable magic packet matching */
+		temp = phy_read(phydev, MII_88E1318S_PHY_WOL_CTRL);
+		temp |= MII_88E1318S_PHY_WOL_CTRL_CLEAR_WOL_STATUS;
+		temp &= ~MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE;
+		err = phy_write(phydev, MII_88E1318S_PHY_WOL_CTRL, temp);
+		if (err < 0)
+			return err;
+	}
+
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
 static struct phy_driver marvell_drivers[] = {
 	{
 		.phy_id = MARVELL_PHY_ID_88E1101,
@@ -772,6 +897,8 @@ static struct phy_driver marvell_drivers[] = {
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.did_interrupt = &m88e1121_did_interrupt,
+		.get_wol = &m88e1318_get_wol,
+		.set_wol = &m88e1318_set_wol,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-- 
1.7.10.4
