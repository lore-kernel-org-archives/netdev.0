From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH v4] ether1: Use net_device_stats from struct net_device
Date: Thu, 19 Aug 2010 08:15:04 +0200
Message-ID: <1282198504-4009-1-git-send-email-tklauser@distanz.ch>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
Cc: linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Carpenter <error27@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:32776 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab0HSGPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 02:15:07 -0400
In-Reply-To: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the ether1_priv struct. As the new
ndo_get_stats function would just return dev->stats we can omit it. This
patch also removes an incorrect memset of the stats on open.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/arm/ether1.c |   34 ++++++++++++----------------------
 drivers/net/arm/ether1.h |    1 -
 2 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
index b17ab51..b00781c 100644
--- a/drivers/net/arm/ether1.c
+++ b/drivers/net/arm/ether1.c
@@ -68,7 +68,6 @@ static int ether1_open(struct net_device *dev);
 static int ether1_sendpacket(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t ether1_interrupt(int irq, void *dev_id);
 static int ether1_close(struct net_device *dev);
-static struct net_device_stats *ether1_getstats(struct net_device *dev);
 static void ether1_setmulticastlist(struct net_device *dev);
 static void ether1_timeout(struct net_device *dev);
 
@@ -649,8 +648,6 @@ ether1_open (struct net_device *dev)
 	if (request_irq(dev->irq, ether1_interrupt, 0, "ether1", dev))
 		return -EAGAIN;
 
-	memset (&priv(dev)->stats, 0, sizeof (struct net_device_stats));
-
 	if (ether1_init_for_open (dev)) {
 		free_irq (dev->irq, dev);
 		return -EAGAIN;
@@ -673,7 +670,7 @@ ether1_timeout(struct net_device *dev)
 	if (ether1_init_for_open (dev))
 		printk (KERN_ERR "%s: unable to restart interface\n", dev->name);
 
-	priv(dev)->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
 
@@ -802,21 +799,21 @@ again:
 
 	while (nop.nop_status & STAT_COMPLETE) {
 		if (nop.nop_status & STAT_OK) {
-			priv(dev)->stats.tx_packets ++;
-			priv(dev)->stats.collisions += (nop.nop_status & STAT_COLLISIONS);
+			dev->stats.tx_packets++;
+			dev->stats.collisions += (nop.nop_status & STAT_COLLISIONS);
 		} else {
-			priv(dev)->stats.tx_errors ++;
+			dev->stats.tx_errors++;
 
 			if (nop.nop_status & STAT_COLLAFTERTX)
-				priv(dev)->stats.collisions ++;
+				dev->stats.collisions++;
 			if (nop.nop_status & STAT_NOCARRIER)
-				priv(dev)->stats.tx_carrier_errors ++;
+				dev->stats.tx_carrier_errors++;
 			if (nop.nop_status & STAT_TXLOSTCTS)
 				printk (KERN_WARNING "%s: cts lost\n", dev->name);
 			if (nop.nop_status & STAT_TXSLOWDMA)
-				priv(dev)->stats.tx_fifo_errors ++;
+				dev->stats.tx_fifo_errors++;
 			if (nop.nop_status & STAT_COLLEXCESSIVE)
-				priv(dev)->stats.collisions += 16;
+				dev->stats.collisions += 16;
 		}
 
 		if (nop.nop_link == caddr) {
@@ -879,13 +876,13 @@ ether1_recv_done (struct net_device *dev)
 
 				skb->protocol = eth_type_trans (skb, dev);
 				netif_rx (skb);
-				priv(dev)->stats.rx_packets ++;
+				dev->stats.rx_packets++;
 			} else
-				priv(dev)->stats.rx_dropped ++;
+				dev->stats.rx_dropped++;
 		} else {
 			printk(KERN_WARNING "%s: %s\n", dev->name,
 				(rbd.rbd_status & RBD_EOF) ? "oversized packet" : "acnt not valid");
-			priv(dev)->stats.rx_dropped ++;
+			dev->stats.rx_dropped++;
 		}
 
 		nexttail = ether1_readw(dev, priv(dev)->rx_tail, rfd_t, rfd_link, NORMALIRQS);
@@ -939,7 +936,7 @@ ether1_interrupt (int irq, void *dev_id)
 				printk (KERN_WARNING "%s: RU went not ready: RU suspended\n", dev->name);
 				ether1_writew(dev, SCB_CMDRXRESUME, SCB_ADDR, scb_t, scb_command, NORMALIRQS);
 				writeb(CTRL_CA, REG_CONTROL);
-				priv(dev)->stats.rx_dropped ++;	/* we suspended due to lack of buffer space */
+				dev->stats.rx_dropped++;	/* we suspended due to lack of buffer space */
 			} else
 				printk(KERN_WARNING "%s: RU went not ready: %04X\n", dev->name,
 					ether1_readw(dev, SCB_ADDR, scb_t, scb_status, NORMALIRQS));
@@ -962,12 +959,6 @@ ether1_close (struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *
-ether1_getstats (struct net_device *dev)
-{
-	return &priv(dev)->stats;
-}
-
 /*
  * Set or clear the multicast filter for this adaptor.
  * num_addrs == -1	Promiscuous mode, receive all packets.
@@ -994,7 +985,6 @@ static const struct net_device_ops ether1_netdev_ops = {
 	.ndo_open		= ether1_open,
 	.ndo_stop		= ether1_close,
 	.ndo_start_xmit		= ether1_sendpacket,
-	.ndo_get_stats		= ether1_getstats,
 	.ndo_set_multicast_list	= ether1_setmulticastlist,
 	.ndo_tx_timeout		= ether1_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/arm/ether1.h b/drivers/net/arm/ether1.h
index c8a4b23..3a5830a 100644
--- a/drivers/net/arm/ether1.h
+++ b/drivers/net/arm/ether1.h
@@ -38,7 +38,6 @@
 
 struct ether1_priv {
 	void __iomem *base;
-	struct net_device_stats stats;
 	unsigned int tx_link;
 	unsigned int tx_head;
 	volatile unsigned int tx_tail;
-- 
1.7.0.4

