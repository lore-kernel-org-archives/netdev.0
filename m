From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: limit tx to 16
Date: Mon, 10 Mar 2008 14:58:21 -0500
Message-ID: <47D592DD.4070300@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070807050403040807050300"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:3567 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbYCJV7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 17:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070807050403040807050300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is a critical patch which adds a workaround for a HW bug. The patch 
will limit the number of outstanding tx packets to 16. Otherwise, the HW 
could send out packets with bad checksums.

The driver will still setup the tx packets into the ring, however, will 
only set the Valid bit on 16 packets at a time.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070807050403040807050300
Content-Type: text/plain;
 name="patch-forcedeth-txlimit16"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-txlimit16"

--- old/drivers/net/forcedeth.c	2008-02-27 23:16:26.000000000 -0800
+++ new/drivers/net/forcedeth.c	2008-02-28 12:20:02.000000000 -0800
@@ -184,6 +184,7 @@
 #define DEV_HAS_PAUSEFRAME_TX_V1   0x08000  /* device supports tx pause frames version 1 */
 #define DEV_HAS_PAUSEFRAME_TX_V2   0x10000  /* device supports tx pause frames version 2 */
 #define DEV_HAS_PAUSEFRAME_TX_V3   0x20000  /* device supports tx pause frames version 3 */
+#define DEV_NEED_TX_LIMIT          0x40000  /* device needs to limit tx */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -635,6 +636,8 @@
 #define NV_RESTART_TX         0x1
 #define NV_RESTART_RX         0x2
 
+#define NV_TX_LIMIT_COUNT     16
+
 /* statistics */
 struct nv_ethtool_str {
 	char name[ETH_GSTRING_LEN];
@@ -743,6 +746,8 @@
 	struct sk_buff *skb;
 	dma_addr_t dma;
 	unsigned int dma_len;
+	struct ring_desc_ex *first_tx_desc;
+	struct nv_skb_map *next_tx_ctx;
 };
 
 /*
@@ -827,6 +832,10 @@
 	union ring_type tx_ring;
 	u32 tx_flags;
 	int tx_ring_size;
+	int tx_limit;
+	u32 tx_pkts_in_progress;
+	struct nv_skb_map *tx_change_owner;
+	struct nv_skb_map *tx_end_flip;
 	int tx_stop;
 
 	/* vlan fields */
@@ -1707,6 +1716,9 @@
 		np->last_tx.ex = &np->tx_ring.ex[np->tx_ring_size-1];
 	np->get_tx_ctx = np->put_tx_ctx = np->first_tx_ctx = np->tx_skb;
 	np->last_tx_ctx = &np->tx_skb[np->tx_ring_size-1];
+	np->tx_pkts_in_progress = 0;
+	np->tx_change_owner = NULL;
+	np->tx_end_flip = NULL;
 
 	for (i = 0; i < np->tx_ring_size; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
@@ -1720,6 +1732,9 @@
 		}
 		np->tx_skb[i].skb = NULL;
 		np->tx_skb[i].dma = 0;
+		np->tx_skb[i].dma_len = 0;
+		np->tx_skb[i].first_tx_desc = NULL;
+		np->tx_skb[i].next_tx_ctx = NULL;
 	}
 }
 
@@ -1771,7 +1786,14 @@
 		}
 		if (nv_release_txskb(dev, &np->tx_skb[i]))
 			dev->stats.tx_dropped++;
-	}
+		np->tx_skb[i].dma = 0;
+		np->tx_skb[i].dma_len = 0;
+		np->tx_skb[i].first_tx_desc = NULL;
+		np->tx_skb[i].next_tx_ctx = NULL;
+	}
+	np->tx_pkts_in_progress = 0;
+	np->tx_change_owner = NULL;
+	np->tx_end_flip = NULL;
 }
 
 static void nv_drain_rx(struct net_device *dev)
@@ -1948,6 +1970,7 @@
 	struct ring_desc_ex* start_tx;
 	struct ring_desc_ex* prev_tx;
 	struct nv_skb_map* prev_tx_ctx;
+	struct nv_skb_map* start_tx_ctx;
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
@@ -1965,6 +1988,7 @@
 	}
 
 	start_tx = put_tx = np->put_tx.ex;
+	start_tx_ctx = np->put_tx_ctx;
 
 	/* setup the header buffer */
 	do {
@@ -2037,6 +2061,26 @@
 
 	spin_lock_irq(&np->lock);
 
+	if (np->tx_limit) {
+		/* Limit the number of outstanding tx. Setup all fragments, but
+		 * do not set the VALID bit on the first descriptor. Save a pointer
+		 * to that descriptor and also for next skb_map element.
+		 */
+
+		if (np->tx_pkts_in_progress == NV_TX_LIMIT_COUNT) {
+			if (!np->tx_change_owner)
+				np->tx_change_owner = start_tx_ctx;
+
+			/* remove VALID bit */
+			tx_flags &= ~NV_TX2_VALID;
+			start_tx_ctx->first_tx_desc = start_tx;
+			start_tx_ctx->next_tx_ctx = np->put_tx_ctx;
+			np->tx_end_flip = np->put_tx_ctx;
+		} else {
+			np->tx_pkts_in_progress++;
+		}
+	}
+
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	np->put_tx.ex = put_tx;
@@ -2060,6 +2104,25 @@
 	return NETDEV_TX_OK;
 }
 
+static inline void nv_tx_flip_ownership(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+
+	np->tx_pkts_in_progress--;
+	if (np->tx_change_owner) {
+		__le32 flaglen = le32_to_cpu(np->tx_change_owner->first_tx_desc->flaglen);
+		flaglen |= NV_TX2_VALID;
+		np->tx_change_owner->first_tx_desc->flaglen = cpu_to_le32(flaglen);
+		np->tx_pkts_in_progress++;
+
+		np->tx_change_owner = np->tx_change_owner->next_tx_ctx;
+		if (np->tx_change_owner == np->tx_end_flip)
+			np->tx_change_owner = NULL;
+
+		writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+	}
+}
+
 /*
  * nv_tx_done: check for completed packets, release the skbs.
  *
@@ -2147,6 +2210,10 @@
 				dev->stats.tx_packets++;
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
+
+			if (np->tx_limit) {
+				nv_tx_flip_ownership(dev);
+			}
 		}
 		if (unlikely(np->get_tx.ex++ == np->last_tx.ex))
 			np->get_tx.ex = np->first_tx.ex;
@@ -5333,6 +5400,21 @@
 		np->need_linktimer = 0;
 	}
 
+	/* Limit the number of tx's outstanding for hw bug */
+	if (id->driver_data & DEV_NEED_TX_LIMIT) {
+		np->tx_limit = 1;
+		if ((id->device == PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_34 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_35 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_36 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_37 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_38 ||
+		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_39) &&
+		    pci_dev->revision >= 0xA2)
+			np->tx_limit = 0;
+	}
+
 	/* clear phy state and temporarily halt phy interrupts */
 	writel(0, base + NvRegMIIMask);
 	phystate = readl(base + NvRegAdapterControl);
@@ -5563,19 +5645,19 @@
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_8),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_9),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_10),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_11),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_12),
@@ -5587,11 +5669,11 @@
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
@@ -5611,19 +5693,19 @@
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_24),
@@ -5659,35 +5741,35 @@
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
 	},
 	{0,},
 };

--------------070807050403040807050300--
