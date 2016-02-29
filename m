From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 09/17] stmmac: optimize tx desc management
Date: Mon, 29 Feb 2016 14:27:35 +0100
Message-ID: <1456752463-27128-10-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45914 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753005AbcB2N2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:42 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDS8pb019736
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:41 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b3jgaqet-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:40 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 972AF23
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:37 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 3F089F7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:36 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This patch is to optimize the way to manage the TDES inside the
xmit function. When prepare the frame, some settings (e.g. OWN
bit) can be merged. This has been reworked to improve the tx
performances.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index dacb654..b3e669a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -50,7 +50,9 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		return -1;
 	priv->tx_skbuff_dma[entry].buf = desc->des2;
 	priv->tx_skbuff_dma[entry].len = bmax;
-	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
+	/* do not close the descriptor and do not set own bit */
+	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE,
+					0, false);
 
 	while (len != 0) {
 		priv->tx_skbuff[entry] = NULL;
@@ -66,8 +68,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			priv->tx_skbuff_dma[entry].buf = desc->des2;
 			priv->tx_skbuff_dma[entry].len = bmax;
 			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
-							STMMAC_CHAIN_MODE);
-			priv->hw->desc->set_tx_owner(desc);
+							STMMAC_CHAIN_MODE, 1,
+							false);
 			len -= bmax;
 			i++;
 		} else {
@@ -78,9 +80,10 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 				return -1;
 			priv->tx_skbuff_dma[entry].buf = desc->des2;
 			priv->tx_skbuff_dma[entry].len = len;
+			/* last descriptor can be set now */
 			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
-							STMMAC_CHAIN_MODE);
-			priv->hw->desc->set_tx_owner(desc);
+							STMMAC_CHAIN_MODE, 1,
+							true);
 			len = 0;
 		}
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 3ba268e..885c0f9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -338,12 +338,11 @@ struct stmmac_desc_ops {
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
-				 int csum_flag, int mode);
+				 bool csum_flag, int mode, bool tx_own,
+				 bool ls_ic);
 	/* Set/get the owner of the descriptor */
 	void (*set_tx_owner) (struct dma_desc *p);
 	int (*get_tx_owner) (struct dma_desc *p);
-	/* Invoked by the xmit function to close the tx descriptor */
-	void (*close_tx_desc) (struct dma_desc *p);
 	/* Clean the tx descriptor as soon as the tx irq is received */
 	void (*release_tx_desc) (struct dma_desc *p, int mode);
 	/* Clear interrupt on tx frame completion. When this bit is
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 1a2fce9..1abd80e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -302,7 +302,8 @@ static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 }
 
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				     int csum_flag, int mode)
+				     bool csum_flag, int mode, bool tx_own,
+				     bool ls_ic)
 {
 	unsigned int tdes0 = p->des0;
 
@@ -316,6 +317,19 @@ static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	else
 		tdes0 &= ~(TX_CIC_FULL << ETDES0_CHECKSUM_INSERTION_SHIFT);
 
+	if (tx_own)
+		tdes0 |= ETDES0_OWN;
+
+	if (is_fs & tx_own)
+		/* When the own bit, for the first frame, has to be set, all
+		 * descriptors for the same frame has to be set before, to
+		 * avoid race condition.
+		 */
+		wmb();
+
+	if (ls_ic)
+		tdes0 |= ETDES0_LAST_SEGMENT | ETDES0_INTERRUPT;
+
 	p->des0 = tdes0;
 
 	if (mode == STMMAC_CHAIN_MODE)
@@ -329,11 +343,6 @@ static void enh_desc_clear_tx_ic(struct dma_desc *p)
 	p->des0 &= ~ETDES0_INTERRUPT;
 }
 
-static void enh_desc_close_tx_desc(struct dma_desc *p)
-{
-	p->des0 |= ETDES0_LAST_SEGMENT | ETDES0_INTERRUPT;
-}
-
 static int enh_desc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
 {
 	unsigned int csum = 0;
@@ -403,7 +412,6 @@ const struct stmmac_desc_ops enh_desc_ops = {
 	.release_tx_desc = enh_desc_release_tx_desc,
 	.prepare_tx_desc = enh_desc_prepare_tx_desc,
 	.clear_tx_ic = enh_desc_clear_tx_ic,
-	.close_tx_desc = enh_desc_close_tx_desc,
 	.get_tx_ls = enh_desc_get_tx_ls,
 	.set_tx_owner = enh_desc_set_tx_owner,
 	.set_rx_owner = enh_desc_set_rx_owner,
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 5a91932..19cc12d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -185,7 +185,8 @@ static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 }
 
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				  int csum_flag, int mode)
+				  bool csum_flag, int mode, bool tx_own,
+				  bool ls_ic)
 {
 	unsigned int tdes1 = p->des1;
 
@@ -199,6 +200,12 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	else
 		tdes1 &= ~(TX_CIC_FULL << TDES1_CHECKSUM_INSERTION_SHIFT);
 
+	if (tx_own)
+		tdes1 |= TDES0_OWN;
+
+	if (ls_ic)
+		tdes1 |= TDES1_LAST_SEGMENT | TDES1_INTERRUPT;
+
 	p->des1 = tdes1;
 
 	if (mode == STMMAC_CHAIN_MODE)
@@ -212,11 +219,6 @@ static void ndesc_clear_tx_ic(struct dma_desc *p)
 	p->des1 &= ~TDES1_INTERRUPT;
 }
 
-static void ndesc_close_tx_desc(struct dma_desc *p)
-{
-	p->des1 |= TDES1_LAST_SEGMENT | TDES1_INTERRUPT;
-}
-
 static int ndesc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
 {
 	unsigned int csum = 0;
@@ -278,7 +280,6 @@ const struct stmmac_desc_ops ndesc_ops = {
 	.release_tx_desc = ndesc_release_tx_desc,
 	.prepare_tx_desc = ndesc_prepare_tx_desc,
 	.clear_tx_ic = ndesc_clear_tx_ic,
-	.close_tx_desc = ndesc_close_tx_desc,
 	.get_tx_ls = ndesc_get_tx_ls,
 	.set_tx_owner = ndesc_set_tx_owner,
 	.set_rx_owner = ndesc_set_rx_owner,
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index c648774..11c7164 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -61,7 +61,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
-						STMMAC_RING_MODE);
+						STMMAC_RING_MODE, 0, false);
 		wmb();
 		priv->tx_skbuff[entry] = NULL;
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
@@ -81,9 +81,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
-						STMMAC_RING_MODE);
+						STMMAC_RING_MODE, 1, true);
 		wmb();
-		priv->hw->desc->set_tx_owner(desc);
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
@@ -94,7 +93,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		priv->tx_skbuff_dma[entry].is_jumbo = true;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
-						STMMAC_RING_MODE);
+						STMMAC_RING_MODE, 0, true);
 	}
 
 	priv->cur_tx = entry;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 796d7c6..24c3608 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1991,8 +1991,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto dma_map_err;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].len = nopaged_len;
+		/* do not set the own at this stage */
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
-						csum_insertion, priv->mode);
+						csum_insertion, priv->mode, 0,
+						nfrags == 0);
 	} else {
 		desc = first;
 		entry = priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
@@ -2003,6 +2005,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < nfrags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		int len = skb_frag_size(frag);
+		bool last_segment = (i == (nfrags - 1));
 
 		priv->tx_skbuff[entry] = NULL;
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
@@ -2021,19 +2024,12 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->tx_skbuff_dma[entry].map_as_page = true;
 		priv->tx_skbuff_dma[entry].len = len;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
-						priv->mode);
-		wmb();
-		priv->hw->desc->set_tx_owner(desc);
-		wmb();
+						priv->mode, 1, last_segment);
+		priv->tx_skbuff_dma[entry].last_segment = last_segment;
 	}
 
 	priv->tx_skbuff[entry] = skb;
 
-	/* Finalize the latest segment. */
-	priv->hw->desc->close_tx_desc(desc);
-	priv->tx_skbuff_dma[entry].last_segment = true;
-
-	wmb();
 	/* According to the coalesce parameter the IC bit for the latest
 	 * segment could be reset and the timer re-started to invoke the
 	 * stmmac_tx function. This approach takes care about the fragments.
-- 
1.9.1
