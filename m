From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv2 2/2] tg3: Add code to allow ethtool to enable/disable loopback.
Date: Fri, 29 Apr 2011 18:03:24 -0700
Message-ID: <1304125404-19376-1-git-send-email-maheshb@google.com>
References: <1304033599-8395-3-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:42600 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757532Ab1D3BDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 21:03:42 -0400
In-Reply-To: <1304033599-8395-3-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
Changes since v1:
 Implemented Matt's suggestions.
   (a) Enable this capability on the devices which are capable of MAC-loopback
       mode.
   (b) check if the device is running before making changes.
   (c) check bits before making changes.

 drivers/net/tg3.c |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fa57e3d..f6e4c10 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6319,6 +6319,51 @@ static u32 tg3_fix_features(struct net_device *dev, u32 features)
 	return features;
 }
 
+static int tg3_set_features(struct net_device *dev, u32 features)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	u32 cur_mode = 0;
+	int err = 0;
+
+	if (!netif_running(dev)) {
+		err = -EAGAIN;
+		goto sfeatures_out;
+	}
+
+	spin_lock_bh(&tp->lock);
+	cur_mode = tr32(MAC_MODE);
+
+	if (features & NETIF_F_LOOPBACK) {
+		if (cur_mode & MAC_MODE_PORT_INT_LPBACK)
+			goto sfeatures_unlock;
+
+		/*
+		 * Clear MAC_MODE_HALF_DUPLEX or you won't get packets back in
+		 * loopback mode if Half-Duplex mode was negotiated earlier.
+		 */
+		cur_mode &= ~MAC_MODE_HALF_DUPLEX;
+
+		/* Enable internal MAC loopback mode */
+		tw32(MAC_MODE, cur_mode | MAC_MODE_PORT_INT_LPBACK);
+		netif_carrier_on(tp->dev);
+		netdev_info(dev, "Internal MAC loopback mode enabled.\n");
+	} else {
+		if (!(cur_mode & MAC_MODE_PORT_INT_LPBACK))
+			goto sfeatures_unlock;
+
+		/* Disable internal MAC loopback mode */
+		tw32(MAC_MODE, cur_mode & ~MAC_MODE_PORT_INT_LPBACK);
+		/* Force link status check */
+		tg3_setup_phy(tp, 1);
+		netdev_info(dev, "Internal MAC loopback mode disabled.\n");
+	}
+sfeatures_unlock:
+	spin_unlock_bh(&tp->lock);
+
+sfeatures_out:
+	return err;
+}
+
 static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 			       int new_mtu)
 {
@@ -15028,6 +15073,7 @@ static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
 	.ndo_fix_features	= tg3_fix_features,
+	.ndo_set_features	= tg3_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -15044,6 +15090,7 @@ static const struct net_device_ops tg3_netdev_ops_dma_bug = {
 	.ndo_do_ioctl		= tg3_ioctl,
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
+	.ndo_set_features	= tg3_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -15241,6 +15288,16 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->features |= hw_features;
 	dev->vlan_features |= hw_features;
 
+	/*
+	 * Add loopback capability only for a subset of devices that support
+	 * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
+	 * loopback for the remaining devices.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5780 ||
+			!tg3_flag(tp, CPMU_PRESENT))
+		/* Add the loopback capability */
+		dev->hw_features |= NETIF_F_LOOPBACK;
+
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
 	    !tg3_flag(tp, TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
-- 
1.7.3.1

