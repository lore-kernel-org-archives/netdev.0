From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.10-rc2-netdev1 3/4] r8169: Large Send enablement
Date: Tue, 16 Nov 2004 23:34:39 +0100
Message-ID: <20041116223439.GB16781@electric-eye.fr.zoreil.com>
References: <20041116223040.GA16715@electric-eye.fr.zoreil.com> <20041116223332.GA16781@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041116223332.GA16781@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Large Send enablement.

Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jon Mason <jdmason@us.ibm.com>

diff -puN drivers/net/r8169.c~r8169-260 drivers/net/r8169.c
--- linux-2.6.10-rc2-mm1.orig/drivers/net/r8169.c~r8169-260	2004-11-16 21:12:34.000000000 +0100
+++ linux-2.6.10-rc2-mm1/drivers/net/r8169.c	2004-11-16 22:26:11.000000000 +0100
@@ -112,7 +112,7 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
-#define RxPacketMaxSize	0x0800	/* Maximum size supported is 16K-1 */
+#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
@@ -426,6 +426,9 @@ static void rtl8169_tx_timeout(struct ne
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
+static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static void rtl8169_down(struct net_device *dev);
+
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
@@ -1237,8 +1240,6 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 	tp->chipset = i;
 
-	tp->rx_buf_sz = RX_BUF_SIZE;
-
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
 out:
@@ -1320,6 +1321,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
+	dev->change_mtu = rtl8169_change_mtu;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
@@ -1448,13 +1450,22 @@ static int rtl8169_resume(struct pci_dev
                                                                                 
 #endif /* CONFIG_PM */
 
-static int
-rtl8169_open(struct net_device *dev)
+static void rtl8169_set_rxbufsize(struct rtl8169_private *tp,
+				  struct net_device *dev)
+{
+	unsigned int mtu = dev->mtu;
+
+	tp->rx_buf_sz = (mtu > RX_BUF_SIZE) ? mtu + ETH_HLEN + 8 : RX_BUF_SIZE;
+}
+
+static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
 	int retval;
 
+	rtl8169_set_rxbufsize(tp, dev);
+
 	retval =
 	    request_irq(dev->irq, rtl8169_interrupt, SA_SHIRQ, dev->name, dev);
 	if (retval < 0)
@@ -1534,8 +1545,8 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	// For gigabit rtl8169, MTU + header + CRC + VLAN
+	RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1576,6 +1587,37 @@ rtl8169_hw_start(struct net_device *dev)
 	netif_start_queue(dev);
 }
 
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	int ret = 0;
+
+	if (new_mtu < ETH_ZLEN || new_mtu > RxPacketMaxSize)
+		return -EINVAL;
+	
+	dev->mtu = new_mtu;
+
+	if (!netif_running(dev)) 
+		goto out;
+
+	rtl8169_down(dev);
+	
+	rtl8169_set_rxbufsize(tp, dev);
+	
+	ret = rtl8169_init_ring(dev);
+	if (ret < 0)
+		goto out;
+
+	rtl8169_hw_start(dev);
+	
+	netif_poll_enable(dev);
+
+	rtl8169_request_timer(dev);
+
+out:
+	return ret;
+}
+
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
 	desc->addr = 0x0badbadbadbadbadull;
@@ -2264,19 +2306,17 @@ static int rtl8169_poll(struct net_devic
 }
 #endif
 
-static int
-rtl8169_close(struct net_device *dev)
+static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	struct pci_dev *pdev = tp->pci_dev;
 	void __iomem *ioaddr = tp->mmio_addr;
 
+	rtl8169_delete_timer(dev);
+
 	netif_stop_queue(dev);
 
 	flush_scheduled_work();
 
-	rtl8169_delete_timer(dev);
-
 	spin_lock_irq(&tp->lock);
 
 	/* Stop the chip's Tx and Rx DMA processes. */
@@ -2291,13 +2331,27 @@ rtl8169_close(struct net_device *dev)
 
 	spin_unlock_irq(&tp->lock);
 
-	free_irq(dev->irq, dev);
+	synchronize_irq(dev->irq);
 
 	netif_poll_disable(dev);
 
+	/* Give a racing hard_start_xmit a few cycles to complete. */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(1);
+
 	rtl8169_tx_clear(tp);
 
 	rtl8169_rx_clear(tp);
+}
+
+static int rtl8169_close(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl8169_down(dev);
+	
+	free_irq(dev->irq, dev);
 
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);

_
