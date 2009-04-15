From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 07/12] fec: refactor init function
Date: Wed, 15 Apr 2009 13:32:20 +0200
Message-ID: <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49312 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759755AbZDOLgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:36:01 -0400
In-Reply-To: <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_enet_init() does the hardware initialisation and then calls
fec_restart() which does the same initialisation again, so we
can safely remove the initialisation from fec_enet_init().

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   39 ++++-----------------------------------
 1 files changed, 4 insertions(+), 35 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index b72df48..a3037ab 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1616,10 +1616,6 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	fep->hwp = (void __iomem *)dev->base_addr;
 	fep->netdev = dev;
 
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
-
 	/* Set the Ethernet address */
 #ifdef CONFIG_M5272
 	fec_get_mac(dev);
@@ -1641,11 +1637,6 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	fep->rx_bd_base = cbd_base;
 	fep->tx_bd_base = cbd_base + RX_RING_SIZE;
 
-	fep->dirty_tx = fep->cur_tx = fep->tx_bd_base;
-	fep->cur_rx = fep->rx_bd_base;
-
-	fep->skb_cur = fep->skb_dirty = 0;
-
 	/* Initialize the receive buffer descriptors. */
 	bdp = fep->rx_bd_base;
 	for (i=0; i<FEC_ENET_RX_PAGES; i++) {
@@ -1689,25 +1680,9 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	bdp--;
 	bdp->cbd_sc |= BD_SC_WRAP;
 
-	/* Set receive and transmit descriptor base */
-	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
-	writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX_RING_SIZE,
-			fep->hwp + FEC_X_DES_START);
-
 #ifdef HAVE_mii_link_interrupt
 	fec_request_mii_intr(dev);
 #endif
-
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
-	writel(2, fep->hwp + FEC_ECNTRL);
-	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
-#ifndef CONFIG_M5272
-	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
-#endif
-
 	/* The FEC Ethernet specific entries in the device structure */
 	dev->open = fec_enet_open;
 	dev->hard_start_xmit = fec_enet_start_xmit;
@@ -1720,21 +1695,11 @@ int __init fec_enet_init(struct net_device *dev, int index)
 		mii_cmds[i].mii_next = &mii_cmds[i+1];
 	mii_free = mii_cmds;
 
-	/* setup MII interface */
-	writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
-	writel(0, fep->hwp + FEC_X_CNTRL);
-
 	/* Set MII speed to 2.5 MHz */
 	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
 					/ 2500000) / 2) & 0x3F) << 1;
-	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	fec_restart(dev, 0);
 
-	/* Clear and enable interrupts */
-	writel(0xffc00000, fep->hwp + FEC_IEVENT);
-	writel(FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII,
-			fep->hwp + FEC_IMASK);
-
 	/* Queue up command to detect the PHY and initialize the
 	 * remainder of the interface.
 	 */
@@ -1769,6 +1734,10 @@ fec_restart(struct net_device *dev, int duplex)
 	/* Reset all multicast.	*/
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+#ifndef CONFIG_M5272
+	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
+#endif
 
 	/* Set maximum receive buffer size. */
 	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
-- 
1.6.2.1

