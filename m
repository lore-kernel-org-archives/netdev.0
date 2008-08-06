From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/4] forcedeth: add new tx stat counters
Date: Wed, 06 Aug 2008 12:11:42 -0400
Message-ID: <4899CD3E.3080200@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060905090203040400030107"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:10613 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234AbYHFTVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 15:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060905090203040400030107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for new tx statistic counters in the hardware - 
unicast, multicast, and broadcast

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------060905090203040400030107
Content-Type: text/plain;
 name="patch-forcedeth-txstats3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-txstats3"

--- old/drivers/net/forcedeth.c	2008-08-06 11:31:37.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-08-06 11:32:07.000000000 -0400
@@ -77,26 +77,27 @@
  * Hardware access:
  */
 
-#define DEV_NEED_TIMERIRQ          0x00001  /* set the timer irq flag in the irq mask */
-#define DEV_NEED_LINKTIMER         0x00002  /* poll link settings. Relies on the timer irq */
-#define DEV_HAS_LARGEDESC          0x00004  /* device supports jumbo frames and needs packet format 2 */
-#define DEV_HAS_HIGH_DMA           0x00008  /* device supports 64bit dma */
-#define DEV_HAS_CHECKSUM           0x00010  /* device supports tx and rx checksum offloads */
-#define DEV_HAS_VLAN               0x00020  /* device supports vlan tagging and striping */
-#define DEV_HAS_MSI                0x00040  /* device supports MSI */
-#define DEV_HAS_MSI_X              0x00080  /* device supports MSI-X */
-#define DEV_HAS_POWER_CNTRL        0x00100  /* device supports power savings */
-#define DEV_HAS_STATISTICS_V1      0x00200  /* device supports hw statistics version 1 */
-#define DEV_HAS_STATISTICS_V2      0x00400  /* device supports hw statistics version 2 */
-#define DEV_HAS_TEST_EXTENDED      0x00800  /* device supports extended diagnostic test */
-#define DEV_HAS_MGMT_UNIT          0x01000  /* device supports management unit */
-#define DEV_HAS_CORRECT_MACADDR    0x02000  /* device supports correct mac address order */
-#define DEV_HAS_COLLISION_FIX      0x04000  /* device supports tx collision fix */
-#define DEV_HAS_PAUSEFRAME_TX_V1   0x08000  /* device supports tx pause frames version 1 */
-#define DEV_HAS_PAUSEFRAME_TX_V2   0x10000  /* device supports tx pause frames version 2 */
-#define DEV_HAS_PAUSEFRAME_TX_V3   0x20000  /* device supports tx pause frames version 3 */
-#define DEV_NEED_TX_LIMIT          0x40000  /* device needs to limit tx */
-#define DEV_HAS_GEAR_MODE          0x80000  /* device supports gear mode */
+#define DEV_NEED_TIMERIRQ          0x000001  /* set the timer irq flag in the irq mask */
+#define DEV_NEED_LINKTIMER         0x000002  /* poll link settings. Relies on the timer irq */
+#define DEV_HAS_LARGEDESC          0x000004  /* device supports jumbo frames and needs packet format 2 */
+#define DEV_HAS_HIGH_DMA           0x000008  /* device supports 64bit dma */
+#define DEV_HAS_CHECKSUM           0x000010  /* device supports tx and rx checksum offloads */
+#define DEV_HAS_VLAN               0x000020  /* device supports vlan tagging and striping */
+#define DEV_HAS_MSI                0x000040  /* device supports MSI */
+#define DEV_HAS_MSI_X              0x000080  /* device supports MSI-X */
+#define DEV_HAS_POWER_CNTRL        0x000100  /* device supports power savings */
+#define DEV_HAS_STATISTICS_V1      0x000200  /* device supports hw statistics version 1 */
+#define DEV_HAS_STATISTICS_V2      0x000400  /* device supports hw statistics version 2 */
+#define DEV_HAS_STATISTICS_V3      0x000800  /* device supports hw statistics version 3 */
+#define DEV_HAS_TEST_EXTENDED      0x001000  /* device supports extended diagnostic test */
+#define DEV_HAS_MGMT_UNIT          0x002000  /* device supports management unit */
+#define DEV_HAS_CORRECT_MACADDR    0x004000  /* device supports correct mac address order */
+#define DEV_HAS_COLLISION_FIX      0x008000  /* device supports tx collision fix */
+#define DEV_HAS_PAUSEFRAME_TX_V1   0x010000  /* device supports tx pause frames version 1 */
+#define DEV_HAS_PAUSEFRAME_TX_V2   0x020000  /* device supports tx pause frames version 2 */
+#define DEV_HAS_PAUSEFRAME_TX_V3   0x040000  /* device supports tx pause frames version 3 */
+#define DEV_NEED_TX_LIMIT          0x080000  /* device needs to limit tx */
+#define DEV_HAS_GEAR_MODE          0x100000  /* device supports gear mode */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -270,6 +271,9 @@
 #define NVREG_MIICTL_WRITE	0x00400
 #define NVREG_MIICTL_ADDRSHIFT	5
 	NvRegMIIData = 0x194,
+	NvRegTxUnicast = 0x1a0,
+	NvRegTxMulticast = 0x1a4,
+	NvRegTxBroadcast = 0x1a8,
 	NvRegWakeUpFlags = 0x200,
 #define NVREG_WAKEUPFLAGS_VAL		0x7770
 #define NVREG_WAKEUPFLAGS_BUSYSHIFT	24
@@ -618,7 +622,12 @@
 	{ "rx_bytes" },
 	{ "tx_pause" },
 	{ "rx_pause" },
-	{ "rx_drop_frame" }
+	{ "rx_drop_frame" },
+
+	/* version 3 stats */
+	{ "tx_unicast" },
+	{ "tx_multicast" },
+	{ "tx_broadcast" }
 };
 
 struct nv_ethtool_stats {
@@ -654,9 +663,15 @@
 	u64 tx_pause;
 	u64 rx_pause;
 	u64 rx_drop_frame;
+
+	/* version 3 stats */
+	u64 tx_unicast;
+	u64 tx_multicast;
+	u64 tx_broadcast;
 };
 
-#define NV_DEV_STATISTICS_V2_COUNT (sizeof(struct nv_ethtool_stats)/sizeof(u64))
+#define NV_DEV_STATISTICS_V3_COUNT (sizeof(struct nv_ethtool_stats)/sizeof(u64))
+#define NV_DEV_STATISTICS_V2_COUNT (NV_DEV_STATISTICS_V3_COUNT - 3)
 #define NV_DEV_STATISTICS_V1_COUNT (NV_DEV_STATISTICS_V2_COUNT - 6)
 
 /* diagnostics */
@@ -1630,6 +1645,12 @@
 		np->estats.rx_pause += readl(base + NvRegRxPause);
 		np->estats.rx_drop_frame += readl(base + NvRegRxDropFrame);
 	}
+
+	if (np->driver_data & DEV_HAS_STATISTICS_V3) {
+		np->estats.tx_unicast += readl(base + NvRegTxUnicast);
+		np->estats.tx_multicast += readl(base + NvRegTxMulticast);
+		np->estats.tx_broadcast += readl(base + NvRegTxBroadcast);
+	}
 }
 
 /*
@@ -1643,7 +1664,7 @@
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* If the nic supports hw counters then retrieve latest values */
-	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2)) {
+	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_STATISTICS_V3)) {
 		nv_get_hw_stats(dev);
 
 		/* copy to net_device stats */
@@ -4742,6 +4763,8 @@
 			return NV_DEV_STATISTICS_V1_COUNT;
 		else if (np->driver_data & DEV_HAS_STATISTICS_V2)
 			return NV_DEV_STATISTICS_V2_COUNT;
+		else if (np->driver_data & DEV_HAS_STATISTICS_V3)
+			return NV_DEV_STATISTICS_V3_COUNT;
 		else
 			return 0;
 	default:
@@ -5326,7 +5349,7 @@
 		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 
 	/* start statistics timer */
-	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2))
+	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_STATISTICS_V3))
 		mod_timer(&np->stats_poll,
 			round_jiffies(jiffies + STATS_INTERVAL));
 
@@ -5430,7 +5453,7 @@
 	if (err < 0)
 		goto out_disable;
 
-	if (id->driver_data & (DEV_HAS_VLAN|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_STATISTICS_V2))
+	if (id->driver_data & (DEV_HAS_VLAN|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_STATISTICS_V2|DEV_HAS_STATISTICS_V3))
 		np->register_size = NV_PCI_REGSZ_VER3;
 	else if (id->driver_data & DEV_HAS_STATISTICS_V1)
 		np->register_size = NV_PCI_REGSZ_VER2;
@@ -6085,35 +6108,35 @@
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{0,},
 };

--------------060905090203040400030107--
