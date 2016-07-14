From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: pasemi_mac: use phydev from struct net_device
Date: Thu, 14 Jul 2016 23:44:52 +0200
Message-ID: <1468532693-456-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: olof@lixom.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33752 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcGNVpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 17:45:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c         |   28 ++++++++++-----------
 drivers/net/ethernet/pasemi/pasemi_mac.h         |    1 -
 drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c |    6 +---
 3 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index af54df5..2f4a837 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -989,7 +989,7 @@ static void pasemi_adjust_link(struct net_device *dev)
 	unsigned int flags;
 	unsigned int new_flags;
 
-	if (!mac->phydev->link) {
+	if (!dev->phydev->link) {
 		/* If no link, MAC speed settings don't matter. Just report
 		 * link down and return.
 		 */
@@ -1010,10 +1010,10 @@ static void pasemi_adjust_link(struct net_device *dev)
 	new_flags = flags & ~(PAS_MAC_CFG_PCFG_HD | PAS_MAC_CFG_PCFG_SPD_M |
 			      PAS_MAC_CFG_PCFG_TSR_M);
 
-	if (!mac->phydev->duplex)
+	if (!dev->phydev->duplex)
 		new_flags |= PAS_MAC_CFG_PCFG_HD;
 
-	switch (mac->phydev->speed) {
+	switch (dev->phydev->speed) {
 	case 1000:
 		new_flags |= PAS_MAC_CFG_PCFG_SPD_1G |
 			     PAS_MAC_CFG_PCFG_TSR_1G;
@@ -1027,15 +1027,15 @@ static void pasemi_adjust_link(struct net_device *dev)
 			     PAS_MAC_CFG_PCFG_TSR_10M;
 		break;
 	default:
-		printk("Unsupported speed %d\n", mac->phydev->speed);
+		printk("Unsupported speed %d\n", dev->phydev->speed);
 	}
 
 	/* Print on link or speed/duplex change */
-	msg = mac->link != mac->phydev->link || flags != new_flags;
+	msg = mac->link != dev->phydev->link || flags != new_flags;
 
-	mac->duplex = mac->phydev->duplex;
-	mac->speed = mac->phydev->speed;
-	mac->link = mac->phydev->link;
+	mac->duplex = dev->phydev->duplex;
+	mac->speed = dev->phydev->speed;
+	mac->link = dev->phydev->link;
 
 	if (new_flags != flags)
 		write_mac_reg(mac, PAS_MAC_CFG_PCFG, new_flags);
@@ -1067,8 +1067,6 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	mac->phydev = phydev;
-
 	return 0;
 }
 
@@ -1198,8 +1196,8 @@ static int pasemi_mac_open(struct net_device *dev)
 		goto out_rx_int;
 	}
 
-	if (mac->phydev)
-		phy_start(mac->phydev);
+	if (dev->phydev)
+		phy_start(dev->phydev);
 
 	setup_timer(&mac->tx->clean_timer, pasemi_mac_tx_timer,
 		    (unsigned long)mac->tx);
@@ -1293,9 +1291,9 @@ static int pasemi_mac_close(struct net_device *dev)
 	rxch = rx_ring(mac)->chan.chno;
 	txch = tx_ring(mac)->chan.chno;
 
-	if (mac->phydev) {
-		phy_stop(mac->phydev);
-		phy_disconnect(mac->phydev);
+	if (dev->phydev) {
+		phy_stop(dev->phydev);
+		phy_disconnect(dev->phydev);
 	}
 
 	del_timer_sync(&mac->tx->clean_timer);
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.h b/drivers/net/ethernet/pasemi/pasemi_mac.h
index 161c99a..7c47e26 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.h
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.h
@@ -70,7 +70,6 @@ struct pasemi_mac {
 	struct pci_dev *pdev;
 	struct pci_dev *dma_pdev;
 	struct pci_dev *iob_pdev;
-	struct phy_device *phydev;
 	struct napi_struct napi;
 
 	int		bufsz; /* RX ring buffer size */
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
index f046bfc..e99cf42 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
@@ -66,8 +66,7 @@ static int
 pasemi_mac_ethtool_get_settings(struct net_device *netdev,
 			       struct ethtool_cmd *cmd)
 {
-	struct pasemi_mac *mac = netdev_priv(netdev);
-	struct phy_device *phydev = mac->phydev;
+	struct phy_device *phydev = netdev->phydev;
 
 	if (!phydev)
 		return -EOPNOTSUPP;
@@ -79,8 +78,7 @@ static int
 pasemi_mac_ethtool_set_settings(struct net_device *netdev,
 			       struct ethtool_cmd *cmd)
 {
-	struct pasemi_mac *mac = netdev_priv(netdev);
-	struct phy_device *phydev = mac->phydev;
+	struct phy_device *phydev = netdev->phydev;
 
 	if (!phydev)
 		return -EOPNOTSUPP;
-- 
1.7.4.4
