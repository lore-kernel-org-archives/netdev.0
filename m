From: akpm@osdl.org
Subject: [patch 07/10] r8169: Large Send enablement
Date: Tue, 04 Jan 2005 21:59:33 -0800
Message-ID: <200501050559.j055xg614698@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org,
        romieu@fr.zoreil.com, jdmason@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Francois Romieu <romieu@fr.zoreil.com>

Large Send enablement.

Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/r8169.c |   80 ++++++++++++++++++++++++++++++++++++--------
 1 files changed, 67 insertions(+), 13 deletions(-)

diff -puN drivers/net/r8169.c~r8169-large-send-enablement drivers/net/r8169.c
--- 25/drivers/net/r8169.c~r8169-large-send-enablement	2005-01-04 21:57:36.194631864 -0800
+++ 25-akpm/drivers/net/r8169.c	2005-01-04 21:57:44.830319040 -0800
@@ -112,7 +112,7 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
-#define RxPacketMaxSize	0x0800	/* Maximum size supported is 16K-1 */
+#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
@@ -427,6 +427,9 @@ static void rtl8169_tx_timeout(struct ne
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
+static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static void rtl8169_down(struct net_device *dev);
+
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
@@ -1238,8 +1241,6 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 	tp->chipset = i;
 
-	tp->rx_buf_sz = RX_BUF_SIZE;
-
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
 out:
@@ -1321,6 +1322,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
+	dev->change_mtu = rtl8169_change_mtu;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
@@ -1449,13 +1451,22 @@ static int rtl8169_resume(struct pci_dev
                                                                                 
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
@@ -1535,8 +1546,8 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	// For gigabit rtl8169, MTU + header + CRC + VLAN
+	RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1577,6 +1588,37 @@ rtl8169_hw_start(struct net_device *dev)
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
@@ -2265,19 +2307,17 @@ static int rtl8169_poll(struct net_devic
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
@@ -2292,13 +2332,27 @@ rtl8169_close(struct net_device *dev)
 
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
