From: Laura Garcia <nevola@gmail.com>
Subject: [PATCH 2/2]via-rhine.c: Write-Wake-on-LAN-options-in-_real-time_-not-at-shutdown
Date: Sat, 23 Feb 2008 18:56:45 +0100
Message-ID: <E1JSyc9-0004BM-BS@elite>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:64835 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573AbYBWR4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 12:56:49 -0500
Received: by ug-out-1314.google.com with SMTP id z38so205294ugc.16
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2008 09:56:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Write Wake-on-LAN options in _real time_ not at shutdown. It might
be safe in case of power outage.

Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>

	modified:   drivers/net/via-rhine.c
---
 drivers/net/via-rhine.c |   76 +++++++++++++++++++++++++---------------------
 1 files changed, 41 insertions(+), 35 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 8c9d6ae..7723ec0 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -418,6 +418,7 @@ static void rhine_tx(struct net_device *dev);
 static int rhine_rx(struct net_device *dev, int limit);
 static void rhine_error(struct net_device *dev, int intr_status);
 static void rhine_set_rx_mode(struct net_device *dev);
+static void rhine_write_wol(struct net_device *dev);
 static struct net_device_stats *rhine_get_stats(struct net_device *dev);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
@@ -1772,7 +1773,7 @@ static void rhine_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct rhine_private *rp = netdev_priv(dev);
 
 	if (!(rp->quirks & rqWOL))
-		return;
+		return; /* Nothing to do for non-WOL adapters */
 
 	spin_lock_irq(&rp->lock);
 	wol->supported = WAKE_PHY | WAKE_MAGIC |
@@ -1788,7 +1789,7 @@ static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		      WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
 
 	if (!(rp->quirks & rqWOL))
-		return -EINVAL;
+		return -EINVAL; /* Nothing to do for non-WOL adapters */
 
 	if (wol->wolopts & ~support)
 		return -EINVAL;
@@ -1797,9 +1798,47 @@ static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	rp->wolopts = wol->wolopts;
 	spin_unlock_irq(&rp->lock);
 
+	rhine_write_wol(dev);
+
 	return 0;
 }
 
+static void rhine_write_wol(struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	void __iomem *ioaddr = rp->base;
+
+	rhine_power_init(dev);
+
+	/* Make sure we use pattern 0, 1 and not 4, 5 */
+	if (rp->quirks & rq6patterns)
+		iowrite8(0x04, ioaddr + WOLcgClr);
+
+	if (rp->wolopts & WAKE_MAGIC) {
+		iowrite8(WOLmagic, ioaddr + WOLcrSet);
+		/*
+		 * Turn EEPROM-controlled wake-up back on -- some hardware may
+		 * not cooperate otherwise.
+		 */
+		iowrite8(ioread8(ioaddr + ConfigA) | 0x03, ioaddr + ConfigA);
+	}
+
+	if (rp->wolopts & (WAKE_BCAST|WAKE_MCAST))
+		iowrite8(WOLbmcast, ioaddr + WOLcgSet);
+
+	if (rp->wolopts & WAKE_PHY)
+		iowrite8(WOLlnkon | WOLlnkoff, ioaddr + WOLcrSet);
+
+	if (rp->wolopts & WAKE_UCAST)
+		iowrite8(WOLucast, ioaddr + WOLcrSet);
+
+	if (rp->wolopts) {
+		/* Enable legacy WOL (for old motherboards) */
+		iowrite8(0x01, ioaddr + PwcfgSet);
+		iowrite8(ioread8(ioaddr + StickyHW) | 0x04, ioaddr + StickyHW);
+	}
+}
+
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_settings		= netdev_get_settings,
@@ -1886,39 +1925,6 @@ static void rhine_shutdown (struct pci_dev *pdev)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	if (!(rp->quirks & rqWOL))
-		return; /* Nothing to do for non-WOL adapters */
-
-	rhine_power_init(dev);
-
-	/* Make sure we use pattern 0, 1 and not 4, 5 */
-	if (rp->quirks & rq6patterns)
-		iowrite8(0x04, ioaddr + WOLcgClr);
-
-	if (rp->wolopts & WAKE_MAGIC) {
-		iowrite8(WOLmagic, ioaddr + WOLcrSet);
-		/*
-		 * Turn EEPROM-controlled wake-up back on -- some hardware may
-		 * not cooperate otherwise.
-		 */
-		iowrite8(ioread8(ioaddr + ConfigA) | 0x03, ioaddr + ConfigA);
-	}
-
-	if (rp->wolopts & (WAKE_BCAST|WAKE_MCAST))
-		iowrite8(WOLbmcast, ioaddr + WOLcgSet);
-
-	if (rp->wolopts & WAKE_PHY)
-		iowrite8(WOLlnkon | WOLlnkoff, ioaddr + WOLcrSet);
-
-	if (rp->wolopts & WAKE_UCAST)
-		iowrite8(WOLucast, ioaddr + WOLcrSet);
-
-	if (rp->wolopts) {
-		/* Enable legacy WOL (for old motherboards) */
-		iowrite8(0x01, ioaddr + PwcfgSet);
-		iowrite8(ioread8(ioaddr + StickyHW) | 0x04, ioaddr + StickyHW);
-	}
-
 	/* Hit power state D3 (sleep) */
 	if (!avoid_D3)
 		iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
-- 
1.5.3.8

