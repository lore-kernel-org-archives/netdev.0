From: "Mario Molitor" <Mario_Molitor@web.de>
Subject: [PATCH 2/2(net.git)] stmmac: fix for hw timestamp of GMAC3 unit
Date: Thu, 8 Jun 2017 23:35:02 +0200
Message-ID: <trinity-8bed4ae0-8914-46c8-b515-dda572c13b88-1496957702157@3capp-webde-bs49>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "linux-kernelvger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>,
        "Alexandre TORGUE" <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From d5c520880a5f6b470cb150b9aae67341089b9395 Mon Sep 17 00:00:00 2001
From: Mario Molitor <mario_molitor@web.de>
Date: Thu, 8 Jun 2017 23:03:09 +0200
Subject: [PATCH 2/2] stmmac: fix for hw timestamp of GMAC3 unit

1.) Bugfix of function stmmac_get_tx_hwtstamp.
    Corrected the tx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

2.) Bugfix of function stmmac_get_rx_hwtstamp.
    Corrected the rx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

Fixes: ba1ffd74df74 ("stmmac: fix PTP support for GMAC4")
Signed-off-by: Mario Molitor <mario_molitor@web.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 11 +++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 10 +++++-----
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index aa64764..e0ef02f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -214,13 +214,13 @@ static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
 {
 	/* Context type from W/B descriptor must be zero */
 	if (le32_to_cpu(p->des3) & TDES3_CONTEXT_TYPE)
-		return -EINVAL;
+		return 0;
 
 	/* Tx Timestamp Status is 1 so des0 and des1'll have valid values */
 	if (le32_to_cpu(p->des3) & TDES3_TIMESTAMP_STATUS)
-		return 0;
+		return 1;
 
-	return 1;
+	return 0;
 }
 
 static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
@@ -282,7 +282,10 @@ static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 		}
 	}
 exit:
-	return ret;
+	if (likely(ret == 0))
+		return 1;
+
+	return 0;
 }
 
 static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d54e5d7..d16d11b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -434,14 +434,14 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 		return;
 
 	/* check tx tstamp status */
-	if (!priv->hw->desc->get_tx_timestamp_status(p)) {
+	if (priv->hw->desc->get_tx_timestamp_status(p)) {
 		/* get the valid tstamp */
 		ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
 		memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 		shhwtstamp.hwtstamp = ns_to_ktime(ns);
 
-		netdev_info(priv->dev, "get valid TX hw timestamp %llu\n", ns);
+		netdev_dbg(priv->dev, "get valid TX hw timestamp %llu\n", ns);
 		/* pass tstamp to stack */
 		skb_tstamp_tx(skb, &shhwtstamp);
 	}
@@ -468,19 +468,19 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
 		return;
 
 	/* Check if timestamp is available */
-	if (!priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
+	if (priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
 		/* For GMAC4, the valid timestamp is from CTX next desc. */
 		if (priv->plat->has_gmac4)
 			ns = priv->hw->desc->get_timestamp(np, priv->adv_ts);
 		else
 			ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
-		netdev_info(priv->dev, "get valid RX hw timestamp %llu\n", ns);
+		netdev_dbg(priv->dev, "get valid RX hw timestamp %llu\n", ns);
 		shhwtstamp = skb_hwtstamps(skb);
 		memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 		shhwtstamp->hwtstamp = ns_to_ktime(ns);
 	} else  {
-		netdev_err(priv->dev, "cannot get RX hw timestamp\n");
+		netdev_dbg(priv->dev, "cannot get RX hw timestamp\n");
 	}
 }
 
-- 
2.7.4
