From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 08/15] via-rhine: MMIO: move support decision (compile-time-only to runtime).
Date: Mon, 31 Dec 2012 16:25:42 +0100
Message-ID: <1356967549-5056-9-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54076 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab2LaPen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:43 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Reduces ifdefs a bit in the process, too.

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   56 ++++++++++++++++++++-------------
 1 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index a16e227..a4b8d84 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -36,6 +36,7 @@
 #define DRV_RELDATE	"2010-10-09"
 
 #include <linux/types.h>
+#include <linux/cache.h> /* __read_mostly */
 
 /* A few user-configurable values.
    These may be modified when a driver module is loaded. */
@@ -119,7 +120,12 @@ static const char version[] =
 /* This driver was written to use PCI memory space. Some early versions
    of the Rhine may only work correctly with I/O space accesses. */
 #ifdef CONFIG_VIA_RHINE_MMIO
-#define USE_MMIO
+#define IMPL_MMIO
+/* Hmm, I don't know whether we actually want to offer this
+ * as a publicly visible module parameter, with the likely ensuing confusion
+ * (does/doesn't this module build variant have it, and what is the default?).
+ */
+static bool use_mmio __read_mostly = 1;
 #else
 #endif
 
@@ -137,6 +143,9 @@ MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for broken BIOSes)
 #define MCAM_SIZE	32
 #define VCAM_SIZE	32
 
+#define VIA_PCIBAR_IO 0
+#define VIA_PCIBAR_MMIO 1
+
 /*
 		Theory of Operation
 
@@ -638,7 +647,7 @@ static void rhine_chip_reset(struct net_device *dev)
 		   "failed" : "succeeded");
 }
 
-#ifdef USE_MMIO
+#ifdef IMPL_MMIO
 static void enable_mmio(long pioaddr, u32 quirks)
 {
 	int n;
@@ -696,13 +705,14 @@ static void rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 	if (i > 512)
 		pr_info("%4d cycles used @ %s:%d\n", i, __func__, __LINE__);
 
-#ifdef USE_MMIO
+#ifdef IMPL_MMIO
 	/*
 	 * Reloading from EEPROM overwrites ConfigA-D, so we must re-enable
 	 * MMIO. If reloading EEPROM was done first this could be avoided, but
 	 * it is not known if that still works with the "win98-reboot" problem.
 	 */
-	enable_mmio(pioaddr, rp->quirks);
+	if (use_mmio)
+		enable_mmio(pioaddr, rp->quirks);
 #endif
 
 	/* Turn off EEPROM-controlled wake-up (magic packet) */
@@ -890,14 +900,11 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u32 quirks;
 	long pioaddr;
 	long memaddr;
+	long log_ioaddr; /* (non-)MMIO switch helper */
 	void __iomem *ioaddr;
 	int io_size, phy_id;
 	const char *name;
-#ifdef USE_MMIO
-	int bar = 1;
-#else
-	int bar = 0;
-#endif
+	int bar = VIA_PCIBAR_IO;
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -972,6 +979,10 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto err_out_free_netdev;
 
+#ifdef IMPL_MMIO
+	if (use_mmio)
+		bar = VIA_PCIBAR_MMIO;
+#endif
 	ioaddr = pci_iomap(pdev, bar, io_size);
 	if (!ioaddr) {
 		rc = -EIO;
@@ -983,14 +994,18 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rp->base = ioaddr;
 
-#ifdef USE_MMIO
-	enable_mmio(rp->pioaddr, rp->quirks);
+	log_ioaddr = (long)ioaddr;
+#ifdef IMPL_MMIO
+	if (use_mmio) {
+		enable_mmio(rp->pioaddr, rp->quirks);
 
-	if (!mmio_verify_registers(pdev, pioaddr, ioaddr)) {
-		rc = -EIO;
-		goto err_out_unmap;
+		if (!mmio_verify_registers(pdev, pioaddr, ioaddr)) {
+			rc = -EIO;
+			goto err_out_unmap;
+		}
+		log_ioaddr = memaddr;
 	}
-#endif /* USE_MMIO */
+#endif /* IMPL_MMIO */
 
 	/* Get chip registers into a sane state */
 	rhine_power_init(dev);
@@ -1044,11 +1059,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev_info(dev, "VIA %s at 0x%lx, %pM, IRQ %d\n",
 		    name,
-#ifdef USE_MMIO
-		    memaddr,
-#else
-		    (long)ioaddr,
-#endif
+		    log_ioaddr,
 		    dev->dev_addr, pdev->irq);
 
 	pci_set_drvdata(pdev, dev);
@@ -2362,8 +2373,9 @@ static int rhine_resume(struct device *device)
 	 * into a helper to be commonly called by both places.
 	 */
 
-#ifdef USE_MMIO
-	enable_mmio(rp->pioaddr, rp->quirks);
+#ifdef IMPL_MMIO
+	if (use_mmio)
+		enable_mmio(rp->pioaddr, rp->quirks);
 #endif
 	/*
 	 * FIXME: some power calls here are being done
-- 
1.7.2.5
