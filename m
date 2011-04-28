From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 2/2] tg3: Add code to allow ethtool to enable/disable loopback.
Date: Thu, 28 Apr 2011 16:33:19 -0700
Message-ID: <1304033599-8395-3-git-send-email-maheshb@google.com>
References: <1304033599-8395-1-git-send-email-maheshb@google.com>
 <1304033599-8395-2-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:2052 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756863Ab1D1Xdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 19:33:38 -0400
In-Reply-To: <1304033599-8395-2-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/tg3.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fa57e3d..208884d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6319,6 +6319,33 @@ static u32 tg3_fix_features(struct net_device *dev, u32 features)
 	return features;
 }
 
+static int tg3_set_features(struct net_device *dev, u32 features)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	u32 cur_mode = 0;
+	int err = 0;
+
+	spin_lock_bh(&tp->lock);
+	cur_mode = tr32(MAC_MODE);
+
+	if (features & NETIF_F_LOOPBACK) {
+		/* Enable internal MAC loopback mode */
+		tw32(MAC_MODE, cur_mode | MAC_MODE_PORT_INT_LPBACK);
+		netif_carrier_on(tp->dev);
+		netdev_info(dev, "Internal MAC loopback mode enabled.\n");
+	} else {
+		/* Disable internal MAC loopback mode */
+		tw32(MAC_MODE, cur_mode & ~MAC_MODE_PORT_INT_LPBACK);
+		/* Force link status check */
+		if (netif_running(dev))
+			tg3_setup_phy(tp, 1);
+		netdev_info(dev, "Internal MAC loopback mode disabled.\n");
+	}
+	spin_unlock_bh(&tp->lock);
+
+	return err;
+}
+
 static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 			       int new_mtu)
 {
@@ -15028,6 +15055,7 @@ static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
 	.ndo_fix_features	= tg3_fix_features,
+	.ndo_set_features	= tg3_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -15044,6 +15072,7 @@ static const struct net_device_ops tg3_netdev_ops_dma_bug = {
 	.ndo_do_ioctl		= tg3_ioctl,
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
+	.ndo_set_features	= tg3_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -15241,6 +15270,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->features |= hw_features;
 	dev->vlan_features |= hw_features;
 
+	/* Add the loopback capability */
+	dev->hw_features |= NETIF_F_LOOPBACK;
+
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
 	    !tg3_flag(tp, TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
-- 
1.7.3.1

