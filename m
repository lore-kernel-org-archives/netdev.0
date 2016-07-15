From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: amd: au1000_eth: use phydev from struct net_device
Date: Fri, 15 Jul 2016 12:05:11 +0200
Message-ID: <1468577112-7884-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	manuel.lauss@gmail.com, mugunthanvnm@ti.com, ivecera@redhat.com,
	xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36743 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbcGOKFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:05:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id x83so1647459wma.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 03:05:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/amd/au1000_eth.c |   40 +++++++++++++-------------------
 drivers/net/ethernet/amd/au1000_eth.h |    1 -
 2 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 20760e1..18fe333 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -412,13 +412,13 @@ static void
 au1000_adjust_link(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
-	struct phy_device *phydev = aup->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	u32 reg;
 
 	int status_change = 0;
 
-	BUG_ON(!aup->phy_dev);
+	BUG_ON(!phydev);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -579,7 +579,6 @@ static int au1000_mii_probe(struct net_device *dev)
 	aup->old_link = 0;
 	aup->old_speed = 0;
 	aup->old_duplex = -1;
-	aup->phy_dev = phydev;
 
 	phy_attached_info(phydev);
 
@@ -680,23 +679,19 @@ au1000_setup_hw_rings(struct au1000_private *aup, void __iomem *tx_base)
 
 static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = netdev_priv(dev);
-
-	if (aup->phy_dev)
-		return phy_ethtool_gset(aup->phy_dev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_gset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
 
 static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = netdev_priv(dev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (aup->phy_dev)
-		return phy_ethtool_sset(aup->phy_dev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_sset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
@@ -778,8 +773,8 @@ static int au1000_init(struct net_device *dev)
 #ifndef CONFIG_CPU_LITTLE_ENDIAN
 	control |= MAC_BIG_ENDIAN;
 #endif
-	if (aup->phy_dev) {
-		if (aup->phy_dev->link && (DUPLEX_FULL == aup->phy_dev->duplex))
+	if (dev->phydev) {
+		if (dev->phydev->link && (DUPLEX_FULL == dev->phydev->duplex))
 			control |= MAC_FULL_DUPLEX;
 		else
 			control |= MAC_DISABLE_RX_OWN;
@@ -891,11 +886,10 @@ static int au1000_rx(struct net_device *dev)
 
 static void au1000_update_tx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 
 	if (status & TX_FRAME_ABORTED) {
-		if (!aup->phy_dev || (DUPLEX_FULL == aup->phy_dev->duplex)) {
+		if (!dev->phydev || (DUPLEX_FULL == dev->phydev->duplex)) {
 			if (status & (TX_JAB_TIMEOUT | TX_UNDERRUN)) {
 				/* any other tx errors are only valid
 				 * in half duplex mode
@@ -975,10 +969,10 @@ static int au1000_open(struct net_device *dev)
 		return retval;
 	}
 
-	if (aup->phy_dev) {
+	if (dev->phydev) {
 		/* cause the PHY state machine to schedule a link state check */
-		aup->phy_dev->state = PHY_CHANGELINK;
-		phy_start(aup->phy_dev);
+		dev->phydev->state = PHY_CHANGELINK;
+		phy_start(dev->phydev);
 	}
 
 	netif_start_queue(dev);
@@ -995,8 +989,8 @@ static int au1000_close(struct net_device *dev)
 
 	netif_dbg(aup, drv, dev, "close: dev=%p\n", dev);
 
-	if (aup->phy_dev)
-		phy_stop(aup->phy_dev);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -1110,15 +1104,13 @@ static void au1000_multicast_list(struct net_device *dev)
 
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct au1000_private *aup = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!aup->phy_dev)
+	if (!dev->phydev)
 		return -EINVAL; /* PHY not controllable */
 
-	return phy_mii_ioctl(aup->phy_dev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 static const struct net_device_ops au1000_netdev_ops = {
diff --git a/drivers/net/ethernet/amd/au1000_eth.h b/drivers/net/ethernet/amd/au1000_eth.h
index ca53024..4c47c23 100644
--- a/drivers/net/ethernet/amd/au1000_eth.h
+++ b/drivers/net/ethernet/amd/au1000_eth.h
@@ -106,7 +106,6 @@ struct au1000_private {
 	int old_speed;
 	int old_duplex;
 
-	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
 
 	/* PHY configuration */
-- 
1.7.4.4
