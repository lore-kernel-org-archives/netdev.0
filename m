From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] fix media detection for nForce 2 nics
Date: Tue, 31 Aug 2004 22:11:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4134DB8C.1030108@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030900010801050901060009"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030900010801050901060009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

attached is a patch that polls the media setting for non GigE nForce nics:
Without polling, media changes are not autodetected. This is fatal, 
because the nic initialization is asynchroneous, thus "modprobe;ifup" 
resulted in a dead network connection. The attached patch fixes that 
problem.

It's a repost of a patch I sent around three weeks ago: you objected 
that I rely on the nic irq instead of a software timer. I've documented 
why this is ok.
Could you add the patch to your tree and forward it to Andrew? The bug 
is a show-stopper, it must be fixed before I can backport the gige 
changes to 2.4.

--
    Manfred

--------------030900010801050901060009
Content-Type: text/plain;
 name="patch-forcedeth-029-timer"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-029-timer"

// $Header$
// Kernel Version:
//  VERSION = 2
//  PATCHLEVEL = 6
//  SUBLEVEL = 8
//  EXTRAVERSION =
--- 2.6/drivers/net/forcedeth.c	2004-08-20 19:56:32.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2004-08-31 21:58:32.896159514 +0200
@@ -75,6 +75,7 @@
  *			   added CK804/MCP04 device IDs, code fixes
  *			   for registers, link status and other minor fixes.
  *	0.28: 21 Jun 2004: Big cleanup, making driver mostly endian safe
+ *	0.29: 31 Aug 2004: Add backup timer for link change notification.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -86,7 +87,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.28"
+#define FORCEDETH_VERSION		"0.29"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -120,10 +121,11 @@
  * Hardware access:
  */
 
-#define DEV_NEED_LASTPACKET1	0x0001
-#define DEV_IRQMASK_1		0x0002
-#define DEV_IRQMASK_2		0x0004
-#define DEV_NEED_TIMERIRQ	0x0008
+#define DEV_NEED_LASTPACKET1	0x0001	/* set LASTPACKET1 in tx flags */
+#define DEV_IRQMASK_1		0x0002  /* use NVREG_IRQMASK_WANTED_1 for irq mask */
+#define DEV_IRQMASK_2		0x0004  /* use NVREG_IRQMASK_WANTED_2 for irq mask */
+#define DEV_NEED_TIMERIRQ	0x0008  /* set the timer irq flag in the irq mask */
+#define DEV_NEED_LINKTIMER	0x0010	/* poll link settings. Relies on the timer irq */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -367,6 +369,7 @@ struct ring_desc {
 
 #define OOM_REFILL	(1+HZ/20)
 #define POLL_WAIT	(1+HZ/100)
+#define LINK_TIMEOUT	(3*HZ)
 
 #define DESC_VER_1	0x0
 #define DESC_VER_2	0x02100
@@ -446,6 +449,11 @@ struct fe_priv {
 	struct timer_list oom_kick;
 	struct timer_list nic_poll;
 
+	/* media detection workaround.
+	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
+	 */
+	int need_linktimer;
+	unsigned long link_timeout;
 	/*
 	 * tx specific fields.
 	 */
@@ -1384,6 +1392,25 @@ set_speed:
 	return retval;
 }
 
+static void nv_linkchange(struct net_device *dev)
+{
+	if (nv_update_linkspeed(dev)) {
+		if (netif_carrier_ok(dev)) {
+			nv_stop_rx(dev);
+		} else {
+			netif_carrier_on(dev);
+			printk(KERN_INFO "%s: link up.\n", dev->name);
+		}
+		nv_start_rx(dev);
+	} else {
+		if (netif_carrier_ok(dev)) {
+			netif_carrier_off(dev);
+			printk(KERN_INFO "%s: link down.\n", dev->name);
+			nv_stop_rx(dev);
+		}
+	}
+}
+
 static void nv_link_irq(struct net_device *dev)
 {
 	u8 *base = get_hwbase(dev);
@@ -1391,25 +1418,10 @@ static void nv_link_irq(struct net_devic
 
 	miistat = readl(base + NvRegMIIStatus);
 	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
-	dprintk(KERN_DEBUG "%s: link change notification, status 0x%x.\n", dev->name, miistat);
+	dprintk(KERN_INFO "%s: link change irq, status 0x%x.\n", dev->name, miistat);
 
-	if (miistat & (NVREG_MIISTAT_LINKCHANGE)) {
-		if (nv_update_linkspeed(dev)) {
-			if (netif_carrier_ok(dev)) {
-				nv_stop_rx(dev);
-			} else {
-				netif_carrier_on(dev);
-				printk(KERN_INFO "%s: link up.\n", dev->name);
-			}
-			nv_start_rx(dev);
-		} else {
-			if (netif_carrier_ok(dev)) {
-				netif_carrier_off(dev);
-				printk(KERN_INFO "%s: link down.\n", dev->name);
-				nv_stop_rx(dev);
-			}
-		}
-	}
+	if (miistat & (NVREG_MIISTAT_LINKCHANGE))
+		nv_linkchange(dev);
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
@@ -1452,6 +1464,12 @@ static irqreturn_t nv_nic_irq(int foo, v
 			nv_link_irq(dev);
 			spin_unlock(&np->lock);
 		}
+		if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
+			spin_lock(&np->lock);
+			nv_linkchange(dev);
+			spin_unlock(&np->lock);
+			np->link_timeout = jiffies + LINK_TIMEOUT;
+		}
 		if (events & (NVREG_IRQ_TX_ERR)) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
 						dev->name, events);
@@ -1816,6 +1834,14 @@ static int __devinit nv_probe(struct pci
 		np->irqmask = NVREG_IRQMASK_WANTED_2;
 	if (id->driver_data & DEV_NEED_TIMERIRQ)
 		np->irqmask |= NVREG_IRQ_TIMER;
+	if (id->driver_data & DEV_NEED_LINKTIMER) {
+		dprintk(KERN_INFO "%s: link timer on.\n", pci_name(pci_dev));
+		np->need_linktimer = 1;
+		np->link_timeout = jiffies + LINK_TIMEOUT;
+	} else {
+		dprintk(KERN_INFO "%s: link timer off.\n", pci_name(pci_dev));
+		np->need_linktimer = 0;
+	}
 
 	/* find a suitable phy */
 	for (i = 1; i < 32; i++) {
@@ -1909,21 +1935,21 @@ static struct pci_device_id pci_tbl[] = 
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_1,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_IRQMASK_1|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_IRQMASK_1|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce2 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_2,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_3,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,

--------------030900010801050901060009--
