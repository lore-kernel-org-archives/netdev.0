From: Manfred Spraul <manfred@colorfullife.com>
Subject: [CFT, PATCH] media detection updates for 100 MBit nForce nics
Date: Sat, 07 Aug 2004 12:01:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4114A873.7050007@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080406060307080703000902"
Cc: Tim Waugh <twaugh@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080406060307080703000902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

the media detection seems to be broken for the non-gige nForce nics: The 
driver doesn't receive interupts for link changes and thus a link change 
means a dead network interface.
This is fatal, because the driver doesn't wait for autonegotiation 
completion in _probe() or _open().

The attached patch adds a periodic timer that polls the phy - that 
should fix the problem.
Could you test it? I don't have an 100 MBit nForce board, my 250-Gb 
doesn't show the problem.

Thanks,
    Manfred
P.S.: The patch is against the 0.29 jumbo frame version I posted last 
week, but the rejects against stock 2.6.8-rc3-mm1 are trivial: just the 
changelog and the version number. You can ignore the merge errors.

--------------080406060307080703000902
Content-Type: text/plain;
 name="patch-forcedeth-timer"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-timer"

// $Header$
// Kernel Version:
//  VERSION = 2
//  PATCHLEVEL = 6
//  SUBLEVEL = 8
//  EXTRAVERSION =-rc3-mm1
--- 2.6/drivers/net/forcedeth.c	2004-08-07 11:52:47.563501472 +0200
+++ build-2.6/drivers/net/forcedeth.c	2004-08-07 11:40:34.000000000 +0200
@@ -77,6 +77,7 @@
  *	0.28: 21 Jun 2004: Big cleanup, making driver mostly endian safe
  *	0.29: 28 Jul 2004: Add jumbo frame support. Add reset into nv_close,
  *			   previous code clobbered kfree'd memory.
+ *	0.30: 07 Aug 2004: Add backup timer for link change notification.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -88,7 +89,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.29"
+#define FORCEDETH_VERSION		"0.30"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -126,6 +127,7 @@
 #define DEV_IRQMASK_1		0x0002
 #define DEV_IRQMASK_2		0x0004
 #define DEV_NEED_TIMERIRQ	0x0008
+#define DEV_NEED_LINKTIMER	0x0010
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -373,6 +375,7 @@ struct ring_desc {
 
 #define OOM_REFILL	(1+HZ/20)
 #define POLL_WAIT	(1+HZ/100)
+#define LINK_TIMEOUT	(3*HZ)
 
 #define DESC_VER_1	0x0
 #define DESC_VER_2	0x02100
@@ -453,6 +456,11 @@ struct fe_priv {
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
@@ -1470,6 +1478,25 @@ set_speed:
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
@@ -1477,25 +1504,10 @@ static void nv_link_irq(struct net_devic
 
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
 
@@ -1538,6 +1550,12 @@ static irqreturn_t nv_nic_irq(int foo, v
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
@@ -1907,6 +1925,14 @@ static int __devinit nv_probe(struct pci
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
@@ -2000,21 +2026,21 @@ static struct pci_device_id pci_tbl[] = 
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

--------------080406060307080703000902--
