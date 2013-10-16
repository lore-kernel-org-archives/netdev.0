From: Jimmy Perchet <jimmy.perchet@parrot.com>
Subject: [PATCH RFC 4/5] net:stmmac: fix jumbo frame handling.
Date: Wed, 16 Oct 2013 17:24:11 +0200
Message-ID: <1381937052-8999-5-git-send-email-jimmy.perchet@parrot.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jimmy Perchet <jimmy.perchet@parrot.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:60755 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756281Ab3JPPj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 11:39:28 -0400
In-Reply-To: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses several issues which prevent jumbo frames from working properly :
.jumbo frames' last descriptor was not closed
.several confusion regarding descriptor's max buffer size
.frags could not be jumbo

Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |  95 ++++++++----------
 drivers/net/ethernet/stmicro/stmmac/common.h      |   6 ++
 drivers/net/ethernet/stmicro/stmmac/descs_com.h   |   8 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   6 ++
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   6 ++
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |  90 ++++++++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 112 +++++++++++-----------
 7 files changed, 158 insertions(+), 165 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index d234ab5..d6ed0ce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -28,70 +28,58 @@
 
 #include "stmmac.h"
 
-static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
+static unsigned int stmmac_prepare_frm(void *p, void *data, unsigned int len,
+						 int csum, unsigned int entry)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)p;
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry = priv->cur_tx % txsize;
-	struct dma_desc *desc = priv->dma_tx + entry;
-	unsigned int nopaged_len = skb_headlen(skb);
+	unsigned int entry_count = 0;
+	struct dma_desc *desc;
 	unsigned int bmax;
-	unsigned int i = 1, len;
 
-	if (priv->plat->enh_desc)
-		bmax = BUF_SIZE_8KiB;
-	else
-		bmax = BUF_SIZE_2KiB;
-
-	len = nopaged_len - bmax;
-
-	desc->des2 = dma_map_single(priv->device, skb->data,
-				    bmax, DMA_TO_DEVICE);
-	priv->tx_skbuff_dma[entry] = desc->des2;
-	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
-
-	while (len != 0) {
-		entry = (++priv->cur_tx) % txsize;
+	if (priv->plat->enh_desc) {
+		desc = (struct dma_desc *)(priv->dma_etx + entry);
+		bmax = BUF_SIZE_8KiB - 1;
+	} else{
 		desc = priv->dma_tx + entry;
-
-		if (len > bmax) {
-			desc->des2 = dma_map_single(priv->device,
-						    (skb->data + bmax * i),
-						    bmax, DMA_TO_DEVICE);
-			priv->tx_skbuff_dma[entry] = desc->des2;
-			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
-							STMMAC_CHAIN_MODE);
-			priv->hw->desc->set_tx_owner(desc);
-			priv->tx_skbuff[entry] = NULL;
-			len -= bmax;
-			i++;
-		} else {
-			desc->des2 = dma_map_single(priv->device,
-						    (skb->data + bmax * i), len,
-						    DMA_TO_DEVICE);
-			priv->tx_skbuff_dma[entry] = desc->des2;
-			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
-							STMMAC_CHAIN_MODE);
-			priv->hw->desc->set_tx_owner(desc);
-			priv->tx_skbuff[entry] = NULL;
-			len = 0;
-		}
+		bmax = BUF_SIZE_2KiB - 1;
 	}
-	return entry;
-}
 
-static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
-{
-	unsigned int ret = 0;
+	while (len > bmax) {
+		desc->des2 = dma_map_single(priv->device,
+					    data + bmax*entry_count,
+					    bmax, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
+		priv->tx_skbuff[entry] = NULL;
+		priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
+						STMMAC_CHAIN_MODE);
+
+		len -= bmax;
+		entry++;
+		entry %= priv->dma_tx_size;
+		entry_count++;
+
+		if (priv->plat->enh_desc)
+			desc = (struct dma_desc *)
+					(((struct dma_extended_desc *)desc)+1);
+		else
+			desc++;
+	}
 
-	if ((enh_desc && (len > BUF_SIZE_8KiB)) ||
-	    (!enh_desc && (len > BUF_SIZE_2KiB))) {
-		ret = 1;
+	if (len)	{
+		desc->des2 = dma_map_single(priv->device,
+					    data + bmax*entry_count,
+					    len, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
+		priv->tx_skbuff[entry] = NULL;
+		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
+						STMMAC_CHAIN_MODE);
+		entry_count++;
 	}
 
-	return ret;
+	return entry_count;
 }
 
+
 static void stmmac_init_dma_chain(void *des, dma_addr_t phy_addr,
 				  unsigned int size, unsigned int extend_desc)
 {
@@ -154,8 +142,7 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 
 const struct stmmac_chain_mode_ops chain_mode_ops = {
 	.init = stmmac_init_dma_chain,
-	.is_jumbo_frm = stmmac_is_jumbo_frm,
-	.jumbo_frm = stmmac_jumbo_frm,
+	.prepare_frm = stmmac_prepare_frm,
 	.refill_desc3 = stmmac_refill_desc3,
 	.clean_desc3 = stmmac_clean_desc3,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 7eb8bab..5d3f734 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -323,6 +323,8 @@ struct stmmac_desc_ops {
 	/* Handle extra events on specific interrupts hw dependent */
 	int (*get_rx_owner) (struct dma_desc *p);
 	void (*set_rx_owner) (struct dma_desc *p);
+
+	void (*set_tx_first) (struct dma_desc *p);
 	/* Get the receive frame size */
 	int (*get_rx_frame_len) (struct dma_desc *p, int rx_coe_type);
 	/* Return the reception status looking at the RDES1 */
@@ -421,6 +423,8 @@ struct mii_regs {
 struct stmmac_ring_mode_ops {
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
+	unsigned int (*prepare_frm) (void *p, void *data, unsigned int len,
+						int csum, unsigned int entry);
 	void (*refill_desc3) (void *priv, struct dma_desc *p);
 	void (*init_desc3) (struct dma_desc *p);
 	void (*clean_desc3) (void *priv, struct dma_desc *p);
@@ -432,6 +436,8 @@ struct stmmac_chain_mode_ops {
 		      unsigned int extend_desc);
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
+	unsigned int (*prepare_frm) (void *p, void *data, unsigned int len,
+					 int csum, unsigned int entry);
 	void (*refill_desc3) (void *priv, struct dma_desc *p);
 	void (*clean_desc3) (void *priv, struct dma_desc *p);
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
index 6f2cc78..cf199d6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs_com.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
@@ -53,9 +53,9 @@ static inline void enh_desc_end_tx_desc_on_ring(struct dma_desc *p, int ter)
 
 static inline void enh_set_tx_desc_len_on_ring(struct dma_desc *p, int len)
 {
-	if (unlikely(len > BUF_SIZE_4KiB)) {
-		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
-		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
+	if (unlikely(len >= BUF_SIZE_8KiB)) {
+		p->des01.etx.buffer1_size = BUF_SIZE_8KiB - 1;
+		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
 	} else
 		p->des01.etx.buffer1_size = len;
 }
@@ -81,7 +81,7 @@ static inline void ndesc_end_tx_desc_on_ring(struct dma_desc *p, int ter)
 
 static inline void norm_set_tx_desc_len_on_ring(struct dma_desc *p, int len)
 {
-	if (unlikely(len > BUF_SIZE_2KiB)) {
+	if (unlikely(len >= BUF_SIZE_2KiB)) {
 		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
 		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
 	} else
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 7e6628a..915a7ab 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -297,6 +297,11 @@ static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 		enh_desc_end_tx_desc_on_ring(p, ter);
 }
 
+static void enh_desc_set_tx_first(struct dma_desc *p)
+{
+	p->des01.etx.first_segment = 1;
+}
+
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				     int csum_flag, int mode)
 {
@@ -393,6 +398,7 @@ const struct stmmac_desc_ops enh_desc_ops = {
 	.get_tx_ls = enh_desc_get_tx_ls,
 	.set_tx_owner = enh_desc_set_tx_owner,
 	.set_rx_owner = enh_desc_set_rx_owner,
+	.set_tx_first = enh_desc_set_tx_first,
 	.get_rx_frame_len = enh_desc_get_rx_frame_len,
 	.rx_extended_status = enh_desc_get_ext_status,
 	.enable_tx_timestamp = enh_desc_enable_tx_timestamp,
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 35ad4f4..6363776 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -180,6 +180,11 @@ static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 		ndesc_end_tx_desc_on_ring(p, ter);
 }
 
+static void ndesc_set_tx_first(struct dma_desc *p)
+{
+	p->des01.etx.first_segment = 1;
+}
+
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				  int csum_flag, int mode)
 {
@@ -265,6 +270,7 @@ const struct stmmac_desc_ops ndesc_ops = {
 	.get_tx_ls = ndesc_get_tx_ls,
 	.set_tx_owner = ndesc_set_tx_owner,
 	.set_rx_owner = ndesc_set_rx_owner,
+	.set_tx_first = ndesc_set_tx_first,
 	.get_rx_frame_len = ndesc_get_rx_frame_len,
 	.enable_tx_timestamp = ndesc_enable_tx_timestamp,
 	.get_tx_timestamp_status = ndesc_get_tx_timestamp_status,
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 1ef9d8a..7faa42a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -28,73 +28,60 @@
 
 #include "stmmac.h"
 
-static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
+
+static unsigned int stmmac_prepare_frm(void *p, void *data, unsigned int len,
+						 int csum, unsigned int entry)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)p;
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry = priv->cur_tx % txsize;
+	unsigned int entry_count = 0;
 	struct dma_desc *desc;
-	unsigned int nopaged_len = skb_headlen(skb);
-	unsigned int bmax, len;
+	unsigned int bmax;
 
-	if (priv->extend_desc)
+	if (priv->plat->enh_desc) {
 		desc = (struct dma_desc *)(priv->dma_etx + entry);
-	else
+		bmax = BUF_SIZE_8KiB - 1;
+	} else{
 		desc = priv->dma_tx + entry;
+		bmax = BUF_SIZE_2KiB - 1;
+	}
 
-	if (priv->plat->enh_desc)
-		bmax = BUF_SIZE_8KiB;
-	else
-		bmax = BUF_SIZE_2KiB;
-
-	len = nopaged_len - bmax;
-
-	if (nopaged_len > BUF_SIZE_8KiB) {
-
-		desc->des2 = dma_map_single(priv->device, skb->data,
-					    bmax, DMA_TO_DEVICE);
+	while (len > 2*bmax) {
+		desc->des2 = dma_map_single(priv->device,
+						data + 2*bmax*entry_count,
+						2*bmax, DMA_TO_DEVICE);
 		priv->tx_skbuff_dma[entry] = desc->des2;
-		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
+		priv->tx_skbuff[entry] = NULL;
+		desc->des3 = desc->des2 + bmax;
+		priv->hw->desc->prepare_tx_desc(desc, 0, 2*bmax, csum,
 						STMMAC_RING_MODE);
-		wmb();
-		entry = (++priv->cur_tx) % txsize;
 
-		if (priv->extend_desc)
-			desc = (struct dma_desc *)(priv->dma_etx + entry);
+		len -= 2*bmax;
+		entry++;
+		entry %= priv->dma_tx_size;
+		entry_count++;
+
+		if (priv->plat->enh_desc)
+			desc = (struct dma_desc *)
+					(((struct dma_extended_desc *)desc)+1);
 		else
-			desc = priv->dma_tx + entry;
+			desc++;
+	}
+	if (len) {
 
-		desc->des2 = dma_map_single(priv->device, skb->data + bmax,
-					    len, DMA_TO_DEVICE);
+		desc->des2 = dma_map_single(priv->device,
+						data + 2*bmax*entry_count,
+						len, DMA_TO_DEVICE);
 		priv->tx_skbuff_dma[entry] = desc->des2;
-		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
-						STMMAC_RING_MODE);
-		wmb();
-		priv->hw->desc->set_tx_owner(desc);
 		priv->tx_skbuff[entry] = NULL;
-	} else {
-		desc->des2 = dma_map_single(priv->device, skb->data,
-					    nopaged_len, DMA_TO_DEVICE);
-		priv->tx_skbuff_dma[entry] = desc->des2;
-		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
+		desc->des3 = desc->des2 + bmax;
+		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 						STMMAC_RING_MODE);
+		entry_count++;
 	}
 
-	return entry;
+	return entry_count;
 }
 
-static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
-{
-	unsigned int ret = 0;
-
-	if (len >= BUF_SIZE_4KiB)
-		ret = 1;
-
-	return ret;
-}
 
 static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 {
@@ -103,13 +90,13 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 	if (unlikely(priv->plat->has_gmac))
 		/* Fill DES3 in case of RING mode */
 		if (priv->dma_buf_sz >= BUF_SIZE_8KiB)
-			p->des3 = p->des2 + BUF_SIZE_8KiB;
+			p->des3 = p->des2 + BUF_SIZE_8KiB - 1;
 }
 
 /* In ring mode we need to fill the desc3 because it is used as buffer */
 static void stmmac_init_desc3(struct dma_desc *p)
 {
-	p->des3 = p->des2 + BUF_SIZE_8KiB;
+	p->des3 = p->des2 + BUF_SIZE_8KiB - 1;
 }
 
 static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
@@ -127,8 +114,7 @@ static int stmmac_set_16kib_bfsize(int mtu)
 }
 
 const struct stmmac_ring_mode_ops ring_mode_ops = {
-	.is_jumbo_frm = stmmac_is_jumbo_frm,
-	.jumbo_frm = stmmac_jumbo_frm,
+	.prepare_frm = stmmac_prepare_frm,
 	.refill_desc3 = stmmac_refill_desc3,
 	.init_desc3 = stmmac_init_desc3,
 	.clean_desc3 = stmmac_clean_desc3,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index af04b5d..5873246 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1832,6 +1832,20 @@ static int stmmac_release(struct net_device *dev)
 	return 0;
 }
 
+
+static struct dma_desc *get_desc(struct stmmac_priv *priv, unsigned int entry)
+{
+	struct dma_desc *desc;
+
+	if (priv->plat->enh_desc)
+		desc = (struct dma_desc *)(priv->dma_etx + entry);
+	else
+		desc = priv->dma_tx + entry;
+
+	return  desc;
+}
+
+
 /**
  *  stmmac_xmit: Tx entry point of the driver
  *  @skb : the socket buffer
@@ -1844,11 +1858,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry;
-	int i, csum_insertion = 0, is_jumbo = 0;
+	unsigned int entry, first_entry, nb_desc = 0;
+	int i, csum_insertion = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
-	struct dma_desc *desc, *first;
-	unsigned int nopaged_len = skb_headlen(skb);
+	struct dma_desc *desc = NULL, *first;
 
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
 		if (!netif_queue_stopped(dev)) {
@@ -1858,73 +1871,53 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 		return NETDEV_TX_BUSY;
 	}
-
 	spin_lock(&priv->tx_lock);
 
 	if (priv->tx_path_in_lpi_mode)
 		stmmac_disable_eee_mode(priv);
 
-	entry = priv->cur_tx % txsize;
+	first_entry = entry = priv->cur_tx % txsize;
 
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
-
-	if (priv->extend_desc)
-		desc = (struct dma_desc *)(priv->dma_etx + entry);
+	/* To program the descriptors according to the size of the frame */
+	if (priv->mode == STMMAC_RING_MODE)
+		entry += priv->hw->ring->prepare_frm(priv, skb->data,
+				skb_headlen(skb), csum_insertion, entry);
 	else
-		desc = priv->dma_tx + entry;
+		entry += priv->hw->chain->prepare_frm(priv, skb->data,
+				 skb_headlen(skb), csum_insertion, entry);
 
-	first = desc;
-
-	priv->tx_skbuff[entry] = skb;
-
-	/* To program the descriptors according to the size of the frame */
-	if (priv->mode == STMMAC_RING_MODE) {
-		is_jumbo = priv->hw->ring->is_jumbo_frm(skb->len,
-							priv->plat->enh_desc);
-		if (unlikely(is_jumbo))
-			entry = priv->hw->ring->jumbo_frm(priv, skb,
-							  csum_insertion);
-	} else {
-		is_jumbo = priv->hw->chain->is_jumbo_frm(skb->len,
-							 priv->plat->enh_desc);
-		if (unlikely(is_jumbo))
-			entry = priv->hw->chain->jumbo_frm(priv, skb,
-							   csum_insertion);
-	}
-	if (likely(!is_jumbo)) {
-		desc->des2 = dma_map_single(priv->device, skb->data,
-					    nopaged_len, DMA_TO_DEVICE);
-		priv->tx_skbuff_dma[entry] = desc->des2;
-		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
-						csum_insertion, priv->mode);
-	} else
-		desc = first;
+	entry %= txsize;
 
 	for (i = 0; i < nfrags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		int len = skb_frag_size(frag);
 
-		entry = (++priv->cur_tx) % txsize;
-		if (priv->extend_desc)
-			desc = (struct dma_desc *)(priv->dma_etx + entry);
+		if (priv->mode == STMMAC_RING_MODE)
+			entry += priv->hw->ring->prepare_frm(priv,
+						 skb_frag_address(frag),
+						 skb_frag_size(frag),
+						 csum_insertion, entry);
 		else
-			desc = priv->dma_tx + entry;
-
-		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
-					      DMA_TO_DEVICE);
-		priv->tx_skbuff_dma[entry] = desc->des2;
-		priv->tx_skbuff[entry] = NULL;
-		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
-						priv->mode);
-		wmb();
-		priv->hw->desc->set_tx_owner(desc);
-		wmb();
-	}
-
+			entry += priv->hw->chain->prepare_frm(priv,
+						 skb_frag_address(frag),
+						 skb_frag_size(frag),
+						 csum_insertion, entry);
+
+		entry %= txsize;
+	}
+	/*Set owner for all segment but the first one */
+	for (i = first_entry; i != entry;) {
+		desc = get_desc(priv, i);
+		nb_desc++;
+		if (i != first_entry)
+			priv->hw->desc->set_tx_owner(desc);
+		i++;
+		i %= txsize;
+	}
+	BUG_ON(desc == NULL);
 	/* Finalize the latest segment. */
 	priv->hw->desc->close_tx_desc(desc);
 
-	wmb();
 	/* According to the coalesce parameter the IC bit for the latest
 	 * segment could be reset and the timer re-started to invoke the
 	 * stmmac_tx function. This approach takes care about the fragments.
@@ -1938,11 +1931,20 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else
 		priv->tx_count_frames = 0;
 
+	/*Prepare first segment */
+	priv->tx_skbuff[first_entry] = skb;
+
+	first = get_desc(priv, first_entry);
+
+	priv->hw->desc->set_tx_first(first);
+
+	wmb();
+
 	/* To avoid raise condition */
 	priv->hw->desc->set_tx_owner(first);
 	wmb();
 
-	priv->cur_tx++;
+	priv->cur_tx += nb_desc;
 
 	if (netif_msg_pktdata(priv)) {
 		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
-- 
1.8.1.2
