From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv6 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Sun,  8 May 2011 09:51:48 -0700
Message-ID: <1304873508-24307-1-git-send-email-maheshb@google.com>
References: <1304749117-1989-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:8614 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab1EHQv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 12:51:56 -0400
In-Reply-To: <1304749117-1989-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tg3_set_features() to handle loopback mode. Currently the
capability is added for the devices which support internal MAC loopback mode.
So when enabled, it enables internal-MAC loopback.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
Changes since v5:
 (a) Removed TG3_FLAG_LOOPBACK_ENABLED flag.

Changes since v4:
 (a) Added TG3_FLAG_LOOPBACK_ENABLED flag to keep loopback state in driver's 
     private data-structure.
 (b) Corrected the loopback implementation by using tp->mac_mode.
 (c) Forced Link up when in loopback mode. 

Changes since v3:
 (a) Corrected the condition (|| => &&) where loopback capability is added.
 (b) set_features() always returns 0.
 (c) Clear the loopback bit in ndo_open callback to avoid discrepancy.

Changes since v2:
 Implemtned Joe Perches's style change.

Changes since v1:
 Implemented Matt Carlson's suggestions.
  (a) Enable this capability on the devices which are capable of MAC-loopback
      mode.
  (b) check if the device is running before making changes.
  (c) check bits before making changes.

 drivers/net/tg3.c |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 67 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7c7c9a8..9f77533 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3373,8 +3373,8 @@ relink:
 		tg3_phy_copper_begin(tp);
 
 		tg3_readphy(tp, MII_BMSR, &bmsr);
-		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
-		    (bmsr & BMSR_LSTATUS))
+		if ((!tg3_readphy(tp, MII_BMSR, &bmsr) && (bmsr & BMSR_LSTATUS)) ||
+		    (tp->mac_mode & MAC_MODE_PORT_INT_LPBACK))
 			current_link_up = 1;
 	}
 
@@ -6309,6 +6309,42 @@ dma_error:
 	return NETDEV_TX_OK;
 }
 
+static void tg3_set_loopback(struct net_device *dev, u32 features)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (features & NETIF_F_LOOPBACK) {
+		if (tp->mac_mode & MAC_MODE_PORT_INT_LPBACK)
+			return;
+
+		/*
+		 * Clear MAC_MODE_HALF_DUPLEX or you won't get packets back in
+		 * loopback mode if Half-Duplex mode was negotiated earlier.
+		 */
+		tp->mac_mode &= ~MAC_MODE_HALF_DUPLEX;
+
+		/* Enable internal MAC loopback mode */
+		tp->mac_mode |= MAC_MODE_PORT_INT_LPBACK;
+		spin_lock_bh(&tp->lock);
+		tw32(MAC_MODE, tp->mac_mode);
+		netif_carrier_on(tp->dev);
+		spin_unlock_bh(&tp->lock);
+		netdev_info(dev, "Internal MAC loopback mode enabled.\n");
+	} else {
+		if (!(tp->mac_mode & MAC_MODE_PORT_INT_LPBACK))
+			return;
+
+		/* Disable internal MAC loopback mode */
+		tp->mac_mode &= ~MAC_MODE_PORT_INT_LPBACK;
+		spin_lock_bh(&tp->lock);
+		tw32(MAC_MODE, tp->mac_mode);
+		/* Force link status check */
+		tg3_setup_phy(tp, 1);
+		spin_unlock_bh(&tp->lock);
+		netdev_info(dev, "Internal MAC loopback mode disabled.\n");
+	}
+}
+
 static u32 tg3_fix_features(struct net_device *dev, u32 features)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -6319,6 +6355,16 @@ static u32 tg3_fix_features(struct net_device *dev, u32 features)
 	return features;
 }
 
+static int tg3_set_features(struct net_device *dev, u32 features)
+{
+	u32 changed = dev->features ^ features;
+
+	if ((changed & NETIF_F_LOOPBACK) && netif_running(dev))
+		tg3_set_loopback(dev, features);
+
+	return 0;
+}
+
 static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 			       int new_mtu)
 {
@@ -9485,6 +9531,13 @@ static int tg3_open(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
+	/*
+	 * Reset loopback feature if it was turned on while the device was down
+	 * make sure that it's installed properly now.
+	 */
+	if (dev->features & NETIF_F_LOOPBACK)
+		tg3_set_loopback(dev, dev->features);
+
 	return 0;
 
 err_out3:
@@ -15029,6 +15082,7 @@ static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
 	.ndo_fix_features	= tg3_fix_features,
+	.ndo_set_features	= tg3_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -15045,6 +15099,7 @@ static const struct net_device_ops tg3_netdev_ops_dma_bug = {
 	.ndo_do_ioctl		= tg3_ioctl,
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
+	.ndo_set_features	= tg3_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -15242,6 +15297,16 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->features |= hw_features;
 	dev->vlan_features |= hw_features;
 
+	/*
+	 * Add loopback capability only for a subset of devices that support
+	 * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
+	 * loopback for the remaining devices.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5780 &&
+	    !tg3_flag(tp, CPMU_PRESENT))
+		/* Add the loopback capability */
+		dev->hw_features |= NETIF_F_LOOPBACK;
+
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
 	    !tg3_flag(tp, TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
-- 
1.7.3.1

