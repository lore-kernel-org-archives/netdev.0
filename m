From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 3/3][net-next] gianfar: Pack struct gfar_priv_grp into three cachelines
Date: Tue, 29 Jan 2013 15:55:12 +0200
Message-ID: <1359467712-32079-3-git-send-email-claudiu.manoil@freescale.com>
References: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com>
 <1359467712-32079-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:1893 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756604Ab3A2Nzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 08:55:37 -0500
In-Reply-To: <1359467712-32079-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* remove unused members(!): imask, ievent
* move space consuming interrupt name strings (int_name_* members) to
external structures, unessential for the driver's hot path
* keep high priority hot path data within the first 2 cache lines

This reduces struct gfar_priv_grp from 6 to 3 cache lines.
(Also fixed checkpatch warnings for the old code, in the process.)

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   98 ++++++++++++++++++++----------
 drivers/net/ethernet/freescale/gianfar.h |   40 +++++++------
 2 files changed, 87 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index fdb8080..19c54a0 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -544,6 +544,19 @@ static void unmap_group_regs(struct gfar_private *priv)
 			iounmap(priv->gfargrp[i].regs);
 }
 
+static void free_gfar_dev(struct gfar_private *priv)
+{
+	int i, j;
+
+	for (i = 0; i < priv->num_grps; i++)
+		for (j = 0; j < GFAR_NUM_IRQS; j++) {
+			kfree(priv->gfargrp[i].irqinfo[j]);
+			priv->gfargrp[i].irqinfo[j] = NULL;
+		}
+
+	free_netdev(priv->ndev);
+}
+
 static void disable_napi(struct gfar_private *priv)
 {
 	int i;
@@ -565,20 +578,36 @@ static int gfar_parse_group(struct device_node *np,
 {
 	struct gfar_priv_grp *grp = &priv->gfargrp[priv->num_grps];
 	u32 *queue_mask;
+	int i;
+
+	if (priv->mode == MQ_MG_MODE) {
+		for (i = 0; i < GFAR_NUM_IRQS; i++) {
+			grp->irqinfo[i] = kzalloc(sizeof(struct gfar_irqinfo),
+						  GFP_KERNEL);
+			if (!grp->irqinfo[i])
+				return -ENOMEM;
+		}
+	} else {
+		grp->irqinfo[GFAR_TX] = kzalloc(sizeof(struct gfar_irqinfo),
+						GFP_KERNEL);
+		if (!grp->irqinfo[GFAR_TX])
+			return -ENOMEM;
+		grp->irqinfo[GFAR_RX] = grp->irqinfo[GFAR_ER] = NULL;
+	}
 
 	grp->regs = of_iomap(np, 0);
 	if (!grp->regs)
 		return -ENOMEM;
 
-	grp->interruptTransmit = irq_of_parse_and_map(np, 0);
+	gfar_irq(grp, TX)->irq = irq_of_parse_and_map(np, 0);
 
 	/* If we aren't the FEC we have multiple interrupts */
 	if (model && strcasecmp(model, "FEC")) {
-		grp->interruptReceive =	irq_of_parse_and_map(np, 1);
-		grp->interruptError =	irq_of_parse_and_map(np, 2);
-		if (grp->interruptTransmit == NO_IRQ ||
-		    grp->interruptReceive  == NO_IRQ ||
-		    grp->interruptError    == NO_IRQ)
+		gfar_irq(grp, RX)->irq = irq_of_parse_and_map(np, 1);
+		gfar_irq(grp, ER)->irq = irq_of_parse_and_map(np, 2);
+		if (gfar_irq(grp, TX)->irq == NO_IRQ ||
+		    gfar_irq(grp, RX)->irq == NO_IRQ ||
+		    gfar_irq(grp, ER)->irq == NO_IRQ)
 			return -EINVAL;
 	}
 
@@ -779,7 +808,7 @@ tx_alloc_failed:
 	free_tx_pointers(priv);
 err_grp_init:
 	unmap_group_regs(priv);
-	free_netdev(dev);
+	free_gfar_dev(priv);
 	return err;
 }
 
@@ -1184,15 +1213,16 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	/* fill out IRQ number and name fields */
 	for (i = 0; i < priv->num_grps; i++) {
+		struct gfar_priv_grp *grp = &priv->gfargrp[i];
 		if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-			sprintf(priv->gfargrp[i].int_name_tx, "%s%s%c%s",
+			sprintf(gfar_irq(grp, TX)->name, "%s%s%c%s",
 				dev->name, "_g", '0' + i, "_tx");
-			sprintf(priv->gfargrp[i].int_name_rx, "%s%s%c%s",
+			sprintf(gfar_irq(grp, RX)->name, "%s%s%c%s",
 				dev->name, "_g", '0' + i, "_rx");
-			sprintf(priv->gfargrp[i].int_name_er, "%s%s%c%s",
+			sprintf(gfar_irq(grp, ER)->name, "%s%s%c%s",
 				dev->name, "_g", '0' + i, "_er");
 		} else
-			strcpy(priv->gfargrp[i].int_name_tx, dev->name);
+			strcpy(gfar_irq(grp, TX)->name, dev->name);
 	}
 
 	/* Initialize the filer table */
@@ -1225,7 +1255,7 @@ register_fail:
 		of_node_put(priv->phy_node);
 	if (priv->tbi_node)
 		of_node_put(priv->tbi_node);
-	free_netdev(dev);
+	free_gfar_dev(priv);
 	return err;
 }
 
@@ -1242,7 +1272,7 @@ static int gfar_remove(struct platform_device *ofdev)
 
 	unregister_netdev(priv->ndev);
 	unmap_group_regs(priv);
-	free_netdev(priv->ndev);
+	free_gfar_dev(priv);
 
 	return 0;
 }
@@ -1650,9 +1680,9 @@ void gfar_halt(struct net_device *dev)
 
 static void free_grp_irqs(struct gfar_priv_grp *grp)
 {
-	free_irq(grp->interruptError, grp);
-	free_irq(grp->interruptTransmit, grp);
-	free_irq(grp->interruptReceive, grp);
+	free_irq(gfar_irq(grp, TX)->irq, grp);
+	free_irq(gfar_irq(grp, RX)->irq, grp);
+	free_irq(gfar_irq(grp, ER)->irq, grp);
 }
 
 void stop_gfar(struct net_device *dev)
@@ -1681,7 +1711,7 @@ void stop_gfar(struct net_device *dev)
 			free_grp_irqs(&priv->gfargrp[i]);
 	} else {
 		for (i = 0; i < priv->num_grps; i++)
-			free_irq(priv->gfargrp[i].interruptTransmit,
+			free_irq(gfar_irq(&priv->gfargrp[i], TX)->irq,
 				 &priv->gfargrp[i]);
 	}
 
@@ -1856,32 +1886,34 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive
 		 */
-		if ((err = request_irq(grp->interruptError, gfar_error,
-				       0, grp->int_name_er, grp)) < 0) {
+		err = request_irq(gfar_irq(grp, ER)->irq, gfar_error, 0,
+				  gfar_irq(grp, ER)->name, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
-				  grp->interruptError);
+				  gfar_irq(grp, ER)->irq);
 
 			goto err_irq_fail;
 		}
-
-		if ((err = request_irq(grp->interruptTransmit, gfar_transmit,
-				       0, grp->int_name_tx, grp)) < 0) {
+		err = request_irq(gfar_irq(grp, TX)->irq, gfar_transmit, 0,
+				  gfar_irq(grp, TX)->name, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
-				  grp->interruptTransmit);
+				  gfar_irq(grp, TX)->irq);
 			goto tx_irq_fail;
 		}
-
-		if ((err = request_irq(grp->interruptReceive, gfar_receive,
-				       0, grp->int_name_rx, grp)) < 0) {
+		err = request_irq(gfar_irq(grp, RX)->irq, gfar_receive, 0,
+				  gfar_irq(grp, RX)->name, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
-				  grp->interruptReceive);
+				  gfar_irq(grp, RX)->irq);
 			goto rx_irq_fail;
 		}
 	} else {
-		if ((err = request_irq(grp->interruptTransmit, gfar_interrupt,
-				       0, grp->int_name_tx, grp)) < 0) {
+		err = request_irq(gfar_irq(grp, TX)->irq, gfar_interrupt, 0,
+				  gfar_irq(grp, TX)->name, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
-				  grp->interruptTransmit);
+				  gfar_irq(grp, TX)->irq);
 			goto err_irq_fail;
 		}
 	}
@@ -1889,9 +1921,9 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 	return 0;
 
 rx_irq_fail:
-	free_irq(grp->interruptTransmit, grp);
+	free_irq(gfar_irq(grp, TX)->irq, grp);
 tx_irq_fail:
-	free_irq(grp->interruptError, grp);
+	free_irq(gfar_irq(grp, ER)->irq, grp);
 err_irq_fail:
 	return err;
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 045c0d2..71793f4 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -996,18 +996,25 @@ struct gfar_priv_rx_q {
 	unsigned long rxic;
 };
 
+enum gfar_irqinfo_id {
+	GFAR_TX = 0,
+	GFAR_RX = 1,
+	GFAR_ER = 2,
+	GFAR_NUM_IRQS = 3
+};
+
+struct gfar_irqinfo {
+	unsigned int irq;
+	char name[GFAR_INT_NAME_MAX];
+};
+
 /**
  *	struct gfar_priv_grp - per group structure
  *	@napi: the napi poll function
  *	@priv: back pointer to the priv structure
  *	@regs: the ioremapped register space for this group
  *	@grp_id: group id for this group
- *	@interruptTransmit: The TX interrupt number for this group
- *	@interruptReceive: The RX interrupt number for this group
- *	@interruptError: The ERROR interrupt number for this group
- *	@int_name_tx: tx interrupt name for this group
- *	@int_name_rx: rx interrupt name for this group
- *	@int_name_er: er interrupt name for this group
+ *	@irqinfo: TX/RX/ER irq data for this group
  */
 
 struct gfar_priv_grp {
@@ -1016,23 +1023,20 @@ struct gfar_priv_grp {
 	struct gfar_private *priv;
 	struct gfar __iomem *regs;
 	unsigned int grp_id;
-	unsigned long rx_bit_map;
-	unsigned long tx_bit_map;
-	unsigned long num_tx_queues;
 	unsigned long num_rx_queues;
+	unsigned long rx_bit_map;
+	/* cacheline 3 */
 	unsigned int rstat;
 	unsigned int tstat;
-	unsigned int imask;
-	unsigned int ievent;
-	unsigned int interruptTransmit;
-	unsigned int interruptReceive;
-	unsigned int interruptError;
-
-	char int_name_tx[GFAR_INT_NAME_MAX];
-	char int_name_rx[GFAR_INT_NAME_MAX];
-	char int_name_er[GFAR_INT_NAME_MAX];
+	unsigned long num_tx_queues;
+	unsigned long tx_bit_map;
+
+	struct gfar_irqinfo *irqinfo[GFAR_NUM_IRQS];
 };
 
+#define gfar_irq(grp, ID) \
+	((grp)->irqinfo[GFAR_##ID])
+
 enum gfar_errata {
 	GFAR_ERRATA_74		= 0x01,
 	GFAR_ERRATA_76		= 0x02,
-- 
1.6.6
