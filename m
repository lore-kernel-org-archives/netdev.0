From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] natsemi 2: support packets > 1518 bytes
Date: Fri, 25 Jun 2004 22:54:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40DC9105.60901@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080309080001000203030604"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080309080001000203030604
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

attached is the promised cleanup of the vlan handling:
By default, the DP83815/6 nics reject packets larger than 1518 bytes. 
This must be disabled by setting the RxAcceptLong flag, otherwise vlan 
doesn't work. This is now properly implemented.

The patch also adds support for larger than normal frames: the nic can 
support up to 2046 byte frames, i.e. mtu 2024. I've tested mtu 2000 
between two natsemi nics: tcp bandwidth up from 11.7 to 11.9 MB/sec.
Additionally, it fixes a bug in the tx overrun handling: The drain 
threshold must be limited to 1472 bytes, larger settings are documented 
to cause internal nic corruptions.

Jeff, could you apply it to your tree and forward it?

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------080309080001000203030604
Content-Type: text/plain;
 name="patch-natsemi-02-long"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-natsemi-02-long"

--- 2.6/drivers/net/natsemi.c	2004-06-25 21:35:53.321129712 +0200
+++ build-2.6/drivers/net/natsemi.c	2004-06-25 21:36:11.809319080 +0200
@@ -236,7 +236,14 @@
 #define NATSEMI_REGS_SIZE	(NATSEMI_NREGS * sizeof(u32))
 #define NATSEMI_EEPROM_SIZE	24 /* 12 16-bit values */
 
-#define PKT_BUF_SZ		1536 /* Size of each temporary Rx buffer. */
+/* Buffer sizes:
+ * The nic writes 32-bit values, even if the upper bytes of
+ * a 32-bit value are beyond the end of the buffer.
+ */
+#define NATSEMI_HEADERS		22	/* 2*mac,type,vlan,crc */
+#define NATSEMI_PADDING		16	/* 2 bytes should be sufficient */
+#define NATSEMI_LONGPKT		1518	/* limit for normal packets */
+#define NATSEMI_RX_LIMIT	2046	/* maximum supported by hardware */
 
 /* These identify the driver base version and may not be removed. */
 static char version[] __devinitdata =
@@ -539,6 +546,22 @@
 	TxCarrierIgn		= 0x80000000
 };
 
+/* 
+ * Tx Configuration:
+ * - 256 byte DMA burst length
+ * - fill threshold 512 bytes (i.e. restart DMA when 512 bytes are free)
+ * - 64 bytes initial drain threshold (i.e. begin actual transmission
+ *   when 64 byte are in the fifo)
+ * - on tx underruns, increase drain threshold by 64.
+ * - at most use a drain threshold of 1472 bytes: The sum of the fill
+ *   threshold and the drain threshold must be less than 2016 bytes.
+ *
+ */
+#define TX_FLTH_VAL		((512/32) << 8)
+#define TX_DRTH_VAL_START	(64/32)
+#define TX_DRTH_VAL_INC		2
+#define TX_DRTH_VAL_LIMIT	(1472/32)
+
 enum RxConfig_bits {
 	RxDrthMask		= 0x3e,
 	RxMxdmaMask		= 0x700000,
@@ -555,6 +578,7 @@
 	RxAcceptRunt		= 0x40000000,
 	RxAcceptErr		= 0x80000000
 };
+#define RX_DRTH_VAL		(128/8)
 
 enum ClkRun_bits {
 	PMEEnable		= 0x100,
@@ -731,6 +755,7 @@
 static void netdev_error(struct net_device *dev, int intr_status);
 static void netdev_rx(struct net_device *dev);
 static void netdev_tx_done(struct net_device *dev);
+static int natsemi_change_mtu(struct net_device *dev, int new_mtu);
 static void __set_rx_mode(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static void __get_stats(struct net_device *dev);
@@ -897,6 +922,7 @@
 	dev->stop = &netdev_close;
 	dev->get_stats = &get_stats;
 	dev->set_multicast_list = &set_rx_mode;
+	dev->change_mtu = &natsemi_change_mtu;
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
@@ -1680,15 +1706,16 @@
 	 * ECRETRY=1
 	 * ATP=1
 	 */
-	np->tx_config = TxAutoPad | TxCollRetry | TxMxdma_256 | (0x1002);
+	np->tx_config = TxAutoPad | TxCollRetry | TxMxdma_256 |
+				TX_FLTH_VAL | TX_DRTH_VAL_START;
 	writel(np->tx_config, ioaddr + TxConfig);
 
 	/* DRTH 0x10: start copying to memory if 128 bytes are in the fifo
 	 * MXDMA 0: up to 256 byte bursts
 	 */
-	np->rx_config = RxMxdma_256 | 0x20;
+	np->rx_config = RxMxdma_256 | RX_DRTH_VAL;
 	/* if receive ring now has bigger buffers than normal, enable jumbo */
-	if (np->rx_buf_sz > PKT_BUF_SZ)
+	if (np->rx_buf_sz > NATSEMI_LONGPKT)
 		np->rx_config |= RxAcceptLong;
 
 	writel(np->rx_config, ioaddr + RxConfig);
@@ -1870,7 +1897,7 @@
 		struct sk_buff *skb;
 		int entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
-			unsigned int buflen = np->rx_buf_sz + RX_OFFSET;
+			unsigned int buflen = np->rx_buf_sz+NATSEMI_PADDING;
 			skb = dev_alloc_skb(buflen);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
@@ -1889,6 +1916,15 @@
 	}
 }
 
+static void set_bufsize(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	if (dev->mtu <= ETH_DATA_LEN)
+		np->rx_buf_sz = ETH_DATA_LEN + NATSEMI_HEADERS;
+	else
+		np->rx_buf_sz = dev->mtu + NATSEMI_HEADERS;
+}
+
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void init_ring(struct net_device *dev)
 {
@@ -1909,9 +1945,8 @@
 	np->dirty_rx = 0;
 	np->cur_rx = RX_RING_SIZE;
 	np->oom = 0;
-	np->rx_buf_sz = PKT_BUF_SZ;
-	if (dev->mtu > ETH_DATA_LEN)
-		np->rx_buf_sz += dev->mtu - ETH_DATA_LEN;
+	set_bufsize(dev);
+
 	np->rx_head_desc = &np->rx_ring[0];
 
 	/* Please be carefull before changing this loop - at least gcc-2.95.1
@@ -1946,10 +1981,10 @@
 	}
 }
 
-static void drain_ring(struct net_device *dev)
+static void drain_rx(struct net_device *dev)
 {
- 	struct netdev_private *np = netdev_priv(dev);
-	unsigned int buflen = np->rx_buf_sz + RX_OFFSET;
+	struct netdev_private *np = netdev_priv(dev);
+	unsigned int buflen = np->rx_buf_sz;
 	int i;
 
 	/* Free all the skbuffs in the Rx queue. */
@@ -1964,6 +1999,11 @@
 		}
 		np->rx_skbuff[i] = NULL;
 	}
+}
+
+static void drain_ring(struct net_device *dev)
+{
+	drain_rx(dev);
 	drain_tx(dev);
 }
 
@@ -1975,17 +2015,11 @@
 		np->rx_ring, np->ring_dma);
 }
 
-static void reinit_ring(struct net_device *dev)
+static void reinit_rx(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
-	/* drain TX ring */
-	drain_tx(dev);
-	np->dirty_tx = np->cur_tx = 0;
-	for (i=0;i<TX_RING_SIZE;i++)
-		np->tx_ring[i].cmd_status = 0;
-
 	/* RX Ring */
 	np->dirty_rx = 0;
 	np->cur_rx = RX_RING_SIZE;
@@ -1997,6 +2031,20 @@
 	refill_rx(dev);
 }
 
+static void reinit_ring(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	int i;
+
+	/* drain TX ring */
+	drain_tx(dev);
+	np->dirty_tx = np->cur_tx = 0;
+	for (i=0;i<TX_RING_SIZE;i++)
+		np->tx_ring[i].cmd_status = 0;
+
+	reinit_rx(dev);
+}
+
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -2154,7 +2202,7 @@
 	int entry = np->cur_rx % RX_RING_SIZE;
 	int boguscnt = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 	s32 desc_status = le32_to_cpu(np->rx_head_desc->cmd_status);
-	unsigned int buflen = np->rx_buf_sz + RX_OFFSET;
+	unsigned int buflen = np->rx_buf_sz;
 
 	/* If the driver owns the next entry it's a new packet. Send it up. */
 	while (desc_status < 0) { /* e.g. & DescOwn */
@@ -2263,12 +2311,18 @@
 		__get_stats(dev);
 	}
 	if (intr_status & IntrTxUnderrun) {
-		if ((np->tx_config & TxDrthMask) < 62)
-			np->tx_config += 2;
-		if (netif_msg_tx_err(np))
-			printk(KERN_NOTICE
-				"%s: increased Tx threshold, txcfg %#08x.\n",
-				dev->name, np->tx_config);
+		if ((np->tx_config & TxDrthMask) < TX_DRTH_VAL_LIMIT) {
+			np->tx_config += TX_DRTH_VAL_INC;
+			if (netif_msg_tx_err(np))
+				printk(KERN_NOTICE
+					"%s: increased tx threshold, txcfg %#08x.\n",
+					dev->name, np->tx_config);
+		} else {
+			if (netif_msg_tx_err(np))
+				printk(KERN_NOTICE
+					"%s: tx underrun with maximum tx threshold, txcfg %#08x.\n",
+					dev->name, np->tx_config);
+		}
 		writel(np->tx_config, ioaddr + TxConfig);
 	}
 	if (intr_status & WOLPkt && netif_msg_wol(np)) {
@@ -2355,6 +2409,36 @@
 	np->cur_rx_mode = rx_mode;
 }
 
+static int natsemi_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (new_mtu < 64 || new_mtu > NATSEMI_RX_LIMIT-NATSEMI_HEADERS)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	/* synchronized against open : rtnl_lock() held by caller */
+	if (netif_running(dev)) {
+		struct netdev_private *np = netdev_priv(dev);
+		long ioaddr = dev->base_addr;
+
+		disable_irq(dev->irq);
+		spin_lock(&np->lock);
+		/* stop engines */
+		natsemi_stop_rxtx(dev);
+		/* drain rx queue */
+		drain_rx(dev);
+		/* change buffers */
+		set_bufsize(dev);
+		reinit_rx(dev);
+		writel(np->ring_dma, ioaddr + RxRingPtr);
+		/* restart engines */
+		writel(RxOn | TxOn, ioaddr + ChipCmd);
+		spin_unlock(&np->lock);
+		enable_irq(dev->irq);
+	}
+	return 0;
+}
+
 static void set_rx_mode(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -2876,6 +2960,7 @@
 	}
 	return 0;
 }
+
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(rq);

--------------080309080001000203030604--
