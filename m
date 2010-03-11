From: akpm@linux-foundation.org
Subject: [patch 3/5] LL TEMAC driver: add non-Virtex 5 support
Date: Thu, 11 Mar 2010 14:07:51 -0800
Message-ID: <201003112207.o2BM7qhv013492@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jtyner@cs.ucr.edu, afleming@freescale.com,
	grant.likely@secretlab.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44418 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758302Ab0CKWH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:07:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Tyner <jtyner@cs.ucr.edu>

Add support for using the LL TEMAC Ethernet driver on non-Virtex 5
platforms by adding support for accessing the Soft DMA registers as if
they were memory mapped instead of solely through the DCR's (available on
the Virtex 5).

Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
Cc: Andy Fleming <afleming@freescale.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ll_temac.h      |    1 +
 drivers/net/ll_temac_main.c |   31 ++++++++++++++++++++-----------
 2 files changed, 21 insertions(+), 11 deletions(-)

diff -puN drivers/net/ll_temac.h~ll-temac-driver-add-non-virtex-5-support drivers/net/ll_temac.h
--- a/drivers/net/ll_temac.h~ll-temac-driver-add-non-virtex-5-support
+++ a/drivers/net/ll_temac.h
@@ -338,6 +338,7 @@ struct temac_local {
 	/* IO registers and IRQs */
 	void __iomem *regs;
 	dcr_host_t sdma_dcrs;
+	u32 __iomem *sdma_regs;
 	int tx_irq;
 	int rx_irq;
 	int emac_num;
diff -puN drivers/net/ll_temac_main.c~ll-temac-driver-add-non-virtex-5-support drivers/net/ll_temac_main.c
--- a/drivers/net/ll_temac_main.c~ll-temac-driver-add-non-virtex-5-support
+++ a/drivers/net/ll_temac_main.c
@@ -20,9 +20,6 @@
  *   or rx, so this should be okay.
  *
  * TODO:
- * - Fix driver to work on more than just Virtex5.  Right now the driver
- *   assumes that the locallink DMA registers are accessed via DCR
- *   instructions.
  * - Factor out locallink DMA code into separate driver
  * - Fix multicast assignment.
  * - Fix support for hardware checksumming.
@@ -117,12 +114,20 @@ void temac_indirect_out32(struct temac_l
 
 static u32 temac_dma_in32(struct temac_local *lp, int reg)
 {
-	return dcr_read(lp->sdma_dcrs, reg);
+	if (lp->sdma_regs) {
+		return __raw_readl(lp->sdma_regs + reg);
+	} else {
+		return dcr_read(lp->sdma_dcrs, reg);
+	}
 }
 
 static void temac_dma_out32(struct temac_local *lp, int reg, u32 value)
 {
-	dcr_write(lp->sdma_dcrs, reg, value);
+	if (lp->sdma_regs) {
+		__raw_writel(value, lp->sdma_regs + reg);
+	} else {
+		dcr_write(lp->sdma_dcrs, reg, value);
+	}
 }
 
 /**
@@ -870,13 +875,17 @@ temac_of_probe(struct of_device *op, con
 		goto nodev;
 	}
 
-	dcrs = dcr_resource_start(np, 0);
-	if (dcrs == 0) {
-		dev_err(&op->dev, "could not get DMA register address\n");
+	lp->sdma_regs = NULL;
+
+	if ((dcrs = dcr_resource_start(np, 0)) != 0) {
+		lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
+		dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
+	} else if ((lp->sdma_regs = of_iomap(np, 0))) {
+		dev_dbg(&op->dev, "MEM base: %p\n", lp->sdma_regs);
+	} else {
+		dev_err(&op->dev, "unable to map DMA registers\n");
 		goto nodev;
 	}
-	lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
-	dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
 
 	lp->rx_irq = irq_of_parse_and_map(np, 0);
 	lp->tx_irq = irq_of_parse_and_map(np, 1);
@@ -903,7 +912,7 @@ temac_of_probe(struct of_device *op, con
 
 	lp->phy_node = of_parse_phandle(op->node, "phy-handle", 0);
 	if (lp->phy_node)
-		dev_dbg(lp->dev, "using PHY node %s (%p)\n", np->full_name, np);
+		dev_dbg(lp->dev, "using PHY node %s (%p)\n", lp->phy_node->full_name, lp->phy_node);
 
 	/* Add the device attributes */
 	rc = sysfs_create_group(&lp->dev->kobj, &temac_attr_group);
_
