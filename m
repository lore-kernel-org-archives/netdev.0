From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 10/18] stmmac: optimize tx clean function
Date: Wed, 9 Dec 2015 09:37:46 +0100
Message-ID: <1449650274-14896-11-git-send-email-peppe.cavallaro@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>, Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:41812 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753409AbbLII2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 03:28:31 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id tB98DjeE006965
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2015 09:28:30 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1yjw8vkqbx-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:28:30 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5DC2C34
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:27:53 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BD5AE4F63
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:28 +0000 (GMT)
In-Reply-To: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabrice Gasnier <fabrice.gasnier@st.com>

This patch "inline" get_tx_owner and get_ls routines. It Results in a
unique read to tdes0, instead of three, to check TX_OWN and LS bits,
and other status bits.

It helps improve driver TX path by removing two uncached read/writes
inside TX clean loop for enhanced descriptors but not for normal ones
because the des1 must be read in any case.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |    8 ++++++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   12 +++++++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   13 ++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   27 ++++++++++-----------
 4 files changed, 42 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index e58d81c..fb01e94 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -241,6 +241,14 @@ enum rx_frame_status {
 	dma_own = 0x8,
 };
 
+/* Tx status */
+enum tx_frame_status {
+	tx_done = 0x0,
+	tx_not_ls = 0x1,
+	tx_err = 0x2,
+	tx_dma_own = 0x4,
+};
+
 enum dma_irq_status {
 	tx_hard_error = 0x1,
 	tx_hard_error_bump_tc = 0x2,
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 1c9a520..b672e51 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -31,7 +31,15 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 {
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 	unsigned int tdes0 = p->des0;
-	int ret = 0;
+	int ret = tx_done;
+
+	/* Get tx owner first */
+	if (unlikely(tdes0 & ETDES0_OWN))
+		return tx_dma_own;
+
+	/* Verify tx error by looking at the last segment. */
+	if (likely(!(tdes0 & ETDES0_LAST_SEGMENT)))
+		return tx_not_ls;
 
 	if (unlikely(tdes0 & ETDES0_ERROR_SUMMARY)) {
 		if (unlikely(tdes0 & ETDES0_JABBER_TIMEOUT))
@@ -71,7 +79,7 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 			dwmac_dma_flush_tx_fifo(ioaddr);
 		}
 
-		ret = -1;
+		ret = tx_err;
 	}
 
 	if (unlikely(tdes0 & ETDES0_DEFERRED))
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index df2603e..9ccae3c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -31,7 +31,16 @@ static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 {
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 	unsigned int tdes0 = p->des0;
-	int ret = 0;
+	unsigned int tdes1 = p->des1;
+	int ret = tx_done;
+
+	/* Get tx owner first */
+	if (unlikely(tdes0 & TDES0_OWN))
+		return tx_dma_own;
+
+	/* Verify tx error by looking at the last segment. */
+	if (likely(!(tdes1 & TDES1_LAST_SEGMENT)))
+		return tx_not_ls;
 
 	if (unlikely(tdes0 & TDES0_ERROR_SUMMARY)) {
 		if (unlikely(tdes0 & TDES0_UNDERFLOW_ERROR)) {
@@ -54,7 +63,7 @@ static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 			collisions = (tdes0 & TDES0_COLLISION_COUNT_MASK) >> 3;
 			stats->collisions += collisions;
 		}
-		ret = -1;
+		ret = tx_err;
 	}
 
 	if (tdes0 & TDES0_VLAN_FRAME)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 2f2f607..e51eee3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1333,32 +1333,31 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 	priv->xstats.tx_clean++;
 
 	while (entry != priv->cur_tx) {
-		int last;
 		struct sk_buff *skb = priv->tx_skbuff[entry];
 		struct dma_desc *p;
+		int status;
 
 		if (priv->extend_desc)
 			p = (struct dma_desc *)(priv->dma_etx + entry);
 		else
 			p = priv->dma_tx + entry;
 
-		/* Check if the descriptor is owned by the DMA. */
-		if (priv->hw->desc->get_tx_owner(p))
-			break;
-
-		/* Verify tx error by looking at the last segment. */
-		last = priv->tx_skbuff_dma[entry].last_segment;
-		if (likely(last)) {
-			int tx_error =
-			    priv->hw->desc->tx_status(&priv->dev->stats,
+		status = priv->hw->desc->tx_status(&priv->dev->stats,
 						      &priv->xstats, p,
 						      priv->ioaddr);
-			if (likely(tx_error == 0)) {
+		/* Check if the descriptor is owned by the DMA */
+		if (unlikely(status & tx_dma_own))
+			break;
+
+		/* Just consider the last segment and ...*/
+		if (likely(!(status & tx_not_ls))) {
+			/* ... verify the status error condition */
+			if (unlikely(status & tx_err)) {
+				priv->dev->stats.tx_errors++;
+			} else {
 				priv->dev->stats.tx_packets++;
 				priv->xstats.tx_pkt_n++;
-			} else
-				priv->dev->stats.tx_errors++;
-
+			}
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
 		if (netif_msg_tx_done(priv))
-- 
1.7.4.4
