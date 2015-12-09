From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 12/18] stmmac: first frame prep at the end of xmit routine
Date: Wed, 9 Dec 2015 09:37:48 +0100
Message-ID: <1449650274-14896-13-git-send-email-peppe.cavallaro@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:65415 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753453AbbLII2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 03:28:34 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id tB98BkfE031126
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2015 09:28:32 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 1ynn3af71v-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:28:32 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E5D9534
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:27:55 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 512054F61
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:31 +0000 (GMT)
In-Reply-To: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    7 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   25 +++--
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   24 ++--
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |    2 -
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  114 +++++++++++--------
 6 files changed, 95 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index fb01e94..3e13b10 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -96,7 +96,7 @@ struct stmmac_extra_stats {
 	unsigned long napi_poll;
 	unsigned long tx_normal_irq_n;
 	unsigned long tx_clean;
-	unsigned long tx_reset_ic_bit;
+	unsigned long tx_set_ic_bit;
 	unsigned long irq_receive_pmt_irq_n;
 	/* MMC info */
 	unsigned long mmc_tx_irq_n;
@@ -342,8 +342,7 @@ struct stmmac_desc_ops {
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
-				 int csum_flag, int mode, int tx_own,
-				 bool ls_ic);
+				 int csum_flag, int mode, int tx_own, bool ls);
 	/* Set/get the owner of the descriptor */
 	void (*set_tx_owner) (struct dma_desc *p);
 	int (*get_tx_owner) (struct dma_desc *p);
@@ -351,7 +350,7 @@ struct stmmac_desc_ops {
 	void (*release_tx_desc) (struct dma_desc *p, int mode);
 	/* Clear interrupt on tx frame completion. When this bit is
 	 * set an interrupt happens as soon as the frame is transmitted */
-	void (*clear_tx_ic) (struct dma_desc *p);
+	void (*set_tx_ic)(struct dma_desc *p);
 	/* Last tx segment reports the transmit status */
 	int (*get_tx_ls) (struct dma_desc *p);
 	/* Return the transmit status looking at the TDES1 */
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index b672e51..76e1c15 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -311,10 +311,15 @@ static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				     int csum_flag, int mode, int tx_own,
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
index 9ccae3c..f227be6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -195,10 +195,15 @@ static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				  int csum_flag, int mode, int tx_own,
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
index 4978a6c..1e90276 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -63,7 +63,6 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
 						STMMAC_RING_MODE, 0, false);
-		wmb();
 		priv->tx_skbuff[entry] = NULL;
 		if (++entry >= txsize)
 			entry = 0;
@@ -84,7 +83,6 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
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
index 38468e9..0a39331 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1967,13 +1967,13 @@ static int stmmac_release(struct net_device *dev)
 static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	unsigned int nopaged_len = skb_headlen(skb);
 	unsigned int txsize = priv->dma_tx_size;
-	int entry;
 	int i, csum_insertion = 0, is_jumbo = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
+	unsigned int entry, first_entry;
 	struct dma_desc *desc, *first;
-	unsigned int nopaged_len = skb_headlen(skb);
-	unsigned int enh_desc = priv->plat->enh_desc;
+	unsigned int enh_desc;
 
 	spin_lock(&priv->tx_lock);
 
@@ -1991,34 +1991,25 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -2029,11 +2020,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		int len = skb_frag_size(frag);
 		bool last_segment = (i == (nfrags - 1));
 
-		priv->tx_skbuff[entry] = NULL;
 		if (++entry >= txsize)
 			entry = 0;
 
-		if (priv->extend_desc)
+		if (likely(priv->extend_desc))
 			desc = (struct dma_desc *)(priv->dma_etx + entry);
 		else
 			desc = priv->dma_tx + entry;
@@ -2043,42 +2033,26 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
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
 	if (++entry >= txsize)
 		entry = 0;
 
 	priv->cur_tx = entry;
 
 	if (netif_msg_pktdata(priv)) {
-		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
-			__func__, (priv->cur_tx % txsize),
-			(priv->dirty_tx % txsize), entry, first, nfrags);
+		pr_debug("%s: curr=%d dirty=%d f=%d, e=%d, first=%p, nfrags=%d",
+			 __func__, priv->cur_tx, priv->dirty_tx, first_entry,
+			 entry, first, nfrags);
 
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
@@ -2088,6 +2062,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		pr_debug(">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
 	}
+
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
 		if (netif_msg_hw(priv))
 			pr_debug("%s: stop transmitted packets\n", __func__);
@@ -2096,16 +2071,59 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
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
1.7.4.4
