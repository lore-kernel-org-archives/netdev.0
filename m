From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 1/2] forcedeth: Add hardware tx checksum support
Date: Sun, 18 Sep 2005 16:01:20 +0200
Message-ID: <432D7330.6090001@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090809010604010806080805"
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090809010604010806080805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Recent forcedeth nics support checksum offloading for tx.
The attached patch, written by Ayaz Abdulla, adds the support to the driver.
It also cleans up the handling of the three dma ring entry formats that 
are supported by the driver.

Signed-off-By: Manfred Spraul <manfred@colorfullife.com>

--------------090809010604010806080805
Content-Type: text/plain;
 name="patch-forcedeth-043-txchecksum"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-043-txchecksum"

--- orig-2.6/drivers/net/forcedeth.c	2005-09-06 11:46:05.000000000 -0700
+++ 2.6/drivers/net/forcedeth.c	2005-09-06 11:45:15.000000000 -0700
@@ -95,6 +95,7 @@
  *			   of nv_remove
  *	0.42: 06 Aug 2005: Fix lack of link speed initialization
  *			   in the second (and later) nv_open call
+ *      0.43: 10 Aug 2005: Add support for tx checksum.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -106,7 +107,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.41"
+#define FORCEDETH_VERSION		"0.43"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -145,6 +146,7 @@
 #define DEV_NEED_LINKTIMER	0x0002	/* poll link settings. Relies on the timer irq */
 #define DEV_HAS_LARGEDESC	0x0004	/* device supports jumbo frames and needs packet format 2 */
 #define DEV_HAS_HIGH_DMA        0x0008  /* device supports 64bit dma */
+#define DEV_HAS_CHECKSUM        0x0010  /* device supports tx and rx checksum offloads */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -241,6 +243,9 @@
 #define NVREG_TXRXCTL_IDLE	0x0008
 #define NVREG_TXRXCTL_RESET	0x0010
 #define NVREG_TXRXCTL_RXCHECK	0x0400
+#define NVREG_TXRXCTL_DESC_1	0
+#define NVREG_TXRXCTL_DESC_2	0x02100
+#define NVREG_TXRXCTL_DESC_3	0x02200
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
@@ -335,6 +340,8 @@
 /* error and valid are the same for both */
 #define NV_TX2_ERROR		(1<<30)
 #define NV_TX2_VALID		(1<<31)
+#define NV_TX2_CHECKSUM_L3	(1<<27)
+#define NV_TX2_CHECKSUM_L4	(1<<26)
 
 #define NV_RX_DESCRIPTORVALID	(1<<16)
 #define NV_RX_MISSEDFRAME	(1<<17)
@@ -417,14 +424,14 @@
 
 /* 
  * desc_ver values:
- * This field has two purposes:
- * - Newer nics uses a different ring layout. The layout is selected by
- *   comparing np->desc_ver with DESC_VER_xy.
- * - It contains bits that are forced on when writing to NvRegTxRxControl.
+ * The nic supports three different descriptor types:
+ * - DESC_VER_1: Original
+ * - DESC_VER_2: support for jumbo frames.
+ * - DESC_VER_3: 64-bit format.
  */
-#define DESC_VER_1	0x0
-#define DESC_VER_2	(0x02100|NVREG_TXRXCTL_RXCHECK)
-#define DESC_VER_3      (0x02200|NVREG_TXRXCTL_RXCHECK)
+#define DESC_VER_1	1
+#define DESC_VER_2	2
+#define DESC_VER_3	3
 
 /* PHY defines */
 #define PHY_OUI_MARVELL	0x5043
@@ -491,6 +498,7 @@
 	u32 orig_mac[2];
 	u32 irqmask;
 	u32 desc_ver;
+	u32 txrxctl_bits;
 
 	void __iomem *base;
 
@@ -786,10 +794,10 @@
 	u8 __iomem *base = get_hwbase(dev);
 
 	dprintk(KERN_DEBUG "%s: nv_txrx_reset\n", dev->name);
-	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->desc_ver, base + NvRegTxRxControl);
+	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
 	udelay(NV_TXRX_RESET_DELAY);
-	writel(NVREG_TXRXCTL_BIT2 | np->desc_ver, base + NvRegTxRxControl);
+	writel(NVREG_TXRXCTL_BIT2 | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
 }
 
@@ -961,6 +969,7 @@
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	int nr = np->next_tx % TX_RING;
+	u32 tx_checksum = (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
 
 	np->tx_skbuff[nr] = skb;
 	np->tx_dma[nr] = pci_map_single(np->pci_dev, skb->data,skb->len,
@@ -976,10 +985,10 @@
 	spin_lock_irq(&np->lock);
 	wmb();
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-		np->tx_ring.orig[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags );
+		np->tx_ring.orig[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags | tx_checksum);
 	else
-		np->tx_ring.ex[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags );
-	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet packet %d queued for transmission.\n",
+		np->tx_ring.ex[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags | tx_checksum);
+	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet packet %d queued for transmission\n",
 				dev->name, np->next_tx);
 	{
 		int j;
@@ -997,7 +1006,7 @@
 	if (np->next_tx - np->nic_tx >= TX_LIMIT_STOP)
 		netif_stop_queue(dev);
 	spin_unlock_irq(&np->lock);
-	writel(NVREG_TXRXCTL_KICK|np->desc_ver, get_hwbase(dev) + NvRegTxRxControl);
+	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	pci_push(get_hwbase(dev));
 	return 0;
 }
@@ -1408,7 +1417,7 @@
 		writel( ((RX_RING-1) << NVREG_RINGSZ_RXSHIFT) + ((TX_RING-1) << NVREG_RINGSZ_TXSHIFT),
 			base + NvRegRingSizes);
 		pci_push(base);
-		writel(NVREG_TXRXCTL_KICK|np->desc_ver, get_hwbase(dev) + NvRegTxRxControl);
+		writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 		pci_push(base);
 
 		/* restart rx engine */
@@ -2114,9 +2123,9 @@
 	/* 5) continue setup */
 	writel(np->linkspeed, base + NvRegLinkSpeed);
 	writel(NVREG_UNKSETUP3_VAL1, base + NvRegUnknownSetupReg3);
-	writel(np->desc_ver, base + NvRegTxRxControl);
+	writel(np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
-	writel(NVREG_TXRXCTL_BIT1|np->desc_ver, base + NvRegTxRxControl);
+	writel(NVREG_TXRXCTL_BIT1|np->txrxctl_bits, base + NvRegTxRxControl);
 	reg_delay(dev, NvRegUnknownSetupReg5, NVREG_UNKSETUP5_BIT31, NVREG_UNKSETUP5_BIT31,
 			NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX,
 			KERN_INFO "open: SetupReg5, Bit 31 remained off\n");
@@ -2314,18 +2323,26 @@
 			printk(KERN_INFO "forcedeth: 64-bit DMA failed, using 32-bit addressing for device %s.\n",
 					pci_name(pci_dev));
 		}
+		np->txrxctl_bits = NVREG_TXRXCTL_DESC_3;
 	} else if (id->driver_data & DEV_HAS_LARGEDESC) {
 		/* packet format 2: supports jumbo frames */
 		np->desc_ver = DESC_VER_2;
+		np->txrxctl_bits = NVREG_TXRXCTL_DESC_2;
 	} else {
 		/* original packet format */
 		np->desc_ver = DESC_VER_1;
+		np->txrxctl_bits = NVREG_TXRXCTL_DESC_1;
 	}
 
 	np->pkt_limit = NV_PKTLIMIT_1;
 	if (id->driver_data & DEV_HAS_LARGEDESC)
 		np->pkt_limit = NV_PKTLIMIT_2;
 
+	if (id->driver_data & DEV_HAS_CHECKSUM) {
+		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
+		dev->features |= NETIF_F_HW_CSUM;
+	}
+
 	err = -ENOMEM;
 	np->base = ioremap(addr, NV_PCI_REGSZ);
 	if (!np->base)
@@ -2525,35 +2542,35 @@
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_4),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_5),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_6),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_7),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_8),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_9),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_10),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_11),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_12),
@@ -2565,11 +2582,11 @@
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
 	},
 	{0,},
 };

--------------090809010604010806080805--
