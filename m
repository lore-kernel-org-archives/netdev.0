From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 11/13] ftgmac100: Rework MAC reset and init
Date: Wed,  5 Apr 2017 12:28:51 +1000
Message-ID: <20170405022853.8238-12-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48215 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755122AbdDECaX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:30:23 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HW requires a full MAC reset when changing the speed.

Additionally the Aspeed documentation spells out that the
MAC needs to be reset twice with a 10us interval.

We thus move the speed setting and top level reset code
into a new ftgmac100_reset_and_config_mac() function which
handles both. Move the ring pointers initialization there
too in order to reflect the HW change.

Also reduce the timeout for the MAC reset as it shouldn't
take more than 300 clock cycles according to the doc.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 98 +++++++++++++++++++-------------
 1 file changed, 59 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 61f02bf..3adfb92 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -112,27 +112,64 @@ static void ftgmac100_txdma_normal_prio_start_polling(struct ftgmac100 *priv)
 	iowrite32(1, priv->base + FTGMAC100_OFFSET_NPTXPD);
 }
 
-static int ftgmac100_reset_hw(struct ftgmac100 *priv)
+static int ftgmac100_reset_mac(struct ftgmac100 *priv, u32 maccr)
 {
 	struct net_device *netdev = priv->netdev;
 	int i;
 
 	/* NOTE: reset clears all registers */
-	iowrite32(FTGMAC100_MACCR_SW_RST, priv->base + FTGMAC100_OFFSET_MACCR);
-	for (i = 0; i < 5; i++) {
+	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
+	iowrite32(maccr | FTGMAC100_MACCR_SW_RST,
+		  priv->base + FTGMAC100_OFFSET_MACCR);
+	for (i = 0; i < 50; i++) {
 		unsigned int maccr;
 
 		maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
 		if (!(maccr & FTGMAC100_MACCR_SW_RST))
 			return 0;
 
-		udelay(1000);
+		udelay(1);
 	}
 
-	netdev_err(netdev, "software reset failed\n");
+	netdev_err(netdev, "Hardware reset failed\n");
 	return -EIO;
 }
 
+static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
+{
+	u32 maccr = 0;
+
+	switch (priv->cur_speed) {
+	case SPEED_10:
+	case 0: /* no link */
+		break;
+
+	case SPEED_100:
+		maccr |= FTGMAC100_MACCR_FAST_MODE;
+		break;
+
+	case SPEED_1000:
+		maccr |= FTGMAC100_MACCR_GIGA_MODE;
+		break;
+	default:
+		netdev_err(priv->netdev, "Unknown speed %d !\n",
+			   priv->cur_speed);
+		break;
+	}
+
+	/* (Re)initialize the queue pointers */
+	priv->rx_pointer = 0;
+	priv->tx_clean_pointer = 0;
+	priv->tx_pointer = 0;
+	priv->tx_pending = 0;
+
+	/* The doc says reset twice with 10us interval */
+	if (ftgmac100_reset_mac(priv, maccr))
+		return -EIO;
+	usleep_range(10, 1000);
+	return ftgmac100_reset_mac(priv, maccr);
+}
+
 static void ftgmac100_set_mac(struct ftgmac100 *priv, const unsigned char *mac)
 {
 	unsigned int maddr = mac[0] << 8 | mac[1];
@@ -208,35 +245,28 @@ static void ftgmac100_init_hw(struct ftgmac100 *priv)
 	ftgmac100_set_mac(priv, priv->netdev->dev_addr);
 }
 
-#define MACCR_ENABLE_ALL	(FTGMAC100_MACCR_TXDMA_EN	| \
-				 FTGMAC100_MACCR_RXDMA_EN	| \
-				 FTGMAC100_MACCR_TXMAC_EN	| \
-				 FTGMAC100_MACCR_RXMAC_EN	| \
-				 FTGMAC100_MACCR_CRC_APD	| \
-				 FTGMAC100_MACCR_RX_RUNT	| \
-				 FTGMAC100_MACCR_RX_BROADPKT)
-
 static void ftgmac100_start_hw(struct ftgmac100 *priv)
 {
-	int maccr = MACCR_ENABLE_ALL;
+	u32 maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
 
-	switch (priv->cur_speed) {
-	default:
-	case 10:
-		break;
+	/* Keep the original GMAC and FAST bits */
+	maccr &= (FTGMAC100_MACCR_FAST_MODE | FTGMAC100_MACCR_GIGA_MODE);
 
-	case 100:
-		maccr |= FTGMAC100_MACCR_FAST_MODE;
-		break;
-
-	case 1000:
-		maccr |= FTGMAC100_MACCR_GIGA_MODE;
-		break;
-	}
+	/* Add all the main enable bits */
+	maccr |= FTGMAC100_MACCR_TXDMA_EN	|
+		 FTGMAC100_MACCR_RXDMA_EN	|
+		 FTGMAC100_MACCR_TXMAC_EN	|
+		 FTGMAC100_MACCR_RXMAC_EN	|
+		 FTGMAC100_MACCR_CRC_APD	|
+		 FTGMAC100_MACCR_PHY_LINK_LEVEL	|
+		 FTGMAC100_MACCR_RX_RUNT	|
+		 FTGMAC100_MACCR_RX_BROADPKT;
 
+	/* Add other bits as needed */
 	if (priv->cur_duplex == DUPLEX_FULL)
 		maccr |= FTGMAC100_MACCR_FULLDUP;
 
+	/* Hit the HW */
 	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
 }
 
@@ -1154,7 +1184,7 @@ static void ftgmac100_reset_task(struct work_struct *work)
 
 	/* Stop and reset the MAC */
 	ftgmac100_stop_hw(priv);
-	err = ftgmac100_reset_hw(priv);
+	err = ftgmac100_reset_and_config_mac(priv);
 	if (err) {
 		/* Not much we can do ... it might come back... */
 		netdev_err(netdev, "attempting to continue...\n");
@@ -1163,12 +1193,6 @@ static void ftgmac100_reset_task(struct work_struct *work)
 	/* Free all rx and tx buffers */
 	ftgmac100_free_buffers(priv);
 
-	/* The ring pointers have been reset in HW, reflect this here */
-	priv->rx_pointer = 0;
-	priv->tx_clean_pointer = 0;
-	priv->tx_pointer = 0;
-	priv->tx_pending = 0;
-
 	/* Setup everything again and restart chip */
 	ftgmac100_init_all(priv, true);
 
@@ -1207,12 +1231,8 @@ static int ftgmac100_open(struct net_device *netdev)
 		priv->cur_speed = 0;
 	}
 
-	priv->rx_pointer = 0;
-	priv->tx_clean_pointer = 0;
-	priv->tx_pointer = 0;
-	priv->tx_pending = 0;
-
-	err = ftgmac100_reset_hw(priv);
+	/* Reset the hardware */
+	err = ftgmac100_reset_and_config_mac(priv);
 	if (err)
 		goto err_hw;
 
-- 
2.9.3
