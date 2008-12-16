From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 05/14] gianfar: Fix eTSEC configuration procedure
Date: Tue, 16 Dec 2008 17:20:58 -0600
Message-ID: <1229469667-25002-6-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Haruki Dai <Dai.Haruki@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39699 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbYLPXVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:23 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL9t3013544
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:10 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mBGNL8m3017595
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-5-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

Fix some bugs in the ethtool configuration functions:
* gfar_clean_rx_ring should not be called with interrupts disabled.
* Update last transmission time to avoid tx timeout.
* Delete redundant NETIF_F_IP_CSUM check in gfar_start_xmit
* Use netif_tx_lock_bh when reconfiguring the tx csum

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c         |    5 +++--
 drivers/net/gianfar_ethtool.c |   23 ++++++++++++-----------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 9b1a423..aac9915 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -892,6 +892,8 @@ void gfar_start(struct net_device *dev)
 
 	/* Unmask the interrupts we look for */
 	gfar_write(&regs->imask, IMASK_DEFAULT);
+
+	dev->trans_start = jiffies;
 }
 
 /* Bring the controller up and running */
@@ -1233,8 +1235,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	status = txbdp->status & TXBD_WRAP;
 
 	/* Set up checksumming */
-	if (likely((dev->features & NETIF_F_IP_CSUM)
-			&& (CHECKSUM_PARTIAL == skb->ip_summed))) {
+	if (CHECKSUM_PARTIAL == skb->ip_summed) {
 		fcb = gfar_add_fcb(skb, txbdp);
 		status |= TXBD_TOE;
 		gfar_tx_checksum(skb, fcb);
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index c111c53..3021057 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -462,11 +462,12 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 		spin_lock(&priv->rxlock);
 
 		gfar_halt(dev);
-		gfar_clean_rx_ring(dev, priv->rx_ring_size);
 
 		spin_unlock(&priv->rxlock);
 		spin_unlock_irqrestore(&priv->txlock, flags);
 
+		gfar_clean_rx_ring(dev, priv->rx_ring_size);
+
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
 	}
@@ -476,9 +477,10 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 	priv->tx_ring_size = rvals->tx_pending;
 
 	/* Rebuild the rings with the new size */
-	if (dev->flags & IFF_UP)
+	if (dev->flags & IFF_UP) {
 		err = startup_gfar(dev);
-
+		netif_wake_queue(dev);
+	}
 	return err;
 }
 
@@ -498,11 +500,12 @@ static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 		spin_lock(&priv->rxlock);
 
 		gfar_halt(dev);
-		gfar_clean_rx_ring(dev, priv->rx_ring_size);
 
 		spin_unlock(&priv->rxlock);
 		spin_unlock_irqrestore(&priv->txlock, flags);
 
+		gfar_clean_rx_ring(dev, priv->rx_ring_size);
+
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
 	}
@@ -511,9 +514,10 @@ static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 	priv->rx_csum_enable = data;
 	spin_unlock_irqrestore(&priv->bflock, flags);
 
-	if (dev->flags & IFF_UP)
+	if (dev->flags & IFF_UP) {
 		err = startup_gfar(dev);
-
+		netif_wake_queue(dev);
+	}
 	return err;
 }
 
@@ -529,22 +533,19 @@ static uint32_t gfar_get_rx_csum(struct net_device *dev)
 
 static int gfar_set_tx_csum(struct net_device *dev, uint32_t data)
 {
-	unsigned long flags;
 	struct gfar_private *priv = netdev_priv(dev);
 
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
 		return -EOPNOTSUPP;
 
-	spin_lock_irqsave(&priv->txlock, flags);
-	gfar_halt(dev);
+	netif_tx_lock_bh(dev);
 
 	if (data)
 		dev->features |= NETIF_F_IP_CSUM;
 	else
 		dev->features &= ~NETIF_F_IP_CSUM;
 
-	gfar_start(dev);
-	spin_unlock_irqrestore(&priv->txlock, flags);
+	netif_tx_unlock_bh(dev);
 
 	return 0;
 }
-- 
1.5.4.GIT

