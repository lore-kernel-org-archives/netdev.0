From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] acenic: use netdev_alloc_skb_ip_align
Date: Fri, 22 Jul 2011 09:31:12 -0700
Message-ID: <20110722093112.4caa39e7@nehalam.ftrdhcpuser.net>
References: <1311312533.3886.2.camel@edumazet-laptop>
	<20110721.232501.1187843432422240228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50698 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186Ab1GVQbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 12:31:09 -0400
In-Reply-To: <20110721.232501.1187843432422240228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take Eric's patch one step further.
Use netdev_skb_ip_align to do setup the receive skb.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/acenic.c	2011-07-22 09:15:26.103853123 -0700
+++ b/drivers/net/acenic.c	2011-07-22 09:28:36.343823394 -0700
@@ -1502,13 +1502,13 @@ static int __devinit ace_init(struct net
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
@@ -1584,9 +1584,10 @@ static void ace_watchdog(struct net_devi
 }
 
 
-static void ace_tasklet(unsigned long dev)
+static void ace_tasklet(unsigned long arg)
 {
-	struct ace_private *ap = netdev_priv((struct net_device *)dev);
+	struct net_device *dev = (struct net_device *) arg;
+	struct ace_private *ap = netdev_priv(dev);
 	int cur_size;
 
 	cur_size = atomic_read(&ap->cur_rx_bufs);
@@ -1595,7 +1596,7 @@ static void ace_tasklet(unsigned long de
 #ifdef DEBUG
 		printk("refilling buffers (current %i)\n", cur_size);
 #endif
-		ace_load_std_rx_ring(ap, RX_RING_SIZE - cur_size);
+		ace_load_std_rx_ring(dev, RX_RING_SIZE - cur_size);
 	}
 
 	if (ap->version >= 2) {
@@ -1606,7 +1607,7 @@ static void ace_tasklet(unsigned long de
 			printk("refilling mini buffers (current %i)\n",
 			       cur_size);
 #endif
-			ace_load_mini_rx_ring(ap, RX_MINI_SIZE - cur_size);
+			ace_load_mini_rx_ring(dev, RX_MINI_SIZE - cur_size);
 		}
 	}
 
@@ -1616,7 +1617,7 @@ static void ace_tasklet(unsigned long de
 #ifdef DEBUG
 		printk("refilling jumbo buffers (current %i)\n", cur_size);
 #endif
-		ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE - cur_size);
+		ace_load_jumbo_rx_ring(dev, RX_JUMBO_SIZE - cur_size);
 	}
 	ap->tasklet_pending = 0;
 }
@@ -1642,8 +1643,9 @@ static void ace_dump_trace(struct ace_pr
  * done only before the device is enabled, thus no interrupts are
  * generated and by the interrupt handler/tasklet handler.
  */
-static void ace_load_std_rx_ring(struct ace_private *ap, int nr_bufs)
+static void ace_load_std_rx_ring(struct net_device *dev, int nr_bufs)
 {
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
@@ -1657,11 +1659,10 @@ static void ace_load_std_rx_ring(struct
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = dev_alloc_skb(ACE_STD_BUFSIZE + NET_IP_ALIGN);
+		skb = netdev_alloc_skb_ip_align(dev, ACE_STD_BUFSIZE);
 		if (!skb)
 			break;
 
-		skb_reserve(skb, NET_IP_ALIGN);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
 				       ACE_STD_BUFSIZE,
@@ -1705,8 +1706,9 @@ static void ace_load_std_rx_ring(struct
 }
 
 
-static void ace_load_mini_rx_ring(struct ace_private *ap, int nr_bufs)
+static void ace_load_mini_rx_ring(struct net_device *dev, int nr_bufs)
 {
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
@@ -1718,11 +1720,10 @@ static void ace_load_mini_rx_ring(struct
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = dev_alloc_skb(ACE_MINI_BUFSIZE + NET_IP_ALIGN);
+		skb = netdev_alloc_skb_ip_align(dev, ACE_MINI_BUFSIZE);
 		if (!skb)
 			break;
 
-		skb_reserve(skb, NET_IP_ALIGN);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
 				       ACE_MINI_BUFSIZE,
@@ -1762,8 +1763,9 @@ static void ace_load_mini_rx_ring(struct
  * Load the jumbo rx ring, this may happen at any time if the MTU
  * is changed to a value > 1500.
  */
-static void ace_load_jumbo_rx_ring(struct ace_private *ap, int nr_bufs)
+static void ace_load_jumbo_rx_ring(struct net_device *dev, int nr_bufs)
 {
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	short i, idx;
 
@@ -1774,11 +1776,10 @@ static void ace_load_jumbo_rx_ring(struc
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = dev_alloc_skb(ACE_JUMBO_BUFSIZE + NET_IP_ALIGN);
+		skb = netdev_alloc_skb_ip_align(dev, ACE_JUMBO_BUFSIZE);
 		if (!skb)
 			break;
 
-		skb_reserve(skb, NET_IP_ALIGN);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
 				       ACE_JUMBO_BUFSIZE,
@@ -2196,7 +2197,7 @@ static irqreturn_t ace_interrupt(int irq
 #ifdef DEBUG
 				printk("low on std buffers %i\n", cur_size);
 #endif
-				ace_load_std_rx_ring(ap,
+				ace_load_std_rx_ring(dev,
 						     RX_RING_SIZE - cur_size);
 			} else
 				run_tasklet = 1;
@@ -2212,7 +2213,8 @@ static irqreturn_t ace_interrupt(int irq
 					printk("low on mini buffers %i\n",
 					       cur_size);
 #endif
-					ace_load_mini_rx_ring(ap, RX_MINI_SIZE - cur_size);
+					ace_load_mini_rx_ring(dev,
+							      RX_MINI_SIZE - cur_size);
 				} else
 					run_tasklet = 1;
 			}
@@ -2228,7 +2230,8 @@ static irqreturn_t ace_interrupt(int irq
 					printk("low on jumbo buffers %i\n",
 					       cur_size);
 #endif
-					ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE - cur_size);
+					ace_load_jumbo_rx_ring(dev,
+							       RX_JUMBO_SIZE - cur_size);
 				} else
 					run_tasklet = 1;
 			}
@@ -2267,7 +2270,7 @@ static int ace_open(struct net_device *d
 
 	if (ap->jumbo &&
 	    !test_and_set_bit(0, &ap->jumbo_refill_busy))
-		ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE);
+		ace_load_jumbo_rx_ring(dev, RX_JUMBO_SIZE);
 
 	if (dev->flags & IFF_PROMISC) {
 		cmd.evt = C_SET_PROMISC_MODE;
@@ -2575,7 +2578,7 @@ static int ace_change_mtu(struct net_dev
 			       "support\n", dev->name);
 			ap->jumbo = 1;
 			if (!test_and_set_bit(0, &ap->jumbo_refill_busy))
-				ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE);
+				ace_load_jumbo_rx_ring(dev, RX_JUMBO_SIZE);
 			ace_set_rxtx_parms(dev, 1);
 		}
 	} else {
--- a/drivers/net/acenic.h	2011-07-22 09:23:55.087833975 -0700
+++ b/drivers/net/acenic.h	2011-07-22 09:24:19.575833054 -0700
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
