From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/2] ks8695net: Disable non-working ethtool operations
Date: Thu, 13 Jan 2011 17:50:14 +0000
Message-ID: <1294941014.3946.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Figo.zhang" <figo1802@gmail.com>, zeal <zealcook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:40567 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933022Ab1AMRuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 12:50:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ethtool operations can only be implemented for the WAN port, and
not all such operations are allowed to return an error code such as
-EOPNOTSUPP.  Therefore, define two separate ethtool_ops structures
for WAN and non-WAN ports; simplify and rename the WAN-only functions.

This is completely untested as I don't have an ARM build environment.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This has nothing much to do with my work, but I spotted it while
auditing the various implementations of ethtool_ops::get_link.  While
ks8695net doesn't have a regular maintainer, the commit log suggests
that you are using it so perhaps you could test this change.

Ben.

 drivers/net/arm/ks8695net.c |  282 +++++++++++++++----------------------------
 1 files changed, 99 insertions(+), 183 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 54c6d84..8820fcd 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -854,12 +854,12 @@ ks8695_set_msglevel(struct net_device *ndev, u32 value)
 }
 
 /**
- *	ks8695_get_settings - Get device-specific settings.
+ *	ks8695_wan_get_settings - Get device-specific settings.
  *	@ndev: The network device to read settings from
  *	@cmd: The ethtool structure to read into
  */
 static int
-ks8695_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+ks8695_wan_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	u32 ctrl;
@@ -870,69 +870,50 @@ ks8695_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 			  SUPPORTED_TP | SUPPORTED_MII);
 	cmd->transceiver = XCVR_INTERNAL;
 
-	/* Port specific extras */
-	switch (ksp->dtype) {
-	case KS8695_DTYPE_HPNA:
-		cmd->phy_address = 0;
-		/* not supported for HPNA */
-		cmd->autoneg = AUTONEG_DISABLE;
+	cmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
+	cmd->port = PORT_MII;
+	cmd->supported |= (SUPPORTED_Autoneg | SUPPORTED_Pause);
+	cmd->phy_address = 0;
 
-		/* BUG: Erm, dtype hpna implies no phy regs */
-		/*
-		ctrl = readl(KS8695_MISC_VA + KS8695_HMC);
-		cmd->speed = (ctrl & HMC_HSS) ? SPEED_100 : SPEED_10;
-		cmd->duplex = (ctrl & HMC_HDS) ? DUPLEX_FULL : DUPLEX_HALF;
-		*/
-		return -EOPNOTSUPP;
-	case KS8695_DTYPE_WAN:
-		cmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
-		cmd->port = PORT_MII;
-		cmd->supported |= (SUPPORTED_Autoneg | SUPPORTED_Pause);
-		cmd->phy_address = 0;
+	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+	if ((ctrl & WMC_WAND) == 0) {
+		/* auto-negotiation is enabled */
+		cmd->advertising |= ADVERTISED_Autoneg;
+		if (ctrl & WMC_WANA100F)
+			cmd->advertising |= ADVERTISED_100baseT_Full;
+		if (ctrl & WMC_WANA100H)
+			cmd->advertising |= ADVERTISED_100baseT_Half;
+		if (ctrl & WMC_WANA10F)
+			cmd->advertising |= ADVERTISED_10baseT_Full;
+		if (ctrl & WMC_WANA10H)
+			cmd->advertising |= ADVERTISED_10baseT_Half;
+		if (ctrl & WMC_WANAP)
+			cmd->advertising |= ADVERTISED_Pause;
+		cmd->autoneg = AUTONEG_ENABLE;
+
+		cmd->speed = (ctrl & WMC_WSS) ? SPEED_100 : SPEED_10;
+		cmd->duplex = (ctrl & WMC_WDS) ?
+			DUPLEX_FULL : DUPLEX_HALF;
+	} else {
+		/* auto-negotiation is disabled */
+		cmd->autoneg = AUTONEG_DISABLE;
 
-		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
-		if ((ctrl & WMC_WAND) == 0) {
-			/* auto-negotiation is enabled */
-			cmd->advertising |= ADVERTISED_Autoneg;
-			if (ctrl & WMC_WANA100F)
-				cmd->advertising |= ADVERTISED_100baseT_Full;
-			if (ctrl & WMC_WANA100H)
-				cmd->advertising |= ADVERTISED_100baseT_Half;
-			if (ctrl & WMC_WANA10F)
-				cmd->advertising |= ADVERTISED_10baseT_Full;
-			if (ctrl & WMC_WANA10H)
-				cmd->advertising |= ADVERTISED_10baseT_Half;
-			if (ctrl & WMC_WANAP)
-				cmd->advertising |= ADVERTISED_Pause;
-			cmd->autoneg = AUTONEG_ENABLE;
-
-			cmd->speed = (ctrl & WMC_WSS) ? SPEED_100 : SPEED_10;
-			cmd->duplex = (ctrl & WMC_WDS) ?
-				DUPLEX_FULL : DUPLEX_HALF;
-		} else {
-			/* auto-negotiation is disabled */
-			cmd->autoneg = AUTONEG_DISABLE;
-
-			cmd->speed = (ctrl & WMC_WANF100) ?
-				SPEED_100 : SPEED_10;
-			cmd->duplex = (ctrl & WMC_WANFF) ?
-				DUPLEX_FULL : DUPLEX_HALF;
-		}
-		break;
-	case KS8695_DTYPE_LAN:
-		return -EOPNOTSUPP;
+		cmd->speed = (ctrl & WMC_WANF100) ?
+			SPEED_100 : SPEED_10;
+		cmd->duplex = (ctrl & WMC_WANFF) ?
+			DUPLEX_FULL : DUPLEX_HALF;
 	}
 
 	return 0;
 }
 
 /**
- *	ks8695_set_settings - Set device-specific settings.
+ *	ks8695_wan_set_settings - Set device-specific settings.
  *	@ndev: The network device to configure
  *	@cmd: The settings to configure
  */
 static int
-ks8695_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+ks8695_wan_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	u32 ctrl;
@@ -956,171 +937,99 @@ ks8695_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 				ADVERTISED_100baseT_Full)) == 0)
 			return -EINVAL;
 
-		switch (ksp->dtype) {
-		case KS8695_DTYPE_HPNA:
-			/* HPNA does not support auto-negotiation. */
-			return -EINVAL;
-		case KS8695_DTYPE_WAN:
-			ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
-
-			ctrl &= ~(WMC_WAND | WMC_WANA100F | WMC_WANA100H |
-				  WMC_WANA10F | WMC_WANA10H);
-			if (cmd->advertising & ADVERTISED_100baseT_Full)
-				ctrl |= WMC_WANA100F;
-			if (cmd->advertising & ADVERTISED_100baseT_Half)
-				ctrl |= WMC_WANA100H;
-			if (cmd->advertising & ADVERTISED_10baseT_Full)
-				ctrl |= WMC_WANA10F;
-			if (cmd->advertising & ADVERTISED_10baseT_Half)
-				ctrl |= WMC_WANA10H;
-
-			/* force a re-negotiation */
-			ctrl |= WMC_WANR;
-			writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
-			break;
-		case KS8695_DTYPE_LAN:
-			return -EOPNOTSUPP;
-		}
+		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
 
+		ctrl &= ~(WMC_WAND | WMC_WANA100F | WMC_WANA100H |
+			  WMC_WANA10F | WMC_WANA10H);
+		if (cmd->advertising & ADVERTISED_100baseT_Full)
+			ctrl |= WMC_WANA100F;
+		if (cmd->advertising & ADVERTISED_100baseT_Half)
+			ctrl |= WMC_WANA100H;
+		if (cmd->advertising & ADVERTISED_10baseT_Full)
+			ctrl |= WMC_WANA10F;
+		if (cmd->advertising & ADVERTISED_10baseT_Half)
+			ctrl |= WMC_WANA10H;
+
+		/* force a re-negotiation */
+		ctrl |= WMC_WANR;
+		writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
 	} else {
-		switch (ksp->dtype) {
-		case KS8695_DTYPE_HPNA:
-			/* BUG: dtype_hpna implies no phy registers */
-			/*
-			ctrl = __raw_readl(KS8695_MISC_VA + KS8695_HMC);
-
-			ctrl &= ~(HMC_HSS | HMC_HDS);
-			if (cmd->speed == SPEED_100)
-				ctrl |= HMC_HSS;
-			if (cmd->duplex == DUPLEX_FULL)
-				ctrl |= HMC_HDS;
-
-			__raw_writel(ctrl, KS8695_MISC_VA + KS8695_HMC);
-			*/
-			return -EOPNOTSUPP;
-		case KS8695_DTYPE_WAN:
-			ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
-
-			/* disable auto-negotiation */
-			ctrl |= WMC_WAND;
-			ctrl &= ~(WMC_WANF100 | WMC_WANFF);
-
-			if (cmd->speed == SPEED_100)
-				ctrl |= WMC_WANF100;
-			if (cmd->duplex == DUPLEX_FULL)
-				ctrl |= WMC_WANFF;
-
-			writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
-			break;
-		case KS8695_DTYPE_LAN:
-			return -EOPNOTSUPP;
-		}
+		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+
+		/* disable auto-negotiation */
+		ctrl |= WMC_WAND;
+		ctrl &= ~(WMC_WANF100 | WMC_WANFF);
+
+		if (cmd->speed == SPEED_100)
+			ctrl |= WMC_WANF100;
+		if (cmd->duplex == DUPLEX_FULL)
+			ctrl |= WMC_WANFF;
+
+		writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
 	}
 
 	return 0;
 }
 
 /**
- *	ks8695_nwayreset - Restart the autonegotiation on the port.
+ *	ks8695_wan_nwayreset - Restart the autonegotiation on the port.
  *	@ndev: The network device to restart autoneotiation on
  */
 static int
-ks8695_nwayreset(struct net_device *ndev)
+ks8695_wan_nwayreset(struct net_device *ndev)
 {
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	u32 ctrl;
 
-	switch (ksp->dtype) {
-	case KS8695_DTYPE_HPNA:
-		/* No phy means no autonegotiation on hpna */
-		return -EINVAL;
-	case KS8695_DTYPE_WAN:
-		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
 
-		if ((ctrl & WMC_WAND) == 0)
-			writel(ctrl | WMC_WANR,
-			       ksp->phyiface_regs + KS8695_WMC);
-		else
-			/* auto-negotiation not enabled */
-			return -EINVAL;
-		break;
-	case KS8695_DTYPE_LAN:
-		return -EOPNOTSUPP;
-	}
+	if ((ctrl & WMC_WAND) == 0)
+		writel(ctrl | WMC_WANR,
+		       ksp->phyiface_regs + KS8695_WMC);
+	else
+		/* auto-negotiation not enabled */
+		return -EINVAL;
 
 	return 0;
 }
 
 /**
- *	ks8695_get_link - Retrieve link status of network interface
+ *	ks8695_wan_get_link - Retrieve link status of network interface
  *	@ndev: The network interface to retrive the link status of.
  */
 static u32
-ks8695_get_link(struct net_device *ndev)
+ks8695_wan_get_link(struct net_device *ndev)
 {
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	u32 ctrl;
 
-	switch (ksp->dtype) {
-	case KS8695_DTYPE_HPNA:
-		/* HPNA always has link */
-		return 1;
-	case KS8695_DTYPE_WAN:
-		/* WAN we can read the PHY for */
-		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
-		return ctrl & WMC_WLS;
-	case KS8695_DTYPE_LAN:
-		return -EOPNOTSUPP;
-	}
-	return 0;
+	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+	return ctrl & WMC_WLS;
 }
 
 /**
- *	ks8695_get_pause - Retrieve network pause/flow-control advertising
+ *	ks8695_wan_get_pause - Retrieve network pause/flow-control advertising
  *	@ndev: The device to retrieve settings from
  *	@param: The structure to fill out with the information
  */
 static void
-ks8695_get_pause(struct net_device *ndev, struct ethtool_pauseparam *param)
+ks8695_wan_get_pause(struct net_device *ndev, struct ethtool_pauseparam *param)
 {
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	u32 ctrl;
 
-	switch (ksp->dtype) {
-	case KS8695_DTYPE_HPNA:
-		/* No phy link on hpna to configure */
-		return;
-	case KS8695_DTYPE_WAN:
-		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
-
-		/* advertise Pause */
-		param->autoneg = (ctrl & WMC_WANAP);
+	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
 
-		/* current Rx Flow-control */
-		ctrl = ks8695_readreg(ksp, KS8695_DRXC);
-		param->rx_pause = (ctrl & DRXC_RFCE);
+	/* advertise Pause */
+	param->autoneg = (ctrl & WMC_WANAP);
 
-		/* current Tx Flow-control */
-		ctrl = ks8695_readreg(ksp, KS8695_DTXC);
-		param->tx_pause = (ctrl & DTXC_TFCE);
-		break;
-	case KS8695_DTYPE_LAN:
-		/* The LAN's "phy" is a direct-attached switch */
-		return;
-	}
-}
+	/* current Rx Flow-control */
+	ctrl = ks8695_readreg(ksp, KS8695_DRXC);
+	param->rx_pause = (ctrl & DRXC_RFCE);
 
-/**
- *	ks8695_set_pause - Configure pause/flow-control
- *	@ndev: The device to configure
- *	@param: The pause parameters to set
- *
- *	TODO: Implement this
- */
-static int
-ks8695_set_pause(struct net_device *ndev, struct ethtool_pauseparam *param)
-{
-	return -EOPNOTSUPP;
+	/* current Tx Flow-control */
+	ctrl = ks8695_readreg(ksp, KS8695_DTXC);
+	param->tx_pause = (ctrl & DTXC_TFCE);
 }
 
 /**
@@ -1140,12 +1049,17 @@ ks8695_get_drvinfo(struct net_device *ndev, struct ethtool_drvinfo *info)
 static const struct ethtool_ops ks8695_ethtool_ops = {
 	.get_msglevel	= ks8695_get_msglevel,
 	.set_msglevel	= ks8695_set_msglevel,
-	.get_settings	= ks8695_get_settings,
-	.set_settings	= ks8695_set_settings,
-	.nway_reset	= ks8695_nwayreset,
-	.get_link	= ks8695_get_link,
-	.get_pauseparam = ks8695_get_pause,
-	.set_pauseparam = ks8695_set_pause,
+	.get_drvinfo	= ks8695_get_drvinfo,
+};
+
+static const struct ethtool_ops ks8695_wan_ethtool_ops = {
+	.get_msglevel	= ks8695_get_msglevel,
+	.set_msglevel	= ks8695_set_msglevel,
+	.get_settings	= ks8695_wan_get_settings,
+	.set_settings	= ks8695_wan_set_settings,
+	.nway_reset	= ks8695_wan_nwayreset,
+	.get_link	= ks8695_wan_get_link,
+	.get_pauseparam = ks8695_wan_get_pause,
 	.get_drvinfo	= ks8695_get_drvinfo,
 };
 
@@ -1541,7 +1455,6 @@ ks8695_probe(struct platform_device *pdev)
 
 	/* driver system setup */
 	ndev->netdev_ops = &ks8695_netdev_ops;
-	SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
 	ndev->watchdog_timeo	 = msecs_to_jiffies(watchdog);
 
 	netif_napi_add(ndev, &ksp->napi, ks8695_poll, NAPI_WEIGHT);
@@ -1608,12 +1521,15 @@ ks8695_probe(struct platform_device *pdev)
 	if (ksp->phyiface_regs && ksp->link_irq == -1) {
 		ks8695_init_switch(ksp);
 		ksp->dtype = KS8695_DTYPE_LAN;
+		SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
 	} else if (ksp->phyiface_regs && ksp->link_irq != -1) {
 		ks8695_init_wan_phy(ksp);
 		ksp->dtype = KS8695_DTYPE_WAN;
+		SET_ETHTOOL_OPS(ndev, &ks8695_wan_ethtool_ops);
 	} else {
 		/* No initialisation since HPNA does not have a PHY */
 		ksp->dtype = KS8695_DTYPE_HPNA;
+		SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
 	}
 
 	/* And bring up the net_device with the net core */
-- 
1.7.3.4




