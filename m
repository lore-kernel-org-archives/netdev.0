From: Alexey Charkov <alchark@gmail.com>
Subject: [PATCH] net: via-rhine: Convert #ifdef USE_MMIO to a runtime flag
Date: Sat,  3 May 2014 16:40:53 +0400
Message-ID: <1399120853-26967-1-git-send-email-alchark@gmail.com>
References: <20140502.155635.1691085402453175737.davem@davemloft.net>
Cc: Alexey Charkov <alchark@gmail.com>
To: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:60255 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbaECMm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 08:42:26 -0400
In-Reply-To: <20140502.155635.1691085402453175737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces another flag in 'quirks' to replace the preprocessor
define (USE_MMIO) used to indicate whether the device needs a
separate enable routine to operate in MMIO mode.

All of the currently known platform Rhine cores operate in MMIO
mode by default, and on PCI it is preferred over PIO for performance
reasons. However, a comment in code suggests that some (?) early
Rhine cores only work in PIO mode, so they should not be switched
to MMIO.

Enabling MMIO on PCI is still triggered by the same Kconfig option
to avoid breaking user configs needlessly, but this can be changed
going forward towards automatic runtime detection in case a list of
PIO-only Rhine revisions can be compiled.

This also fixes a couple of compiler warnings detected by Fengguang
Wu's test bot (!USE_MMIO case):

   drivers/net/ethernet/via/via-rhine.c: In function 'rhine_init_one_pci':
   drivers/net/ethernet/via/via-rhine.c:1108:1: warning: label 'err_out_unmap' defined but not used [-Wunused-label]
    err_out_unmap:
    ^
   drivers/net/ethernet/via/via-rhine.c:1022:6: warning: unused variable 'i' [-Wunused-variable]
     int i, rc;
         ^
   drivers/net/ethernet/via/via-rhine.c:916:22: warning: 'quirks' may be used uninitialized in this function [-Wmaybe-uninitialized]
     phy_id = rp->quirks & rqIntPHY ? 1 : 0;
                         ^
   drivers/net/ethernet/via/via-rhine.c:1026:6: note: 'quirks' was declared here
     u32 quirks;
         ^

Signed-off-by: Alexey Charkov <alchark@gmail.com>
---
 drivers/net/ethernet/via/via-rhine.c | 102 +++++++++++++++++++----------------
 1 file changed, 55 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 13cfcce..981be015 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -120,13 +120,6 @@ static const int multicast_filter_limit = 32;
 static const char version[] =
 	"v1.10-LK" DRV_VERSION " " DRV_RELDATE " Written by Donald Becker";
 
-/* This driver was written to use PCI memory space. Some early versions
-   of the Rhine may only work correctly with I/O space accesses. */
-#ifdef CONFIG_VIA_RHINE_MMIO
-#define USE_MMIO
-#else
-#endif
-
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
@@ -266,6 +259,10 @@ enum rhine_quirks {
 	rqRhineI	= 0x0100,	/* See comment below */
 	rqIntPHY	= 0x0200,	/* Integrated PHY */
 	rqMgmt		= 0x0400,	/* Management adapter */
+	rqNeedEnMMIO	= 0x0800,	/* Whether the core needs to be
+					 * switched from PIO mode to MMIO
+					 * (only applies to PCI)
+					 */
 };
 /*
  * rqRhineI: VT86C100A (aka Rhine-I) uses different bits to enable
@@ -353,13 +350,11 @@ enum bcr1_bits {
 	BCR1_MED1=0x80,		/* for VT6102 */
 };
 
-#ifdef USE_MMIO
 /* Registers we check that mmio and reg are the same. */
 static const int mmio_verify_registers[] = {
 	RxConfig, TxConfig, IntrEnable, ConfigA, ConfigB, ConfigC, ConfigD,
 	0
 };
-#endif
 
 /* Bits in the interrupt status/mask registers. */
 enum intr_status_bits {
@@ -664,20 +659,46 @@ static void rhine_chip_reset(struct net_device *dev)
 		   "failed" : "succeeded");
 }
 
-#ifdef USE_MMIO
 static void enable_mmio(long pioaddr, u32 quirks)
 {
 	int n;
-	if (quirks & rqRhineI) {
-		/* More recent docs say that this bit is reserved ... */
-		n = inb(pioaddr + ConfigA) | 0x20;
-		outb(n, pioaddr + ConfigA);
-	} else {
-		n = inb(pioaddr + ConfigD) | 0x80;
-		outb(n, pioaddr + ConfigD);
+
+	if (quirks & rqNeedEnMMIO) {
+		if (quirks & rqRhineI) {
+			/* More recent docs say that this bit is reserved */
+			n = inb(pioaddr + ConfigA) | 0x20;
+			outb(n, pioaddr + ConfigA);
+		} else {
+			n = inb(pioaddr + ConfigD) | 0x80;
+			outb(n, pioaddr + ConfigD);
+		}
 	}
 }
-#endif
+
+static inline int verify_mmio(struct device *hwdev,
+			      long pioaddr,
+			      void __iomem *ioaddr,
+			      u32 quirks)
+{
+	if (quirks & rqNeedEnMMIO) {
+		int i = 0;
+
+		/* Check that selected MMIO registers match the PIO ones */
+		while (mmio_verify_registers[i]) {
+			int reg = mmio_verify_registers[i++];
+			unsigned char a = inb(pioaddr+reg);
+			unsigned char b = readb(ioaddr+reg);
+
+			if (a != b) {
+				dev_err(hwdev,
+					"MMIO do not match PIO [%02x] (%02x != %02x)\n",
+					reg, a, b);
+				return -EIO;
+			}
+		}
+	}
+	return 0;
+}
 
 /*
  * Loads bytes 0x00-0x05, 0x6E-0x6F, 0x78-0x7B from EEPROM
@@ -697,14 +718,12 @@ static void rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 	if (i > 512)
 		pr_info("%4d cycles used @ %s:%d\n", i, __func__, __LINE__);
 
-#ifdef USE_MMIO
 	/*
 	 * Reloading from EEPROM overwrites ConfigA-D, so we must re-enable
 	 * MMIO. If reloading EEPROM was done first this could be avoided, but
 	 * it is not known if that still works with the "win98-reboot" problem.
 	 */
 	enable_mmio(pioaddr, rp->quirks);
-#endif
 
 	/* Turn off EEPROM-controlled wake-up (magic packet) */
 	if (rp->quirks & rqWOL)
@@ -1019,15 +1038,20 @@ static int rhine_init_one_pci(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
 	struct device *hwdev = &pdev->dev;
-	int i, rc;
+	int rc;
 	long pioaddr, memaddr;
 	void __iomem *ioaddr;
 	int io_size = pdev->revision < VTunknown0 ? 128 : 256;
-	u32 quirks;
-#ifdef USE_MMIO
-	int bar = 1;
+
+/* This driver was written to use PCI memory space. Some early versions
+ * of the Rhine may only work correctly with I/O space accesses.
+ * TODO: determine for which revisions this is true and assign the flag
+ *	 in code as opposed to this Kconfig option (???)
+ */
+#ifdef CONFIG_VIA_RHINE_MMIO
+	u32 quirks = rqNeedEnMMIO;
 #else
-	int bar = 0;
+	u32 quirks = 0;
 #endif
 
 /* when built into the kernel, we only print version if device is found */
@@ -1040,9 +1064,9 @@ static int rhine_init_one_pci(struct pci_dev *pdev,
 		goto err_out;
 
 	if (pdev->revision < VTunknown0) {
-		quirks = rqRhineI;
+		quirks |= rqRhineI;
 	} else if (pdev->revision >= VT6102) {
-		quirks = rqWOL | rqForceReset;
+		quirks |= rqWOL | rqForceReset;
 		if (pdev->revision < VT6105) {
 			quirks |= rqStatusWBRace;
 		} else {
@@ -1071,7 +1095,7 @@ static int rhine_init_one_pci(struct pci_dev *pdev,
 	if (rc)
 		goto err_out_pci_disable;
 
-	ioaddr = pci_iomap(pdev, bar, io_size);
+	ioaddr = pci_iomap(pdev, (quirks & rqNeedEnMMIO ? 1 : 0), io_size);
 	if (!ioaddr) {
 		rc = -EIO;
 		dev_err(hwdev,
@@ -1080,25 +1104,11 @@ static int rhine_init_one_pci(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-#ifdef USE_MMIO
 	enable_mmio(pioaddr, quirks);
 
-	/* Check that selected MMIO registers match the PIO ones */
-	i = 0;
-	while (mmio_verify_registers[i]) {
-		int reg = mmio_verify_registers[i++];
-		unsigned char a = inb(pioaddr+reg);
-		unsigned char b = readb(ioaddr+reg);
-
-		if (a != b) {
-			rc = -EIO;
-			dev_err(hwdev,
-				"MMIO do not match PIO [%02x] (%02x != %02x)\n",
-				reg, a, b);
-			goto err_out_unmap;
-		}
-	}
-#endif /* USE_MMIO */
+	rc = verify_mmio(hwdev, pioaddr, ioaddr, quirks);
+	if (rc)
+		goto err_out_unmap;
 
 	rc = rhine_init_one_common(&pdev->dev, quirks,
 				   pioaddr, ioaddr, pdev->irq);
@@ -2458,9 +2468,7 @@ static int rhine_resume(struct device *device)
 	if (!netif_running(dev))
 		return 0;
 
-#ifdef USE_MMIO
 	enable_mmio(rp->pioaddr, rp->quirks);
-#endif
 	rhine_power_init(dev);
 	free_tbufs(dev);
 	free_rbufs(dev);
-- 
1.9.1
