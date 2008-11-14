From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for 2.6.28-rc
Date: Fri, 14 Nov 2008 18:25:43 -0500
Message-ID: <20081114232543.GA2276@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:58363 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbYKNXZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 18:25:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/atl1e/atl1e_hw.c   |    4 ----
 drivers/net/atlx/atl1.c        |   17 +++--------------
 drivers/net/gianfar.c          |   15 ++++++++-------
 drivers/net/phy/mdio_bus.c     |    2 +-
 drivers/net/ucc_geth_ethtool.c |    6 +++---
 5 files changed, 15 insertions(+), 29 deletions(-)

Andy Fleming (1):
      gianfar: Fix DMA unmap invocations

Anton Vorontsov (1):
      net/ucc_geth: Fix oops in uec_get_ethtool_stats()

J. K. Cliburn (2):
      atl1e: fix broken multicast by removing unnecessary crc inversion
      atl1: Do not enumerate options unsupported by chip

Lennert Buytenhek (1):
      phylib: fix premature freeing of struct mii_bus

diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 8cbc1b5..4a77006 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -163,9 +163,6 @@ int atl1e_read_mac_addr(struct atl1e_hw *hw)
  * atl1e_hash_mc_addr
  *  purpose
  *      set hash value for a multicast address
- *      hash calcu processing :
- *          1. calcu 32bit CRC for multicast address
- *          2. reverse crc with MSB to LSB
  */
 u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
 {
@@ -174,7 +171,6 @@ u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
 	int i;
 
 	crc32 = ether_crc_le(6, mc_addr);
-	crc32 = ~crc32;
 	for (i = 0; i < 32; i++)
 		value |= (((crc32 >> i) & 1) << (31 - i));
 
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 246d92b..aef403d 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3404,14 +3404,8 @@ static void atl1_get_wol(struct net_device *netdev,
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
-	wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
+	wol->supported = WAKE_MAGIC;
 	wol->wolopts = 0;
-	if (adapter->wol & ATLX_WUFC_EX)
-		wol->wolopts |= WAKE_UCAST;
-	if (adapter->wol & ATLX_WUFC_MC)
-		wol->wolopts |= WAKE_MCAST;
-	if (adapter->wol & ATLX_WUFC_BC)
-		wol->wolopts |= WAKE_BCAST;
 	if (adapter->wol & ATLX_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
 	return;
@@ -3422,15 +3416,10 @@ static int atl1_set_wol(struct net_device *netdev,
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
-	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+	if (wol->wolopts & (WAKE_PHY | WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
+		WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
 	adapter->wol = 0;
-	if (wol->wolopts & WAKE_UCAST)
-		adapter->wol |= ATLX_WUFC_EX;
-	if (wol->wolopts & WAKE_MCAST)
-		adapter->wol |= ATLX_WUFC_MC;
-	if (wol->wolopts & WAKE_BCAST)
-		adapter->wol |= ATLX_WUFC_BC;
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= ATLX_WUFC_MAG;
 	return 0;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 83a5cb6..c4af949 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1407,6 +1407,10 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 		if (bdp->status & TXBD_DEF)
 			dev->stats.collisions++;
 
+		/* Unmap the DMA memory */
+		dma_unmap_single(&priv->dev->dev, bdp->bufPtr,
+				bdp->length, DMA_TO_DEVICE);
+
 		/* Free the sk buffer associated with this TxBD */
 		dev_kfree_skb_irq(priv->tx_skbuff[priv->skb_dirtytx]);
 
@@ -1666,6 +1670,9 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 		skb = priv->rx_skbuff[priv->skb_currx];
 
+		dma_unmap_single(&priv->dev->dev, bdp->bufPtr,
+				priv->rx_buffer_size, DMA_FROM_DEVICE);
+
 		/* We drop the frame if we failed to allocate a new buffer */
 		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
 				 bdp->status & RXBD_ERR)) {
@@ -1674,14 +1681,8 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 			if (unlikely(!newskb))
 				newskb = skb;
 
-			if (skb) {
-				dma_unmap_single(&priv->dev->dev,
-						bdp->bufPtr,
-						priv->rx_buffer_size,
-						DMA_FROM_DEVICE);
-
+			if (skb)
 				dev_kfree_skb_any(skb);
-			}
 		} else {
 			/* Increment the number of packets */
 			dev->stats.rx_packets++;
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index d0ed1ef..536bda1 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -136,7 +136,7 @@ void mdiobus_unregister(struct mii_bus *bus)
 	BUG_ON(bus->state != MDIOBUS_REGISTERED);
 	bus->state = MDIOBUS_UNREGISTERED;
 
-	device_unregister(&bus->dev);
+	device_del(&bus->dev);
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 85f38a6..68a7f54 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -323,17 +323,17 @@ static void uec_get_ethtool_stats(struct net_device *netdev,
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE) {
 		base = (u32 __iomem *)&ugeth->ug_regs->tx64;
 		for (i = 0; i < UEC_HW_STATS_LEN; i++)
-			data[j++] = (u64)in_be32(&base[i]);
+			data[j++] = in_be32(&base[i]);
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
 		base = (u32 __iomem *)ugeth->p_tx_fw_statistics_pram;
 		for (i = 0; i < UEC_TX_FW_STATS_LEN; i++)
-			data[j++] = (u64)in_be32(&base[i]);
+			data[j++] = base ? in_be32(&base[i]) : 0;
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX) {
 		base = (u32 __iomem *)ugeth->p_rx_fw_statistics_pram;
 		for (i = 0; i < UEC_RX_FW_STATS_LEN; i++)
-			data[j++] = (u64)in_be32(&base[i]);
+			data[j++] = base ? in_be32(&base[i]) : 0;
 	}
 }
 
