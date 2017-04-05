From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 05/13] ftgmac100: Cleanup speed/duplex tracking and fix duplex config
Date: Wed,  5 Apr 2017 12:28:45 +1000
Message-ID: <20170405022853.8238-6-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48190 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755122AbdDECaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:30:02 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep track of both the current speed and duplex settings
instead of only speed and properly apply the duplex setting
to the HW.

This reworks the adjust_link() function to also avoid trying
to reconfigure the HW when there is no link and to display
the link state to the user.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--

v2. Use phy_print_status()
    Only bail out on link down *after* updating priv->cur_speed
---
 drivers/net/ethernet/faraday/ftgmac100.c | 52 +++++++++++++++++++++++++++-----
 1 file changed, 44 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index cc2271b..cc6e971 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -77,7 +77,8 @@ struct ftgmac100 {
 	struct mii_bus *mii_bus;
 
 	/* Link management */
-	int old_speed;
+	int cur_speed;
+	int cur_duplex;
 	bool use_ncsi;
 
 	/* Misc */
@@ -210,16 +211,15 @@ static void ftgmac100_init_hw(struct ftgmac100 *priv)
 				 FTGMAC100_MACCR_RXDMA_EN	| \
 				 FTGMAC100_MACCR_TXMAC_EN	| \
 				 FTGMAC100_MACCR_RXMAC_EN	| \
-				 FTGMAC100_MACCR_FULLDUP	| \
 				 FTGMAC100_MACCR_CRC_APD	| \
 				 FTGMAC100_MACCR_RX_RUNT	| \
 				 FTGMAC100_MACCR_RX_BROADPKT)
 
-static void ftgmac100_start_hw(struct ftgmac100 *priv, int speed)
+static void ftgmac100_start_hw(struct ftgmac100 *priv)
 {
 	int maccr = MACCR_ENABLE_ALL;
 
-	switch (speed) {
+	switch (priv->cur_speed) {
 	default:
 	case 10:
 		break;
@@ -233,6 +233,9 @@ static void ftgmac100_start_hw(struct ftgmac100 *priv, int speed)
 		break;
 	}
 
+	if (priv->cur_duplex == DUPLEX_FULL)
+		maccr |= FTGMAC100_MACCR_FULLDUP;
+
 	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
 }
 
@@ -852,12 +855,31 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct phy_device *phydev = netdev->phydev;
+	int new_speed;
 	int ier;
 
-	if (phydev->speed == priv->old_speed)
+	/* We store "no link" as speed 0 */
+	if (!phydev->link)
+		new_speed = 0;
+	else
+		new_speed = phydev->speed;
+
+	if (phydev->speed == priv->cur_speed &&
+	    phydev->duplex == priv->cur_duplex)
 		return;
 
-	priv->old_speed = phydev->speed;
+	/* Print status if we have a link or we had one and just lost it,
+	 * don't print otherwise.
+	 */
+	if (new_speed || priv->cur_speed)
+		phy_print_status(phydev);
+
+	priv->cur_speed = new_speed;
+	priv->cur_duplex = phydev->duplex;
+
+	/* Link is down, do nothing else */
+	if (!new_speed)
+		return;
 
 	ier = ioread32(priv->base + FTGMAC100_OFFSET_IER);
 
@@ -869,7 +891,7 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 
 	netif_start_queue(netdev);
 	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv, phydev->speed);
+	ftgmac100_start_hw(priv);
 
 	/* re-enable interrupts */
 	iowrite32(ier, priv->base + FTGMAC100_OFFSET_IER);
@@ -1089,6 +1111,20 @@ static int ftgmac100_open(struct net_device *netdev)
 		goto err_irq;
 	}
 
+	/* When using NC-SI we force the speed to 100Mbit/s full duplex,
+	 *
+	 * Otherwise we leave it set to 0 (no link), the link
+	 * message from the PHY layer will handle setting it up to
+	 * something else if needed.
+	 */
+	if (priv->use_ncsi) {
+		priv->cur_duplex = DUPLEX_FULL;
+		priv->cur_speed = SPEED_100;
+	} else {
+		priv->cur_duplex = 0;
+		priv->cur_speed = 0;
+	}
+
 	priv->rx_pointer = 0;
 	priv->tx_clean_pointer = 0;
 	priv->tx_pointer = 0;
@@ -1099,7 +1135,7 @@ static int ftgmac100_open(struct net_device *netdev)
 		goto err_hw;
 
 	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv, priv->use_ncsi ? 100 : 10);
+	ftgmac100_start_hw(priv);
 
 	/* Clear stale interrupts */
 	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
-- 
2.9.3
