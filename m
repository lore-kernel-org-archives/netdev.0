From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 9/9] amd-xgbe: Mask auto-negotiation interrupts
 in ISR
Date: Fri, 12 Feb 2016 08:33:44 -0600
Message-ID: <20160212143344.23973.97400.stgit@tlendack-t1.amdoffice.net>
References: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0095.outbound.protection.outlook.com ([65.55.169.95]:24171
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751040AbcBLOsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:48:21 -0500
In-Reply-To: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the auto-negotiation interrupt handling disables the irq
instead of masking off the interrupts. This was done because the phy
library was originally used to read and write the PCS registers, which
could not be performed in interrupt context. Now that the phy library is
no longer used to read and write the PCS registers the interrupts can be
masked off in the interrupt service routine eliminating the need to call
disable_irq/enable_irq. This also requires changing the protection mutex
to a spinlock.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |   10 +++--
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    6 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   53 ++++++++++++++++-------------
 drivers/net/ethernet/amd/xgbe/xgbe.h      |    5 ++-
 4 files changed, 41 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index c41cc50..feb3fdd 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1025,6 +1025,7 @@ static int xgbe_config_rx_mode(struct xgbe_prv_data *pdata)
 static int xgbe_read_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
 			      int mmd_reg)
 {
+	unsigned long flags;
 	unsigned int mmd_address;
 	int mmd_data;
 
@@ -1042,10 +1043,10 @@ static int xgbe_read_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
 	 * register offsets must therefore be adjusted by left shifting the
 	 * offset 2 bits and reading 32 bits of data.
 	 */
-	mutex_lock(&pdata->xpcs_mutex);
+	spin_lock_irqsave(&pdata->xpcs_lock, flags);
 	XPCS_IOWRITE(pdata, PCS_MMD_SELECT << 2, mmd_address >> 8);
 	mmd_data = XPCS_IOREAD(pdata, (mmd_address & 0xff) << 2);
-	mutex_unlock(&pdata->xpcs_mutex);
+	spin_unlock_irqrestore(&pdata->xpcs_lock, flags);
 
 	return mmd_data;
 }
@@ -1054,6 +1055,7 @@ static void xgbe_write_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
 				int mmd_reg, int mmd_data)
 {
 	unsigned int mmd_address;
+	unsigned long flags;
 
 	if (mmd_reg & MII_ADDR_C45)
 		mmd_address = mmd_reg & ~MII_ADDR_C45;
@@ -1069,10 +1071,10 @@ static void xgbe_write_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
 	 * register offsets must therefore be adjusted by left shifting the
 	 * offset 2 bits and reading 32 bits of data.
 	 */
-	mutex_lock(&pdata->xpcs_mutex);
+	spin_lock_irqsave(&pdata->xpcs_lock, flags);
 	XPCS_IOWRITE(pdata, PCS_MMD_SELECT << 2, mmd_address >> 8);
 	XPCS_IOWRITE(pdata, (mmd_address & 0xff) << 2, mmd_data);
-	mutex_unlock(&pdata->xpcs_mutex);
+	spin_unlock_irqrestore(&pdata->xpcs_lock, flags);
 }
 
 static int xgbe_tx_complete(struct xgbe_ring_desc *rdesc)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 618d952..3eee320 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -6,7 +6,7 @@
  *
  * License 1: GPLv2
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  *
  * This file is free software; you may copy, redistribute and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,7 +56,7 @@
  *
  * License 2: Modified BSD
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -363,7 +363,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, netdev);
 
 	spin_lock_init(&pdata->lock);
-	mutex_init(&pdata->xpcs_mutex);
+	spin_lock_init(&pdata->xpcs_lock);
 	mutex_init(&pdata->rss_mutex);
 	spin_lock_init(&pdata->tstamp_lock);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 4460580..84c5d29 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -6,7 +6,7 @@
  *
  * License 1: GPLv2
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  *
  * This file is free software; you may copy, redistribute and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,7 +56,7 @@
  *
  * License 2: Modified BSD
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -626,10 +626,22 @@ static irqreturn_t xgbe_an_isr(int irq, void *data)
 
 	netif_dbg(pdata, intr, pdata->netdev, "AN interrupt received\n");
 
-	/* Interrupt reason must be read and cleared outside of IRQ context */
-	disable_irq_nosync(pdata->an_irq);
+	/* Disable AN interrupts */
+	XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INTMASK, 0);
+
+	/* Save the interrupt(s) that fired */
+	pdata->an_int = XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_INT);
 
-	queue_work(pdata->an_workqueue, &pdata->an_irq_work);
+	if (pdata->an_int) {
+		/* Clear the interrupt(s) that fired and process them */
+		XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INT, ~pdata->an_int);
+
+		queue_work(pdata->an_workqueue, &pdata->an_irq_work);
+	} else {
+		/* Enable AN interrupts */
+		XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INTMASK,
+			    XGBE_AN_INT_MASK);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -673,34 +685,26 @@ static void xgbe_an_state_machine(struct work_struct *work)
 						   struct xgbe_prv_data,
 						   an_work);
 	enum xgbe_an cur_state = pdata->an_state;
-	unsigned int int_reg, int_mask;
 
 	mutex_lock(&pdata->an_mutex);
 
-	/* Read the interrupt */
-	int_reg = XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_INT);
-	if (!int_reg)
+	if (!pdata->an_int)
 		goto out;
 
 next_int:
-	if (int_reg & XGBE_AN_PG_RCV) {
+	if (pdata->an_int & XGBE_AN_PG_RCV) {
 		pdata->an_state = XGBE_AN_PAGE_RECEIVED;
-		int_mask = XGBE_AN_PG_RCV;
-	} else if (int_reg & XGBE_AN_INC_LINK) {
+		pdata->an_int &= ~XGBE_AN_PG_RCV;
+	} else if (pdata->an_int & XGBE_AN_INC_LINK) {
 		pdata->an_state = XGBE_AN_INCOMPAT_LINK;
-		int_mask = XGBE_AN_INC_LINK;
-	} else if (int_reg & XGBE_AN_INT_CMPLT) {
+		pdata->an_int &= ~XGBE_AN_INC_LINK;
+	} else if (pdata->an_int & XGBE_AN_INT_CMPLT) {
 		pdata->an_state = XGBE_AN_COMPLETE;
-		int_mask = XGBE_AN_INT_CMPLT;
+		pdata->an_int &= ~XGBE_AN_INT_CMPLT;
 	} else {
 		pdata->an_state = XGBE_AN_ERROR;
-		int_mask = 0;
 	}
 
-	/* Clear the interrupt to be processed */
-	int_reg &= ~int_mask;
-	XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INT, int_reg);
-
 	pdata->an_result = pdata->an_state;
 
 again:
@@ -740,14 +744,14 @@ again:
 	}
 
 	if (pdata->an_state == XGBE_AN_NO_LINK) {
-		int_reg = 0;
+		pdata->an_int = 0;
 		XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INT, 0);
 	} else if (pdata->an_state == XGBE_AN_ERROR) {
 		netdev_err(pdata->netdev,
 			   "error during auto-negotiation, state=%u\n",
 			   cur_state);
 
-		int_reg = 0;
+		pdata->an_int = 0;
 		XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INT, 0);
 	}
 
@@ -765,11 +769,12 @@ again:
 	if (cur_state != pdata->an_state)
 		goto again;
 
-	if (int_reg)
+	if (pdata->an_int)
 		goto next_int;
 
 out:
-	enable_irq(pdata->an_irq);
+	/* Enable AN interrupts on the way out */
+	XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INTMASK, XGBE_AN_INT_MASK);
 
 	mutex_unlock(&pdata->an_mutex);
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index ca28354..98d9d63 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -774,8 +774,8 @@ struct xgbe_prv_data {
 	/* Overall device lock */
 	spinlock_t lock;
 
-	/* XPCS indirect addressing mutex */
-	struct mutex xpcs_mutex;
+	/* XPCS indirect addressing lock */
+	spinlock_t xpcs_lock;
 
 	/* RSS addressing mutex */
 	struct mutex rss_mutex;
@@ -927,6 +927,7 @@ struct xgbe_prv_data {
 	u32 serdes_dfe_tap_ena[XGBE_SPEEDS];
 
 	/* Auto-negotiation state machine support */
+	unsigned int an_int;
 	struct mutex an_mutex;
 	enum xgbe_an an_result;
 	enum xgbe_an an_state;
