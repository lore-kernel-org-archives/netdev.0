From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/4] r8169: support control of advertising.
Date: Sat, 5 Mar 2011 10:40:34 +0100
Message-ID: <20110305094034.GC13854@electric-eye.fr.zoreil.com>
References: <20110305093716.GA13835@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Oliver Neukum <oneukum@suse.de>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50187 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab1CEJpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 04:45:13 -0500
Content-Disposition: inline
In-Reply-To: <20110305093716.GA13835@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows "ethtool advertise" to control the speed and duplex
features the device offers the switch.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   54 ++++++++++++++++++++++++++++++++++----------------
 1 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2543edd..d842d00 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -551,7 +551,7 @@ struct rtl8169_private {
 		void (*up)(struct rtl8169_private *);
 	} pll_power_ops;
 
-	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
+	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
 	void (*hw_start)(struct net_device *);
@@ -1108,7 +1108,7 @@ static int rtl8169_get_regs_len(struct net_device *dev)
 }
 
 static int rtl8169_set_speed_tbi(struct net_device *dev,
-				 u8 autoneg, u16 speed, u8 duplex)
+				 u8 autoneg, u16 speed, u8 duplex, u32 ignored)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1131,10 +1131,11 @@ static int rtl8169_set_speed_tbi(struct net_device *dev,
 }
 
 static int rtl8169_set_speed_xmii(struct net_device *dev,
-				  u8 autoneg, u16 speed, u8 duplex)
+				  u8 autoneg, u16 speed, u8 duplex, u32 adv)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int giga_ctrl, bmcr;
+	int rc = -EINVAL;
 
 	rtl_writephy(tp, 0x1f, 0x0000);
 
@@ -1142,8 +1143,18 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		int auto_nego;
 
 		auto_nego = rtl_readphy(tp, MII_ADVERTISE);
-		auto_nego |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
-			      ADVERTISE_100HALF | ADVERTISE_100FULL);
+		auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
+				ADVERTISE_100HALF | ADVERTISE_100FULL);
+
+		if (adv & ADVERTISED_10baseT_Half)
+			auto_nego |= ADVERTISE_10HALF;
+		if (adv & ADVERTISED_10baseT_Full)
+			auto_nego |= ADVERTISE_10FULL;
+		if (adv & ADVERTISED_100baseT_Half)
+			auto_nego |= ADVERTISE_100HALF;
+		if (adv & ADVERTISED_100baseT_Full)
+			auto_nego |= ADVERTISE_100FULL;
+
 		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
 		giga_ctrl = rtl_readphy(tp, MII_CTRL1000);
@@ -1160,10 +1171,15 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		    (tp->mac_version != RTL_GIGA_MAC_VER_16) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_29) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_30)) {
-			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
-		} else {
+			if (adv & ADVERTISED_1000baseT_Half)
+				giga_ctrl |= ADVERTISE_1000HALF;
+			if (adv & ADVERTISED_1000baseT_Full)
+				giga_ctrl |= ADVERTISE_1000FULL;
+		} else if (adv & (ADVERTISED_1000baseT_Half |
+				  ADVERTISED_1000baseT_Full)) {
 			netif_info(tp, link, dev,
 				   "PHY does not support 1000Mbps\n");
+			goto out;
 		}
 
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
@@ -1178,7 +1194,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		else if (speed == SPEED_100)
 			bmcr = BMCR_SPEED100;
 		else
-			return -EINVAL;
+			goto out;
 
 		if (duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
@@ -1199,16 +1215,18 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		}
 	}
 
-	return 0;
+	rc = 0;
+out:
+	return rc;
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
@@ -1223,7 +1241,8 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	ret = rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	ret = rtl8169_set_speed(dev,
+		cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return ret;
@@ -2669,11 +2688,12 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
 	rtl8169_phy_reset(dev, tp);
 
-	/*
-	 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
-	 * only 8101. Don't panic.
-	 */
-	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
+	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
+		ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
+		ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
+		tp->mii.supports_gmii ?
+			ADVERTISED_1000baseT_Half |
+			ADVERTISED_1000baseT_Full : 0);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
-- 
1.7.4


