From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: mask mmc interrupts
Date: Fri, 18 Nov 2011 16:00:20 +0100
Message-ID: <1321628420-29637-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:32916 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751941Ab1KRPAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 10:00:42 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7314421E
	for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 15:00:27 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 088F02B23
	for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 15:00:27 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to mask the MMC irq otherwise if we raise the mmc
interrupts that are not handled the driver loops in the
handler.
In fact, by default all mmc counters (only used for stats)
are managed in SW and registers are cleared on each READ.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8ea770a..72cd190 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -781,10 +781,15 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 	unsigned int mode = MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER_RESET |
 			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
 
-	/* Do not manage MMC IRQ (FIXME) */
+	/* Mask MMC irq, counters are managed in SW and registers
+	 * are cleared on each READ eventually. */
 	dwmac_mmc_intr_all_mask(priv->ioaddr);
-	dwmac_mmc_ctrl(priv->ioaddr, mode);
-	memset(&priv->mmc, 0, sizeof(struct stmmac_counters));
+
+	if (priv->dma_cap.rmon) {
+		dwmac_mmc_ctrl(priv->ioaddr, mode);
+		memset(&priv->mmc, 0, sizeof(struct stmmac_counters));
+	} else
+		pr_info(" No MAC Management Counters available");
 }
 
 static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
@@ -1012,8 +1017,7 @@ static int stmmac_open(struct net_device *dev)
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
 
-	if (priv->dma_cap.rmon)
-		stmmac_mmc_setup(priv);
+	stmmac_mmc_setup(priv);
 
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
-- 
1.7.4.4
