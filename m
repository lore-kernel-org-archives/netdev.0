From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 2/3] r8169: Large Send enablement
Date: Tue, 2 Nov 2004 12:03:21 -0600
Message-ID: <200411021203.22003.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_qv8hBO1M2IDuHYd"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_qv8hBO1M2IDuHYd
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch enables driver support of MTUs greater than 1500.  Though the 
adapter documentation says that maximum MTU is 16k, the largest packet I 
could send was 7440.  So, I am setting that as the max mtu until I can figure 
out why the adapter misbehaves with packets larger than 7440.

I have tested this code on ppc64 and x86_64.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- r8169-post-patch1.c 2004-11-02 10:37:18.190155864 -0600
+++ r8169.c     2004-11-02 10:37:31.035203120 -0600
@@ -114,14 +114,13 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST   6       /* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST   6       /* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld    0x3F    /* 0x3F means NO early transmit */
-#define RxPacketMaxSize        0x0800  /* Maximum size supported is 16K-1 */
+#define RxPacketMaxSize        0x3FE8  /* Maximum size supported is 
16K-(1+Header+CRC+VLAN ) */
 #define InterFrameGap  0x03    /* 3 means InterFrameGap = the shortest one */

 #define R8169_REGS_SIZE                256
 #define R8169_NAPI_WEIGHT      64
 #define NUM_TX_DESC    64      /* Number of Tx descriptor registers */
 #define NUM_RX_DESC    256     /* Number of Rx descriptor registers */
-#define RX_BUF_SIZE    1536    /* Rx Buffer size */
 #define R8169_TX_RING_BYTES    (NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES    (NUM_RX_DESC * sizeof(struct RxDesc))

@@ -427,6 +426,8 @@ static void rtl8169_tx_timeout(struct ne
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private 
*,
                                void __iomem *);
+static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
@@ -1239,7 +1240,7 @@ rtl8169_init_board(struct pci_dev *pdev,
        }
        tp->chipset = i;

-       tp->rx_buf_sz = RX_BUF_SIZE;
+       tp->rx_buf_sz = dev->mtu + ETH_HLEN + 8;

        *ioaddr_out = ioaddr;
        *dev_out = dev;
@@ -1322,6 +1323,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
        dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
        dev->irq = pdev->irq;
        dev->base_addr = (unsigned long) ioaddr;
+       dev->change_mtu = rtl8169_change_mtu;

 #ifdef CONFIG_R8169_NAPI
        dev->poll = rtl8169_poll;
@@ -1536,8 +1538,8 @@ rtl8169_hw_start(struct net_device *dev)
        RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
        RTL_W8(EarlyTxThres, EarlyTxThld);

-       // For gigabit rtl8169
-       RTL_W16(RxMaxSize, RxPacketMaxSize);
+       // For gigabit rtl8169, MTU + header + CRC + VLAN
+       RTL_W16(RxMaxSize, tp->rx_buf_sz);

        // Set Rx Config register
        i = rtl8169_rx_config |
@@ -1578,6 +1580,24 @@ rtl8169_hw_start(struct net_device *dev)
        netif_start_queue(dev);
 }

+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
+{
+       struct rtl8169_private *tp = netdev_priv(dev);
+
+       if (new_mtu < ETH_ZLEN || new_mtu > 7400)
+               return -EINVAL;
+
+       if (netif_running(dev))
+               rtl8169_close(dev);
+
+       dev->mtu = new_mtu;
+       tp->rx_buf_sz = new_mtu + ETH_HLEN + 8;
+
+       rtl8169_open(dev);
+
+       return 0;
+}
+
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
        desc->addr = 0x0badbadbadbadbadull;

--Boundary-00=_qv8hBO1M2IDuHYd
Content-Type: text/x-diff;
  charset="us-ascii";
  name="r8169-large-send-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="r8169-large-send-2.patch"

--- r8169-post-patch1.c	2004-11-02 10:37:18.190155864 -0600
+++ r8169.c	2004-11-02 10:37:31.035203120 -0600
@@ -114,14 +114,13 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
-#define RxPacketMaxSize	0x0800	/* Maximum size supported is 16K-1 */
+#define RxPacketMaxSize	0x3FE8	/* Maximum size supported is 16K-(1+Header+CRC+VLAN ) */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
-#define RX_BUF_SIZE	1536	/* Rx Buffer size */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
@@ -427,6 +426,8 @@ static void rtl8169_tx_timeout(struct ne
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
+static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
@@ -1239,7 +1240,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 	tp->chipset = i;
 
-	tp->rx_buf_sz = RX_BUF_SIZE;
+	tp->rx_buf_sz = dev->mtu + ETH_HLEN + 8; 
 
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
@@ -1322,6 +1323,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
+	dev->change_mtu = rtl8169_change_mtu;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
@@ -1536,8 +1538,8 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	// For gigabit rtl8169, MTU + header + CRC + VLAN
+	RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1578,6 +1580,24 @@ rtl8169_hw_start(struct net_device *dev)
 	netif_start_queue(dev);
 }
 
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	if (new_mtu < ETH_ZLEN || new_mtu > 7400)
+		return -EINVAL;
+		
+	if (netif_running(dev)) 
+		rtl8169_close(dev);
+	
+	dev->mtu = new_mtu;
+	tp->rx_buf_sz = new_mtu + ETH_HLEN + 8;
+	
+	rtl8169_open(dev);
+
+	return 0;	
+}
+
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
 	desc->addr = 0x0badbadbadbadbadull;

--Boundary-00=_qv8hBO1M2IDuHYd--
