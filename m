From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: support control of advertising
Date: Tue, 4 Jan 2011 23:38:02 +0100
Message-ID: <20110104223802.GA6105@electric-eye.fr.zoreil.com>
References: <201101041715.09622.oneukum@suse.de> <1294161621.3636.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Neukum <oneukum@suse.de>, davem@davemloft.net,
	netdev@vger.kernel.org, machen@novell.com,
	Hayes Wang <hayeswang@realtek.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36011 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab1ADWiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 17:38:21 -0500
Content-Disposition: inline
In-Reply-To: <1294161621.3636.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> :
[...]
> Should be ADVERTISE_10HALF.

Fixed.

[...]
> > +		if (adv & ADVERTISED_10baseT_Half)
> > +			auto_nego |= ADVERTISE_10HALF;
> > +		if (adv & ADVERTISED_10baseT_Full)
> > +			auto_nego |= ADVERTISE_10FULL;
> > +		if (adv & ADVERTISED_100baseT_Half)
> > +			auto_nego |= ADVERTISE_100HALF;
> > +		if (adv & ADVERTISED_100baseT_Full)
> > +			auto_nego |=  ADVERTISE_100FULL;
> > +
> >  		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
> [...]
> 
> Pause advertising should also be controllable through ethtool, if flow
> control can be altered in the MAC.  (It's not clear whether it can.)

It would be gluttony.

> This should also check for unsupported advertising flags (e.g.
> ADVERTISED_1000baseT_Full when the MAC doesn't support 1000M) and return
> -EINVAL if they're set.

Fixed.

Oliver, are you ok with the patch below (against davem's net-next or you
will experience rejects) ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 27a7c20..4175a14 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -540,7 +540,7 @@ struct rtl8169_private {
 		void (*up)(struct rtl8169_private *);
 	} pll_power_ops;
 
-	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
+	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
 	void (*hw_start)(struct net_device *);
@@ -1093,7 +1093,7 @@ static int rtl8169_get_regs_len(struct net_device *dev)
 }
 
 static int rtl8169_set_speed_tbi(struct net_device *dev,
-				 u8 autoneg, u16 speed, u8 duplex)
+				 u8 autoneg, u16 speed, u8 duplex, u32 ignored)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1116,17 +1116,28 @@ static int rtl8169_set_speed_tbi(struct net_device *dev,
 }
 
 static int rtl8169_set_speed_xmii(struct net_device *dev,
-				  u8 autoneg, u16 speed, u8 duplex)
+				  u8 autoneg, u16 speed, u8 duplex, u32 adv)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int giga_ctrl, bmcr;
+	int rc = -EINVAL;
 
 	if (autoneg == AUTONEG_ENABLE) {
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
@@ -1141,10 +1152,15 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		    (tp->mac_version != RTL_GIGA_MAC_VER_14) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_16)) {
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
@@ -1171,7 +1187,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		else if (speed == SPEED_100)
 			bmcr = BMCR_SPEED100;
 		else
-			return -EINVAL;
+			goto out;
 
 		if (duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
@@ -1194,16 +1210,18 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
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
@@ -1218,7 +1236,8 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	ret = rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	ret = rtl8169_set_speed(dev,
+		cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return ret;
@@ -2517,11 +2536,11 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
 	rtl8169_phy_reset(dev, tp);
 
-	/*
-	 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
-	 * only 8101. Don't panic.
-	 */
-	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
+	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
+		ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
+		ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
+		tp->mii.supports_gmii ? 0 :
+			ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
