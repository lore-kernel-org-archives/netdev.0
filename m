From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 04/17] stmmac: review RX/TX ring management
Date: Mon, 29 Feb 2016 14:27:30 +0100
Message-ID: <1456752463-27128-5-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:19066 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755279AbcB2N22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:28 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDQNG7032766
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:26 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx07-00178001.pphosted.com with ESMTP id 21b254tvcg-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:21 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 3F7FB22
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:17 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id C6D96F7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:15 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This patch is to rework the ring management now optimized.
The indexes into the ring buffer are always incremented, and
the entry is accessed via doing a modulo to find the "real"
position in the ring.
It is inefficient, modulo is an expensive operation.

The formula [(entry + 1) & (size - 1)] is now adopted on
a ring that is power-of-2 in size.
Then, the number of elements cannot be set by command line but
it is fixed.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index cf28dab..2763772 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -31,8 +31,7 @@
 static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)p;
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry = priv->cur_tx % txsize;
+	unsigned int entry = priv->cur_tx;
 	struct dma_desc *desc = priv->dma_tx + entry;
 	unsigned int nopaged_len = skb_headlen(skb);
 	unsigned int bmax;
@@ -54,7 +53,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 	while (len != 0) {
 		priv->tx_skbuff[entry] = NULL;
-		entry = (++priv->cur_tx) % txsize;
+		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 		desc = priv->dma_tx + entry;
 
 		if (len > bmax) {
@@ -82,6 +81,9 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			len = 0;
 		}
 	}
+
+	priv->cur_tx = entry;
+
 	return entry;
 }
 
@@ -138,7 +140,7 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 		 */
 		p->des3 = (unsigned int)(priv->dma_rx_phy +
 					 (((priv->dirty_rx) + 1) %
-					  priv->dma_rx_size) *
+					  DMA_RX_SIZE) *
 					 sizeof(struct dma_desc));
 }
 
@@ -151,10 +153,9 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
 		 */
-		p->des3 = (unsigned int)(priv->dma_tx_phy +
-					 (((priv->dirty_tx + 1) %
-					   priv->dma_tx_size) *
-					  sizeof(struct dma_desc)));
+		p->des3 = (unsigned int)((priv->dma_tx_phy +
+					  ((priv->dirty_tx + 1) % DMA_TX_SIZE))
+					  * sizeof(struct dma_desc));
 }
 
 const struct stmmac_mode_ops chain_mode_ops = {
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 586a336..09291af 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -42,6 +42,10 @@
 #define	DWMAC_CORE_3_40	0x34
 #define	DWMAC_CORE_3_50	0x35
 
+#define DMA_TX_SIZE 512
+#define DMA_RX_SIZE 512
+#define STMMAC_GET_ENTRY(x, size)	((x + 1) & (size - 1))
+
 #undef FRAME_FILTER_DEBUG
 /* #define FRAME_FILTER_DEBUG */
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 5dd50c6..4358a87 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -31,8 +31,7 @@
 static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)p;
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry = priv->cur_tx % txsize;
+	unsigned int entry = priv->cur_tx;
 	struct dma_desc *desc;
 	unsigned int nopaged_len = skb_headlen(skb);
 	unsigned int bmax, len;
@@ -62,7 +61,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 						STMMAC_RING_MODE);
 		wmb();
 		priv->tx_skbuff[entry] = NULL;
-		entry = (++priv->cur_tx) % txsize;
+		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 
 		if (priv->extend_desc)
 			desc = (struct dma_desc *)(priv->dma_etx + entry);
@@ -90,6 +89,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 						STMMAC_RING_MODE);
 	}
 
+	priv->cur_tx = entry;
+
 	return entry;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 1f3b33a..7ae7c64 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -54,7 +54,6 @@ struct stmmac_priv {
 	struct sk_buff **tx_skbuff;
 	unsigned int cur_tx;
 	unsigned int dirty_tx;
-	unsigned int dma_tx_size;
 	u32 tx_count_frames;
 	u32 tx_coal_frames;
 	u32 tx_coal_timer;
@@ -71,7 +70,6 @@ struct stmmac_priv {
 	struct sk_buff **rx_skbuff;
 	unsigned int cur_rx;
 	unsigned int dirty_rx;
-	unsigned int dma_rx_size;
 	unsigned int dma_buf_sz;
 	u32 rx_riwt;
 	int hwts_rx_en;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 89c2626..eb555f0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -71,15 +71,7 @@ static int phyaddr = -1;
 module_param(phyaddr, int, S_IRUGO);
 MODULE_PARM_DESC(phyaddr, "Physical device address");
 
-#define DMA_TX_SIZE 256
-static int dma_txsize = DMA_TX_SIZE;
-module_param(dma_txsize, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(dma_txsize, "Number of descriptors in the TX list");
-
-#define DMA_RX_SIZE 256
-static int dma_rxsize = DMA_RX_SIZE;
-module_param(dma_rxsize, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(dma_rxsize, "Number of descriptors in the RX list");
+#define STMMAC_TX_THRESH	(DMA_TX_SIZE / 4)
 
 static int flow_ctrl = FLOW_OFF;
 module_param(flow_ctrl, int, S_IRUGO | S_IWUSR);
@@ -134,10 +126,6 @@ static void stmmac_verify_args(void)
 {
 	if (unlikely(watchdog < 0))
 		watchdog = TX_TIMEO;
-	if (unlikely(dma_rxsize < 0))
-		dma_rxsize = DMA_RX_SIZE;
-	if (unlikely(dma_txsize < 0))
-		dma_txsize = DMA_TX_SIZE;
 	if (unlikely((buf_sz < DEFAULT_BUFSIZE) || (buf_sz > BUF_SIZE_16KiB)))
 		buf_sz = DEFAULT_BUFSIZE;
 	if (unlikely(flow_ctrl > 1))
@@ -197,12 +185,28 @@ static void print_pkt(unsigned char *buf, int len)
 	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, buf, len);
 }
 
-/* minimum number of free TX descriptors required to wake up TX process */
-#define STMMAC_TX_THRESH(x)	(x->dma_tx_size/4)
-
 static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 {
-	return priv->dirty_tx + priv->dma_tx_size - priv->cur_tx - 1;
+	unsigned avail;
+
+	if (priv->dirty_tx > priv->cur_tx)
+		avail = priv->dirty_tx - priv->cur_tx - 1;
+	else
+		avail = DMA_TX_SIZE - priv->cur_tx + priv->dirty_tx - 1;
+
+	return avail;
+}
+
+static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv)
+{
+	unsigned dirty;
+
+	if (priv->dirty_rx <= priv->cur_rx)
+		dirty = priv->cur_rx - priv->dirty_rx;
+	else
+		dirty = DMA_RX_SIZE - priv->dirty_rx + priv->cur_rx;
+
+	return dirty;
 }
 
 /**
@@ -906,19 +910,16 @@ static void stmmac_display_ring(void *head, int size, int extend_desc)
 
 static void stmmac_display_rings(struct stmmac_priv *priv)
 {
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int rxsize = priv->dma_rx_size;
-
 	if (priv->extend_desc) {
 		pr_info("Extended RX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
+		stmmac_display_ring((void *)priv->dma_erx, DMA_RX_SIZE, 1);
 		pr_info("Extended TX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
+		stmmac_display_ring((void *)priv->dma_etx, DMA_TX_SIZE, 1);
 	} else {
 		pr_info("RX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
+		stmmac_display_ring((void *)priv->dma_rx, DMA_RX_SIZE, 0);
 		pr_info("TX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_tx, txsize, 0);
+		stmmac_display_ring((void *)priv->dma_tx, DMA_TX_SIZE, 0);
 	}
 }
 
@@ -947,28 +948,26 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 static void stmmac_clear_descriptors(struct stmmac_priv *priv)
 {
 	int i;
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int rxsize = priv->dma_rx_size;
 
 	/* Clear the Rx/Tx descriptors */
-	for (i = 0; i < rxsize; i++)
+	for (i = 0; i < DMA_RX_SIZE; i++)
 		if (priv->extend_desc)
 			priv->hw->desc->init_rx_desc(&priv->dma_erx[i].basic,
 						     priv->use_riwt, priv->mode,
-						     (i == rxsize - 1));
+						     (i == DMA_RX_SIZE - 1));
 		else
 			priv->hw->desc->init_rx_desc(&priv->dma_rx[i],
 						     priv->use_riwt, priv->mode,
-						     (i == rxsize - 1));
-	for (i = 0; i < txsize; i++)
+						     (i == DMA_RX_SIZE - 1));
+	for (i = 0; i < DMA_TX_SIZE; i++)
 		if (priv->extend_desc)
 			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
 						     priv->mode,
-						     (i == txsize - 1));
+						     (i == DMA_TX_SIZE - 1));
 		else
 			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
 						     priv->mode,
-						     (i == txsize - 1));
+						     (i == DMA_TX_SIZE - 1));
 }
 
 /**
@@ -1031,8 +1030,6 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 {
 	int i;
 	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int rxsize = priv->dma_rx_size;
 	unsigned int bfsize = 0;
 	int ret = -ENOMEM;
 
@@ -1044,10 +1041,6 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 
 	priv->dma_buf_sz = bfsize;
 
-	if (netif_msg_probe(priv))
-		pr_debug("%s: txsize %d, rxsize %d, bfsize %d\n", __func__,
-			 txsize, rxsize, bfsize);
-
 	if (netif_msg_probe(priv)) {
 		pr_debug("(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n", __func__,
 			 (u32) priv->dma_rx_phy, (u32) priv->dma_tx_phy);
@@ -1055,7 +1048,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		/* RX INITIALIZATION */
 		pr_debug("\tSKB addresses:\nskb\t\tskb data\tdma data\n");
 	}
-	for (i = 0; i < rxsize; i++) {
+	for (i = 0; i < DMA_RX_SIZE; i++) {
 		struct dma_desc *p;
 		if (priv->extend_desc)
 			p = &((priv->dma_erx + i)->basic);
@@ -1072,26 +1065,26 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 				 (unsigned int)priv->rx_skbuff_dma[i]);
 	}
 	priv->cur_rx = 0;
-	priv->dirty_rx = (unsigned int)(i - rxsize);
+	priv->dirty_rx = (unsigned int)(i - DMA_RX_SIZE);
 	buf_sz = bfsize;
 
 	/* Setup the chained descriptor addresses */
 	if (priv->mode == STMMAC_CHAIN_MODE) {
 		if (priv->extend_desc) {
 			priv->hw->mode->init(priv->dma_erx, priv->dma_rx_phy,
-					     rxsize, 1);
+					     DMA_RX_SIZE, 1);
 			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
-					     txsize, 1);
+					     DMA_TX_SIZE, 1);
 		} else {
 			priv->hw->mode->init(priv->dma_rx, priv->dma_rx_phy,
-					     rxsize, 0);
+					     DMA_RX_SIZE, 0);
 			priv->hw->mode->init(priv->dma_tx, priv->dma_tx_phy,
-					     txsize, 0);
+					     DMA_TX_SIZE, 0);
 		}
 	}
 
 	/* TX INITIALIZATION */
-	for (i = 0; i < txsize; i++) {
+	for (i = 0; i < DMA_TX_SIZE; i++) {
 		struct dma_desc *p;
 		if (priv->extend_desc)
 			p = &((priv->dma_etx + i)->basic);
@@ -1123,7 +1116,7 @@ static void dma_free_rx_skbufs(struct stmmac_priv *priv)
 {
 	int i;
 
-	for (i = 0; i < priv->dma_rx_size; i++)
+	for (i = 0; i < DMA_RX_SIZE; i++)
 		stmmac_free_rx_buffers(priv, i);
 }
 
@@ -1131,7 +1124,7 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 {
 	int i;
 
-	for (i = 0; i < priv->dma_tx_size; i++) {
+	for (i = 0; i < DMA_TX_SIZE; i++) {
 		struct dma_desc *p;
 
 		if (priv->extend_desc)
@@ -1171,33 +1164,31 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
  */
 static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 {
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int rxsize = priv->dma_rx_size;
 	int ret = -ENOMEM;
 
-	priv->rx_skbuff_dma = kmalloc_array(rxsize, sizeof(dma_addr_t),
+	priv->rx_skbuff_dma = kmalloc_array(DMA_RX_SIZE, sizeof(dma_addr_t),
 					    GFP_KERNEL);
 	if (!priv->rx_skbuff_dma)
 		return -ENOMEM;
 
-	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
+	priv->rx_skbuff = kmalloc_array(DMA_RX_SIZE, sizeof(struct sk_buff *),
 					GFP_KERNEL);
 	if (!priv->rx_skbuff)
 		goto err_rx_skbuff;
 
-	priv->tx_skbuff_dma = kmalloc_array(txsize,
+	priv->tx_skbuff_dma = kmalloc_array(DMA_TX_SIZE,
 					    sizeof(*priv->tx_skbuff_dma),
 					    GFP_KERNEL);
 	if (!priv->tx_skbuff_dma)
 		goto err_tx_skbuff_dma;
 
-	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
+	priv->tx_skbuff = kmalloc_array(DMA_TX_SIZE, sizeof(struct sk_buff *),
 					GFP_KERNEL);
 	if (!priv->tx_skbuff)
 		goto err_tx_skbuff;
 
 	if (priv->extend_desc) {
-		priv->dma_erx = dma_zalloc_coherent(priv->device, rxsize *
+		priv->dma_erx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
 						    sizeof(struct
 							   dma_extended_desc),
 						    &priv->dma_rx_phy,
@@ -1205,31 +1196,31 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 		if (!priv->dma_erx)
 			goto err_dma;
 
-		priv->dma_etx = dma_zalloc_coherent(priv->device, txsize *
+		priv->dma_etx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
 						    sizeof(struct
 							   dma_extended_desc),
 						    &priv->dma_tx_phy,
 						    GFP_KERNEL);
 		if (!priv->dma_etx) {
-			dma_free_coherent(priv->device, priv->dma_rx_size *
+			dma_free_coherent(priv->device, DMA_RX_SIZE *
 					  sizeof(struct dma_extended_desc),
 					  priv->dma_erx, priv->dma_rx_phy);
 			goto err_dma;
 		}
 	} else {
-		priv->dma_rx = dma_zalloc_coherent(priv->device, rxsize *
+		priv->dma_rx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
 						   sizeof(struct dma_desc),
 						   &priv->dma_rx_phy,
 						   GFP_KERNEL);
 		if (!priv->dma_rx)
 			goto err_dma;
 
-		priv->dma_tx = dma_zalloc_coherent(priv->device, txsize *
+		priv->dma_tx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
 						   sizeof(struct dma_desc),
 						   &priv->dma_tx_phy,
 						   GFP_KERNEL);
 		if (!priv->dma_tx) {
-			dma_free_coherent(priv->device, priv->dma_rx_size *
+			dma_free_coherent(priv->device, DMA_RX_SIZE *
 					  sizeof(struct dma_desc),
 					  priv->dma_rx, priv->dma_rx_phy);
 			goto err_dma;
@@ -1258,16 +1249,16 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 	/* Free DMA regions of consistent memory previously allocated */
 	if (!priv->extend_desc) {
 		dma_free_coherent(priv->device,
-				  priv->dma_tx_size * sizeof(struct dma_desc),
+				  DMA_TX_SIZE * sizeof(struct dma_desc),
 				  priv->dma_tx, priv->dma_tx_phy);
 		dma_free_coherent(priv->device,
-				  priv->dma_rx_size * sizeof(struct dma_desc),
+				  DMA_RX_SIZE * sizeof(struct dma_desc),
 				  priv->dma_rx, priv->dma_rx_phy);
 	} else {
-		dma_free_coherent(priv->device, priv->dma_tx_size *
+		dma_free_coherent(priv->device, DMA_TX_SIZE *
 				  sizeof(struct dma_extended_desc),
 				  priv->dma_etx, priv->dma_tx_phy);
-		dma_free_coherent(priv->device, priv->dma_rx_size *
+		dma_free_coherent(priv->device, DMA_RX_SIZE *
 				  sizeof(struct dma_extended_desc),
 				  priv->dma_erx, priv->dma_rx_phy);
 	}
@@ -1312,16 +1303,15 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
  */
 static void stmmac_tx_clean(struct stmmac_priv *priv)
 {
-	unsigned int txsize = priv->dma_tx_size;
 	unsigned int bytes_compl = 0, pkts_compl = 0;
+	unsigned int entry = priv->dirty_tx;
 
 	spin_lock(&priv->tx_lock);
 
 	priv->xstats.tx_clean++;
 
-	while (priv->dirty_tx != priv->cur_tx) {
+	while (entry != priv->cur_tx) {
 		int last;
-		unsigned int entry = priv->dirty_tx % txsize;
 		struct sk_buff *skb = priv->tx_skbuff[entry];
 		struct dma_desc *p;
 
@@ -1378,16 +1368,17 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 		priv->hw->desc->release_tx_desc(p, priv->mode);
 
-		priv->dirty_tx++;
+		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
+		priv->dirty_tx = entry;
 	}
 
 	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
 
 	if (unlikely(netif_queue_stopped(priv->dev) &&
-		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv))) {
+		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
 		netif_tx_lock(priv->dev);
 		if (netif_queue_stopped(priv->dev) &&
-		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
+		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {
 			if (netif_msg_tx_done(priv))
 				pr_debug("%s: restart transmit\n", __func__);
 			netif_wake_queue(priv->dev);
@@ -1421,20 +1412,19 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
 static void stmmac_tx_err(struct stmmac_priv *priv)
 {
 	int i;
-	int txsize = priv->dma_tx_size;
 	netif_stop_queue(priv->dev);
 
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	dma_free_tx_skbufs(priv);
-	for (i = 0; i < txsize; i++)
+	for (i = 0; i < DMA_TX_SIZE; i++)
 		if (priv->extend_desc)
 			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
 						     priv->mode,
-						     (i == txsize - 1));
+						     (i == DMA_TX_SIZE - 1));
 		else
 			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
 						     priv->mode,
-						     (i == txsize - 1));
+						     (i == DMA_TX_SIZE - 1));
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 	netdev_reset_queue(priv->dev);
@@ -1811,9 +1801,6 @@ static int stmmac_open(struct net_device *dev)
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
 
-	/* Create and initialize the TX/RX descriptors chains. */
-	priv->dma_tx_size = STMMAC_ALIGN(dma_txsize);
-	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
 	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
 
 	ret = alloc_dma_desc_resources(priv);
@@ -1955,7 +1942,6 @@ static int stmmac_release(struct net_device *dev)
 static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned int txsize = priv->dma_tx_size;
 	int entry;
 	int i, csum_insertion = 0, is_jumbo = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
@@ -1978,7 +1964,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (priv->tx_path_in_lpi_mode)
 		stmmac_disable_eee_mode(priv);
 
-	entry = priv->cur_tx % txsize;
+	entry = priv->cur_tx;
+
 
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
 
@@ -2013,7 +2000,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		int len = skb_frag_size(frag);
 
 		priv->tx_skbuff[entry] = NULL;
-		entry = (++priv->cur_tx) % txsize;
+		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
+
 		if (priv->extend_desc)
 			desc = (struct dma_desc *)(priv->dma_etx + entry);
 		else
@@ -2056,17 +2044,21 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->hw->desc->set_tx_owner(first);
 	wmb();
 
-	priv->cur_tx++;
+	entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
+
+	priv->cur_tx = entry;
 
 	if (netif_msg_pktdata(priv)) {
 		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
-			__func__, (priv->cur_tx % txsize),
-			(priv->dirty_tx % txsize), entry, first, nfrags);
+			__func__, (priv->cur_tx % DMA_TX_SIZE),
+			(priv->dirty_tx % DMA_TX_SIZE), entry, first, nfrags);
 
 		if (priv->extend_desc)
-			stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
+			stmmac_display_ring((void *)priv->dma_etx,
+					    DMA_TX_SIZE, 1);
 		else
-			stmmac_display_ring((void *)priv->dma_tx, txsize, 0);
+			stmmac_display_ring((void *)priv->dma_tx,
+					    DMA_TX_SIZE, 0);
 
 		pr_debug(">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
@@ -2128,11 +2120,11 @@ static void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
  */
 static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 {
-	unsigned int rxsize = priv->dma_rx_size;
 	int bfsize = priv->dma_buf_sz;
+	unsigned int entry = priv->dirty_rx;
+	int dirty = stmmac_rx_dirty(priv);
 
-	for (; priv->cur_rx - priv->dirty_rx > 0; priv->dirty_rx++) {
-		unsigned int entry = priv->dirty_rx % rxsize;
+	while (dirty-- > 0) {
 		struct dma_desc *p;
 
 		if (priv->extend_desc)
@@ -2168,7 +2160,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
 		wmb();
+
+		entry = STMMAC_GET_ENTRY(entry, DMA_RX_SIZE);
 	}
+	priv->dirty_rx = entry;
 }
 
 /**
@@ -2180,8 +2175,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
  */
 static int stmmac_rx(struct stmmac_priv *priv, int limit)
 {
-	unsigned int rxsize = priv->dma_rx_size;
-	unsigned int entry = priv->cur_rx % rxsize;
+	unsigned int entry = priv->cur_rx;
 	unsigned int next_entry;
 	unsigned int count = 0;
 	int coe = priv->hw->rx_csum;
@@ -2189,9 +2183,11 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	if (netif_msg_rx_status(priv)) {
 		pr_debug("%s: descriptor ring:\n", __func__);
 		if (priv->extend_desc)
-			stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
+			stmmac_display_ring((void *)priv->dma_erx,
+					    DMA_RX_SIZE, 1);
 		else
-			stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
+			stmmac_display_ring((void *)priv->dma_rx,
+					    DMA_RX_SIZE, 0);
 	}
 	while (count < limit) {
 		int status;
@@ -2207,7 +2203,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 		count++;
 
-		next_entry = (++priv->cur_rx) % rxsize;
+		priv->cur_rx = STMMAC_GET_ENTRY(priv->cur_rx, DMA_RX_SIZE);
+		next_entry = priv->cur_rx;
+
 		if (priv->extend_desc)
 			prefetch(priv->dma_erx + next_entry);
 		else
@@ -2567,19 +2565,17 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 {
 	struct net_device *dev = seq->private;
 	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int rxsize = priv->dma_rx_size;
 
 	if (priv->extend_desc) {
 		seq_printf(seq, "Extended RX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_erx, rxsize, 1, seq);
+		sysfs_display_ring((void *)priv->dma_erx, DMA_RX_SIZE, 1, seq);
 		seq_printf(seq, "Extended TX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_etx, txsize, 1, seq);
+		sysfs_display_ring((void *)priv->dma_etx, DMA_TX_SIZE, 1, seq);
 	} else {
 		seq_printf(seq, "RX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_rx, rxsize, 0, seq);
+		sysfs_display_ring((void *)priv->dma_rx, DMA_RX_SIZE, 0, seq);
 		seq_printf(seq, "TX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_tx, txsize, 0, seq);
+		sysfs_display_ring((void *)priv->dma_tx, DMA_TX_SIZE, 0, seq);
 	}
 
 	return 0;
@@ -3149,12 +3145,6 @@ static int __init stmmac_cmdline_opt(char *str)
 		} else if (!strncmp(opt, "phyaddr:", 8)) {
 			if (kstrtoint(opt + 8, 0, &phyaddr))
 				goto err;
-		} else if (!strncmp(opt, "dma_txsize:", 11)) {
-			if (kstrtoint(opt + 11, 0, &dma_txsize))
-				goto err;
-		} else if (!strncmp(opt, "dma_rxsize:", 11)) {
-			if (kstrtoint(opt + 11, 0, &dma_rxsize))
-				goto err;
 		} else if (!strncmp(opt, "buf_sz:", 7)) {
 			if (kstrtoint(opt + 7, 0, &buf_sz))
 				goto err;
-- 
1.9.1
