From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 11/12] forcedeth: statistics supported
Date: Sun, 21 Jan 2007 18:11:26 -0500
Message-ID: <45B3F31E.7000006@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070605050703050700070503"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:6983 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbXAVBGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 20:06:19 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070605050703050700070503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch introduces hw statistics for older devices that supported it.
It breaks up the counters supported into separate versions.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

--------------070605050703050700070503
Content-Type: text/plain;
 name="patch-stats-ver"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-stats-ver"

--- orig/drivers/net/forcedeth.c	2007-01-21 17:33:59.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-21 17:38:23.000000000 -0500
@@ -173,9 +173,10 @@
 #define DEV_HAS_MSI_X           0x0080  /* device supports MSI-X */
 #define DEV_HAS_POWER_CNTRL     0x0100  /* device supports power savings */
 #define DEV_HAS_PAUSEFRAME_TX   0x0200  /* device supports tx pause frames */
-#define DEV_HAS_STATISTICS      0x0400  /* device supports hw statistics */
-#define DEV_HAS_TEST_EXTENDED   0x0800  /* device supports extended diagnostic test */
-#define DEV_HAS_MGMT_UNIT       0x1000  /* device supports management unit */
+#define DEV_HAS_STATISTICS_V1   0x0400  /* device supports hw statistics version 1 */
+#define DEV_HAS_STATISTICS_V2   0x0800  /* device supports hw statistics version 2 */
+#define DEV_HAS_TEST_EXTENDED   0x1000  /* device supports extended diagnostic test */
+#define DEV_HAS_MGMT_UNIT       0x2000  /* device supports management unit */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -487,7 +488,8 @@
 
 /* Miscelaneous hardware related defines: */
 #define NV_PCI_REGSZ_VER1      	0x270
-#define NV_PCI_REGSZ_VER2      	0x604
+#define NV_PCI_REGSZ_VER2      	0x2d4
+#define NV_PCI_REGSZ_VER3      	0x604
 
 /* various timeout delays: all in usec */
 #define NV_TXRX_RESET_DELAY	4
@@ -605,9 +607,6 @@
 	{ "tx_carrier_errors" },
 	{ "tx_excess_deferral" },
 	{ "tx_retry_error" },
-	{ "tx_deferral" },
-	{ "tx_packets" },
-	{ "tx_pause" },
 	{ "rx_frame_error" },
 	{ "rx_extra_byte" },
 	{ "rx_late_collision" },
@@ -620,11 +619,17 @@
 	{ "rx_unicast" },
 	{ "rx_multicast" },
 	{ "rx_broadcast" },
+	{ "rx_packets" },
+	{ "rx_errors_total" },
+	{ "tx_errors_total" },
+
+	/* version 2 stats */
+	{ "tx_deferral" },
+	{ "tx_packets" },
 	{ "rx_bytes" },
+	{ "tx_pause" },
 	{ "rx_pause" },
-	{ "rx_drop_frame" },
-	{ "rx_packets" },
-	{ "rx_errors_total" }
+	{ "rx_drop_frame" }
 };
 
 struct nv_ethtool_stats {
@@ -637,9 +642,6 @@
 	u64 tx_carrier_errors;
 	u64 tx_excess_deferral;
 	u64 tx_retry_error;
-	u64 tx_deferral;
-	u64 tx_packets;
-	u64 tx_pause;
 	u64 rx_frame_error;
 	u64 rx_extra_byte;
 	u64 rx_late_collision;
@@ -652,13 +654,22 @@
 	u64 rx_unicast;
 	u64 rx_multicast;
 	u64 rx_broadcast;
+	u64 rx_packets;
+	u64 rx_errors_total;
+	u64 tx_errors_total;
+
+	/* version 2 stats */
+	u64 tx_deferral;
+	u64 tx_packets;
 	u64 rx_bytes;
+	u64 tx_pause;
 	u64 rx_pause;
 	u64 rx_drop_frame;
-	u64 rx_packets;
-	u64 rx_errors_total;
 };
 
+#define NV_DEV_STATISTICS_V2_COUNT (sizeof(struct nv_ethtool_stats)/sizeof(u64))
+#define NV_DEV_STATISTICS_V1_COUNT (NV_DEV_STATISTICS_V2_COUNT - 6)
+
 /* diagnostics */
 #define NV_TEST_COUNT_BASE 3
 #define NV_TEST_COUNT_EXTENDED 4
@@ -1275,6 +1286,61 @@
 	pci_push(base);
 }
 
+static void nv_get_hw_stats(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+
+	np->estats.tx_bytes += readl(base + NvRegTxCnt);
+	np->estats.tx_zero_rexmt += readl(base + NvRegTxZeroReXmt);
+	np->estats.tx_one_rexmt += readl(base + NvRegTxOneReXmt);
+	np->estats.tx_many_rexmt += readl(base + NvRegTxManyReXmt);
+	np->estats.tx_late_collision += readl(base + NvRegTxLateCol);
+	np->estats.tx_fifo_errors += readl(base + NvRegTxUnderflow);
+	np->estats.tx_carrier_errors += readl(base + NvRegTxLossCarrier);
+	np->estats.tx_excess_deferral += readl(base + NvRegTxExcessDef);
+	np->estats.tx_retry_error += readl(base + NvRegTxRetryErr);
+	np->estats.rx_frame_error += readl(base + NvRegRxFrameErr);
+	np->estats.rx_extra_byte += readl(base + NvRegRxExtraByte);
+	np->estats.rx_late_collision += readl(base + NvRegRxLateCol);
+	np->estats.rx_runt += readl(base + NvRegRxRunt);
+	np->estats.rx_frame_too_long += readl(base + NvRegRxFrameTooLong);
+	np->estats.rx_over_errors += readl(base + NvRegRxOverflow);
+	np->estats.rx_crc_errors += readl(base + NvRegRxFCSErr);
+	np->estats.rx_frame_align_error += readl(base + NvRegRxFrameAlignErr);
+	np->estats.rx_length_error += readl(base + NvRegRxLenErr);
+	np->estats.rx_unicast += readl(base + NvRegRxUnicast);
+	np->estats.rx_multicast += readl(base + NvRegRxMulticast);
+	np->estats.rx_broadcast += readl(base + NvRegRxBroadcast);
+	np->estats.rx_packets =
+		np->estats.rx_unicast +
+		np->estats.rx_multicast +
+		np->estats.rx_broadcast;
+	np->estats.rx_errors_total =
+		np->estats.rx_crc_errors +
+		np->estats.rx_over_errors +
+		np->estats.rx_frame_error +
+		(np->estats.rx_frame_align_error - np->estats.rx_extra_byte) +
+		np->estats.rx_late_collision +
+		np->estats.rx_runt +
+		np->estats.rx_frame_too_long;
+	np->estats.tx_errors_total =
+		np->estats.tx_late_collision +
+		np->estats.tx_fifo_errors +
+		np->estats.tx_carrier_errors +
+		np->estats.tx_excess_deferral +
+		np->estats.tx_retry_error;
+
+	if (np->driver_data & DEV_HAS_STATISTICS_V2) {
+		np->estats.tx_deferral += readl(base + NvRegTxDef);
+		np->estats.tx_packets += readl(base + NvRegTxFrame);
+		np->estats.rx_bytes += readl(base + NvRegRxCnt);
+		np->estats.tx_pause += readl(base + NvRegTxPause);
+		np->estats.rx_pause += readl(base + NvRegRxPause);
+		np->estats.rx_drop_frame += readl(base + NvRegRxDropFrame);
+	}
+}
+
 /*
  * nv_get_stats: dev->get_stats function
  * Get latest stats value from the nic.
@@ -3502,47 +3568,8 @@
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
 
-	np->estats.tx_bytes += readl(base + NvRegTxCnt);
-	np->estats.tx_zero_rexmt += readl(base + NvRegTxZeroReXmt);
-	np->estats.tx_one_rexmt += readl(base + NvRegTxOneReXmt);
-	np->estats.tx_many_rexmt += readl(base + NvRegTxManyReXmt);
-	np->estats.tx_late_collision += readl(base + NvRegTxLateCol);
-	np->estats.tx_fifo_errors += readl(base + NvRegTxUnderflow);
-	np->estats.tx_carrier_errors += readl(base + NvRegTxLossCarrier);
-	np->estats.tx_excess_deferral += readl(base + NvRegTxExcessDef);
-	np->estats.tx_retry_error += readl(base + NvRegTxRetryErr);
-	np->estats.tx_deferral += readl(base + NvRegTxDef);
-	np->estats.tx_packets += readl(base + NvRegTxFrame);
-	np->estats.tx_pause += readl(base + NvRegTxPause);
-	np->estats.rx_frame_error += readl(base + NvRegRxFrameErr);
-	np->estats.rx_extra_byte += readl(base + NvRegRxExtraByte);
-	np->estats.rx_late_collision += readl(base + NvRegRxLateCol);
-	np->estats.rx_runt += readl(base + NvRegRxRunt);
-	np->estats.rx_frame_too_long += readl(base + NvRegRxFrameTooLong);
-	np->estats.rx_over_errors += readl(base + NvRegRxOverflow);
-	np->estats.rx_crc_errors += readl(base + NvRegRxFCSErr);
-	np->estats.rx_frame_align_error += readl(base + NvRegRxFrameAlignErr);
-	np->estats.rx_length_error += readl(base + NvRegRxLenErr);
-	np->estats.rx_unicast += readl(base + NvRegRxUnicast);
-	np->estats.rx_multicast += readl(base + NvRegRxMulticast);
-	np->estats.rx_broadcast += readl(base + NvRegRxBroadcast);
-	np->estats.rx_bytes += readl(base + NvRegRxCnt);
-	np->estats.rx_pause += readl(base + NvRegRxPause);
-	np->estats.rx_drop_frame += readl(base + NvRegRxDropFrame);
-	np->estats.rx_packets =
-		np->estats.rx_unicast +
-		np->estats.rx_multicast +
-		np->estats.rx_broadcast;
-	np->estats.rx_errors_total =
-		np->estats.rx_crc_errors +
-		np->estats.rx_over_errors +
-		np->estats.rx_frame_error +
-		(np->estats.rx_frame_align_error - np->estats.rx_extra_byte) +
-		np->estats.rx_late_collision +
-		np->estats.rx_runt +
-		np->estats.rx_frame_too_long;
+	nv_get_hw_stats(dev);
 
 	if (!np->in_shutdown)
 		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
@@ -4161,8 +4188,10 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 
-	if (np->driver_data & DEV_HAS_STATISTICS)
-		return sizeof(struct nv_ethtool_stats)/sizeof(u64);
+	if (np->driver_data & DEV_HAS_STATISTICS_V1)
+		return NV_DEV_STATISTICS_V1_COUNT;
+	else if (np->driver_data & DEV_HAS_STATISTICS_V2)
+		return NV_DEV_STATISTICS_V2_COUNT;
 	else
 		return 0;
 }
@@ -4749,7 +4778,7 @@
 		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 
 	/* start statistics timer */
-	if (np->driver_data & DEV_HAS_STATISTICS)
+	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2))
 		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
 
 	spin_unlock_irq(&np->lock);
@@ -4846,7 +4875,9 @@
 	if (err < 0)
 		goto out_disable;
 
-	if (id->driver_data & (DEV_HAS_VLAN|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_STATISTICS))
+	if (id->driver_data & (DEV_HAS_VLAN|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_STATISTICS_V2))
+		np->register_size = NV_PCI_REGSZ_VER3;
+	else if (id->driver_data & DEV_HAS_STATISTICS_V1)
 		np->register_size = NV_PCI_REGSZ_VER2;
 	else
 		np->register_size = NV_PCI_REGSZ_VER1;
@@ -5295,83 +5326,83 @@
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_8),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_9),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_10),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_11),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_STATISTICS_V1,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_12),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_STATISTICS_V1,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_13),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_STATISTICS_V1,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_17),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_18),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_24),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_25),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_26),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_27),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{0,},
 };

--------------070605050703050700070503--
