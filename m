From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 07/17] stmmac: add is_jumbo field to dma data
Date: Mon, 29 Feb 2016 14:27:33 +0100
Message-ID: <1456752463-27128-8-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:13879 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750796AbcB2N2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:34 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u1TDRvZr027537
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:32 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by m0046037.ppops.net with ESMTP id 21b2ev2tyf-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:32 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 0EF2E24
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:29 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id A05FBF7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:27 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Optimize tx_clean by avoiding a des3 read in stmmac_clean_desc3().

In ring mode, TX, des3 seems only used when xmit a jumbo frame.
In case of normal descriptors, it may also be used for time
stamping.
Clean it in the above two case, without reading it.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 355eafb..dacb654 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -152,7 +152,8 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
 	unsigned int entry = priv->dirty_tx;
 
-	if (priv->tx_skbuff_dma[entry].last_segment && !priv->extend_desc)
+	if (priv->tx_skbuff_dma[entry].last_segment && !priv->extend_desc &&
+	    priv->hwts_tx_en)
 		/* NOTE: Device will overwrite des3 with timestamp value if
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index cfc2f24..c648774 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -57,6 +57,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].len = bmax;
+		priv->tx_skbuff_dma[entry].is_jumbo = true;
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
@@ -76,6 +77,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].len = len;
+		priv->tx_skbuff_dma[entry].is_jumbo = true;
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
@@ -89,6 +91,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].len = nopaged_len;
+		priv->tx_skbuff_dma[entry].is_jumbo = true;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
 						STMMAC_RING_MODE);
@@ -126,7 +129,13 @@ static void stmmac_init_desc3(struct dma_desc *p)
 
 static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 {
-	if (unlikely(p->des3))
+	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
+	unsigned int entry = priv->dirty_tx;
+
+	/* des3 is only used for jumbo frames tx or time stamping */
+	if (unlikely(priv->tx_skbuff_dma[entry].is_jumbo ||
+		     (priv->tx_skbuff_dma[entry].last_segment &&
+		      !priv->extend_desc && priv->hwts_tx_en)))
 		p->des3 = 0;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 0436918..0d01f3e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -47,6 +47,7 @@ struct stmmac_tx_info {
 	bool map_as_page;
 	unsigned len;
 	bool last_segment;
+	bool is_jumbo;
 };
 
 struct stmmac_priv {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index feae0de..0194a8f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1361,6 +1361,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		}
 		priv->hw->mode->clean_desc3(priv, p);
 		priv->tx_skbuff_dma[entry].last_segment = false;
+		priv->tx_skbuff_dma[entry].is_jumbo = false;
 
 		if (likely(skb != NULL)) {
 			pkts_compl++;
-- 
1.9.1
