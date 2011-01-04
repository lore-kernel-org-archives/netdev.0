From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] r8169: support control of advertising
Date: Tue, 4 Jan 2011 17:15:09 +0100
Message-ID: <201101041715.09622.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Francois Romieu <romieu@fr.zoreil.com>, davem@davemloft.net,
	netdev@vger.kernel.org, machen@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58095 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944Ab1ADQNe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 11:13:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 91e84e6b6ca416e8200f04b60383c398f9b93bd2 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oliver@neukum.org>
Date: Tue, 4 Jan 2011 17:11:29 +0100
Subject: [PATCH] r8169: support control of advertising

This allows "ethtool advertise" to control the speed and duplex
features the device offers the switch.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/r8169.c |   41 +++++++++++++++++++++++++++++++----------
 1 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e165d96..f2c8583 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -490,7 +490,7 @@ struct rtl8169_private {
 #ifdef CONFIG_R8169_VLAN
 	struct vlan_group *vlgrp;
 #endif
-	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
+	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex, u32 advertising);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
 	void (*hw_start)(struct net_device *);
@@ -879,7 +879,7 @@ static int rtl8169_get_regs_len(struct net_device *dev)
 }
 
 static int rtl8169_set_speed_tbi(struct net_device *dev,
-				 u8 autoneg, u16 speed, u8 duplex)
+				 u8 autoneg, u16 speed, u8 duplex, u32 d)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -902,7 +902,7 @@ static int rtl8169_set_speed_tbi(struct net_device *dev,
 }
 
 static int rtl8169_set_speed_xmii(struct net_device *dev,
-				  u8 autoneg, u16 speed, u8 duplex)
+				  u8 autoneg, u16 speed, u8 duplex, u32 adv)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -912,8 +912,20 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		int auto_nego;
 
 		auto_nego = mdio_read(ioaddr, MII_ADVERTISE);
-		auto_nego |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
-			      ADVERTISE_100HALF | ADVERTISE_100FULL);
+		auto_nego &= ~(ADVERTISED_10baseT_Half |
+				ADVERTISE_10FULL |
+				ADVERTISE_100HALF |
+				ADVERTISE_100FULL);
+		
+		if (adv & ADVERTISED_10baseT_Half)
+			auto_nego |= ADVERTISE_10HALF;
+		if (adv & ADVERTISED_10baseT_Full)
+			auto_nego |= ADVERTISE_10FULL;
+		if (adv & ADVERTISED_100baseT_Half)
+			auto_nego |= ADVERTISE_100HALF;
+		if (adv & ADVERTISED_100baseT_Full)
+			auto_nego |=  ADVERTISE_100FULL;
+
 		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
 		giga_ctrl = mdio_read(ioaddr, MII_CTRL1000);
@@ -928,7 +940,10 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		    (tp->mac_version != RTL_GIGA_MAC_VER_14) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_16)) {
-			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
+			if (adv & ADVERTISED_1000baseT_Half)
+				giga_ctrl |= ADVERTISE_1000HALF;
+			if (adv &ADVERTISED_1000baseT_Full )
+				giga_ctrl |= ADVERTISE_1000FULL;
 		} else {
 			netif_info(tp, link, dev,
 				   "PHY does not support 1000Mbps\n");
@@ -985,12 +1000,12 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 }
 
 static int rtl8169_set_speed(struct net_device *dev,
-			     u8 autoneg, u16 speed, u8 duplex)
+			     u8 autoneg, u16 speed, u8 duplex, u32 advertising)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int ret;
 
-	ret = tp->set_speed(dev, autoneg, speed, duplex);
+	ret = tp->set_speed(dev, autoneg, speed, duplex, advertising);
 
 	if (netif_running(dev) && (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -1005,7 +1020,7 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	ret = rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	ret = rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return ret;
@@ -2842,7 +2857,13 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 	 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
 	 * only 8101. Don't panic.
 	 */
-	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
+	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
+			ADVERTISED_10baseT_Half |
+			ADVERTISED_10baseT_Full |
+			ADVERTISED_100baseT_Half |
+			ADVERTISED_100baseT_Full |
+			ADVERTISED_1000baseT_Half |
+			ADVERTISED_1000baseT_Full );
 
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
-- 
1.7.1

