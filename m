From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 1/2] ravb: factor out register bit twiddling code
Date: Wed, 10 Feb 2016 01:37:44 +0300
Message-ID: <3447960.Sfp8MfyPX3@wasted.cogentembedded.com>
References: <2107757.v1oGBJ7aiG@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2107757.v1oGBJ7aiG@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The  driver has often repeated pattern of reading a register,  AND'ing and/or
OR'ing some bits  and writing  the  value back. Factor the pattern out into
ravb_modify() -- this saves 260 bytes of code with ARM gcc 4.7.3.

While at it, update Cogent Embedded's copyrights.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 2:
- renamed ravb_modify()'s parameters.

 drivers/net/ethernet/renesas/ravb.h      |    4 +
 drivers/net/ethernet/renesas/ravb_main.c |   68 ++++++++++++-------------------
 drivers/net/ethernet/renesas/ravb_ptp.c  |   25 ++---------
 3 files changed, 36 insertions(+), 61 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/ravb.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb.h
+++ net-next/drivers/net/ethernet/renesas/ravb.h
@@ -2,7 +2,7 @@
  *
  * Copyright (C) 2014-2015 Renesas Electronics Corporation
  * Copyright (C) 2015 Renesas Solutions Corp.
- * Copyright (C) 2015 Cogent Embedded, Inc. <source@cogentembedded.com>
+ * Copyright (C) 2015-2016 Cogent Embedded, Inc. <source@cogentembedded.com>
  *
  * Based on the SuperH Ethernet driver
  *
@@ -837,6 +837,8 @@ static inline void ravb_write(struct net
 	iowrite32(data, priv->addr + reg);
 }
 
+void ravb_modify(struct net_device *ndev, enum ravb_reg reg, u32 clear,
+		 u32 set);
 int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value);
 
 irqreturn_t ravb_ptp_interrupt(struct net_device *ndev);
Index: net-next/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net-next/drivers/net/ethernet/renesas/ravb_main.c
@@ -2,7 +2,7 @@
  *
  * Copyright (C) 2014-2015 Renesas Electronics Corporation
  * Copyright (C) 2015 Renesas Solutions Corp.
- * Copyright (C) 2015 Cogent Embedded, Inc. <source@cogentembedded.com>
+ * Copyright (C) 2015-2016 Cogent Embedded, Inc. <source@cogentembedded.com>
  *
  * Based on the SuperH Ethernet driver
  *
@@ -42,6 +42,12 @@
 		 NETIF_MSG_RX_ERR | \
 		 NETIF_MSG_TX_ERR)
 
+void ravb_modify(struct net_device *ndev, enum ravb_reg reg, u32 clear,
+		 u32 set)
+{
+	ravb_write(ndev, (ravb_read(ndev, reg) & ~clear) | set, reg);
+}
+
 int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value)
 {
 	int i;
@@ -59,8 +65,7 @@ static int ravb_config(struct net_device
 	int error;
 
 	/* Set config mode */
-	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) | CCC_OPC_CONFIG,
-		   CCC);
+	ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_CONFIG);
 	/* Check if the operating mode is changed to the config mode */
 	error = ravb_wait(ndev, CSR, CSR_OPS, CSR_OPS_CONFIG);
 	if (error)
@@ -72,13 +77,8 @@ static int ravb_config(struct net_device
 static void ravb_set_duplex(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-	u32 ecmr = ravb_read(ndev, ECMR);
 
-	if (priv->duplex)	/* Full */
-		ecmr |=  ECMR_DM;
-	else			/* Half */
-		ecmr &= ~ECMR_DM;
-	ravb_write(ndev, ecmr, ECMR);
+	ravb_modify(ndev, ECMR, ECMR_DM, priv->duplex ? ECMR_DM : 0);
 }
 
 static void ravb_set_rate(struct net_device *ndev)
@@ -131,13 +131,8 @@ static void ravb_mdio_ctrl(struct mdiobb
 {
 	struct ravb_private *priv = container_of(ctrl, struct ravb_private,
 						 mdiobb);
-	u32 pir = ravb_read(priv->ndev, PIR);
 
-	if (set)
-		pir |=  mask;
-	else
-		pir &= ~mask;
-	ravb_write(priv->ndev, pir, PIR);
+	ravb_modify(priv->ndev, PIR, mask, set ? mask : 0);
 }
 
 /* MDC pin control */
@@ -393,9 +388,9 @@ static int ravb_dmac_init(struct net_dev
 	ravb_ring_format(ndev, RAVB_NC);
 
 #if defined(__LITTLE_ENDIAN)
-	ravb_write(ndev, ravb_read(ndev, CCC) & ~CCC_BOC, CCC);
+	ravb_modify(ndev, CCC, CCC_BOC, 0);
 #else
-	ravb_write(ndev, ravb_read(ndev, CCC) | CCC_BOC, CCC);
+	ravb_modify(ndev, CCC, CCC_BOC, CCC_BOC);
 #endif
 
 	/* Set AVB RX */
@@ -418,8 +413,7 @@ static int ravb_dmac_init(struct net_dev
 	ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
 
 	/* Setting the control will start the AVB-DMAC process. */
-	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) | CCC_OPC_OPERATION,
-		   CCC);
+	ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_OPERATION);
 
 	return 0;
 }
@@ -493,7 +487,7 @@ static void ravb_get_tx_tstamp(struct ne
 				break;
 			}
 		}
-		ravb_write(ndev, ravb_read(ndev, TCCR) | TCCR_TFR, TCCR);
+		ravb_modify(ndev, TCCR, TCCR_TFR, TCCR_TFR);
 	}
 }
 
@@ -613,13 +607,13 @@ static bool ravb_rx(struct net_device *n
 static void ravb_rcv_snd_disable(struct net_device *ndev)
 {
 	/* Disable TX and RX */
-	ravb_write(ndev, ravb_read(ndev, ECMR) & ~(ECMR_RE | ECMR_TE), ECMR);
+	ravb_modify(ndev, ECMR, ECMR_RE | ECMR_TE, 0);
 }
 
 static void ravb_rcv_snd_enable(struct net_device *ndev)
 {
 	/* Enable TX and RX */
-	ravb_write(ndev, ravb_read(ndev, ECMR) | ECMR_RE | ECMR_TE, ECMR);
+	ravb_modify(ndev, ECMR, ECMR_RE | ECMR_TE, ECMR_RE | ECMR_TE);
 }
 
 /* function for waiting dma process finished */
@@ -812,8 +806,8 @@ static int ravb_poll(struct napi_struct
 
 	/* Re-enable RX/TX interrupts */
 	spin_lock_irqsave(&priv->lock, flags);
-	ravb_write(ndev, ravb_read(ndev, RIC0) | mask, RIC0);
-	ravb_write(ndev, ravb_read(ndev, TIC)  | mask,  TIC);
+	ravb_modify(ndev, RIC0, mask, mask);
+	ravb_modify(ndev, TIC,  mask, mask);
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -852,8 +846,7 @@ static void ravb_adjust_link(struct net_
 			ravb_set_rate(ndev);
 		}
 		if (!priv->link) {
-			ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_TXF,
-				   ECMR);
+			ravb_modify(ndev, ECMR, ECMR_TXF, 0);
 			new_state = true;
 			priv->link = phydev->link;
 			if (priv->no_avb_link)
@@ -1393,7 +1386,7 @@ static netdev_tx_t ravb_start_xmit(struc
 	desc--;
 	desc->die_dt = DT_FSTART;
 
-	ravb_write(ndev, ravb_read(ndev, TCCR) | (TCCR_TSRQ0 << q), TCCR);
+	ravb_modify(ndev, TCCR, TCCR_TSRQ0 << q, TCCR_TSRQ0 << q);
 
 	priv->cur_tx[q] += NUM_TX_DESC;
 	if (priv->cur_tx[q] - priv->dirty_tx[q] >
@@ -1468,15 +1461,10 @@ static void ravb_set_rx_mode(struct net_
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	unsigned long flags;
-	u32 ecmr;
 
 	spin_lock_irqsave(&priv->lock, flags);
-	ecmr = ravb_read(ndev, ECMR);
-	if (ndev->flags & IFF_PROMISC)
-		ecmr |=  ECMR_PRM;
-	else
-		ecmr &= ~ECMR_PRM;
-	ravb_write(ndev, ecmr, ECMR);
+	ravb_modify(ndev, ECMR, ECMR_PRM,
+		    ndev->flags & IFF_PROMISC ? ECMR_PRM : 0);
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
@@ -1804,14 +1792,12 @@ static int ravb_probe(struct platform_de
 
 	/* Set AVB config mode */
 	if (chip_id == RCAR_GEN2) {
-		ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) |
-			   CCC_OPC_CONFIG, CCC);
+		ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_CONFIG);
 		/* Set CSEL value */
-		ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_CSEL) |
-			   CCC_CSEL_HPB, CCC);
+		ravb_modify(ndev, CCC, CCC_CSEL, CCC_CSEL_HPB);
 	} else {
-		ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) |
-			   CCC_OPC_CONFIG | CCC_GAC | CCC_CSEL_HPB, CCC);
+		ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_CONFIG |
+			    CCC_GAC | CCC_CSEL_HPB);
 	}
 
 	/* Set CSEL value */
@@ -1824,7 +1810,7 @@ static int ravb_probe(struct platform_de
 		goto out_release;
 
 	/* Request GTI loading */
-	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LTI, GCCR);
+	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
 
 	/* Allocate descriptor base address table */
 	priv->desc_bat_size = sizeof(struct ravb_desc) * DBAT_ENTRY_NUM;
Index: net-next/drivers/net/ethernet/renesas/ravb_ptp.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb_ptp.c
+++ net-next/drivers/net/ethernet/renesas/ravb_ptp.c
@@ -2,7 +2,7 @@
  *
  * Copyright (C) 2013-2015 Renesas Electronics Corporation
  * Copyright (C) 2015 Renesas Solutions Corp.
- * Copyright (C) 2015 Cogent Embedded, Inc. <source@cogentembedded.com>
+ * Copyright (C) 2015-2016 Cogent Embedded, Inc. <source@cogentembedded.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -21,7 +21,7 @@ static int ravb_ptp_tcr_request(struct r
 	if (error)
 		return error;
 
-	ravb_write(ndev, ravb_read(ndev, GCCR) | request, GCCR);
+	ravb_modify(ndev, GCCR, request, request);
 	return ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
 }
 
@@ -185,7 +185,6 @@ static int ravb_ptp_extts(struct ptp_clo
 						 ptp.info);
 	struct net_device *ndev = priv->ndev;
 	unsigned long flags;
-	u32 gic;
 
 	if (req->index)
 		return -EINVAL;
@@ -195,12 +194,7 @@ static int ravb_ptp_extts(struct ptp_clo
 	priv->ptp.extts[req->index] = on;
 
 	spin_lock_irqsave(&priv->lock, flags);
-	gic = ravb_read(ndev, GIC);
-	if (on)
-		gic |= GIC_PTCE;
-	else
-		gic &= ~GIC_PTCE;
-	ravb_write(ndev, gic, GIC);
+	ravb_modify(ndev, GIC, GIC_PTCE, on ? GIC_PTCE : 0);
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -216,7 +210,6 @@ static int ravb_ptp_perout(struct ptp_cl
 	struct ravb_ptp_perout *perout;
 	unsigned long flags;
 	int error = 0;
-	u32 gic;
 
 	if (req->index)
 		return -EINVAL;
@@ -248,9 +241,7 @@ static int ravb_ptp_perout(struct ptp_cl
 		error = ravb_ptp_update_compare(priv, (u32)start_ns);
 		if (!error) {
 			/* Unmask interrupt */
-			gic = ravb_read(ndev, GIC);
-			gic |= GIC_PTME;
-			ravb_write(ndev, gic, GIC);
+			ravb_modify(ndev, GIC, GIC_PTME, GIC_PTME);
 		}
 	} else	{
 		spin_lock_irqsave(&priv->lock, flags);
@@ -259,9 +250,7 @@ static int ravb_ptp_perout(struct ptp_cl
 		perout->period = 0;
 
 		/* Mask interrupt */
-		gic = ravb_read(ndev, GIC);
-		gic &= ~GIC_PTME;
-		ravb_write(ndev, gic, GIC);
+		ravb_modify(ndev, GIC, GIC_PTME, 0);
 	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -331,7 +320,6 @@ void ravb_ptp_init(struct net_device *nd
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	unsigned long flags;
-	u32 gccr;
 
 	priv->ptp.info = ravb_ptp_info;
 
@@ -340,8 +328,7 @@ void ravb_ptp_init(struct net_device *nd
 
 	spin_lock_irqsave(&priv->lock, flags);
 	ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
-	gccr = ravb_read(ndev, GCCR) & ~GCCR_TCSS;
-	ravb_write(ndev, gccr | GCCR_TCSS_ADJGPTP, GCCR);
+	ravb_modify(ndev, GCCR, GCCR_TCSS, GCCR_TCSS_ADJGPTP);
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 
