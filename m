From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 3/6] net: calxedaxgmac: use raw i/o accessors in rx and tx paths
Date: Mon,  5 Nov 2012 10:22:21 -0600
Message-ID: <1352132544-15809-4-git-send-email-robherring2@gmail.com>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:49379 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab2KEQWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 11:22:42 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so5924901oag.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 08:22:42 -0800 (PST)
In-Reply-To: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

The standard readl/writel accessors involve a spinlock and cache sync
operation on ARM platforms with an outer cache. Only DMA triggering
accesses need this, so use the raw variants instead in the critical paths.

The relaxed variants would be more appropriate, but don't exist on all
arches.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
v3:
- Use raw i/o accessors instead of relaxed for better build coverage.

 drivers/net/ethernet/calxeda/xgmac.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 728fcef..84cd40e 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1203,7 +1203,7 @@ static int xgmac_poll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		napi_complete(napi);
-		writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_INTR_ENA);
+		__raw_writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_INTR_ENA);
 	}
 	return work_done;
 }
@@ -1348,7 +1348,7 @@ static irqreturn_t xgmac_pmt_interrupt(int irq, void *dev_id)
 	struct xgmac_priv *priv = netdev_priv(dev);
 	void __iomem *ioaddr = priv->base;
 
-	intr_status = readl(ioaddr + XGMAC_INT_STAT);
+	intr_status = __raw_readl(ioaddr + XGMAC_INT_STAT);
 	if (intr_status & XGMAC_INT_STAT_PMT) {
 		netdev_dbg(priv->dev, "received Magic frame\n");
 		/* clear the PMT bits 5 and 6 by reading the PMT */
@@ -1366,9 +1366,9 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
 	struct xgmac_extra_stats *x = &priv->xstats;
 
 	/* read the status register (CSR5) */
-	intr_status = readl(priv->base + XGMAC_DMA_STATUS);
-	intr_status &= readl(priv->base + XGMAC_DMA_INTR_ENA);
-	writel(intr_status, priv->base + XGMAC_DMA_STATUS);
+	intr_status = __raw_readl(priv->base + XGMAC_DMA_STATUS);
+	intr_status &= __raw_readl(priv->base + XGMAC_DMA_INTR_ENA);
+	__raw_writel(intr_status, priv->base + XGMAC_DMA_STATUS);
 
 	/* It displays the DMA process states (CSR5 register) */
 	/* ABNORMAL interrupts */
@@ -1404,7 +1404,7 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
 
 	/* TX/RX NORMAL interrupts */
 	if (intr_status & (DMA_STATUS_RI | DMA_STATUS_TU)) {
-		writel(DMA_INTR_ABNORMAL, priv->base + XGMAC_DMA_INTR_ENA);
+		__raw_writel(DMA_INTR_ABNORMAL, priv->base + XGMAC_DMA_INTR_ENA);
 		napi_schedule(&priv->napi);
 	}
 
-- 
1.7.10.4
