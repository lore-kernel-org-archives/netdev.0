From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Updated 8139too with NAPI
Date: Tue, 11 Nov 2003 14:31:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111143143.794909e8.shemminger@osdl.org>
References: <3F9070B6.9090306@pobox.com>
	<873cdqbt6z.fsf@devron.myhome.or.jp>
	<20031020131106.6862e951.shemminger@osdl.org>
	<877k2ysohc.fsf@devron.myhome.or.jp>
	<20031028114707.1d234da6.shemminger@osdl.org>
	<3FA01629.2080202@pobox.com>
	<873cdaabue.fsf@devron.myhome.or.jp>
	<20031030104943.20b61af0.shemminger@osdl.org>
	<87ekwu9tn4.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Jeff Garzik
 <jgarzik@pobox.com>
In-Reply-To: <87ekwu9tn4.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the latest update for 8139too with NAPI.

The changes from last time were to get rid of some of the netif_poll_disable calls
to avoid getting trapped by receive interrupt races.  It is okay for the interrupt
code to enable the poll routine to run even if we are just about to suspend or
change multicast list.

--- 2.6.0-test9/drivers/net/8139too.c	2003-10-27 12:09:03.000000000 -0800
+++ linux-2.5/drivers/net/8139too.c	2003-11-11 09:16:42.000000000 -0800
@@ -92,7 +92,7 @@
 */
 
 #define DRV_NAME	"8139too"
-#define DRV_VERSION	"0.9.26"
+#define DRV_VERSION	"0.9.27"
 
 
 #include <linux/config.h>
@@ -123,8 +123,8 @@
 #define USE_IO_OPS 1
 #endif
 
-/* use a 16K rx ring buffer instead of the default 32K */
-#ifdef CONFIG_SH_DREAMCAST
+/* use a 16K rx ring buffer instead of the default 64K */
+#if defined(CONFIG_SH_DREAMCAST) || defined(CONFIG_EMBEDDED)
 #define USE_BUF16K 1
 #endif
 
@@ -145,11 +145,7 @@
 #ifdef RTL8139_NDEBUG
 #  define assert(expr) do {} while (0)
 #else
-#  define assert(expr) \
-        if(!(expr)) {					\
-        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		\
-        }
+#  define assert(expr) BUG_ON((expr) == 0)
 #endif
 
 
@@ -159,9 +155,6 @@
 static int media[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static int max_interrupt_work = 20;
-
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
@@ -170,11 +163,15 @@
 static int debug = -1;
 
 /* Size of the in-memory receive ring. */
+/* 0==8K, 1==16K, 2==32K, 3==64K */
 #ifdef USE_BUF16K
-#define RX_BUF_LEN_IDX	1	/* 0==8K, 1==16K, 2==32K, 3==64K */
+#define RX_BUF_LEN_IDX	1
+#elif defined(USE_BUF32K)
+#define RX_BUF_LEN_IDX	2
 #else
-#define RX_BUF_LEN_IDX	2	/* 0==8K, 1==16K, 2==32K, 3==64K */
+#define RX_BUF_LEN_IDX	3
 #endif
+
 #define RX_BUF_LEN	(8192 << RX_BUF_LEN_IDX)
 #define RX_BUF_PAD	16
 #define RX_BUF_WRAP_PAD 2048 /* spare padding to handle lack of packet wrap */
@@ -245,6 +242,7 @@
 	{0x1186, 0x1340, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x13d1, 0xab06, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1259, 0xa117, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{0x1259, 0xa11e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x14ea, 0xab06, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x14ea, 0xab07, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x11db, 0x1234, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
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
@@ -681,16 +678,25 @@
 	PCIErr | PCSTimeout | RxUnderrun | RxOverflow | RxFIFOOver |
 	TxErr | TxOK | RxErr | RxOK;
 
+static const u16 rtl8139_norx_intr_mask =
+	PCIErr | PCSTimeout | RxUnderrun |
+	TxErr | TxOK | RxErr ;
+
 #ifdef USE_BUF16K 
 static const unsigned int rtl8139_rx_config =
 	RxCfgRcv16K | RxNoWrap |
 	(RX_FIFO_THRESH << RxCfgFIFOShift) |
 	(RX_DMA_BURST << RxCfgDMAShift);
-#else
+#elif defined(USE_BUF32K)
 static const unsigned int rtl8139_rx_config =
 	RxCfgRcv32K | RxNoWrap |
 	(RX_FIFO_THRESH << RxCfgFIFOShift) |
 	(RX_DMA_BURST << RxCfgDMAShift);
+#else
+static const unsigned int rtl8139_rx_config =
+	RxCfgRcv64K | RxNoWrap |
+	(RX_FIFO_THRESH << RxCfgFIFOShift) |
+	(RX_DMA_BURST << RxCfgDMAShift);
 #endif
 
 static const unsigned int rtl8139_tx_config =
@@ -867,9 +873,7 @@
 
 match:
 	DPRINTK ("chipset id (%d) == index %d, '%s'\n",
-		tmp,
-		tp->chipset,
-		rtl_chip_info[tp->chipset].name);
+		 version, i, rtl_chip_info[i].name);
 
 	if (tp->chipset >= CH_8139B) {
 		u8 new_tmp8 = tmp8 = RTL_R8 (Config1);
@@ -963,6 +967,8 @@
 	/* The Rtl8139-specific entries in the device structure. */
 	dev->open = rtl8139_open;
 	dev->hard_start_xmit = rtl8139_start_xmit;
+	dev->poll = rtl8139_poll;
+	dev->weight = 64;
 	dev->stop = rtl8139_close;
 	dev->get_stats = rtl8139_get_stats;
 	dev->set_multicast_list = rtl8139_set_rx_mode;
@@ -1630,7 +1636,7 @@
 	}
 }
 
-static void rtl8139_tx_clear (struct rtl8139_private *tp)
+static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
 {
 	tp->cur_tx = 0;
 	tp->dirty_tx = 0;
@@ -1639,6 +1645,15 @@
 }
 
 
+/* spin while poll is running
+ * could use netif_poll_disable but that sleeps.
+ */
+static inline void __netif_poll_disable(struct net_device *dev)
+{
+	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state)) 
+		cpu_relax();
+}
+
 static void rtl8139_tx_timeout (struct net_device *dev)
 {
 	struct rtl8139_private *tp = dev->priv;
@@ -1663,6 +1678,8 @@
 	/* Disable interrupts by clearing the interrupt mask. */
 	RTL_W16 (IntrMask, 0x0000);
 
+	__netif_poll_disable(dev);
+
 	/* Emit info to figure out what went wrong. */
 	printk (KERN_DEBUG "%s: Tx queue start entry %ld  dirty entry %ld.\n",
 		dev->name, tp->cur_tx, tp->dirty_tx);
@@ -1678,9 +1695,11 @@
 	spin_unlock_irqrestore (&tp->lock, flags);
 
 	/* ...and finally, reset everything */
-	rtl8139_hw_start (dev);
-
-	netif_wake_queue (dev);
+	if (netif_running(dev)) {
+		netif_poll_enable (dev);
+		rtl8139_hw_start (dev);
+		netif_wake_queue (dev);
+	}
 }
 
 
@@ -1694,6 +1713,7 @@
 	/* Calculate the next Tx descriptor entry. */
 	entry = tp->cur_tx % NUM_TX_DESC;
 
+	/* Note: the chip doesn't have auto-pad! */
 	if (likely(len < TX_BUF_SIZE)) {
 		if (len < ETH_ZLEN)
 			memset(tp->tx_buf[entry], 0, ETH_ZLEN);
@@ -1705,7 +1725,6 @@
 		return 0;
 	}
 
-	/* Note: the chip doesn't have auto-pad! */
 	spin_lock_irq(&tp->lock);
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
@@ -1791,8 +1810,7 @@
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		mb();
-		if (netif_queue_stopped (dev))
-			netif_wake_queue (dev);
+		netif_wake_queue (dev);
 	}
 }
 
@@ -1879,35 +1897,31 @@
 #endif
 }
 
-static void rtl8139_rx_interrupt (struct net_device *dev,
-				  struct rtl8139_private *tp, void *ioaddr)
+static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
+		      int budget)
 {
-	unsigned char *rx_ring;
-	u16 cur_rx;
-
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
-
-	rx_ring = tp->rx_ring;
-	cur_rx = tp->cur_rx;
+	void *ioaddr = tp->mmio_addr;
+	int received = 0;
+	const unsigned char *rx_ring = tp->rx_ring;
+	unsigned int cur_rx = tp->cur_rx;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
-	while ((RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
-		int ring_offset = cur_rx % RX_BUF_LEN;
+	while (netif_running(dev) && received < budget 
+	       && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		u32 rx_status;
 		unsigned int rx_size;
 		unsigned int pkt_size;
 		struct sk_buff *skb;
+		u16 status;
 
 		rmb();
 
 		/* read size+status of next frame from DMA ring buffer */
-		rx_status = le32_to_cpu (*(u32 *) (rx_ring + ring_offset));
+		rx_status = le32_to_cpu (*(u32 *) (rx_ring + cur_rx));
 		rx_size = rx_status >> 16;
 		pkt_size = rx_size - 4;
 
@@ -1929,9 +1943,9 @@
 		 * Theoretically, this should never happen
 		 * since EarlyRx is disabled.
 		 */
-		if (rx_size == 0xfff0) {
+		if (unlikely(rx_size == 0xfff0)) {
 			tp->xstats.early_rx++;
-			break;
+			goto done;
 		}
 
 		/* If Rx err or invalid rx_size/rx_status received
@@ -1939,55 +1953,65 @@
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
 		/* Omit the four octet CRC from the length. */
 
-		/* TODO: consider allocating skb's outside of
-		 * interrupt context, both to speed interrupt processing,
-		 * and also to reduce the chances of having to
-		 * drop packets here under memory pressure.
-		 */
-
 		skb = dev_alloc_skb (pkt_size + 2);
-		if (skb) {
+		if (likely(skb)) {
 			skb->dev = dev;
 			skb_reserve (skb, 2);	/* 16 byte align the IP fields. */
-
-			eth_copy_and_sum (skb, &rx_ring[ring_offset + 4], pkt_size, 0);
+			memcpy(skb->data, &rx_ring[cur_rx + 4], pkt_size);
 			skb_put (skb, pkt_size);
 
 			skb->protocol = eth_type_trans (skb, dev);
-			netif_rx (skb);
+
 			dev->last_rx = jiffies;
 			tp->stats.rx_bytes += pkt_size;
 			tp->stats.rx_packets++;
+
+			netif_receive_skb (skb);
 		} else {
-			printk (KERN_WARNING
-				"%s: Memory squeeze, dropping packet.\n",
-				dev->name);
+			if (net_ratelimit()) 
+				printk (KERN_WARNING
+					"%s: Memory squeeze, dropping packet.\n",
+					dev->name);
 			tp->stats.rx_dropped++;
 		}
+		received++;
 
-		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
-		RTL_W16 (RxBufPtr, cur_rx - 16);
+		cur_rx = ((cur_rx + rx_size + 4 + 3) & ~3) % RX_BUF_LEN;
+		RTL_W16 (RxBufPtr, (u16) (cur_rx - 16));
 
-		if (RTL_R16 (IntrStatus) & RxAckBits)
+		/* Clear out errors and receive interrupts */
+		status = RTL_R16 (IntrStatus) & RxAckBits;
+		if (likely(status != 0)) {
+			if (unlikely(status & (RxFIFOOver | RxOverflow))) {
+				tp->stats.rx_errors++;
+				if (status & RxFIFOOver)
+					tp->stats.rx_fifo_errors++;
+			}
 			RTL_W16_F (IntrStatus, RxAckBits);
+		}
 	}
 
+ done:
+
+#if RTL8139_DEBUG > 1
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
+#endif
 
 	tp->cur_rx = cur_rx;
+	return received;
 }
 
 
@@ -2013,14 +2037,11 @@
 		status &= ~RxUnderrun;
 	}
 
-	/* XXX along with rtl8139_rx_err, are we double-counting errors? */
-	if (status &
-	    (RxUnderrun | RxOverflow | RxErr | RxFIFOOver))
+	if (status & (RxUnderrun | RxErr))
 		tp->stats.rx_errors++;
-
 	if (status & PCSTimeout)
-		tp->stats.rx_length_errors++;
-	if (status & (RxUnderrun | RxFIFOOver))
+		tp->stats.rx_length_errors++;	/* race with rtl8139_rx_err */
+	if (status & RxUnderrun)
 		tp->stats.rx_fifo_errors++;
 	if (status & PCIErr) {
 		u16 pci_cmd_status;
@@ -2032,6 +2053,35 @@
 	}
 }
 
+static int rtl8139_poll(struct net_device *dev, int *budget)
+{
+	struct rtl8139_private *tp = dev->priv;
+	void *ioaddr = tp->mmio_addr;
+	int orig_budget = min(*budget, dev->quota);
+	int done = 1;
+
+	if (likely(RTL_R16(IntrStatus) & RxAckBits)) {
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
+	return !done;
+}
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
@@ -2040,68 +2090,59 @@
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct rtl8139_private *tp = dev->priv;
-	int boguscnt = max_interrupt_work;
 	void *ioaddr = tp->mmio_addr;
-	int ackstat, status;
+	u16 status, ackstat;
 	int link_changed = 0; /* avoid bogus "uninit" warning */
 	int handled = 0;
 
 	spin_lock (&tp->lock);
+	status = RTL_R16 (IntrStatus);
 
-	do {
-		status = RTL_R16 (IntrStatus);
+	/* shared irq? */
+	if (unlikely((status & rtl8139_intr_mask) == 0)) 
+		goto out;
 
-		/* h/w no longer present (hotplug?) or major error, bail */
-		if (status == 0xFFFF)
-			break;
+	handled = 1;
 
-		if ((status &
-		     (PCIErr | PCSTimeout | RxUnderrun | RxOverflow |
-		      RxFIFOOver | TxErr | TxOK | RxErr | RxOK)) == 0)
-			break;
+	/* h/w no longer present (hotplug?) or major error, bail */
+	if (unlikely(status == 0xFFFF)) 
+		goto out;
 
-		handled = 1;
+	/* close possible race's with dev_close */
+	if (unlikely(!netif_running(dev))) {
+		RTL_W16 (IntrMask, 0);
+		goto out;
+	}
 
-		/* Acknowledge all of the current interrupt sources ASAP, but
-		   an first get an additional status bit from CSCR. */
-		if (status & RxUnderrun)
-			link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
+	/* Acknowledge all of the current interrupt sources ASAP, but
+	   an first get an additional status bit from CSCR. */
+	if (unlikely(status & RxUnderrun))
+		link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
 
-		/* The chip takes special action when we clear RxAckBits,
-		 * so we clear them later in rtl8139_rx_interrupt
-		 */
-		ackstat = status & ~(RxAckBits | TxErr);
+	ackstat = status & ~(RxAckBits | TxErr);
+	if (ackstat)
 		RTL_W16 (IntrStatus, ackstat);
 
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
+	/* Receive packets are processed by poll routine.
+	   If not running start it now. */
+	if (status & RxAckBits){
+		if (netif_rx_schedule_prep(dev)) {
+			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
+			__netif_rx_schedule (dev);
 		}
-
-		boguscnt--;
-	} while (boguscnt > 0);
-
-	if (boguscnt <= 0) {
-		printk (KERN_WARNING "%s: Too much work at interrupt, "
-			"IntrStatus=0x%4.4x.\n", dev->name, status);
-
-		/* Clear all interrupt sources. */
-		RTL_W16 (IntrStatus, 0xffff);
 	}
 
+	/* Check uncommon events with one test. */
+	if (unlikely(status & (PCIErr | PCSTimeout | RxUnderrun | RxErr)))
+		rtl8139_weird_interrupt (dev, tp, ioaddr,
+					 status, link_changed);
+
+	if (status & (TxOK | TxErr)) {
+		rtl8139_tx_interrupt (dev, tp, ioaddr);
+		if (status & TxErr)
+			RTL_W16 (IntrStatus, TxErr);
+	}
+ out:
 	spin_unlock (&tp->lock);
 
 	DPRINTK ("%s: exiting interrupt, intr_status=%#4.4x.\n",
