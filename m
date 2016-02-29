From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 08/17] stmmac: merge get_rx_owner into rx_status routine.
Date: Mon, 29 Feb 2016 14:27:34 +0100
Message-ID: <1456752463-27128-9-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45911 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750796AbcB2N2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:39 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDRsig019392
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:38 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b3jgaqeh-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:37 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id D967F22
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:33 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 7CFA4F7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:32 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabrice Gasnier <fabrice.gasnier@st.com>

The RDES0 register can be read several times while doing RX of a
packet.
This patch slightly improves RX path performance by reading rdes0
once for two operation: check rx owner, get rx status bits.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 09291af..3ba268e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -238,10 +238,11 @@ struct stmmac_extra_stats {
 
 /* Rx IPC status */
 enum rx_frame_status {
-	good_frame = 0,
-	discard_frame = 1,
-	csum_none = 2,
-	llc_snap = 4,
+	good_frame = 0x0,
+	discard_frame = 0x1,
+	csum_none = 0x2,
+	llc_snap = 0x4,
+	dma_own = 0x8,
 };
 
 enum dma_irq_status {
@@ -356,7 +357,6 @@ struct stmmac_desc_ops {
 	/* Get the buffer size from the descriptor */
 	int (*get_tx_len) (struct dma_desc *p);
 	/* Handle extra events on specific interrupts hw dependent */
-	int (*get_rx_owner) (struct dma_desc *p);
 	void (*set_rx_owner) (struct dma_desc *p);
 	/* Get the receive frame size */
 	int (*get_rx_frame_len) (struct dma_desc *p, int rx_coe_type);
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 716b807..1a2fce9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -186,6 +186,9 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	unsigned int rdes0 = p->des0;
 	int ret = good_frame;
 
+	if (unlikely(rdes0 & RDES0_OWN))
+		return dma_own;
+
 	if (unlikely(rdes0 & RDES0_ERROR_SUMMARY)) {
 		if (unlikely(rdes0 & RDES0_DESCRIPTOR_ERROR)) {
 			x->rx_desc++;
@@ -272,11 +275,6 @@ static int enh_desc_get_tx_owner(struct dma_desc *p)
 	return (p->des0 & ETDES0_OWN) >> 31;
 }
 
-static int enh_desc_get_rx_owner(struct dma_desc *p)
-{
-	return (p->des0 & RDES0_OWN) >> 31;
-}
-
 static void enh_desc_set_tx_owner(struct dma_desc *p)
 {
 	p->des0 |= ETDES0_OWN;
@@ -402,7 +400,6 @@ const struct stmmac_desc_ops enh_desc_ops = {
 	.init_rx_desc = enh_desc_init_rx_desc,
 	.init_tx_desc = enh_desc_init_tx_desc,
 	.get_tx_owner = enh_desc_get_tx_owner,
-	.get_rx_owner = enh_desc_get_rx_owner,
 	.release_tx_desc = enh_desc_release_tx_desc,
 	.prepare_tx_desc = enh_desc_prepare_tx_desc,
 	.clear_tx_ic = enh_desc_clear_tx_ic,
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 460c573..5a91932 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -82,6 +82,9 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	unsigned int rdes0 = p->des0;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 
+	if (unlikely(rdes0 & RDES0_OWN))
+		return dma_own;
+
 	if (unlikely(!(rdes0 & RDES0_LAST_DESCRIPTOR))) {
 		pr_warn("%s: Oversized frame spanned multiple buffers\n",
 			__func__);
@@ -155,11 +158,6 @@ static int ndesc_get_tx_owner(struct dma_desc *p)
 	return (p->des0 & TDES0_OWN) >> 31;
 }
 
-static int ndesc_get_rx_owner(struct dma_desc *p)
-{
-	return (p->des0 & RDES0_OWN) >> 31;
-}
-
 static void ndesc_set_tx_owner(struct dma_desc *p)
 {
 	p->des0 |= TDES0_OWN;
@@ -277,7 +275,6 @@ const struct stmmac_desc_ops ndesc_ops = {
 	.init_rx_desc = ndesc_init_rx_desc,
 	.init_tx_desc = ndesc_init_tx_desc,
 	.get_tx_owner = ndesc_get_tx_owner,
-	.get_rx_owner = ndesc_get_rx_owner,
 	.release_tx_desc = ndesc_release_tx_desc,
 	.prepare_tx_desc = ndesc_prepare_tx_desc,
 	.clear_tx_ic = ndesc_clear_tx_ic,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0194a8f..796d7c6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2205,7 +2205,11 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		else
 			p = priv->dma_rx + entry;
 
-		if (priv->hw->desc->get_rx_owner(p))
+		/* read the status of the incoming frame */
+		status = priv->hw->desc->rx_status(&priv->dev->stats,
+						   &priv->xstats, p);
+		/* check if managed by the DMA otherwise go ahead */
+		if (unlikely(status & dma_own))
 			break;
 
 		count++;
@@ -2218,9 +2222,6 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		else
 			prefetch(priv->dma_rx + next_entry);
 
-		/* read the status of the incoming frame */
-		status = priv->hw->desc->rx_status(&priv->dev->stats,
-						   &priv->xstats, p);
 		if ((priv->extend_desc) && (priv->hw->desc->rx_extended_status))
 			priv->hw->desc->rx_extended_status(&priv->dev->stats,
 							   &priv->xstats,
-- 
1.9.1
