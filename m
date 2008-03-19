From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/4] mv643xx_eth: configurable t_clk
Date: Wed, 19 Mar 2008 08:50:06 +0100
Message-ID: <20080319075006.GD5010@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47619 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758772AbYCSURc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:17:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make t_clk configurable via platform device data (with the current
hardcoded value, 133 MHz, being the default), as it varies across
different chip families.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -519,6 +519,8 @@ struct mv643xx_shared_private {
 	spinlock_t phy_lock;
 
 	u32 win_protect;
+
+	unsigned int t_clk;
 };
 
 struct mv643xx_private {
@@ -1129,7 +1131,6 @@ static irqreturn_t mv643xx_eth_int_handl
  *
  * INPUT:
  *	struct mv643xx_private *mp	Ethernet port
- *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
  *	unsigned int delay		Delay in usec
  *
  * OUTPUT:
@@ -1140,10 +1141,10 @@ static irqreturn_t mv643xx_eth_int_handl
  *
  */
 static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
-					unsigned int t_clk, unsigned int delay)
+					unsigned int delay)
 {
 	unsigned int port_num = mp->port_num;
-	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
+	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
 	wrl(mp, SDMA_CONFIG_REG(port_num),
@@ -1168,7 +1169,6 @@ static unsigned int eth_port_set_rx_coal
  *
  * INPUT:
  *	struct mv643xx_private *mp	Ethernet port
- *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
  *	unsigned int delay		Delay in uSeconds
  *
  * OUTPUT:
@@ -1179,9 +1179,9 @@ static unsigned int eth_port_set_rx_coal
  *
  */
 static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
-					unsigned int t_clk, unsigned int delay)
+					unsigned int delay)
 {
-	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
+	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set TX Coalescing mechanism */
 	wrl(mp, TX_FIFO_URGENT_THRESHOLD_REG(mp->port_num), coal << 4);
@@ -1423,11 +1423,11 @@ static int mv643xx_eth_open(struct net_d
 
 #ifdef MV643XX_COAL
 	mp->rx_int_coal =
-		eth_port_set_rx_coal(mp, 133000000, MV643XX_RX_COAL);
+		eth_port_set_rx_coal(mp, MV643XX_RX_COAL);
 #endif
 
 	mp->tx_int_coal =
-		eth_port_set_tx_coal(mp, 133000000, MV643XX_TX_COAL);
+		eth_port_set_tx_coal(mp, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
 	wrl(mp, INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
@@ -2063,6 +2063,7 @@ static int mv643xx_eth_shared_probe(stru
 		goto out_free;
 
 	spin_lock_init(&msp->phy_lock);
+	msp->t_clk = (pd != NULL) ? pd->t_clk : 133000000;
 
 	platform_set_drvdata(pdev, msp);
 
Index: linux-2.6.25-rc6/include/linux/mv643xx_eth.h
===================================================================
--- linux-2.6.25-rc6.orig/include/linux/mv643xx_eth.h
+++ linux-2.6.25-rc6/include/linux/mv643xx_eth.h
@@ -17,6 +17,7 @@
 
 struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
+	unsigned int	t_clk;
 };
 
 struct mv643xx_eth_platform_data {


----
