From: Olof Johansson <olof@lixom.net>
Subject: [PATCH RESEND] [11/11] pasemi_mac: enable iommu support
Date: Wed, 3 Oct 2007 13:03:54 -0500
Message-ID: <20071003180354.GB19319@lixom.net>
References: <20071002212421.GA2282@lixom.net> <20071002212818.GL2282@lixom.net> <4703D5A5.1080204@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49532 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758777AbXJCR7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 13:59:43 -0400
Content-Disposition: inline
In-Reply-To: <4703D5A5.1080204@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: enable iommu support

Enable IOMMU support for pasemi_mac, but avoid using it on non-partitioned
systems for performance reasons.

The user can override this by selecting the PPC_PASEMI_IOMMU_DMA_FORCE
configuration option.

Signed-off-by: Olof Johansson <olof@lixom.net>

---

On Wed, Oct 03, 2007 at 01:47:17PM -0400, Jeff Garzik wrote:

> You sent patch #10 against as patch #11 :)

Oops! Here's the real copy.


-Olof


Index: k.org/arch/powerpc/platforms/pasemi/iommu.c
===================================================================
--- k.org.orig/arch/powerpc/platforms/pasemi/iommu.c
+++ k.org/arch/powerpc/platforms/pasemi/iommu.c
@@ -25,6 +25,7 @@
 #include <asm/iommu.h>
 #include <asm/machdep.h>
 #include <asm/abs_addr.h>
+#include <asm/firmware.h>
 
 
 #define IOBMAP_PAGE_SHIFT	12
@@ -175,13 +176,17 @@ static void pci_dma_dev_setup_pasemi(str
 {
 	pr_debug("pci_dma_dev_setup, dev %p (%s)\n", dev, pci_name(dev));
 
-	/* DMA device is untranslated, but all other PCI-e goes through
-	 * the IOMMU
+#if !defined(CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE)
+	/* For non-LPAR environment, don't translate anything for the DMA
+	 * engine. The exception to this is if the user has enabled
+	 * CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE at build time.
 	 */
-	if (dev->vendor == 0x1959 && dev->device == 0xa007)
+	if (dev->vendor == 0x1959 && dev->device == 0xa007 &&
+	    !firmware_has_feature(FW_FEATURE_LPAR))
 		dev->dev.archdata.dma_ops = &dma_direct_ops;
-	else
-		dev->dev.archdata.dma_data = &iommu_table_iobmap;
+#endif
+
+	dev->dev.archdata.dma_data = &iommu_table_iobmap;
 }
 
 static void pci_dma_bus_setup_null(struct pci_bus *b) { }
Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -34,6 +34,7 @@
 #include <net/checksum.h>
 
 #include <asm/irq.h>
+#include <asm/firmware.h>
 
 #include "pasemi_mac.h"
 
@@ -89,6 +90,15 @@ MODULE_PARM_DESC(debug, "PA Semi MAC bit
 
 static struct pasdma_status *dma_status;
 
+static int translation_enabled(void)
+{
+#if defined(CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE)
+	return 1;
+#else
+	return firmware_has_feature(FW_FEATURE_LPAR);
+#endif
+}
+
 static void write_iob_reg(struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
@@ -193,6 +203,7 @@ static int pasemi_mac_setup_rx_resources
 	struct pasemi_mac_rxring *ring;
 	struct pasemi_mac *mac = netdev_priv(dev);
 	int chan_id = mac->dma_rxch;
+	unsigned int cfg;
 
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 
@@ -232,20 +243,28 @@ static int pasemi_mac_setup_rx_resources
 			   PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
 			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id),
-			   PAS_DMA_RXCHAN_CFG_HBU(2));
+	cfg = PAS_DMA_RXCHAN_CFG_HBU(2);
+
+	if (translation_enabled())
+		cfg |= PAS_DMA_RXCHAN_CFG_CTR;
+
+	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id), cfg);
 
 	write_dma_reg(mac, PAS_DMA_RXINT_BASEL(mac->dma_if),
-			   PAS_DMA_RXINT_BASEL_BRBL(__pa(ring->buffers)));
+			   PAS_DMA_RXINT_BASEL_BRBL(ring->buf_dma));
 
 	write_dma_reg(mac, PAS_DMA_RXINT_BASEU(mac->dma_if),
-			   PAS_DMA_RXINT_BASEU_BRBH(__pa(ring->buffers) >> 32) |
+			   PAS_DMA_RXINT_BASEU_BRBH(ring->buf_dma >> 32) |
 			   PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if),
-		      PAS_DMA_RXINT_CFG_DHL(3) | PAS_DMA_RXINT_CFG_L2 |
-		      PAS_DMA_RXINT_CFG_LW | PAS_DMA_RXINT_CFG_RBP |
-		      PAS_DMA_RXINT_CFG_HEN);
+	cfg = PAS_DMA_RXINT_CFG_DHL(3) | PAS_DMA_RXINT_CFG_L2 |
+	      PAS_DMA_RXINT_CFG_LW | PAS_DMA_RXINT_CFG_RBP |
+	      PAS_DMA_RXINT_CFG_HEN;
+
+	if (translation_enabled())
+		cfg |= PAS_DMA_RXINT_CFG_ITRR | PAS_DMA_RXINT_CFG_ITR;
+
+	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if), cfg);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
@@ -275,6 +294,7 @@ static int pasemi_mac_setup_tx_resources
 	u32 val;
 	int chan_id = mac->dma_txch;
 	struct pasemi_mac_txring *ring;
+	unsigned int cfg;
 
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 	if (!ring)
@@ -304,11 +324,15 @@ static int pasemi_mac_setup_tx_resources
 
 	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEU(chan_id), val);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(chan_id),
-			   PAS_DMA_TXCHAN_CFG_TY_IFACE |
-			   PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
-			   PAS_DMA_TXCHAN_CFG_UP |
-			   PAS_DMA_TXCHAN_CFG_WT(2));
+	cfg = PAS_DMA_TXCHAN_CFG_TY_IFACE |
+	      PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
+	      PAS_DMA_TXCHAN_CFG_UP |
+	      PAS_DMA_TXCHAN_CFG_WT(2);
+
+	if (translation_enabled())
+		cfg |= PAS_DMA_TXCHAN_CFG_TRD | PAS_DMA_TXCHAN_CFG_TRR;
+
+	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(chan_id), cfg);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -212,6 +212,7 @@ enum {
 #define    PAS_DMA_RXINT_CFG_DHL_S	24
 #define    PAS_DMA_RXINT_CFG_DHL(x)	(((x) << PAS_DMA_RXINT_CFG_DHL_S) & \
 					 PAS_DMA_RXINT_CFG_DHL_M)
+#define    PAS_DMA_RXINT_CFG_ITR	0x00400000
 #define    PAS_DMA_RXINT_CFG_LW		0x00200000
 #define    PAS_DMA_RXINT_CFG_L2		0x00100000
 #define    PAS_DMA_RXINT_CFG_HEN	0x00080000
@@ -258,9 +259,11 @@ enum {
 #define    PAS_DMA_TXCHAN_CFG_WT_S	6
 #define    PAS_DMA_TXCHAN_CFG_WT(x)	(((x) << PAS_DMA_TXCHAN_CFG_WT_S) & \
 					 PAS_DMA_TXCHAN_CFG_WT_M)
-#define    PAS_DMA_TXCHAN_CFG_CF	0x00001000	/* Clean first line */
-#define    PAS_DMA_TXCHAN_CFG_CL	0x00002000	/* Clean last line */
+#define    PAS_DMA_TXCHAN_CFG_TRD	0x00010000	/* translate data */
+#define    PAS_DMA_TXCHAN_CFG_TRR	0x00008000	/* translate rings */
 #define    PAS_DMA_TXCHAN_CFG_UP	0x00004000	/* update tx descr when sent */
+#define    PAS_DMA_TXCHAN_CFG_CL	0x00002000	/* Clean last line */
+#define    PAS_DMA_TXCHAN_CFG_CF	0x00001000	/* Clean first line */
 #define PAS_DMA_TXCHAN_INCR(c)    (0x310+(c)*_PAS_DMA_TXCHAN_STRIDE)
 #define PAS_DMA_TXCHAN_BASEL(c)   (0x318+(c)*_PAS_DMA_TXCHAN_STRIDE)
 #define    PAS_DMA_TXCHAN_BASEL_BRBL_M	0xffffffc0
@@ -294,6 +297,7 @@ enum {
 #define    PAS_DMA_RXCHAN_CCMDSTA_FD	0x00001000
 #define    PAS_DMA_RXCHAN_CCMDSTA_DT	0x00000800
 #define PAS_DMA_RXCHAN_CFG(c)     (0x804+(c)*_PAS_DMA_RXCHAN_STRIDE)
+#define    PAS_DMA_RXCHAN_CFG_CTR	0x00000400
 #define    PAS_DMA_RXCHAN_CFG_HBU_M	0x00000380
 #define    PAS_DMA_RXCHAN_CFG_HBU_S	7
 #define    PAS_DMA_RXCHAN_CFG_HBU(x)	(((x) << PAS_DMA_RXCHAN_CFG_HBU_S) & \
Index: k.org/arch/powerpc/platforms/pasemi/Kconfig
===================================================================
--- k.org.orig/arch/powerpc/platforms/pasemi/Kconfig
+++ k.org/arch/powerpc/platforms/pasemi/Kconfig
@@ -19,6 +19,16 @@ config PPC_PASEMI_IOMMU
 	help
 	  IOMMU support for PA6T-1682M
 
+config PPC_PASEMI_IOMMU_DMA_FORCE
+	bool "Force DMA engine to use IOMMU"
+	depends on PPC_PASEMI_IOMMU
+	help
+	  This option forces the use of the IOMMU also for the
+	  DMA engine. Otherwise the kernel will use it only when
+	  running under a hypervisor.
+
+	  If in doubt, say "N".
+
 config PPC_PASEMI_MDIO
 	depends on PHYLIB
 	tristate "MDIO support via GPIO"
