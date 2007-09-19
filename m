From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'ssb-drivers' branch of wireless-2.6
Date: Wed, 19 Sep 2007 16:44:28 -0400
Message-ID: <20070919204428.GE5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, gregkh@suse.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-usb-users@lists.sourceforge.net, zambrano@broadcom.com,
	mb@bu3sch.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4839 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbXISVLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 17:11:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff, Greg, Gary, and Dave,

These patches build upon the SSB bus support added to net-2.6.24 to
support the b43 wireless driver.  Since Dave has that support in his
tree, I'm asking him to merge these patches as well.

The first patch changes b44 from being a PCI (i.e. SSB-in-drag)
device to being a native SSB device.  This has little effect one
way or the other for laptop/desktop/server machines.  But, some
embedded devices have b44 hardware but no PCI bus (i.e. just SSB).
This patch enables the use of the b44 driver on that hardware.

The second patch adds a driver for a USB OHCI device which lives on
the SSB bus.  Again, this is found on a number of SoC devices used
especially in wireless routers and APs.

Thanks for reviewing/ACKing/merging!

John

---

The patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/ssb-drivers/0001-b44-port-to-native-ssb-support.patch
	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/ssb-drivers/0002-usb-ssb-hosted-OHCI-driver.patch

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git ssb-drivers

Michael Buesch (2):
      b44: port to native ssb support
      usb: ssb-hosted OHCI driver

 drivers/net/Kconfig         |   28 ++-
 drivers/net/b44.c           |  743 ++++++++++++++++++++----------------------
 drivers/net/b44.h           |   81 +-----
 drivers/usb/host/Kconfig    |   13 +
 drivers/usb/host/ohci-hcd.c |   21 ++-
 drivers/usb/host/ohci-ssb.c |  254 +++++++++++++++
 6 files changed, 672 insertions(+), 468 deletions(-)
 create mode 100644 drivers/usb/host/ohci-ssb.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5b9e17b..6051fe6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1453,18 +1453,38 @@ config APRICOT
 	  called apricot.
 
 config B44
-	tristate "Broadcom 4400 ethernet support"
-	depends on NET_PCI && PCI
+	tristate "Broadcom 440x/47xx ethernet support"
+	depends on SSB_POSSIBLE
+	select SSB
 	select MII
 	help
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
+	  If you have a network (Ethernet) controller of this type, say Y
+	  or M and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called b44.
 
+# Auto-select SSB PCI-HOST support, if possible
+config B44_PCI_AUTOSELECT
+	bool
+	depends on B44 && SSB_PCIHOST_POSSIBLE
+	select SSB_PCIHOST
+	default y
+
+# Auto-select SSB PCICORE driver, if possible
+config B44_PCICORE_AUTOSELECT
+	bool
+	depends on B44 && SSB_DRIVER_PCICORE_POSSIBLE
+	select SSB_DRIVER_PCICORE
+	default y
+
+config B44_PCI
+	bool
+	depends on B44_PCI_AUTOSELECT && B44_PCICORE_AUTOSELECT
+	default y
+
 config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on NET_PCI && PCI
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 0795df2..98ef267 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1,8 +1,11 @@
-/* b44.c: Broadcom 4400 device driver.
+/* b44.c: Broadcom 44xx/47xx Fast Ethernet device driver.
  *
  * Copyright (C) 2002 David S. Miller (davem@redhat.com)
- * Fixed by Pekka Pietikainen (pp@ee.oulu.fi)
+ * Copyright (C) 2004 Pekka Pietikainen (pp@ee.oulu.fi)
+ * Copyright (C) 2004 Florian Schirmer (jolt@tuxbox.org)
+ * Copyright (C) 2006 Felix Fietkau (nbd@openwrt.org)
  * Copyright (C) 2006 Broadcom Corporation.
+ * Copyright (C) 2007 Michael Buesch <mb@bu3sch.de>
  *
  * Distribute under GPL.
  */
@@ -21,17 +24,18 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
+#include <linux/ssb/ssb.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 
+
 #include "b44.h"
 
 #define DRV_MODULE_NAME		"b44"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.01"
-#define DRV_MODULE_RELDATE	"Jun 16, 2006"
+#define DRV_MODULE_VERSION	"2.0"
 
 #define B44_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
@@ -85,10 +89,10 @@
 #define B44_ETHIPV4UDP_HLEN	42
 
 static char version[] __devinitdata =
-	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION "\n";
 
-MODULE_AUTHOR("Florian Schirmer, Pekka Pietikainen, David S. Miller");
-MODULE_DESCRIPTION("Broadcom 4400 10/100 PCI ethernet driver");
+MODULE_AUTHOR("Felix Fietkau, Florian Schirmer, Pekka Pietikainen, David S. Miller");
+MODULE_DESCRIPTION("Broadcom 44xx/47xx 10/100 PCI ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
@@ -96,18 +100,28 @@ static int b44_debug = -1;	/* -1 == use B44_DEF_MSG_ENABLE as value */
 module_param(b44_debug, int, 0);
 MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable value");
 
-static struct pci_device_id b44_pci_tbl[] = {
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B0,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B1,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ }	/* terminate list with empty entry */
-};
 
+#ifdef CONFIG_B44_PCI
+static const struct pci_device_id b44_pci_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B0) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B1) },
+	{ 0 } /* terminate list with empty entry */
+};
 MODULE_DEVICE_TABLE(pci, b44_pci_tbl);
 
+static struct pci_driver b44_pci_driver = {
+	.name		= DRV_MODULE_NAME,
+	.id_table	= b44_pci_tbl,
+};
+#endif /* CONFIG_B44_PCI */
+
+static const struct ssb_device_id b44_ssb_tbl[] = {
+	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_ETHERNET, SSB_ANY_REV),
+	SSB_DEVTABLE_END
+};
+MODULE_DEVICE_TABLE(ssb, b44_ssb_tbl);
+
 static void b44_halt(struct b44 *);
 static void b44_init_rings(struct b44 *);
 
@@ -119,6 +133,7 @@ static void b44_init_hw(struct b44 *, int);
 
 static int dma_desc_align_mask;
 static int dma_desc_sync_size;
+static int instance;
 
 static const char b44_gstrings[][ETH_GSTRING_LEN] = {
 #define _B44(x...)	# x,
@@ -126,35 +141,35 @@ B44_STAT_REG_DECLARE
 #undef _B44
 };
 
-static inline void b44_sync_dma_desc_for_device(struct pci_dev *pdev,
-                                                dma_addr_t dma_base,
-                                                unsigned long offset,
-                                                enum dma_data_direction dir)
+static inline void b44_sync_dma_desc_for_device(struct ssb_device *sdev,
+						dma_addr_t dma_base,
+						unsigned long offset,
+						enum dma_data_direction dir)
 {
-	dma_sync_single_range_for_device(&pdev->dev, dma_base,
-	                                 offset & dma_desc_align_mask,
-	                                 dma_desc_sync_size, dir);
+	dma_sync_single_range_for_device(sdev->dev, dma_base,
+					 offset & dma_desc_align_mask,
+					 dma_desc_sync_size, dir);
 }
 
-static inline void b44_sync_dma_desc_for_cpu(struct pci_dev *pdev,
-                                             dma_addr_t dma_base,
-                                             unsigned long offset,
-                                             enum dma_data_direction dir)
+static inline void b44_sync_dma_desc_for_cpu(struct ssb_device *sdev,
+					     dma_addr_t dma_base,
+					     unsigned long offset,
+					     enum dma_data_direction dir)
 {
-	dma_sync_single_range_for_cpu(&pdev->dev, dma_base,
-	                              offset & dma_desc_align_mask,
-	                              dma_desc_sync_size, dir);
+	dma_sync_single_range_for_cpu(sdev->dev, dma_base,
+				      offset & dma_desc_align_mask,
+				      dma_desc_sync_size, dir);
 }
 
 static inline unsigned long br32(const struct b44 *bp, unsigned long reg)
 {
-	return readl(bp->regs + reg);
+	return ssb_read32(bp->sdev, reg);
 }
 
 static inline void bw32(const struct b44 *bp,
 			unsigned long reg, unsigned long val)
 {
-	writel(val, bp->regs + reg);
+	ssb_write32(bp->sdev, reg, val);
 }
 
 static int b44_wait_bit(struct b44 *bp, unsigned long reg,
@@ -182,117 +197,29 @@ static int b44_wait_bit(struct b44 *bp, unsigned long reg,
 	return 0;
 }
 
-/* Sonics SiliconBackplane support routines.  ROFL, you should see all the
- * buzz words used on this company's website :-)
- *
- * All of these routines must be invoked with bp->lock held and
- * interrupts disabled.
- */
-
-#define SB_PCI_DMA             0x40000000      /* Client Mode PCI memory access space (1 GB) */
-#define BCM4400_PCI_CORE_ADDR  0x18002000      /* Address of PCI core on BCM4400 cards */
-
-static u32 ssb_get_core_rev(struct b44 *bp)
-{
-	return (br32(bp, B44_SBIDHIGH) & SBIDHIGH_RC_MASK);
-}
-
-static u32 ssb_pci_setup(struct b44 *bp, u32 cores)
-{
-	u32 bar_orig, pci_rev, val;
-
-	pci_read_config_dword(bp->pdev, SSB_BAR0_WIN, &bar_orig);
-	pci_write_config_dword(bp->pdev, SSB_BAR0_WIN, BCM4400_PCI_CORE_ADDR);
-	pci_rev = ssb_get_core_rev(bp);
-
-	val = br32(bp, B44_SBINTVEC);
-	val |= cores;
-	bw32(bp, B44_SBINTVEC, val);
-
-	val = br32(bp, SSB_PCI_TRANS_2);
-	val |= SSB_PCI_PREF | SSB_PCI_BURST;
-	bw32(bp, SSB_PCI_TRANS_2, val);
-
-	pci_write_config_dword(bp->pdev, SSB_BAR0_WIN, bar_orig);
-
-	return pci_rev;
-}
-
-static void ssb_core_disable(struct b44 *bp)
-{
-	if (br32(bp, B44_SBTMSLOW) & SBTMSLOW_RESET)
-		return;
-
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_REJECT | SBTMSLOW_CLOCK));
-	b44_wait_bit(bp, B44_SBTMSLOW, SBTMSLOW_REJECT, 100000, 0);
-	b44_wait_bit(bp, B44_SBTMSHIGH, SBTMSHIGH_BUSY, 100000, 1);
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_FGC | SBTMSLOW_CLOCK |
-			    SBTMSLOW_REJECT | SBTMSLOW_RESET));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_REJECT | SBTMSLOW_RESET));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-}
-
-static void ssb_core_reset(struct b44 *bp)
+static inline void __b44_cam_read(struct b44 *bp, unsigned char *data, int index)
 {
 	u32 val;
 
-	ssb_core_disable(bp);
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_RESET | SBTMSLOW_CLOCK | SBTMSLOW_FGC));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-
-	/* Clear SERR if set, this is a hw bug workaround.  */
-	if (br32(bp, B44_SBTMSHIGH) & SBTMSHIGH_SERR)
-		bw32(bp, B44_SBTMSHIGH, 0);
-
-	val = br32(bp, B44_SBIMSTATE);
-	if (val & (SBIMSTATE_IBE | SBIMSTATE_TO))
-		bw32(bp, B44_SBIMSTATE, val & ~(SBIMSTATE_IBE | SBIMSTATE_TO));
-
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_CLOCK | SBTMSLOW_FGC));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_CLOCK));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-}
+	bw32(bp, B44_CAM_CTRL, (CAM_CTRL_READ |
+			    (index << CAM_CTRL_INDEX_SHIFT)));
 
-static int ssb_core_unit(struct b44 *bp)
-{
-#if 0
-	u32 val = br32(bp, B44_SBADMATCH0);
-	u32 base;
+	b44_wait_bit(bp, B44_CAM_CTRL, CAM_CTRL_BUSY, 100, 1);
 
-	type = val & SBADMATCH0_TYPE_MASK;
-	switch (type) {
-	case 0:
-		base = val & SBADMATCH0_BS0_MASK;
-		break;
+	val = br32(bp, B44_CAM_DATA_LO);
 
-	case 1:
-		base = val & SBADMATCH0_BS1_MASK;
-		break;
+	data[2] = (val >> 24) & 0xFF;
+	data[3] = (val >> 16) & 0xFF;
+	data[4] = (val >> 8) & 0xFF;
+	data[5] = (val >> 0) & 0xFF;
 
-	case 2:
-	default:
-		base = val & SBADMATCH0_BS2_MASK;
-		break;
-	};
-#endif
-	return 0;
-}
+	val = br32(bp, B44_CAM_DATA_HI);
 
-static int ssb_is_core_up(struct b44 *bp)
-{
-	return ((br32(bp, B44_SBTMSLOW) & (SBTMSLOW_RESET | SBTMSLOW_REJECT | SBTMSLOW_CLOCK))
-		== SBTMSLOW_CLOCK);
+	data[0] = (val >> 8) & 0xFF;
+	data[1] = (val >> 0) & 0xFF;
 }
 
-static void __b44_cam_write(struct b44 *bp, unsigned char *data, int index)
+static inline void __b44_cam_write(struct b44 *bp, unsigned char *data, int index)
 {
 	u32 val;
 
@@ -328,14 +255,14 @@ static void b44_enable_ints(struct b44 *bp)
 	bw32(bp, B44_IMASK, bp->imask);
 }
 
-static int b44_readphy(struct b44 *bp, int reg, u32 *val)
+static int __b44_readphy(struct b44 *bp, int phy_addr, int reg, u32 *val)
 {
 	int err;
 
 	bw32(bp, B44_EMAC_ISTAT, EMAC_INT_MII);
 	bw32(bp, B44_MDIO_DATA, (MDIO_DATA_SB_START |
 			     (MDIO_OP_READ << MDIO_DATA_OP_SHIFT) |
-			     (bp->phy_addr << MDIO_DATA_PMD_SHIFT) |
+			     (phy_addr << MDIO_DATA_PMD_SHIFT) |
 			     (reg << MDIO_DATA_RA_SHIFT) |
 			     (MDIO_TA_VALID << MDIO_DATA_TA_SHIFT)));
 	err = b44_wait_bit(bp, B44_EMAC_ISTAT, EMAC_INT_MII, 100, 0);
@@ -344,29 +271,40 @@ static int b44_readphy(struct b44 *bp, int reg, u32 *val)
 	return err;
 }
 
-static int b44_writephy(struct b44 *bp, int reg, u32 val)
+static int __b44_writephy(struct b44 *bp, int phy_addr, int reg, u32 val)
 {
 	bw32(bp, B44_EMAC_ISTAT, EMAC_INT_MII);
 	bw32(bp, B44_MDIO_DATA, (MDIO_DATA_SB_START |
 			     (MDIO_OP_WRITE << MDIO_DATA_OP_SHIFT) |
-			     (bp->phy_addr << MDIO_DATA_PMD_SHIFT) |
+			     (phy_addr << MDIO_DATA_PMD_SHIFT) |
 			     (reg << MDIO_DATA_RA_SHIFT) |
 			     (MDIO_TA_VALID << MDIO_DATA_TA_SHIFT) |
 			     (val & MDIO_DATA_DATA)));
 	return b44_wait_bit(bp, B44_EMAC_ISTAT, EMAC_INT_MII, 100, 0);
 }
 
+static inline int b44_readphy(struct b44 *bp, int reg, u32 *val)
+{
+	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+		return 0;
+
+	return __b44_readphy(bp, bp->phy_addr, reg, val);
+}
+
+static inline int b44_writephy(struct b44 *bp, int reg, u32 val)
+{
+	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+		return 0;
+
+	return __b44_writephy(bp, bp->phy_addr, reg, val);
+}
+
 /* miilib interface */
-/* FIXME FIXME: phy_id is ignored, bp->phy_addr use is unconditional
- * due to code existing before miilib use was added to this driver.
- * Someone should remove this artificial driver limitation in
- * b44_{read,write}phy.  bp->phy_addr itself is fine (and needed).
- */
 static int b44_mii_read(struct net_device *dev, int phy_id, int location)
 {
 	u32 val;
 	struct b44 *bp = netdev_priv(dev);
-	int rc = b44_readphy(bp, location, &val);
+	int rc = __b44_readphy(bp, phy_id, location, &val);
 	if (rc)
 		return 0xffffffff;
 	return val;
@@ -376,7 +314,7 @@ static void b44_mii_write(struct net_device *dev, int phy_id, int location,
 			 int val)
 {
 	struct b44 *bp = netdev_priv(dev);
-	b44_writephy(bp, location, val);
+	__b44_writephy(bp, phy_id, location, val);
 }
 
 static int b44_phy_reset(struct b44 *bp)
@@ -384,6 +322,8 @@ static int b44_phy_reset(struct b44 *bp)
 	u32 val;
 	int err;
 
+	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+		return 0;
 	err = b44_writephy(bp, MII_BMCR, BMCR_RESET);
 	if (err)
 		return err;
@@ -442,11 +382,52 @@ static void b44_set_flow_ctrl(struct b44 *bp, u32 local, u32 remote)
 	__b44_set_flow_ctrl(bp, pause_enab);
 }
 
+#ifdef SSB_DRIVER_MIPS
+extern char *nvram_get(char *name);
+static void b44_wap54g10_workaround(struct b44 *bp)
+{
+	const char *str;
+	u32 val;
+	int err;
+
+	/*
+	 * workaround for bad hardware design in Linksys WAP54G v1.0
+	 * see https://dev.openwrt.org/ticket/146
+	 * check and reset bit "isolate"
+	 */
+	str = nvram_get("boardnum");
+	if (!str)
+		return;
+	if (simple_strtoul(str, NULL, 0) == 2) {
+		err = __b44_readphy(bp, 0, MII_BMCR, &val);
+		if (err)
+			goto error;
+		if (!(val & BMCR_ISOLATE))
+			return;
+		val &= ~BMCR_ISOLATE;
+		err = __b44_writephy(bp, 0, MII_BMCR, val);
+		if (err)
+			goto error;
+	}
+	return;
+error:
+	printk(KERN_WARNING PFX "PHY: cannot reset MII transceiver isolate bit.\n");
+}
+#else
+static inline void b44_wap54g10_workaround(struct b44 *bp)
+{
+}
+#endif
+
 static int b44_setup_phy(struct b44 *bp)
 {
 	u32 val;
 	int err;
 
+	b44_wap54g10_workaround(bp);
+
+	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+		return 0;
 	if ((err = b44_readphy(bp, B44_MII_ALEDCTRL, &val)) != 0)
 		goto out;
 	if ((err = b44_writephy(bp, B44_MII_ALEDCTRL,
@@ -542,6 +523,19 @@ static void b44_check_phy(struct b44 *bp)
 {
 	u32 bmsr, aux;
 
+	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY) {
+		bp->flags |= B44_FLAG_100_BASE_T;
+		bp->flags |= B44_FLAG_FULL_DUPLEX;
+		if (!netif_carrier_ok(bp->dev)) {
+			u32 val = br32(bp, B44_TX_CTRL);
+			val |= TX_CTRL_DUPLEX;
+			bw32(bp, B44_TX_CTRL, val);
+			netif_carrier_on(bp->dev);
+			b44_link_report(bp);
+		}
+		return;
+	}
+
 	if (!b44_readphy(bp, MII_BMSR, &bmsr) &&
 	    !b44_readphy(bp, B44_MII_AUXCTRL, &aux) &&
 	    (bmsr != 0xffff)) {
@@ -617,10 +611,10 @@ static void b44_tx(struct b44 *bp)
 
 		BUG_ON(skb == NULL);
 
-		pci_unmap_single(bp->pdev,
-				 pci_unmap_addr(rp, mapping),
+		dma_unmap_single(bp->sdev->dev,
+				 rp->mapping,
 				 skb->len,
-				 PCI_DMA_TODEVICE);
+				 DMA_TO_DEVICE);
 		rp->skb = NULL;
 		dev_kfree_skb_irq(skb);
 	}
@@ -657,9 +651,9 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	mapping = pci_map_single(bp->pdev, skb->data,
+	mapping = dma_map_single(bp->sdev->dev, skb->data,
 				 RX_PKT_BUF_SZ,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 
 	/* Hardware bug work-around, the chip is unable to do PCI DMA
 	   to/from anything above 1GB :-( */
@@ -667,18 +661,19 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 		mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 		/* Sigh... */
 		if (!dma_mapping_error(mapping))
-			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+			dma_unmap_single(bp->sdev->dev, mapping,
+					RX_PKT_BUF_SZ, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
 		skb = __netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ, GFP_ATOMIC|GFP_DMA);
 		if (skb == NULL)
 			return -ENOMEM;
-		mapping = pci_map_single(bp->pdev, skb->data,
+		mapping = dma_map_single(bp->sdev->dev, skb->data,
 					 RX_PKT_BUF_SZ,
-					 PCI_DMA_FROMDEVICE);
+					 DMA_FROM_DEVICE);
 		if (dma_mapping_error(mapping) ||
 			mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
-				pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+				dma_unmap_single(bp->sdev->dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
@@ -691,7 +686,7 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	rh->flags = 0;
 
 	map->skb = skb;
-	pci_unmap_addr_set(map, mapping, mapping);
+	map->mapping = mapping;
 
 	if (src_map != NULL)
 		src_map->skb = NULL;
@@ -705,9 +700,9 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	dp->addr = cpu_to_le32((u32) mapping + RX_PKT_OFFSET + bp->dma_offset);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		b44_sync_dma_desc_for_device(bp->pdev, bp->rx_ring_dma,
-		                             dest_idx * sizeof(dp),
-		                             DMA_BIDIRECTIONAL);
+		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
+			                    dest_idx * sizeof(dp),
+			                    DMA_BIDIRECTIONAL);
 
 	return RX_PKT_BUF_SZ;
 }
@@ -730,13 +725,12 @@ static void b44_recycle_rx(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	rh = (struct rx_header *) src_map->skb->data;
 	rh->len = 0;
 	rh->flags = 0;
-	pci_unmap_addr_set(dest_map, mapping,
-			   pci_unmap_addr(src_map, mapping));
+	dest_map->mapping = src_map->mapping;
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		b44_sync_dma_desc_for_cpu(bp->pdev, bp->rx_ring_dma,
-		                          src_idx * sizeof(src_desc),
-		                          DMA_BIDIRECTIONAL);
+		b44_sync_dma_desc_for_cpu(bp->sdev, bp->rx_ring_dma,
+			                 src_idx * sizeof(src_desc),
+			                 DMA_BIDIRECTIONAL);
 
 	ctrl = src_desc->ctrl;
 	if (dest_idx == (B44_RX_RING_SIZE - 1))
@@ -750,13 +744,13 @@ static void b44_recycle_rx(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	src_map->skb = NULL;
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		b44_sync_dma_desc_for_device(bp->pdev, bp->rx_ring_dma,
-		                             dest_idx * sizeof(dest_desc),
-		                             DMA_BIDIRECTIONAL);
+		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
+					     dest_idx * sizeof(dest_desc),
+					     DMA_BIDIRECTIONAL);
 
-	pci_dma_sync_single_for_device(bp->pdev, le32_to_cpu(src_desc->addr),
-				       RX_PKT_BUF_SZ,
-				       PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_device(bp->sdev->dev, le32_to_cpu(src_desc->addr),
+				   RX_PKT_BUF_SZ,
+				   DMA_FROM_DEVICE);
 }
 
 static int b44_rx(struct b44 *bp, int budget)
@@ -772,13 +766,13 @@ static int b44_rx(struct b44 *bp, int budget)
 	while (cons != prod && budget > 0) {
 		struct ring_info *rp = &bp->rx_buffers[cons];
 		struct sk_buff *skb = rp->skb;
-		dma_addr_t map = pci_unmap_addr(rp, mapping);
+		dma_addr_t map = rp->mapping;
 		struct rx_header *rh;
 		u16 len;
 
-		pci_dma_sync_single_for_cpu(bp->pdev, map,
+		dma_sync_single_for_cpu(bp->sdev->dev, map,
 					    RX_PKT_BUF_SZ,
-					    PCI_DMA_FROMDEVICE);
+					    DMA_FROM_DEVICE);
 		rh = (struct rx_header *) skb->data;
 		len = le16_to_cpu(rh->len);
 		if ((len > (RX_PKT_BUF_SZ - RX_PKT_OFFSET)) ||
@@ -810,8 +804,8 @@ static int b44_rx(struct b44 *bp, int budget)
 			skb_size = b44_alloc_rx_skb(bp, cons, bp->rx_prod);
 			if (skb_size < 0)
 				goto drop_it;
-			pci_unmap_single(bp->pdev, map,
-					 skb_size, PCI_DMA_FROMDEVICE);
+			dma_unmap_single(bp->sdev->dev, map,
+					 skb_size, DMA_FROM_DEVICE);
 			/* Leave out rx_header */
                 	skb_put(skb, len + RX_PKT_OFFSET);
             	        skb_pull(skb, RX_PKT_OFFSET);
@@ -982,24 +976,25 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto err_out;
 	}
 
-	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	mapping = dma_map_single(bp->sdev->dev, skb->data, len, DMA_TO_DEVICE);
 	if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 		struct sk_buff *bounce_skb;
 
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
 		if (!dma_mapping_error(mapping))
-			pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
+			dma_unmap_single(bp->sdev->dev, mapping, len,
+					DMA_TO_DEVICE);
 
 		bounce_skb = __dev_alloc_skb(len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
-		mapping = pci_map_single(bp->pdev, bounce_skb->data,
-					 len, PCI_DMA_TODEVICE);
+		mapping = dma_map_single(bp->sdev->dev, bounce_skb->data,
+					 len, DMA_TO_DEVICE);
 		if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
-				pci_unmap_single(bp->pdev, mapping,
-						 len, PCI_DMA_TODEVICE);
+				dma_unmap_single(bp->sdev->dev, mapping,
+					 len, DMA_TO_DEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
 		}
@@ -1011,7 +1006,7 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	entry = bp->tx_prod;
 	bp->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&bp->tx_buffers[entry], mapping, mapping);
+	bp->tx_buffers[entry].mapping = mapping;
 
 	ctrl  = (len & DESC_CTRL_LEN);
 	ctrl |= DESC_CTRL_IOC | DESC_CTRL_SOF | DESC_CTRL_EOF;
@@ -1022,9 +1017,9 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bp->tx_ring[entry].addr = cpu_to_le32((u32) mapping+bp->dma_offset);
 
 	if (bp->flags & B44_FLAG_TX_RING_HACK)
-		b44_sync_dma_desc_for_device(bp->pdev, bp->tx_ring_dma,
-		                             entry * sizeof(bp->tx_ring[0]),
-		                             DMA_TO_DEVICE);
+		b44_sync_dma_desc_for_device(bp->sdev, bp->tx_ring_dma,
+			                    entry * sizeof(bp->tx_ring[0]),
+			                    DMA_TO_DEVICE);
 
 	entry = NEXT_TX(entry);
 
@@ -1097,10 +1092,8 @@ static void b44_free_rings(struct b44 *bp)
 
 		if (rp->skb == NULL)
 			continue;
-		pci_unmap_single(bp->pdev,
-				 pci_unmap_addr(rp, mapping),
-				 RX_PKT_BUF_SZ,
-				 PCI_DMA_FROMDEVICE);
+		dma_unmap_single(bp->sdev->dev, rp->mapping, RX_PKT_BUF_SZ,
+					DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
 	}
@@ -1111,10 +1104,8 @@ static void b44_free_rings(struct b44 *bp)
 
 		if (rp->skb == NULL)
 			continue;
-		pci_unmap_single(bp->pdev,
-				 pci_unmap_addr(rp, mapping),
-				 rp->skb->len,
-				 PCI_DMA_TODEVICE);
+		dma_unmap_single(bp->sdev->dev, rp->mapping, rp->skb->len,
+					DMA_TO_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
 	}
@@ -1136,14 +1127,14 @@ static void b44_init_rings(struct b44 *bp)
 	memset(bp->tx_ring, 0, B44_TX_RING_BYTES);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		dma_sync_single_for_device(&bp->pdev->dev, bp->rx_ring_dma,
-		                           DMA_TABLE_BYTES,
-		                           PCI_DMA_BIDIRECTIONAL);
+		dma_sync_single_for_device(bp->sdev->dev, bp->rx_ring_dma,
+			                  DMA_TABLE_BYTES,
+			                  DMA_BIDIRECTIONAL);
 
 	if (bp->flags & B44_FLAG_TX_RING_HACK)
-		dma_sync_single_for_device(&bp->pdev->dev, bp->tx_ring_dma,
-		                           DMA_TABLE_BYTES,
-		                           PCI_DMA_TODEVICE);
+		dma_sync_single_for_device(bp->sdev->dev, bp->tx_ring_dma,
+			                  DMA_TABLE_BYTES,
+			                  DMA_TO_DEVICE);
 
 	for (i = 0; i < bp->rx_pending; i++) {
 		if (b44_alloc_rx_skb(bp, -1, i) < 0)
@@ -1163,24 +1154,24 @@ static void b44_free_consistent(struct b44 *bp)
 	bp->tx_buffers = NULL;
 	if (bp->rx_ring) {
 		if (bp->flags & B44_FLAG_RX_RING_HACK) {
-			dma_unmap_single(&bp->pdev->dev, bp->rx_ring_dma,
-				         DMA_TABLE_BYTES,
-				         DMA_BIDIRECTIONAL);
+			dma_unmap_single(bp->sdev->dev, bp->rx_ring_dma,
+					DMA_TABLE_BYTES,
+					DMA_BIDIRECTIONAL);
 			kfree(bp->rx_ring);
 		} else
-			pci_free_consistent(bp->pdev, DMA_TABLE_BYTES,
+			dma_free_coherent(bp->sdev->dev, DMA_TABLE_BYTES,
 					    bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 		bp->flags &= ~B44_FLAG_RX_RING_HACK;
 	}
 	if (bp->tx_ring) {
 		if (bp->flags & B44_FLAG_TX_RING_HACK) {
-			dma_unmap_single(&bp->pdev->dev, bp->tx_ring_dma,
-				         DMA_TABLE_BYTES,
-				         DMA_TO_DEVICE);
+			dma_unmap_single(bp->sdev->dev, bp->tx_ring_dma,
+					DMA_TABLE_BYTES,
+					DMA_TO_DEVICE);
 			kfree(bp->tx_ring);
 		} else
-			pci_free_consistent(bp->pdev, DMA_TABLE_BYTES,
+			dma_free_coherent(bp->sdev->dev, DMA_TABLE_BYTES,
 					    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring = NULL;
 		bp->flags &= ~B44_FLAG_TX_RING_HACK;
@@ -1191,22 +1182,22 @@ static void b44_free_consistent(struct b44 *bp)
  * Must not be invoked with interrupt sources disabled and
  * the hardware shutdown down.  Can sleep.
  */
-static int b44_alloc_consistent(struct b44 *bp)
+static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 {
 	int size;
 
 	size  = B44_RX_RING_SIZE * sizeof(struct ring_info);
-	bp->rx_buffers = kzalloc(size, GFP_KERNEL);
+	bp->rx_buffers = kzalloc(size, gfp);
 	if (!bp->rx_buffers)
 		goto out_err;
 
 	size = B44_TX_RING_SIZE * sizeof(struct ring_info);
-	bp->tx_buffers = kzalloc(size, GFP_KERNEL);
+	bp->tx_buffers = kzalloc(size, gfp);
 	if (!bp->tx_buffers)
 		goto out_err;
 
 	size = DMA_TABLE_BYTES;
-	bp->rx_ring = pci_alloc_consistent(bp->pdev, size, &bp->rx_ring_dma);
+	bp->rx_ring = dma_alloc_coherent(bp->sdev->dev, size, &bp->rx_ring_dma, gfp);
 	if (!bp->rx_ring) {
 		/* Allocation may have failed due to pci_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1214,13 +1205,13 @@ static int b44_alloc_consistent(struct b44 *bp)
 		struct dma_desc *rx_ring;
 		dma_addr_t rx_ring_dma;
 
-		rx_ring = kzalloc(size, GFP_KERNEL);
+		rx_ring = kzalloc(size, gfp);
 		if (!rx_ring)
 			goto out_err;
 
-		rx_ring_dma = dma_map_single(&bp->pdev->dev, rx_ring,
-		                             DMA_TABLE_BYTES,
-		                             DMA_BIDIRECTIONAL);
+		rx_ring_dma = dma_map_single(bp->sdev->dev, rx_ring,
+			                    DMA_TABLE_BYTES,
+			                    DMA_BIDIRECTIONAL);
 
 		if (dma_mapping_error(rx_ring_dma) ||
 			rx_ring_dma + size > DMA_30BIT_MASK) {
@@ -1233,21 +1224,21 @@ static int b44_alloc_consistent(struct b44 *bp)
 		bp->flags |= B44_FLAG_RX_RING_HACK;
 	}
 
-	bp->tx_ring = pci_alloc_consistent(bp->pdev, size, &bp->tx_ring_dma);
+	bp->tx_ring = dma_alloc_coherent(bp->sdev->dev, size, &bp->tx_ring_dma, gfp);
 	if (!bp->tx_ring) {
-		/* Allocation may have failed due to pci_alloc_consistent
+		/* Allocation may have failed due to dma_alloc_coherent
 		   insisting on use of GFP_DMA, which is more restrictive
 		   than necessary...  */
 		struct dma_desc *tx_ring;
 		dma_addr_t tx_ring_dma;
 
-		tx_ring = kzalloc(size, GFP_KERNEL);
+		tx_ring = kzalloc(size, gfp);
 		if (!tx_ring)
 			goto out_err;
 
-		tx_ring_dma = dma_map_single(&bp->pdev->dev, tx_ring,
-		                             DMA_TABLE_BYTES,
-		                             DMA_TO_DEVICE);
+		tx_ring_dma = dma_map_single(bp->sdev->dev, tx_ring,
+			                    DMA_TABLE_BYTES,
+			                    DMA_TO_DEVICE);
 
 		if (dma_mapping_error(tx_ring_dma) ||
 			tx_ring_dma + size > DMA_30BIT_MASK) {
@@ -1282,7 +1273,9 @@ static void b44_clear_stats(struct b44 *bp)
 /* bp->lock is held. */
 static void b44_chip_reset(struct b44 *bp)
 {
-	if (ssb_is_core_up(bp)) {
+	struct ssb_device *sdev = bp->sdev;
+
+	if (ssb_device_is_enabled(bp->sdev)) {
 		bw32(bp, B44_RCV_LAZY, 0);
 		bw32(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE);
 		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 200, 1);
@@ -1294,19 +1287,25 @@ static void b44_chip_reset(struct b44 *bp)
 		}
 		bw32(bp, B44_DMARX_CTRL, 0);
 		bp->rx_prod = bp->rx_cons = 0;
-	} else {
-		ssb_pci_setup(bp, (bp->core_unit == 0 ?
-				   SBINTVEC_ENET0 :
-				   SBINTVEC_ENET1));
-	}
-
-	ssb_core_reset(bp);
+	} else
+		ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
 
+	ssb_device_enable(bp->sdev, 0);
 	b44_clear_stats(bp);
 
-	/* Make PHY accessible. */
-	bw32(bp, B44_MDIO_CTRL, (MDIO_CTRL_PREAMBLE |
-			     (0x0d & MDIO_CTRL_MAXF_MASK)));
+	switch (sdev->bus->bustype) {
+	case SSB_BUSTYPE_SSB:
+		bw32(bp, B44_MDIO_CTRL, (MDIO_CTRL_PREAMBLE |
+		     (((ssb_clockspeed(sdev->bus) + (B44_MDC_RATIO / 2)) / B44_MDC_RATIO)
+		     & MDIO_CTRL_MAXF_MASK)));
+		break;
+	case SSB_BUSTYPE_PCI:
+	case SSB_BUSTYPE_PCMCIA:
+		bw32(bp, B44_MDIO_CTRL, (MDIO_CTRL_PREAMBLE |
+		     (0x0d & MDIO_CTRL_MAXF_MASK)));
+		break;
+	}
+
 	br32(bp, B44_MDIO_CTRL);
 
 	if (!(br32(bp, B44_DEVCTRL) & DEVCTRL_IPP)) {
@@ -1349,6 +1348,7 @@ static int b44_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct b44 *bp = netdev_priv(dev);
 	struct sockaddr *addr = p;
+	u32 val;
 
 	if (netif_running(dev))
 		return -EBUSY;
@@ -1359,7 +1359,11 @@ static int b44_set_mac_addr(struct net_device *dev, void *p)
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	spin_lock_irq(&bp->lock);
-	__b44_set_mac_addr(bp);
+
+	val = br32(bp, B44_RXCONFIG);
+	if (!(val & RXCONFIG_CAM_ABSENT))
+		__b44_set_mac_addr(bp);
+
 	spin_unlock_irq(&bp->lock);
 
 	return 0;
@@ -1416,7 +1420,7 @@ static int b44_open(struct net_device *dev)
 	struct b44 *bp = netdev_priv(dev);
 	int err;
 
-	err = b44_alloc_consistent(bp);
+	err = b44_alloc_consistent(bp, GFP_KERNEL);
 	if (err)
 		goto out;
 
@@ -1445,18 +1449,6 @@ out:
 	return err;
 }
 
-#if 0
-/*static*/ void b44_dump_state(struct b44 *bp)
-{
-	u32 val32, val32_2, val32_3, val32_4, val32_5;
-	u16 val16;
-
-	pci_read_config_word(bp->pdev, PCI_STATUS, &val16);
-	printk("DEBUG: PCI status [%04x] \n", val16);
-
-}
-#endif
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling receive - used by netconsole and other diagnostic tools
@@ -1567,10 +1559,24 @@ static void b44_setup_pseudo_magicp(struct b44 *bp)
 
 }
 
+#ifdef CONFIG_B44_PCI
+static void b44_setup_wol_pci(struct b44 *bp)
+{
+	u16 val;
+
+	if (bp->sdev->bus->bustype != SSB_BUSTYPE_SSB) {
+		bw32(bp, SSB_TMSLOW, br32(bp, SSB_TMSLOW) | SSB_TMSLOW_PE);
+		pci_read_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, &val);
+		pci_write_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, val | SSB_PE);
+	}
+}
+#else
+static inline void b44_setup_wol_pci(struct b44 *bp) { }
+#endif /* CONFIG_B44_PCI */
+
 static void b44_setup_wol(struct b44 *bp)
 {
 	u32 val;
-	u16 pmval;
 
 	bw32(bp, B44_RXCONFIG, RXCONFIG_ALLMULTI);
 
@@ -1594,13 +1600,7 @@ static void b44_setup_wol(struct b44 *bp)
  	} else {
  		b44_setup_pseudo_magicp(bp);
  	}
-
-	val = br32(bp, B44_SBTMSLOW);
-	bw32(bp, B44_SBTMSLOW, val | SBTMSLOW_PE);
-
-	pci_read_config_word(bp->pdev, SSB_PMCSR, &pmval);
-	pci_write_config_word(bp->pdev, SSB_PMCSR, pmval | SSB_PE);
-
+	b44_setup_wol_pci(bp);
 }
 
 static int b44_close(struct net_device *dev)
@@ -1615,9 +1615,6 @@ static int b44_close(struct net_device *dev)
 
 	spin_lock_irq(&bp->lock);
 
-#if 0
-	b44_dump_state(bp);
-#endif
 	b44_halt(bp);
 	b44_free_rings(bp);
 	netif_carrier_off(dev);
@@ -1700,7 +1697,7 @@ static void __b44_set_rx_mode(struct net_device *dev)
 
 	val = br32(bp, B44_RXCONFIG);
 	val &= ~(RXCONFIG_PROMISC | RXCONFIG_ALLMULTI);
-	if (dev->flags & IFF_PROMISC) {
+	if ((dev->flags & IFF_PROMISC) || (val & RXCONFIG_CAM_ABSENT)) {
 		val |= RXCONFIG_PROMISC;
 		bw32(bp, B44_RXCONFIG, val);
 	} else {
@@ -1748,11 +1745,19 @@ static void b44_set_msglevel(struct net_device *dev, u32 value)
 static void b44_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct b44 *bp = netdev_priv(dev);
-	struct pci_dev *pci_dev = bp->pdev;
+	struct ssb_bus *bus = bp->sdev->bus;
 
-	strcpy (info->driver, DRV_MODULE_NAME);
-	strcpy (info->version, DRV_MODULE_VERSION);
-	strcpy (info->bus_info, pci_name(pci_dev));
+	strncpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strncpy(info->version, DRV_MODULE_VERSION, sizeof(info->driver));
+	switch (bus->bustype) {
+	case SSB_BUSTYPE_PCI:
+		strncpy(info->bus_info, pci_name(bus->host_pci), sizeof(info->bus_info));
+		break;
+	case SSB_BUSTYPE_PCMCIA:
+	case SSB_BUSTYPE_SSB:
+		strncpy(info->bus_info, "SSB", sizeof(info->bus_info));
+		break;
+	}
 }
 
 static int b44_nway_reset(struct net_device *dev)
@@ -2051,33 +2056,23 @@ out:
 	return err;
 }
 
-/* Read 128-bytes of EEPROM. */
-static int b44_read_eeprom(struct b44 *bp, u8 *data)
-{
-	long i;
-	__le16 *ptr = (__le16 *) data;
-
-	for (i = 0; i < 128; i += 2)
-		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
-
-	return 0;
-}
-
 static int __devinit b44_get_invariants(struct b44 *bp)
 {
-	u8 eeprom[128];
-	int err;
+	struct ssb_device *sdev = bp->sdev;
+	int err = 0;
+	u8 *addr;
 
-	err = b44_read_eeprom(bp, &eeprom[0]);
-	if (err)
-		goto out;
+	bp->dma_offset = ssb_dma_translation(sdev);
 
-	bp->dev->dev_addr[0] = eeprom[79];
-	bp->dev->dev_addr[1] = eeprom[78];
-	bp->dev->dev_addr[2] = eeprom[81];
-	bp->dev->dev_addr[3] = eeprom[80];
-	bp->dev->dev_addr[4] = eeprom[83];
-	bp->dev->dev_addr[5] = eeprom[82];
+	if (sdev->bus->bustype == SSB_BUSTYPE_SSB &&
+	    instance > 1) {
+		addr = sdev->bus->sprom.r1.et1mac;
+		bp->phy_addr = sdev->bus->sprom.r1.et1phyaddr;
+	} else {
+		addr = sdev->bus->sprom.r1.et0mac;
+		bp->phy_addr = sdev->bus->sprom.r1.et0phyaddr;
+	}
+	memcpy(bp->dev->dev_addr, addr, 6);
 
 	if (!is_valid_ether_addr(&bp->dev->dev_addr[0])){
 		printk(KERN_ERR PFX "Invalid MAC address found in EEPROM\n");
@@ -2086,103 +2081,51 @@ static int __devinit b44_get_invariants(struct b44 *bp)
 
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, bp->dev->addr_len);
 
-	bp->phy_addr = eeprom[90] & 0x1f;
-
 	bp->imask = IMASK_DEF;
-
-	bp->core_unit = ssb_core_unit(bp);
-	bp->dma_offset = SB_PCI_DMA;
-
 	/* XXX - really required?
 	   bp->flags |= B44_FLAG_BUGGY_TXPTR;
-         */
+	*/
 
- 	if (ssb_get_core_rev(bp) >= 7)
- 		bp->flags |= B44_FLAG_B0_ANDLATER;
+	if (bp->sdev->id.revision >= 7)
+		bp->flags |= B44_FLAG_B0_ANDLATER;
 
-out:
 	return err;
 }
 
-static int __devinit b44_init_one(struct pci_dev *pdev,
-				  const struct pci_device_id *ent)
+static int __devinit b44_init_one(struct ssb_device *sdev,
+				  const struct ssb_device_id *ent)
 {
 	static int b44_version_printed = 0;
-	unsigned long b44reg_base, b44reg_len;
 	struct net_device *dev;
 	struct b44 *bp;
 	int err, i;
 
+	instance++;
+
 	if (b44_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
 
-	err = pci_enable_device(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "Cannot enable PCI device, "
-		       "aborting.\n");
-		return err;
-	}
-
-	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		dev_err(&pdev->dev,
-			"Cannot find proper PCI device "
-		       "base address, aborting.\n");
-		err = -ENODEV;
-		goto err_out_disable_pdev;
-	}
-
-	err = pci_request_regions(pdev, DRV_MODULE_NAME);
-	if (err) {
-		dev_err(&pdev->dev,
-			"Cannot obtain PCI resources, aborting.\n");
-		goto err_out_disable_pdev;
-	}
-
-	pci_set_master(pdev);
-
-	err = pci_set_dma_mask(pdev, (u64) DMA_30BIT_MASK);
-	if (err) {
-		dev_err(&pdev->dev, "No usable DMA configuration, aborting.\n");
-		goto err_out_free_res;
-	}
-
-	err = pci_set_consistent_dma_mask(pdev, (u64) DMA_30BIT_MASK);
-	if (err) {
-		dev_err(&pdev->dev, "No usable DMA configuration, aborting.\n");
-		goto err_out_free_res;
-	}
-
-	b44reg_base = pci_resource_start(pdev, 0);
-	b44reg_len = pci_resource_len(pdev, 0);
-
 	dev = alloc_etherdev(sizeof(*bp));
 	if (!dev) {
-		dev_err(&pdev->dev, "Etherdev alloc failed, aborting.\n");
+		dev_err(sdev->dev, "Etherdev alloc failed, aborting.\n");
 		err = -ENOMEM;
-		goto err_out_free_res;
+		goto out;
 	}
 
 	SET_MODULE_OWNER(dev);
-	SET_NETDEV_DEV(dev,&pdev->dev);
+	SET_NETDEV_DEV(dev, sdev->dev);
 
 	/* No interesting netdevice features in this card... */
 	dev->features |= 0;
 
 	bp = netdev_priv(dev);
-	bp->pdev = pdev;
+	bp->sdev = sdev;
 	bp->dev = dev;
 
 	bp->msg_enable = netif_msg_init(b44_debug, B44_DEF_MSG_ENABLE);
 
 	spin_lock_init(&bp->lock);
 
-	bp->regs = ioremap(b44reg_base, b44reg_len);
-	if (bp->regs == 0UL) {
-		dev_err(&pdev->dev, "Cannot map device registers, aborting.\n");
-		err = -ENOMEM;
-		goto err_out_free_dev;
-	}
-
 	bp->rx_pending = B44_DEF_RX_RING_PENDING;
 	bp->tx_pending = B44_DEF_TX_RING_PENDING;
 
@@ -2201,16 +2144,28 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 	dev->poll_controller = b44_poll_controller;
 #endif
 	dev->change_mtu = b44_change_mtu;
-	dev->irq = pdev->irq;
+	dev->irq = sdev->irq;
 	SET_ETHTOOL_OPS(dev, &b44_ethtool_ops);
 
 	netif_carrier_off(dev);
 
+	err = ssb_bus_powerup(sdev->bus, 0);
+	if (err) {
+		dev_err(sdev->dev,
+			"Failed to powerup the bus\n");
+		goto err_out_free_dev;
+	}
+	err = ssb_dma_set_mask(sdev, DMA_30BIT_MASK);
+	if (err) {
+		dev_err(sdev->dev,
+			"Required 30BIT DMA mask unsupported by the system.\n");
+		goto err_out_powerdown;
+	}
 	err = b44_get_invariants(bp);
 	if (err) {
-		dev_err(&pdev->dev,
+		dev_err(sdev->dev,
 			"Problem fetching invariants of chip, aborting.\n");
-		goto err_out_iounmap;
+		goto err_out_powerdown;
 	}
 
 	bp->mii_if.dev = dev;
@@ -2229,61 +2184,51 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 
 	err = register_netdev(dev);
 	if (err) {
-		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_iounmap;
+		dev_err(sdev->dev, "Cannot register net device, aborting.\n");
+		goto err_out_powerdown;
 	}
 
-	pci_set_drvdata(pdev, dev);
-
-	pci_save_state(bp->pdev);
+	ssb_set_drvdata(sdev, dev);
 
 	/* Chip reset provides power to the b44 MAC & PCI cores, which
 	 * is necessary for MAC register access.
 	 */
 	b44_chip_reset(bp);
 
-	printk(KERN_INFO "%s: Broadcom 4400 10/100BaseT Ethernet ", dev->name);
+	printk(KERN_INFO "%s: Broadcom 44xx/47xx 10/100BaseT Ethernet ", dev->name);
 	for (i = 0; i < 6; i++)
 		printk("%2.2x%c", dev->dev_addr[i],
 		       i == 5 ? '\n' : ':');
 
 	return 0;
 
-err_out_iounmap:
-	iounmap(bp->regs);
+err_out_powerdown:
+	ssb_bus_may_powerdown(sdev->bus);
 
 err_out_free_dev:
 	free_netdev(dev);
 
-err_out_free_res:
-	pci_release_regions(pdev);
-
-err_out_disable_pdev:
-	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
+out:
 	return err;
 }
 
-static void __devexit b44_remove_one(struct pci_dev *pdev)
+static void __devexit b44_remove_one(struct ssb_device *sdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct b44 *bp = netdev_priv(dev);
+	struct net_device *dev = ssb_get_drvdata(sdev);
 
 	unregister_netdev(dev);
-	iounmap(bp->regs);
+	ssb_bus_may_powerdown(sdev->bus);
 	free_netdev(dev);
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
+	ssb_set_drvdata(sdev, NULL);
 }
 
-static int b44_suspend(struct pci_dev *pdev, pm_message_t state)
+static int b44_suspend(struct ssb_device *sdev, pm_message_t state)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = ssb_get_drvdata(sdev);
 	struct b44 *bp = netdev_priv(dev);
 
         if (!netif_running(dev))
-                 return 0;
+		return 0;
 
 	del_timer_sync(&bp->timer);
 
@@ -2301,33 +2246,29 @@ static int b44_suspend(struct pci_dev *pdev, pm_message_t state)
 		b44_init_hw(bp, B44_PARTIAL_RESET);
 		b44_setup_wol(bp);
 	}
-	pci_disable_device(pdev);
+
 	return 0;
 }
 
-static int b44_resume(struct pci_dev *pdev)
+static int b44_resume(struct ssb_device *sdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = ssb_get_drvdata(sdev);
 	struct b44 *bp = netdev_priv(dev);
 	int rc = 0;
 
-	pci_restore_state(pdev);
-	rc = pci_enable_device(pdev);
+	rc = ssb_bus_powerup(sdev->bus, 0);
 	if (rc) {
-		printk(KERN_ERR PFX "%s: pci_enable_device failed\n",
-			dev->name);
+		dev_err(sdev->dev,
+			"Failed to powerup the bus\n");
 		return rc;
 	}
 
-	pci_set_master(pdev);
-
 	if (!netif_running(dev))
 		return 0;
 
 	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
 		printk(KERN_ERR PFX "%s: request_irq failed\n", dev->name);
-		pci_disable_device(pdev);
 		return rc;
 	}
 
@@ -2346,29 +2287,53 @@ static int b44_resume(struct pci_dev *pdev)
 	return 0;
 }
 
-static struct pci_driver b44_driver = {
+static struct ssb_driver b44_ssb_driver = {
 	.name		= DRV_MODULE_NAME,
-	.id_table	= b44_pci_tbl,
+	.id_table	= b44_ssb_tbl,
 	.probe		= b44_init_one,
 	.remove		= __devexit_p(b44_remove_one),
-        .suspend        = b44_suspend,
-        .resume         = b44_resume,
+	.suspend	= b44_suspend,
+	.resume		= b44_resume,
 };
 
+static inline int b44_pci_init(void)
+{
+	int err = 0;
+#ifdef CONFIG_B44_PCI
+	err = ssb_pcihost_register(&b44_pci_driver);
+#endif
+	return err;
+}
+
+static inline void b44_pci_exit(void)
+{
+#ifdef CONFIG_B44_PCI
+	ssb_pcihost_unregister(&b44_pci_driver);
+#endif
+}
+
 static int __init b44_init(void)
 {
 	unsigned int dma_desc_align_size = dma_get_cache_alignment();
+	int err;
 
 	/* Setup paramaters for syncing RX/TX DMA descriptors */
 	dma_desc_align_mask = ~(dma_desc_align_size - 1);
 	dma_desc_sync_size = max_t(unsigned int, dma_desc_align_size, sizeof(struct dma_desc));
 
-	return pci_register_driver(&b44_driver);
+	err = b44_pci_init();
+	if (err)
+		return err;
+	err = ssb_driver_register(&b44_ssb_driver);
+	if (err)
+		b44_pci_exit();
+	return err;
 }
 
 static void __exit b44_cleanup(void)
 {
-	pci_unregister_driver(&b44_driver);
+	ssb_driver_unregister(&b44_ssb_driver);
+	b44_pci_exit();
 }
 
 module_init(b44_init);
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index e537e63..632a851 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -129,6 +129,7 @@
 #define  RXCONFIG_FLOW		0x00000020 /* Flow Control Enable */
 #define  RXCONFIG_FLOW_ACCEPT	0x00000040 /* Accept Unicast Flow Control Frame */
 #define  RXCONFIG_RFILT		0x00000080 /* Reject Filter */
+#define  RXCONFIG_CAM_ABSENT	0x00000100 /* CAM Absent */
 #define B44_RXMAXLEN	0x0404UL /* EMAC RX Max Packet Length */
 #define B44_TXMAXLEN	0x0408UL /* EMAC TX Max Packet Length */
 #define B44_MDIO_CTRL	0x0410UL /* EMAC MDIO Control */
@@ -227,76 +228,6 @@
 #define B44_RX_PAUSE	0x05D4UL /* MIB RX Pause Packets */
 #define B44_RX_NPAUSE	0x05D8UL /* MIB RX Non-Pause Packets */
 
-/* Silicon backplane register definitions */
-#define B44_SBIMSTATE	0x0F90UL /* SB Initiator Agent State */
-#define  SBIMSTATE_PC		0x0000000f /* Pipe Count */
-#define  SBIMSTATE_AP_MASK	0x00000030 /* Arbitration Priority */
-#define  SBIMSTATE_AP_BOTH	0x00000000 /* Use both timeslices and token */
-#define  SBIMSTATE_AP_TS	0x00000010 /* Use timeslices only */
-#define  SBIMSTATE_AP_TK	0x00000020 /* Use token only */
-#define  SBIMSTATE_AP_RSV	0x00000030 /* Reserved */
-#define  SBIMSTATE_IBE		0x00020000 /* In Band Error */
-#define  SBIMSTATE_TO		0x00040000 /* Timeout */
-#define B44_SBINTVEC	0x0F94UL /* SB Interrupt Mask */
-#define  SBINTVEC_PCI		0x00000001 /* Enable interrupts for PCI */
-#define  SBINTVEC_ENET0		0x00000002 /* Enable interrupts for enet 0 */
-#define  SBINTVEC_ILINE20	0x00000004 /* Enable interrupts for iline20 */
-#define  SBINTVEC_CODEC		0x00000008 /* Enable interrupts for v90 codec */
-#define  SBINTVEC_USB		0x00000010 /* Enable interrupts for usb */
-#define  SBINTVEC_EXTIF		0x00000020 /* Enable interrupts for external i/f */
-#define  SBINTVEC_ENET1		0x00000040 /* Enable interrupts for enet 1 */
-#define B44_SBTMSLOW	0x0F98UL /* SB Target State Low */
-#define  SBTMSLOW_RESET		0x00000001 /* Reset */
-#define  SBTMSLOW_REJECT	0x00000002 /* Reject */
-#define  SBTMSLOW_CLOCK		0x00010000 /* Clock Enable */
-#define  SBTMSLOW_FGC		0x00020000 /* Force Gated Clocks On */
-#define  SBTMSLOW_PE		0x40000000 /* Power Management Enable */
-#define  SBTMSLOW_BE		0x80000000 /* BIST Enable */
-#define B44_SBTMSHIGH	0x0F9CUL /* SB Target State High */
-#define  SBTMSHIGH_SERR		0x00000001 /* S-error */
-#define  SBTMSHIGH_INT		0x00000002 /* Interrupt */
-#define  SBTMSHIGH_BUSY		0x00000004 /* Busy */
-#define  SBTMSHIGH_GCR		0x20000000 /* Gated Clock Request */
-#define  SBTMSHIGH_BISTF	0x40000000 /* BIST Failed */
-#define  SBTMSHIGH_BISTD	0x80000000 /* BIST Done */
-#define B44_SBIDHIGH	0x0FFCUL /* SB Identification High */
-#define  SBIDHIGH_RC_MASK	0x0000000f /* Revision Code */
-#define  SBIDHIGH_CC_MASK	0x0000fff0 /* Core Code */
-#define  SBIDHIGH_CC_SHIFT	4
-#define  SBIDHIGH_VC_MASK	0xffff0000 /* Vendor Code */
-#define  SBIDHIGH_VC_SHIFT	16
-
-/* SSB PCI config space registers.  */
-#define SSB_PMCSR		0x44
-#define  SSB_PE			0x100
-#define	SSB_BAR0_WIN		0x80
-#define	SSB_BAR1_WIN		0x84
-#define	SSB_SPROM_CONTROL	0x88
-#define	SSB_BAR1_CONTROL	0x8c
-
-/* SSB core and host control registers.  */
-#define SSB_CONTROL		0x0000UL
-#define SSB_ARBCONTROL		0x0010UL
-#define SSB_ISTAT		0x0020UL
-#define SSB_IMASK		0x0024UL
-#define SSB_MBOX		0x0028UL
-#define SSB_BCAST_ADDR		0x0050UL
-#define SSB_BCAST_DATA		0x0054UL
-#define SSB_PCI_TRANS_0		0x0100UL
-#define SSB_PCI_TRANS_1		0x0104UL
-#define SSB_PCI_TRANS_2		0x0108UL
-#define SSB_SPROM		0x0800UL
-
-#define SSB_PCI_MEM		0x00000000
-#define SSB_PCI_IO		0x00000001
-#define SSB_PCI_CFG0		0x00000002
-#define SSB_PCI_CFG1		0x00000003
-#define SSB_PCI_PREF		0x00000004
-#define SSB_PCI_BURST		0x00000008
-#define SSB_PCI_MASK0		0xfc000000
-#define SSB_PCI_MASK1		0xfc000000
-#define SSB_PCI_MASK2		0xc0000000
-
 /* 4400 PHY registers */
 #define B44_MII_AUXCTRL		24	/* Auxiliary Control */
 #define  MII_AUXCTRL_DUPLEX	0x0001  /* Full Duplex */
@@ -346,10 +277,12 @@ struct rx_header {
 
 struct ring_info {
 	struct sk_buff		*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping);
+	dma_addr_t	mapping;
 };
 
 #define B44_MCAST_TABLE_SIZE	32
+#define B44_PHY_ADDR_NO_PHY	30
+#define B44_MDC_RATIO		5000000
 
 #define	B44_STAT_REG_DECLARE		\
 	_B44(tx_good_octets)		\
@@ -410,6 +343,8 @@ B44_STAT_REG_DECLARE
 #undef _B44
 };
 
+struct ssb_device;
+
 struct b44 {
 	spinlock_t		lock;
 
@@ -450,8 +385,7 @@ struct b44 {
 	struct net_device_stats	stats;
 	struct b44_hw_stats	hw_stats;
 
-	void __iomem		*regs;
-	struct pci_dev		*pdev;
+	struct ssb_device	*sdev;
 	struct net_device	*dev;
 
 	dma_addr_t		rx_ring_dma, tx_ring_dma;
@@ -459,7 +393,6 @@ struct b44 {
 	u32			rx_pending;
 	u32			tx_pending;
 	u8			phy_addr;
-	u8			core_unit;
 
 	struct mii_if_info	mii_if;
 };
diff --git a/drivers/usb/host/Kconfig b/drivers/usb/host/Kconfig
index 565d6ef..dc3b7fe 100644
--- a/drivers/usb/host/Kconfig
+++ b/drivers/usb/host/Kconfig
@@ -154,6 +154,19 @@ config USB_OHCI_HCD_PCI
 	  Enables support for PCI-bus plug-in USB controller cards.
 	  If unsure, say Y.
 
+config USB_OHCI_HCD_SSB
+	bool "OHCI support for the Broadcom SSB OHCI core (embedded systems only)"
+	depends on USB_OHCI_HCD && ((USB_OHCI_HCD=m && SSB) || (USB_OHCI_HCD=y && SSB=y)) && EXPERIMENTAL
+	default n
+	---help---
+	  Support for the Sonics Silicon Backplane (SSB) attached
+	  Broadcom USB OHCI core.
+
+	  This device is only present in some embedded devices with
+	  Broadcom based SSB bus.
+
+	  If unsure, say N.
+
 config USB_OHCI_BIG_ENDIAN_DESC
 	bool
 	depends on USB_OHCI_HCD
diff --git a/drivers/usb/host/ohci-hcd.c b/drivers/usb/host/ohci-hcd.c
index 6edf409..cc39e22 100644
--- a/drivers/usb/host/ohci-hcd.c
+++ b/drivers/usb/host/ohci-hcd.c
@@ -926,11 +926,17 @@ MODULE_LICENSE ("GPL");
 #define PS3_SYSTEM_BUS_DRIVER	ps3_ohci_driver
 #endif
 
+#ifdef CONFIG_USB_OHCI_HCD_SSB
+#include "ohci-ssb.c"
+#define SSB_OHCI_DRIVER		ssb_ohci_driver
+#endif
+
 #if	!defined(PCI_DRIVER) &&		\
 	!defined(PLATFORM_DRIVER) &&	\
 	!defined(OF_PLATFORM_DRIVER) &&	\
 	!defined(SA1111_DRIVER) &&	\
-	!defined(PS3_SYSTEM_BUS_DRIVER)
+	!defined(PS3_SYSTEM_BUS_DRIVER) && \
+	!defined(SSB_OHCI_DRIVER)
 #error "missing bus glue for ohci-hcd"
 #endif
 
@@ -975,10 +981,20 @@ static int __init ohci_hcd_mod_init(void)
 		goto error_pci;
 #endif
 
+#ifdef SSB_OHCI_DRIVER
+	retval = ssb_driver_register(&SSB_OHCI_DRIVER);
+	if (retval)
+		goto error_ssb;
+#endif
+
 	return retval;
 
 	/* Error path */
+#ifdef SSB_OHCI_DRIVER
+ error_ssb:
+#endif
 #ifdef PCI_DRIVER
+	pci_unregister_driver(&PCI_DRIVER);
  error_pci:
 #endif
 #ifdef SA1111_DRIVER
@@ -1003,6 +1019,9 @@ module_init(ohci_hcd_mod_init);
 
 static void __exit ohci_hcd_mod_exit(void)
 {
+#ifdef SSB_OHCI_DRIVER
+	ssb_driver_unregister(&SSB_OHCI_DRIVER);
+#endif
 #ifdef PCI_DRIVER
 	pci_unregister_driver(&PCI_DRIVER);
 #endif
diff --git a/drivers/usb/host/ohci-ssb.c b/drivers/usb/host/ohci-ssb.c
new file mode 100644
index 0000000..2b3ef36
--- /dev/null
+++ b/drivers/usb/host/ohci-ssb.c
@@ -0,0 +1,254 @@
+/*
+ * Sonics Silicon Backplane
+ * Broadcom USB-core OHCI driver
+ *
+ * Copyright 2007 Michael Buesch <mb@bu3sch.de>
+ *
+ * Derived from the OHCI-PCI driver
+ * Copyright 1999 Roman Weissgaerber
+ * Copyright 2000-2002 David Brownell
+ * Copyright 1999 Linus Torvalds
+ * Copyright 1999 Gregory P. Smith
+ *
+ * Derived from the USBcore related parts of Broadcom-SB
+ * Copyright 2005 Broadcom Corporation
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#include <linux/ssb/ssb.h>
+
+
+#define SSB_OHCI_TMSLOW_HOSTMODE	(1 << 29)
+
+struct ssb_ohci_device {
+	struct ohci_hcd ohci; /* _must_ be at the beginning. */
+
+	u32 enable_flags;
+};
+
+
+static inline
+struct ssb_ohci_device * hcd_to_ssb_ohci(struct usb_hcd *hcd)
+{
+	return (struct ssb_ohci_device *)(hcd->hcd_priv);
+}
+
+
+static const struct ssb_device_id ssb_ohci_table[] = {
+	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_USB11_HOSTDEV, SSB_ANY_REV),
+	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_USB11_HOST, SSB_ANY_REV),
+	SSB_DEVTABLE_END
+};
+MODULE_DEVICE_TABLE(ssb, ssb_ohci_table);
+
+
+static int ssb_ohci_reset(struct usb_hcd *hcd)
+{
+	struct ssb_ohci_device *ohcidev = hcd_to_ssb_ohci(hcd);
+	struct ohci_hcd *ohci = &ohcidev->ohci;
+	int err;
+
+	ohci_hcd_init(ohci);
+	err = ohci_init(ohci);
+
+	return err;
+}
+
+static int ssb_ohci_start(struct usb_hcd *hcd)
+{
+	struct ssb_ohci_device *ohcidev = hcd_to_ssb_ohci(hcd);
+	struct ohci_hcd *ohci = &ohcidev->ohci;
+	int err;
+
+	err = ohci_run(ohci);
+	if (err < 0) {
+		ohci_err(ohci, "can't start\n");
+		ohci_stop(hcd);
+	}
+
+	return err;
+}
+
+#ifdef CONFIG_PM
+static int ssb_ohci_hcd_suspend(struct usb_hcd *hcd, pm_message_t message)
+{
+	struct ssb_ohci_device *ohcidev = hcd_to_ssb_ohci(hcd);
+	struct ohci_hcd *ohci = &ohcidev->ohci;
+	unsigned long flags;
+
+	spin_lock_irqsave(&ohci->lock, flags);
+
+	ohci_writel(ohci, OHCI_INTR_MIE, &ohci->regs->intrdisable);
+	ohci_readl(ohci, &ohci->regs->intrdisable); /* commit write */
+
+	/* make sure snapshot being resumed re-enumerates everything */
+	if (message.event == PM_EVENT_PRETHAW)
+		ohci_usb_reset(ohci);
+
+	clear_bit(HCD_FLAG_HW_ACCESSIBLE, &hcd->flags);
+
+	spin_unlock_irqrestore(&ohci->lock, flags);
+
+	return 0;
+}
+
+static int ssb_ohci_hcd_resume(struct usb_hcd *hcd)
+{
+	set_bit(HCD_FLAG_HW_ACCESSIBLE, &hcd->flags);
+	usb_hcd_resume_root_hub(hcd);
+	return 0;
+}
+#endif /* CONFIG_PM */
+
+static const struct hc_driver ssb_ohci_hc_driver = {
+	.description		= "ssb-usb-ohci",
+	.product_desc		= "SSB OHCI Controller",
+	.hcd_priv_size		= sizeof(struct ssb_ohci_device),
+
+	.irq			= ohci_irq,
+	.flags			= HCD_MEMORY | HCD_USB11,
+
+	.reset			= ssb_ohci_reset,
+	.start			= ssb_ohci_start,
+	.stop			= ohci_stop,
+	.shutdown		= ohci_shutdown,
+
+#ifdef CONFIG_PM
+	.suspend		= ssb_ohci_hcd_suspend,
+	.resume			= ssb_ohci_hcd_resume,
+#endif
+
+	.urb_enqueue		= ohci_urb_enqueue,
+	.urb_dequeue		= ohci_urb_dequeue,
+	.endpoint_disable	= ohci_endpoint_disable,
+
+	.get_frame_number	= ohci_get_frame,
+
+	.hub_status_data	= ohci_hub_status_data,
+	.hub_control		= ohci_hub_control,
+	.hub_irq_enable		= ohci_rhsc_enable,
+
+#ifdef CONFIG_PM
+	.bus_suspend		= ohci_bus_suspend,
+	.bus_resume		= ohci_bus_resume,
+#endif
+
+	.start_port_reset	= ohci_start_port_reset,
+};
+
+
+static void ssb_ohci_detach(struct ssb_device *dev)
+{
+	struct usb_hcd *hcd = ssb_get_drvdata(dev);
+
+	usb_remove_hcd(hcd);
+	iounmap(hcd->regs);
+	usb_put_hcd(hcd);
+	ssb_device_disable(dev, 0);
+}
+
+static int ssb_ohci_attach(struct ssb_device *dev)
+{
+	struct ssb_ohci_device *ohcidev;
+	struct usb_hcd *hcd;
+	int err = -ENOMEM;
+	u32 tmp, flags = 0;
+
+	if (dev->id.coreid == SSB_DEV_USB11_HOSTDEV)
+		flags |= SSB_OHCI_TMSLOW_HOSTMODE;
+
+	ssb_device_enable(dev, flags);
+
+	hcd = usb_create_hcd(&ssb_ohci_hc_driver, dev->dev,
+			     dev->dev->bus_id);
+	if (!hcd)
+		goto err_dev_disable;
+	ohcidev = hcd_to_ssb_ohci(hcd);
+	ohcidev->enable_flags = flags;
+
+	tmp = ssb_read32(dev, SSB_ADMATCH0);
+	hcd->rsrc_start = ssb_admatch_base(tmp);
+	hcd->rsrc_len = ssb_admatch_size(tmp);
+	hcd->regs = ioremap_nocache(hcd->rsrc_start, hcd->rsrc_len);
+	if (!hcd->regs)
+		goto err_put_hcd;
+	err = usb_add_hcd(hcd, dev->irq, IRQF_SHARED);
+	if (err)
+		goto err_iounmap;
+
+	ssb_set_drvdata(dev, hcd);
+
+	return err;
+
+err_iounmap:
+	iounmap(hcd->regs);
+err_put_hcd:
+	usb_put_hcd(hcd);
+err_dev_disable:
+	ssb_device_disable(dev, flags);
+	return err;
+}
+
+static int ssb_ohci_probe(struct ssb_device *dev,
+			  const struct ssb_device_id *id)
+{
+	int err;
+	u16 chipid_top;
+
+	chipid_top = (dev->bus->chip_id & 0xFF00);
+	if (chipid_top != 0x4700 &&
+	    chipid_top != 0x5300) {
+		/* USBcores are only connected on embedded devices. */
+		return -ENODEV;
+	}
+	/* TODO: Probably need more checks here whether the core is connected. */
+
+	if (usb_disabled())
+		return -ENODEV;
+
+	/* We currently always attach SSB_DEV_USB11_HOSTDEV
+	 * as HOST OHCI. If we want to attach it as Client device,
+	 * we must branch here and call into the (yet to
+	 * be written) Client mode driver. Same for remove(). */
+
+	err = ssb_ohci_attach(dev);
+
+	return err;
+}
+
+static void ssb_ohci_remove(struct ssb_device *dev)
+{
+	ssb_ohci_detach(dev);
+}
+
+#ifdef CONFIG_PM
+static int ssb_ohci_suspend(struct ssb_device *dev, pm_message_t state)
+{
+	ssb_device_disable(dev, 0);
+
+	return 0;
+}
+
+static int ssb_ohci_resume(struct ssb_device *dev)
+{
+	struct usb_hcd *hcd = ssb_get_drvdata(dev);
+	struct ssb_ohci_device *ohcidev = hcd_to_ssb_ohci(hcd);
+
+	ssb_device_enable(dev, ohcidev->enable_flags);
+
+	return 0;
+}
+#else /* CONFIG_PM */
+# define ssb_ohci_suspend	NULL
+# define ssb_ohci_resume	NULL
+#endif /* CONFIG_PM */
+
+static struct ssb_driver ssb_ohci_driver = {
+	.name		= KBUILD_MODNAME,
+	.id_table	= ssb_ohci_table,
+	.probe		= ssb_ohci_probe,
+	.remove		= ssb_ohci_remove,
+	.suspend	= ssb_ohci_suspend,
+	.resume		= ssb_ohci_resume,
+};
-- 
John W. Linville
linville@tuxdriver.com
