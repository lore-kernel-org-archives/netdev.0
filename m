From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth: add mgmt unit support
Date: Mon, 30 Oct 2006 17:31:51 -0500
Message-ID: <45467D57.9060404@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030602060401030602030704"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:38422 "EHLO
	HQEMGATE01.nvidia.com") by vger.kernel.org with ESMTP
	id S1030572AbWJ3Som (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:44:42 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030602060401030602030704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for the mgmt unit in certain chipsets. The MAC 
and the mgmt unit share the PHY and therefore proper intialization 
procedures are needed for them to maintain coexistense.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030602060401030602030704
Content-Type: text/plain;
 name="patch-forcedeth-058-mgmt-unit"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-058-mgmt-unit"

--- orig-2.6/drivers/net/forcedeth.c	2006-10-30 16:03:56.000000000 -0500
+++ new-2.6/drivers/net/forcedeth.c	2006-10-30 16:04:03.000000000 -0500
@@ -110,6 +110,7 @@
  *	0.55: 22 Mar 2006: Add flow control (pause frame).
  *	0.56: 22 Mar 2006: Additional ethtool config and moduleparam support.
  *	0.57: 14 May 2006: Mac address set in probe/remove and order corrections.
+ *	0.58: 30 Oct 2006: Added support for sideband management unit.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -126,7 +127,7 @@
 #else
 #define DRIVERNAPI
 #endif
-#define FORCEDETH_VERSION		"0.57"
+#define FORCEDETH_VERSION		"0.58"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -174,6 +175,7 @@
 #define DEV_HAS_PAUSEFRAME_TX   0x0200  /* device supports tx pause frames */
 #define DEV_HAS_STATISTICS      0x0400  /* device supports hw statistics */
 #define DEV_HAS_TEST_EXTENDED   0x0800  /* device supports extended diagnostic test */
+#define DEV_HAS_MGMT_UNIT       0x1000  /* device supports management unit */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -222,6 +224,15 @@
 #define NVREG_MAC_RESET_ASSERT	0x0F3
 	NvRegTransmitterControl = 0x084,
 #define NVREG_XMITCTL_START	0x01
+#define NVREG_XMITCTL_MGMT_ST	0x40000000
+#define NVREG_XMITCTL_SYNC_MASK		0x000f0000
+#define NVREG_XMITCTL_SYNC_NOT_READY	0x0
+#define NVREG_XMITCTL_SYNC_PHY_INIT	0x00040000
+#define NVREG_XMITCTL_MGMT_SEMA_MASK	0x00000f00
+#define NVREG_XMITCTL_MGMT_SEMA_FREE	0x0
+#define NVREG_XMITCTL_HOST_SEMA_MASK	0x0000f000
+#define NVREG_XMITCTL_HOST_SEMA_ACQ	0x0000f000
+#define NVREG_XMITCTL_HOST_LOADED	0x00004000
 	NvRegTransmitterStatus = 0x088,
 #define NVREG_XMITSTAT_BUSY	0x01
 
@@ -304,8 +315,8 @@
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
 #define NVREG_MIISTAT_MASK		0x000f
 #define NVREG_MIISTAT_MASK2		0x000f
-	NvRegUnknownSetupReg4 = 0x184,
-#define NVREG_UNKSETUP4_VAL	8
+	NvRegMIIMask = 0x184,
+#define NVREG_MII_LINKCHANGE		0x0008
 
 	NvRegAdapterControl = 0x188,
 #define NVREG_ADAPTCTL_START	0x02
@@ -719,6 +730,7 @@
 	u32 driver_data;
 	u32 register_size;
 	int rx_csum;
+	u32 mac_in_use;
 
 	void __iomem *base;
 
@@ -4030,6 +4042,54 @@
 	/* nothing to do */
 };
 
+/* The mgmt unit and driver use a semaphore to access the phy during init */
+static int nv_mgmt_acquire_sema(struct net_device *dev)
+{
+	u8 __iomem *base = get_hwbase(dev);
+	int i;
+	u32 tx_ctrl, mgmt_sema;
+
+	for (i = 0; i < 10; i++) {
+		mgmt_sema = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_SEMA_MASK;
+		if (mgmt_sema == NVREG_XMITCTL_MGMT_SEMA_FREE)
+			break;
+		msleep(500);
+	}
+
+	if (mgmt_sema != NVREG_XMITCTL_MGMT_SEMA_FREE)
+		return 0;
+
+	for (i = 0; i < 2; i++) {
+		tx_ctrl = readl(base + NvRegTransmitterControl);
+		tx_ctrl |= NVREG_XMITCTL_HOST_SEMA_ACQ;
+		writel(tx_ctrl, base + NvRegTransmitterControl);
+
+		/* verify that semaphore was acquired */
+		tx_ctrl = readl(base + NvRegTransmitterControl);
+		if (((tx_ctrl & NVREG_XMITCTL_HOST_SEMA_MASK) == NVREG_XMITCTL_HOST_SEMA_ACQ) &&
+		    ((tx_ctrl & NVREG_XMITCTL_MGMT_SEMA_MASK) == NVREG_XMITCTL_MGMT_SEMA_FREE))
+			return 1;
+		else
+			udelay(50);
+	}
+
+	return 0;
+}
+
+/* Indicate to mgmt unit whether driver is loaded or not */
+static void nv_mgmt_driver_loaded(struct net_device *dev, int loaded)
+{
+	u8 __iomem *base = get_hwbase(dev);
+	u32 tx_ctrl;
+
+	tx_ctrl = readl(base + NvRegTransmitterControl);
+	if (loaded)
+		tx_ctrl |= NVREG_XMITCTL_HOST_LOADED;
+	else
+		tx_ctrl &= ~NVREG_XMITCTL_HOST_LOADED;
+	writel(tx_ctrl, base + NvRegTransmitterControl);
+}
+
 static int nv_open(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -4085,7 +4145,7 @@
 			NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX,
 			KERN_INFO "open: SetupReg5, Bit 31 remained off\n");
 
-	writel(0, base + NvRegUnknownSetupReg4);
+	writel(0, base + NvRegMIIMask);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 	writel(NVREG_MIISTAT_MASK2, base + NvRegMIIStatus);
 
@@ -4111,7 +4171,7 @@
 	writel((np->phyaddr << NVREG_ADAPTCTL_PHYSHIFT)|NVREG_ADAPTCTL_PHYVALID|NVREG_ADAPTCTL_RUNNING,
 			base + NvRegAdapterControl);
 	writel(NVREG_MIISPEED_BIT8|NVREG_MIIDELAY, base + NvRegMIISpeed);
-	writel(NVREG_UNKSETUP4_VAL, base + NvRegUnknownSetupReg4);
+	writel(NVREG_MII_LINKCHANGE, base + NvRegMIIMask);
 	if (np->wolenabled)
 		writel(NVREG_WAKEUPFLAGS_ENABLE , base + NvRegWakeUpFlags);
 
@@ -4230,6 +4290,8 @@
 	u8 __iomem *base;
 	int err, i;
 	u32 powerstate, txreg;
+	u32 phystate_orig = 0, phystate;
+	int phyinitialized = 0;
 
 	dev = alloc_etherdev(sizeof(struct fe_priv));
 	err = -ENOMEM;
@@ -4514,6 +4576,48 @@
 		np->need_linktimer = 0;
 	}
 
+	/* clear phy state and temporarily halt phy interrupts */
+	writel(0, base + NvRegMIIMask);
+	phystate = readl(base + NvRegAdapterControl);
+	if (phystate & NVREG_ADAPTCTL_RUNNING) {
+		phystate_orig = 1;
+		phystate &= ~NVREG_ADAPTCTL_RUNNING;
+		writel(phystate, base + NvRegAdapterControl);
+	}
+	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+
+	if (id->driver_data & DEV_HAS_MGMT_UNIT) {
+		writel(0x1, base + 0x204); pci_push(base);
+		msleep(500);
+		/* management unit running on the mac? */
+		np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
+		if (np->mac_in_use) {
+			u32 mgmt_sync;
+			/* management unit setup the phy already? */
+			mgmt_sync = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK;
+			if (mgmt_sync == NVREG_XMITCTL_SYNC_NOT_READY) {
+				if (!nv_mgmt_acquire_sema(dev)) {
+					for (i = 0; i < 5000; i++) {
+						msleep(1);
+						mgmt_sync = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK;
+						if (mgmt_sync == NVREG_XMITCTL_SYNC_NOT_READY)
+							continue;
+						if (mgmt_sync == NVREG_XMITCTL_SYNC_PHY_INIT)
+							phyinitialized = 1;
+						break;
+					}
+				} else {
+					/* we need to init the phy */
+				}
+			} else if (mgmt_sync == NVREG_XMITCTL_SYNC_PHY_INIT) {
+				/* phy is inited by SMU */
+				phyinitialized = 1;
+			} else {
+				/* we need to init the phy */
+			}
+		}
+	}
+
 	/* find a suitable phy */
 	for (i = 1; i <= 32; i++) {
 		int id1, id2;
@@ -4545,8 +4649,14 @@
 		goto out_error;
 	}
 
-	/* reset it */
-	phy_init(dev);
+	if (!phyinitialized) {
+		/* reset it */
+		phy_init(dev);
+	}
+
+	if (id->driver_data & DEV_HAS_MGMT_UNIT) {
+		nv_mgmt_driver_loaded(dev, 1);
+	}
 
 	/* set default link speed settings */
 	np->linkspeed = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
@@ -4565,6 +4675,10 @@
 	return 0;
 
 out_error:
+	if (phystate_orig)
+		writel(phystate|NVREG_ADAPTCTL_RUNNING, base + NvRegAdapterControl);
+	if (np->mac_in_use)
+		nv_mgmt_driver_loaded(dev, 0);
 	pci_set_drvdata(pci_dev, NULL);
 out_freering:
 	free_rings(dev);
@@ -4594,6 +4708,9 @@
 	writel(np->orig_mac[0], base + NvRegMacAddrA);
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
 
+	if (np->mac_in_use)
+		nv_mgmt_driver_loaded(dev, 0);
+
 	/* free all structures */
 	free_rings(dev);
 	iounmap(get_hwbase(dev));
@@ -4702,43 +4819,43 @@
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_17),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_18),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{0,},
 };

--------------030602060401030602030704--
