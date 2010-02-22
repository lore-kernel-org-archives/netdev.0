From: gfilip@ee.ethz.ch
Subject: [PATCH 2/5] temac: dma init for Virtex4
Date: Mon, 22 Feb 2010 20:06:58 +0100
Message-ID: <1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch>
References: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
Cc: glikely@secretlab.ca, Filip Gospodinov <gfilip@ee.ethz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:56366 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684Ab0BVTOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 14:14:38 -0500
In-Reply-To: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch belongs to a set of patches which extends the temac driver to support Virtex4-FX. It was successfully tested on the ML403 evaluation board.

Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
---
 drivers/net/ll_temac.h      |    4 ++++
 drivers/net/ll_temac_main.c |   17 ++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
index 95dd650..51824a8 100644
--- a/drivers/net/ll_temac.h
+++ b/drivers/net/ll_temac.h
@@ -383,7 +383,11 @@ struct temac_local {
 
 	/* IO registers and IRQs */
 	void __iomem *regs;
+#ifdef CONFIG_XILINX_VIRTEX_4_FX
+	void __iomem *dma_regs;
+#else
 	dcr_host_t sdma_dcrs;
+#endif
 	int tx_irq;
 	int rx_irq;
 	int emac_num;
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index a8522bd..0d4b1c5 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -812,7 +812,6 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	struct net_device *ndev;
 	const void *addr;
 	int size, rc = 0;
-	unsigned int dcrs;
 
 	/* Init network device structure */
 	ndev = alloc_etherdev(sizeof(*lp));
@@ -862,6 +861,21 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 		goto nodev;
 	}
 
+#ifdef CONFIG_XILINX_VIRTEX_4_FX
+	unsigned int ds;
+	const u32 *dr = of_get_property(np, "reg", &ds);
+	if (dr == NULL || ds & 1 || 0 >= ds ) {
+		dev_err(&op->dev, "could not get DMA register address\n");
+		goto nodev;
+	}
+	lp->dma_regs = (u32) ioremap(*dr, 4096);
+	if (!lp->dma_regs) {
+		dev_err(&op->dev, "could not get DMA virtual address\n");
+		goto nodev;
+	}
+	dev_dbg(&op->dev, "DMA base: %x\n", lp->dma_regs);
+#else	/*CONFIG_XILINX_VIRTEX_4_FX*/
+	unsigned int dcrs;
 	dcrs = dcr_resource_start(np, 0);
 	if (dcrs == 0) {
 		dev_err(&op->dev, "could not get DMA register address\n");
@@ -869,6 +883,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	}
 	lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
 	dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
+#endif /*CONFIG_XILINX_VIRTEX_4_FX*/'
 
 	lp->rx_irq = irq_of_parse_and_map(np, 0);
 	lp->tx_irq = irq_of_parse_and_map(np, 1);
-- 
1.6.4.4

