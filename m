From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH net-next-2.6] sungem: Use net_device's internal stats
Date: Thu, 27 Jan 2011 19:54:12 +0000
Message-ID: <20110127195412.GA25216@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:49367 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287Ab1A0TyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 14:54:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use net_device_stats instance from the struct net_device.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sungem.c |   58 +++++++++++++++++++++++++-------------------------
 drivers/net/sungem.h |    1 -
 2 files changed, 29 insertions(+), 30 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 1c5408f..c1a3448 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -320,28 +320,28 @@ static int gem_txmac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_s
 
 	if (txmac_stat & MAC_TXSTAT_URUN) {
 		netdev_err(dev, "TX MAC xmit underrun\n");
-		gp->net_stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 	}
 
 	if (txmac_stat & MAC_TXSTAT_MPE) {
 		netdev_err(dev, "TX MAC max packet size error\n");
-		gp->net_stats.tx_errors++;
+		dev->stats.tx_errors++;
 	}
 
 	/* The rest are all cases of one of the 16-bit TX
 	 * counters expiring.
 	 */
 	if (txmac_stat & MAC_TXSTAT_NCE)
-		gp->net_stats.collisions += 0x10000;
+		dev->stats.collisions += 0x10000;
 
 	if (txmac_stat & MAC_TXSTAT_ECE) {
-		gp->net_stats.tx_aborted_errors += 0x10000;
-		gp->net_stats.collisions += 0x10000;
+		dev->stats.tx_aborted_errors += 0x10000;
+		dev->stats.collisions += 0x10000;
 	}
 
 	if (txmac_stat & MAC_TXSTAT_LCE) {
-		gp->net_stats.tx_aborted_errors += 0x10000;
-		gp->net_stats.collisions += 0x10000;
+		dev->stats.tx_aborted_errors += 0x10000;
+		dev->stats.collisions += 0x10000;
 	}
 
 	/* We do not keep track of MAC_TXSTAT_FCE and
@@ -469,20 +469,20 @@ static int gem_rxmac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_s
 		u32 smac = readl(gp->regs + MAC_SMACHINE);
 
 		netdev_err(dev, "RX MAC fifo overflow smac[%08x]\n", smac);
-		gp->net_stats.rx_over_errors++;
-		gp->net_stats.rx_fifo_errors++;
+		dev->stats.rx_over_errors++;
+		dev->stats.rx_fifo_errors++;
 
 		ret = gem_rxmac_reset(gp);
 	}
 
 	if (rxmac_stat & MAC_RXSTAT_ACE)
-		gp->net_stats.rx_frame_errors += 0x10000;
+		dev->stats.rx_frame_errors += 0x10000;
 
 	if (rxmac_stat & MAC_RXSTAT_CCE)
-		gp->net_stats.rx_crc_errors += 0x10000;
+		dev->stats.rx_crc_errors += 0x10000;
 
 	if (rxmac_stat & MAC_RXSTAT_LCE)
-		gp->net_stats.rx_length_errors += 0x10000;
+		dev->stats.rx_length_errors += 0x10000;
 
 	/* We do not track MAC_RXSTAT_FCE and MAC_RXSTAT_VCE
 	 * events.
@@ -594,7 +594,7 @@ static int gem_abnormal_irq(struct net_device *dev, struct gem *gp, u32 gem_stat
 		if (netif_msg_rx_err(gp))
 			printk(KERN_DEBUG "%s: no buffer for rx frame\n",
 				gp->dev->name);
-		gp->net_stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	}
 
 	if (gem_status & GREG_STAT_RXTAGERR) {
@@ -602,7 +602,7 @@ static int gem_abnormal_irq(struct net_device *dev, struct gem *gp, u32 gem_stat
 		if (netif_msg_rx_err(gp))
 			printk(KERN_DEBUG "%s: corrupt rx tag framing\n",
 				gp->dev->name);
-		gp->net_stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 		goto do_reset;
 	}
@@ -684,7 +684,7 @@ static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_st
 				break;
 		}
 		gp->tx_skbs[entry] = NULL;
-		gp->net_stats.tx_bytes += skb->len;
+		dev->stats.tx_bytes += skb->len;
 
 		for (frag = 0; frag <= skb_shinfo(skb)->nr_frags; frag++) {
 			txd = &gp->init_block->txd[entry];
@@ -696,7 +696,7 @@ static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_st
 			entry = NEXT_TX(entry);
 		}
 
-		gp->net_stats.tx_packets++;
+		dev->stats.tx_packets++;
 		dev_kfree_skb_irq(skb);
 	}
 	gp->tx_old = entry;
@@ -738,6 +738,7 @@ static __inline__ void gem_post_rxds(struct gem *gp, int limit)
 
 static int gem_rx(struct gem *gp, int work_to_do)
 {
+	struct net_device *dev = gp->dev;
 	int entry, drops, work_done = 0;
 	u32 done;
 	__sum16 csum;
@@ -782,15 +783,15 @@ static int gem_rx(struct gem *gp, int work_to_do)
 
 		len = (status & RXDCTRL_BUFSZ) >> 16;
 		if ((len < ETH_ZLEN) || (status & RXDCTRL_BAD)) {
-			gp->net_stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (len < ETH_ZLEN)
-				gp->net_stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (len & RXDCTRL_BAD)
-				gp->net_stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 
 			/* We'll just return it to GEM. */
 		drop_it:
-			gp->net_stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			goto next;
 		}
 
@@ -843,8 +844,8 @@ static int gem_rx(struct gem *gp, int work_to_do)
 
 		netif_receive_skb(skb);
 
-		gp->net_stats.rx_packets++;
-		gp->net_stats.rx_bytes += len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
 
 	next:
 		entry = NEXT_RX(entry);
@@ -2472,7 +2473,6 @@ static int gem_resume(struct pci_dev *pdev)
 static struct net_device_stats *gem_get_stats(struct net_device *dev)
 {
 	struct gem *gp = netdev_priv(dev);
-	struct net_device_stats *stats = &gp->net_stats;
 
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
@@ -2481,17 +2481,17 @@ static struct net_device_stats *gem_get_stats(struct net_device *dev)
 	 * so we shield against this
 	 */
 	if (gp->running) {
-		stats->rx_crc_errors += readl(gp->regs + MAC_FCSERR);
+		dev->stats.rx_crc_errors += readl(gp->regs + MAC_FCSERR);
 		writel(0, gp->regs + MAC_FCSERR);
 
-		stats->rx_frame_errors += readl(gp->regs + MAC_AERR);
+		dev->stats.rx_frame_errors += readl(gp->regs + MAC_AERR);
 		writel(0, gp->regs + MAC_AERR);
 
-		stats->rx_length_errors += readl(gp->regs + MAC_LERR);
+		dev->stats.rx_length_errors += readl(gp->regs + MAC_LERR);
 		writel(0, gp->regs + MAC_LERR);
 
-		stats->tx_aborted_errors += readl(gp->regs + MAC_ECOLL);
-		stats->collisions +=
+		dev->stats.tx_aborted_errors += readl(gp->regs + MAC_ECOLL);
+		dev->stats.collisions +=
 			(readl(gp->regs + MAC_ECOLL) +
 			 readl(gp->regs + MAC_LCOLL));
 		writel(0, gp->regs + MAC_ECOLL);
@@ -2501,7 +2501,7 @@ static struct net_device_stats *gem_get_stats(struct net_device *dev)
 	spin_unlock(&gp->tx_lock);
 	spin_unlock_irq(&gp->lock);
 
-	return &gp->net_stats;
+	return &dev->stats;
 }
 
 static int gem_set_mac_address(struct net_device *dev, void *addr)
diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index 1990546..ede0178 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -994,7 +994,6 @@ struct gem {
 	u32			status;
 
 	struct napi_struct	napi;
-	struct net_device_stats net_stats;
 
 	int			tx_fifo_sz;
 	int			rx_fifo_sz;
-- 
1.7.3.4

