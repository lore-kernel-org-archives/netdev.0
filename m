From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH] r8169: Large Send enablement, part 2
Date: Wed, 3 Nov 2004 18:17:06 -0600
Message-ID: <200411031817.06629.jdmason@us.ibm.com>
References: <200411021203.22003.jdmason@us.ibm.com> <20041102191103.GA24860@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_CUXiBVwclKE1ew4"
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041102191103.GA24860@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_CUXiBVwclKE1ew4
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I have tried to address all of the issues with the previous large send patch 
in the following patch (and I have confirmed it works on ppc64).  

--- r8169.c.orig        2004-11-02 11:01:02.000000000 -0600
+++ r8169.c     2004-11-03 17:58:49.830373784 -0600
@@ -85,10 +85,14 @@ VERSION 1.6LK       <2004/04/14>
 #define rtl8169_rx_skb                 netif_receive_skb
 #define rtl8169_rx_hwaccel_skb         vlan_hwaccel_rx
 #define rtl8169_rx_quota(count, quota) min(count, quota)
+#define rtl8169_poll_disable(dev)      netif_poll_disable(dev)
+#define rtl8169_poll_enable(dev)       netif_poll_enable(dev)
 #else
 #define rtl8169_rx_skb                 netif_rx
 #define rtl8169_rx_hwaccel_skb         vlan_hwaccel_receive_skb
 #define rtl8169_rx_quota(count, quota) count
+#define rtl8169_poll_disable(dev)
+#define rtl8169_poll_enable(dev)
 #endif

 /* media options */
@@ -112,14 +116,13 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST   6       /* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST   6       /* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld    0x3F    /* 0x3F means NO early transmit */
-#define RxPacketMaxSize        0x0800  /* Maximum size supported is 16K-1 */
+#define RxPacketMaxSize        0x3FFE  /* Maximum size supported is 16K-1 */
 #define InterFrameGap  0x03    /* 3 means InterFrameGap = the shortest one */

 #define R8169_REGS_SIZE                256
 #define R8169_NAPI_WEIGHT      64
 #define NUM_TX_DESC    64      /* Number of Tx descriptor registers */
 #define NUM_RX_DESC    256     /* Number of Rx descriptor registers */
-#define RX_BUF_SIZE    1536    /* Rx Buffer size */
 #define R8169_TX_RING_BYTES    (NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES    (NUM_RX_DESC * sizeof(struct RxDesc))

@@ -425,6 +428,9 @@ static void rtl8169_tx_timeout(struct ne
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private 
*,
                                void __iomem *);
+static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static int rtl8169_down(struct net_device *dev);
+
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
@@ -1237,8 +1243,6 @@ rtl8169_init_board(struct pci_dev *pdev,
        }
        tp->chipset = i;

-       tp->rx_buf_sz = RX_BUF_SIZE;
-
        *ioaddr_out = ioaddr;
        *dev_out = dev;
 out:
@@ -1320,6 +1324,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
        dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
        dev->irq = pdev->irq;
        dev->base_addr = (unsigned long) ioaddr;
+       dev->change_mtu = rtl8169_change_mtu;

 #ifdef CONFIG_R8169_NAPI
        dev->poll = rtl8169_poll;
@@ -1455,6 +1460,8 @@ rtl8169_open(struct net_device *dev)
        struct pci_dev *pdev = tp->pci_dev;
        int retval;

+       tp->rx_buf_sz = dev->mtu + ETH_HLEN + 8;
+
        retval =
            request_irq(dev->irq, rtl8169_interrupt, SA_SHIRQ, dev->name, 
dev);
        if (retval < 0)
@@ -1534,8 +1541,8 @@ rtl8169_hw_start(struct net_device *dev)
        RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
        RTL_W8(EarlyTxThres, EarlyTxThld);

-       // For gigabit rtl8169
-       RTL_W16(RxMaxSize, RxPacketMaxSize);
+       // For gigabit rtl8169, MTU + header + CRC + VLAN
+       RTL_W16(RxMaxSize, tp->rx_buf_sz);

        // Set Rx Config register
        i = rtl8169_rx_config |
@@ -1576,6 +1583,36 @@ rtl8169_hw_start(struct net_device *dev)
        netif_start_queue(dev);
 }

+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
+{
+       struct rtl8169_private *tp = netdev_priv(dev);
+       int retval;
+
+       if (new_mtu < ETH_ZLEN || new_mtu > RxPacketMaxSize)
+               return -EINVAL;
+
+       dev->mtu = new_mtu;
+
+       if (!netif_running(dev))
+               return 0;
+
+       rtl8169_down(dev);
+
+       tp->rx_buf_sz = new_mtu + ETH_HLEN + 8;
+
+       retval = rtl8169_init_ring(dev);
+       if (retval < 0)
+               return retval;
+
+       rtl8169_hw_start(dev);
+
+       rtl8169_poll_enable(dev);
+
+       rtl8169_request_timer(dev);
+
+       return 0;
+}
+
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
        desc->addr = 0x0badbadbadbadbadull;
@@ -1745,7 +1782,7 @@ static void rtl8169_wait_for_quiescence(
        synchronize_irq(dev->irq);

        /* Wait for any pending NAPI task to complete */
-       netif_poll_disable(dev);
+       rtl8169_poll_disable(dev);
 }

 static void rtl8169_reinit_task(void *_data)
@@ -1785,6 +1822,7 @@ static void rtl8169_reset_task(void *_da
                rtl8169_init_ring_indexes(tp);
                rtl8169_hw_start(dev);
                netif_wake_queue(dev);
+               rtl8169_poll_enable(dev);
        } else {
                if (net_ratelimit()) {
                        printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
@@ -2255,19 +2293,17 @@ static int rtl8169_poll(struct net_devic
 }
 #endif

-static int
-rtl8169_close(struct net_device *dev)
+static int rtl8169_down(struct net_device *dev)
 {
        struct rtl8169_private *tp = netdev_priv(dev);
-       struct pci_dev *pdev = tp->pci_dev;
        void __iomem *ioaddr = tp->mmio_addr;

+       rtl8169_delete_timer(dev);
+
        netif_stop_queue(dev);

        flush_scheduled_work();

-       rtl8169_delete_timer(dev);
-
        spin_lock_irq(&tp->lock);

        /* Stop the chip's Tx and Rx DMA processes. */
@@ -2282,14 +2318,30 @@ rtl8169_close(struct net_device *dev)

        spin_unlock_irq(&tp->lock);

-       free_irq(dev->irq, dev);
+       synchronize_irq(dev->irq);
+
+       rtl8169_poll_disable(dev);

-       netif_poll_disable(dev);
+       /* Give a racing hard_start_xmit a few cycles to complete. */
+       set_current_state(TASK_UNINTERRUPTIBLE);
+       schedule_timeout(1);

        rtl8169_tx_clear(tp);

        rtl8169_rx_clear(tp);

+       return 0;
+}
+
+static int rtl8169_close(struct net_device *dev)
+{
+       struct rtl8169_private *tp = netdev_priv(dev);
+       struct pci_dev *pdev = tp->pci_dev;
+
+       rtl8169_down(dev);
+
+       free_irq(dev->irq, dev);
+
        pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
                            tp->RxPhyAddr);
        pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,

--Boundary-00=_CUXiBVwclKE1ew4
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="r8169-large-send.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="r8169-large-send.patch"

--- r8169.c.orig	2004-11-02 11:01:02.000000000 -0600
+++ r8169.c	2004-11-03 17:58:49.830373784 -0600
@@ -85,10 +85,14 @@ VERSION 1.6LK	<2004/04/14>
 #define rtl8169_rx_skb			netif_receive_skb
 #define rtl8169_rx_hwaccel_skb		vlan_hwaccel_rx
 #define rtl8169_rx_quota(count, quota)	min(count, quota)
+#define rtl8169_poll_disable(dev)	netif_poll_disable(dev)
+#define rtl8169_poll_enable(dev)	netif_poll_enable(dev)
 #else
 #define rtl8169_rx_skb			netif_rx
 #define rtl8169_rx_hwaccel_skb		vlan_hwaccel_receive_skb
 #define rtl8169_rx_quota(count, quota)	count
+#define rtl8169_poll_disable(dev)
+#define rtl8169_poll_enable(dev)
 #endif
 
 /* media options */
@@ -112,14 +116,13 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
-#define RxPacketMaxSize	0x0800	/* Maximum size supported is 16K-1 */
+#define RxPacketMaxSize	0x3FFE	/* Maximum size supported is 16K-1 */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
-#define RX_BUF_SIZE	1536	/* Rx Buffer size */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
@@ -425,6 +428,9 @@ static void rtl8169_tx_timeout(struct ne
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
+static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static int rtl8169_down(struct net_device *dev);
+
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
@@ -1237,8 +1243,6 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 	tp->chipset = i;
 
-	tp->rx_buf_sz = RX_BUF_SIZE;
-
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
 out:
@@ -1320,6 +1324,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
+	dev->change_mtu = rtl8169_change_mtu;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
@@ -1455,6 +1460,8 @@ rtl8169_open(struct net_device *dev)
 	struct pci_dev *pdev = tp->pci_dev;
 	int retval;
 
+	tp->rx_buf_sz = dev->mtu + ETH_HLEN + 8; 
+
 	retval =
 	    request_irq(dev->irq, rtl8169_interrupt, SA_SHIRQ, dev->name, dev);
 	if (retval < 0)
@@ -1534,8 +1541,8 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	// For gigabit rtl8169, MTU + header + CRC + VLAN
+	RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1576,6 +1583,36 @@ rtl8169_hw_start(struct net_device *dev)
 	netif_start_queue(dev);
 }
 
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	int retval;
+
+	if (new_mtu < ETH_ZLEN || new_mtu > RxPacketMaxSize)
+		return -EINVAL;
+	
+	dev->mtu = new_mtu;
+
+	if (!netif_running(dev)) 
+		return 0;
+
+	rtl8169_down(dev);	
+	
+	tp->rx_buf_sz = new_mtu + ETH_HLEN + 8;
+	
+	retval = rtl8169_init_ring(dev);
+	if (retval < 0)
+		return retval;
+
+	rtl8169_hw_start(dev);
+	
+	rtl8169_poll_enable(dev);
+
+	rtl8169_request_timer(dev);
+
+	return 0;
+}
+
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
 	desc->addr = 0x0badbadbadbadbadull;
@@ -1745,7 +1782,7 @@ static void rtl8169_wait_for_quiescence(
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
-	netif_poll_disable(dev);
+	rtl8169_poll_disable(dev);
 }
 
 static void rtl8169_reinit_task(void *_data)
@@ -1785,6 +1822,7 @@ static void rtl8169_reset_task(void *_da
 		rtl8169_init_ring_indexes(tp);
 		rtl8169_hw_start(dev);
 		netif_wake_queue(dev);
+		rtl8169_poll_enable(dev);
 	} else {
 		if (net_ratelimit()) {
 			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
@@ -2255,19 +2293,17 @@ static int rtl8169_poll(struct net_devic
 }
 #endif
 
-static int
-rtl8169_close(struct net_device *dev)
+static int rtl8169_down(struct net_device *dev)
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
@@ -2282,14 +2318,30 @@ rtl8169_close(struct net_device *dev)
 
 	spin_unlock_irq(&tp->lock);
 
-	free_irq(dev->irq, dev);
+	synchronize_irq(dev->irq);
+
+	rtl8169_poll_disable(dev);
 
-	netif_poll_disable(dev);
+	/* Give a racing hard_start_xmit a few cycles to complete. */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(1);
 
 	rtl8169_tx_clear(tp);
 
 	rtl8169_rx_clear(tp);
 
+	return 0;
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
+
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);
 	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,

--Boundary-00=_CUXiBVwclKE1ew4--
