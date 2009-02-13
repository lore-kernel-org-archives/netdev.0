From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/6] mv643xx_eth: implement ethtool rx/tx ring size query and resizing
Date: Fri, 13 Feb 2009 01:07:37 +0100
Message-ID: <20090213000737.GM17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43003 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbZBMAHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:07:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the mp->default_[rt]x_ring_size variables to ->[rt]x_ring_size,
allow them to be read via the standard ethtool ->get_ringparam() op,
and add a ->set_ringparam() op to allow resizing them at run time.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   63 ++++++++++++++++++++++++++++++++++++++------
 1 files changed, 54 insertions(+), 9 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4a92d99..0fcaca5 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -286,6 +286,9 @@ struct mv643xx_eth_shared_private {
 #define TX_BW_CONTROL_OLD_LAYOUT	1
 #define TX_BW_CONTROL_NEW_LAYOUT	2
 
+static int mv643xx_eth_open(struct net_device *dev);
+static int mv643xx_eth_stop(struct net_device *dev);
+
 
 /* per-port *****************************************************************/
 struct mib_counters {
@@ -385,7 +388,7 @@ struct mv643xx_eth_private {
 	/*
 	 * RX state.
 	 */
-	int default_rx_ring_size;
+	int rx_ring_size;
 	unsigned long rx_desc_sram_addr;
 	int rx_desc_sram_size;
 	int rxq_count;
@@ -395,7 +398,7 @@ struct mv643xx_eth_private {
 	/*
 	 * TX state.
 	 */
-	int default_tx_ring_size;
+	int tx_ring_size;
 	unsigned long tx_desc_sram_addr;
 	int tx_desc_sram_size;
 	int txq_count;
@@ -907,7 +910,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 
 		if (skb != NULL) {
 			if (skb_queue_len(&mp->rx_recycle) <
-					mp->default_rx_ring_size &&
+					mp->rx_ring_size &&
 			    skb_recycle_check(skb, mp->skb_size +
 					dma_get_cache_alignment() - 1))
 				__skb_queue_head(&mp->rx_recycle, skb);
@@ -1485,6 +1488,46 @@ mv643xx_eth_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	return 0;
 }
 
+static void
+mv643xx_eth_get_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	er->rx_max_pending = 4096;
+	er->tx_max_pending = 4096;
+	er->rx_mini_max_pending = 0;
+	er->rx_jumbo_max_pending = 0;
+
+	er->rx_pending = mp->rx_ring_size;
+	er->tx_pending = mp->tx_ring_size;
+	er->rx_mini_pending = 0;
+	er->rx_jumbo_pending = 0;
+}
+
+static int
+mv643xx_eth_set_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	if (er->rx_mini_pending || er->rx_jumbo_pending)
+		return -EINVAL;
+
+	mp->rx_ring_size = er->rx_pending < 4096 ? er->rx_pending : 4096;
+	mp->tx_ring_size = er->tx_pending < 4096 ? er->tx_pending : 4096;
+
+	if (netif_running(dev)) {
+		mv643xx_eth_stop(dev);
+		if (mv643xx_eth_open(dev)) {
+			dev_printk(KERN_ERR, &dev->dev,
+				   "fatal error on re-opening device after "
+				   "ring param change\n");
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
 static void mv643xx_eth_get_strings(struct net_device *dev,
 				    uint32_t stringset, uint8_t *data)
 {
@@ -1541,6 +1584,8 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_link		= mv643xx_eth_get_link,
 	.get_coalesce		= mv643xx_eth_get_coalesce,
 	.set_coalesce		= mv643xx_eth_set_coalesce,
+	.get_ringparam		= mv643xx_eth_get_ringparam,
+	.set_ringparam		= mv643xx_eth_set_ringparam,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
@@ -1732,7 +1777,7 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 
 	rxq->index = index;
 
-	rxq->rx_ring_size = mp->default_rx_ring_size;
+	rxq->rx_ring_size = mp->rx_ring_size;
 
 	rxq->rx_desc_count = 0;
 	rxq->rx_curr_desc = 0;
@@ -1832,7 +1877,7 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	txq->index = index;
 
-	txq->tx_ring_size = mp->default_tx_ring_size;
+	txq->tx_ring_size = mp->tx_ring_size;
 
 	txq->tx_desc_count = 0;
 	txq->tx_curr_desc = 0;
@@ -2597,17 +2642,17 @@ static void set_params(struct mv643xx_eth_private *mp,
 	else
 		uc_addr_get(mp, dev->dev_addr);
 
-	mp->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
+	mp->rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
 	if (pd->rx_queue_size)
-		mp->default_rx_ring_size = pd->rx_queue_size;
+		mp->rx_ring_size = pd->rx_queue_size;
 	mp->rx_desc_sram_addr = pd->rx_sram_addr;
 	mp->rx_desc_sram_size = pd->rx_sram_size;
 
 	mp->rxq_count = pd->rx_queue_count ? : 1;
 
-	mp->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
+	mp->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 	if (pd->tx_queue_size)
-		mp->default_tx_ring_size = pd->tx_queue_size;
+		mp->tx_ring_size = pd->tx_queue_size;
 	mp->tx_desc_sram_addr = pd->tx_sram_addr;
 	mp->tx_desc_sram_size = pd->tx_sram_size;
 
-- 
1.5.6.4
