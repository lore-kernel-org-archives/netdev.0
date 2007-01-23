From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH review] b44: Port to ssb subsystem
Date: Tue, 23 Jan 2007 17:20:35 +0100
Message-ID: <200701231720.36370.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54020
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964851AbXAWQXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 11:23:03 -0500
To: Gary Zambrano <zambrano@broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch ports b44 to the new SSB subsystem and makes
it possible to turn off PCI related stuff.

This patch is against my tree, where I have implemented the
ssb subsystem.

If you're all OK with this patch, I'd like apply it to my tree.
I think that's best. Although it's not wireless-related, it's
much easier to maintain this way.

This patch is tested on a b4401b0

This patch also makes it possible to run the driver on b47xx devices.


Index: bu3sch-wireless-dev/drivers/net/b44.c
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/b44.c	2007-01-23 17:10:05.000000000 +0100
+++ bu3sch-wireless-dev/drivers/net/b44.c	2007-01-23 17:15:05.000000000 +0100
@@ -1,7 +1,10 @@
-/* b44.c: Broadcom 4400 device driver.
+/* b44.c: Broadcom 44xx/47xx device driver.
  *
  * Copyright (C) 2002 David S. Miller (davem@redhat.com)
- * Fixed by Pekka Pietikainen (pp@ee.oulu.fi)
+ * Copyright (C) 2004 Pekka Pietikainen (pp@ee.oulu.fi)
+ * Copyright (C) 2004 Florian Schirmer (jolt@tuxbox.org)
+ * Copyright (C) 2006 Felix Fietkau (nbd@openwrt.org)
+ * Copyright (C) 2007 Michael Buesch <mb@bu3sch.de>
  * Copyright (C) 2006 Broadcom Corporation.
  *
  * Distribute under GPL.
@@ -20,11 +23,13 @@
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
@@ -87,8 +92,8 @@
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
-MODULE_AUTHOR("Florian Schirmer, Pekka Pietikainen, David S. Miller");
-MODULE_DESCRIPTION("Broadcom 4400 10/100 PCI ethernet driver");
+MODULE_AUTHOR("Felix Fietkau, Florian Schirmer, Pekka Pietikainen, David S. Miller");
+MODULE_DESCRIPTION("Broadcom 44xx/47xx 10/100 PCI ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
@@ -96,17 +101,22 @@
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
+#endif /* CONFIG_B44_PCI */
+
+static const struct ssb_device_id b44_ssb_tbl[] = {
+	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_ETHERNET, SSB_ANY_REV),
+	SSB_DEVTABLE_END
+};
+MODULE_DEVICE_TABLE(ssb, b44_ssb_tbl);
 
 static void b44_halt(struct b44 *);
 static void b44_init_rings(struct b44 *);
@@ -114,6 +124,7 @@
 
 static int dma_desc_align_mask;
 static int dma_desc_sync_size;
+static int instance;
 
 static const char b44_gstrings[][ETH_GSTRING_LEN] = {
 #define _B44(x...)	# x,
@@ -121,35 +132,35 @@
 #undef _B44
 };
 
-static inline void b44_sync_dma_desc_for_device(struct pci_dev *pdev,
-                                                dma_addr_t dma_base,
-                                                unsigned long offset,
-                                                enum dma_data_direction dir)
-{
-	dma_sync_single_range_for_device(&pdev->dev, dma_base,
-	                                 offset & dma_desc_align_mask,
-	                                 dma_desc_sync_size, dir);
-}
-
-static inline void b44_sync_dma_desc_for_cpu(struct pci_dev *pdev,
-                                             dma_addr_t dma_base,
-                                             unsigned long offset,
-                                             enum dma_data_direction dir)
-{
-	dma_sync_single_range_for_cpu(&pdev->dev, dma_base,
-	                              offset & dma_desc_align_mask,
-	                              dma_desc_sync_size, dir);
+static inline void b44_sync_dma_desc_for_device(struct ssb_device *sdev,
+						dma_addr_t dma_base,
+						unsigned long offset,
+						enum dma_data_direction dir)
+{
+	dma_sync_single_range_for_device(&sdev->dev, dma_base,
+					 offset & dma_desc_align_mask,
+					 dma_desc_sync_size, dir);
+}
+
+static inline void b44_sync_dma_desc_for_cpu(struct ssb_device *sdev,
+					     dma_addr_t dma_base,
+					     unsigned long offset,
+					     enum dma_data_direction dir)
+{
+	dma_sync_single_range_for_cpu(&sdev->dev, dma_base,
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
@@ -177,117 +188,29 @@
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
+	bw32(bp, B44_CAM_CTRL, (CAM_CTRL_READ |
+			    (index << CAM_CTRL_INDEX_SHIFT)));
 
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_CLOCK));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-}
+	b44_wait_bit(bp, B44_CAM_CTRL, CAM_CTRL_BUSY, 100, 1);
 
-static int ssb_core_unit(struct b44 *bp)
-{
-#if 0
-	u32 val = br32(bp, B44_SBADMATCH0);
-	u32 base;
+	val = br32(bp, B44_CAM_DATA_LO);
 
-	type = val & SBADMATCH0_TYPE_MASK;
-	switch (type) {
-	case 0:
-		base = val & SBADMATCH0_BS0_MASK;
-		break;
+	data[2] = (val >> 24) & 0xFF;
+	data[3] = (val >> 16) & 0xFF;
+	data[4] = (val >> 8) & 0xFF;
+	data[5] = (val >> 0) & 0xFF;
 
-	case 1:
-		base = val & SBADMATCH0_BS1_MASK;
-		break;
+	val = br32(bp, B44_CAM_DATA_HI);
 
-	case 2:
-	default:
-		base = val & SBADMATCH0_BS2_MASK;
-		break;
-	};
-#endif
-	return 0;
+	data[0] = (val >> 8) & 0xFF;
+	data[1] = (val >> 0) & 0xFF;
 }
 
-static int ssb_is_core_up(struct b44 *bp)
-{
-	return ((br32(bp, B44_SBTMSLOW) & (SBTMSLOW_RESET | SBTMSLOW_REJECT | SBTMSLOW_CLOCK))
-		== SBTMSLOW_CLOCK);
-}
-
-static void __b44_cam_write(struct b44 *bp, unsigned char *data, int index)
+static inline void __b44_cam_write(struct b44 *bp, unsigned char *data, int index)
 {
 	u32 val;
 
@@ -323,14 +246,14 @@
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
@@ -339,18 +262,34 @@
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
 /* FIXME FIXME: phy_id is ignored, bp->phy_addr use is unconditional
  * due to code existing before miilib use was added to this driver.
@@ -379,6 +318,8 @@
 	u32 val;
 	int err;
 
+	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+		return 0;
 	err = b44_writephy(bp, MII_BMCR, BMCR_RESET);
 	if (err)
 		return err;
@@ -437,11 +378,52 @@
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
@@ -537,6 +519,19 @@
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
@@ -613,10 +608,10 @@
 
 		BUG_ON(skb == NULL);
 
-		pci_unmap_single(bp->pdev,
+		dma_unmap_single(&bp->sdev->dev,
 				 pci_unmap_addr(rp, mapping),
 				 skb->len,
-				 PCI_DMA_TODEVICE);
+				 DMA_TO_DEVICE);
 		rp->skb = NULL;
 		dev_kfree_skb_irq(skb);
 	}
@@ -653,9 +648,9 @@
 	if (skb == NULL)
 		return -ENOMEM;
 
-	mapping = pci_map_single(bp->pdev, skb->data,
+	mapping = dma_map_single(&bp->sdev->dev, skb->data,
 				 RX_PKT_BUF_SZ,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 
 	/* Hardware bug work-around, the chip is unable to do PCI DMA
 	   to/from anything above 1GB :-( */
@@ -663,18 +658,18 @@
 		mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
 		/* Sigh... */
 		if (!dma_mapping_error(mapping))
-			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+			dma_unmap_single(&bp->sdev->dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
 		skb = __dev_alloc_skb(RX_PKT_BUF_SZ,GFP_DMA);
 		if (skb == NULL)
 			return -ENOMEM;
-		mapping = pci_map_single(bp->pdev, skb->data,
+		mapping = dma_map_single(&bp->sdev->dev, skb->data,
 					 RX_PKT_BUF_SZ,
-					 PCI_DMA_FROMDEVICE);
+					 DMA_FROM_DEVICE);
 		if (dma_mapping_error(mapping) ||
 			mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
 			if (!dma_mapping_error(mapping))
-				pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+				dma_unmap_single(&bp->sdev->dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
@@ -703,9 +698,9 @@
 	dp->addr = cpu_to_le32((u32) mapping + bp->rx_offset + bp->dma_offset);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		b44_sync_dma_desc_for_device(bp->pdev, bp->rx_ring_dma,
-		                             dest_idx * sizeof(dp),
-		                             DMA_BIDIRECTIONAL);
+		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
+			                    dest_idx * sizeof(dp),
+			                    DMA_BIDIRECTIONAL);
 
 	return RX_PKT_BUF_SZ;
 }
@@ -732,9 +727,9 @@
 			   pci_unmap_addr(src_map, mapping));
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		b44_sync_dma_desc_for_cpu(bp->pdev, bp->rx_ring_dma,
-		                          src_idx * sizeof(src_desc),
-		                          DMA_BIDIRECTIONAL);
+		b44_sync_dma_desc_for_cpu(bp->sdev, bp->rx_ring_dma,
+			                 src_idx * sizeof(src_desc),
+			                 DMA_BIDIRECTIONAL);
 
 	ctrl = src_desc->ctrl;
 	if (dest_idx == (B44_RX_RING_SIZE - 1))
@@ -748,13 +743,13 @@
 	src_map->skb = NULL;
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		b44_sync_dma_desc_for_device(bp->pdev, bp->rx_ring_dma,
-		                             dest_idx * sizeof(dest_desc),
-		                             DMA_BIDIRECTIONAL);
+		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
+			                    dest_idx * sizeof(dest_desc),
+			                    DMA_BIDIRECTIONAL);
 
-	pci_dma_sync_single_for_device(bp->pdev, src_desc->addr,
+	dma_sync_single_for_device(&bp->sdev->dev, src_desc->addr,
 				       RX_PKT_BUF_SZ,
-				       PCI_DMA_FROMDEVICE);
+				       DMA_FROM_DEVICE);
 }
 
 static int b44_rx(struct b44 *bp, int budget)
@@ -774,9 +769,9 @@
 		struct rx_header *rh;
 		u16 len;
 
-		pci_dma_sync_single_for_cpu(bp->pdev, map,
+		dma_sync_single_for_cpu(&bp->sdev->dev, map,
 					    RX_PKT_BUF_SZ,
-					    PCI_DMA_FROMDEVICE);
+					    DMA_FROM_DEVICE);
 		rh = (struct rx_header *) skb->data;
 		len = cpu_to_le16(rh->len);
 		if ((len > (RX_PKT_BUF_SZ - bp->rx_offset)) ||
@@ -808,11 +803,11 @@
 			skb_size = b44_alloc_rx_skb(bp, cons, bp->rx_prod);
 			if (skb_size < 0)
 				goto drop_it;
-			pci_unmap_single(bp->pdev, map,
-					 skb_size, PCI_DMA_FROMDEVICE);
+			dma_unmap_single(&bp->sdev->dev, map,
+					 skb_size, DMA_FROM_DEVICE);
 			/* Leave out rx_header */
-                	skb_put(skb, len+bp->rx_offset);
-            	        skb_pull(skb,bp->rx_offset);
+	       	skb_put(skb, len+bp->rx_offset);
+	   	        skb_pull(skb,bp->rx_offset);
 		} else {
 			struct sk_buff *copy_skb;
 
@@ -982,23 +977,23 @@
 		goto err_out;
 	}
 
-	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	mapping = dma_map_single(&bp->sdev->dev, skb->data, len, DMA_TO_DEVICE);
 	if (dma_mapping_error(mapping) || mapping + len > B44_DMA_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
 		if (!dma_mapping_error(mapping))
-			pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
+			dma_unmap_single(&bp->sdev->dev, mapping, len, DMA_TO_DEVICE);
 
 		bounce_skb = __dev_alloc_skb(TX_PKT_BUF_SZ,
 					     GFP_ATOMIC|GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
-		mapping = pci_map_single(bp->pdev, bounce_skb->data,
-					 len, PCI_DMA_TODEVICE);
+		mapping = dma_map_single(&bp->sdev->dev, bounce_skb->data,
+					 len, DMA_TO_DEVICE);
 		if (dma_mapping_error(mapping) || mapping + len > B44_DMA_MASK) {
 			if (!dma_mapping_error(mapping))
-				pci_unmap_single(bp->pdev, mapping,
-					 len, PCI_DMA_TODEVICE);
+				dma_unmap_single(&bp->sdev->dev, mapping,
+					 len, DMA_TO_DEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
 		}
@@ -1021,9 +1016,9 @@
 	bp->tx_ring[entry].addr = cpu_to_le32((u32) mapping+bp->dma_offset);
 
 	if (bp->flags & B44_FLAG_TX_RING_HACK)
-		b44_sync_dma_desc_for_device(bp->pdev, bp->tx_ring_dma,
-		                             entry * sizeof(bp->tx_ring[0]),
-		                             DMA_TO_DEVICE);
+		b44_sync_dma_desc_for_device(bp->sdev, bp->tx_ring_dma,
+			                    entry * sizeof(bp->tx_ring[0]),
+			                    DMA_TO_DEVICE);
 
 	entry = NEXT_TX(entry);
 
@@ -1096,10 +1091,10 @@
 
 		if (rp->skb == NULL)
 			continue;
-		pci_unmap_single(bp->pdev,
+		dma_unmap_single(&bp->sdev->dev,
 				 pci_unmap_addr(rp, mapping),
 				 RX_PKT_BUF_SZ,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
 	}
@@ -1110,10 +1105,10 @@
 
 		if (rp->skb == NULL)
 			continue;
-		pci_unmap_single(bp->pdev,
+		dma_unmap_single(&bp->sdev->dev,
 				 pci_unmap_addr(rp, mapping),
 				 rp->skb->len,
-				 PCI_DMA_TODEVICE);
+				 DMA_TO_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
 	}
@@ -1135,14 +1130,14 @@
 	memset(bp->tx_ring, 0, B44_TX_RING_BYTES);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		dma_sync_single_for_device(&bp->pdev->dev, bp->rx_ring_dma,
-		                           DMA_TABLE_BYTES,
-		                           PCI_DMA_BIDIRECTIONAL);
+		dma_sync_single_for_device(&bp->sdev->dev, bp->rx_ring_dma,
+			                  DMA_TABLE_BYTES,
+			                  DMA_BIDIRECTIONAL);
 
 	if (bp->flags & B44_FLAG_TX_RING_HACK)
-		dma_sync_single_for_device(&bp->pdev->dev, bp->tx_ring_dma,
-		                           DMA_TABLE_BYTES,
-		                           PCI_DMA_TODEVICE);
+		dma_sync_single_for_device(&bp->sdev->dev, bp->tx_ring_dma,
+			                  DMA_TABLE_BYTES,
+			                  DMA_TO_DEVICE);
 
 	for (i = 0; i < bp->rx_pending; i++) {
 		if (b44_alloc_rx_skb(bp, -1, i) < 0)
@@ -1162,24 +1157,24 @@
 	bp->tx_buffers = NULL;
 	if (bp->rx_ring) {
 		if (bp->flags & B44_FLAG_RX_RING_HACK) {
-			dma_unmap_single(&bp->pdev->dev, bp->rx_ring_dma,
-				         DMA_TABLE_BYTES,
-				         DMA_BIDIRECTIONAL);
+			dma_unmap_single(&bp->sdev->dev, bp->rx_ring_dma,
+					DMA_TABLE_BYTES,
+					DMA_BIDIRECTIONAL);
 			kfree(bp->rx_ring);
 		} else
-			pci_free_consistent(bp->pdev, DMA_TABLE_BYTES,
+			dma_free_coherent(&bp->sdev->dev, DMA_TABLE_BYTES,
 					    bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 		bp->flags &= ~B44_FLAG_RX_RING_HACK;
 	}
 	if (bp->tx_ring) {
 		if (bp->flags & B44_FLAG_TX_RING_HACK) {
-			dma_unmap_single(&bp->pdev->dev, bp->tx_ring_dma,
-				         DMA_TABLE_BYTES,
-				         DMA_TO_DEVICE);
+			dma_unmap_single(&bp->sdev->dev, bp->tx_ring_dma,
+					DMA_TABLE_BYTES,
+					DMA_TO_DEVICE);
 			kfree(bp->tx_ring);
 		} else
-			pci_free_consistent(bp->pdev, DMA_TABLE_BYTES,
+			dma_free_coherent(&bp->sdev->dev, DMA_TABLE_BYTES,
 					    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring = NULL;
 		bp->flags &= ~B44_FLAG_TX_RING_HACK;
@@ -1190,22 +1185,22 @@
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
+	bp->rx_ring = dma_alloc_coherent(&bp->sdev->dev, size, &bp->rx_ring_dma, gfp);
 	if (!bp->rx_ring) {
 		/* Allocation may have failed due to pci_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1213,13 +1208,13 @@
 		struct dma_desc *rx_ring;
 		dma_addr_t rx_ring_dma;
 
-		rx_ring = kzalloc(size, GFP_KERNEL);
+		rx_ring = kzalloc(size, gfp);
 		if (!rx_ring)
 			goto out_err;
 
-		rx_ring_dma = dma_map_single(&bp->pdev->dev, rx_ring,
-		                             DMA_TABLE_BYTES,
-		                             DMA_BIDIRECTIONAL);
+		rx_ring_dma = dma_map_single(&bp->sdev->dev, rx_ring,
+			                    DMA_TABLE_BYTES,
+			                    DMA_BIDIRECTIONAL);
 
 		if (dma_mapping_error(rx_ring_dma) ||
 			rx_ring_dma + size > B44_DMA_MASK) {
@@ -1232,21 +1227,21 @@
 		bp->flags |= B44_FLAG_RX_RING_HACK;
 	}
 
-	bp->tx_ring = pci_alloc_consistent(bp->pdev, size, &bp->tx_ring_dma);
+	bp->tx_ring = dma_alloc_coherent(&bp->sdev->dev, size, &bp->tx_ring_dma, gfp);
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
+		tx_ring_dma = dma_map_single(&bp->sdev->dev, tx_ring,
+			                    DMA_TABLE_BYTES,
+			                    DMA_TO_DEVICE);
 
 		if (dma_mapping_error(tx_ring_dma) ||
 			tx_ring_dma + size > B44_DMA_MASK) {
@@ -1281,7 +1276,9 @@
 /* bp->lock is held. */
 static void b44_chip_reset(struct b44 *bp)
 {
-	if (ssb_is_core_up(bp)) {
+	struct ssb_device *sdev = bp->sdev;
+
+	if (ssb_device_is_enabled(bp->sdev)) {
 		bw32(bp, B44_RCV_LAZY, 0);
 		bw32(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE);
 		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 100, 1);
@@ -1293,19 +1290,24 @@
 		}
 		bw32(bp, B44_DMARX_CTRL, 0);
 		bp->rx_prod = bp->rx_cons = 0;
-	} else {
-		ssb_pci_setup(bp, (bp->core_unit == 0 ?
-				   SBINTVEC_ENET0 :
-				   SBINTVEC_ENET1));
 	}
 
-	ssb_core_reset(bp);
-
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
@@ -1348,6 +1350,7 @@
 {
 	struct b44 *bp = netdev_priv(dev);
 	struct sockaddr *addr = p;
+ 	u32 val;
 
 	if (netif_running(dev))
 		return -EBUSY;
@@ -1358,7 +1361,11 @@
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	spin_lock_irq(&bp->lock);
-	__b44_set_mac_addr(bp);
+
+   	val = br32(bp, B44_RXCONFIG);
+   	if (!(val & RXCONFIG_CAM_ABSENT))
+		__b44_set_mac_addr(bp);
+
 	spin_unlock_irq(&bp->lock);
 
 	return 0;
@@ -1415,7 +1422,7 @@
 	struct b44 *bp = netdev_priv(dev);
 	int err;
 
-	err = b44_alloc_consistent(bp);
+	err = b44_alloc_consistent(bp, GFP_KERNEL);
 	if (err)
 		goto out;
 
@@ -1444,18 +1451,6 @@
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
@@ -1570,7 +1565,6 @@
 static void b44_setup_wol(struct b44 *bp)
 {
 	u32 val;
-	u16 pmval;
 
 	bw32(bp, B44_RXCONFIG, RXCONFIG_ALLMULTI);
 
@@ -1595,12 +1589,14 @@
  		b44_setup_pseudo_magicp(bp);
  	}
 
-	val = br32(bp, B44_SBTMSLOW);
-	bw32(bp, B44_SBTMSLOW, val | SBTMSLOW_PE);
-
-	pci_read_config_word(bp->pdev, SSB_PMCSR, &pmval);
-	pci_write_config_word(bp->pdev, SSB_PMCSR, pmval | SSB_PE);
-
+#ifdef CONFIG_B44_PCI
+	if (bp->sdev->bus->bustype != SSB_BUSTYPE_SSB) {
+		val = br32(bp, SSB_TMSLOW);
+		bw32(bp, SSB_TMSLOW, val | SSB_TMSLOW_PE);
+	}
+	pci_read_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, (u16 *)(&val));
+	pci_write_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, val | SSB_PE);
+#endif /* CONFIG_B44_PCI */
 }
 
 static int b44_close(struct net_device *dev)
@@ -1615,9 +1611,6 @@
 
 	spin_lock_irq(&bp->lock);
 
-#if 0
-	b44_dump_state(bp);
-#endif
 	b44_halt(bp);
 	b44_free_rings(bp);
 	netif_carrier_off(dev);
@@ -1700,7 +1693,7 @@
 
 	val = br32(bp, B44_RXCONFIG);
 	val &= ~(RXCONFIG_PROMISC | RXCONFIG_ALLMULTI);
-	if (dev->flags & IFF_PROMISC) {
+	if ((dev->flags & IFF_PROMISC) || (val & RXCONFIG_CAM_ABSENT)) {
 		val |= RXCONFIG_PROMISC;
 		bw32(bp, B44_RXCONFIG, val);
 	} else {
@@ -1747,12 +1740,8 @@
 
 static void b44_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct b44 *bp = netdev_priv(dev);
-	struct pci_dev *pci_dev = bp->pdev;
-
 	strcpy (info->driver, DRV_MODULE_NAME);
 	strcpy (info->version, DRV_MODULE_VERSION);
-	strcpy (info->bus_info, pci_name(pci_dev));
 }
 
 static int b44_nway_reset(struct net_device *dev)
@@ -2036,6 +2025,245 @@
 	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
+static int b44_ethtool_ioctl (struct net_device *dev, void __user *useraddr)
+{
+	struct b44 *bp = dev->priv;
+	u32 ethcmd;
+
+	if (copy_from_user (&ethcmd, useraddr, sizeof (ethcmd)))
+		return -EFAULT;
+
+	switch (ethcmd) {
+	case ETHTOOL_GDRVINFO: {
+		struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
+		strcpy (info.driver, DRV_MODULE_NAME);
+		strcpy (info.version, DRV_MODULE_VERSION);
+		memset(&info.fw_version, 0, sizeof(info.fw_version));
+		info.eedump_len = 0;
+		info.regdump_len = 0;
+		if (copy_to_user (useraddr, &info, sizeof (info)))
+			return -EFAULT;
+		return 0;
+	}
+
+	case ETHTOOL_GSET: {
+		struct ethtool_cmd cmd = { ETHTOOL_GSET };
+
+		if (!(bp->flags & B44_FLAG_INIT_COMPLETE))
+			return -EAGAIN;
+		cmd.supported = (SUPPORTED_Autoneg);
+		cmd.supported |= (SUPPORTED_100baseT_Half |
+				  SUPPORTED_100baseT_Full |
+				  SUPPORTED_10baseT_Half |
+				  SUPPORTED_10baseT_Full |
+				  SUPPORTED_MII);
+
+		cmd.advertising = 0;
+		if (bp->flags & B44_FLAG_ADV_10HALF)
+			cmd.advertising |= ADVERTISE_10HALF;
+		if (bp->flags & B44_FLAG_ADV_10FULL)
+			cmd.advertising |= ADVERTISE_10FULL;
+		if (bp->flags & B44_FLAG_ADV_100HALF)
+			cmd.advertising |= ADVERTISE_100HALF;
+		if (bp->flags & B44_FLAG_ADV_100FULL)
+			cmd.advertising |= ADVERTISE_100FULL;
+		cmd.advertising |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+		cmd.speed = (bp->flags & B44_FLAG_100_BASE_T) ?
+			SPEED_100 : SPEED_10;
+		cmd.duplex = (bp->flags & B44_FLAG_FULL_DUPLEX) ?
+			DUPLEX_FULL : DUPLEX_HALF;
+		cmd.port = 0;
+		cmd.phy_address = bp->phy_addr;
+		cmd.transceiver = (bp->flags & B44_FLAG_INTERNAL_PHY) ?
+			XCVR_INTERNAL : XCVR_EXTERNAL;
+		cmd.autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
+			AUTONEG_DISABLE : AUTONEG_ENABLE;
+		cmd.maxtxpkt = 0;
+		cmd.maxrxpkt = 0;
+		if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_SSET: {
+		struct ethtool_cmd cmd;
+
+		if (!(bp->flags & B44_FLAG_INIT_COMPLETE))
+			return -EAGAIN;
+
+		if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+			return -EFAULT;
+
+		/* We do not support gigabit. */
+		if (cmd.autoneg == AUTONEG_ENABLE) {
+			if (cmd.advertising &
+			    (ADVERTISED_1000baseT_Half |
+			     ADVERTISED_1000baseT_Full))
+				return -EINVAL;
+		} else if ((cmd.speed != SPEED_100 &&
+			    cmd.speed != SPEED_10) ||
+			   (cmd.duplex != DUPLEX_HALF &&
+			    cmd.duplex != DUPLEX_FULL)) {
+				return -EINVAL;
+		}
+
+		spin_lock_irq(&bp->lock);
+
+		if (cmd.autoneg == AUTONEG_ENABLE) {
+			bp->flags &= ~B44_FLAG_FORCE_LINK;
+			bp->flags &= ~(B44_FLAG_ADV_10HALF |
+				       B44_FLAG_ADV_10FULL |
+				       B44_FLAG_ADV_100HALF |
+				       B44_FLAG_ADV_100FULL);
+			if (cmd.advertising & ADVERTISE_10HALF)
+				bp->flags |= B44_FLAG_ADV_10HALF;
+			if (cmd.advertising & ADVERTISE_10FULL)
+				bp->flags |= B44_FLAG_ADV_10FULL;
+			if (cmd.advertising & ADVERTISE_100HALF)
+				bp->flags |= B44_FLAG_ADV_100HALF;
+			if (cmd.advertising & ADVERTISE_100FULL)
+				bp->flags |= B44_FLAG_ADV_100FULL;
+		} else {
+			bp->flags |= B44_FLAG_FORCE_LINK;
+			if (cmd.speed == SPEED_100)
+				bp->flags |= B44_FLAG_100_BASE_T;
+			if (cmd.duplex == DUPLEX_FULL)
+				bp->flags |= B44_FLAG_FULL_DUPLEX;
+		}
+
+		b44_setup_phy(bp);
+
+		spin_unlock_irq(&bp->lock);
+
+		return 0;
+	}
+
+	case ETHTOOL_GMSGLVL: {
+		struct ethtool_value edata = { ETHTOOL_GMSGLVL };
+		edata.data = bp->msg_enable;
+		if (copy_to_user(useraddr, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_SMSGLVL: {
+		struct ethtool_value edata;
+		if (copy_from_user(&edata, useraddr, sizeof(edata)))
+			return -EFAULT;
+		bp->msg_enable = edata.data;
+		return 0;
+	}
+	case ETHTOOL_NWAY_RST: {
+		u32 bmcr;
+		int r;
+
+		spin_lock_irq(&bp->lock);
+		b44_readphy(bp, MII_BMCR, &bmcr);
+		b44_readphy(bp, MII_BMCR, &bmcr);
+		r = -EINVAL;
+		if (bmcr & BMCR_ANENABLE) {
+			b44_writephy(bp, MII_BMCR,
+				     bmcr | BMCR_ANRESTART);
+			r = 0;
+		}
+		spin_unlock_irq(&bp->lock);
+
+		return r;
+	}
+	case ETHTOOL_GLINK: {
+		struct ethtool_value edata = { ETHTOOL_GLINK };
+		edata.data = netif_carrier_ok(bp->dev) ? 1 : 0;
+		if (copy_to_user(useraddr, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_GRINGPARAM: {
+		struct ethtool_ringparam ering = { ETHTOOL_GRINGPARAM };
+
+		ering.rx_max_pending = B44_RX_RING_SIZE - 1;
+		ering.rx_pending = bp->rx_pending;
+
+		/* XXX ethtool lacks a tx_max_pending, oops... */
+
+		if (copy_to_user(useraddr, &ering, sizeof(ering)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_SRINGPARAM: {
+		struct ethtool_ringparam ering;
+
+		if (copy_from_user(&ering, useraddr, sizeof(ering)))
+			return -EFAULT;
+
+		if ((ering.rx_pending > B44_RX_RING_SIZE - 1) ||
+		    (ering.rx_mini_pending != 0) ||
+		    (ering.rx_jumbo_pending != 0) ||
+		    (ering.tx_pending > B44_TX_RING_SIZE - 1))
+			return -EINVAL;
+
+		spin_lock_irq(&bp->lock);
+
+		bp->rx_pending = ering.rx_pending;
+		bp->tx_pending = ering.tx_pending;
+
+		b44_halt(bp);
+		b44_init_rings(bp);
+		b44_init_hw(bp, 1);
+		netif_wake_queue(bp->dev);
+		spin_unlock_irq(&bp->lock);
+
+		b44_enable_ints(bp);
+
+		return 0;
+	}
+	case ETHTOOL_GPAUSEPARAM: {
+		struct ethtool_pauseparam epause = { ETHTOOL_GPAUSEPARAM };
+
+		epause.autoneg =
+			(bp->flags & B44_FLAG_PAUSE_AUTO) != 0;
+		epause.rx_pause =
+			(bp->flags & B44_FLAG_RX_PAUSE) != 0;
+		epause.tx_pause =
+			(bp->flags & B44_FLAG_TX_PAUSE) != 0;
+		if (copy_to_user(useraddr, &epause, sizeof(epause)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_SPAUSEPARAM: {
+		struct ethtool_pauseparam epause;
+
+		if (copy_from_user(&epause, useraddr, sizeof(epause)))
+			return -EFAULT;
+
+		spin_lock_irq(&bp->lock);
+		if (epause.autoneg)
+			bp->flags |= B44_FLAG_PAUSE_AUTO;
+		else
+			bp->flags &= ~B44_FLAG_PAUSE_AUTO;
+		if (epause.rx_pause)
+			bp->flags |= B44_FLAG_RX_PAUSE;
+		else
+			bp->flags &= ~B44_FLAG_RX_PAUSE;
+		if (epause.tx_pause)
+			bp->flags |= B44_FLAG_TX_PAUSE;
+		else
+			bp->flags &= ~B44_FLAG_TX_PAUSE;
+		if (bp->flags & B44_FLAG_PAUSE_AUTO) {
+			b44_halt(bp);
+			b44_init_rings(bp);
+			b44_init_hw(bp, 1);
+		} else {
+			__b44_set_flow_ctrl(bp, bp->flags);
+		}
+		spin_unlock_irq(&bp->lock);
+
+		b44_enable_ints(bp);
+
+		return 0;
+	}
+	};
+
+	return -EOPNOTSUPP;
+}
+
 static int b44_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(ifr);
@@ -2045,40 +2273,61 @@
 	if (!netif_running(dev))
 		goto out;
 
-	spin_lock_irq(&bp->lock);
-	err = generic_mii_ioctl(&bp->mii_if, data, cmd, NULL);
-	spin_unlock_irq(&bp->lock);
-out:
-	return err;
-}
+	switch (cmd) {
+	case SIOCETHTOOL:
+	       return b44_ethtool_ioctl(dev, (void __user*) ifr->ifr_data);
 
-/* Read 128-bytes of EEPROM. */
-static int b44_read_eeprom(struct b44 *bp, u8 *data)
-{
-	long i;
-	u16 *ptr = (u16 *) data;
+	case SIOCGMIIPHY:
+	       data->phy_id = bp->phy_addr;
 
-	for (i = 0; i < 128; i += 2)
-		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
+	       /* fallthru */
+	case SIOCGMIIREG: {
+	       u32 mii_regval;
+	       spin_lock_irq(&bp->lock);
+	       err = __b44_readphy(bp, data->phy_id & 0x1f, data->reg_num & 0x1f, &mii_regval);
+	       spin_unlock_irq(&bp->lock);
 
-	return 0;
+	       data->val_out = mii_regval;
+
+	       return err;
+	}
+
+	case SIOCSMIIREG:
+	       if (!capable(CAP_NET_ADMIN))
+		      return -EPERM;
+
+	       spin_lock_irq(&bp->lock);
+	       err = __b44_writephy(bp, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
+	       spin_unlock_irq(&bp->lock);
+
+	       return err;
+
+	default:
+	       break;
+	};
+	return -EOPNOTSUPP;
+
+out:
+	return err;
 }
 
 static int __devinit b44_get_invariants(struct b44 *bp)
 {
-	u8 eeprom[128];
-	int err;
-
-	err = b44_read_eeprom(bp, &eeprom[0]);
-	if (err)
-		goto out;
-
-	bp->dev->dev_addr[0] = eeprom[79];
-	bp->dev->dev_addr[1] = eeprom[78];
-	bp->dev->dev_addr[2] = eeprom[81];
-	bp->dev->dev_addr[3] = eeprom[80];
-	bp->dev->dev_addr[4] = eeprom[83];
-	bp->dev->dev_addr[5] = eeprom[82];
+	struct ssb_device *sdev = bp->sdev;
+	int err = 0;
+	u8 *addr;
+
+	bp->dma_offset = ssb_dma_translation(sdev);
+
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
@@ -2087,108 +2336,52 @@
 
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, bp->dev->addr_len);
 
-	bp->phy_addr = eeprom[90] & 0x1f;
-
 	/* With this, plus the rx_header prepended to the data by the
 	 * hardware, we'll land the ethernet header on a 2-byte boundary.
 	 */
 	bp->rx_offset = 30;
-
 	bp->imask = IMASK_DEF;
-
-	bp->core_unit = ssb_core_unit(bp);
-	bp->dma_offset = SB_PCI_DMA;
-
 	/* XXX - really required?
 	   bp->flags |= B44_FLAG_BUGGY_TXPTR;
-         */
-
- 	if (ssb_get_core_rev(bp) >= 7)
- 		bp->flags |= B44_FLAG_B0_ANDLATER;
+	*/
 
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
-	err = pci_set_dma_mask(pdev, (u64) B44_DMA_MASK);
-	if (err) {
-		dev_err(&pdev->dev, "No usable DMA configuration, aborting.\n");
-		goto err_out_free_res;
-	}
-
-	err = pci_set_consistent_dma_mask(pdev, (u64) B44_DMA_MASK);
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
+		dev_err(&sdev->dev, "Etherdev alloc failed, aborting.\n");
 		err = -ENOMEM;
-		goto err_out_free_res;
+		goto out;
 	}
 
 	SET_MODULE_OWNER(dev);
-	SET_NETDEV_DEV(dev,&pdev->dev);
+	SET_NETDEV_DEV(dev,&sdev->dev);
 
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
 
@@ -2207,16 +2400,22 @@
 	dev->poll_controller = b44_poll_controller;
 #endif
 	dev->change_mtu = b44_change_mtu;
-	dev->irq = pdev->irq;
+	dev->irq = sdev->irq;
 	SET_ETHTOOL_OPS(dev, &b44_ethtool_ops);
 
 	netif_carrier_off(dev);
 
+	err = ssb_dma_set_mask(sdev, DMA_30BIT_MASK);
+	if (err) {
+		dev_err(&sdev->dev,
+			"Required 30BIT DMA mask unsupported by the system.\n");
+		goto err_out_free_dev;
+	}
 	err = b44_get_invariants(bp);
 	if (err) {
-		dev_err(&pdev->dev,
+		dev_err(&sdev->dev,
 			"Problem fetching invariants of chip, aborting.\n");
-		goto err_out_iounmap;
+		goto err_out_free_dev;
 	}
 
 	bp->mii_if.dev = dev;
@@ -2235,61 +2434,52 @@
 
 	err = register_netdev(dev);
 	if (err) {
-		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_iounmap;
+		dev_err(&sdev->dev, "Cannot register net device, aborting.\n");
+		goto out;
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
 
-	return 0;
+	/* Initialize phy */
+	spin_lock_irq(&bp->lock);
+	b44_chip_reset(bp);
+	spin_unlock_irq(&bp->lock);
 
-err_out_iounmap:
-	iounmap(bp->regs);
+	return 0;
 
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
+static void __devexit b44_remove_one(struct ssb_device *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct b44 *bp = netdev_priv(dev);
+	struct net_device *dev = ssb_get_drvdata(pdev);
 
 	unregister_netdev(dev);
-	iounmap(bp->regs);
 	free_netdev(dev);
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
+	ssb_set_drvdata(pdev, NULL);
 }
 
-static int b44_suspend(struct pci_dev *pdev, pm_message_t state)
+static int b44_suspend(struct ssb_device *sdev, pm_message_t state)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = ssb_get_drvdata(sdev);
 	struct b44 *bp = netdev_priv(dev);
 
         if (!netif_running(dev))
-                 return 0;
+		goto out;
 
 	del_timer_sync(&bp->timer);
 
@@ -2307,18 +2497,26 @@
 		b44_init_hw(bp, 0);
 		b44_setup_wol(bp);
 	}
-	pci_disable_device(pdev);
+
+out:
+#ifdef CONFIG_B44_PCI
+	pci_disable_device(sdev->bus->host_pci);
+#endif
+
 	return 0;
 }
 
-static int b44_resume(struct pci_dev *pdev)
+static int b44_resume(struct ssb_device *sdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = ssb_get_drvdata(sdev);
 	struct b44 *bp = netdev_priv(dev);
 
-	pci_restore_state(pdev);
-	pci_enable_device(pdev);
-	pci_set_master(pdev);
+#ifdef CONFIG_B44_PCI
+	pci_restore_state(sdev->bus->host_pci);
+	if (pci_enable_device(sdev->bus->host_pci))
+		return -ENODEV;
+	pci_set_master(sdev->bus->host_pci);
+#endif /* CONFIG_B44_PCI */
 
 	if (!netif_running(dev))
 		return 0;
@@ -2341,29 +2539,107 @@
 	return 0;
 }
 
-static struct pci_driver b44_driver = {
+#ifdef CONFIG_B44_PCI
+
+static int __devinit b44_pci_probe(struct pci_dev *dev,
+				   const struct pci_device_id *id)
+{
+	struct ssb_bus *ssb;
+	int err = -ENOMEM;
+
+	ssb = kzalloc(sizeof(*ssb), GFP_KERNEL);
+	if (!ssb)
+		goto out;
+	err = pci_enable_device(dev);
+	if (err)
+		goto err_kfree_ssb;
+	err = pci_request_regions(dev, DRV_MODULE_NAME);
+	if (err)
+		goto err_pci_disable;
+	pci_set_master(dev);
+	err = ssb_bus_pcibus_register(ssb, dev);
+	if (err)
+		goto err_pci_release_regions;
+
+	pci_set_drvdata(dev, ssb);
+out:
+	return err;
+err_pci_release_regions:
+	pci_release_regions(dev);
+err_pci_disable:
+	pci_disable_device(dev);
+err_kfree_ssb:
+	kfree(ssb);
+	return err;
+}
+
+static void __devexit b44_pci_remove(struct pci_dev *dev)
+{
+	struct ssb_bus *ssb = pci_get_drvdata(dev);
+
+	ssb_bus_unregister(ssb);
+	pci_release_regions(dev);
+	pci_disable_device(dev);
+	kfree(ssb);
+}
+
+static struct pci_driver b44_pci_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= b44_pci_tbl,
+	.probe		= b44_pci_probe,
+	.remove		= __devexit_p(b44_pci_remove),
+};
+
+#endif /* CONFIG_B44_PCI */
+
+
+static struct ssb_driver b44_ssb_driver = {
+	.name		= DRV_MODULE_NAME,
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
+	err = pci_register_driver(&b44_pci_driver);
+#endif
+	return err;
+}
+
+static inline void b44_pci_exit(void)
+{
+#ifdef CONFIG_B44_PCI
+	pci_unregister_driver(&b44_pci_driver);
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
Index: bu3sch-wireless-dev/drivers/net/b44.h
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/b44.h	2007-01-23 17:10:05.000000000 +0100
+++ bu3sch-wireless-dev/drivers/net/b44.h	2007-01-23 17:15:05.000000000 +0100
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
@@ -346,10 +277,12 @@
 
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
@@ -410,6 +343,8 @@
 #undef _B44
 };
 
+struct ssb_device;
+
 struct b44 {
 	spinlock_t		lock;
 
@@ -425,9 +360,10 @@
 
 	u32			dma_offset;
 	u32			flags;
-#define B44_FLAG_B0_ANDLATER	0x00000001
+#define B44_FLAG_INIT_COMPLETE	0x00000001
 #define B44_FLAG_BUGGY_TXPTR	0x00000002
 #define B44_FLAG_REORDER_BUG	0x00000004
+#define B44_FLAG_B0_ANDLATER    0x00000008
 #define B44_FLAG_PAUSE_AUTO	0x00008000
 #define B44_FLAG_FULL_DUPLEX	0x00010000
 #define B44_FLAG_100_BASE_T	0x00020000
@@ -452,8 +388,7 @@
 	struct net_device_stats	stats;
 	struct b44_hw_stats	hw_stats;
 
-	void __iomem		*regs;
-	struct pci_dev		*pdev;
+	struct ssb_device	*sdev;
 	struct net_device	*dev;
 
 	dma_addr_t		rx_ring_dma, tx_ring_dma;
Index: bu3sch-wireless-dev/drivers/net/Kconfig
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/Kconfig	2007-01-23 17:10:05.000000000 +0100
+++ bu3sch-wireless-dev/drivers/net/Kconfig	2007-01-23 17:15:05.000000000 +0100
@@ -1413,7 +1413,7 @@
 
 config B44
 	tristate "Broadcom 4400 ethernet support"
-	depends on NET_PCI && PCI
+	depends on SSB
 	select MII
 	help
 	  If you have a network (Ethernet) controller of this type, say Y and
@@ -1424,6 +1424,15 @@
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called b44.
 
+config B44_PCI
+	bool "Broadcom 4400 PCI device support"
+	depends on B44 && NET_PCI
+	default y
+	help
+	  Support for b44 PCI devices.
+
+	  Say Y
+
 config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on NET_PCI && PCI

-- 
Greetings Michael.
