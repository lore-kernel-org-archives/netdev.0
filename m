From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc3-mm2 1/5] r8169: Tx timeout rework
Date: Mon, 4 Oct 2004 21:48:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004194826.GA18404@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tx timeout rework:
- the ring descriptors of the chipset and the ring index of the driver
  are synced during a reset of the device;
- rtl8169_interrupt: rtl8169_hw_reset() replaces the previous stop code.
  An implicit reset of the device is added but it makes no noticeable
  difference with the former behavior (i.e.: stop the chipset).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-200 drivers/net/r8169.c
--- linux-2.6.9-rc3/drivers/net/r8169.c~r8169-200	2004-10-04 21:13:45.000000000 +0200
+++ linux-2.6.9-rc3-fr/drivers/net/r8169.c	2004-10-04 21:15:41.000000000 +0200
@@ -400,6 +400,7 @@ struct rtl8169_private {
 	void (*phy_reset_enable)(void *);
 	unsigned int (*phy_reset_pending)(void *);
 	unsigned int (*link_ok)(void *);
+	struct work_struct task;
 };
 
 MODULE_AUTHOR("Realtek");
@@ -420,6 +421,8 @@ static int rtl8169_close(struct net_devi
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
+static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
+				void *);
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
@@ -1456,6 +1459,8 @@ rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_free_rx;
 
+	INIT_WORK(&tp->task, NULL, dev);
+
 	rtl8169_hw_start(dev);
 
 	rtl8169_request_timer(dev);
@@ -1475,6 +1480,18 @@ err_free_irq:
 	goto out;
 }
 
+static void rtl8169_hw_reset(void *ioaddr)
+{
+	/* Disable interrupts */
+	RTL_W16(IntrMask, 0x0000);
+
+	/* Reset the chipset */
+	RTL_W8(ChipCmd, CmdReset);
+
+	/* PCI commit */
+	RTL_R8(ChipCmd);
+}
+
 static void
 rtl8169_hw_start(struct net_device *dev)
 {
@@ -1518,8 +1535,6 @@ rtl8169_hw_start(struct net_device *dev)
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 	}
 
-	tp->cur_rx = 0;
-
 	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
 	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
 	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
@@ -1634,12 +1649,16 @@ static inline void rtl8169_mark_as_last_
 	desc->opts1 |= cpu_to_le32(RingEnd);
 }
 
+static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
+{
+	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
+}
+
 static int rtl8169_init_ring(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	tp->cur_rx = tp->dirty_rx = 0;
-	tp->cur_tx = tp->dirty_tx = 0;
+	rtl8169_init_ring_indexes(tp);
 
 	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
 	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));
@@ -1691,31 +1710,53 @@ static void rtl8169_tx_clear(struct rtl8
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
-static void
-rtl8169_tx_timeout(struct net_device *dev)
+static void rtl8169_schedule_work(struct net_device *dev, void (*task)(void *))
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
-	u8 tmp8;
 
-	printk(KERN_INFO "%s: TX Timeout\n", dev->name);
-	/* disable Tx, if not already */
-	tmp8 = RTL_R8(ChipCmd);
-	if (tmp8 & CmdTxEnb)
-		RTL_W8(ChipCmd, tmp8 & ~CmdTxEnb);
+	PREPARE_WORK(&tp->task, task, dev);
+	schedule_delayed_work(&tp->task, 4);
+}
 
-	/* Disable interrupts by clearing the interrupt mask. */
-	RTL_W16(IntrMask, 0x0000);
+static void rtl8169_reset_task(void *_data)
+{
+	struct net_device *dev = _data;
+	struct rtl8169_private *tp = netdev_priv(dev);
 
-	/* Stop a shared interrupt from scavenging while we are. */
-	spin_lock_irq(&tp->lock);
+	if (!netif_running(dev))
+		return;
+
+	synchronize_irq(dev->irq);
+
+	/* Wait for any pending NAPI task to complete */
+	netif_poll_disable(dev);
+
+	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr);
 	rtl8169_tx_clear(tp);
-	spin_unlock_irq(&tp->lock);
 
-	/* ...and finally, reset everything */
-	rtl8169_hw_start(dev);
+	if (tp->dirty_rx == tp->cur_rx) {
+		rtl8169_init_ring_indexes(tp);
+		rtl8169_hw_start(dev);
+		netif_wake_queue(dev);
+	} else {
+		if (net_ratelimit()) {
+			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
+			       dev->name);
+		}
+		rtl8169_schedule_work(dev, rtl8169_reset_task);
+	}
+}
+
+static void rtl8169_tx_timeout(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	printk(KERN_INFO "%s: TX Timeout\n", dev->name);
 
-	netif_wake_queue(dev);
+	rtl8169_hw_reset(tp->mmio_addr);
+
+	/* Let's wait a bit while any (async) irq lands on */
+	rtl8169_schedule_work(dev, rtl8169_reset_task);
 }
 
 static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
@@ -2057,9 +2098,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (unlikely(status & SYSErr)) {
 			printk(KERN_ERR PFX "%s: PCI error (status: 0x%04x)."
 			       " Device disabled.\n", dev->name, status);
-			RTL_W8(ChipCmd, 0x00);
-			RTL_W16(IntrMask, 0x0000);
-			RTL_R16(IntrMask);
+			rtl8169_hw_reset(ioaddr);
 			break;
 		}
 
@@ -2138,6 +2177,8 @@ rtl8169_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
+	flush_scheduled_work();
+
 	rtl8169_delete_timer(dev);
 
 	spin_lock_irq(&tp->lock);

_
