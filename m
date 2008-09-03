From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 08/17] mv643xx_eth: get rid of compile-time configurable transmit checksumming
Date: Wed,  3 Sep 2008 14:29:35 +0200
Message-ID: <1220444984-20150-9-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52898 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752412AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of the mv643xx_eth-internal MV643XX_ETH_CHECKSUM_OFFLOAD_TX
compile-time option.  Using transmit checksumming is the sane default,
and anyone wanting to disable it should use ethtool(8) instead of
recompiling their kernels.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   25 +++----------------------
 1 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3831a8b..53cfd01 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -57,15 +57,8 @@
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.3";
 
-#define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MV643XX_ETH_TX_FAST_REFILL
 
-#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-#define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
-#else
-#define MAX_DESCS_PER_SKB	1
-#endif
-
 /*
  * Registers shared between all ports.
  */
@@ -464,7 +457,7 @@ static void __txq_maybe_wake(struct tx_queue *txq)
 	 */
 	BUG_ON(txq->index != mp->txq_primary);
 
-	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_DESCS_PER_SKB)
+	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
 		netif_wake_queue(mp->dev);
 }
 
@@ -855,7 +848,7 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	txq = mp->txq + mp->txq_primary;
 
-	if (txq->tx_ring_size - txq->tx_desc_count < MAX_DESCS_PER_SKB) {
+	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
 		spin_unlock_irqrestore(&mp->lock, flags);
 		if (txq->index == mp->txq_primary && net_ratelimit())
 			dev_printk(KERN_ERR, &dev->dev,
@@ -873,7 +866,7 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		int entries_left;
 
 		entries_left = txq->tx_ring_size - txq->tx_desc_count;
-		if (entries_left < MAX_DESCS_PER_SKB)
+		if (entries_left < MAX_SKB_FRAGS + 1)
 			netif_stop_queue(dev);
 	}
 
@@ -2656,14 +2649,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->watchdog_timeo = 2 * HZ;
 	dev->base_addr = 0;
 
-#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-	/*
-	 * Zero copy can only work if we use Discovery II memory. Else, we will
-	 * have to map the buffers to ISA memory which is only 16 MB
-	 */
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM;
-#endif
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -2677,12 +2664,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev_printk(KERN_NOTICE, &dev->dev, "port %d with MAC address %s\n",
 		   mp->port_num, print_mac(mac, dev->dev_addr));
 
-	if (dev->features & NETIF_F_SG)
-		dev_printk(KERN_NOTICE, &dev->dev, "scatter/gather enabled\n");
-
-	if (dev->features & NETIF_F_IP_CSUM)
-		dev_printk(KERN_NOTICE, &dev->dev, "tx checksum offload\n");
-
 	if (mp->tx_desc_sram_size > 0)
 		dev_printk(KERN_NOTICE, &dev->dev, "configured with sram\n");
 
-- 
1.5.6.4

