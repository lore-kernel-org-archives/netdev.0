From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] merged 8139too NAPI
Date: Mon, 20 Oct 2003 13:11:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020131106.6862e951.shemminger@osdl.org>
References: <3F9070B6.9090306@pobox.com>
	<873cdqbt6z.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <873cdqbt6z.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This version merges hirofumi's and my changes.  It includes:
	* fix DPRINTK() arguments that got out of date
	* likely/unlikely in interrupt path.
	* handle shared interrupts better.
	* need to block out bottom half in tx_timeout
	* exit receive loop if interface is brought down
	* avoid false activation of receive poll due to tx interrupts
	* don't need the local_irq_disable() in end of receive poll.

This patch is against 2.6.0-test8

--- linux-2.5/drivers/net/8139too.c	2003-10-20 11:49:13.000000000 -0700
+++ desktop-2.5/drivers/net/8139too.c	2003-10-20 12:06:12.000000000 -0700
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
@@ -572,6 +569,7 @@
 	signed char phys[4];		/* MII device addresses. */
 	char twistie, twist_row, twist_col;	/* Twister tune state. */
 	unsigned int default_port:4;	/* Last dev->if_port value. */
+	spinlock_t rx_lock;
 	spinlock_t lock;
 	chip_t chipset;
 	pid_t thr_pid;
@@ -589,13 +587,11 @@
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
 
@@ -609,6 +605,7 @@
 static void rtl8139_init_ring (struct net_device *dev);
 static int rtl8139_start_xmit (struct sk_buff *skb,
 			       struct net_device *dev);
+static int rtl8139_poll(struct net_device *dev, int *budget);
 static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance,
 			       struct pt_regs *regs);
 static int rtl8139_close (struct net_device *dev);
@@ -681,6 +678,10 @@
 	PCIErr | PCSTimeout | RxUnderrun | RxOverflow | RxFIFOOver |
 	TxErr | TxOK | RxErr | RxOK;
 
+static const u16 rtl8139_norx_intr_mask =
+	PCIErr | PCSTimeout | RxUnderrun |
+	TxErr | TxOK | RxErr ;
+
 #ifdef USE_BUF16K 
 static const unsigned int rtl8139_rx_config =
 	RxCfgRcv16K | RxNoWrap |
@@ -867,9 +868,7 @@
 
 match:
 	DPRINTK ("chipset id (%d) == index %d, '%s'\n",
-		tmp,
-		tp->chipset,
-		rtl_chip_info[tp->chipset].name);
+		 version, i, rtl_chip_info[i].name);
 
 	if (tp->chipset >= CH_8139B) {
 		u8 new_tmp8 = tmp8 = RTL_R8 (Config1);
@@ -963,6 +962,8 @@
 	/* The Rtl8139-specific entries in the device structure. */
 	dev->open = rtl8139_open;
 	dev->hard_start_xmit = rtl8139_start_xmit;
+	dev->poll = rtl8139_poll;
+	dev->weight = 64;
 	dev->stop = rtl8139_close;
 	dev->get_stats = rtl8139_get_stats;
 	dev->set_multicast_list = rtl8139_set_rx_mode;
@@ -985,6 +986,7 @@
 	/* note: tp->chipset set in rtl8139_init_board */
 	tp->drv_flags = board_info[ent->driver_data].hw_flags;
 	tp->mmio_addr = ioaddr;
+	spin_lock_init (&tp->rx_lock);
 	spin_lock_init (&tp->lock);
 	init_waitqueue_head (&tp->thr_wait);
 	init_completion (&tp->thr_exited);
@@ -1319,6 +1321,8 @@
 	rtl8139_init_ring (dev);
 	rtl8139_hw_start (dev);
 
+	netif_start_queue (dev);
+
 	DPRINTK ("%s: rtl8139_open() ioaddr %#lx IRQ %d"
 			" GP Pins %2.2x %s-duplex.\n",
 			dev->name, pci_resource_start (tp->pci_dev, 1),
@@ -1406,8 +1410,6 @@
 
 	/* Enable all known interrupts by setting the interrupt mask. */
 	RTL_W16 (IntrMask, rtl8139_intr_mask);
-
-	netif_start_queue (dev);
 }
 
 
@@ -1655,6 +1657,7 @@
 
 	tp->xstats.tx_timeouts++;
 
+	spin_lock_bh(&tp->rx_lock);
 	/* disable Tx ASAP, if not already */
 	tmp8 = RTL_R8 (ChipCmd);
 	if (tmp8 & CmdTxEnb)
@@ -1679,6 +1682,7 @@
 
 	/* ...and finally, reset everything */
 	rtl8139_hw_start (dev);
+	spin_unlock_bh(&tp->rx_lock);
 
 	netif_wake_queue (dev);
 }
@@ -1694,6 +1698,7 @@
 	/* Calculate the next Tx descriptor entry. */
 	entry = tp->cur_tx % NUM_TX_DESC;
 
+	/* Note: the chip doesn't have auto-pad! */
 	if (likely(len < TX_BUF_SIZE)) {
 		if (len < ETH_ZLEN)
 			memset(tp->tx_buf[entry], 0, ETH_ZLEN);
@@ -1705,7 +1710,6 @@
 		return 0;
 	}
 
-	/* Note: the chip doesn't have auto-pad! */
 	spin_lock_irq(&tp->lock);
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
@@ -1791,8 +1795,7 @@
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		mb();
-		if (netif_queue_stopped (dev))
-			netif_wake_queue (dev);
+		netif_wake_queue (dev);
 	}
 }
 
@@ -1879,16 +1882,15 @@
 #endif
 }
 
-static void rtl8139_rx_interrupt (struct net_device *dev,
-				  struct rtl8139_private *tp, void *ioaddr)
+static inline int rtl8139_rx(struct net_device *dev, 
+			     struct rtl8139_private *tp,
+			     int budget)
 {
+	void *ioaddr = tp->mmio_addr;
+	int received = 0;
 	unsigned char *rx_ring;
 	u16 cur_rx;
 
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
-
 	rx_ring = tp->rx_ring;
 	cur_rx = tp->cur_rx;
 
@@ -1897,7 +1899,10 @@
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
-	while ((RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
+rx_status_loop:
+	RTL_W16_F (IntrStatus, RxAckBits);
+
+	while (budget > 0 && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		int ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
 		unsigned int rx_size;
@@ -1929,21 +1934,27 @@
 		 * Theoretically, this should never happen
 		 * since EarlyRx is disabled.
 		 */
-		if (rx_size == 0xfff0) {
+		if (unlikely(rx_size == 0xfff0)) {
 			tp->xstats.early_rx++;
 			break;
 		}
 
+		/*
+		 * Shutting down, network.
+		 */
+		if (unlikely(!netif_running(dev)))
+			goto done;
+
 		/* If Rx err or invalid rx_size/rx_status received
 		 * (which happens if we get lost in the ring),
 		 * Rx process gets reset, so we abort any further
 		 * Rx processing.
 		 */
-		if ((rx_size > (MAX_ETH_FRAME_SIZE+4)) ||
-		    (rx_size < 8) ||
-		    (!(rx_status & RxStatusOK))) {
+		if (unlikely((rx_size > (MAX_ETH_FRAME_SIZE+4)) ||
+			     (rx_size < 8) ||
+			     (!(rx_status & RxStatusOK)))) {
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
-			return;
+			return -1;
 		}
 
 		/* Malloc up new buffer, compatible with net-2e. */
@@ -1964,7 +1975,7 @@
 			skb_put (skb, pkt_size);
 
 			skb->protocol = eth_type_trans (skb, dev);
-			netif_rx (skb);
+			netif_receive_skb (skb);
 			dev->last_rx = jiffies;
 			tp->stats.rx_bytes += pkt_size;
 			tp->stats.rx_packets++;
@@ -1974,23 +1985,31 @@
 				dev->name);
 			tp->stats.rx_dropped++;
 		}
+		received++;
+		budget--;
 
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
 		RTL_W16 (RxBufPtr, cur_rx - 16);
 
-		if (RTL_R16 (IntrStatus) & RxAckBits)
+		if (RTL_R16 (IntrStatus) & (RxFIFOOver | RxOverflow)) {
 			RTL_W16_F (IntrStatus, RxAckBits);
+			tp->stats.rx_errors++;
+		}
 	}
 
+	if (budget && (RTL_R16(IntrStatus) & RxAckBits))
+		goto rx_status_loop;
+ done:
+
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
 	tp->cur_rx = cur_rx;
+	return received;
 }
 
-
 static void rtl8139_weird_interrupt (struct net_device *dev,
 				     struct rtl8139_private *tp,
 				     void *ioaddr,
@@ -2013,13 +2032,11 @@
 		status &= ~RxUnderrun;
 	}
 
-	/* XXX along with rtl8139_rx_err, are we double-counting errors? */
-	if (status &
-	    (RxUnderrun | RxOverflow | RxErr | RxFIFOOver))
-		tp->stats.rx_errors++;
+	if (status & (RxUnderrun | RxErr))
+		tp->stats.rx_errors++;		/* race with rtl8139_rx_err */
 
 	if (status & PCSTimeout)
-		tp->stats.rx_length_errors++;
+		tp->stats.rx_length_errors++;	/* race with rtl8139_rx_err */
 	if (status & (RxUnderrun | RxFIFOOver))
 		tp->stats.rx_fifo_errors++;
 	if (status & PCIErr) {
@@ -2032,6 +2049,42 @@
 	}
 }
 
+static int rtl8139_poll(struct net_device *dev, int *budget)
+{
+	struct rtl8139_private *tp = dev->priv;
+	void *ioaddr = tp->mmio_addr;
+	u16 status;
+	int orig_budget = min(*budget, dev->quota);
+	int done = 1;
+
+	spin_lock(&tp->rx_lock);
+
+	status = RTL_R16(IntrStatus);
+
+	if (likely(status & RxAckBits)) {
+		int work_done;
+
+		work_done = rtl8139_rx(dev, tp, orig_budget);
+		if (likely(work_done > 0)) {
+			*budget -= work_done;
+			dev->quota -= work_done;
+			done = (work_done < orig_budget);
+		}
+	}
+
+	if (done) {
+		/*
+		 * This order is important
+		 * (see Documentation/networking/NAPI_HOWTO.txt)
+		 */
+		netif_rx_complete(dev);
+		RTL_W16_F(IntrMask, rtl8139_intr_mask);
+	}
+
+	spin_unlock(&tp->rx_lock);
+
+	return !done;
+}
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
@@ -2040,76 +2093,56 @@
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct rtl8139_private *tp = dev->priv;
-	int boguscnt = max_interrupt_work;
 	void *ioaddr = tp->mmio_addr;
-	int ackstat, status;
+	u16 status;
 	int link_changed = 0; /* avoid bogus "uninit" warning */
 	int handled = 0;
 
 	spin_lock (&tp->lock);
+	status = RTL_R16 (IntrStatus);
 
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
-
-		/* Acknowledge all of the current interrupt sources ASAP, but
-		   an first get an additional status bit from CSCR. */
-		if (status & RxUnderrun)
-			link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
-
-		/* The chip takes special action when we clear RxAckBits,
-		 * so we clear them later in rtl8139_rx_interrupt
+	/* shared irq? */
+	if (unlikely((status & rtl8139_intr_mask) == 0)) 
+		goto out;
+
+	handled = 1;
+
+	/* h/w no longer present (hotplug?) or major error, bail */
+	if (unlikely(status == 0xFFFF)) 
+		goto out;
+
+	/* Acknowledge all of the current interrupt sources ASAP, but
+	   an first get an additional status bit from CSCR. */
+	if (unlikely(status & RxUnderrun))
+		link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
+
+	if (status & (RTL_R16 (IntrMask) & RxAckBits)) {
+		/* Disable furthur receive interrupts.
+		 * receive packets are processed by poll routine.
 		 */
-		ackstat = status & ~(RxAckBits | TxErr);
-		RTL_W16 (IntrStatus, ackstat);
-
-		DPRINTK ("%s: interrupt  status=%#4.4x ackstat=%#4.4x new intstat=%#4.4x.\n",
-			 dev->name, status, ackstat, RTL_R16 (IntrStatus));
-
-		if (netif_running (dev) && (status & RxAckBits))
-			rtl8139_rx_interrupt (dev, tp, ioaddr);
-
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
+		RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
+		netif_rx_schedule (dev);
+	}
 
-	if (boguscnt <= 0) {
-		printk (KERN_WARNING "%s: Too much work at interrupt, "
-			"IntrStatus=0x%4.4x.\n", dev->name, status);
+	/* Check uncommon events with one test. */
+	if (unlikely(status & (PCIErr | PCSTimeout | RxUnderrun | RxOverflow)))
+		rtl8139_weird_interrupt (dev, tp, ioaddr,
+					 status, link_changed);
 
-		/* Clear all interrupt sources. */
-		RTL_W16 (IntrStatus, 0xffff);
+	if (netif_running (dev) && (status & (TxOK | TxErr))) {
+		rtl8139_tx_interrupt (dev, tp, ioaddr);
+		if (status & TxErr)
+			RTL_W16 (IntrStatus, TxErr);
 	}
 
+	RTL_W16_F (IntrStatus, status & ~(RxAckBits | TxErr));
+
+ out:
 	spin_unlock (&tp->lock);
 
-	DPRINTK ("%s: exiting interrupt, intr_status=%#4.4x.\n",
-		 dev->name, RTL_R16 (IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
-
 static int rtl8139_close (struct net_device *dev)
 {
 	struct rtl8139_private *tp = dev->priv;
@@ -2493,6 +2526,7 @@
 	pci_set_power_state (pdev, 0);
 	rtl8139_init_ring (dev);
 	rtl8139_hw_start (dev);
+	netif_start_queue (dev);
 	netif_device_attach (dev);
 	return 0;
 }
