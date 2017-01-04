From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/3] sh_eth: factor out sh_eth_emac_interrupt()
Date: Wed, 04 Jan 2017 15:11:21 +0300
Message-ID: <2316251.zKWDf5AMHG@wasted.cogentembedded.com>
References: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35877 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753735AbdADMLZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 07:11:25 -0500
Received: by mail-lf0-f50.google.com with SMTP id x140so6190408lfa.3
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 04:11:24 -0800 (PST)
In-Reply-To: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The E-MAC interrupt (EESR.ECI) is not always caused  by an error condition,
so  it really shouldn't be handled by sh_eth_error(). Factor out the E-MAC
interrupt handler, sh_eth_emac_interrupt(),  removing the ECI bit from the
EESR's values throughout the driver...

Update Cogent Embedded's copyright and clean up the whitespace in Renesas'
copyright, while at it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |  102 +++++++++++++++++-----------------
 drivers/net/ethernet/renesas/sh_eth.h |    2 
 2 files changed, 53 insertions(+), 51 deletions(-)

Index: renesas/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- renesas.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ renesas/drivers/net/ethernet/renesas/sh_eth.c
@@ -1,9 +1,9 @@
 /*  SuperH Ethernet device driver
  *
- *  Copyright (C) 2014  Renesas Electronics Corporation
+ *  Copyright (C) 2014 Renesas Electronics Corporation
  *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2014 Renesas Solutions Corp.
- *  Copyright (C) 2013-2016 Cogent Embedded, Inc.
+ *  Copyright (C) 2013-2017 Cogent Embedded, Inc.
  *  Copyright (C) 2014 Codethink Limited
  *
  *  This program is free software; you can redistribute it and/or modify it
@@ -523,7 +523,7 @@ static struct sh_eth_cpu_data r7s72100_d
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
-			  EESR_TDE | EESR_ECI,
+			  EESR_TDE,
 	.fdr_value	= 0x0000070f,
 
 	.no_psr		= 1,
@@ -562,7 +562,7 @@ static struct sh_eth_cpu_data r8a7740_da
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
-			  EESR_TDE | EESR_ECI,
+			  EESR_TDE,
 	.fdr_value	= 0x0000070f,
 
 	.apr		= 1,
@@ -607,8 +607,7 @@ static struct sh_eth_cpu_data r8a777x_da
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
-			  EESR_ECI,
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE,
 	.fdr_value	= 0x00000f0f,
 
 	.apr		= 1,
@@ -630,8 +629,7 @@ static struct sh_eth_cpu_data r8a779x_da
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
-			  EESR_ECI,
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE,
 	.fdr_value	= 0x00000f0f,
 
 	.trscer_err_mask = DESC_I_RINT8,
@@ -671,8 +669,7 @@ static struct sh_eth_cpu_data sh7724_dat
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
-			  EESR_ECI,
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -707,8 +704,7 @@ static struct sh_eth_cpu_data sh7757_dat
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
-			  EESR_ECI,
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE,
 
 	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
@@ -776,7 +772,7 @@ static struct sh_eth_cpu_data sh7757_dat
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
-			  EESR_TDE | EESR_ECI,
+			  EESR_TDE,
 	.fdr_value	= 0x0000072f,
 
 	.irq_flags	= IRQF_SHARED,
@@ -807,7 +803,7 @@ static struct sh_eth_cpu_data sh7734_dat
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
-			  EESR_TDE | EESR_ECI,
+			  EESR_TDE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -835,8 +831,7 @@ static struct sh_eth_cpu_data sh7763_dat
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
-			  EESR_ECI,
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -1526,43 +1521,44 @@ static void sh_eth_rcv_snd_enable(struct
 	sh_eth_modify(ndev, ECMR, ECMR_RE | ECMR_TE, ECMR_RE | ECMR_TE);
 }
 
-/* error control function */
-static void sh_eth_error(struct net_device *ndev, u32 intr_status)
+/* E-MAC interrupt handler */
+static void sh_eth_emac_interrupt(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	u32 felic_stat;
 	u32 link_stat;
-	u32 mask;
 
-	if (intr_status & EESR_ECI) {
-		felic_stat = sh_eth_read(ndev, ECSR) &
-			     sh_eth_read(ndev, ECSIPR);
-		sh_eth_write(ndev, felic_stat, ECSR);	/* clear int */
-		if (felic_stat & ECSR_ICD)
-			ndev->stats.tx_carrier_errors++;
-		if (felic_stat & ECSR_LCHNG) {
-			/* Link Changed */
-			if (mdp->cd->no_psr || mdp->no_ether_link)
-				goto ignore_link;
-			link_stat = sh_eth_read(ndev, PSR);
-			if (mdp->ether_link_active_low)
-				link_stat = ~link_stat;
-			if (!(link_stat & PHY_ST_LINK)) {
-				sh_eth_rcv_snd_disable(ndev);
-			} else {
-				/* Link Up */
-				sh_eth_modify(ndev, EESIPR, DMAC_M_ECI, 0);
-				/* clear int */
-				sh_eth_modify(ndev, ECSR, 0, 0);
-				sh_eth_modify(ndev, EESIPR, DMAC_M_ECI,
-					      DMAC_M_ECI);
-				/* enable tx and rx */
-				sh_eth_rcv_snd_enable(ndev);
-			}
+	felic_stat = sh_eth_read(ndev, ECSR) & sh_eth_read(ndev, ECSIPR);
+	sh_eth_write(ndev, felic_stat, ECSR);	/* clear int */
+	if (felic_stat & ECSR_ICD)
+		ndev->stats.tx_carrier_errors++;
+	if (felic_stat & ECSR_LCHNG) {
+		/* Link Changed */
+		if (mdp->cd->no_psr || mdp->no_ether_link)
+			return;
+		link_stat = sh_eth_read(ndev, PSR);
+		if (mdp->ether_link_active_low)
+			link_stat = ~link_stat;
+		if (!(link_stat & PHY_ST_LINK)) {
+			sh_eth_rcv_snd_disable(ndev);
+		} else {
+			/* Link Up */
+			sh_eth_modify(ndev, EESIPR, DMAC_M_ECI, 0);
+			/* clear int */
+			sh_eth_modify(ndev, ECSR, 0, 0);
+			sh_eth_modify(ndev, EESIPR, DMAC_M_ECI, DMAC_M_ECI);
+			/* enable tx and rx */
+			sh_eth_rcv_snd_enable(ndev);
 		}
 	}
+}
+
+/* error control function */
+static void sh_eth_error(struct net_device *ndev, u32 intr_status)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 mask;
 
-ignore_link:
 	if (intr_status & EESR_TWB) {
 		/* Unused write back interrupt */
 		if (intr_status & EESR_TABT) {	/* Transmit Abort int */
@@ -1643,14 +1639,16 @@ static irqreturn_t sh_eth_interrupt(int
 
 	/* Get interrupt status */
 	intr_status = sh_eth_read(ndev, EESR);
-	/* Mask it with the interrupt mask, forcing ECI interrupt to be always
-	 * enabled since it's the one that  comes thru regardless of the mask,
-	 * and we need to fully handle it in sh_eth_error() in order to quench
-	 * it as it doesn't get cleared by just writing 1 to the ECI bit...
+	/* Mask it with the interrupt mask, forcing ECI interrupt  to be always
+	 * enabled since it's the one that  comes  thru regardless of the mask,
+	 * and  we need to fully handle it  in sh_eth_emac_interrupt() in order
+	 * to quench it as it doesn't get cleared by just writing 1 to the  ECI
+	 * bit...
 	 */
 	intr_enable = sh_eth_read(ndev, EESIPR);
 	intr_status &= intr_enable | DMAC_M_ECI;
-	if (intr_status & (EESR_RX_CHECK | cd->tx_check | cd->eesr_err_check))
+	if (intr_status & (EESR_RX_CHECK | cd->tx_check | EESR_ECI |
+			   cd->eesr_err_check))
 		ret = IRQ_HANDLED;
 	else
 		goto out;
@@ -1682,6 +1680,10 @@ static irqreturn_t sh_eth_interrupt(int
 		netif_wake_queue(ndev);
 	}
 
+	/* E-MAC interrupt */
+	if (intr_status & EESR_ECI)
+		sh_eth_emac_interrupt(ndev);
+
 	if (intr_status & cd->eesr_err_check) {
 		/* Clear error interrupts */
 		sh_eth_write(ndev, intr_status & cd->eesr_err_check, EESR);
Index: renesas/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- renesas.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ renesas/drivers/net/ethernet/renesas/sh_eth.h
@@ -265,7 +265,7 @@ enum EESR_BIT {
 				 EESR_RTO)
 #define DEFAULT_EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE | \
 				 EESR_RDE | EESR_RFRMER | EESR_ADE | \
-				 EESR_TFE | EESR_TDE | EESR_ECI)
+				 EESR_TFE | EESR_TDE)
 
 /* EESIPR */
 enum DMAC_IM_BIT {
