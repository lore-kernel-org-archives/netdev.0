From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/13] acenic: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:40 -0700
Message-ID: <20080416233757.925572770@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org, linux-acenic@sunsite.dk
To: Jeff Garzik <jgarzik@pobox.com>,
	Jes Sorensen <jes@trained-monkey.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43817 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729AbYDPXv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:51:29 -0400
Content-Disposition: inline; filename=acenic
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb. This sets skb->dev and allows arch specific
allocation.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/acenic.c	2008-04-07 10:36:16.000000000 -0700
+++ b/drivers/net/acenic.c	2008-04-07 12:36:50.000000000 -0700
@@ -1514,13 +1514,13 @@ static int __devinit ace_init(struct net
 	 * firmware to wipe the ring without re-initializing it.
 	 */
 	if (!test_and_set_bit(0, &ap->std_refill_busy))
-		ace_load_std_rx_ring(ap, RX_RING_SIZE);
+		ace_load_std_rx_ring(dev, RX_RING_SIZE);
 	else
 		printk(KERN_ERR "%s: Someone is busy refilling the RX ring\n",
 		       ap->name);
 	if (ap->version >= 2) {
 		if (!test_and_set_bit(0, &ap->mini_refill_busy))
-			ace_load_mini_rx_ring(ap, RX_MINI_SIZE);
+			ace_load_mini_rx_ring(dev, RX_MINI_SIZE);
 		else
 			printk(KERN_ERR "%s: Someone is busy refilling "
 			       "the RX mini ring\n", ap->name);
@@ -1607,7 +1607,7 @@ static void ace_tasklet(unsigned long de
 #ifdef DEBUG
 		printk("refilling buffers (current %i)\n", cur_size);
 #endif
-		ace_load_std_rx_ring(ap, RX_RING_SIZE - cur_size);
+		ace_load_std_rx_ring(dev, RX_RING_SIZE - cur_size);
 	}
 
 	if (ap->version >= 2) {
@@ -1618,7 +1618,7 @@ static void ace_tasklet(unsigned long de
 			printk("refilling mini buffers (current %i)\n",
 			       cur_size);
 #endif
-			ace_load_mini_rx_ring(ap, RX_MINI_SIZE - cur_size);
+			ace_load_mini_rx_ring(dev, RX_MINI_SIZE - cur_size);
 		}
 	}
 
@@ -1628,7 +1628,7 @@ static void ace_tasklet(unsigned long de
 #ifdef DEBUG
 		printk("refilling jumbo buffers (current %i)\n", cur_size);
 #endif
-		ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE - cur_size);
+		ace_load_jumbo_rx_ring(dev, RX_JUMBO_SIZE - cur_size);
 	}
 	ap->tasklet_pending = 0;
 }
@@ -1654,12 +1654,12 @@ static void ace_dump_trace(struct ace_pr
  * done only before the device is enabled, thus no interrupts are
  * generated and by the interrupt handler/tasklet handler.
  */
-static void ace_load_std_rx_ring(struct ace_private *ap, int nr_bufs)
+static void ace_load_std_rx_ring(struct net_device *dev, int nr_bufs)
 {
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
-
 	prefetchw(&ap->cur_rx_bufs);
 
 	idx = ap->rx_std_skbprd;
@@ -1669,7 +1669,7 @@ static void ace_load_std_rx_ring(struct 
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_STD_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
+		skb = netdev_alloc_skb(dev, ACE_STD_BUFSIZE + NET_IP_ALIGN);
 		if (!skb)
 			break;
 
@@ -1717,8 +1717,9 @@ static void ace_load_std_rx_ring(struct 
 }
 
 
-static void ace_load_mini_rx_ring(struct ace_private *ap, int nr_bufs)
+static void ace_load_mini_rx_ring(struct net_device *dev, int nr_bufs)
 {
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
@@ -1730,7 +1731,7 @@ static void ace_load_mini_rx_ring(struct
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_MINI_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
+		skb = netdev_alloc_skb(dev, ACE_MINI_BUFSIZE + NET_IP_ALIGN);
 		if (!skb)
 			break;
 
@@ -1774,8 +1775,9 @@ static void ace_load_mini_rx_ring(struct
  * Load the jumbo rx ring, this may happen at any time if the MTU
  * is changed to a value > 1500.
  */
-static void ace_load_jumbo_rx_ring(struct ace_private *ap, int nr_bufs)
+static void ace_load_jumbo_rx_ring(struct net_device *dev, int nr_bufs)
 {
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
@@ -1786,7 +1788,7 @@ static void ace_load_jumbo_rx_ring(struc
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_JUMBO_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
+		skb = netdev_alloc_skb(dev, ACE_JUMBO_BUFSIZE + NET_IP_ALIGN);
 		if (!skb)
 			break;
 
@@ -2214,7 +2216,7 @@ static irqreturn_t ace_interrupt(int irq
 #ifdef DEBUG
 				printk("low on std buffers %i\n", cur_size);
 #endif
-				ace_load_std_rx_ring(ap,
+				ace_load_std_rx_ring(dev,
 						     RX_RING_SIZE - cur_size);
 			} else
 				run_tasklet = 1;
@@ -2230,7 +2232,8 @@ static irqreturn_t ace_interrupt(int irq
 					printk("low on mini buffers %i\n",
 					       cur_size);
 #endif
-					ace_load_mini_rx_ring(ap, RX_MINI_SIZE - cur_size);
+					ace_load_mini_rx_ring(dev,
+							      RX_MINI_SIZE - cur_size);
 				} else
 					run_tasklet = 1;
 			}
@@ -2246,7 +2249,8 @@ static irqreturn_t ace_interrupt(int irq
 					printk("low on jumbo buffers %i\n",
 					       cur_size);
 #endif
-					ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE - cur_size);
+					ace_load_jumbo_rx_ring(dev,
+							       RX_JUMBO_SIZE - cur_size);
 				} else
 					run_tasklet = 1;
 			}
@@ -2303,7 +2307,7 @@ static int ace_open(struct net_device *d
 
 	if (ap->jumbo &&
 	    !test_and_set_bit(0, &ap->jumbo_refill_busy))
-		ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE);
+		ace_load_jumbo_rx_ring(dev, RX_JUMBO_SIZE);
 
 	if (dev->flags & IFF_PROMISC) {
 		cmd.evt = C_SET_PROMISC_MODE;
@@ -2621,7 +2625,7 @@ static int ace_change_mtu(struct net_dev
 			       "support\n", dev->name);
 			ap->jumbo = 1;
 			if (!test_and_set_bit(0, &ap->jumbo_refill_busy))
-				ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE);
+				ace_load_jumbo_rx_ring(dev, RX_JUMBO_SIZE);
 			ace_set_rxtx_parms(dev, 1);
 		}
 	} else {
--- a/drivers/net/acenic.h	2008-04-07 10:36:16.000000000 -0700
+++ b/drivers/net/acenic.h	2008-04-07 12:36:50.000000000 -0700
@@ -766,9 +766,9 @@ static inline void ace_unmask_irq(struct
  * Prototypes
  */
 static int ace_init(struct net_device *dev);
-static void ace_load_std_rx_ring(struct ace_private *ap, int nr_bufs);
-static void ace_load_mini_rx_ring(struct ace_private *ap, int nr_bufs);
-static void ace_load_jumbo_rx_ring(struct ace_private *ap, int nr_bufs);
+static void ace_load_std_rx_ring(struct net_device *dev, int nr_bufs);
+static void ace_load_mini_rx_ring(struct net_device *dev, int nr_bufs);
+static void ace_load_jumbo_rx_ring(struct net_device *dev, int nr_bufs);
 static irqreturn_t ace_interrupt(int irq, void *dev_id);
 static int ace_load_firmware(struct net_device *dev);
 static int ace_open(struct net_device *dev);

-- 

