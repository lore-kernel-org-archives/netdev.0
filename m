From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/7][MV643XX_ETH] various cleanups
Date: Mon, 17 Mar 2008 20:17:55 +0100
Message-ID: <20080317191755.GC17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37938 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbYCQTR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:17:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various cleanups:
- Remove unused MV643XX_DEFAULT_[RT]X_QUEUE_SIZE definitions.
- Remove ETH_TARGET enum -- it isn't used anywhere in the driver,
  and isn't even valid for non-mv643xx chip models, as those use
  different MBUS target IDs.
- Clean up comment and control flow in mv643xx_eth_change_mtu().
- Use mp->dev instead of mp->mii.dev in mv643xx_eth_tx_timeout_task().
- Make mv643xx_eth_free_tx_descs() static.
- Remove overzealous NULL check in mv643xx_eth_start_xmit().
- Use symbolic NETDEV_TX_* constants in mv643xx_eth_start_xmit().

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -63,20 +63,6 @@
 #define MV643XX_TX_FAST_REFILL
 #undef	MV643XX_COAL
 
-/*
- * Number of RX / TX descriptors on RX / TX rings.
- * Note that allocating RX descriptors is done by allocating the RX
- * ring AND a preallocated RX buffers (skb's) for each descriptor.
- * The TX descriptors only allocates the TX descriptors ring,
- * with no pre allocated TX buffers (skb's are allocated by higher layers.
- */
-
-/* Default TX ring size is 1000 descriptors */
-#define MV643XX_DEFAULT_TX_QUEUE_SIZE 1000
-
-/* Default RX ring size is 400 descriptors */
-#define MV643XX_DEFAULT_RX_QUEUE_SIZE 400
-
 #define MV643XX_TX_COAL 100
 #ifdef MV643XX_COAL
 #define MV643XX_RX_COAL 100
@@ -434,14 +420,6 @@ typedef enum _eth_func_ret_status {
 	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
 } ETH_FUNC_RET_STATUS;
 
-typedef enum _eth_target {
-	ETH_TARGET_DRAM,
-	ETH_TARGET_DEVICE,
-	ETH_TARGET_CBS,
-	ETH_TARGET_PCI0,
-	ETH_TARGET_PCI1
-} ETH_TARGET;
-
 /* These are for big-endian machines.  Little endian needs different
  * definitions.
  */
@@ -615,7 +593,6 @@ static unsigned int mv643xx_eth_port_dis
 static unsigned int mv643xx_eth_port_disable_rx(unsigned int port_num);
 static int mv643xx_eth_open(struct net_device *);
 static int mv643xx_eth_stop(struct net_device *);
-static int mv643xx_eth_change_mtu(struct net_device *, int);
 static void eth_port_init_mac_tables(unsigned int eth_port_num);
 #ifdef MV643XX_NAPI
 static int mv643xx_poll(struct napi_struct *napi, int budget);
@@ -659,18 +636,19 @@ static int mv643xx_eth_change_mtu(struct
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
+	if (!netif_running(dev))
+		return 0;
+
 	/*
-	 * Stop then re-open the interface. This will allocate RX skb's with
-	 * the new MTU.
-	 * There is a possible danger that the open will not successed, due
-	 * to memory is full, which might fail the open function.
+	 * Stop and then re-open the interface. This will allocate RX
+	 * skbs of the new MTU.
+	 * There is a possible danger that the open will not succeed,
+	 * due to memory being full, which might fail the open function.
 	 */
-	if (netif_running(dev)) {
-		mv643xx_eth_stop(dev);
-		if (mv643xx_eth_open(dev))
-			printk(KERN_ERR
-				"%s: Fatal error on opening device\n",
-				dev->name);
+	mv643xx_eth_stop(dev);
+	if (mv643xx_eth_open(dev)) {
+		printk(KERN_ERR "%s: Fatal error on opening device\n",
+			dev->name);
 	}
 
 	return 0;
@@ -826,7 +804,7 @@ static void mv643xx_eth_tx_timeout_task(
 {
 	struct mv643xx_private *mp = container_of(ugly, struct mv643xx_private,
 						  tx_timeout_task);
-	struct net_device *dev = mp->mii.dev; /* yuck */
+	struct net_device *dev = mp->dev;
 
 	if (!netif_running(dev))
 		return;
@@ -845,7 +823,7 @@ static void mv643xx_eth_tx_timeout_task(
  *
  * If force is non-zero, frees uncompleted descriptors as well
  */
-int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
+static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	struct eth_tx_desc *desc;
@@ -1739,13 +1717,12 @@ static int mv643xx_eth_start_xmit(struct
 	unsigned long flags;
 
 	BUG_ON(netif_queue_stopped(dev));
-	BUG_ON(skb == NULL);
 
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
 		stats->tx_dropped++;
 		printk(KERN_DEBUG "%s: failed to linearize tiny "
 				"unaligned fragment\n", dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock_irqsave(&mp->lock, flags);
@@ -1754,7 +1731,7 @@ static int mv643xx_eth_start_xmit(struct
 		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&mp->lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	eth_tx_submit_descs_for_skb(mp, skb);
@@ -1767,7 +1744,7 @@ static int mv643xx_eth_start_xmit(struct
 
 	spin_unlock_irqrestore(&mp->lock, flags);
 
-	return 0;		/* success */
+	return NETDEV_TX_OK;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
