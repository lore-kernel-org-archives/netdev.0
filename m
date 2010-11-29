From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/11] forcedeth: Convert remaining dprintk to netdev_dbg
Date: Mon, 29 Nov 2010 09:41:55 -0800
Message-ID: <87181f5da23c220d242dfb0db151d8a489381ad6.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The remaining dprintk uses are emitted as KERN_INFO.
Change these dprintk uses to netdev_dbg.
Remove the now unused dprintk macros.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |   31 ++++++++++++-------------------
 1 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1ac8b4e..b30a599 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -66,12 +66,6 @@
 #include <asm/irq.h>
 #include <asm/system.h>
 
-#if 0
-#define dprintk			printk
-#else
-#define dprintk(x...)		do { } while (0)
-#endif
-
 #define TX_WORK_PER_LOOP  64
 #define RX_WORK_PER_LOOP  64
 
@@ -3033,8 +3027,7 @@ static void nv_set_multicast(struct net_device *dev)
 	writel(mask[0], base + NvRegMulticastMaskA);
 	writel(mask[1], base + NvRegMulticastMaskB);
 	writel(pff, base + NvRegPacketFilterFlags);
-	dprintk(KERN_INFO "%s: reconfiguration for multicast lists.\n",
-		dev->name);
+	netdev_dbg(dev, "reconfiguration for multicast lists\n");
 	nv_start_rx(dev);
 	spin_unlock_irq(&np->lock);
 }
@@ -3192,8 +3185,8 @@ set_speed:
 	if (np->duplex == newdup && np->linkspeed == newls)
 		return retval;
 
-	dprintk(KERN_INFO "%s: changing link setting from %d/%d to %d/%d.\n",
-			dev->name, np->linkspeed, np->duplex, newls, newdup);
+	netdev_dbg(dev, "changing link setting from %d/%d to %d/%d\n",
+		   np->linkspeed, np->duplex, newls, newdup);
 
 	np->duplex = newdup;
 	np->linkspeed = newls;
@@ -3336,7 +3329,7 @@ static void nv_link_irq(struct net_device *dev)
 
 	miistat = readl(base + NvRegMIIStatus);
 	writel(NVREG_MIISTAT_LINKCHANGE, base + NvRegMIIStatus);
-	dprintk(KERN_INFO "%s: link change irq, status 0x%x.\n", dev->name, miistat);
+	netdev_dbg(dev, "link change irq, status 0x%x\n", miistat);
 
 	if (miistat & (NVREG_MIISTAT_LINKCHANGE))
 		nv_linkchange(dev);
@@ -5243,7 +5236,7 @@ static int nv_open(struct net_device *dev)
 		u32 miistat;
 		miistat = readl(base + NvRegMIIStatus);
 		writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
-		dprintk(KERN_INFO "startup: got 0x%08x.\n", miistat);
+		netdev_dbg(dev, "startup: got 0x%08x\n", miistat);
 	}
 	/* set linkspeed to invalid value, thus force nv_update_linkspeed
 	 * to init hw */
@@ -5299,7 +5292,7 @@ static int nv_close(struct net_device *dev)
 	base = get_hwbase(dev);
 	nv_disable_hw_interrupts(dev, np->irqmask);
 	pci_push(base);
-	dprintk(KERN_INFO "%s: Irqmask is zero again\n", dev->name);
+	netdev_dbg(dev, "Irqmask is zero again\n");
 
 	spin_unlock_irq(&np->lock);
 
@@ -5649,11 +5642,11 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	if (id->driver_data & DEV_NEED_TIMERIRQ)
 		np->irqmask |= NVREG_IRQ_TIMER;
 	if (id->driver_data & DEV_NEED_LINKTIMER) {
-		dprintk(KERN_INFO "%s: link timer on.\n", pci_name(pci_dev));
+		netdev_dbg(dev, "%s: link timer on\n", pci_name(pci_dev));
 		np->need_linktimer = 1;
 		np->link_timeout = jiffies + LINK_TIMEOUT;
 	} else {
-		dprintk(KERN_INFO "%s: link timer off.\n", pci_name(pci_dev));
+		netdev_dbg(dev, "%s: link timer off\n", pci_name(pci_dev));
 		np->need_linktimer = 0;
 	}
 
@@ -5684,16 +5677,16 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 			np->mac_in_use = 1;
 			if (np->mgmt_version > 0)
 				np->mac_in_use = readl(base + NvRegMgmtUnitControl) & NVREG_MGMTUNITCONTROL_INUSE;
-			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n",
-				pci_name(pci_dev), np->mac_in_use);
+			netdev_dbg(dev, "%s: mgmt unit is running. mac in use %x\n",
+				   pci_name(pci_dev), np->mac_in_use);
 			/* management unit setup the phy already? */
 			if (np->mac_in_use &&
 			    ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
 			     NVREG_XMITCTL_SYNC_PHY_INIT)) {
 				/* phy is inited by mgmt unit */
 				phyinitialized = 1;
-				dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n",
-					pci_name(pci_dev));
+				netdev_dbg(dev, "%s: Phy already initialized by mgmt unit\n",
+					   pci_name(pci_dev));
 			} else {
 				/* we need to init the phy */
 			}
-- 
1.7.3.2.245.g03276.dirty
