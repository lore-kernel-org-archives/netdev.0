From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH resend 2.6.25 9/12][BNX2X]: workaround PCI queue
 overflow
Date: Mon, 25 Feb 2008 12:33:08 +0200
Message-ID: <1203935588.8232.213.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1686 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121AbYBYKe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 05:34:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: workaround PCI queue overflow - limit traffic through an internal queue to prevent overflow. 

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x_init.h |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 04f93bf..dcaecc5 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -1,6 +1,6 @@
 /* bnx2x_init.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007 Broadcom Corporation
+ * Copyright (c) 2007-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -409,7 +409,7 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 
 	pci_read_config_word(bp->pdev,
 			     bp->pcie_cap + PCI_EXP_DEVCTL, (u16 *)&val);
-	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", val);
+	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", (u16)val);
 	w_order = ((val & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
 	r_order = ((val & PCI_EXP_DEVCTL_READRQ) >> 12);
 
@@ -472,10 +472,14 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_PSWRQ_BW_WR, val);
 
 	REG_WR(bp, PXP2_REG_RQ_WR_MBS0, w_order);
-	REG_WR(bp, PXP2_REG_RQ_WR_MBS0 + 8, w_order);
+	REG_WR(bp, PXP2_REG_RQ_WR_MBS1, w_order);
 	REG_WR(bp, PXP2_REG_RQ_RD_MBS0, r_order);
-	REG_WR(bp, PXP2_REG_RQ_RD_MBS0 + 8, r_order);
+	REG_WR(bp, PXP2_REG_RQ_RD_MBS1, r_order);
 
+	if (r_order == MAX_RD_ORD)
+		REG_WR(bp, PXP2_REG_RQ_PDR_LIMIT, 0xe00);
+
+	REG_WR(bp, PXP2_REG_WR_USDMDP_TH, (0x18 << w_order));
 	REG_WR(bp, PXP2_REG_WR_DMAE_TH, (128 << w_order)/16);
 }
 
-- 
1.5.3.2




