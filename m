From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 1/7] 2.6.6-rc3-mm1 - r8169 napi
Date: Sat, 1 May 2004 02:24:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501022439.A500@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040501022308.A32762@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, May 01, 2004 at 02:23:08AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Napi for r8169 (Jon D Mason <jonmason@us.ibm.com>).
Both Tx and Rx processing are moved to the ->poll() function.



diff -puN drivers/net/r8169.c~r8169-napi drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-napi	2004-05-01 01:46:29.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-01 01:46:29.000000000 +0200
@@ -64,6 +64,14 @@ VERSION 1.2	<2002/11/30>
 #define dprintk(fmt, args...)	do {} while (0)
 #endif /* RTL8169_DEBUG */
 
+#ifdef CONFIG_R8169_NAPI
+#define rtl8169_rx_skb			netif_receive_skb
+#define rtl8169_rx_quota(count, quota)	min(count, quota)
+#else
+#define rtl8169_rx_skb			netif_rx
+#define rtl8169_rx_quota(count, quota)	count
+#endif
+
 /* media options */
 #define MAX_UNITS 8
 static int media[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1 };
@@ -90,8 +98,9 @@ static int multicast_filter_limit = 32;
 #define RxPacketMaxSize	0x0800	/* Maximum size supported is 16K-1 */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
+#define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
-#define NUM_RX_DESC	64	/* Number of Rx descriptor registers */
+#define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
 #define RX_BUF_SIZE	1536	/* Rx Buffer size */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
@@ -326,6 +335,7 @@ struct rtl8169_private {
 	struct timer_list timer;
 	unsigned long phy_link_down_cnt;
 	u16 cp_cmd;
+	u16 intr_mask;
 };
 
 MODULE_AUTHOR("Realtek");
@@ -344,9 +354,14 @@ static int rtl8169_close(struct net_devi
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
+#ifdef CONFIG_R8169_NAPI
+static int rtl8169_poll(struct net_device *dev, int *budget);
+#endif
 
 static const u16 rtl8169_intr_mask =
-    RxUnderrun | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
+	RxUnderrun | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
+static const u16 rtl8169_napi_event =
+	RxOK | RxUnderrun | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
     (RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
@@ -836,9 +851,12 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
-//      dev->do_ioctl           = mii_ioctl;
-
-	tp = dev->priv;		// private data //
+#ifdef CONFIG_R8169_NAPI
+	dev->poll = rtl8169_poll;
+	dev->weight = R8169_NAPI_WEIGHT;
+	printk(KERN_INFO PFX "NAPI enabled\n");
+#endif
+	tp->intr_mask = 0xffff;
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
 
@@ -1442,11 +1460,11 @@ static inline int rtl8169_try_rx_copy(st
 	return ret;
 }
 
-static void
+static int
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void *ioaddr)
 {
-	unsigned long cur_rx, rx_left;
+	unsigned int cur_rx, rx_left, count;
 	int delta;
 
 	assert(dev != NULL);
@@ -1455,6 +1473,7 @@ rtl8169_rx_interrupt(struct net_device *
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
+	rx_left = rtl8169_rx_quota(rx_left, (u32) dev->quota);
 
 	while (rx_left > 0) {
 		int entry = cur_rx % NUM_RX_DESC;
@@ -1494,7 +1513,7 @@ rtl8169_rx_interrupt(struct net_device *
 
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
-			netif_rx(skb);
+			rtl8169_rx_skb(skb);
 
 			dev->last_rx = jiffies;
 			tp->stats.rx_bytes += pkt_size;
@@ -1505,13 +1524,15 @@ rtl8169_rx_interrupt(struct net_device *
 		rx_left--;
 	}
 
+	count = cur_rx - tp->cur_rx;
 	tp->cur_rx = cur_rx;
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-	if (delta > 0)
-		tp->dirty_rx += delta;
-	else if (delta < 0)
+	if (delta < 0) {
 		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
+		delta = 0;
+	}
+	tp->dirty_rx += delta;
 
 	/*
 	 * FIXME: until there is periodic timer to try and refill the ring,
@@ -1522,6 +1543,8 @@ rtl8169_rx_interrupt(struct net_device *
 	 */
 	if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
 		printk(KERN_EMERG "%s: Rx buffers exhausted\n", dev->name);
+
+	return count;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up after the Tx thread. */
@@ -1547,12 +1570,25 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (status & RxUnderrun)
 			link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
 */
+		status &= tp->intr_mask;
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 
 		if (!(status & rtl8169_intr_mask))
 			break;
 
+#ifdef CONFIG_R8169_NAPI
+		RTL_W16(IntrMask, rtl8169_intr_mask & ~rtl8169_napi_event);
+		tp->intr_mask = ~rtl8169_napi_event;
+
+		if (likely(netif_rx_schedule_prep(dev)))
+			__netif_rx_schedule(dev);
+		else {
+			printk(KERN_INFO "%s: interrupt %x taken in poll\n",
+			       dev->name, status);	
+		}
+		break;
+#else
 		// Rx interrupt 
 		if (status & (RxOK | RxUnderrun | RxOverflow | RxFIFOOver)) {
 			rtl8169_rx_interrupt(dev, tp, ioaddr);
@@ -1563,6 +1599,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 			rtl8169_tx_interrupt(dev, tp, ioaddr);
 			spin_unlock(&tp->lock);
 		}
+#endif
 
 		boguscnt--;
 	} while (boguscnt > 0);
@@ -1576,6 +1613,36 @@ rtl8169_interrupt(int irq, void *dev_ins
 	return IRQ_RETVAL(handled);
 }
 
+#ifdef CONFIG_R8169_NAPI
+static int rtl8169_poll(struct net_device *dev, int *budget)
+{
+	unsigned int work_done, work_to_do = min(*budget, dev->quota);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+
+	work_done = rtl8169_rx_interrupt(dev, tp, ioaddr);
+	rtl8169_tx_interrupt(dev, tp, ioaddr);
+
+	*budget -= work_done;
+	dev->quota -= work_done;
+
+	if ((work_done < work_to_do) || !netif_running(dev)) {
+		netif_rx_complete(dev);
+		tp->intr_mask = 0xffff;
+		/*
+		 * 20040426: the barrier is not strictly required but the
+		 * behavior of the irq handler could be less predictable
+		 * without it. Btw, the lack of flush for the posted pci
+		 * write is safe - FR
+		 */
+		smp_wmb();
+		RTL_W16(IntrMask, rtl8169_intr_mask);
+	}
+
+	return (work_done >= work_to_do);
+}
+#endif
+
 static int
 rtl8169_close(struct net_device *dev)
 {
diff -puN drivers/net/Kconfig~r8169-napi drivers/net/Kconfig
--- linux-2.6.6-rc3/drivers/net/Kconfig~r8169-napi	2004-05-01 01:46:29.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/Kconfig	2004-05-01 01:46:29.000000000 +0200
@@ -1979,6 +1979,11 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
+config R8169_NAPI
+	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
+	depends on R8169 && EXPERIMENTAL 
+
+
 config SK98LIN
 	tristate "Marvell Yukon Chipset / SysKonnect SK-98xx Support"
 	depends on PCI

_
