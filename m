From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH/RFC net-next] ravb: Add dma queue interrupt support
Date: Tue, 15 Dec 2015 21:23:01 +0900
Message-ID: <1450182181-12575-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33132 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbbLOMZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 07:25:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

This patch supports the following interrupts.

- One interrupt for multiple (descriptor, error, management)
- One interrupt for emac
- Four interrupts for dma queue (best effort rx/tx, network control rx/tx)

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's next networking
tree.

 drivers/net/ethernet/renesas/ravb.h      |  34 +++++
 drivers/net/ethernet/renesas/ravb_main.c | 248 +++++++++++++++++++++++++++----
 drivers/net/ethernet/renesas/ravb_ptp.c  |  42 ++++--
 3 files changed, 283 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index 9fbe92a..eada5a1 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -157,6 +157,7 @@ enum ravb_reg {
 	TIC	= 0x0378,
 	TIS	= 0x037C,
 	ISS	= 0x0380,
+	CIE	= 0x0384,
 	GCCR	= 0x0390,
 	GMTT	= 0x0394,
 	GPTC	= 0x0398,
@@ -170,6 +171,15 @@ enum ravb_reg {
 	GCT0	= 0x03B8,
 	GCT1	= 0x03BC,
 	GCT2	= 0x03C0,
+	GIE	= 0x03CC,
+	GID	= 0x03D0,
+	DIL	= 0x0440,
+	RIE0	= 0x0460,
+	RID0	= 0x0464,
+	RIE2	= 0x0470,
+	RID2	= 0x0474,
+	TIE	= 0x0478,
+	TID	= 0x047c,
 
 	/* E-MAC registers */
 	ECMR	= 0x0500,
@@ -556,6 +566,16 @@ enum ISS_BIT {
 	ISS_DPS15	= 0x80000000,
 };
 
+/* CIE */
+enum CIE_BIT {
+	CIE_CRIE	= 0x00000001, /* Common Receive Interrupt Enable */
+	CIE_CTIE	= 0x00000100, /* Common Transmit Interrupt Enable */
+	CIE_RQFM	= 0x00010000, /* Reception Queue Full Mode */
+	CIE_CL0M	= 0x00020000, /* Common Line 0 Mode */
+	CIE_RFWL	= 0x00040000, /* Rx-FIFO Warning interrupt Line */
+	CIE_RFFL	= 0x00080000, /* Rx-FIFO Full interrupt Line */
+};
+
 /* GCCR */
 enum GCCR_BIT {
 	GCCR_TCR	= 0x00000003,
@@ -592,6 +612,18 @@ enum GIS_BIT {
 	GIS_PTMF	= 0x00000004,
 };
 
+/* GIx */
+#define RAVB_GIx_ALL	0xffff03ff
+
+/* RIx0 */
+#define RAVB_RIx0_ALL	0x0003ffff
+
+/* RIx2 */
+#define RAVB_RIx2_ALL	0x8003ffff
+
+/* TIx */
+#define RAVB_TIx_ALL	0x000fffff
+
 /* ECMR */
 enum ECMR_BIT {
 	ECMR_PRM	= 0x00000001,
@@ -817,6 +849,8 @@ struct ravb_private {
 	int duplex;
 	int emac_irq;
 	enum ravb_chip_id chip_id;
+	int rx_irqs[NUM_RX_QUEUE];
+	int tx_irqs[NUM_TX_QUEUE];
 
 	unsigned no_avb_link:1;
 	unsigned avb_link_active_low:1;
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 120cc25..753b67d 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -42,6 +42,16 @@
 		 NETIF_MSG_RX_ERR | \
 		 NETIF_MSG_TX_ERR)
 
+static const char *ravb_rx_irqs[NUM_RX_QUEUE] = {
+	"ch0", /* RAVB_BE */
+	"ch1", /* RAVB_NC */
+};
+
+static const char *ravb_tx_irqs[NUM_TX_QUEUE] = {
+	"ch18", /* RAVB_BE */
+	"ch19", /* RAVB_NC */
+};
+
 int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value)
 {
 	int i;
@@ -376,6 +386,7 @@ static void ravb_emac_init(struct net_device *ndev)
 static int ravb_dmac_init(struct net_device *ndev)
 {
 	int error;
+	struct ravb_private *priv = netdev_priv(ndev);
 
 	/* Set CONFIG mode */
 	error = ravb_config(ndev);
@@ -411,14 +422,28 @@ static int ravb_dmac_init(struct net_device *ndev)
 	ravb_write(ndev, TCCR_TFEN, TCCR);
 
 	/* Interrupt init: */
-	/* Frame receive */
-	ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
-	/* Disable FIFO full warning */
-	ravb_write(ndev, 0, RIC1);
-	/* Receive FIFO full error, descriptor empty */
-	ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
-	/* Frame transmitted, timestamp FIFO updated */
-	ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
+	if (priv->chip_id == RCAR_GEN2) {
+		/* Frame receive */
+		ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
+		/* Disable FIFO full warning */
+		ravb_write(ndev, 0, RIC1);
+		/* Receive FIFO full error, descriptor empty */
+		ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
+		/* Frame transmitted, timestamp FIFO updated */
+		ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
+	} else {
+		/* Clear CIE.CTIE, CIE.CRIE, DIL.DPLx */
+		ravb_write(ndev, 0, CIE);
+		ravb_write(ndev, 0, DIL);
+		/* Set queue specific interrupt */
+		ravb_write(ndev, CIE_CRIE | CIE_CTIE | CIE_CL0M, CIE);
+		/* Frame receive */
+		ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIE0);
+		/* Receive FIFO full error, descriptor empty */
+		ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIE2);
+		/* Frame transmitted, timestamp FIFO updated */
+		ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIE);
+	}
 
 	/* Setting the control will start the AVB-DMAC process. */
 	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) | CCC_OPC_OPERATION,
@@ -654,7 +679,7 @@ static int ravb_stop_dma(struct net_device *ndev)
 }
 
 /* E-MAC interrupt handler */
-static void ravb_emac_interrupt(struct net_device *ndev)
+static void _ravb_emac_interrupt(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	u32 ecsr, psr;
@@ -680,6 +705,18 @@ static void ravb_emac_interrupt(struct net_device *ndev)
 	}
 }
 
+static irqreturn_t ravb_emac_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	spin_lock(&priv->lock);
+	_ravb_emac_interrupt(ndev);
+	mmiowb();
+	spin_unlock(&priv->lock);
+	return IRQ_HANDLED;
+}
+
 /* Error interrupt handler */
 static void ravb_error_interrupt(struct net_device *ndev)
 {
@@ -690,7 +727,10 @@ static void ravb_error_interrupt(struct net_device *ndev)
 	ravb_write(ndev, ~EIS_QFS, EIS);
 	if (eis & EIS_QFS) {
 		ris2 = ravb_read(ndev, RIS2);
-		ravb_write(ndev, ~(RIS2_QFF0 | RIS2_RFFF), RIS2);
+		if (priv->chip_id == RCAR_GEN2)
+			ravb_write(ndev, ~(RIS2_QFF0 | RIS2_RFFF), RIS2);
+		else
+			ravb_write(ndev, RIS2_QFF0 | RIS2_RFFF, RID2);
 
 		/* Receive Descriptor Empty int */
 		if (ris2 & RIS2_QFF0)
@@ -758,16 +798,43 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
 
 	/* E-MAC status summary */
 	if (iss & ISS_MS) {
-		ravb_emac_interrupt(ndev);
+		_ravb_emac_interrupt(ndev);
+		result = IRQ_HANDLED;
+	}
+
+	/* Error status summary */
+	if (iss & ISS_ES) {
+		ravb_error_interrupt(ndev);
 		result = IRQ_HANDLED;
 	}
 
+	if (iss & ISS_CGIS)
+		result = ravb_ptp_interrupt(ndev);
+
+	mmiowb();
+	spin_unlock(&priv->lock);
+	return result;
+}
+
+/* Descriptor IRQ/ Error/ Management interrupt handler */
+static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct ravb_private *priv = netdev_priv(ndev);
+	irqreturn_t result = IRQ_NONE;
+	u32 iss;
+
+	spin_lock(&priv->lock);
+	/* Get interrupt status */
+	iss = ravb_read(ndev, ISS);
+
 	/* Error status summary */
 	if (iss & ISS_ES) {
 		ravb_error_interrupt(ndev);
 		result = IRQ_HANDLED;
 	}
 
+	/* Management */
 	if (iss & ISS_CGIS)
 		result = ravb_ptp_interrupt(ndev);
 
@@ -776,6 +843,55 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
 	return result;
 }
 
+static irqreturn_t ravb_dmaq_interrupt(int irq, void *dev_id, int ravb_queue)
+{
+	struct net_device *ndev = dev_id;
+	struct ravb_private *priv = netdev_priv(ndev);
+	irqreturn_t result = IRQ_NONE;
+	u32 ris0, ric0, tis, tic;
+	int q = ravb_queue;
+
+	spin_lock(&priv->lock);
+
+	ris0 = ravb_read(ndev, RIS0);
+	ric0 = ravb_read(ndev, RIC0);
+	tis  = ravb_read(ndev, TIS);
+	tic  = ravb_read(ndev, TIC);
+
+	/* Timestamp updated */
+	if (tis & TIS_TFUF) {
+		ravb_write(ndev, TIS_TFUF, TID);
+		ravb_get_tx_tstamp(ndev);
+		result = IRQ_HANDLED;
+	}
+
+	/* Best effort queue RX/TX */
+	if (((ris0 & ric0) & BIT(q)) ||
+	    ((tis  & tic)  & BIT(q))) {
+		if (napi_schedule_prep(&priv->napi[q])) {
+			/* Mask RX and TX interrupts */
+			ravb_write(ndev, BIT(q), RID0);
+			ravb_write(ndev, BIT(q), TID);
+			__napi_schedule(&priv->napi[q]);
+		}
+		result = IRQ_HANDLED;
+	}
+
+	mmiowb();
+	spin_unlock(&priv->lock);
+	return result;
+}
+
+static irqreturn_t ravb_be_interrupt(int irq, void *dev_id)
+{
+	return ravb_dmaq_interrupt(irq, dev_id, RAVB_BE);
+}
+
+static irqreturn_t ravb_nc_interrupt(int irq, void *dev_id)
+{
+	return ravb_dmaq_interrupt(irq, dev_id, RAVB_NC);
+}
+
 static int ravb_poll(struct napi_struct *napi, int budget)
 {
 	struct net_device *ndev = napi->dev;
@@ -815,8 +931,13 @@ static int ravb_poll(struct napi_struct *napi, int budget)
 
 	/* Re-enable RX/TX interrupts */
 	spin_lock_irqsave(&priv->lock, flags);
-	ravb_write(ndev, ravb_read(ndev, RIC0) | mask, RIC0);
-	ravb_write(ndev, ravb_read(ndev, TIC)  | mask,  TIC);
+	if (priv->chip_id == RCAR_GEN2) {
+		ravb_write(ndev, ravb_read(ndev, RIC0) | mask, RIC0);
+		ravb_write(ndev, ravb_read(ndev, TIC)  | mask,  TIC);
+	} else {
+		ravb_write(ndev, mask, RIE0);
+		ravb_write(ndev, mask, TIE);
+	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -1208,23 +1329,68 @@ static const struct ethtool_ops ravb_ethtool_ops = {
 static int ravb_open(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-	int error;
+	int error, i;
+	struct platform_device *pdev = priv->pdev;
+	struct device *dev = &pdev->dev;
+	char *name;
 
 	napi_enable(&priv->napi[RAVB_BE]);
 	napi_enable(&priv->napi[RAVB_NC]);
 
-	error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED, ndev->name,
-			    ndev);
-	if (error) {
-		netdev_err(ndev, "cannot request IRQ\n");
-		goto out_napi_off;
-	}
-
-	if (priv->chip_id == RCAR_GEN3) {
-		error = request_irq(priv->emac_irq, ravb_interrupt,
-				    IRQF_SHARED, ndev->name, ndev);
+	if (priv->chip_id == RCAR_GEN2) {
+		error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED,
+				    ndev->name, ndev);
 		if (error) {
 			netdev_err(ndev, "cannot request IRQ\n");
+			goto out_napi_off;
+		}
+	} else {
+		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch22:multi",
+				      ndev->name);
+		error = request_irq(ndev->irq, ravb_multi_interrupt,
+				    IRQF_SHARED, name, ndev);
+		if (error) {
+			netdev_err(ndev, "cannot request IRQ %s\n", name);
+			goto out_napi_off;
+		}
+		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch24:emac",
+				      ndev->name);
+		error = request_irq(priv->emac_irq, ravb_emac_interrupt,
+				    IRQF_SHARED, name, ndev);
+		if (error) {
+			netdev_err(ndev, "cannot request IRQ %s\n", name);
+			goto out_free_irq;
+		}
+		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch0:rx_be",
+				      ndev->name);
+		error = request_irq(priv->rx_irqs[RAVB_BE], ravb_be_interrupt,
+				    IRQF_SHARED, name, ndev);
+		if (error) {
+			netdev_err(ndev, "cannot request IRQ %s\n", name);
+			goto out_free_irq;
+		}
+		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch18:tx_be",
+				      ndev->name);
+		error = request_irq(priv->tx_irqs[RAVB_BE], ravb_be_interrupt,
+				    IRQF_SHARED, name, ndev);
+		if (error) {
+			netdev_err(ndev, "cannot request IRQ %s\n", name);
+			goto out_free_irq;
+		}
+		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch1:rx_nc",
+				      ndev->name);
+		error = request_irq(priv->rx_irqs[RAVB_NC], ravb_nc_interrupt,
+				    IRQF_SHARED, name, ndev);
+		if (error) {
+			netdev_err(ndev, "cannot request IRQ %s\n", name);
+			goto out_free_irq;
+		}
+		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch19:tx_nc",
+				      ndev->name);
+		error = request_irq(priv->tx_irqs[RAVB_NC], ravb_nc_interrupt,
+				    IRQF_SHARED, name, ndev);
+		if (error) {
+			netdev_err(ndev, "cannot request IRQ %s\n", name);
 			goto out_free_irq;
 		}
 	}
@@ -1257,6 +1423,10 @@ out_free_irq2:
 		free_irq(priv->emac_irq, ndev);
 out_free_irq:
 	free_irq(ndev->irq, ndev);
+	for (i = 0; i < NUM_RX_QUEUE; i++)
+		free_irq(priv->rx_irqs[i], ndev);
+	for (i = 0; i < NUM_TX_QUEUE; i++)
+		free_irq(priv->tx_irqs[i], ndev);
 out_napi_off:
 	napi_disable(&priv->napi[RAVB_NC]);
 	napi_disable(&priv->napi[RAVB_BE]);
@@ -1479,10 +1649,15 @@ static int ravb_close(struct net_device *ndev)
 	netif_tx_stop_all_queues(ndev);
 
 	/* Disable interrupts by clearing the interrupt masks. */
-	ravb_write(ndev, 0, RIC0);
-	ravb_write(ndev, 0, RIC2);
-	ravb_write(ndev, 0, TIC);
-
+	if (priv->chip_id == RCAR_GEN2) {
+		ravb_write(ndev, 0, RIC0);
+		ravb_write(ndev, 0, RIC2);
+		ravb_write(ndev, 0, TIC);
+	} else {
+		ravb_write(ndev, RAVB_RIx0_ALL, RID0);
+		ravb_write(ndev, RAVB_RIx2_ALL, RID2);
+		ravb_write(ndev, RAVB_TIx_ALL, TID);
+	}
 	/* Stop PTP Clock driver */
 	if (priv->chip_id == RCAR_GEN2)
 		ravb_ptp_stop(ndev);
@@ -1713,6 +1888,7 @@ static int ravb_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	int error, irq, q;
 	struct resource *res;
+	int i;
 
 	if (!np) {
 		dev_err(&pdev->dev,
@@ -1783,6 +1959,22 @@ static int ravb_probe(struct platform_device *pdev)
 			goto out_release;
 		}
 		priv->emac_irq = irq;
+		for (i = 0; i < NUM_RX_QUEUE; i++) {
+			irq = platform_get_irq_byname(pdev, ravb_rx_irqs[i]);
+			if (irq < 0) {
+				error = irq;
+				goto out_release;
+			}
+			priv->rx_irqs[i] = irq;
+		}
+		for (i = 0; i < NUM_TX_QUEUE; i++) {
+			irq = platform_get_irq_byname(pdev, ravb_tx_irqs[i]);
+			if (irq < 0) {
+				error = irq;
+				goto out_release;
+			}
+			priv->tx_irqs[i] = irq;
+		}
 	}
 
 	priv->chip_id = chip_id;
diff --git a/drivers/net/ethernet/renesas/ravb_ptp.c b/drivers/net/ethernet/renesas/ravb_ptp.c
index 7a8ce92..a789c7c 100644
--- a/drivers/net/ethernet/renesas/ravb_ptp.c
+++ b/drivers/net/ethernet/renesas/ravb_ptp.c
@@ -196,11 +196,15 @@ static int ravb_ptp_extts(struct ptp_clock_info *ptp,
 
 	spin_lock_irqsave(&priv->lock, flags);
 	gic = ravb_read(ndev, GIC);
-	if (on)
-		gic |= GIC_PTCE;
-	else
-		gic &= ~GIC_PTCE;
-	ravb_write(ndev, gic, GIC);
+	if (priv->chip_id == RCAR_GEN2) {
+		if (on)
+			gic |= GIC_PTCE;
+		else
+			gic &= ~GIC_PTCE;
+		ravb_write(ndev, gic, GIC);
+	} else {
+		ravb_write(ndev, GIC_PTCE, (on) ? GIE : GID);
+	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -216,7 +220,7 @@ static int ravb_ptp_perout(struct ptp_clock_info *ptp,
 	struct ravb_ptp_perout *perout;
 	unsigned long flags;
 	int error = 0;
-	u32 gic;
+	u32 gic = 0;
 
 	if (req->index)
 		return -EINVAL;
@@ -248,9 +252,13 @@ static int ravb_ptp_perout(struct ptp_clock_info *ptp,
 		error = ravb_ptp_update_compare(priv, (u32)start_ns);
 		if (!error) {
 			/* Unmask interrupt */
-			gic = ravb_read(ndev, GIC);
-			gic |= GIC_PTME;
-			ravb_write(ndev, gic, GIC);
+			if (priv->chip_id == RCAR_GEN2) {
+				gic = ravb_read(ndev, GIC);
+				gic |= GIC_PTME;
+				ravb_write(ndev, gic, GIC);
+			} else {
+				ravb_write(ndev, GIC_PTME, GIE);
+			}
 		}
 	} else	{
 		spin_lock_irqsave(&priv->lock, flags);
@@ -259,9 +267,13 @@ static int ravb_ptp_perout(struct ptp_clock_info *ptp,
 		perout->period = 0;
 
 		/* Mask interrupt */
-		gic = ravb_read(ndev, GIC);
-		gic &= ~GIC_PTME;
-		ravb_write(ndev, gic, GIC);
+		if (priv->chip_id == RCAR_GEN2) {
+			gic = ravb_read(ndev, GIC);
+			gic &= ~GIC_PTME;
+			ravb_write(ndev, gic, GIC);
+		} else {
+			ravb_write(ndev, GIC_PTME, GID);
+		}
 	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -352,7 +364,11 @@ void ravb_ptp_stop(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 
-	ravb_write(ndev, 0, GIC);
+	if (priv->chip_id == RCAR_GEN2)
+		ravb_write(ndev, 0, GIC);
+	else
+		ravb_write(ndev, RAVB_GIx_ALL, GID);
+
 	ravb_write(ndev, 0, GIS);
 
 	ptp_clock_unregister(priv->ptp.clock);
-- 
1.9.1
