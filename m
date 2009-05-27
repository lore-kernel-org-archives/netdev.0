From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: use netdev stats in b44, sundance, via-rhine and via-velocity
Date: Wed, 27 May 2009 22:34:50 +0200
Message-ID: <4A1DA3EA.4030304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35048 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbZE0UfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 16:35:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use struct net_device_stats provided in struct net_device instead of
private ones.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/b44.c          |    4 +-
 drivers/net/b44.h          |    1
 drivers/net/sundance.c     |   53 ++++++++++++++++---------------
 drivers/net/via-rhine.c    |   58 +++++++++++++++++++----------------
 drivers/net/via-velocity.c |   22 ++++++-------
 drivers/net/via-velocity.h |    1
 6 files changed, 73 insertions(+), 66 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index b70b81e..36d4d37 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -782,7 +782,7 @@ static int b44_rx(struct b44 *bp, int budget)
 		drop_it:
 			b44_recycle_rx(bp, cons, bp->rx_prod);
 		drop_it_no_recycle:
-			bp->stats.rx_dropped++;
+			bp->dev->stats.rx_dropped++;
 			goto next_pkt;
 		}
 
@@ -1647,7 +1647,7 @@ static int b44_close(struct net_device *dev)
 static struct net_device_stats *b44_get_stats(struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
-	struct net_device_stats *nstat = &bp->stats;
+	struct net_device_stats *nstat = &dev->stats;
 	struct b44_hw_stats *hwstat = &bp->hw_stats;
 
 	/* Convert HW stats into netdevice stats. */
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index e678498..0443f68 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -384,7 +384,6 @@ struct b44 {
 
 	struct timer_list	timer;
 
-	struct net_device_stats	stats;
 	struct b44_hw_stats	hw_stats;
 
 	struct ssb_device	*sdev;
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index c399b19..545f81b 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -369,7 +369,6 @@ struct netdev_private {
 	struct sk_buff* tx_skbuff[TX_RING_SIZE];
         dma_addr_t tx_ring_dma;
         dma_addr_t rx_ring_dma;
-	struct net_device_stats stats;
 	struct timer_list timer;		/* Media monitoring timer. */
 	/* Frequently used values: keep some adjacent for cache effect. */
 	spinlock_t lock;
@@ -975,7 +974,7 @@ static void tx_timeout(struct net_device *dev)
 	dev->if_port = 0;
 
 	dev->trans_start = jiffies;
-	np->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 		netif_wake_queue(dev);
 	}
@@ -1123,7 +1122,7 @@ reset_tx (struct net_device *dev)
 			else
 				dev_kfree_skb (skb);
 			np->tx_skbuff[i] = NULL;
-			np->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 		}
 	}
 	np->cur_tx = np->dirty_tx = 0;
@@ -1181,15 +1180,15 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 					if (netif_msg_tx_err(np))
 						printk("%s: Transmit error status %4.4x.\n",
 							   dev->name, tx_status);
-					np->stats.tx_errors++;
+					dev->stats.tx_errors++;
 					if (tx_status & 0x10)
-						np->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 					if (tx_status & 0x08)
-						np->stats.collisions++;
+						dev->stats.collisions++;
 					if (tx_status & 0x04)
-						np->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 					if (tx_status & 0x02)
-						np->stats.tx_window_errors++;
+						dev->stats.tx_window_errors++;
 
 					/*
 					** This reset has been verified on
@@ -1313,11 +1312,15 @@ static void rx_poll(unsigned long data)
 			if (netif_msg_rx_err(np))
 				printk(KERN_DEBUG "  netdev_rx() Rx error was %8.8x.\n",
 					   frame_status);
-			np->stats.rx_errors++;
-			if (frame_status & 0x00100000) np->stats.rx_length_errors++;
-			if (frame_status & 0x00010000) np->stats.rx_fifo_errors++;
-			if (frame_status & 0x00060000) np->stats.rx_frame_errors++;
-			if (frame_status & 0x00080000) np->stats.rx_crc_errors++;
+			dev->stats.rx_errors++;
+			if (frame_status & 0x00100000)
+				dev->stats.rx_length_errors++;
+			if (frame_status & 0x00010000)
+				dev->stats.rx_fifo_errors++;
+			if (frame_status & 0x00060000)
+				dev->stats.rx_frame_errors++;
+			if (frame_status & 0x00080000)
+				dev->stats.rx_crc_errors++;
 			if (frame_status & 0x00100000) {
 				printk(KERN_WARNING "%s: Oversized Ethernet frame,"
 					   " status %8.8x.\n",
@@ -1485,22 +1488,22 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 	   the vulnerability window is very small and statistics are
 	   non-critical. */
 	/* The chip only need report frame silently dropped. */
-	np->stats.rx_missed_errors	+= ioread8(ioaddr + RxMissed);
-	np->stats.tx_packets += ioread16(ioaddr + TxFramesOK);
-	np->stats.rx_packets += ioread16(ioaddr + RxFramesOK);
-	np->stats.collisions += ioread8(ioaddr + StatsLateColl);
-	np->stats.collisions += ioread8(ioaddr + StatsMultiColl);
-	np->stats.collisions += ioread8(ioaddr + StatsOneColl);
-	np->stats.tx_carrier_errors += ioread8(ioaddr + StatsCarrierError);
+	dev->stats.rx_missed_errors	+= ioread8(ioaddr + RxMissed);
+	dev->stats.tx_packets += ioread16(ioaddr + TxFramesOK);
+	dev->stats.rx_packets += ioread16(ioaddr + RxFramesOK);
+	dev->stats.collisions += ioread8(ioaddr + StatsLateColl);
+	dev->stats.collisions += ioread8(ioaddr + StatsMultiColl);
+	dev->stats.collisions += ioread8(ioaddr + StatsOneColl);
+	dev->stats.tx_carrier_errors += ioread8(ioaddr + StatsCarrierError);
 	ioread8(ioaddr + StatsTxDefer);
 	for (i = StatsTxDefer; i <= StatsMcastRx; i++)
 		ioread8(ioaddr + i);
-	np->stats.tx_bytes += ioread16(ioaddr + TxOctetsLow);
-	np->stats.tx_bytes += ioread16(ioaddr + TxOctetsHigh) << 16;
-	np->stats.rx_bytes += ioread16(ioaddr + RxOctetsLow);
-	np->stats.rx_bytes += ioread16(ioaddr + RxOctetsHigh) << 16;
+	dev->stats.tx_bytes += ioread16(ioaddr + TxOctetsLow);
+	dev->stats.tx_bytes += ioread16(ioaddr + TxOctetsHigh) << 16;
+	dev->stats.rx_bytes += ioread16(ioaddr + RxOctetsLow);
+	dev->stats.rx_bytes += ioread16(ioaddr + RxOctetsHigh) << 16;
 
-	return &np->stats;
+	return &dev->stats;
 }
 
 static void set_rx_mode(struct net_device *dev)
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 45daba7..d3489a3 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -388,7 +388,6 @@ struct rhine_private {
 	long pioaddr;
 	struct net_device *dev;
 	struct napi_struct napi;
-	struct net_device_stats stats;
 	spinlock_t lock;
 
 	/* Frequently used values: keep some adjacent for cache effect. */
@@ -1209,7 +1208,7 @@ static void rhine_tx_timeout(struct net_device *dev)
 	enable_irq(rp->pdev->irq);
 
 	dev->trans_start = jiffies;
-	rp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
 
@@ -1237,7 +1236,7 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 			/* packet too long, drop it */
 			dev_kfree_skb(skb);
 			rp->tx_skbuff[entry] = NULL;
-			rp->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			return 0;
 		}
 
@@ -1378,29 +1377,33 @@ static void rhine_tx(struct net_device *dev)
 				printk(KERN_DEBUG "%s: Transmit error, "
 				       "Tx status %8.8x.\n",
 				       dev->name, txstatus);
-			rp->stats.tx_errors++;
-			if (txstatus & 0x0400) rp->stats.tx_carrier_errors++;
-			if (txstatus & 0x0200) rp->stats.tx_window_errors++;
-			if (txstatus & 0x0100) rp->stats.tx_aborted_errors++;
-			if (txstatus & 0x0080) rp->stats.tx_heartbeat_errors++;
+			dev->stats.tx_errors++;
+			if (txstatus & 0x0400)
+				dev->stats.tx_carrier_errors++;
+			if (txstatus & 0x0200)
+				dev->stats.tx_window_errors++;
+			if (txstatus & 0x0100)
+				dev->stats.tx_aborted_errors++;
+			if (txstatus & 0x0080)
+				dev->stats.tx_heartbeat_errors++;
 			if (((rp->quirks & rqRhineI) && txstatus & 0x0002) ||
 			    (txstatus & 0x0800) || (txstatus & 0x1000)) {
-				rp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 				rp->tx_ring[entry].tx_status = cpu_to_le32(DescOwn);
 				break; /* Keep the skb - we try again */
 			}
 			/* Transmitter restarted in 'abnormal' handler. */
 		} else {
 			if (rp->quirks & rqRhineI)
-				rp->stats.collisions += (txstatus >> 3) & 0x0F;
+				dev->stats.collisions += (txstatus >> 3) & 0x0F;
 			else
-				rp->stats.collisions += txstatus & 0x0F;
+				dev->stats.collisions += txstatus & 0x0F;
 			if (debug > 6)
 				printk(KERN_DEBUG "collisions: %1.1x:%1.1x\n",
 				       (txstatus >> 3) & 0xF,
 				       txstatus & 0xF);
-			rp->stats.tx_bytes += rp->tx_skbuff[entry]->len;
-			rp->stats.tx_packets++;
+			dev->stats.tx_bytes += rp->tx_skbuff[entry]->len;
+			dev->stats.tx_packets++;
 		}
 		/* Free the original skb. */
 		if (rp->tx_skbuff_dma[entry]) {
@@ -1455,21 +1458,24 @@ static int rhine_rx(struct net_device *dev, int limit)
 				printk(KERN_WARNING "%s: Oversized Ethernet "
 				       "frame %p vs %p.\n", dev->name,
 				       rp->rx_head_desc, &rp->rx_ring[entry]);
-				rp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			} else if (desc_status & RxErr) {
 				/* There was a error. */
 				if (debug > 2)
 					printk(KERN_DEBUG "rhine_rx() Rx "
 					       "error was %8.8x.\n",
 					       desc_status);
-				rp->stats.rx_errors++;
-				if (desc_status & 0x0030) rp->stats.rx_length_errors++;
-				if (desc_status & 0x0048) rp->stats.rx_fifo_errors++;
-				if (desc_status & 0x0004) rp->stats.rx_frame_errors++;
+				dev->stats.rx_errors++;
+				if (desc_status & 0x0030)
+					dev->stats.rx_length_errors++;
+				if (desc_status & 0x0048)
+					dev->stats.rx_fifo_errors++;
+				if (desc_status & 0x0004)
+					dev->stats.rx_frame_errors++;
 				if (desc_status & 0x0002) {
 					/* this can also be updated outside the interrupt handler */
 					spin_lock(&rp->lock);
-					rp->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 					spin_unlock(&rp->lock);
 				}
 			}
@@ -1513,8 +1519,8 @@ static int rhine_rx(struct net_device *dev, int limit)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
-			rp->stats.rx_bytes += pkt_len;
-			rp->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
 		}
 		entry = (++rp->cur_rx) % RX_RING_SIZE;
 		rp->rx_head_desc = &rp->rx_ring[entry];
@@ -1599,8 +1605,8 @@ static void rhine_error(struct net_device *dev, int intr_status)
 	if (intr_status & IntrLinkChange)
 		rhine_check_media(dev, 0);
 	if (intr_status & IntrStatsMax) {
-		rp->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
-		rp->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
+		dev->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
+		dev->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
 		clear_tally_counters(ioaddr);
 	}
 	if (intr_status & IntrTxAborted) {
@@ -1654,12 +1660,12 @@ static struct net_device_stats *rhine_get_stats(struct net_device *dev)
 	unsigned long flags;
 
 	spin_lock_irqsave(&rp->lock, flags);
-	rp->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
-	rp->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
+	dev->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
+	dev->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
 	clear_tally_counters(ioaddr);
 	spin_unlock_irqrestore(&rp->lock, flags);
 
-	return &rp->stats;
+	return &dev->stats;
 }
 
 static void rhine_set_rx_mode(struct net_device *dev)
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 754a4b1..e2a7725 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1385,7 +1385,7 @@ static void velocity_free_td_ring(struct velocity_info *vptr)
 
 static int velocity_rx_srv(struct velocity_info *vptr, int status)
 {
-	struct net_device_stats *stats = &vptr->stats;
+	struct net_device_stats *stats = &vptr->dev->stats;
 	int rd_curr = vptr->rx.curr;
 	int works = 0;
 
@@ -1519,7 +1519,7 @@ static inline void velocity_iph_realign(struct velocity_info *vptr,
 static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 {
 	void (*pci_action)(struct pci_dev *, dma_addr_t, size_t, int);
-	struct net_device_stats *stats = &vptr->stats;
+	struct net_device_stats *stats = &vptr->dev->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 	struct rx_desc *rd = &(vptr->rx.ring[idx]);
 	int pkt_len = le16_to_cpu(rd->rdesc0.len) & 0x3fff;
@@ -1532,7 +1532,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	}
 
 	if (rd->rdesc0.RSR & RSR_MAR)
-		vptr->stats.multicast++;
+		stats->multicast++;
 
 	skb = rd_info->skb;
 
@@ -1634,7 +1634,7 @@ static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
 	int idx;
 	int works = 0;
 	struct velocity_td_info *tdinfo;
-	struct net_device_stats *stats = &vptr->stats;
+	struct net_device_stats *stats = &vptr->dev->stats;
 
 	for (qnum = 0; qnum < vptr->tx.numq; qnum++) {
 		for (idx = vptr->tx.tail[qnum]; vptr->tx.used[qnum] > 0;
@@ -2324,22 +2324,22 @@ static struct net_device_stats *velocity_get_stats(struct net_device *dev)
 
 	/* If the hardware is down, don't touch MII */
 	if(!netif_running(dev))
-		return &vptr->stats;
+		return &dev->stats;
 
 	spin_lock_irq(&vptr->lock);
 	velocity_update_hw_mibs(vptr);
 	spin_unlock_irq(&vptr->lock);
 
-	vptr->stats.rx_packets = vptr->mib_counter[HW_MIB_ifRxAllPkts];
-	vptr->stats.rx_errors = vptr->mib_counter[HW_MIB_ifRxErrorPkts];
-	vptr->stats.rx_length_errors = vptr->mib_counter[HW_MIB_ifInRangeLengthErrors];
+	dev->stats.rx_packets = vptr->mib_counter[HW_MIB_ifRxAllPkts];
+	dev->stats.rx_errors = vptr->mib_counter[HW_MIB_ifRxErrorPkts];
+	dev->stats.rx_length_errors = vptr->mib_counter[HW_MIB_ifInRangeLengthErrors];
 
 //  unsigned long   rx_dropped;     /* no space in linux buffers    */
-	vptr->stats.collisions = vptr->mib_counter[HW_MIB_ifTxEtherCollisions];
+	dev->stats.collisions = vptr->mib_counter[HW_MIB_ifTxEtherCollisions];
 	/* detailed rx_errors: */
 //  unsigned long   rx_length_errors;
 //  unsigned long   rx_over_errors;     /* receiver ring buff overflow  */
-	vptr->stats.rx_crc_errors = vptr->mib_counter[HW_MIB_ifRxPktCRCE];
+	dev->stats.rx_crc_errors = vptr->mib_counter[HW_MIB_ifRxPktCRCE];
 //  unsigned long   rx_frame_errors;    /* recv'd frame alignment error */
 //  unsigned long   rx_fifo_errors;     /* recv'r fifo overrun      */
 //  unsigned long   rx_missed_errors;   /* receiver missed packet   */
@@ -2347,7 +2347,7 @@ static struct net_device_stats *velocity_get_stats(struct net_device *dev)
 	/* detailed tx_errors */
 //  unsigned long   tx_fifo_errors;
 
-	return &vptr->stats;
+	return &dev->stats;
 }
 
 
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index ea43e18..4cd3f6c 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1503,7 +1503,6 @@ struct velocity_info {
 
 	struct pci_dev *pdev;
 	struct net_device *dev;
-	struct net_device_stats stats;
 
 	struct vlan_group    *vlgrp;
 	u8 ip_addr[4];
