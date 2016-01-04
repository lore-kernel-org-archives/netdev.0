From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 07/18] stmmac: add is_jumbo field to dma data
Date: Mon, 4 Jan 2016 14:06:52 +0100
Message-ID: <1451912823-5245-8-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:22377 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753547AbcADMyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:12 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id u04ChS0K020150
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:11 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 207dm7trmk-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:11 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D763231
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:27 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 11ECF50F6
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:10 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Optimize tx_clean by avoiding a des3 read in stmmac_clean_desc3().

In ring mode, TX, des3 seems only used when xmit a jumbo frame.
In case of normal descriptors, it may also be used for time
stamping.
Clean it in the above two case, without reading it.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |    3 ++-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |   11 ++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    1 +
 4 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index e985459..d6d56ee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -154,7 +154,8 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
 	unsigned int entry = priv->dirty_tx;
 
-	if (priv->tx_skbuff_dma[entry].last_segment && !priv->extend_desc)
+	if (priv->tx_skbuff_dma[entry].last_segment && !priv->extend_desc &&
+	    priv->hwts_tx_en)
 		/* NOTE: Device will overwrite des3 with timestamp value if
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 3300029..ffab4d7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -58,6 +58,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].len = bmax;
+		priv->tx_skbuff_dma[entry].is_jumbo = true;
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
@@ -78,6 +79,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].len = len;
+		priv->tx_skbuff_dma[entry].is_jumbo = true;
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
@@ -91,6 +93,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			return -1;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].len = nopaged_len;
+		priv->tx_skbuff_dma[entry].is_jumbo = true;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
 						STMMAC_RING_MODE);
@@ -128,7 +131,13 @@ static void stmmac_init_desc3(struct dma_desc *p)
 
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
index f15c493..b73e8d8 100644
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
index cb24779..9094aa6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1378,6 +1378,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		}
 		priv->hw->mode->clean_desc3(priv, p);
 		priv->tx_skbuff_dma[entry].last_segment = false;
+		priv->tx_skbuff_dma[entry].is_jumbo = false;
 
 		if (likely(skb != NULL)) {
 			pkts_compl++;
-- 
1.7.4.4
