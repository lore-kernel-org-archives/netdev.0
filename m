From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: Additional ethtool support
Date: Sun, 10 Jul 2005 13:09:32 +0200
Message-ID: <42D101EC.6000608@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050905000803070200080800"
Cc: Netdev <netdev@oss.sgi.com>, renaud.lienhart@free.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050905000803070200080800
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

The attached patch adds ethtool support for -r (restart 
auto-negotiation) and -d (dump registers).
It also contains the PCI_DEVICE changes from Renaud, a bugfix for the 
jumbo frame patch (the packet size limit remained at 1500, even for the 
nics that support jumbo frames) and a cleanup for the selection of the 
jumbo frame capable/incapable nics.

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------050905000803070200080800
Content-Type: text/plain;
 name="patch-forcedeth-037-ethtool"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-037-ethtool"

--- 2.6/drivers/net/forcedeth.c	2005-07-10 12:38:53.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-07-10 12:51:12.000000000 +0200
@@ -85,7 +85,8 @@
  *	0.33: 16 May 2005: Support for MCP51 added.
  *	0.34: 18 Jun 2005: Add DEV_NEED_LINKTIMER to all nForce nics.
  *	0.35: 26 Jun 2005: Support for MCP55 added.
- *	0.36: 28 Jul 2005: Add jumbo frame support.
+ *	0.36: 28 Jun 2005: Add jumbo frame support.
+ *	0.37: 10 Jul 2005: Additional ethtool support, cleanup of pci id list
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -137,6 +138,7 @@
 #define DEV_IRQMASK_2		0x0004  /* use NVREG_IRQMASK_WANTED_2 for irq mask */
 #define DEV_NEED_TIMERIRQ	0x0008  /* set the timer irq flag in the irq mask */
 #define DEV_NEED_LINKTIMER	0x0010	/* poll link settings. Relies on the timer irq */
+#define DEV_HAS_LARGEDESC	0x0020	/* device supports jumbo frames and needs packet format 2 */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -1846,6 +1848,50 @@
 	return 0;
 }
 
+#define FORCEDETH_REGS_VER	1
+#define FORCEDETH_REGS_SIZE	0x400 /* 256 32-bit registers */
+
+static int nv_get_regs_len(struct net_device *dev)
+{
+	return FORCEDETH_REGS_SIZE;
+}
+
+static void nv_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *buf)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	u32 *rbuf = (u32 *)buf;
+	int i;
+
+	regs->version = FORCEDETH_REGS_VER;
+	spin_lock_irq(&np->lock);
+	for (i=0;i<FORCEDETH_REGS_SIZE/sizeof(u32);i++)
+		rbuf[i] = readl(base + i*sizeof(u32));
+	spin_unlock_irq(&np->lock);
+}
+
+static int nv_nway_reset(struct net_device *dev)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+	int ret;
+
+	spin_lock_irq(&np->lock);
+	if (np->autoneg) {
+		int bmcr;
+
+		bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
+		bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
+		mii_rw(dev, np->phyaddr, MII_BMCR, bmcr);
+
+		ret = 0;
+	} else {
+		ret = -EINVAL;
+	}
+	spin_unlock_irq(&np->lock);
+
+	return ret;
+}
+
 static struct ethtool_ops ops = {
 	.get_drvinfo = nv_get_drvinfo,
 	.get_link = ethtool_op_get_link,
@@ -1853,6 +1899,9 @@
 	.set_wol = nv_set_wol,
 	.get_settings = nv_get_settings,
 	.set_settings = nv_set_settings,
+	.get_regs_len = nv_get_regs_len,
+	.get_regs = nv_get_regs,
+	.nway_reset = nv_nway_reset,
 };
 
 static int nv_open(struct net_device *dev)
@@ -2092,16 +2141,11 @@
 	}
 
 	/* handle different descriptor versions */
-	if (pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_1 ||
-			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
-			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3 ||    
-			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
-			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_13) {
-		np->desc_ver = DESC_VER_1;
- 		np->pkt_limit = NV_PKTLIMIT_1;
-	} else {
+	np->desc_ver = DESC_VER_1;
+ 	np->pkt_limit = NV_PKTLIMIT_1;
+	if (id->driver_data & DEV_HAS_LARGEDESC) {
 		np->desc_ver = DESC_VER_2;
- 		np->pkt_limit = NV_PKTLIMIT_1;
+ 		np->pkt_limit = NV_PKTLIMIT_2;
 	}
 
 	err = -ENOMEM;
@@ -2284,109 +2328,74 @@
 
 static struct pci_device_id pci_tbl[] = {
 	{	/* nForce Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_1,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_1),
 		.driver_data = DEV_IRQMASK_1|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce2 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_2,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_2),
 		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_3,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_3),
 		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_4,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_4),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* nForce3 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_5,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_5),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* nForce3 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_6,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_6),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* nForce3 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_7,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_7),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* CK804 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_8,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_8),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* CK804 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_9,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_9),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP04 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_10,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_10),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP04 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_11,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_11),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP51 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_12,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_12),
 		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP51 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_13,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_13),
 		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP55 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_14,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP55 Ethernet Controller */
-		.vendor = PCI_VENDOR_ID_NVIDIA,
-		.device = PCI_DEVICE_ID_NVIDIA_NVENET_15,
-		.subvendor = PCI_ANY_ID,
-		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
+			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{0,},
 };

--------------050905000803070200080800--
