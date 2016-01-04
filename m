From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 06/18] stmmac: add last_segment field to dma data
Date: Mon, 4 Jan 2016 14:06:51 +0100
Message-ID: <1451912823-5245-7-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:5194 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbcADMyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:11 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CmRTF016681
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:10 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 207r4bg7tj-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:10 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9159C42
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:26 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C964250F7
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:08 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

last_segment field is read twice from dma descriptors in stmmac_clean().
Add last_segment to dma data so that this flag is from priv
structure in cache instead of memory.
It avoids reading twice from memory for each loop in stmmac_clean().

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |    3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 ++++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 688795e..e985459 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -152,8 +152,9 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
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
index 8517a04..f15c493 100644
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
index 004e567..cb24779 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1108,6 +1108,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		priv->tx_skbuff_dma[i].buf = 0;
 		priv->tx_skbuff_dma[i].map_as_page = false;
 		priv->tx_skbuff_dma[i].len = 0;
+		priv->tx_skbuff_dma[i].last_segment = false;
 		priv->tx_skbuff[i] = NULL;
 	}
 
@@ -1343,7 +1344,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			break;
 
 		/* Verify tx error by looking at the last segment. */
-		last = priv->hw->desc->get_tx_ls(p);
+		last = priv->tx_skbuff_dma[entry].last_segment;
 		if (likely(last)) {
 			int tx_error =
 			    priv->hw->desc->tx_status(&priv->dev->stats,
@@ -1376,6 +1377,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			priv->tx_skbuff_dma[entry].map_as_page = false;
 		}
 		priv->hw->mode->clean_desc3(priv, p);
+		priv->tx_skbuff_dma[entry].last_segment = false;
 
 		if (likely(skb != NULL)) {
 			pkts_compl++;
@@ -2052,6 +2054,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Finalize the latest segment. */
 	priv->hw->desc->close_tx_desc(desc);
+	priv->tx_skbuff_dma[entry].last_segment = true;
 
 	wmb();
 	/* According to the coalesce parameter the IC bit for the latest
-- 
1.7.4.4
