From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] 8139too NAPI for net-drivers-2.5-exp
Date: Tue, 18 Nov 2003 16:17:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118161730.2690cb76.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>,
        OGAWA Hirofumi
 <hirofumi@mail.parknet.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the 8139too version in net-drivers-2.5-exp modified for NAPI.
Also:
	64k receive ring - has to handle wrap for that case;
	   the NoWrap flag does nothing if using this big ring.
	assert() -> BUG_ON()
	
To deal with the races with tx_timeout, put back in the rx_lock from earlier versions.

diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	Tue Nov 18 16:16:59 2003
+++ b/drivers/net/8139too.c	Tue Nov 18 16:16:59 2003
@@ -92,7 +92,7 @@
 */
 
 #define DRV_NAME	"8139too"
-#define DRV_VERSION	"0.9.26"
+#define DRV_VERSION	"0.9.27"
 
 
 #include <linux/config.h>
@@ -128,9 +128,11 @@
 #define USE_IO_OPS 1
 #endif
 
-/* use a 16K rx ring buffer instead of the default 32K */
-#ifdef CONFIG_SH_DREAMCAST
+/* use a 16K rx ring buffer instead of the default 64K */
+#if defined(CONFIG_SH_DREAMCAST) || defined(CONFIG_EMBEDDED)
 #define USE_BUF16K 1
+#else
+#define USE_BUF64K 1
 #endif
 
 /* define to 1 to enable copious debugging info */
@@ -150,11 +152,7 @@
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
 
 
@@ -164,9 +162,6 @@
 static int media[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static int max_interrupt_work = 20;
-
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
@@ -175,15 +170,23 @@
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
+#ifdef USE_BUF64K
+#define RX_BUF_TOT_LEN	RX_BUF_LEN
+#else
 #define RX_BUF_TOT_LEN	(RX_BUF_LEN + RX_BUF_PAD + RX_BUF_WRAP_PAD)
+#endif
 
 /* Number of Tx descriptor registers. */
 #define NUM_TX_DESC	4
@@ -455,7 +458,7 @@
 	RxCfgRcv32K = (1 << 12),
 	RxCfgRcv64K = (1 << 11) | (1 << 12),
 
-	/* Disable packet wrap at end of Rx buffer */
+	/* Disable packet wrap at end of Rx buffer. (not possible with 64k) */
 	RxNoWrap = (1 << 7),
 };
 
@@ -580,6 +583,7 @@
 	char twistie, twist_row, twist_col;	/* Twister tune state. */
 	unsigned int default_port:4;	/* Last dev->if_port value. */
 	spinlock_t lock;
+	spinlock_t rx_lock;
 	chip_t chipset;
 	pid_t thr_pid;
 	wait_queue_head_t thr_wait;
@@ -596,13 +600,11 @@
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
 
@@ -616,6 +618,7 @@
 static void rtl8139_init_ring (struct net_device *dev);
 static int rtl8139_start_xmit (struct sk_buff *skb,
 			       struct net_device *dev);
+static int rtl8139_poll(struct net_device *dev, int *budget);
 static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance,
 			       struct pt_regs *regs);
 static int rtl8139_close (struct net_device *dev);
@@ -688,16 +691,27 @@
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
+#elif defined(USE_BUF64K)
+static const unsigned int rtl8139_rx_config =
+	RxCfgRcv64K |
+	(RX_FIFO_THRESH << RxCfgFIFOShift) |
+	(RX_DMA_BURST << RxCfgDMAShift);
+#else
+#error "Need to define receive buffer window"
 #endif
 
 static const unsigned int rtl8139_tx_config =
@@ -874,9 +888,7 @@
 
 match:
 	DPRINTK ("chipset id (%d) == index %d, '%s'\n",
-		tmp,
-		tp->chipset,
-		rtl_chip_info[tp->chipset].name);
+		 version, i, rtl_chip_info[i].name);
 
 	if (tp->chipset >= CH_8139B) {
 		u8 new_tmp8 = tmp8 = RTL_R8 (Config1);
@@ -970,6 +982,8 @@
 	/* The Rtl8139-specific entries in the device structure. */
 	dev->open = rtl8139_open;
 	dev->hard_start_xmit = rtl8139_start_xmit;
+	dev->poll = rtl8139_poll;
+	dev->weight = 64;
 	dev->stop = rtl8139_close;
 	dev->get_stats = rtl8139_get_stats;
 	dev->set_multicast_list = rtl8139_set_rx_mode;
@@ -995,6 +1009,7 @@
 	tp->msg_enable =
 		(debug < 0 ? RTL8139_DEF_MSG_ENABLE : ((1 << debug) - 1));
 	spin_lock_init (&tp->lock);
+	spin_lock_init (&tp->rx_lock);
 	init_waitqueue_head (&tp->thr_wait);
 	init_completion (&tp->thr_exited);
 	tp->mii.dev = dev;
@@ -1638,7 +1653,7 @@
 	}
 }
 
-static void rtl8139_tx_clear (struct rtl8139_private *tp)
+static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
 {
 	tp->cur_tx = 0;
 	tp->dirty_tx = 0;
@@ -1668,6 +1683,7 @@
 	if (tmp8 & CmdTxEnb)
 		RTL_W8 (ChipCmd, CmdRxEnb);
 
+	spin_lock(&tp->rx_lock);
 	/* Disable interrupts by clearing the interrupt mask. */
 	RTL_W16 (IntrMask, 0x0000);
 
@@ -1686,9 +1702,12 @@
 	spin_unlock_irqrestore (&tp->lock, flags);
 
 	/* ...and finally, reset everything */
-	rtl8139_hw_start (dev);
-
-	netif_wake_queue (dev);
+	if (netif_running(dev)) {
+		rtl8139_hw_start (dev);
+		netif_wake_queue (dev);
+	}
+	spin_unlock(&tp->rx_lock);
+	
 }
 
 
@@ -1702,6 +1721,7 @@
 	/* Calculate the next Tx descriptor entry. */
 	entry = tp->cur_tx % NUM_TX_DESC;
 
+	/* Note: the chip doesn't have auto-pad! */
 	if (likely(len < TX_BUF_SIZE)) {
 		if (len < ETH_ZLEN)
 			memset(tp->tx_buf[entry], 0, ETH_ZLEN);
@@ -1713,7 +1733,6 @@
 		return 0;
 	}
 
-	/* Note: the chip doesn't have auto-pad! */
 	spin_lock_irq(&tp->lock);
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
@@ -1801,8 +1820,7 @@
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		mb();
-		if (netif_queue_stopped (dev))
-			netif_wake_queue (dev);
+		netif_wake_queue (dev);
 	}
 }
 
@@ -1890,30 +1908,41 @@
 #endif
 }
 
-static void rtl8139_rx_interrupt (struct net_device *dev,
-				  struct rtl8139_private *tp, void *ioaddr)
+static __inline__ void wrap_copy(struct sk_buff *skb, const unsigned char *ring,
+				 u32 offset, unsigned int size)
 {
-	unsigned char *rx_ring;
-	u16 cur_rx;
+#ifdef USE_BUF64K
+	u32 left = RX_BUF_LEN - offset;
 
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
+	if (size > left) {
+		memcpy(skb->data, ring + offset, left);
+		memcpy(skb->data+left, ring, size - left);
+	} else
+#endif
+		memcpy(skb->data, ring + offset, size);
+}
 
-	rx_ring = tp->rx_ring;
-	cur_rx = tp->cur_rx;
+static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
+		      int budget)
+{
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
+		u32 ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
 		unsigned int rx_size;
 		unsigned int pkt_size;
 		struct sk_buff *skb;
+		u16 status;
 
 		rmb();
 
@@ -1941,9 +1970,9 @@
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
@@ -1951,55 +1980,66 @@
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
+			wrap_copy(skb, rx_ring, ring_offset+4, pkt_size);
 
-			eth_copy_and_sum (skb, &rx_ring[ring_offset + 4], pkt_size, 0);
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
 
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
-		RTL_W16 (RxBufPtr, cur_rx - 16);
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
 
 
@@ -2025,14 +2065,12 @@
 		status &= ~RxUnderrun;
 	}
 
-	/* XXX along with rtl8139_rx_err, are we double-counting errors? */
-	if (status &
-	    (RxUnderrun | RxOverflow | RxErr | RxFIFOOver))
+	if (status & (RxUnderrun | RxErr))
 		tp->stats.rx_errors++;
 
 	if (status & PCSTimeout)
 		tp->stats.rx_length_errors++;
-	if (status & (RxUnderrun | RxFIFOOver))
+	if (status & RxUnderrun)
 		tp->stats.rx_fifo_errors++;
 	if (status & PCIErr) {
 		u16 pci_cmd_status;
@@ -2044,6 +2082,39 @@
 	}
 }
 
+static int rtl8139_poll(struct net_device *dev, int *budget)
+{
+	struct rtl8139_private *tp = dev->priv;
+	void *ioaddr = tp->mmio_addr;
+	int orig_budget = min(*budget, dev->quota);
+	int done = 1;
+
+	spin_lock(&tp->rx_lock);
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
+		 * Order is important since data can get interrupted
+		 * again when we think we are done.
+		 */
+		local_irq_disable();
+		netif_rx_complete(dev);
+		RTL_W16_F(IntrMask, rtl8139_intr_mask);
+		local_irq_enable();
+	}
+	spin_unlock(&tp->rx_lock);
+
+	return !done;
+}
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
@@ -2052,69 +2123,59 @@
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
 
-		if (netif_msg_intr(tp))
-			printk (KERN_DEBUG "%s: interrupt  status=%#4.4x ackstat=%#4.4x new intstat=%#4.4x.\n",
-				dev->name, status, ackstat, RTL_R16 (IntrStatus));
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
