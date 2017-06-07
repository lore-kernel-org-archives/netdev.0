From: "Mario Molitor" <Mario_Molitor@web.de>
Subject: [PATCH 2/2(net.git)] stmmac: fix for hw timestamp of GMAC3 unit
Date: Wed, 7 Jun 2017 10:45:21 +0200
Message-ID: <trinity-988824f2-9aed-4ed0-bc97-d78b13337cf5-1496825121649@3capp-webde-bs41>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 94f3314c6d67246e015a50fd14e665732a5e78b0 Mon Sep 17 00:00:00 2001
From: Mario Molitor <mario_molitor@web.de>
Date: Tue, 6 Jun 2017 21:47:16 +0200
Subject: [PATCH 2/2] stmmac: fix for hw timestamp of GMAC3 unit

1.) Bugfix of function stmmac_get_tx_hwtstamp.
    Corrected the tx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

2.) Bugfix of function stmmac_get_rx_hwtstamp.
    Corrected the rx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

fixed: commit ba1ffd74df74 ("stmmac: fix PTP support for GMAC4")
Signed-off-by: Mario Molitor <mario_molitor@web.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 11 +++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 10 +++++-----
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index aa64764..6c2f956 100644
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
+	else
+		return 0;
 }
 
 static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 14d0bf3..9eb8132 100644
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
