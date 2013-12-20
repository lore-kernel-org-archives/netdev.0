From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net] Fix incorrect spinlock release in stmmac_ptp.c and incorrect PTP capabilities detection in PTP initialization.
Date: Fri, 20 Dec 2013 08:49:36 -0600
Message-ID: <1387550976-31716-1-git-send-email-vbridgers2013@gmail.com>
References: <vbridgers2013@gmail.com>
Cc: netdev@vger.kernel.org, Vince Bridgers <vbridgers2013@gmail.com>
To: peppe.cavallaro@st.com, rayagond@vayavyalabs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:64737 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab3LTOtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:49:41 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so2686089pbc.12
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:49:41 -0800 (PST)
In-Reply-To: <vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects a problem in stmmac_ptp.c, functions
stmmac_adjust_time and stmmac_adjust_freq where the incorrect spinlocks 
were released. This patch also addresses a problem in stmmac_main, 
function stmmac_init_ptp where the capability detection for 
advanced timestamping was masked by message masking. 

This patch was touch tested using linuxptp, and runs without the previously
observed instabilities. More extensive testing is ongoing.

Vince

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   20 +++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c  |    4 ++--
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8a7a23a..797b56a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -622,17 +622,15 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
 		return -EOPNOTSUPP;
 
-	if (netif_msg_hw(priv)) {
-		if (priv->dma_cap.time_stamp) {
-			pr_debug("IEEE 1588-2002 Time Stamp supported\n");
-			priv->adv_ts = 0;
-		}
-		if (priv->dma_cap.atime_stamp && priv->extend_desc) {
-			pr_debug
-			    ("IEEE 1588-2008 Advanced Time Stamp supported\n");
-			priv->adv_ts = 1;
-		}
-	}
+	priv->adv_ts = 0;
+	if (priv->dma_cap.atime_stamp && priv->extend_desc)
+		priv->adv_ts = 1;
+
+	if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
+		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+
+	if (netif_msg_hw(priv) && priv->adv_ts)
+		pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
 
 	priv->hw->ptp = &stmmac_ptp;
 	priv->hwts_tx_en = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index b8b0eee..7680581 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -56,7 +56,7 @@ static int stmmac_adjust_freq(struct ptp_clock_info *ptp, s32 ppb)
 
 	priv->hw->ptp->config_addend(priv->ioaddr, addend);
 
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
 	return 0;
 }
@@ -91,7 +91,7 @@ static int stmmac_adjust_time(struct ptp_clock_info *ptp, s64 delta)
 
 	priv->hw->ptp->adjust_systime(priv->ioaddr, sec, nsec, neg_adj);
 
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
 	return 0;
 }
-- 
1.7.9.5
