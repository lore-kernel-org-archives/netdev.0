From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Fri, 3 Sep 2004 22:56:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040904025640.GA27001@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, torvalds@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/3c527.c            |   13 ++----
 drivers/net/8139cp.c           |    2 -
 drivers/net/forcedeth.c        |   78 +++++++++++++++++++++++++++--------------
 drivers/net/r8169.c            |    2 -
 drivers/net/wireless/airo.c    |    1 
 drivers/net/wireless/wavelan.c |   11 +++--
 6 files changed, 66 insertions(+), 41 deletions(-)

through these ChangeSets:

<manfred@colorfullife.com> (04/09/03 1.2021)
   [PATCH] fix media detection for nForce 2 nics
   
   attached is a patch that polls the media setting for non GigE nForce
   nics:
   Without polling, media changes are not autodetected. This is fatal,
   because the nic initialization is asynchroneous, thus "modprobe;ifup"
   resulted in a dead network connection. The attached patch fixes that
   problem.
   
   It's a repost of a patch I sent around three weeks ago: you objected
   that I rely on the nic irq instead of a software timer. I've documented
   why this is ok.

<akpm@osdl.org> (04/09/03 1.2020)
   [PATCH] airo build fix
   
   drivers/net/wireless/airo.c: In function `issuecommand':
   drivers/net/wireless/airo.c:3812: warning: implicit declaration of function `kernel_locked'
   *** Warning: "kernel_locked" [drivers/net/wireless/airo.ko] undefined!
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<davej@redhat.com> (04/09/03 1.2019)
   [PATCH] wavelan uninitalised var.
   
   This seems a little odd, printing out the value of a variable
   we haven't read yet.
   
   Signed-off-by: Dave Jones <davej@redhat.com>

<davej@redhat.com> (04/09/03 1.2018)
   [PATCH] 3c527 possible oops.
   
   If the alloc_skb() fails, we dereference it in the skb_reserve() call.
   Move the skb_reserve() call to after the NULL check.
   Also clean up some CodingStyle violations whilst in the vicinity.
   
   Signed-off-by: Dave Jones <davej@redhat.com>

<jgarzik@pobox.com> (04/08/31 1.1860.2.1)
   [netdrvr 8139cp,r8169] fix dma_addr_t sizeof test

diff -Nru a/drivers/net/3c527.c b/drivers/net/3c527.c
--- a/drivers/net/3c527.c	2004-09-03 22:20:03 -04:00
+++ b/drivers/net/3c527.c	2004-09-03 22:20:03 -04:00
@@ -751,18 +751,15 @@
 	
 	rx_base=lp->rx_chain;
 
-	for(i=0; i<RX_RING_LEN; i++)
-	{
+	for(i=0; i<RX_RING_LEN; i++) {
 		lp->rx_ring[i].skb=alloc_skb(1532, GFP_KERNEL);
-		skb_reserve(lp->rx_ring[i].skb, 18);  
-
-		if(lp->rx_ring[i].skb==NULL)
-		{
-			for(;i>=0;i--)
+		if (lp->rx_ring[i].skb==NULL) {
+			for (;i>=0;i--)
 				kfree_skb(lp->rx_ring[i].skb);
 			return -ENOBUFS;
 		}
-		
+		skb_reserve(lp->rx_ring[i].skb, 18);
+
 		p=isa_bus_to_virt(lp->base+rx_base);
 				
 		p->control=0;
diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	2004-09-03 22:20:03 -04:00
+++ b/drivers/net/8139cp.c	2004-09-03 22:20:03 -04:00
@@ -1698,7 +1698,7 @@
 	}
 
 	/* Configure DMA attributes. */
-	if ((sizeof(dma_addr_t) > 32) &&
+	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL) &&
 	    !pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
 		pci_using_dac = 1;
diff -Nru a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c	2004-09-03 22:20:03 -04:00
+++ b/drivers/net/forcedeth.c	2004-09-03 22:20:03 -04:00
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
@@ -367,6 +369,7 @@
 
 #define OOM_REFILL	(1+HZ/20)
 #define POLL_WAIT	(1+HZ/100)
+#define LINK_TIMEOUT	(3*HZ)
 
 #define DESC_VER_1	0x0
 #define DESC_VER_2	0x02100
@@ -446,6 +449,11 @@
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
@@ -1384,6 +1392,25 @@
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
@@ -1391,25 +1418,10 @@
 
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
 
@@ -1452,6 +1464,12 @@
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
@@ -1816,6 +1834,14 @@
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
@@ -1909,21 +1935,21 @@
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
diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2004-09-03 22:20:03 -04:00
+++ b/drivers/net/r8169.c	2004-09-03 22:20:03 -04:00
@@ -983,7 +983,7 @@
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
-	if ((sizeof(dma_addr_t) > 32) &&
+	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK))
 		tp->cp_cmd |= PCIDAC;
 	else {
diff -Nru a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c	2004-09-03 22:20:03 -04:00
+++ b/drivers/net/wireless/airo.c	2004-09-03 22:20:03 -04:00
@@ -25,6 +25,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/proc_fs.h>
+#include <linux/smp_lock.h>
 
 #include <linux/sched.h>
 #include <linux/ptrace.h>
diff -Nru a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
--- a/drivers/net/wireless/wavelan.c	2004-09-03 22:20:03 -04:00
+++ b/drivers/net/wireless/wavelan.c	2004-09-03 22:20:03 -04:00
@@ -3822,17 +3822,18 @@
 	if ((hasr & HASR_MMC_INTR) && (lp->hacr & HACR_MMC_INT_ENABLE)) {
 		u8 dce_status;
 
-#ifdef DEBUG_INTERRUPT_ERROR
-		printk(KERN_INFO
-		       "%s: wavelan_interrupt(): unexpected mmc interrupt: status 0x%04x.\n",
-		       dev->name, dce_status);
-#endif
 		/*
 		 * Interrupt from the modem management controller.
 		 * This will clear it -- ignored for now.
 		 */
 		mmc_read(ioaddr, mmroff(0, mmr_dce_status), &dce_status,
 			 sizeof(dce_status));
+
+#ifdef DEBUG_INTERRUPT_ERROR
+		printk(KERN_INFO
+		       "%s: wavelan_interrupt(): unexpected mmc interrupt: status 0x%04x.\n",
+		       dev->name, dce_status);
+#endif
 	}
 
 	/* Check if not controller interrupt */
