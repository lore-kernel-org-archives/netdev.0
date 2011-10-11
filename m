From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/5] stmmac: add CHAINED descriptor mode support
Date: Tue, 11 Oct 2011 09:30:42 +0200
Message-ID: <1318318246-1326-2-git-send-email-peppe.cavallaro@st.com>
References: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:40075 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750794Ab1JKHbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 03:31:04 -0400
In-Reply-To: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rayagond Kokatanur <rayagond@vayavyalabs.com>

This patch enhances the STMMAC driver to support CHAINED mode of
descriptor (useful also on validation side).

STMMAC supports DMA descriptor to operate both in dual buffer(RING)
and linked-list(CHAINED) mode. In RING mode (default) each descriptor
points to two data buffer pointers whereas in CHAINED mode they point
to only one data buffer pointer.

In CHAINED mode each descriptor will have pointer to next descriptor in
the list, hence creating the explicit chaining in the descriptor itself,
whereas such explicit chaining is not possible in RING mode.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |   18 +++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   24 +++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   17 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  136 ++++++++++++++++++---
 4 files changed, 171 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 8cd9dde..ac6f190 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -63,4 +63,22 @@ config STMMAC_RTC_TIMER
 
 endchoice
 
+choice
+	prompt "Select the DMA TX/RX descriptor operating modes"
+	depends on STMMAC_ETH
+	---help---
+	  This driver supports DMA descriptor to operate both in dual buffer
+	  (RING) and linked-list(CHAINED) mode. In RING mode each descriptor
+	  points to two data buffer pointers whereas in CHAINED mode they
+	  points to only one data buffer pointer.
+
+config STMMAC_RING
+	bool "Enable Descriptor Ring Mode"
+
+config STMMAC_CHAINED
+	bool "Enable Descriptor Chained Mode"
+
+endchoice
+
+
 endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index e5dfb6a..a5f95dd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -234,9 +234,13 @@ static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 		p->des01.erx.own = 1;
 		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
 		/* To support jumbo frames */
+#if defined(CONFIG_STMMAC_RING)
 		p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
-		if (i == ring_size - 1)
+		if (i == (ring_size - 1))
 			p->des01.erx.end_ring = 1;
+#else
+		p->des01.erx.second_address_chained = 1;
+#endif
 		if (disable_rx_ic)
 			p->des01.erx.disable_ic = 1;
 		p++;
@@ -249,8 +253,12 @@ static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
 
 	for (i = 0; i < ring_size; i++) {
 		p->des01.etx.own = 0;
-		if (i == ring_size - 1)
+#if defined(CONFIG_STMMAC_RING)
+		if (i == (ring_size - 1))
 			p->des01.etx.end_ring = 1;
+#else
+		p->des01.etx.second_address_chained = 1;
+#endif
 		p++;
 	}
 }
@@ -282,22 +290,30 @@ static int enh_desc_get_tx_ls(struct dma_desc *p)
 
 static void enh_desc_release_tx_desc(struct dma_desc *p)
 {
+#if defined(CONFIG_STMMAC_RING)
 	int ter = p->des01.etx.end_ring;
 
 	memset(p, 0, offsetof(struct dma_desc, des2));
 	p->des01.etx.end_ring = ter;
+#else
+	memset(p, 0, offsetof(struct dma_desc, des2));
+	p->des01.etx.second_address_chained = 1;
+#endif
 }
 
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				     int csum_flag)
 {
 	p->des01.etx.first_segment = is_fs;
+
+#if defined(CONFIG_STMMAC_RING)
 	if (unlikely(len > BUF_SIZE_4KiB)) {
 		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
 		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
-	} else {
+	} else
+#endif
 		p->des01.etx.buffer1_size = len;
-	}
+
 	if (likely(csum_flag))
 		p->des01.etx.checksum_insertion = cic_full;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 029c2a2..6c40a38 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -126,8 +126,12 @@ static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 	for (i = 0; i < ring_size; i++) {
 		p->des01.rx.own = 1;
 		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
-		if (i == ring_size - 1)
+#if defined(CONFIG_STMMAC_RING)
+		if (i == (ring_size - 1))
 			p->des01.rx.end_ring = 1;
+#else
+		p->des01.rx.second_address_chained = 1;
+#endif
 		if (disable_rx_ic)
 			p->des01.rx.disable_ic = 1;
 		p++;
@@ -139,8 +143,12 @@ static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
 	int i;
 	for (i = 0; i < ring_size; i++) {
 		p->des01.tx.own = 0;
-		if (i == ring_size - 1)
+#if defined(CONFIG_STMMAC_RING)
+		if (i == (ring_size - 1))
 			p->des01.tx.end_ring = 1;
+#else
+		p->des01.tx.second_address_chained = 1;
+#endif
 		p++;
 	}
 }
@@ -172,11 +180,16 @@ static int ndesc_get_tx_ls(struct dma_desc *p)
 
 static void ndesc_release_tx_desc(struct dma_desc *p)
 {
+#if defined(CONFIG_STMMAC_RING)
 	int ter = p->des01.tx.end_ring;
 
 	memset(p, 0, offsetof(struct dma_desc, des2));
 	/* set termination field */
 	p->des01.tx.end_ring = ter;
+#else
+	memset(p, 0, offsetof(struct dma_desc, des2));
+	p->des01.tx.second_address_chained = 1;
+#endif
 }
 
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c0ee6b6..54f1e76 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -381,11 +381,32 @@ static void display_ring(struct dma_desc *p, int size)
 	}
 }
 
+#if defined(CONFIG_STMMAC_CHAINED)
+/* In chained mode des3 points to the next element in the ring.
+ * The latest element has to point to the head.
+ */
+static void init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
+			   unsigned int size)
+{
+	int i;
+	struct dma_desc *p = des;
+	dma_addr_t dma_phy = phy_addr;
+
+	for (i = 0; i < (size - 1); i++) {
+		dma_phy += sizeof(struct dma_desc);
+		p->des3 = (unsigned int) dma_phy;
+		p++;
+	}
+	p->des3 = (unsigned int) phy_addr;
+}
+#endif
+
 /**
  * init_dma_desc_rings - init the RX/TX descriptor rings
  * @dev: net device structure
  * Description:  this function initializes the DMA RX/TX descriptors
- * and allocates the socket buffers.
+ * and allocates the socket buffers. It suppors the chained and ring
+ * modes.
  */
 static void init_dma_desc_rings(struct net_device *dev)
 {
@@ -395,14 +416,21 @@ static void init_dma_desc_rings(struct net_device *dev)
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int rxsize = priv->dma_rx_size;
 	unsigned int bfsize = priv->dma_buf_sz;
-	int buff2_needed = 0, dis_ic = 0;
+	int dis_ic = 0;
+#if defined(CONFIG_STMMAC_RING)
+	int des3_as_data_buf = 0;
 
 	/* Set the Buffer size according to the MTU;
 	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
+	 * Note that device can handle only 8KiB in chained mode.
+	 * In ring mode if the mtu exceeds the 8KiB use des3.
 	 */
-	if (unlikely(dev->mtu >= BUF_SIZE_8KiB))
+	if (unlikely(dev->mtu >= BUF_SIZE_8KiB)) {
 		bfsize = BUF_SIZE_16KiB;
-	else if (unlikely(dev->mtu >= BUF_SIZE_4KiB))
+		des3_as_data_buf = 1;
+	} else
+#endif
+	if (unlikely(dev->mtu >= BUF_SIZE_4KiB))
 		bfsize = BUF_SIZE_8KiB;
 	else if (unlikely(dev->mtu >= BUF_SIZE_2KiB))
 		bfsize = BUF_SIZE_4KiB;
@@ -416,9 +444,6 @@ static void init_dma_desc_rings(struct net_device *dev)
 	if (likely(priv->tm->enable))
 		dis_ic = 1;
 #endif
-	/* If the MTU exceeds 8k so use the second buffer in the chain */
-	if (bfsize >= BUF_SIZE_8KiB)
-		buff2_needed = 1;
 
 	DBG(probe, INFO, "stmmac: txsize %d, rxsize %d, bfsize %d\n",
 	    txsize, rxsize, bfsize);
@@ -446,9 +471,15 @@ static void init_dma_desc_rings(struct net_device *dev)
 		return;
 	}
 
-	DBG(probe, INFO, "stmmac (%s) DMA desc rings: virt addr (Rx %p, "
+	DBG(probe, INFO, "stmmac (%s) DMA desc %s mode: virt addr (Rx %p, "
 	    "Tx %p)\n\tDMA phy addr (Rx 0x%08x, Tx 0x%08x)\n",
-	    dev->name, priv->dma_rx, priv->dma_tx,
+	    dev->name,
+#if defined(CONFIG_STMMAC_RING)
+		"ring",
+#else
+		"chained",
+#endif
+		priv->dma_rx, priv->dma_tx,
 	    (unsigned int)priv->dma_rx_phy, (unsigned int)priv->dma_tx_phy);
 
 	/* RX INITIALIZATION */
@@ -468,8 +499,11 @@ static void init_dma_desc_rings(struct net_device *dev)
 						bfsize, DMA_FROM_DEVICE);
 
 		p->des2 = priv->rx_skbuff_dma[i];
-		if (unlikely(buff2_needed))
+
+#if defined(CONFIG_STMMAC_RING)
+		if (unlikely(des3_as_data_buf))
 			p->des3 = p->des2 + BUF_SIZE_8KiB;
+#endif
 		DBG(probe, INFO, "[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
 			priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
 	}
@@ -483,6 +517,11 @@ static void init_dma_desc_rings(struct net_device *dev)
 		priv->tx_skbuff[i] = NULL;
 		priv->dma_tx[i].des2 = 0;
 	}
+
+#if defined(CONFIG_STMMAC_CHAINED)
+	init_dma_chain(priv->dma_rx, priv->dma_rx_phy, rxsize);
+	init_dma_chain(priv->dma_tx, priv->dma_tx_phy, txsize);
+#endif
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 
@@ -611,8 +650,10 @@ static void stmmac_tx(struct stmmac_priv *priv)
 			dma_unmap_single(priv->device, p->des2,
 					 priv->hw->desc->get_tx_len(p),
 					 DMA_TO_DEVICE);
+#if defined(CONFIG_STMMAC_RING)
 		if (unlikely(p->des3))
 			p->des3 = 0;
+#endif
 
 		if (likely(skb != NULL)) {
 			/*
@@ -1014,35 +1055,84 @@ static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int entry = priv->cur_tx % txsize;
 	struct dma_desc *desc = priv->dma_tx + entry;
+	unsigned int buf_max_size;
+	int len;
 
-	if (nopaged_len > BUF_SIZE_8KiB) {
+#if defined(CONFIG_STMMAC_RING)
+	if (priv->plat->enh_desc)
+		buf_max_size = BUF_SIZE_8KiB;
+	else
+		buf_max_size = BUF_SIZE_2KiB;
 
-		int buf2_size = nopaged_len - BUF_SIZE_8KiB;
+	len = nopaged_len - buf_max_size;
+
+	if (nopaged_len > BUF_SIZE_8KiB) {
 
 		desc->des2 = dma_map_single(priv->device, skb->data,
-					    BUF_SIZE_8KiB, DMA_TO_DEVICE);
+					    buf_max_size, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 1, BUF_SIZE_8KiB,
+		priv->hw->desc->prepare_tx_desc(desc, 1, buf_max_size,
 						csum_insertion);
 
 		entry = (++priv->cur_tx) % txsize;
 		desc = priv->dma_tx + entry;
 
 		desc->des2 = dma_map_single(priv->device,
-					skb->data + BUF_SIZE_8KiB,
-					buf2_size, DMA_TO_DEVICE);
+					skb->data + buf_max_size,
+					len, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 0, buf2_size,
+		priv->hw->desc->prepare_tx_desc(desc, 0, len,
 						csum_insertion);
 		priv->hw->desc->set_tx_owner(desc);
 		priv->tx_skbuff[entry] = NULL;
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
-					nopaged_len, DMA_TO_DEVICE);
+					    nopaged_len, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion);
 	}
+#else
+	unsigned i = 1;
+
+	if (priv->plat->enh_desc)
+		buf_max_size = BUF_SIZE_8KiB;
+	else
+		buf_max_size = BUF_SIZE_2KiB;
+
+	len = nopaged_len - buf_max_size;
+
+	desc->des2 = dma_map_single(priv->device, skb->data,
+				    buf_max_size, DMA_TO_DEVICE);
+	priv->hw->desc->prepare_tx_desc(desc, 1, buf_max_size,
+					csum_insertion);
+
+	while (len != 0) {
+		entry = (++priv->cur_tx) % txsize;
+		desc = priv->dma_tx + entry;
+
+		if (len > buf_max_size) {
+			desc->des2 = dma_map_single(priv->device,
+						(skb->data + buf_max_size * i),
+						buf_max_size, DMA_TO_DEVICE);
+			priv->hw->desc->prepare_tx_desc(desc, 0, buf_max_size,
+							csum_insertion);
+			priv->hw->desc->set_tx_owner(desc);
+			priv->tx_skbuff[entry] = NULL;
+			len -= buf_max_size;
+			i++;
+		} else {
+			desc->des2 = dma_map_single(priv->device,
+						(skb->data + buf_max_size * i),
+						len, DMA_TO_DEVICE);
+			priv->hw->desc->prepare_tx_desc(desc, 0, len,
+							csum_insertion);
+			priv->hw->desc->set_tx_owner(desc);
+			priv->tx_skbuff[entry] = NULL;
+			len = 0;
+		}
+	}
+#endif
 	return entry;
 }
 
@@ -1094,9 +1184,17 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		       skb->len, skb_headlen(skb), nfrags, skb->ip_summed);
 #endif
 	priv->tx_skbuff[entry] = skb;
+
+#if defined(CONFIG_STMMAC_RING)
 	if (unlikely(skb->len >= BUF_SIZE_4KiB)) {
 		entry = stmmac_handle_jumbo_frames(skb, dev, csum_insertion);
 		desc = priv->dma_tx + entry;
+#else
+	if ((priv->plat->enh_desc && unlikely(skb->len > BUF_SIZE_8KiB)) ||
+	(!priv->plat->enh_desc && unlikely(skb->len > BUF_SIZE_2KiB))) {
+		entry = stmmac_handle_jumbo_frames(skb, dev, csum_insertion);
+		desc = priv->dma_tx + entry;
+#endif
 	} else {
 		unsigned int nopaged_len = skb_headlen(skb);
 		desc->des2 = dma_map_single(priv->device, skb->data,
@@ -1187,11 +1285,13 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 					   DMA_FROM_DEVICE);
 
 			(p + entry)->des2 = priv->rx_skbuff_dma[entry];
+#if defined(CONFIG_STMMAC_RING)
 			if (unlikely(priv->plat->has_gmac)) {
 				if (bfsize >= BUF_SIZE_8KiB)
 					(p + entry)->des3 =
 					    (p + entry)->des2 + BUF_SIZE_8KiB;
 			}
+#endif
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
 		wmb();
-- 
1.7.4.4
