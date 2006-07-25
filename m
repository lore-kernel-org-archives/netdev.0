From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] via-rhine: NAPI support
Date: Mon, 24 Jul 2006 18:18:06 -0700
Message-ID: <20060724181806.44d56284@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1750 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932373AbWGYBSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 21:18:14 -0400
To: Roger Luethi <rl@hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add NAPI support to the via-rhine driver so that it can handle higher speeds
and doesn't get overloaded by interrupts as easily.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 drivers/net/via-rhine.c |   75 +++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 63 insertions(+), 12 deletions(-)

90258ab7e4c90d183cfa32156cd2ff48aca03974
--- skge.orig/drivers/net/via-rhine.c
+++ skge/drivers/net/via-rhine.c
@@ -30,8 +30,8 @@
 */
 
 #define DRV_NAME	"via-rhine"
-#define DRV_VERSION	"1.4.0"
-#define DRV_RELDATE	"June-27-2006"
+#define DRV_VERSION	"1.4.1"
+#define DRV_RELDATE	"July-24-2006"
 
 
 /* A few user-configurable values.
@@ -63,7 +63,11 @@ static const int multicast_filter_limit 
    There are no ill effects from too-large receive rings. */
 #define TX_RING_SIZE	16
 #define TX_QUEUE_LEN	10	/* Limit ring entries actually used. */
+#ifdef CONFIG_VIA_RHINE_NAPI
+#define RX_RING_SIZE	64
+#else
 #define RX_RING_SIZE	16
+#endif
 
 
 /* Operational parameters that usually are not changed. */
@@ -396,7 +400,7 @@ static void rhine_tx_timeout(struct net_
 static int  rhine_start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
 static void rhine_tx(struct net_device *dev);
-static void rhine_rx(struct net_device *dev);
+static int rhine_rx(struct net_device *dev, int limit);
 static void rhine_error(struct net_device *dev, int intr_status);
 static void rhine_set_rx_mode(struct net_device *dev);
 static struct net_device_stats *rhine_get_stats(struct net_device *dev);
@@ -564,6 +568,32 @@ static void rhine_poll(struct net_device
 }
 #endif
 
+#ifdef CONFIG_VIA_RHINE_NAPI
+static int rhine_napipoll(struct net_device *dev, int *budget)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	void __iomem *ioaddr = rp->base;
+	int done, limit = min(dev->quota, *budget);
+
+	done = rhine_rx(dev, limit);
+	*budget -= done;
+	dev->quota -= done;
+
+	if (done < limit) {
+		netif_rx_complete(dev);
+
+		iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
+			  IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
+			  IntrTxDone | IntrTxError | IntrTxUnderrun |
+			  IntrPCIErr | IntrStatsMax | IntrLinkChange,
+			  ioaddr + IntrEnable);
+		return 0;
+	}
+	else
+		return 1;
+}
+#endif
+
 static void rhine_hw_init(struct net_device *dev, long pioaddr)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -744,6 +774,10 @@ static int __devinit rhine_init_one(stru
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = rhine_poll;
 #endif
+#ifdef CONFIG_VIA_RHINE_NAPI
+	dev->poll = rhine_napipoll;
+	dev->weight = 64;
+#endif
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
@@ -1165,6 +1199,7 @@ static void rhine_tx_timeout(struct net_
 	dev->trans_start = jiffies;
 	rp->stats.tx_errors++;
 	netif_wake_queue(dev);
+	netif_poll_enable(dev);
 }
 
 static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
@@ -1268,8 +1303,18 @@ static irqreturn_t rhine_interrupt(int i
 			       dev->name, intr_status);
 
 		if (intr_status & (IntrRxDone | IntrRxErr | IntrRxDropped |
-		    IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf))
-			rhine_rx(dev);
+				   IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf)) {
+#ifdef CONFIG_VIA_RHINE_NAPI
+			iowrite16(IntrTxAborted |
+				  IntrTxDone | IntrTxError | IntrTxUnderrun |
+				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
+				  ioaddr + IntrEnable);
+
+			netif_rx_schedule(dev);
+#else
+			rhine_rx(dev, RX_RING_SIZE);
+#endif
+		}
 
 		if (intr_status & (IntrTxErrSummary | IntrTxDone)) {
 			if (intr_status & IntrTxErrSummary) {
@@ -1367,13 +1412,12 @@ static void rhine_tx(struct net_device *
 	spin_unlock(&rp->lock);
 }
 
-/* This routine is logically part of the interrupt handler, but isolated
-   for clarity and better register allocation. */
-static void rhine_rx(struct net_device *dev)
+/* Process up to limit frames from receive ring */
+static int rhine_rx(struct net_device *dev, int limit)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	int count;
 	int entry = rp->cur_rx % RX_RING_SIZE;
-	int boguscnt = rp->dirty_rx + RX_RING_SIZE - rp->cur_rx;
 
 	if (debug > 4) {
 		printk(KERN_DEBUG "%s: rhine_rx(), entry %d status %8.8x.\n",
@@ -1382,16 +1426,18 @@ static void rhine_rx(struct net_device *
 	}
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
-	while (!(rp->rx_head_desc->rx_status & cpu_to_le32(DescOwn))) {
+	for (count = 0; count < limit; ++count) {
 		struct rx_desc *desc = rp->rx_head_desc;
 		u32 desc_status = le32_to_cpu(desc->rx_status);
 		int data_size = desc_status >> 16;
 
+		if (desc_status & DescOwn)
+			break;
+
 		if (debug > 4)
 			printk(KERN_DEBUG "rhine_rx() status is %8.8x.\n",
 			       desc_status);
-		if (--boguscnt < 0)
-			break;
+
 		if ((desc_status & (RxWholePkt | RxErr)) != RxWholePkt) {
 			if ((desc_status & RxWholePkt) != RxWholePkt) {
 				printk(KERN_WARNING "%s: Oversized Ethernet "
@@ -1460,7 +1506,11 @@ static void rhine_rx(struct net_device *
 						 PCI_DMA_FROMDEVICE);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
+#ifdef CONFIG_VIA_RHINE_NAPI
+			netif_receive_skb(skb);
+#else
 			netif_rx(skb);
+#endif
 			dev->last_rx = jiffies;
 			rp->stats.rx_bytes += pkt_len;
 			rp->stats.rx_packets++;
@@ -1487,6 +1537,8 @@ static void rhine_rx(struct net_device *
 		}
 		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
 	}
+
+	return count;
 }
 
 /*
@@ -1776,6 +1828,7 @@ static int rhine_close(struct net_device
 	spin_lock_irq(&rp->lock);
 
 	netif_stop_queue(dev);
+	netif_poll_disable(dev);
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, "
--- skge.orig/drivers/net/Kconfig
+++ skge/drivers/net/Kconfig
@@ -1724,6 +1724,20 @@ config VIA_RHINE_MMIO
 
 	  If unsure, say Y.
 
+config VIA_RHINE_NAPI
+	bool "Use Rx Polling (NAPI)"
+	depends on VIA_RHINE
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card.
+
+	  If your estimated Rx load is 10kpps or more, or if the card will be
+	  deployed on potentially unfriendly networks (e.g. in a firewall),
+	  then say Y here.
+
+	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
+	  information.
+
 config LAN_SAA9730
 	bool "Philips SAA9730 Ethernet support (EXPERIMENTAL)"
 	depends on NET_PCI && EXPERIMENTAL && MIPS
