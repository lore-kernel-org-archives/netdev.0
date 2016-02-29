From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 06/17] stmmac: add last_segment field to dma data
Date: Mon, 29 Feb 2016 14:27:32 +0100
Message-ID: <1456752463-27128-7-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:61562 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755389AbcB2N2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:55 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDQLjI032752
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:53 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx07-00178001.pphosted.com with ESMTP id 21b254tvd4-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:46 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 3D8A14B
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:24 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id D937CF9
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:22 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

last_segment field is read twice from dma descriptors in stmmac_clean().
Add last_segment to dma data so that this flag is from priv
structure in cache instead of memory.
It avoids reading twice from memory for each loop in stmmac_clean().

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 7fa7ab0d..355eafb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -150,8 +150,9 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
+	unsigned int entry = priv->dirty_tx;
 
-	if (priv->hw->desc->get_tx_ls(p) && !priv->extend_desc)
+	if (priv->tx_skbuff_dma[entry].last_segment && !priv->extend_desc)
 		/* NOTE: Device will overwrite des3 with timestamp value if
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index c497460..0436918 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -46,6 +46,7 @@ struct stmmac_tx_info {
 	dma_addr_t buf;
 	bool map_as_page;
 	unsigned len;
+	bool last_segment;
 };
 
 struct stmmac_priv {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 90a946f..feae0de 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1094,6 +1094,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		priv->tx_skbuff_dma[i].buf = 0;
 		priv->tx_skbuff_dma[i].map_as_page = false;
 		priv->tx_skbuff_dma[i].len = 0;
+		priv->tx_skbuff_dma[i].last_segment = false;
 		priv->tx_skbuff[i] = NULL;
 	}
 
@@ -1326,7 +1327,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			break;
 
 		/* Verify tx error by looking at the last segment. */
-		last = priv->hw->desc->get_tx_ls(p);
+		last = priv->tx_skbuff_dma[entry].last_segment;
 		if (likely(last)) {
 			int tx_error =
 			    priv->hw->desc->tx_status(&priv->dev->stats,
@@ -1359,6 +1360,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			priv->tx_skbuff_dma[entry].map_as_page = false;
 		}
 		priv->hw->mode->clean_desc3(priv, p);
+		priv->tx_skbuff_dma[entry].last_segment = false;
 
 		if (likely(skb != NULL)) {
 			pkts_compl++;
@@ -2028,6 +2030,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Finalize the latest segment. */
 	priv->hw->desc->close_tx_desc(desc);
+	priv->tx_skbuff_dma[entry].last_segment = true;
 
 	wmb();
 	/* According to the coalesce parameter the IC bit for the latest
-- 
1.9.1
