From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Wed, 24 Nov 2004 16:02:36 -0500
Message-ID: <20041124210235.GA25207@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 arch/m68k/configs/atari_defconfig |    3 ++-
 arch/m68k/configs/hp300_defconfig |    4 ++--
 drivers/net/e100.c                |   18 ++++++++++--------
 drivers/net/hplance.c             |   27 +++++++++++++++++----------
 drivers/net/ibmveth.c             |    2 +-
 drivers/net/pcnet32.c             |    7 ++++++-
 drivers/net/tulip/21142.c         |    2 +-
 drivers/net/tulip/eeprom.c        |    1 +
 drivers/net/tulip/interrupt.c     |    2 +-
 drivers/net/tulip/media.c         |    1 +
 drivers/net/tulip/pnic.c          |    1 +
 drivers/net/tulip/pnic2.c         |    2 +-
 drivers/net/tulip/timer.c         |    1 +
 drivers/net/tulip/tulip.h         |   15 ++++++++++++++-
 drivers/net/tulip/tulip_core.c    |    2 +-
 15 files changed, 60 insertions(+), 28 deletions(-)

through these ChangeSets:

Andrew Morton:
  o e100: early reset fix

Don Fry:
  o pcnet32: added pci_disable_device

Geert Uytterhoeven:
  o M68k: Update HP300 defconfig (enable DIO and HP Lance Ethernet)
  o M68k HP Lance Ethernet: Fix leaks on probe/removal
  o M68k: Update Atari defconfig (enable Ethernet and MII)

John W. Linville:
  o tulip: make tulip_stop_rxtx() wait for DMA to fully stop

Santiago Leon:
  o make ibmveth link always up

diff -Nru a/arch/m68k/configs/atari_defconfig b/arch/m68k/configs/atari_defconfig
--- a/arch/m68k/configs/atari_defconfig	2004-11-24 15:49:50 -05:00
+++ b/arch/m68k/configs/atari_defconfig	2004-11-24 15:49:50 -05:00
@@ -430,7 +430,8 @@
 #
 # Ethernet (10 or 100Mbit)
 #
-# CONFIG_NET_ETHERNET is not set
+CONFIG_NET_ETHERNET=y
+CONFIG_MII=m
 CONFIG_ATARILANCE=m
 
 #
diff -Nru a/arch/m68k/configs/hp300_defconfig b/arch/m68k/configs/hp300_defconfig
--- a/arch/m68k/configs/hp300_defconfig	2004-11-24 15:49:50 -05:00
+++ b/arch/m68k/configs/hp300_defconfig	2004-11-24 15:49:50 -05:00
@@ -65,7 +65,7 @@
 # CONFIG_APOLLO is not set
 # CONFIG_VME is not set
 CONFIG_HP300=y
-# CONFIG_DIO is not set
+CONFIG_DIO=y
 # CONFIG_SUN3X is not set
 # CONFIG_Q40 is not set
 
@@ -404,7 +404,7 @@
 #
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=m
-# CONFIG_HPLANCE is not set
+CONFIG_HPLANCE=y
 
 #
 # Ethernet (1000 Mbit)
diff -Nru a/drivers/net/e100.c b/drivers/net/e100.c
--- a/drivers/net/e100.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/e100.c	2004-11-24 15:49:50 -05:00
@@ -2204,22 +2204,24 @@
 		goto err_out_disable_pdev;
 	}
 
+	nic->csr = ioremap(pci_resource_start(pdev, 0), sizeof(struct csr));
+	if(!nic->csr) {
+		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
+		err = -ENOMEM;
+		goto err_out_free_res;
+	}
+
+	e100_hw_reset(nic);
+
 	pci_set_master(pdev);
 
 	if((err = pci_set_dma_mask(pdev, 0xFFFFFFFFULL))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
-		goto err_out_free_res;
+		goto err_out_iounmap;
 	}
 
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
-
-	nic->csr = ioremap(pci_resource_start(pdev, 0), sizeof(struct csr));
-	if(!nic->csr) {
-		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
-		err = -ENOMEM;
-		goto err_out_free_res;
-	}
 
 	if(ent->driver_data)
 		nic->flags |= ich;
diff -Nru a/drivers/net/hplance.c b/drivers/net/hplance.c
--- a/drivers/net/hplance.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/hplance.c	2004-11-24 15:49:50 -05:00
@@ -76,25 +76,31 @@
 				const struct dio_device_id *ent)
 {
 	struct net_device *dev;
-	int err;
+	int err = -ENOMEM;
 
 	dev = alloc_etherdev(sizeof(struct hplance_private));
 	if (!dev)
-		return -ENOMEM;
+		goto out;
 
-	if (!request_mem_region(d->resource.start, d->resource.end-d->resource.start, d->name))
-		return -EBUSY;
+	err = -EBUSY;
+	if (!request_mem_region(dio_resource_start(d),
+				dio_resource_len(d), d->name))
+		goto out_free_netdev;
 
-	SET_MODULE_OWNER(dev);
-        
 	hplance_init(dev, d);
 	err = register_netdev(dev);
-	if (err) {
-		free_netdev(dev);
-		return err;
-	}
+	if (err)
+		goto out_release_mem_region;
+
 	dio_set_drvdata(d, dev);
 	return 0;
+
+ out_release_mem_region:
+	release_mem_region(dio_resource_start(d), dio_resource_len(d));
+ out_free_netdev:
+	free_netdev(dev);
+ out:
+	return err;
 }
 
 static void __devexit hplance_remove_one(struct dio_dev *d)
@@ -102,6 +108,7 @@
 	struct net_device *dev = dio_get_drvdata(d);
 
 	unregister_netdev(dev);
+	release_mem_region(dio_resource_start(d), dio_resource_len(d));
 	free_netdev(dev);
 }
 
diff -Nru a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/ibmveth.c	2004-11-24 15:49:50 -05:00
@@ -598,7 +598,7 @@
 }
 
 static u32 netdev_get_link(struct net_device *dev) {
-	return 0;
+	return 1;
 }
 
 static struct ethtool_ops netdev_ethtool_ops = {
diff -Nru a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/pcnet32.c	2004-11-24 15:49:50 -05:00
@@ -1010,7 +1010,11 @@
 	return -EBUSY;
     }
 
-    return pcnet32_probe1(ioaddr, 1, pdev);
+    err =  pcnet32_probe1(ioaddr, 1, pdev);
+    if (err < 0) {
+	pci_disable_device(pdev);
+    }
+    return err;
 }
 
 
@@ -2249,6 +2253,7 @@
 	release_region(dev->base_addr, PCNET32_TOTAL_SIZE);
 	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
 	free_netdev(dev);
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
     }
 }
diff -Nru a/drivers/net/tulip/21142.c b/drivers/net/tulip/21142.c
--- a/drivers/net/tulip/21142.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/21142.c	2004-11-24 15:49:50 -05:00
@@ -14,9 +14,9 @@
 
 */
 
-#include "tulip.h"
 #include <linux/pci.h>
 #include <linux/delay.h>
+#include "tulip.h"
 
 
 static u16 t21142_csr13[] = { 0x0001, 0x0009, 0x0009, 0x0000, 0x0001, };
diff -Nru a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
--- a/drivers/net/tulip/eeprom.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/eeprom.c	2004-11-24 15:49:50 -05:00
@@ -14,6 +14,7 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 #include <linux/init.h>
 #include <asm/unaligned.h>
diff -Nru a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
--- a/drivers/net/tulip/interrupt.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/interrupt.c	2004-11-24 15:49:50 -05:00
@@ -14,10 +14,10 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 #include <linux/config.h>
 #include <linux/etherdevice.h>
-#include <linux/pci.h>
 
 int tulip_rx_copybreak;
 unsigned int tulip_max_interrupt_work;
diff -Nru a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
--- a/drivers/net/tulip/media.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/media.c	2004-11-24 15:49:50 -05:00
@@ -18,6 +18,7 @@
 #include <linux/mii.h>
 #include <linux/init.h>
 #include <linux/delay.h>
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -Nru a/drivers/net/tulip/pnic.c b/drivers/net/tulip/pnic.c
--- a/drivers/net/tulip/pnic.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/pnic.c	2004-11-24 15:49:50 -05:00
@@ -15,6 +15,7 @@
 */
 
 #include <linux/kernel.h>
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -Nru a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
--- a/drivers/net/tulip/pnic2.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/pnic2.c	2004-11-24 15:49:50 -05:00
@@ -76,8 +76,8 @@
 
 
 
-#include "tulip.h"
 #include <linux/pci.h>
+#include "tulip.h"
 #include <linux/delay.h>
 
 
diff -Nru a/drivers/net/tulip/timer.c b/drivers/net/tulip/timer.c
--- a/drivers/net/tulip/timer.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/timer.c	2004-11-24 15:49:50 -05:00
@@ -14,6 +14,7 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -Nru a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
--- a/drivers/net/tulip/tulip.h	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/tulip.h	2004-11-24 15:49:50 -05:00
@@ -149,6 +149,9 @@
 	TxIntr = 0x01,
 };
 
+/* bit mask for CSR5 TX/RX process state */
+#define CSR5_TS	0x00700000
+#define CSR5_RS	0x000e0000
 
 enum tulip_mode_bits {
 	TxThreshold		= (1 << 22),
@@ -460,9 +463,19 @@
 	u32 csr6 = ioread32(ioaddr + CSR6);
 
 	if (csr6 & RxTx) {
+		unsigned i=1300/10;
 		iowrite32(csr6 & ~RxTx, ioaddr + CSR6);
 		barrier();
-		(void) ioread32(ioaddr + CSR6); /* mmio sync */
+		/* wait until in-flight frame completes.
+		 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
+		 * Typically expect this loop to end in < 50 us on 100BT.
+		 */
+		while (--i && (ioread32(ioaddr + CSR5) & (CSR5_TS|CSR5_RS)))
+			udelay(10);
+
+		if (!i)
+			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed\n",
+					tp->pdev->slot_name);
 	}
 }
 
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	2004-11-24 15:49:50 -05:00
+++ b/drivers/net/tulip/tulip_core.c	2004-11-24 15:49:50 -05:00
@@ -26,8 +26,8 @@
 
 
 #include <linux/module.h>
-#include "tulip.h"
 #include <linux/pci.h>
+#include "tulip.h"
 #include <linux/init.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
