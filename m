From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 12/17] stmmac: first frame prep at the end of xmit routine
Date: Mon, 29 Feb 2016 14:27:38 +0100
Message-ID: <1456752463-27128-13-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:46365 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755379AbcB2N2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:54 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDOj7Z027614
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:52 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b1t8k33d-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:51 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 74A3C22
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:48 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id E6DF7F7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:46 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This patch is to fill the first descriptor just before granting
the DMA engine so at the end of the xmit.
The patch takes care about the algorithm adopted to mitigate the
interrupts, then it fixes the last segment in case of no fragments.
Moreover, this new implementation does not pass any "ter" field when
prepare the descriptors because this is not necessary.
The patch also details the memory barrier in the xmit.

As final results, this patch guarantees the same performances
but fixing a case if small datagram are sent. In fact, this
kind of test is impacted if no coalesce is done.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 7ccb147..f96d257 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -100,7 +100,7 @@ struct stmmac_extra_stats {
 	unsigned long napi_poll;
 	unsigned long tx_normal_irq_n;
 	unsigned long tx_clean;
-	unsigned long tx_reset_ic_bit;
+	unsigned long tx_set_ic_bit;
 	unsigned long irq_receive_pmt_irq_n;
 	/* MMC info */
 	unsigned long mmc_tx_irq_n;
@@ -347,7 +347,7 @@ struct stmmac_desc_ops {
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
 				 bool csum_flag, int mode, bool tx_own,
-				 bool ls_ic);
+				 bool ls);
 	/* Set/get the owner of the descriptor */
 	void (*set_tx_owner) (struct dma_desc *p);
 	int (*get_tx_owner) (struct dma_desc *p);
@@ -355,7 +355,7 @@ struct stmmac_desc_ops {
 	void (*release_tx_desc) (struct dma_desc *p, int mode);
 	/* Clear interrupt on tx frame completion. When this bit is
 	 * set an interrupt happens as soon as the frame is transmitted */
-	void (*clear_tx_ic) (struct dma_desc *p);
+	void (*set_tx_ic)(struct dma_desc *p);
 	/* Last tx segment reports the transmit status */
 	int (*get_tx_ls) (struct dma_desc *p);
 	/* Return the transmit status looking at the TDES1 */
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 957610b..cfb018c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -311,10 +311,15 @@ static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				     bool csum_flag, int mode, bool tx_own,
-				     bool ls_ic)
+				     bool ls)
 {
 	unsigned int tdes0 = p->des0;
 
+	if (mode == STMMAC_CHAIN_MODE)
+		enh_set_tx_desc_len_on_chain(p, len);
+	else
+		enh_set_tx_desc_len_on_ring(p, len);
+
 	if (is_fs)
 		tdes0 |= ETDES0_FIRST_SEGMENT;
 	else
@@ -325,6 +330,10 @@ static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	else
 		tdes0 &= ~(TX_CIC_FULL << ETDES0_CHECKSUM_INSERTION_SHIFT);
 
+	if (ls)
+		tdes0 |= ETDES0_LAST_SEGMENT;
+
+	/* Finally set the OWN bit. Later the DMA will start! */
 	if (tx_own)
 		tdes0 |= ETDES0_OWN;
 
@@ -335,20 +344,12 @@ static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 		 */
 		wmb();
 
-	if (ls_ic)
-		tdes0 |= ETDES0_LAST_SEGMENT | ETDES0_INTERRUPT;
-
 	p->des0 = tdes0;
-
-	if (mode == STMMAC_CHAIN_MODE)
-		enh_set_tx_desc_len_on_chain(p, len);
-	else
-		enh_set_tx_desc_len_on_ring(p, len);
 }
 
-static void enh_desc_clear_tx_ic(struct dma_desc *p)
+static void enh_desc_set_tx_ic(struct dma_desc *p)
 {
-	p->des0 &= ~ETDES0_INTERRUPT;
+	p->des0 |= ETDES0_INTERRUPT;
 }
 
 static int enh_desc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
@@ -419,7 +420,7 @@ const struct stmmac_desc_ops enh_desc_ops = {
 	.get_tx_owner = enh_desc_get_tx_owner,
 	.release_tx_desc = enh_desc_release_tx_desc,
 	.prepare_tx_desc = enh_desc_prepare_tx_desc,
-	.clear_tx_ic = enh_desc_clear_tx_ic,
+	.set_tx_ic = enh_desc_set_tx_ic,
 	.get_tx_ls = enh_desc_get_tx_ls,
 	.set_tx_owner = enh_desc_set_tx_owner,
 	.set_rx_owner = enh_desc_set_rx_owner,
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 122fb5a..e13228f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -195,10 +195,15 @@ static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				  bool csum_flag, int mode, bool tx_own,
-				  bool ls_ic)
+				  bool ls)
 {
 	unsigned int tdes1 = p->des1;
 
+	if (mode == STMMAC_CHAIN_MODE)
+		norm_set_tx_desc_len_on_chain(p, len);
+	else
+		norm_set_tx_desc_len_on_ring(p, len);
+
 	if (is_fs)
 		tdes1 |= TDES1_FIRST_SEGMENT;
 	else
@@ -209,23 +214,18 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	else
 		tdes1 &= ~(TX_CIC_FULL << TDES1_CHECKSUM_INSERTION_SHIFT);
 
+	if (ls)
+		tdes1 |= TDES1_LAST_SEGMENT;
+
 	if (tx_own)
 		tdes1 |= TDES0_OWN;
 
-	if (ls_ic)
-		tdes1 |= TDES1_LAST_SEGMENT | TDES1_INTERRUPT;
-
 	p->des1 = tdes1;
-
-	if (mode == STMMAC_CHAIN_MODE)
-		norm_set_tx_desc_len_on_chain(p, len);
-	else
-		norm_set_tx_desc_len_on_ring(p, len);
 }
 
-static void ndesc_clear_tx_ic(struct dma_desc *p)
+static void ndesc_set_tx_ic(struct dma_desc *p)
 {
-	p->des1 &= ~TDES1_INTERRUPT;
+	p->des1 |= TDES1_INTERRUPT;
 }
 
 static int ndesc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
@@ -288,7 +288,7 @@ const struct stmmac_desc_ops ndesc_ops = {
 	.get_tx_owner = ndesc_get_tx_owner,
 	.release_tx_desc = ndesc_release_tx_desc,
 	.prepare_tx_desc = ndesc_prepare_tx_desc,
-	.clear_tx_ic = ndesc_clear_tx_ic,
+	.set_tx_ic = ndesc_set_tx_ic,
 	.get_tx_ls = ndesc_get_tx_ls,
 	.set_tx_owner = ndesc_set_tx_owner,
 	.set_rx_owner = ndesc_set_rx_owner,
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 11c7164..7723b5d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -62,7 +62,6 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
 						STMMAC_RING_MODE, 0, false);
-		wmb();
 		priv->tx_skbuff[entry] = NULL;
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 
@@ -82,7 +81,6 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 						STMMAC_RING_MODE, 1, true);
-		wmb();
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 4c6486c..c803d4c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -97,7 +97,7 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(napi_poll),
 	STMMAC_STAT(tx_normal_irq_n),
 	STMMAC_STAT(tx_clean),
-	STMMAC_STAT(tx_reset_ic_bit),
+	STMMAC_STAT(tx_set_ic_bit),
 	STMMAC_STAT(irq_receive_pmt_irq_n),
 	/* MMC info */
 	STMMAC_STAT(mmc_tx_irq_n),
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 2e4c10a..90b2612 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1942,12 +1942,12 @@ static int stmmac_release(struct net_device *dev)
 static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	int entry;
+	unsigned int nopaged_len = skb_headlen(skb);
 	int i, csum_insertion = 0, is_jumbo = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
+	unsigned int entry, first_entry;
 	struct dma_desc *desc, *first;
-	unsigned int nopaged_len = skb_headlen(skb);
-	unsigned int enh_desc = priv->plat->enh_desc;
+	unsigned int enh_desc;
 
 	spin_lock(&priv->tx_lock);
 
@@ -1965,34 +1965,25 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		stmmac_disable_eee_mode(priv);
 
 	entry = priv->cur_tx;
-
+	first_entry = entry;
 
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
 
-	if (priv->extend_desc)
+	if (likely(priv->extend_desc))
 		desc = (struct dma_desc *)(priv->dma_etx + entry);
 	else
 		desc = priv->dma_tx + entry;
 
 	first = desc;
 
+	priv->tx_skbuff[first_entry] = skb;
+
+	enh_desc = priv->plat->enh_desc;
 	/* To program the descriptors according to the size of the frame */
 	if (enh_desc)
 		is_jumbo = priv->hw->mode->is_jumbo_frm(skb->len, enh_desc);
 
-	if (likely(!is_jumbo)) {
-		desc->des2 = dma_map_single(priv->device, skb->data,
-					    nopaged_len, DMA_TO_DEVICE);
-		if (dma_mapping_error(priv->device, desc->des2))
-			goto dma_map_err;
-		priv->tx_skbuff_dma[entry].buf = desc->des2;
-		priv->tx_skbuff_dma[entry].len = nopaged_len;
-		/* do not set the own at this stage */
-		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
-						csum_insertion, priv->mode, 0,
-						nfrags == 0);
-	} else {
-		desc = first;
+	if (unlikely(is_jumbo)) {
 		entry = priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
 		if (unlikely(entry < 0))
 			goto dma_map_err;
@@ -2003,10 +1994,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		int len = skb_frag_size(frag);
 		bool last_segment = (i == (nfrags - 1));
 
-		priv->tx_skbuff[entry] = NULL;
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 
-		if (priv->extend_desc)
+		if (likely(priv->extend_desc))
 			desc = (struct dma_desc *)(priv->dma_etx + entry);
 		else
 			desc = priv->dma_tx + entry;
@@ -2016,41 +2006,25 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (dma_mapping_error(priv->device, desc->des2))
 			goto dma_map_err; /* should reuse desc w/o issues */
 
+		priv->tx_skbuff[entry] = NULL;
 		priv->tx_skbuff_dma[entry].buf = desc->des2;
 		priv->tx_skbuff_dma[entry].map_as_page = true;
 		priv->tx_skbuff_dma[entry].len = len;
+		priv->tx_skbuff_dma[entry].last_segment = last_segment;
+
+		/* Prepare the descriptor and set the own bit too */
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
 						priv->mode, 1, last_segment);
-		priv->tx_skbuff_dma[entry].last_segment = last_segment;
 	}
 
-	priv->tx_skbuff[entry] = skb;
-
-	/* According to the coalesce parameter the IC bit for the latest
-	 * segment could be reset and the timer re-started to invoke the
-	 * stmmac_tx function. This approach takes care about the fragments.
-	 */
-	priv->tx_count_frames += nfrags + 1;
-	if (priv->tx_coal_frames > priv->tx_count_frames) {
-		priv->hw->desc->clear_tx_ic(desc);
-		priv->xstats.tx_reset_ic_bit++;
-		mod_timer(&priv->txtimer,
-			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
-	} else
-		priv->tx_count_frames = 0;
-
-	/* To avoid raise condition */
-	priv->hw->desc->set_tx_owner(first);
-	wmb();
-
 	entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 
 	priv->cur_tx = entry;
 
 	if (netif_msg_pktdata(priv)) {
-		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
-			__func__, (priv->cur_tx % DMA_TX_SIZE),
-			(priv->dirty_tx % DMA_TX_SIZE), entry, first, nfrags);
+		pr_debug("%s: curr=%d dirty=%d f=%d, e=%d, first=%p, nfrags=%d",
+			 __func__, priv->cur_tx, priv->dirty_tx, first_entry,
+			 entry, first, nfrags);
 
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_etx,
@@ -2062,6 +2036,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		pr_debug(">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
 	}
+
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
 		if (netif_msg_hw(priv))
 			pr_debug("%s: stop transmitted packets\n", __func__);
@@ -2070,16 +2045,59 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->stats.tx_bytes += skb->len;
 
-	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
-		     priv->hwts_tx_en)) {
-		/* declare that device is doing timestamping */
-		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-		priv->hw->desc->enable_tx_timestamp(first);
+	/* According to the coalesce parameter the IC bit for the latest
+	 * segment is reset and the timer re-started to clean the tx status.
+	 * This approach takes care about the fragments: desc is the first
+	 * element in case of no SG.
+	 */
+	priv->tx_count_frames += nfrags + 1;
+	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
+		mod_timer(&priv->txtimer,
+			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
+	} else {
+		priv->tx_count_frames = 0;
+		priv->hw->desc->set_tx_ic(desc);
+		priv->xstats.tx_set_ic_bit++;
 	}
 
 	if (!priv->hwts_tx_en)
 		skb_tx_timestamp(skb);
 
+	/* Ready to fill the first descriptor and set the OWN bit w/o any
+	 * problems because all the descriptors are actually ready to be
+	 * passed to the DMA engine.
+	 */
+	if (likely(!is_jumbo)) {
+		bool last_segment = (nfrags == 0);
+
+		first->des2 = dma_map_single(priv->device, skb->data,
+					     nopaged_len, DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->device, first->des2))
+			goto dma_map_err;
+
+		priv->tx_skbuff_dma[first_entry].buf = first->des2;
+		priv->tx_skbuff_dma[first_entry].len = nopaged_len;
+		priv->tx_skbuff_dma[first_entry].last_segment = last_segment;
+
+		if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+			     priv->hwts_tx_en)) {
+			/* declare that device is doing timestamping */
+			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+			priv->hw->desc->enable_tx_timestamp(first);
+		}
+
+		/* Prepare the first descriptor setting the OWN bit too */
+		priv->hw->desc->prepare_tx_desc(first, 1, nopaged_len,
+						csum_insertion, priv->mode, 1,
+						last_segment);
+
+		/* The own bit must be the latest setting done when prepare the
+		 * descriptor and then barrier is needed to make sure that
+		 * all is coherent before granting the DMA engine.
+		 */
+		smp_wmb();
+	}
+
 	netdev_sent_queue(dev, skb->len);
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
 
-- 
1.9.1
