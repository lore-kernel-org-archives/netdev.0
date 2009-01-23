From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: mgmt unit interface changes
Date: Fri, 23 Jan 2009 16:01:58 -0500
Message-ID: <497A3046.7060202@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030706080904020309040404"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:1665 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758137AbZAXAHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 19:07:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030706080904020309040404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch updates the logic used to communicate with the mgmt unit. It 
also adds a version check for a newer mgmt unit firmware.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030706080904020309040404
Content-Type: text/plain;
 name="patch-forcedeth-smu-interface"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-smu-interface"

--- old/drivers/net/forcedeth.c	2009-01-22 14:27:21.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-01-22 15:31:03.000000000 -0800
@@ -157,6 +157,9 @@
 #define NVREG_XMITCTL_HOST_SEMA_ACQ	0x0000f000
 #define NVREG_XMITCTL_HOST_LOADED	0x00004000
 #define NVREG_XMITCTL_TX_PATH_EN	0x01000000
+#define NVREG_XMITCTL_DATA_START	0x00100000
+#define NVREG_XMITCTL_DATA_READY	0x00010000
+#define NVREG_XMITCTL_DATA_ERROR	0x00020000
 	NvRegTransmitterStatus = 0x088,
 #define NVREG_XMITSTAT_BUSY	0x01
 
@@ -289,8 +292,10 @@
 #define NVREG_WAKEUPFLAGS_ACCEPT_LINKCHANGE	0x04
 #define NVREG_WAKEUPFLAGS_ENABLE	0x1111
 
-	NvRegPatternCRC = 0x204,
-	NvRegPatternMask = 0x208,
+	NvRegMgmtUnitGetVersion = 0x204,
+#define NVREG_MGMTUNITGETVERSION     	0x01
+	NvRegMgmtUnitVersion = 0x208,
+#define NVREG_MGMTUNITVERSION		0x08
 	NvRegPowerCap = 0x268,
 #define NVREG_POWERCAP_D3SUPP	(1<<30)
 #define NVREG_POWERCAP_D2SUPP	(1<<26)
@@ -303,6 +308,8 @@
 #define NVREG_POWERSTATE_D1		0x0001
 #define NVREG_POWERSTATE_D2		0x0002
 #define NVREG_POWERSTATE_D3		0x0003
+	NvRegMgmtUnitControl = 0x278,
+#define NVREG_MGMTUNITCONTROL_INUSE	0x20000
 	NvRegTxCnt = 0x280,
 	NvRegTxZeroReXmt = 0x284,
 	NvRegTxOneReXmt = 0x288,
@@ -758,6 +765,8 @@
 	u32 register_size;
 	int rx_csum;
 	u32 mac_in_use;
+	int mgmt_version;
+	int mgmt_sema;
 
 	void __iomem *base;
 
@@ -5169,6 +5178,7 @@
 /* The mgmt unit and driver use a semaphore to access the phy during init */
 static int nv_mgmt_acquire_sema(struct net_device *dev)
 {
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	int i;
 	u32 tx_ctrl, mgmt_sema;
@@ -5191,8 +5201,10 @@
 		/* verify that semaphore was acquired */
 		tx_ctrl = readl(base + NvRegTransmitterControl);
 		if (((tx_ctrl & NVREG_XMITCTL_HOST_SEMA_MASK) == NVREG_XMITCTL_HOST_SEMA_ACQ) &&
-		    ((tx_ctrl & NVREG_XMITCTL_MGMT_SEMA_MASK) == NVREG_XMITCTL_MGMT_SEMA_FREE))
+		    ((tx_ctrl & NVREG_XMITCTL_MGMT_SEMA_MASK) == NVREG_XMITCTL_MGMT_SEMA_FREE)) {
+			np->mgmt_sema = 1;
 			return 1;
+		}
 		else
 			udelay(50);
 	}
@@ -5200,6 +5212,47 @@
 	return 0;
 }
 
+static void nv_mgmt_release_sema(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	u32 tx_ctrl;
+
+	if (np->driver_data & DEV_HAS_MGMT_UNIT) {
+		if (np->mgmt_sema) {
+			tx_ctrl = readl(base + NvRegTransmitterControl);
+			tx_ctrl &= ~NVREG_XMITCTL_HOST_SEMA_ACQ;
+			writel(tx_ctrl, base + NvRegTransmitterControl);
+		}
+	}
+}
+
+
+static int nv_mgmt_get_version(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	u32 data_ready = readl(base + NvRegTransmitterControl);
+	u32 data_ready2;
+	int i;
+
+	writel(NVREG_MGMTUNITGETVERSION, base + NvRegMgmtUnitGetVersion);
+	writel(data_ready ^ NVREG_XMITCTL_DATA_START, base + NvRegTransmitterControl);
+	for (i = 0; i < 1000000; i++) {
+		data_ready2 = readl(base + NvRegTransmitterControl);
+		if ((data_ready & NVREG_XMITCTL_DATA_READY) != (data_ready2 & NVREG_XMITCTL_DATA_READY))
+			break;
+		udelay(50);
+	}
+
+	if (i == 1000000 || (data_ready2 & NVREG_XMITCTL_DATA_ERROR))
+		return 0;
+
+	np->mgmt_version = readl(base + NvRegMgmtUnitVersion) & NVREG_MGMTUNITVERSION;
+
+	return 1;
+}
+
 static int nv_open(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -5771,19 +5824,26 @@
 
 	if (id->driver_data & DEV_HAS_MGMT_UNIT) {
 		/* management unit running on the mac? */
-		if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) {
-			np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
-			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n", pci_name(pci_dev), np->mac_in_use);
-			if (nv_mgmt_acquire_sema(dev)) {
-				/* management unit setup the phy already? */
-				if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
-				    NVREG_XMITCTL_SYNC_PHY_INIT) {
-					/* phy is inited by mgmt unit */
-					phyinitialized = 1;
-					dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
-				} else {
-					/* we need to init the phy */
-				}
+		if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST) &&
+		    (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) &&
+		    nv_mgmt_acquire_sema(dev) &&
+		    nv_mgmt_get_version(dev)) {
+			np->mac_in_use = 1;
+			if (np->mgmt_version > 0) {
+				np->mac_in_use = readl(base + NvRegMgmtUnitControl) & NVREG_MGMTUNITCONTROL_INUSE;
+			}
+			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n",
+				pci_name(pci_dev), np->mac_in_use);
+			/* management unit setup the phy already? */
+			if (np->mac_in_use &&
+			    ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
+			     NVREG_XMITCTL_SYNC_PHY_INIT)) {
+				/* phy is inited by mgmt unit */
+				phyinitialized = 1;
+				dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n",
+					pci_name(pci_dev));
+			} else {
+				/* we need to init the phy */
 			}
 		}
 	}
@@ -5945,6 +6005,8 @@
 	/* restore any phy related changes */
 	nv_restore_phy(dev);
 
+	nv_mgmt_release_sema(dev);
+
 	/* free all structures */
 	free_rings(dev);
 	iounmap(get_hwbase(dev));

--------------030706080904020309040404--
