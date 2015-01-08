From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v2] sh_eth: Fix access to TRSCER register
Date: Thu,  8 Jan 2015 15:25:07 +0900
Message-ID: <1420698307-3707-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com, linux-sh@vger.kernel.org,
	geert@linux-m68k.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:41296 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbbAHGZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 01:25:19 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so9816411pab.4
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 22:25:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TRSCER register is configured differently by SoCs. TRSCER of R-Car Gen2 is
RINT8 bit only valid, other bits are reserved bits. This removes access to
TRSCER register reserve bit by adding variable trscer_err_mask to
sh_eth_cpu_data structure, set the register information to each SoCs.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 v2: - Add trscer_err_mask to struct sh_eth_cpu_data.
     - Add DEFAULT_TRSCER_ERR_MASK.
     - Set DESC_I_RINT8 to trscer_err_mask of r8a779x_data.

 drivers/net/ethernet/renesas/sh_eth.c | 7 ++++++-
 drivers/net/ethernet/renesas/sh_eth.h | 5 +++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c29ba80..f1688201 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -496,6 +496,8 @@ static struct sh_eth_cpu_data r8a779x_data = {
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 			  EESR_ECI,
 
+	.trscer_err_mask = DESC_I_RINT8,
+
 	.apr		= 1,
 	.mpr		= 1,
 	.tpauser	= 1,
@@ -856,6 +858,9 @@ static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
 
 	if (!cd->eesr_err_check)
 		cd->eesr_err_check = DEFAULT_EESR_ERR_CHECK;
+
+	if (!cd->trscer_err_mask)
+		cd->trscer_err_mask = DEFAULT_TRSCER_ERR_MASK;
 }
 
 static int sh_eth_check_reset(struct net_device *ndev)
@@ -1294,7 +1299,7 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	/* Frame recv control (enable multiple-packets per rx irq) */
 	sh_eth_write(ndev, RMCR_RNC, RMCR);
 
-	sh_eth_write(ndev, DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2, TRSCER);
+	sh_eth_write(ndev, mdp->cd->trscer_err_mask, TRSCER);
 
 	if (mdp->cd->bculr)
 		sh_eth_write(ndev, 0x800, BCULR);	/* Burst sycle set */
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 22301bf..71f5de1 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -369,6 +369,8 @@ enum DESC_I_BIT {
 	DESC_I_RINT1 = 0x0001,
 };
 
+#define DEFAULT_TRSCER_ERR_MASK (DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2)
+
 /* RPADIR */
 enum RPADIR_BIT {
 	RPADIR_PADS1 = 0x20000, RPADIR_PADS0 = 0x10000,
@@ -470,6 +472,9 @@ struct sh_eth_cpu_data {
 	unsigned long tx_check;
 	unsigned long eesr_err_check;
 
+	/* Error mask */
+	unsigned long trscer_err_mask;
+
 	/* hardware features */
 	unsigned long irq_flags; /* IRQ configuration flags */
 	unsigned no_psr:1;	/* EtherC DO NOT have PSR */
-- 
2.1.3
