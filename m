From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 09/18] stmmac: optimize tx desc management
Date: Mon, 4 Jan 2016 14:06:54 +0100
Message-ID: <1451912823-5245-10-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:48995 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753626AbcADMyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:15 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CoY0U032228
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:14 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 204cmt5v72-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:14 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8B51F41
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:30 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A3EB350FA
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:12 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to optimize the way to manage the TDES inside the
xmit function. When prepare the frame, some settings (e.g. OWN
bit) can be merged. This has been reworked to improve the tx
performances.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   13 +++++++----
 drivers/net/ethernet/stmicro/stmmac/common.h      |    5 +--
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   22 ++++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   15 +++++++------
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    7 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   16 +++++---------
 6 files changed, 42 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index d6d56ee..c9310ef 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -51,7 +51,9 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		return -1;
 	priv->tx_skbuff_dma[entry].buf = desc->des2;
 	priv->tx_skbuff_dma[entry].len = bmax;
-	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
+	/* do not close the descriptor and do not set own bit */
+	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE,
+					0, false);
 
 	while (len != 0) {
 		priv->tx_skbuff[entry] = NULL;
@@ -68,8 +70,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
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
@@ -80,9 +82,10 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
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
index bc780dc..536aa06 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -334,12 +334,11 @@ struct stmmac_desc_ops {
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
-				 int csum_flag, int mode);
+				 int csum_flag, int mode, int tx_own,
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
index 1a2fce9..1c9a520 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -302,7 +302,8 @@ static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 }
 
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				     int csum_flag, int mode)
+				     int csum_flag, int mode, int tx_own,
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
index 5a91932..df2603e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -185,7 +185,8 @@ static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 }
 
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				  int csum_flag, int mode)
+				  int csum_flag, int mode, int tx_own,
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
index ffab4d7..4978a6c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -62,7 +62,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
-						STMMAC_RING_MODE);
+						STMMAC_RING_MODE, 0, false);
 		wmb();
 		priv->tx_skbuff[entry] = NULL;
 		if (++entry >= txsize)
@@ -83,9 +83,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
-						STMMAC_RING_MODE);
+						STMMAC_RING_MODE, 1, true);
 		wmb();
-		priv->hw->desc->set_tx_owner(desc);
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
@@ -96,7 +95,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		priv->tx_skbuff_dma[entry].is_jumbo = true;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
-						STMMAC_RING_MODE);
+						STMMAC_RING_MODE, 0, true);
 	}
 
 	priv->cur_tx = entry;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1a31a1c..c2d923e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2014,8 +2014,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -2026,6 +2028,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < nfrags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		int len = skb_frag_size(frag);
+		bool last_segment = (i == (nfrags - 1));
 
 		priv->tx_skbuff[entry] = NULL;
 		if (++entry >= txsize)
@@ -2045,19 +2048,12 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
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
1.7.4.4
