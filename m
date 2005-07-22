From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: simplify tx interrupt handling
Date: Fri, 22 Jul 2005 22:00:54 +0200
Message-ID: <42E15076.4080907@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080303050106030109080905"
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080303050106030109080905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

The nForce MAC has two options for generating tx completion interrupts: 
Either by setting a per-packet flag, or by setting a bit in the irq mask 
(which enables interrupts for all packets). forcedeth tried to use one 
approach for nForce boards and the other approach for nForce 2/3/4.
The attached patch removes the special cases and uses the same approach 
for all nForce versions. The patch also adds extensive debug output that 
should help to identify the tx hang described in the bugzilla.kernel.org 
bugreport 4552.

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------080303050106030109080905
Content-Type: text/plain;
 name="patch-forcedeth-038-txirq"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-038-txirq"

--- 2.6/drivers/net/forcedeth.c	2005-07-16 13:10:30.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-07-16 15:58:03.000000000 +0200
@@ -87,6 +87,8 @@
  *	0.35: 26 Jun 2005: Support for MCP55 added.
  *	0.36: 28 Jun 2005: Add jumbo frame support.
  *	0.37: 10 Jul 2005: Additional ethtool support, cleanup of pci id list
+ *	0.38: 16 Jul 2005: tx irq rewrite: Use global flags instead of
+ *			   per-packet flags.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -98,7 +100,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.36"
+#define FORCEDETH_VERSION		"0.38"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -133,12 +135,9 @@
  * Hardware access:
  */
 
-#define DEV_NEED_LASTPACKET1	0x0001	/* set LASTPACKET1 in tx flags */
-#define DEV_IRQMASK_1		0x0002  /* use NVREG_IRQMASK_WANTED_1 for irq mask */
-#define DEV_IRQMASK_2		0x0004  /* use NVREG_IRQMASK_WANTED_2 for irq mask */
-#define DEV_NEED_TIMERIRQ	0x0008  /* set the timer irq flag in the irq mask */
-#define DEV_NEED_LINKTIMER	0x0010	/* poll link settings. Relies on the timer irq */
-#define DEV_HAS_LARGEDESC	0x0020	/* device supports jumbo frames and needs packet format 2 */
+#define DEV_NEED_TIMERIRQ	0x0001  /* set the timer irq flag in the irq mask */
+#define DEV_NEED_LINKTIMER	0x0002	/* poll link settings. Relies on the timer irq */
+#define DEV_HAS_LARGEDESC	0x0004	/* device supports jumbo frames and needs packet format 2 */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -149,13 +148,16 @@
 #define NVREG_IRQ_RX			0x0002
 #define NVREG_IRQ_RX_NOBUF		0x0004
 #define NVREG_IRQ_TX_ERR		0x0008
-#define NVREG_IRQ_TX2			0x0010
+#define NVREG_IRQ_TX_OK			0x0010
 #define NVREG_IRQ_TIMER			0x0020
 #define NVREG_IRQ_LINK			0x0040
+#define NVREG_IRQ_TX_ERROR		0x0080
 #define NVREG_IRQ_TX1			0x0100
-#define NVREG_IRQMASK_WANTED_1		0x005f
-#define NVREG_IRQMASK_WANTED_2		0x0147
-#define NVREG_IRQ_UNKNOWN		(~(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR|NVREG_IRQ_TX2|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX1))
+#define NVREG_IRQMASK_WANTED		0x00df
+
+#define NVREG_IRQ_UNKNOWN	(~(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR| \
+					NVREG_IRQ_TX_OK|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX_ERROR| \
+					NVREG_IRQ_TX1))
 
 	NvRegUnknownSetupReg6 = 0x008,
 #define NVREG_UNKSETUP6_VAL		3
@@ -296,7 +298,7 @@
 
 #define NV_TX_LASTPACKET	(1<<16)
 #define NV_TX_RETRYERROR	(1<<19)
-#define NV_TX_LASTPACKET1	(1<<24)
+#define NV_TX_FORCED_INTERRUPT	(1<<24)
 #define NV_TX_DEFERRED		(1<<26)
 #define NV_TX_CARRIERLOST	(1<<27)
 #define NV_TX_LATECOLLISION	(1<<28)
@@ -306,7 +308,7 @@
 
 #define NV_TX2_LASTPACKET	(1<<29)
 #define NV_TX2_RETRYERROR	(1<<18)
-#define NV_TX2_LASTPACKET1	(1<<23)
+#define NV_TX2_FORCED_INTERRUPT	(1<<30)
 #define NV_TX2_DEFERRED		(1<<25)
 #define NV_TX2_CARRIERLOST	(1<<26)
 #define NV_TX2_LATECOLLISION	(1<<27)
@@ -1013,9 +1015,39 @@
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	dprintk(KERN_DEBUG "%s: Got tx_timeout. irq: %08x\n", dev->name,
+	printk(KERN_INFO "%s: Got tx_timeout. irq: %08x\n", dev->name,
 			readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK);
 
+	{
+		int i;
+
+		printk(KERN_INFO "%s: Ring at %lx: next %d nic %d\n",
+				dev->name, (unsigned long)np->ring_addr,
+				np->next_tx, np->nic_tx);
+		printk(KERN_INFO "%s: Dumping tx registers\n", dev->name);
+		for (i=0;i<0x400;i+= 32) {
+			printk(KERN_INFO "%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
+					i,
+					readl(base + i + 0), readl(base + i + 4),
+					readl(base + i + 8), readl(base + i + 12),
+					readl(base + i + 16), readl(base + i + 20),
+					readl(base + i + 24), readl(base + i + 28));
+		}
+		printk(KERN_INFO "%s: Dumping tx ring\n", dev->name);
+		for (i=0;i<TX_RING;i+= 4) {
+			printk(KERN_INFO "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
+					i, 
+					le32_to_cpu(np->tx_ring[i].PacketBuffer),
+					le32_to_cpu(np->tx_ring[i].FlagLen),
+					le32_to_cpu(np->tx_ring[i+1].PacketBuffer),
+					le32_to_cpu(np->tx_ring[i+1].FlagLen),
+					le32_to_cpu(np->tx_ring[i+2].PacketBuffer),
+					le32_to_cpu(np->tx_ring[i+2].FlagLen),
+					le32_to_cpu(np->tx_ring[i+3].PacketBuffer),
+					le32_to_cpu(np->tx_ring[i+3].FlagLen));
+		}
+	}
+
 	spin_lock_irq(&np->lock);
 
 	/* 1) stop tx engine */
@@ -1557,7 +1589,7 @@
 		if (!(events & np->irqmask))
 			break;
 
-		if (events & (NVREG_IRQ_TX1|NVREG_IRQ_TX2|NVREG_IRQ_TX_ERR)) {
+		if (events & (NVREG_IRQ_TX1|NVREG_IRQ_TX_OK|NVREG_IRQ_TX_ERROR|NVREG_IRQ_TX_ERR)) {
 			spin_lock(&np->lock);
 			nv_tx_done(dev);
 			spin_unlock(&np->lock);
@@ -2213,17 +2245,10 @@
 
 	if (np->desc_ver == DESC_VER_1) {
 		np->tx_flags = NV_TX_LASTPACKET|NV_TX_VALID;
-		if (id->driver_data & DEV_NEED_LASTPACKET1)
-			np->tx_flags |= NV_TX_LASTPACKET1;
 	} else {
 		np->tx_flags = NV_TX2_LASTPACKET|NV_TX2_VALID;
-		if (id->driver_data & DEV_NEED_LASTPACKET1)
-			np->tx_flags |= NV_TX2_LASTPACKET1;
 	}
-	if (id->driver_data & DEV_IRQMASK_1)
-		np->irqmask = NVREG_IRQMASK_WANTED_1;
-	if (id->driver_data & DEV_IRQMASK_2)
-		np->irqmask = NVREG_IRQMASK_WANTED_2;
+	np->irqmask = NVREG_IRQMASK_WANTED;
 	if (id->driver_data & DEV_NEED_TIMERIRQ)
 		np->irqmask |= NVREG_IRQ_TIMER;
 	if (id->driver_data & DEV_NEED_LINKTIMER) {
@@ -2329,73 +2354,63 @@
 static struct pci_device_id pci_tbl[] = {
 	{	/* nForce Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_1),
-		.driver_data = DEV_IRQMASK_1|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce2 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_2),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_3),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_4),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_5),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_6),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* nForce3 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_7),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_8),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_9),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_10),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_11),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_12),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_13),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|
-			DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
 	},
 	{0,},
 };

--------------080303050106030109080905--
