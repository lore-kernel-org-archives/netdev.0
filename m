From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] NAPI for 8139too
Date: Fri, 17 Oct 2003 15:39:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031017153934.6d48e578.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Modified the 2.6.0-test7 driver to use NAPI.  It reduces the CPU load
when getting excessive network traffic but doesn't change normal performance.
I get the same numbers with netperf for send and receive as before, but
when running a pktgen DOS style flood the CPU usage goes from 90+% down
to 75% and the system is still usable.

No problems found so far, but still needs more testing because
some of the error paths might break.

diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	Fri Oct 17 15:32:35 2003
+++ b/drivers/net/8139too.c	Fri Oct 17 15:32:35 2003
@@ -92,7 +92,7 @@
 */
 
 #define DRV_NAME	"8139too"
-#define DRV_VERSION	"0.9.26"
+#define DRV_VERSION	"0.9.27"
 
 
 #include <linux/config.h>
@@ -159,9 +159,6 @@
 static int media[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static int max_interrupt_work = 20;
-
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
@@ -589,13 +586,11 @@
 MODULE_LICENSE("GPL");
 
 MODULE_PARM (multicast_filter_limit, "i");
-MODULE_PARM (max_interrupt_work, "i");
 MODULE_PARM (media, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM (full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM (debug, "i");
 MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
 MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
-MODULE_PARM_DESC (max_interrupt_work, "8139too maximum events handled per interrupt");
 MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
 
@@ -618,6 +613,7 @@
 static void __set_rx_mode (struct net_device *dev);
 static void rtl8139_hw_start (struct net_device *dev);
 static struct ethtool_ops rtl8139_ethtool_ops;
+static int rtl8139_poll(struct net_device *dev, int *budget);
 
 #ifdef USE_IO_OPS
 
@@ -963,6 +959,8 @@
 	/* The Rtl8139-specific entries in the device structure. */
 	dev->open = rtl8139_open;
 	dev->hard_start_xmit = rtl8139_start_xmit;
+	dev->poll = rtl8139_poll;
+	dev->weight = 16;
 	dev->stop = rtl8139_close;
 	dev->get_stats = rtl8139_get_stats;
 	dev->set_multicast_list = rtl8139_set_rx_mode;
@@ -1879,24 +1877,28 @@
 #endif
 }
 
-static void rtl8139_rx_interrupt (struct net_device *dev,
-				  struct rtl8139_private *tp, void *ioaddr)
+/*
+ * NAPI poll routine.
+ */
+static int rtl8139_poll(struct net_device *dev, int *budget)
 {
+	struct rtl8139_private *tp = dev->priv;
+	void *ioaddr = tp->mmio_addr;
 	unsigned char *rx_ring;
 	u16 cur_rx;
+	int rx, status;
+	unsigned long flags;
 
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
-
+	spin_lock_irqsave(&tp->lock, flags);
+ rescan:
 	rx_ring = tp->rx_ring;
 	cur_rx = tp->cur_rx;
-
-	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
+	rx = 0;
+	DPRINTK ("%s: In rtl8139_rx_poll(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
-
+	
 	while ((RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		int ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
@@ -1943,18 +1945,13 @@
 		    (rx_size < 8) ||
 		    (!(rx_status & RxStatusOK))) {
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
-			return;
+			goto err;
 		}
 
-		/* Malloc up new buffer, compatible with net-2e. */
-		/* Omit the four octet CRC from the length. */
-
-		/* TODO: consider allocating skb's outside of
-		 * interrupt context, both to speed interrupt processing,
-		 * and also to reduce the chances of having to
-		 * drop packets here under memory pressure.
-		 */
+		/* Drop lock so we can copy data with interrupts enabled. */
+		spin_unlock_irqrestore(&tp->lock, flags);
 
+		/* Omit the four octet CRC from the length. */
 		skb = dev_alloc_skb (pkt_size + 2);
 		if (skb) {
 			skb->dev = dev;
@@ -1964,22 +1961,35 @@
 			skb_put (skb, pkt_size);
 
 			skb->protocol = eth_type_trans (skb, dev);
-			netif_rx (skb);
+			netif_receive_skb(skb);
 			dev->last_rx = jiffies;
 			tp->stats.rx_bytes += pkt_size;
 			tp->stats.rx_packets++;
 		} else {
-			printk (KERN_WARNING
-				"%s: Memory squeeze, dropping packet.\n",
-				dev->name);
+			/* Since this board has a small fixed rx_ring,
+			 * it is better to toss packets than hold them
+			 * in the ring.
+			 */
+			if (net_ratelimit())
+				printk (KERN_WARNING
+					"%s: Memory squeeze, dropping packet.\n",
+					dev->name);
 			tp->stats.rx_dropped++;
 		}
 
+		spin_lock_irqsave(&tp->lock, flags);
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
 		RTL_W16 (RxBufPtr, cur_rx - 16);
 
-		if (RTL_R16 (IntrStatus) & RxAckBits)
+		status = RTL_R16 (IntrStatus) & RxAckBits;
+		if (status & (RxFIFOOver | RxOverflow))
+			tp->stats.rx_errors++;
+
+		if (status)
 			RTL_W16_F (IntrStatus, RxAckBits);
+
+		if (++rx >= dev->quota)
+			break;
 	}
 
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
@@ -1988,6 +1998,23 @@
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
 	tp->cur_rx = cur_rx;
+ err:
+	*budget -= rx;
+
+	if ((dev->quota -= rx) <= 0) {
+		spin_unlock_irqrestore(&tp->lock, flags);
+		return 1; /* not done */
+	}
+
+	/* last gasp check if interrupt still pending */
+	if (RTL_R16 (IntrStatus) & RxAckBits) {
+		DPRINTK("%s: going back for more work\n", dev->name);
+		goto rescan;
+	}
+	netif_rx_complete(dev);
+	RTL_W16 (IntrMask, rtl8139_intr_mask);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	return 0; /* done */
 }
 
 
@@ -2013,9 +2040,7 @@
 		status &= ~RxUnderrun;
 	}
 
-	/* XXX along with rtl8139_rx_err, are we double-counting errors? */
-	if (status &
-	    (RxUnderrun | RxOverflow | RxErr | RxFIFOOver))
+	if (status & RxUnderrun)
 		tp->stats.rx_errors++;
 
 	if (status & PCSTimeout)
@@ -2032,7 +2057,6 @@
 	}
 }
 
-
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance,
@@ -2040,73 +2064,66 @@
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct rtl8139_private *tp = dev->priv;
-	int boguscnt = max_interrupt_work;
 	void *ioaddr = tp->mmio_addr;
 	int ackstat, status;
 	int link_changed = 0; /* avoid bogus "uninit" warning */
-	int handled = 0;
 
 	spin_lock (&tp->lock);
 
-	do {
-		status = RTL_R16 (IntrStatus);
-
-		/* h/w no longer present (hotplug?) or major error, bail */
-		if (status == 0xFFFF)
-			break;
-
-		if ((status &
-		     (PCIErr | PCSTimeout | RxUnderrun | RxOverflow |
-		      RxFIFOOver | TxErr | TxOK | RxErr | RxOK)) == 0)
-			break;
-
-		handled = 1;
+	status = RTL_R16 (IntrStatus);
 
-		/* Acknowledge all of the current interrupt sources ASAP, but
-		   an first get an additional status bit from CSCR. */
-		if (status & RxUnderrun)
-			link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
-
-		/* The chip takes special action when we clear RxAckBits,
-		 * so we clear them later in rtl8139_rx_interrupt
-		 */
-		ackstat = status & ~(RxAckBits | TxErr);
-		RTL_W16 (IntrStatus, ackstat);
+	/* h/w no longer present (hotplug?) or major error, bail */
+	if (unlikely(status == 0xFFFF)) {
+		spin_unlock(&tp->lock);
+		return IRQ_HANDLED;
+	}
 
-		DPRINTK ("%s: interrupt  status=%#4.4x ackstat=%#4.4x new intstat=%#4.4x.\n",
-			 dev->name, status, ackstat, RTL_R16 (IntrStatus));
+	/* no interrupt source present */
+	if (unlikely((status & rtl8139_intr_mask) == 0)) {
+		spin_unlock(&tp->lock);
+		return IRQ_NONE;
+	}
 
-		if (netif_running (dev) && (status & RxAckBits))
-			rtl8139_rx_interrupt (dev, tp, ioaddr);
+	/* Acknowledge all of the current interrupt sources ASAP, but
+	   an first get an additional status bit from CSCR. */
+	 if (unlikely(status & RxUnderrun))
+		link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
 
-		/* Check uncommon events with one test. */
-		if (status & (PCIErr | PCSTimeout | RxUnderrun | RxOverflow |
-		  	      RxFIFOOver | RxErr))
-			rtl8139_weird_interrupt (dev, tp, ioaddr,
-						 status, link_changed);
-
-		if (netif_running (dev) && (status & (TxOK | TxErr))) {
-			rtl8139_tx_interrupt (dev, tp, ioaddr);
-			if (status & TxErr)
-				RTL_W16 (IntrStatus, TxErr);
-		}
-
-		boguscnt--;
-	} while (boguscnt > 0);
+	/* The chip takes special action when we clear RxAckBits,
+	 * so we clear them later in poll
+	 */
+	ackstat = status & ~(RxAckBits | TxErr);
+	RTL_W16 (IntrStatus, ackstat);
 
-	if (boguscnt <= 0) {
-		printk (KERN_WARNING "%s: Too much work at interrupt, "
-			"IntrStatus=0x%4.4x.\n", dev->name, status);
+	DPRINTK ("%s: interrupt  status=%#4.4x ackstat=%#4.4x new intstat=%#4.4x.\n",
+		 dev->name, status, ackstat, RTL_R16 (IntrStatus));
 
-		/* Clear all interrupt sources. */
-		RTL_W16 (IntrStatus, 0xffff);
+	/* If received interrupt, then disable furthur interrupts
+	 * and enable NAPI polling.
+	 */
+	if (netif_running (dev) && (status & RxAckBits)) {
+		/* disable more receive interrupts */
+		RTL_W16 (IntrMask, rtl8139_intr_mask & ~RxAckBits);
+		netif_rx_schedule(dev);
+	}
+
+	/* Check uncommon events with one test. */
+	if (unlikely(status & (PCIErr|PCSTimeout|RxUnderrun|RxOverflow))) {
+		rtl8139_weird_interrupt (dev, tp, ioaddr,
+					 status, link_changed);
+	}
+
+	if (netif_running (dev) && (status & (TxOK | TxErr))) {
+		rtl8139_tx_interrupt (dev, tp, ioaddr);
+		if (status & TxErr)
+			RTL_W16 (IntrStatus, TxErr);
 	}
 
 	spin_unlock (&tp->lock);
 
 	DPRINTK ("%s: exiting interrupt, intr_status=%#4.4x.\n",
 		 dev->name, RTL_R16 (IntrStatus));
-	return IRQ_RETVAL(handled);
+	return IRQ_HANDLED;
 }
 
 
