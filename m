From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: [PATCH 1/2] [2.6] update forcedeth from 0.20 to 0.22
Date: Tue, 27 Jan 2004 12:20:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40164999.6020806@gmx.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030803080205040107090208"
Cc: Netdev <netdev@oss.sgi.com>, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030803080205040107090208
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Jeff,

the attached patch is against current Linus bk tree and updates forcedeth
from 0.20 to 0.22. This is the version discussed a few days ago.
To address the comments we received on 0.22, we have prepared another
patch to 0.23, which is the next one in this series.

Please consider applying this patch and the next one. The patches are
split up so you can verify more easily that we addressed most of the comments.

Regards,
Carl-Daniel

--------------030803080205040107090208
Content-Type: text/plain;
 name="forcedeth_0.20to0.22.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="forcedeth_0.20to0.22.txt"

===== drivers/net/forcedeth.c 1.5 vs edited =====
--- 1.5/drivers/net/forcedeth.c	Fri Jan 16 01:47:29 2004
+++ edited/drivers/net/forcedeth.c	Fri Jan 23 17:00:27 2004
@@ -60,15 +60,23 @@
  * 			   addresses, really stop rx if already running
  * 			   in start_rx, clean up a bit.
  * 				(C) Carl-Daniel Hailfinger
- * 	0.20: 07 Dev 2003: alloc fixes
+ * 	0.20: 07 Dec 2003: alloc fixes
+ * 	0.21: 12 Jan 2004: additional alloc fix, nic polling fix.
+ *	0.22: 19 Jan 2004: reprogram timer to a sane rate, avoid lockup
+ * 			   on close.
+ * 				(C) Carl-Daniel Hailfinger
  *
  * Known bugs:
- * The irq handling is wrong - no tx done interrupts are generated.
- * This means recovery from netif_stop_queue only happens in the hw timer
- * interrupt (1/2 second on nForce2, 1/100 second on nForce3), or if an
- * rx packet arrives by chance.
+ * We suspect that on some hardware no TX done interrupts are generated.
+ * This means recovery from netif_stop_queue only happens if the hw timer
+ * interrupt fires (100 times/second, configurable with NVREG_POLL_DEFAULT)
+ * and the timer is active in the IRQMask, or if a rx packet arrives by chance.
+ * If your hardware reliably generates tx done interrupts, then you can remove
+ * DEV_NEED_TIMERIRQ from the driver_data flags.
+ * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
+ * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.19"
+#define FORCEDETH_VERSION		"0.22"
 
 #include <linux/module.h>
 #include <linux/types.h>
@@ -104,6 +112,7 @@
 #define DEV_NEED_LASTPACKET1	0x0001
 #define DEV_IRQMASK_1		0x0002
 #define DEV_IRQMASK_2		0x0004
+#define DEV_NEED_TIMERIRQ	0x0008
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -124,7 +133,12 @@
 	NvRegUnknownSetupReg6 = 0x008,
 #define NVREG_UNKSETUP6_VAL		3
 
+/*
+ * NVREG_POLL_DEFAULT is the interval length of the timer source on the nic
+ * NVREG_POLL_DEFAULT=97 would result in an interval length of 1 ms
+ */
 	NvRegPollingInterval = 0x00c,
+#define NVREG_POLL_DEFAULT	970
 	NvRegMisc1 = 0x080,
 #define NVREG_MISC1_HD		0x02
 #define NVREG_MISC1_FORCE	0x3b0f3c
@@ -1185,6 +1199,7 @@
 	writel(NVREG_RNDSEED_FORCE | (i&NVREG_RNDSEED_MASK), base + NvRegRandomSeed);
 	writel(NVREG_UNKSETUP1_VAL, base + NvRegUnknownSetupReg1);
 	writel(NVREG_UNKSETUP2_VAL, base + NvRegUnknownSetupReg2);
+	writel(NVREG_POLL_DEFAULT, base + NvRegPollingInterval);
 	writel(NVREG_UNKSETUP6_VAL, base + NvRegUnknownSetupReg6);
 	writel((np->phyaddr << NVREG_ADAPTCTL_PHYSHIFT)|NVREG_ADAPTCTL_PHYVALID,
 			base + NvRegAdapterControl);
@@ -1248,6 +1263,7 @@
 static int close(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
+	u8 *base;
 
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
@@ -1261,6 +1277,13 @@
 	spin_lock_irq(&np->lock);
 	stop_tx(dev);
 	stop_rx(dev);
+	base = get_hwbase(dev);
+
+	/* disable interrupts on the nic or we will lock up */
+	writel(0, base + NvRegIrqMask);
+	pci_push(base);
+	dprintk(KERN_INFO "%s: Irqmask is zero again\n", dev->name);
+
 	spin_unlock_irq(&np->lock);
 
 	free_irq(dev->irq, dev);
@@ -1393,6 +1416,8 @@
 		np->irqmask = NVREG_IRQMASK_WANTED_1;
 	if (id->driver_data & DEV_IRQMASK_2)
 		np->irqmask = NVREG_IRQMASK_WANTED_2;
+	if (id->driver_data & DEV_NEED_TIMERIRQ)
+		np->irqmask |= NVREG_IRQ_TIMER;
 
 	err = register_netdev(dev);
 	if (err) {
@@ -1450,21 +1475,21 @@
 		.device = 0x1C3,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_IRQMASK_1,
+		.driver_data = DEV_IRQMASK_1|DEV_NEED_TIMERIRQ,
 	},
 	{	/* nForce2 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = 0x0066,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
 	},
 	{	/* nForce3 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = 0x00D6,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
 	},
 	{0,},
 };

--------------030803080205040107090208--
